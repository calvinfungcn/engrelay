[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Get-Location).Path,
    [string]$HandoffPath = '.ai/engrelay-lite/handoff.md',
    [string]$ExpectedTaskId,
    [string]$ExpectedNextAction,
    [string]$ExpectedNextRole,
    [string]$ExpectedReviewRound,
    [string]$ExpectedStateRevision,
    [string]$SourceResultPath,
    [string]$PriorHandoffPath
)

# Read-only structure checks. This script never discovers, applies or publishes a transfer.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$root = [IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\','/')

function Resolve-Input([string]$Relative) {
    if ([string]::IsNullOrWhiteSpace($Relative) -or [IO.Path]::IsPathRooted($Relative) -or
        $Relative -match '[:\\]' -or $Relative -match '(^|/)\.\.?(/|$)') { throw 'Path must stay inside WorkspaceRoot; use a project-relative forward-slash path' }
    $path = [IO.Path]::GetFullPath((Join-Path $root $Relative))
    if (-not $path.StartsWith($root + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Path must stay inside WorkspaceRoot' }
    $cursor = $path
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse point is not allowed: $Relative" }
        }
        $parent = Split-Path -Parent $cursor
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Input file missing: $Relative" }
    return $path
}
function Read-Input([string]$Relative) {
    $bytes = [IO.File]::ReadAllBytes((Resolve-Input $Relative))
    return $utf8.GetString($bytes).TrimStart([char]0xfeff)
}
function Get-Sections([string]$Text) {
    $sections = @{}; $current = ''; $fenceChar = ''; $fenceSize = 0
    foreach ($line in ($Text -split '\r?\n')) {
        $isFence = $line -match '^ {0,3}(`{3,}|~{3,})(.*)$'
        if ($fenceSize) {
            if ($current) { $sections[$current].Raw.Add($line) }
            if ($isFence -and $Matches[1][0].ToString() -ceq $fenceChar -and $Matches[1].Length -ge $fenceSize -and [string]::IsNullOrWhiteSpace($Matches[2])) { $fenceSize = 0 }
            continue
        }
        if ($isFence) {
            $fenceChar = $Matches[1][0].ToString(); $fenceSize = $Matches[1].Length
            if ($current) { $sections[$current].Raw.Add($line) }
            continue
        }
        if ($line -match '^## +(.+?)\s*$') {
            $current = $Matches[1]
            if ($sections.ContainsKey($current)) { throw "Duplicate section: $current" }
            $sections[$current] = @{ Raw=(New-Object 'Collections.Generic.List[string]'); Plain=(New-Object 'Collections.Generic.List[string]') }
            continue
        }
        if ($current) { $sections[$current].Raw.Add($line); $sections[$current].Plain.Add($line) }
    }
    if ($fenceSize) { throw 'Unclosed code fence' }
    return $sections
}
function Get-Body($Sections, [string]$Name, [switch]$Plain) {
    if (-not $Sections.ContainsKey($Name)) { return '' }
    if ($Plain) { return $Sections[$Name].Plain -join "`n" }
    return $Sections[$Name].Raw -join "`n"
}
function Get-Fields([string]$Text, [string]$Context) {
    $fields = @{}
    foreach ($line in ($Text -split '\r?\n')) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -notmatch '^\s*- ([^:]+):\s*(.*?)\s*$') { throw "Invalid $Context field line" }
        $key = $Matches[1]; $value = $Matches[2].Trim('`').Trim()
        if ($fields.ContainsKey($key)) { throw "Duplicate $Context field: $key" }
        if (-not $value) { throw "Empty $Context field: $key" }
        $fields[$key] = $value
    }
    return $fields
}
function Assert-Number([string]$Value, [string]$Name, [long]$Minimum) {
    $number = 0L
    if ($Value -notmatch '^[0-9]+$' -or -not [long]::TryParse($Value,[ref]$number) -or $number -lt $Minimum) { throw "Invalid $Name" }
    return $number
}
function Assert-Command([string]$Text, [string]$Name, [string]$Task, [string]$Role) {
    if (-not $Text -or $Text -notmatch '(?m)^```text\s*$' -or $Text -notmatch ('(?i)\b' + [regex]::Escape($Role) + '\b') -or
        $Text -notmatch ([regex]::Escape($Task))) { throw "Missing or incomplete $Name identity" }
    foreach ($label in @('Read','Objective','Constraints','Output','Follow')) {
        if ($Text -notmatch ('(?m)^' + $label + ':\s*\S')) { throw "Missing $Name $label" }
    }
}
function Test-Capacity([string]$Evidence, [string]$Task, [long]$Round) {
    $decisions = @([regex]::Matches($Evidence,'(?m)^- Task Owner decision:\s*(.+)$'))
    if ($decisions.Count -gt 1) { throw 'Duplicate Task Owner decision' }
    if (-not $decisions.Count -or -not $decisions[0].Groups[1].Value.Trim('`').StartsWith('review-budget-extension',[StringComparison]::Ordinal)) { return ($Round -lt 3) }
    $parts = $decisions[0].Groups[1].Value.Trim('`') -split ';'
    if ($parts[0].Trim() -cne 'review-budget-extension') { throw 'Invalid review-budget-extension' }
    $fields = @{}
    foreach ($part in ($parts | Select-Object -Skip 1)) {
        if ($part -notmatch '^\s*(owner|date|batch|from|through|scope|evidence)\s*=\s*(.+?)\s*$' -or $fields.ContainsKey($Matches[1])) { throw 'Invalid review-budget-extension fields' }
        $fields[$Matches[1]] = $Matches[2]
    }
    if ($fields.Count -ne 7 -or $fields['batch'] -cne $Task) { throw 'Invalid review-budget-extension task or fields' }
    $null = [datetime]::ParseExact($fields['date'],'yyyy-MM-dd',[Globalization.CultureInfo]::InvariantCulture)
    $from = Assert-Number $fields['from'] 'extension from' 0
    $through = Assert-Number $fields['through'] 'extension through' 1
    if ($through -le $from) { throw 'Invalid review-budget-extension ceiling' }
    $null = Resolve-Input $fields['evidence']
    return ($Round -lt 3 -or ($from -le $Round -and $Round -lt $through))
}

