[CmdletBinding()]
param(
    [string]$WorkspaceRoot,
    [string]$CurrentTaskPath = ".ai/current-task.md",
    [string]$HandoffPath = ".ai/handoff.md",
    # Optional expected-state values, decided by the responsible role at a real
    # boundary. Binding is tested with $PSBoundParameters so an omitted value
    # is distinguishable from an explicit empty string or numeric 0.
    [string]$ExpectedBatchId,
    [string]$ExpectedNextAction,
    [string]$ExpectedNextRole,
    [string]$ExpectedReviewRound,
    [string]$ExpectedStateRevision
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $WorkspaceRoot) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
}

$WorkspaceRoot = [IO.Path]::GetFullPath($WorkspaceRoot)
$errors = [Collections.Generic.List[string]]::new()
$warnings = [Collections.Generic.List[string]]::new()

function Add-ValidationError {
    param([string]$Message)
    $script:errors.Add($Message)
}

function Add-ValidationWarning {
    param([string]$Message)
    if (-not $script:warnings.Contains($Message)) {
        $script:warnings.Add($Message)
    }
}

$expectationRequested = $false
foreach ($expectationParameter in @(
    'ExpectedBatchId', 'ExpectedNextAction', 'ExpectedNextRole',
    'ExpectedReviewRound', 'ExpectedStateRevision'
)) {
    if ($PSBoundParameters.ContainsKey($expectationParameter)) {
        $expectationRequested = $true
    }
}
$matchedExpectationFields = [Collections.Generic.List[string]]::new()

function Get-NormalizedDecimal {
    param([string]$Value)

    $trimmed = $Value.TrimStart("0")
    if ($trimmed -eq "") {
        return "0"
    }
    return $trimmed
}

# Expectation values are identity text, so comparisons use ordinal code units.
# Culture-sensitive operators can treat different Unicode sequences as equal.
function Test-OrdinalEqual {
    param([AllowNull()][string]$Left, [AllowNull()][string]$Right)

    return [string]::Equals($Left, $Right, [StringComparison]::Ordinal)
}

function Test-OrdinalMember {
    param([AllowNull()][string]$Value, [string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        if (Test-OrdinalEqual $Value $candidate) {
            return $true
        }
    }
    return $false
}

# Local to the expectation reader: drop a legal closing ATX sequence such as
# "## Routing ##" so that the same real heading is counted once.
function Get-ExpectationHeadingTitle {
    param([string]$Title)

    return ([regex]::Replace($Title, '[ \t]+#+[ \t]*\z', '')).Trim()
}

function Resolve-WorkspacePath {
    param([string]$Path)

    $candidate = $Path.Split("#", 2)[0]
    try {
        if ([IO.Path]::IsPathRooted($candidate)) {
            $fullPath = [IO.Path]::GetFullPath($candidate)
        } else {
            $fullPath = [IO.Path]::GetFullPath((Join-Path $WorkspaceRoot $candidate))
        }
    } catch {
        Add-ValidationError "Path is invalid: $Path"
        return $null
    }

    $rootPrefix = $WorkspaceRoot.TrimEnd("\", "/") + [IO.Path]::DirectorySeparatorChar
    if (
        $fullPath -ne $WorkspaceRoot -and
        -not $fullPath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)
    ) {
        Add-ValidationError "Path escapes workspace: $Path"
        return $null
    }

    return $fullPath
}

function Get-FieldValue {
    param(
        [string]$Text,
        [string]$Name
    )

    $pattern = "(?m)^- " + [regex]::Escape($Name) +
        ":[ \t]*(?:``(?<quoted>[^``\r\n]+)``|(?<plain>[^\r\n]+))\s*$"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return $null
    }

    if ($match.Groups["quoted"].Success) {
        return $match.Groups["quoted"].Value.Trim()
    }

    return $match.Groups["plain"].Value.Trim()
}

function Get-Section {
    param(
        [string]$Text,
        [string]$Heading
    )

    $structure = Get-MarkdownStructure $Text
    $sectionHeading = $structure.Headings |
        Where-Object { $_.Level -eq 2 -and $_.Title -eq $Heading } |
        Select-Object -First 1
    if ($null -eq $sectionHeading) {
        return $null
    }
    return (Get-MarkdownHeadingBody $Text $structure.Headings $sectionHeading 2).Text.Trim()
}

function Get-SectionFieldContent {
    param(
        [string]$Text,
        [string]$Name
    )

    $pattern = "(?ms)^- " + [regex]::Escape($Name) +
        ":[ \t]*(?<value>.*?)(?=^- [A-Za-z][^:\r\n]+:|\z)"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return $null
    }

    # A real subsection ends the field; fenced headings remain value content.
    $valueStart = $match.Groups["value"].Index
    $valueEnd = $valueStart + $match.Groups["value"].Length
    foreach ($heading in (Get-MarkdownStructure $Text).Headings) {
        if ($heading.Start -ge $valueStart -and $heading.Start -lt $valueEnd) {
            $valueEnd = $heading.Start
            break
        }
    }
    $val = $Text.Substring($valueStart, $valueEnd - $valueStart).Trim()
    if ([string]::IsNullOrWhiteSpace($val)) {
        return $null
    }
    return $val
}

function Get-ReviewBudgetExtension {
    # Parses a structured finite review-budget extension from a Task Owner
    # decision value. Returns $null for an absent value or an ordinary
    # (non-extension) decision, which grants no budget capacity. Otherwise
    # returns an object with IsValid, Reason, and the parsed fields.
    # Field separator is ';' (owner identity may contain spaces). No new
    # routing field is read; only the existing Task Owner decision value.
    param([string]$DecisionValue)

    if ([string]::IsNullOrWhiteSpace($DecisionValue)) {
        return $null
    }
    # The extension is a single structured first line; later prose bullets in
    # the same field are context, not additional keys.
    $firstLine = @($DecisionValue -split "`r?`n" |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' }) | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($firstLine)) {
        return $null
    }
    $normalized = $firstLine.Trim('`').Trim('"').Trim("'").Trim()
    if (-not $normalized.StartsWith(
        'review-budget-extension', [StringComparison]::Ordinal
    )) {
        return $null
    }
    $segments = @($normalized -split ';' | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' })
    if ($segments.Count -eq 0 -or $segments[0] -ne 'review-budget-extension') {
        return [pscustomobject]@{
            IsValid = $false
            Reason  = 'malformed review-budget-extension head'
        }
    }
    $fields = @{}
    foreach ($segment in @($segments | Select-Object -Skip 1)) {
        $equals = $segment.IndexOf('=')
        if ($equals -le 0) {
            return [pscustomobject]@{
                IsValid = $false
                Reason  = 'malformed review-budget-extension segment'
            }
        }
        $key = $segment.Substring(0, $equals).Trim()
        $value = $segment.Substring($equals + 1).Trim()
        if ($key -notin @(
            'owner', 'date', 'batch', 'from', 'through', 'scope', 'evidence'
        )) {
            return [pscustomobject]@{
                IsValid = $false
                Reason  = 'unknown review-budget-extension key'
            }
        }
        if ($fields.ContainsKey($key)) {
            return [pscustomobject]@{
                IsValid = $false
                Reason  = 'duplicate review-budget-extension key'
            }
        }
        $fields[$key] = $value
    }
    foreach ($required in @(
        'owner', 'date', 'batch', 'from', 'through', 'scope', 'evidence'
    )) {
        if (-not $fields.ContainsKey($required) -or
            [string]::IsNullOrWhiteSpace($fields[$required])) {
            return [pscustomobject]@{
                IsValid = $false
                Reason  = 'incomplete review-budget-extension'
            }
        }
    }
    if ($fields['date'] -notmatch '^\d{4}-\d{2}-\d{2}$') {
        return [pscustomobject]@{
            IsValid = $false
            Reason  = 'invalid review-budget-extension date'
        }
    }
    try {
        [void][datetime]::ParseExact(
            $fields['date'], 'yyyy-MM-dd',
            [Globalization.CultureInfo]::InvariantCulture
        )
    } catch {
        return [pscustomobject]@{
            IsValid = $false
            Reason  = 'invalid review-budget-extension date'
        }
    }
    foreach ($bound in @('from', 'through')) {
        if ($fields[$bound] -notmatch '^\d+$' -or
            $fields[$bound].TrimStart('0').Length -gt 9) {
            return [pscustomobject]@{
                IsValid = $false
                Reason  = 'invalid review-budget-extension bound'
            }
        }
    }
    $from = [int]$fields['from']
    $through = [int]$fields['through']
    if ($through -le $from) {
        return [pscustomobject]@{
            IsValid = $false
            Reason  = 'invalid review-budget-extension ceiling'
        }
    }
    return [pscustomobject]@{
        IsValid = $true
        Reason  = ''
        Owner   = $fields['owner']
        Date    = $fields['date']
        Batch   = $fields['batch']
        From    = $from
        Through = $through
        Scope   = $fields['scope']
        Evidence = $fields['evidence']
    }
}

function Test-ReviewBudgetExtension {
    # True only when a parsed extension is valid, names this batch, and the
    # current completed count still holds unused capacity (from <= N < through).
    # Structure alone authenticates no owner, history, or independence.
    param(
        $Extension,
        [string]$CurrentBatch,
        [string]$ReviewRound
    )

    if ($null -eq $Extension -or -not $Extension.IsValid) {
        return $false
    }
    if ([string]::IsNullOrWhiteSpace($CurrentBatch) -or
        $Extension.Batch -cne $CurrentBatch) {
        return $false
    }
    if ($ReviewRound -notmatch '^\d+$' -or
        $ReviewRound.TrimStart('0').Length -gt 9) {
        return $false
    }
    $count = [int]$ReviewRound
    return ($count -ge $Extension.From -and $count -lt $Extension.Through)
}

function Get-ItemFieldValue {
    param(
        [string]$Text,
        [string]$Name
    )

    $pattern = "(?m)^- " + [regex]::Escape($Name) +
        ":[ \t]*(?:``(?<quoted>[^``\r\n]+)``|(?<plain>[^\r\n]+))\s*$"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return $null
    }

    if ($match.Groups["quoted"].Success) {
        return $match.Groups["quoted"].Value.Trim()
    }

    return $match.Groups["plain"].Value.Trim()
}

function Get-ItemFieldContent {
    param(
        [string]$Text,
        [string]$Name
    )

    $pattern = "(?ms)^- " + [regex]::Escape($Name) +
        ":[ \t]*(?<value>.*?)(?=^- [A-Za-z][^:\r\n]+:|^ {0,3}#{1,6}[ \t]+|\z)"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return $null
    }

    $val = $match.Groups["value"].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($val)) {
        return $null
    }
    if ($val.StartsWith("``") -and $val.EndsWith("``") -and $val.Length -ge 2) {
        $val = $val.Substring(1, $val.Length - 2).Trim()
    }
    return $val
}

function Get-MarkdownStructure {
    param([string]$Text)

    $headings = [Collections.Generic.List[object]]::new()
    $unfencedLines = [Collections.Generic.List[string]]::new()
    $openFence = $null
    foreach ($line in [regex]::Matches($Text, '[^\r\n]+(?:\r?\n|\z)|\r?\n')) {
        $lineText = $line.Value.TrimEnd("`r", "`n")
        if ($null -ne $openFence) {
            $closingPattern = '^[ \t]*' + [regex]::Escape($openFence.Marker) + '{' + $openFence.Length + ',}[ \t]*$'
            if ($lineText -match $closingPattern) {
                $openFence = $null
            }
            continue
        }
        $fence = [regex]::Match($lineText, '^[ \t]*(?<marker>`{3,}|~{3,})[^\r\n]*$')
        if ($fence.Success) {
            $openFence = [pscustomobject]@{
                Marker = $fence.Groups['marker'].Value.Substring(0, 1)
                Length = $fence.Groups['marker'].Value.Length
            }
            continue
        }
        $unfencedLines.Add($lineText)
        $heading = [regex]::Match($lineText, '^ {0,3}(?<level>#{1,6})[ \t]+(?<title>.*)$')
        if ($heading.Success) {
            $headings.Add([pscustomobject]@{
                Start = $line.Index
                End = $line.Index + $line.Length
                Level = $heading.Groups['level'].Value.Length
                Title = $heading.Groups['title'].Value.Trim()
            })
        }
    }
    return [pscustomobject]@{
        Headings = $headings.ToArray()
        UnfencedText = $unfencedLines -join "`n"
    }
}

function Get-MarkdownHeadingBody {
    param([string]$Text, [object[]]$Headings, [object]$Heading, [int]$BoundaryLevel = 6)

    $end = $Text.Length
    foreach ($next in $Headings) {
        if ($next.Start -gt $Heading.Start -and $next.Level -le $BoundaryLevel) {
            $end = $next.Start
            break
        }
    }
    return [pscustomobject]@{
        Start = $Heading.End
        End = $end
        Text = $Text.Substring($Heading.End, $end - $Heading.End)
    }
}

function Test-MarkdownFragmentExists {
    param(
        [string]$Path,
        [string]$FullPath
    )

    $parts = $Path.Split("#", 2)
    if ($parts.Count -lt 2 -or -not $parts[1]) {
        return $false
    }

    $heading = [Uri]::UnescapeDataString($parts[1]).Replace("-", " ")
    $text = Get-Content -Encoding UTF8 -LiteralPath $FullPath -Raw
    return $text -match (
        "(?im)^#{1,6}\s+" + [regex]::Escape($heading) + "\s*$"
    )
}

function Convert-ToMarkdownAnchor {
    param([string]$Text)

    return (
        $Text.Trim().ToLowerInvariant() -replace "[^a-z0-9\s-]", "" -replace
            "\s+", "-"
    )
}

function Get-ListBlockPaths {
    param(
        [string]$Text,
        [string]$FieldName
    )

    $pattern = "(?ms)^- " + [regex]::Escape($FieldName) +
        ":\s*\r?\n(?<body>(?:\s+- [^\r\n]*(?:\r?\n|$))+)"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return @()
    }

    return @(
        [regex]::Matches($match.Groups["body"].Value, "(?m)^\s+- ``(?<path>[^``]+)``") |
            ForEach-Object { $_.Groups["path"].Value }
    )
}

function Get-OpenSpecChecklistIds {
    param([string]$Text)

    $batchClassification = Get-Section $Text "Batch Classification"
    if (-not $batchClassification) {
        return @()
    }

    $pattern = '(?ms)^- OpenSpec (?:checklist items|task IDs):\s*\r?\n' +
        '(?<body>(?:[ \t]+- [^\r\n]*(?:\r?\n|$))+)'
    $match = [regex]::Match($batchClassification, $pattern)
    if (-not $match.Success) {
        return @()
    }

    $taskIds = [Collections.Generic.List[string]]::new()
    foreach ($itemMatch in [regex]::Matches(
        $match.Groups["body"].Value,
        "(?m)^[ \t]+-[ \t]+(?<item>[^\r\n]+)$"
    )) {
        foreach ($idMatch in [regex]::Matches(
            $itemMatch.Groups["item"].Value,
            "(?<![\w.])P?\d+(?:\.\d+[a-z]?)+(?![\w.])"
        )) {
            $taskIds.Add($idMatch.Value)
        }
    }

    return @($taskIds | Sort-Object -Unique)
}