try {
    $expectations = @{'Task ID'=$ExpectedTaskId; 'Next action'=$ExpectedNextAction; 'Next role'=$ExpectedNextRole; 'Review round'=$ExpectedReviewRound; 'State revision'=$ExpectedStateRevision}
    $hasExpectation = @($PSBoundParameters.Keys | Where-Object { $_ -like 'Expected*' }).Count -gt 0
    if ($hasExpectation -and [string]::IsNullOrWhiteSpace($ExpectedTaskId)) { throw 'ExpectedTaskId is required with any expectation' }
    $text = Read-Input $HandoffPath
    $sections = Get-Sections $text
    foreach ($name in @('Routing','Current Status','Evidence')) {
        if ([string]::IsNullOrWhiteSpace((Get-Body $sections $name))) { throw "Missing section: $name" }
    }
    $routing = Get-Fields (Get-Body $sections 'Routing' -Plain) 'Routing'
    $allowed = @('Schema version','Task ID','State revision','Current role','Current agent','Current status','Next action','Human Action Required','Review round','Next role','Risk level')
    foreach ($key in $allowed) { if (-not $routing.ContainsKey($key)) { throw "Missing Routing field: $key" } }
    foreach ($key in $routing.Keys) { if ($allowed -cnotcontains $key) { throw "Unknown Routing field: $key" } }
    $enums = @{'Schema version'=@('lite-1'); 'Current role'=@('Executor','Reviewer'); 'Current status'=@('in-progress','blocked','awaiting-owner-decision','completed')
        'Next action'=@('continue','dispatch','close'); 'Human Action Required'=@('none','awaiting-decision','awaiting-environment'); 'Next role'=@('none','Executor','Reviewer','Task Owner'); 'Risk level'=@('S','M','H')}
    foreach ($key in $enums.Keys) { if ($enums[$key] -cnotcontains $routing[$key]) { throw "Invalid $key" } }
    if ($routing['Task ID'] -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') { throw 'Invalid Task ID' }
    $revision = Assert-Number $routing['State revision'] 'State revision' 1
    $round = Assert-Number $routing['Review round'] 'Review round' 0
    foreach ($key in $expectations.Keys) {
        $parameter = @{'Task ID'='ExpectedTaskId';'Next action'='ExpectedNextAction';'Next role'='ExpectedNextRole';'Review round'='ExpectedReviewRound';'State revision'='ExpectedStateRevision'}[$key]
        if ($PSBoundParameters.ContainsKey($parameter) -and $routing[$key] -cne $expectations[$key]) { throw "Expected $key '$($expectations[$key])', found '$($routing[$key])'" }
    }
    $action = $routing['Next action']; $status = $routing['Current status']; $human = $routing['Human Action Required']; $next = $routing['Next role']
    $decision = $status -ceq 'awaiting-owner-decision'
    $agentDispatch = $action -ceq 'dispatch' -and $next -cin @('Executor','Reviewer')
    $executable = $action -ceq 'continue' -and $status -ceq 'in-progress'
    $valid = ($executable -and $human -ceq 'none' -and $next -ceq 'none') -or
        ($agentDispatch -and $status -ceq 'in-progress' -and $human -ceq 'none') -or
        ($decision -and $human -ceq 'awaiting-decision' -and (($action -ceq 'continue' -and $next -ceq 'none') -or ($action -ceq 'dispatch' -and $next -ceq 'Task Owner'))) -or
        ($action -ceq 'continue' -and $status -ceq 'blocked' -and $next -ceq 'none' -and $human -cin @('none','awaiting-environment')) -or
        ($action -ceq 'close' -and $status -ceq 'completed' -and $human -ceq 'none' -and $next -ceq 'none')
    if (-not $valid) { throw 'Invalid route: action/status/human/next role conflict' }
    $current = Get-Body $sections 'Current Status'
    $currentPlain = Get-Body $sections 'Current Status' -Plain
    if ($agentDispatch) {
        if (-not (Test-Capacity (Get-Body $sections 'Evidence' -Plain) $routing['Task ID'] $round)) { throw 'Review allowance exhausted; publish the owner decision route' }
        Assert-Command (Get-Body $sections 'Operator Command') 'Operator Command' $routing['Task ID'] $next
        $first = @($currentPlain -split '\r?\n' | Where-Object { $_.Trim() } | Select-Object -First 1)
        if (-not $first.Count -or $first[0] -cnotmatch '^Recommended capability tier: C[1-5]$') { Write-Output 'WARNING: Missing advisory capability as first Current Status line; non-blocking.' }
    } elseif ($sections.ContainsKey('Operator Command')) { throw 'Unexpected Operator Command' }
    $commandCount = [regex]::Matches($currentPlain,'(?m)^### Continuation Command\s*$').Count
    if ($executable) {
        if ($commandCount -ne 1) { throw 'Executable continue requires one Continuation Command' }
        Assert-Command ($current.Substring($current.IndexOf('### Continuation Command'))) 'Continuation Command' $routing['Task ID'] $routing['Current role']
    } elseif ($commandCount) { throw 'Unexpected Continuation Command' }
    if ($decision) {
        $brief = Get-Fields (Get-Body $sections 'Owner Decision Brief' -Plain) 'Owner Decision Brief'
        foreach ($field in @('Decision needed','Recommendation','Alternatives','Reply needed','After the reply')) { if (-not $brief.ContainsKey($field)) { throw "Missing Owner Decision Brief $field" } }
    } elseif ($sections.ContainsKey('Owner Decision Brief')) { throw 'Unexpected Owner Decision Brief' }
    if ($status -ceq 'blocked') {
        $blockers = Get-Body $sections 'Blockers' -Plain
        if ($blockers -notmatch 'Resume condition:\s*\S') { throw 'Blocked state requires Resume condition' }
        if ($human -ceq 'awaiting-environment' -and $blockers -notmatch 'Human preparation:\s*\S') { throw 'Environment wait requires Human preparation' }
    }
    if ($action -ceq 'close' -and [string]::IsNullOrWhiteSpace((Get-Body $sections 'Outcome' -Plain))) { throw 'Close requires Outcome and evidence' }

    if ([bool]$SourceResultPath -ne [bool]$PriorHandoffPath) { throw 'SourceResultPath and PriorHandoffPath must be supplied together' }
    if ($SourceResultPath) {
        $priorPath = Resolve-Input $PriorHandoffPath
        $prior = Get-Sections (Read-Input $PriorHandoffPath)
        $priorRouting = Get-Fields (Get-Body $prior 'Routing' -Plain) 'prior Routing'
        $sourceText = Read-Input $SourceResultPath
        # Metadata is outside fenced response handoffs. Do not examine other files or directories.
        $sourceLines = New-Object 'Collections.Generic.List[string]'; $inFence = $false
        foreach ($line in ($sourceText -split '\r?\n')) {
            if ($line -match '^\s*`{3,}') { $inFence = -not $inFence; continue }
            if (-not $inFence -and $line -match '^\s*- (Task ID|Source role|Source agent|Work producer|Named result|Prior revision|Prior handoff SHA256|Target revision|Cumulative verdicts|Verdict):') { $sourceLines.Add($line) }
        }
        $source = Get-Fields ($sourceLines -join "`n") 'source'
        foreach ($field in @('Task ID','Source role','Source agent','Work producer','Named result','Prior revision','Prior handoff SHA256','Target revision','Cumulative verdicts','Verdict')) { if (-not $source.ContainsKey($field)) { throw "Missing source $field" } }
        $namedPattern = '(?<![A-Za-z0-9_./-])' + [regex]::Escape($SourceResultPath) + '(?![A-Za-z0-9_./-])'
        if ((Get-Body $prior 'Evidence' -Plain) -cnotmatch $namedPattern) { throw 'Source result is not named by prior Evidence' }
        if ($source['Named result'] -cne $SourceResultPath) { throw 'Source Named result mismatch' }
        if ($source['Task ID'] -cne $routing['Task ID'] -or $priorRouting['Task ID'] -cne $routing['Task ID']) { throw 'Source Task ID mismatch' }
        if ($source['Prior handoff SHA256'] -notmatch '^[a-fA-F0-9]{64}$' -or (Get-FileHash -LiteralPath $priorPath -Algorithm SHA256).Hash -ne $source['Prior handoff SHA256']) { throw 'Prior handoff SHA256 mismatch' }
        if ($source['Prior revision'] -cne $priorRouting['State revision'] -or $source['Target revision'] -cne $routing['State revision'] -or
            $revision -ne ((Assert-Number $source['Prior revision'] 'Prior revision' 1) + 1)) { throw 'Source revision mismatch' }
        if ($priorRouting['Current status'] -cne 'in-progress' -or $priorRouting['Next action'] -cne 'dispatch' -or $priorRouting['Next role'] -cne $source['Source role'] -or
            $source['Source role'] -cne 'Reviewer' -or $source['Verdict'] -cnotin @('PASS','FAIL','REVISE') -or
            $source['Source agent'] -ceq $source['Work producer'] -or $source['Source agent'] -cne $routing['Current agent'] -or $routing['Current role'] -cne $source['Source role']) { throw 'Source execution ownership or prior route mismatch' }
        $priorRound = Assert-Number $priorRouting['Review round'] 'prior Review round' 0
        if ($round -ne ($priorRound + 1) -or $source['Cumulative verdicts'] -cne $routing['Review round']) { throw 'Source cumulative verdict mismatch; never reset or recount' }
        if ($priorRouting['Risk level'] -cne $routing['Risk level']) { throw 'Source risk mismatch' }
        Write-Output 'Source matches explicit prior input; no transfer applied or published.'
    }
    Write-Output 'Structure and supplied expectations match. Business acceptance, authorization, independence and host loading are not verified.'
    exit 0
} catch {
    Write-Output ('ERROR: ' + $_.Exception.Message)
    exit 1
}