function Require-Heading {
    param(
        [string]$Text,
        [string]$Heading,
        [string]$FileLabel
    )

    $structure = Get-MarkdownStructure $Text
    $requiredHeading = $structure.Headings |
        Where-Object { $_.Level -eq 2 -and $_.Title -eq $Heading } |
        Select-Object -First 1
    if ($null -eq $requiredHeading) {
        Add-ValidationError "$FileLabel is missing heading: ## $Heading"
    }
}

function Validate-ImplementationResult {
    param(
        [string]$Path,
        [string]$FullPath
    )

    $resultText = Get-Content -Encoding UTF8 -LiteralPath $FullPath -Raw
    foreach ($heading in @(
        "Paths Created Or Updated",
        "Work Summary",
        "Evidence Per Finding Or Requirement",
        "Checks Run",
        "Review Impact",
        "OpenSpec Task Impact",
        "Remaining Risks",
        "Next Action"
    )) {
        Require-Heading $resultText $heading $Path
    }
}

$currentTaskFullPath = Resolve-WorkspacePath $CurrentTaskPath
$handoffFullPath = Resolve-WorkspacePath $HandoffPath

if (-not $currentTaskFullPath -or -not (Test-Path -LiteralPath $currentTaskFullPath)) {
    Add-ValidationError "Current task file does not exist: $CurrentTaskPath"
}
if (-not $handoffFullPath -or -not (Test-Path -LiteralPath $handoffFullPath)) {
    Add-ValidationError "Handoff file does not exist: $HandoffPath"
}

# Missing files stop structural reads, but an invalid expectation value is
# reported alongside them rather than replacing their diagnostics.
$filesReady = ($errors.Count -eq 0)

if ($expectationRequested) {
    if (-not $PSBoundParameters.ContainsKey('ExpectedBatchId')) {
        Add-ValidationError 'ExpectedBatchId is required when expectation parameters are supplied'
    } elseif ([string]::IsNullOrWhiteSpace($ExpectedBatchId)) {
        Add-ValidationError 'ExpectedBatchId must be a non-empty batch ID'
    }
    if ($PSBoundParameters.ContainsKey('ExpectedNextAction') -and
        -not (Test-OrdinalMember $ExpectedNextAction @('continue', 'dispatch', 'close'))) {
        Add-ValidationError 'ExpectedNextAction must be continue, dispatch, or close'
    }
    if ($PSBoundParameters.ContainsKey('ExpectedNextRole') -and
        [string]::IsNullOrWhiteSpace($ExpectedNextRole)) {
        Add-ValidationError 'ExpectedNextRole must be a non-empty role or none'
    }
    if ($PSBoundParameters.ContainsKey('ExpectedReviewRound') -and
        $ExpectedReviewRound -notmatch '^[0-9]+\z') {
        Add-ValidationError 'ExpectedReviewRound must be a nonnegative integer'
    }
    if ($PSBoundParameters.ContainsKey('ExpectedStateRevision') -and
        $ExpectedStateRevision -notmatch '^[1-9][0-9]*\z') {
        Add-ValidationError 'ExpectedStateRevision must be a positive integer'
    }
}

if ($filesReady) {
    $currentTaskBytes = (Get-Item -LiteralPath $currentTaskFullPath).Length
    if ($currentTaskBytes -gt 12288) {
        Add-ValidationWarning (
            "$CurrentTaskPath size ($currentTaskBytes bytes) exceeds advisory 12 KiB threshold"
        )
    }
    $handoffBytes = (Get-Item -LiteralPath $handoffFullPath).Length
    if ($handoffBytes -gt 8192) {
        Add-ValidationWarning (
            "$HandoffPath size ($handoffBytes bytes) exceeds advisory 8 KiB threshold"
        )
    }

    $currentTask = Get-Content -Encoding UTF8 -LiteralPath $currentTaskFullPath -Raw
    $handoff = Get-Content -Encoding UTF8 -LiteralPath $handoffFullPath -Raw

    foreach ($heading in @(
        "Task Identity",
        "Batch Classification",
        "Initial Assignment",
        "Required Reading",
        "Goal",
        "Scope",
        "Out of Scope",
        "Must Not Touch",
        "Acceptance Criteria",
        "Constraints",
        "Required Checks",
        "Output Requirements"
    )) {
        Require-Heading $currentTask $heading $CurrentTaskPath
    }

    $requiredReadingSection = Get-Section $currentTask "Required Reading"
    if ($requiredReadingSection) {
        $canonicalHandbooks = @(
            "README.md",
            "workflows.md",
            "agent-prompts.md",
            "handoff-schema.md"
        )
        $candidatePaths = [Collections.Generic.List[string]]::new()
        foreach ($m in [regex]::Matches($requiredReadingSection, "``(?<path>[^``\r\n]+)``")) {
            [void]$candidatePaths.Add($m.Groups["path"].Value.Trim())
        }
        foreach ($m in [regex]::Matches($requiredReadingSection, "\[[^\]]+\]\((?<url>[^)\r\n]+)\)")) {
            [void]$candidatePaths.Add($m.Groups["url"].Value.Trim())
        }
        foreach ($m in [regex]::Matches($requiredReadingSection, "(?m)^[ \t]*[-*][ \t]+(?<item>[^\r\n]+)")) {
            $itemText = $m.Groups["item"].Value.Trim()
            if (-not ($itemText -match '`') -and -not ($itemText -match '\[')) {
                [void]$candidatePaths.Add($itemText)
            }
        }

        foreach ($pathEntry in $candidatePaths) {
            $normalized = $pathEntry.Replace("\", "/")
            foreach ($hb in $canonicalHandbooks) {
                if ($normalized -match "(?i)(?:^|[\\/])docs/ai-collaboration/$hb(?=$|[#? \t])") {
                    if ($normalized -notmatch "(?i)(?:^|[\\/])docs/ai-collaboration/$hb#[^#\s]+") {
                        Add-ValidationWarning (
                            "$CurrentTaskPath Required Reading references collaboration handbook without section anchor: " +
                            $pathEntry
                        )
                    }
                }
            }
        }
    }

    $currentTaskStructure = Get-MarkdownStructure $currentTask
    if (@($currentTaskStructure.Headings | Where-Object { $_.Level -eq 2 -and $_.Title -eq "Routing" }).Count -gt 0) {
        Add-ValidationError "$CurrentTaskPath must not contain live Routing"
    }
    if (@($currentTaskStructure.Headings | Where-Object { $_.Level -eq 2 -and $_.Title -eq "Status" }).Count -gt 0) {
        Add-ValidationError "$CurrentTaskPath must not contain live Status"
    }

    $templatePlaceholderTokens = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::Ordinal
    )
    foreach ($templateRelativePath in @(
        "docs/ai-collaboration/templates/current-task.template.md",
        "docs/ai-collaboration/templates/handoff.template.md"
    )) {
        $templateFullPath = Resolve-WorkspacePath $templateRelativePath
        if ($templateFullPath -and (Test-Path -LiteralPath $templateFullPath)) {
            $templateText = Get-Content -Encoding UTF8 -LiteralPath $templateFullPath -Raw
            foreach ($placeholderMatch in [regex]::Matches(
                $templateText,
                "<[^>\r\n]+>"
            )) {
                [void]$templatePlaceholderTokens.Add($placeholderMatch.Value)
            }
        }
    }

    foreach ($fileState in @(
        @{ Label = $CurrentTaskPath; Text = $currentTask },
        @{ Label = $HandoffPath; Text = $handoff }
    )) {
        foreach ($placeholderToken in $templatePlaceholderTokens) {
            if ($fileState.Text.Contains($placeholderToken)) {
                Add-ValidationError (
                    "$($fileState.Label) contains template placeholder: " +
                    $placeholderToken
                )
            }
        }
    }

    $batchClassification = Get-Section $currentTask "Batch Classification"
    $riskLevel = Get-FieldValue $batchClassification "Risk level"
    if ($riskLevel -notin @("S", "M", "H")) {
        Add-ValidationError "Current task Risk level must be S, M, or H"
    }
    if (-not (Get-FieldValue $batchClassification "Risk reason")) {
        Add-ValidationError "Current task requires Risk reason for this batch"
    }
    $mappedIncompleteTasks = @()
    $changeId = Get-FieldValue $currentTask "Change ID"
    if ($changeId -and $changeId -ne "none") {
        $tasksRelativePath = "openspec/changes/$changeId/tasks.md"
        $tasksFullPath = Resolve-WorkspacePath $tasksRelativePath
        if (-not $tasksFullPath -or -not (Test-Path -LiteralPath $tasksFullPath)) {
            Add-ValidationError "Mapped OpenSpec tasks file does not exist: $tasksRelativePath"
        } else {
            $tasksText = Get-Content -Encoding UTF8 -LiteralPath $tasksFullPath -Raw
            $taskIds = @(Get-OpenSpecChecklistIds $currentTask)
            if ($taskIds.Count -eq 0) {
                Add-ValidationError "$CurrentTaskPath has no mapped OpenSpec checklist item"
            }
            foreach ($taskId in $taskIds) {
                $taskPattern = "(?m)^- \[[ xX]\] " + [regex]::Escape($taskId) + "(?:\s|$)"
                if ($tasksText -notmatch $taskPattern) {
                    Add-ValidationError "OpenSpec checklist item is missing: $taskId"
                }
                if ($tasksText -match ("(?m)^- \[ \] " + [regex]::Escape($taskId) + "(?:\s|$)")) {
                    $mappedIncompleteTasks += $taskId
                }
            }
        }
    }

    foreach ($heading in @(
        "Routing",
        "Current Status",
        "Delta Since Last Handoff",
        "Authoritative Evidence",
        "Known Risks",
        "Blockers",
        "Review Or Task State Impact"
    )) {
        Require-Heading $handoff $heading $HandoffPath
    }

    $referencedResultPaths = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    $authoritativeEvidence = Get-Section $handoff "Authoritative Evidence"
    foreach ($evidenceMatch in [regex]::Matches(
        $authoritativeEvidence,
        "``(?<value>[^``\r\n]+)``"
    )) {
        $evidenceValue = $evidenceMatch.Groups["value"].Value
        if (
            $evidenceValue -ne "none" -and
            $evidenceValue -notmatch "^[a-z]+://" -and
            $evidenceValue -match "[\\/]"
        ) {
            $fullEvidencePath = Resolve-WorkspacePath $evidenceValue
            if ($fullEvidencePath -and -not (Test-Path -LiteralPath $fullEvidencePath)) {
                Add-ValidationError (
                    "Authoritative Evidence file does not exist: $evidenceValue"
                )
            } elseif (
                $fullEvidencePath -and
                $evidenceValue.Split("#", 2)[0] -match
                    "(?i)(?:^|[\\/])round-\d+-result\.md$"
            ) {
                [void]$referencedResultPaths.Add($evidenceValue)
            }
        }
    }

    $actionMatches = [regex]::Matches(
        $handoff,
        "(?m)^- Next action: ``(?<action>dispatch|continue|close)``\s*$"
    )
    if ($actionMatches.Count -ne 1) {
        Add-ValidationError "$HandoffPath must contain exactly one valid Next action"
        $action = $null
    } else {
        $action = $actionMatches[0].Groups["action"].Value
    }

    $nextRole = Get-FieldValue $handoff "Next role"
    $recommendedAgent = Get-FieldValue $handoff "Recommended next agent"
    $currentRole = Get-FieldValue $handoff "Current role"
    $currentAgent = Get-FieldValue $handoff "Current agent"
    $currentStatus = Get-FieldValue $handoff "Current status"
    $operatorCommand = Get-Section $handoff "Operator Command"
    $processMetrics = Get-Section $handoff "Process Metrics"
    $routing = Get-Section $handoff "Routing"
    # New summary is optional on legacy records. Never infer authority from it.
    $routingText = (Get-MarkdownStructure $routing).UnfencedText
    $humanActionFields = [regex]::Matches($routingText, '(?m)^- Human Action Required:')
    $hasHumanAction = $humanActionFields.Count -gt 0
    $humanActionRequired = Get-FieldValue $routingText "Human Action Required"
    if ($humanActionFields.Count -gt 1) {
        Add-ValidationError "Routing must contain at most one Human Action Required"
    }
    if ($hasHumanAction -and $humanActionRequired -notin @("none", "awaiting-decision", "awaiting-environment")) {
        Add-ValidationError "Human Action Required must be none, awaiting-decision, or awaiting-environment"
    }
    if ($hasHumanAction -and $currentStatus -eq "awaiting-owner-decision" -and $humanActionRequired -ne "awaiting-decision") {
        Add-ValidationError "awaiting-owner-decision requires Human Action Required: awaiting-decision"
    }
    if ($humanActionRequired -eq "awaiting-decision" -and $currentStatus -ne "awaiting-owner-decision") {
        Add-ValidationError "awaiting-decision requires awaiting-owner-decision"
    }

    $executableContinue = $action -eq "continue" -and $currentStatus -notin @("blocked", "awaiting-owner-decision")
    $handoffStructure = Get-MarkdownStructure $handoff
    # ATX headings may have closing hashes; they must not hide a reserved block.
    $continuationHeadings = @($handoffStructure.Headings | Where-Object { $_.Title -match '^Continuation Command(?:[ \t]+#+)?$' })
    $statusHeading = $handoffStructure.Headings | Where-Object { $_.Level -eq 2 -and $_.Title -eq "Current Status" } | Select-Object -First 1
    $statusBody = if ($statusHeading) { Get-MarkdownHeadingBody $handoff $handoffStructure.Headings $statusHeading 2 } else { $null }
    if ($continuationHeadings.Count -gt 1) {
        Add-ValidationError "Handoff must contain at most one Continuation Command"
    }
    if ($hasHumanAction -and $executableContinue -and $continuationHeadings.Count -eq 0) {
        Add-ValidationError "Executable continue with Human Action Required requires ### Continuation Command under Current Status"
    }
    foreach ($heading in $continuationHeadings) {
        if (-not $executableContinue) {
            Add-ValidationError "Continuation Command is permitted only for executable continue"
        }
        if ($heading.Level -ne 3 -or -not $statusBody -or $heading.Start -lt $statusBody.Start -or $heading.Start -ge $statusBody.End) {
            Add-ValidationError "Continuation Command must be under Current Status"
        }
        $command = (Get-MarkdownHeadingBody $handoff $handoffStructure.Headings $heading 3).Text.Trim()
        $commandMatch = [regex]::Match($command, '\A```text[ \t]*\r?\n(?<body>(?:(?!```)[\s\S])+)\r?\n```[ \t]*\z')
        if (-not $commandMatch.Success) {
            Add-ValidationError "Continuation Command requires one text code block"
            continue
        }
        $commandBody = $commandMatch.Groups['body'].Value
        foreach ($field in @("Read", "Objective", "Constraints", "Output", "Follow")) {
            if ($commandBody -notmatch ("(?m)^" + $field + ":[ \t]*\S")) {
                Add-ValidationError "Continuation Command is missing: ${field}:"
            }
        }
        $batchId = Get-FieldValue $batchClassification "Execution Batch ID"
        $identity = ($commandBody -split '\r?\n')[0]
        if ($batchId -and $identity -notmatch ([regex]::Escape("Execution Batch $batchId") + '[.]?[ \t]*$')) {
            Add-ValidationError "Continuation Command must name Execution Batch: $batchId"
        }
        if ($currentRole -and $identity -notmatch ([regex]::Escape("continuing as $currentRole") + ' for Execution Batch ')) {
            Add-ValidationError "Continuation Command must name Current role: $currentRole"
        }
        $roleAnchor = Convert-ToMarkdownAnchor $currentRole
        if ($commandBody -notmatch ("(?m)^Follow:[ \t]*" + [regex]::Escape("docs/ai-collaboration/agent-prompts.md#$roleAnchor") + '[.]?[ \t]*$')) {
            Add-ValidationError "Continuation Command Follow must match Current role prompt"
        }
    }
    $handoffRisk = Get-FieldValue $routing "Risk level"
    if ($handoffRisk -and $handoffRisk -ne $riskLevel) {
        Add-ValidationError "Handoff Risk level must match current task Risk level"
    }
    $handoffBatch = Get-FieldValue $routing "Execution Batch ID"
    if ($handoffBatch -and $handoffBatch -ne (Get-FieldValue $batchClassification "Execution Batch ID")) {
        Add-ValidationError "Handoff Execution Batch ID must match current task"
    }
    $stateRevision = Get-FieldValue $routing "State revision"
    if ($stateRevision -and $stateRevision -notmatch '^[1-9]\d*$') {
        Add-ValidationError "State revision must be a positive integer"
    }
    $reviewRound = Get-FieldValue $routing "Review round"
    if ($null -ne $reviewRound -and $reviewRound -notmatch '^\d+$') {
        Add-ValidationError "Review round must be a nonnegative integer"
    }
    $reviewTrackedRoles = @(
        "Implementation Engineer",
        "Code Reviewer",
        "Fix Engineer",
        "Verification Reviewer",
        "Design Reviewer",
        "Chief Designer"
    )
    $closureOutcome = Get-FieldValue (Get-Section $handoff "Review Or Task State Impact") "Closure outcome"
    if ($closureOutcome -and $action -ne "close") {
        Add-ValidationError "Closure outcome is only valid for close"
    }
    if ($currentStatus -eq "blocked") {
        if ($action -ne "continue") {
            Add-ValidationError "blocked requires continue; dispatch only after a next actor or decision is available"
        }
        if (-not (Get-FieldValue (Get-Section $handoff "Blockers") "Resume condition")) {
            Add-ValidationError "blocked requires a Resume condition in Blockers"
        }
        if (Get-Section $handoff "Owner Decision Brief") {
            Add-ValidationError "Environment blocked state must not include Owner Decision Brief; use awaiting-owner-decision for a real decision"
        }
    }

    foreach ($requiredCurrentValue in @(
        @{ Name = "Current role"; Value = $currentRole },
        @{ Name = "Current agent"; Value = $currentAgent },
        @{ Name = "Current status"; Value = $currentStatus }
    )) {
        if (-not $requiredCurrentValue.Value) {
            Add-ValidationError "handoff requires $($requiredCurrentValue.Name)"
        }
    }

    if ($currentRole -and $currentRole -ne "Task Intake") {
        $rolePromptRelativePath = (
            "docs/ai-collaboration/agent-prompts.md#" +
            (Convert-ToMarkdownAnchor $currentRole)
        )
        $rolePromptFullPath = Resolve-WorkspacePath $rolePromptRelativePath
        if (
            -not $rolePromptFullPath -or
            -not (Test-MarkdownFragmentExists $rolePromptRelativePath $rolePromptFullPath)
        ) {
            Add-ValidationError "Current role is not defined: $currentRole"
        }
    }

    $humanDecisionRoles = @("Task Owner", "User", "Data Owner")
    $isHumanRole = ($nextRole -in $humanDecisionRoles)
    $requiresReviewRound = (
        ($action -eq "dispatch" -and -not $isHumanRole) -or
        ($currentRole -in $reviewTrackedRoles -and $action -ne "close")
    )
    if ($requiresReviewRound -and $null -eq $reviewRound) {
        Add-ValidationError (
            "Active implementation/review/fix handoff requires Review round"
        )
    }
    if ($reviewRound -match '^\d+$') {
        $reviewRoundNumber = $reviewRound.TrimStart('0')
        if ([string]::IsNullOrEmpty($reviewRoundNumber)) {
            $reviewRoundNumber = "0"
        }
        $atOrAboveCircuitBreaker = (
            $reviewRoundNumber.Length -gt 1 -or
            ($reviewRoundNumber.Length -eq 1 -and $reviewRoundNumber -ge "3")
        )
        if ($atOrAboveCircuitBreaker) {
            # An applicable finite owner authorization permits the budgeted
            # route; every other over-limit route keeps the existing rejection.
            $budgetPermitsRoute = $false
            if (($action -eq "dispatch" -and -not $isHumanRole) -or (
                $action -eq "continue" -and
                $currentStatus -ne "awaiting-owner-decision"
            )) {
                $budgetImpact = Get-Section $handoff "Review Or Task State Impact"
                $budgetDecision = $null
                if ($budgetImpact) {
                    $budgetDecision = Get-SectionFieldContent `
                        $budgetImpact "Task Owner decision"
                }
                $budgetPermitsRoute = Test-ReviewBudgetExtension `
                    (Get-ReviewBudgetExtension $budgetDecision) `
                    (Get-FieldValue $batchClassification "Execution Batch ID") `
                    $reviewRound
            }
            if (-not $budgetPermitsRoute) {
                if ($action -eq "dispatch" -and -not $isHumanRole) {
                    Add-ValidationError (
                        "Review round circuit breaker reached at 3; agent dispatch is not permitted; " +
                        "close or await Task Owner decision"
                    )
                } elseif (
                    $action -eq "continue" -and
                    $currentStatus -ne "awaiting-owner-decision"
                ) {
                    Add-ValidationError (
                        "Review round circuit breaker reached at 3; continue is permitted only while awaiting-owner-decision"
                    )
                }
            }
        }
    }

    # Task Intake is a workflow actor without a role prompt; constrain its exits.
    if ($currentRole -eq "Task Intake") {
        $initialRole = Get-FieldValue $currentTask "Initial role"
        $validTaskIntakeAgentDispatch = (
            $action -eq "dispatch" -and
            -not $isHumanRole -and
            $initialRole -and
            $nextRole -eq $initialRole
        )
        $validTaskIntakeHumanDispatch = (
            $action -eq "dispatch" -and
            $isHumanRole -and
            $currentStatus -eq "awaiting-owner-decision"
        )
        $validTaskIntakeWait = (
            $action -eq "continue" -and
            $currentStatus -in @("awaiting-owner-decision", "blocked")
        )
        if (-not $validTaskIntakeAgentDispatch -and -not $validTaskIntakeHumanDispatch -and -not $validTaskIntakeWait) {
            Add-ValidationError (
                "Task Intake must dispatch Initial role, dispatch a human decision recipient awaiting-owner-decision, or continue awaiting-owner-decision/blocked"
            )
        }
    }

    # Requirements Analyst has one confirmed normal dispatch exit: Chief Designer.
    # Keep this allowlist narrow; the validator does not interpret the full
    # Routing Matrix or add new action/status validation.
    if ($currentRole -eq "Requirements Analyst" -and $action -eq "dispatch") {
        if (-not $isHumanRole -and $nextRole -ne "Chief Designer") {
            Add-ValidationError (
                "Requirements Analyst dispatch must target Chief Designer"
            )
        }
    }

    if ($action -eq "dispatch") {
        if ($isHumanRole) {
            # Human decision dispatch: strictly discriminated branch.
            # Fail closed on incomplete human shape; do not fall through to agent dispatch.
            if ($currentStatus -ne "awaiting-owner-decision") {
                Add-ValidationError "human decision dispatch requires Current status: awaiting-owner-decision"
            }

            if ($recommendedAgent -ne "none") {
                Add-ValidationError "human decision dispatch requires Recommended next agent: none"
            }

            $inputFieldValue = Get-FieldValue $handoff "Next input files"
            $inputPaths = @(Get-ListBlockPaths $handoff "Next input files")
            if ($inputFieldValue -ne "none" -or $inputPaths.Count -gt 0) {
                Add-ValidationError "human decision dispatch requires Next input files: none"
            }

            $outputFieldValue = Get-FieldValue $handoff "Next output files"
            $outputPaths = @(Get-ListBlockPaths $handoff "Next output files")
            if ($outputFieldValue -ne "none" -or $outputPaths.Count -gt 0) {
                Add-ValidationError "human decision dispatch requires Next output files: none"
            }

            $promptFieldValue = Get-FieldValue $handoff "Next prompt template"
            $promptPaths = @(Get-ListBlockPaths $handoff "Next prompt template")
            if ($promptFieldValue -ne "none" -or $promptPaths.Count -gt 0) {
                Add-ValidationError "human decision dispatch requires Next prompt template: none"
            }

            if ($operatorCommand) {
                Add-ValidationError "human decision dispatch must not include ## Operator Command"
            }

        } else {
            # Agent dispatch: keep existing checks unchanged.
            if ($currentStatus -eq "awaiting-owner-decision") {
                Add-ValidationError "awaiting-owner-decision is not permitted for agent dispatch"
            }

            foreach ($requiredValue in @(
                @{ Name = "Next role"; Value = $nextRole },
                @{ Name = "Recommended next agent"; Value = $recommendedAgent }
            )) {
                if (
                    -not $requiredValue.Value -or
                    $requiredValue.Value -eq "none"
                ) {
                    Add-ValidationError "dispatch requires $($requiredValue.Name)"
                }
            }

            if (-not $operatorCommand) {
                Add-ValidationError "dispatch requires ## Operator Command"
            } else {
                if ($operatorCommand -notmatch '(?ms)^```text\s*\r?\n.+\r?\n```\s*$') {
                    Add-ValidationError (
                        'dispatch Operator Command requires one ```text code block'
                    )
                }

                foreach ($commandField in @(
                    "Read",
                    "Objective",
                    "Constraints",
                    "Output",
                    "Follow"
                )) {
                    if ($operatorCommand -notmatch (
                        "(?m)^" + [regex]::Escape($commandField) + ":\s*\S"
                    )) {
                        Add-ValidationError (
                            "dispatch Operator Command is missing: ${commandField}:"
                        )
                    }
                }

                $executionBatchId = Get-FieldValue $currentTask "Execution Batch ID"
                if (
                    $executionBatchId -and
                    $operatorCommand -notmatch [regex]::Escape($executionBatchId)
                ) {
                    Add-ValidationError (
                        "dispatch Operator Command must name Execution Batch: " +
                        $executionBatchId
                    )
                }
                if (
                    $nextRole -and
                    $operatorCommand -notmatch [regex]::Escape($nextRole)
                ) {
                    Add-ValidationError (
                        "dispatch Operator Command must name Next role: $nextRole"
                    )
                }
            }

            $inputPaths = @(Get-ListBlockPaths $handoff "Next input files")
            if ($inputPaths.Count -eq 0) {
                Add-ValidationError "dispatch requires at least one Next input file"
            }
            foreach ($inputPath in $inputPaths) {
                $fullInputPath = Resolve-WorkspacePath $inputPath
                if ($fullInputPath -and -not (Test-Path -LiteralPath $fullInputPath)) {
                    Add-ValidationError "Next input file does not exist: $inputPath"
                } elseif (
                    $fullInputPath -and
                    $inputPath.Split("#", 2)[0] -match
                        "(?i)(?:^|[\\/])round-\d+-result\.md$"
                ) {
                    [void]$referencedResultPaths.Add($inputPath)
                }
            }

            $outputPaths = @(Get-ListBlockPaths $handoff "Next output files")
            if ($outputPaths.Count -eq 0) {
                Add-ValidationError "dispatch requires at least one Next output file"
            }

            $promptPaths = @(Get-ListBlockPaths $handoff "Next prompt template")
            if ($promptPaths.Count -eq 0) {
                Add-ValidationError "dispatch requires a Next prompt template"
            }
            foreach ($promptPath in $promptPaths) {
                $fullPromptPath = Resolve-WorkspacePath $promptPath
                if ($fullPromptPath -and -not (Test-Path -LiteralPath $fullPromptPath)) {
                    Add-ValidationError "Next prompt template does not exist: $promptPath"
                } elseif (
                    $fullPromptPath -and
                    -not (Test-MarkdownFragmentExists $promptPath $fullPromptPath)
                ) {
                    Add-ValidationError (
                        "Next prompt template requires an existing heading anchor: " +
                        $promptPath
                    )
                }

                if ($nextRole) {
                    $expectedRoleAnchor = Convert-ToMarkdownAnchor $nextRole
                    $promptParts = $promptPath.Split("#", 2)
                    if (
                        $promptParts.Count -lt 2 -or
                        $promptParts[1] -ne $expectedRoleAnchor
                    ) {
                        Add-ValidationError (
                            "Next prompt template anchor must match Next role: " +
                            "$nextRole"
                        )
                    }
                }
            }

        }
    }

    if ($action -in @("continue", "close")) {
        foreach ($emptyRouteField in @(
            "Next role",
            "Recommended next agent",
            "Next input files",
            "Next output files",
            "Next prompt template"
        )) {
            $value = Get-FieldValue $handoff $emptyRouteField
            if ($value -ne "none") {
                Add-ValidationError "$action requires ${emptyRouteField}: none"
            }
        }
        if ($operatorCommand) {
            Add-ValidationError "$action must not include ## Operator Command"
        }
    }

    if ($currentStatus -eq "awaiting-owner-decision") {
        $validAwaitingAction = (
            $action -eq "continue" -or
            ($action -eq "dispatch" -and $isHumanRole)
        )
        if (-not $validAwaitingAction) {
            Add-ValidationError (
                "awaiting-owner-decision requires Next action: continue or human decision dispatch"
            )
        }

        $ownerDecisionBrief = Get-Section $handoff "Owner Decision Brief"
        if (-not $ownerDecisionBrief) {
            Add-ValidationError (
                "awaiting-owner-decision requires ## Owner Decision Brief"
            )
        } else {
            foreach ($decisionField in @(
                "Decision needed",
                "Recommendation",
                "Alternatives",
                "Reply needed",
                "After the reply"
            )) {
                if (-not (Get-SectionFieldContent $ownerDecisionBrief $decisionField)) {
                    Add-ValidationError (
                        "Owner Decision Brief is missing: $decisionField"
                    )
                }
            }

            $recContent = Get-SectionFieldContent $ownerDecisionBrief "Recommendation"
            if ($recContent -and $recContent -notmatch '(?i)(?:reason\s*:|because\b)') {
                Add-ValidationError (
                    "Owner Decision Brief Recommendation requires a stated reason"
                )
            }

            $altContent = Get-SectionFieldContent $ownerDecisionBrief "Alternatives"
            if ($altContent -and $altContent -notmatch '(?i)(?:consequence\s*:|consequence\b)') {
                Add-ValidationError (
                    "Owner Decision Brief Alternatives requires a stated consequence"
                )
            }

            $replyContent = Get-SectionFieldContent $ownerDecisionBrief "Reply needed"
            $hasCodeOrQuotes = ($replyContent -match '`[^`]+`') -or ($replyContent -match '"[^"]+"') -or ($replyContent -match "'[^']+'")
            if ($replyContent -and -not $hasCodeOrQuotes) {
                Add-ValidationError (
                    "Owner Decision Brief Reply needed requires an exact reply in code or quotes"
                )
            }

            # Forbidden human artifact assignment check in brief
            if (
                $ownerDecisionBrief -match '(?i)\b(?:Task Owner|User|Data Owner)\s+(?:will\s+)?(?:write|update|edit|create|prepare|maintain|produce|commit)\b.*?\b(?:\.ai|openspec|review|handoff|current-task|tasks\.md|runtime)\b' -or
                ($replyContent -and $replyContent -match '(?i)\b(?:write|update|edit|create|prepare|maintain|produce|commit)\b.*?\b(?:\.ai|openspec|review|handoff|current-task|tasks\.md)\b')
            ) {
                Add-ValidationError (
                    "Owner Decision Brief must not assign workflow artifacts to a human recipient"
                )
            }
        }
    }

    foreach ($resultPath in $referencedResultPaths) {
        $fullResultPath = Resolve-WorkspacePath $resultPath
        if ($fullResultPath -and (Test-Path -LiteralPath $fullResultPath)) {
            Validate-ImplementationResult $resultPath $fullResultPath
        }
    }

    # These deterministic checks do not judge scope necessity or test sufficiency.
    if ($action -eq "dispatch" -and -not $isHumanRole) {
        if ($currentRole -eq "Implementation Engineer" -and $currentStatus -eq "ready-for-review" -and $nextRole -ne "Code Reviewer") {
            Add-ValidationError "Implementation ready-for-review must dispatch Code Reviewer"
        }
        if ($currentRole -eq "Fix Engineer" -and $currentStatus -eq "ready-for-verification") {
            $expectedVerifier = if ($riskLevel -eq "H") { "Verification Reviewer" } else { "Code Reviewer" }
            if ($nextRole -ne $expectedVerifier) {
                Add-ValidationError "Fix ready-for-verification must dispatch $expectedVerifier for risk $riskLevel"
            }
        }
    }

    $unmetImmediateEnvironment = $false
    $envPrepSection = Get-Section $handoff "Environment Preparation"
    if ($null -ne $envPrepSection) {
        $envPrepStructure = Get-MarkdownStructure $envPrepSection
        $prereqHeadings = @($envPrepStructure.Headings | Where-Object { $_.Level -eq 3 })
        if ($prereqHeadings.Count -eq 0) {
            Add-ValidationError "Environment Preparation requires at least one prerequisite heading (### ...)"
        }
        foreach ($prereqHeading in $prereqHeadings) {
            $prereqTitle = $prereqHeading.Title
            $prereqBody = (Get-MarkdownHeadingBody $envPrepSection $envPrepStructure.Headings $prereqHeading 3).Text

            $readiness = Get-ItemFieldValue $prereqBody "Readiness"
            if (-not $readiness) {
                Add-ValidationError "Environment Preparation '$prereqTitle' is missing: Readiness"
            } elseif ($readiness -notin @("ready", "pending", "unknown")) {
                Add-ValidationError "Environment Preparation '$prereqTitle' Readiness must be ready, pending, or unknown: $readiness"
            }

            $needed = Get-ItemFieldValue $prereqBody "Needed before next action"
            if (-not $needed) {
                Add-ValidationError "Environment Preparation '$prereqTitle' is missing: Needed before next action"
            } elseif ($needed -notin @("yes", "no")) {
                Add-ValidationError "Environment Preparation '$prereqTitle' Needed before next action must be yes or no: $needed"
            }

            $humanAction = Get-ItemFieldContent $prereqBody "Human action"
            if (-not $humanAction) {
                Add-ValidationError "Environment Preparation '$prereqTitle' is missing: Human action"
            } elseif ($humanAction.Trim().Trim([char]96) -in @("pending", "unknown") -or (
                $needed -eq "yes" -and $humanAction.Trim().Trim([char]96) -eq "none"
            )) {
                Add-ValidationError "Environment Preparation '$prereqTitle' requires actionable Human action, not $humanAction"
            }

            $confirmation = Get-ItemFieldContent $prereqBody "Confirmation and check"
            if (-not $confirmation) {
                Add-ValidationError "Environment Preparation '$prereqTitle' is missing: Confirmation and check"
            } elseif ($confirmation.Trim() -in @("none", "pending", "unknown")) {
                Add-ValidationError "Environment Preparation '$prereqTitle' requires Confirmation and check, not $confirmation"
            }

            $workCanProceed = Get-ItemFieldContent $prereqBody "Work that can proceed"
            if (-not $workCanProceed) {
                Add-ValidationError "Environment Preparation '$prereqTitle' is missing: Work that can proceed"
            }

            if ($action -eq "dispatch" -and -not $isHumanRole) {
                if ($readiness -in @("pending", "unknown") -and $needed -eq "yes") {
                    Add-ValidationError "Agent dispatch is not permitted when environment prerequisite is $readiness and needed before next action: $prereqTitle"
                }
            }
            if ($readiness -in @("pending", "unknown") -and $needed -eq "yes") {
                $unmetImmediateEnvironment = $true
            }
        }
    }
    if ($unmetImmediateEnvironment) {
        if ($action -ne "continue" -or $currentStatus -ne "blocked") {
            Add-ValidationError "Unmet immediate environment prerequisite requires continue/blocked"
        }
        if ($hasHumanAction -and $humanActionRequired -ne "awaiting-environment") {
            Add-ValidationError "Unmet immediate environment prerequisite requires Human Action Required: awaiting-environment"
        }
    }
    if ($humanActionRequired -eq "awaiting-environment" -and (
        $action -ne "continue" -or $currentStatus -ne "blocked" -or -not $unmetImmediateEnvironment
    )) {
        Add-ValidationError "awaiting-environment requires continue/blocked and an unmet immediate environment prerequisite"
    }

    $reviewImpact = Get-Section $handoff "Review Or Task State Impact"
    $taskOwnerDecisionFieldCount = if ($reviewImpact) {
        @(
            [regex]::Matches(
                $reviewImpact,
                "(?m)^- Task Owner decision:[ \t]*"
            )
        ).Count
    } else {
        0
    }
    if ($taskOwnerDecisionFieldCount -gt 1) {
        Add-ValidationError (
            "Review Or Task State Impact must contain one Task Owner decision field; " +
            "duplicate actual decision fields are not accepted"
        )
    }
    $acceptanceBasis = Get-SectionFieldContent $reviewImpact "Acceptance basis"
    if ($acceptanceBasis -and ($action -ne "close" -or $closureOutcome -ne "accepted")) {
        Add-ValidationError "Acceptance basis is only valid for accepted close"
    }
    if ($action -eq "close") {
        $normalizedAcceptanceBasis = if ($acceptanceBasis) {
            $acceptanceBasis.Trim([char]96).Trim([char]34).Trim([char]39).Trim()
        } else {
            ""
        }
        if (-not $closureOutcome) {
            Add-ValidationWarning "Legacy close has no Closure outcome; record accepted, stopped, or superseded when next updated"
        } elseif ($closureOutcome -notin @("accepted", "stopped", "superseded")) {
            Add-ValidationError "Closure outcome must be accepted, stopped, or superseded"
        } elseif ($closureOutcome -eq "accepted") {
            $taskOwnerDecision = Get-SectionFieldContent $reviewImpact "Task Owner decision"
            $normalizedTaskOwnerDecision = if ($taskOwnerDecision) {
                $taskOwnerDecision.Trim([char]96).Trim([char]34).Trim([char]39).Trim()
            } else {
                ""
            }
            $ownerDecisionAcceptance = ($normalizedAcceptanceBasis -eq "owner-decision")
            if ($normalizedAcceptanceBasis -and -not $ownerDecisionAcceptance) {
                Add-ValidationError "Accepted closure Acceptance basis must be owner-decision when supplied"
            }
            if ($ownerDecisionAcceptance -and $currentRole -ne "Chief Designer") {
                Add-ValidationError "Owner-decision accepted closure requires Chief Designer disposition"
            }
            if ($ownerDecisionAcceptance -and (
                    -not $normalizedTaskOwnerDecision -or
                    $normalizedTaskOwnerDecision -in @("none", "pending", "unknown")
                )) {
                Add-ValidationError "Owner-decision accepted closure requires Task Owner decision in Review Or Task State Impact"
            }
            if ($mappedIncompleteTasks.Count -gt 0 -and -not $ownerDecisionAcceptance) {
                Add-ValidationError ("Accepted closure has incomplete mapped OpenSpec tasks: " + ($mappedIncompleteTasks -join ", "))
            }
            if ($riskLevel -in @("M", "H") -and $currentRole -in @("Implementation Engineer", "Fix Engineer")) {
                Add-ValidationError "Risk M/H accepted closure requires independent review, not implementer/fixer self-closure"
            }
        } elseif ($closureOutcome -in @("stopped", "superseded")) {
            if ($currentRole -ne "Chief Designer") {
                Add-ValidationError "Stopped or superseded closure requires Chief Designer disposition"
            }
            $taskOwnerDecision = Get-SectionFieldContent $reviewImpact "Task Owner decision"
            $decisionValue = if ($taskOwnerDecision) {
                $taskOwnerDecision.Trim().Trim('`').Trim('"').Trim("'").Trim()
            } else {
                ""
            }
            if (-not $decisionValue -or $decisionValue -in @("none", "pending", "unknown")) {
                Add-ValidationError "Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact"
            }
        }
    }
    if ($processMetrics) {
        foreach ($integerMetric in @(
            "Role actions",
            "Review/fix/verification loops",
            "Broad regression runs"
        )) {
            $metricValue = Get-FieldValue $processMetrics $integerMetric
            if ($metricValue -eq "unknown") {
                Add-ValidationWarning "Process Metrics ${integerMetric} is unknown; do not invent a count"
            } elseif ($metricValue -and $metricValue -notmatch "^\d+$") {
                Add-ValidationError (
                    "Process Metrics requires integer or unknown: ${integerMetric}"
                )
            }
        }
        $roleActions = Get-FieldValue $processMetrics "Role actions"
        $actionTarget = if ($riskLevel -eq "H") { 5 } else { 3 }
        if ($roleActions -match '^\d+$' -and [double]$roleActions -ge $actionTarget -and $action -ne "close") {
            Add-ValidationWarning "Role action target reached; check scope, remaining acceptance, and repeated evidence before another handoff"
        }
        $fixLoops = Get-FieldValue $processMetrics "Review/fix/verification loops"
        if ($fixLoops -match '^\d+$' -and [double]$fixLoops -gt 1) {
            Add-ValidationWarning "Fix loop target exceeded; record a scope or technical disposition instead of repeating unchanged work"
        }
        $broadRuns = Get-FieldValue $processMetrics "Broad regression runs"
        if ($broadRuns -match '^\d+$' -and [double]$broadRuns -gt 1) {
            Add-ValidationWarning "Multiple broad regression runs; record which relevant inputs changed"
        }
    }

    if ($expectationRequested) {
        # Compare only the one real level-2 Routing section, fence-aware and
        # without filling a missing field from examples or other sections.
        # Closing ATX markers are normalized here only, so "## Routing ##" is
        # counted as the same real heading and a duplicate is rejected.
        $expectationRoutingHeadings = @(
            $handoffStructure.Headings | Where-Object {
                $_.Level -eq 2 -and (Test-OrdinalEqual (Get-ExpectationHeadingTitle $_.Title) "Routing")
            }
        )
        if ($expectationRoutingHeadings.Count -ne 1) {
            Add-ValidationError "Expectation requires exactly one real ## Routing section"
        } else {
            $expectationRoutingText = (Get-MarkdownStructure (
                (Get-MarkdownHeadingBody $handoff $handoffStructure.Headings $expectationRoutingHeadings[0] 2).Text.Trim()
            )).UnfencedText
            $expectationChecks = [Collections.Generic.List[object]]::new()
            if ($PSBoundParameters.ContainsKey("ExpectedBatchId") -and -not [string]::IsNullOrWhiteSpace($ExpectedBatchId)) {
                $expectationChecks.Add(@{ Field = "Execution Batch ID"; Expected = $ExpectedBatchId; Kind = "text" })
            }
            if ($PSBoundParameters.ContainsKey("ExpectedNextAction") -and (Test-OrdinalMember $ExpectedNextAction @("continue", "dispatch", "close"))) {
                $expectationChecks.Add(@{ Field = "Next action"; Expected = $ExpectedNextAction; Kind = "text" })
            }
            if ($PSBoundParameters.ContainsKey("ExpectedNextRole") -and -not [string]::IsNullOrWhiteSpace($ExpectedNextRole)) {
                $expectationChecks.Add(@{ Field = "Next role"; Expected = $ExpectedNextRole; Kind = "text" })
            }
            if ($PSBoundParameters.ContainsKey("ExpectedReviewRound") -and $ExpectedReviewRound -match '^[0-9]+\z') {
                $expectationChecks.Add(@{ Field = "Review round"; Expected = $ExpectedReviewRound; Kind = "count" })
            }
            if ($PSBoundParameters.ContainsKey("ExpectedStateRevision") -and $ExpectedStateRevision -match '^[1-9][0-9]*\z') {
                $expectationChecks.Add(@{ Field = "State revision"; Expected = $ExpectedStateRevision; Kind = "text" })
            }

            foreach ($check in $expectationChecks) {
                $fieldOccurrences = [regex]::Matches(
                    $expectationRoutingText,
                    "(?m)^- " + [regex]::Escape($check.Field) + ":"
                ).Count
                if ($fieldOccurrences -eq 0) {
                    Add-ValidationError "Routing is missing expected field: $($check.Field)"
                    continue
                }
                if ($fieldOccurrences -gt 1) {
                    Add-ValidationError "Routing has duplicate field: $($check.Field)"
                    continue
                }
                $actualValue = Get-FieldValue $expectationRoutingText $check.Field
                $isMatch = if ($check.Kind -eq "count") {
                    # Decimal text comparison: leading zeros normalize, and no
                    # narrow integer conversion can overflow.
                    ($null -ne $actualValue) -and
                        ($actualValue -match '^[0-9]+\z') -and
                        (Test-OrdinalEqual (Get-NormalizedDecimal $actualValue) (Get-NormalizedDecimal $check.Expected))
                } else {
                    ($null -ne $actualValue) -and (Test-OrdinalEqual $actualValue $check.Expected)
                }
                if (-not $isMatch) {
                    Add-ValidationError (
                        "Expected $($check.Field) mismatch: expected '$($check.Expected)' but Routing has '$actualValue'"
                    )
                } else {
                    $matchedExpectationFields.Add($check.Field)
                }
            }

            if ($PSBoundParameters.ContainsKey("ExpectedBatchId") -and -not [string]::IsNullOrWhiteSpace($ExpectedBatchId)) {
                $currentTaskBatch = Get-FieldValue $batchClassification "Execution Batch ID"
                if (-not (Test-OrdinalEqual $currentTaskBatch $ExpectedBatchId)) {
                    Add-ValidationError (
                        "Expected Execution Batch ID mismatch: expected '$ExpectedBatchId' but current task has '$currentTaskBatch'"
                    )
                }
            }
        }
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "Advisory workflow warnings:" -ForegroundColor Yellow
    foreach ($validationWarning in $warnings) {
        Write-Host " - $validationWarning" -ForegroundColor Yellow
    }
}

if ($errors.Count -gt 0) {
    Write-Host "Runtime collaboration state is INVALID:" -ForegroundColor Red
    foreach ($validationError in $errors) {
        Write-Host " - $validationError" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Runtime collaboration structure is valid (not acceptance, evidence freshness, or reviewer independence verification)." -ForegroundColor Green
Write-Host " Current task: $CurrentTaskPath"
Write-Host " Handoff: $HandoffPath"
if ($expectationRequested) {
    Write-Host (
        " Supplied expectations match Routing: " + ($matchedExpectationFields -join ", ") +
        ". This compares the stated values only; it does not prove freshness, authenticity, or acceptance."
    ) -ForegroundColor Green
}
exit 0
