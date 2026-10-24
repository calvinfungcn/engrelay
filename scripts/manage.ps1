[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateSet('Install', 'Adopt', 'Uninstall', 'Status', 'CheckVersion', 'Upgrade', 'SetMode')][string]$Action,
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [ValidateSet('none', 'agents', 'codex', 'claude', 'cursor', 'opencode', 'antigravity', 'gemini', 'iflow', 'qwen')]
    [string]$SkillTarget = 'none',
    [ValidateSet('full', 'lite')][string]$WorkflowProfile,
    [ValidateSet('optional', 'default', 'disabled')][string]$WorkflowMode = 'optional',
    [switch]$Preview
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# ValidateSet accepts case-insensitive input. Persist canonical machine values so
# every successful constructor is also readable by the strict v2 reader.
if ($WorkflowProfile) { $WorkflowProfile = $WorkflowProfile.ToLowerInvariant() }
$WorkflowMode = $WorkflowMode.ToLowerInvariant()
$SkillTarget = $SkillTarget.ToLowerInvariant()
$packageRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$ProjectRoot = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\', '/')
$stateRoot = Join-Path $ProjectRoot '.ai-collaboration-install'
$manifestPath = Join-Path $stateRoot 'manifest.json'
$snapshotPath = Join-Path $packageRoot 'snapshot.json'
$begin = '<!-- ai-collaboration:begin -->'
$end = '<!-- ai-collaboration:end -->'
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$sourceCloudTags = @{}
$script:resolvedProfile = 'full'
$targets = @{
    agents = '.agents'; codex = '.codex'; claude = '.claude'; cursor = '.cursor'
    opencode = '.opencode'; antigravity = '.agent'; gemini = '.gemini'; iflow = '.iflow'; qwen = '.qwen'
}

function Get-Hash([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Get-NormalizedTextHash([string]$Path) {
    $info = Read-FileInfo $Path
    return Get-Hash ($utf8.GetBytes(($info.Text -replace "`r`n", "`n")))
}
function Test-CatalogueHash([string]$Path, [string]$Expected) {
    return (Get-Hash ([IO.File]::ReadAllBytes($Path))) -eq $Expected -or (Get-NormalizedTextHash $Path) -eq $Expected
}

function Read-Text([string]$Path) {
    return (Read-FileInfo $Path).Text
}

function Read-FileInfo([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 2 -and (($bytes[0] -eq 255 -and $bytes[1] -eq 254) -or
        ($bytes[0] -eq 254 -and $bytes[1] -eq 255))) {
        throw "UTF-16 is unsupported; preserve the file and convert only with owner approval: $Path"
    }
    $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191
    $text = if ($bom) { $utf8.GetString($bytes, 3, $bytes.Length - 3) } else { $utf8.GetString($bytes) }
    return [pscustomobject]@{ Bytes = $bytes; Text = $text; Bom = $bom }
}

function Encode-Text([string]$Text, [bool]$Bom) {
    if ($Bom) {
        $content = $utf8.GetBytes($Text)
        $result = New-Object byte[] ($content.Length + 3)
        $result[0] = 239; $result[1] = 187; $result[2] = 191
        [Array]::Copy($content, 0, $result, 3, $content.Length)
        return $result
    }
    return $utf8.GetBytes($Text)
}

function Assert-NoReparse([string]$Path, [switch]$AllowSourceCloud) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                # The owner may keep the read-only package in a Cloud Files sync
                # folder. Do not confuse those tags with redirecting links.
                # Target project/state paths still reject ALL reparse points.
                if (-not $AllowSourceCloud) { throw "Reparse point is not allowed: $cursor" }
                if (-not $sourceCloudTags.ContainsKey($cursor)) {
                    $tagOutput = & fsutil.exe reparsepoint query $cursor 2>&1
                    if ($LASTEXITCODE -ne 0) { throw "Cannot inspect source reparse tag: $cursor" }
                    $tag = [regex]::Match(($tagOutput -join "`n"), '0x[0-9a-fA-F]{8}').Value
                    if ($tag -notmatch '^0x9000[0-9a-f]01a$') { throw "Redirecting or unknown source reparse point: $cursor" }
                    $sourceCloudTags[$cursor] = $tag
                }
            }
        }
        $parent = Split-Path -Parent $cursor
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
}

function Resolve-ProjectFile([string]$Relative) {
    if ([string]::IsNullOrWhiteSpace($Relative) -or $Relative -match '[:\\]' -or
        $Relative.StartsWith('/') -or $Relative -match '(^|/)\.\.?(/|$)') {
        throw "Unsafe relative path: $Relative"
    }
    $path = [IO.Path]::GetFullPath((Join-Path $ProjectRoot $Relative))
    if (-not $path.StartsWith($ProjectRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes project: $Relative"
    }
    Assert-NoReparse $path
    if (Test-Path -LiteralPath $path -PathType Container) { throw "Expected file, found directory: $Relative" }
    return $path
}

function Write-Bytes([string]$Path, [byte[]]$Bytes) {
    Assert-NoReparse $Path
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    [IO.File]::WriteAllBytes($Path, $Bytes)
}

function Get-SkillCopyPath([string]$Relative, [string]$SelectedTarget) {
    if ($SelectedTarget -eq 'none') { return $null }
    if ($Relative -match '^docs/ai-collaboration/skills/(ce-code-review|ce-debug|ce-simplify-code|ce-compound|ai-collab-requirements|ai-collab-start|ai-collab-continue)/(.+)$') {
        return $targets[$SelectedTarget] + '/skills/' + $Matches[1] + '/' + $Matches[2]
    }
    return $null
}

function Get-BasePlan {
    $payload = Join-Path $packageRoot 'payload'
    if (-not (Test-Path -LiteralPath $payload -PathType Container)) { throw 'Payload missing' }
    Assert-NoReparse $payload -AllowSourceCloud
    $items = New-Object 'Collections.Generic.List[object]'
    if ($script:resolvedProfile -eq 'lite') {
        $liteRoot = Join-Path $payload 'docs/ai-collaboration/lite'
        $files = @('RULES.md','README.md','README.zh-CN.md','LICENSE','templates/project-config.md','templates/queue.md','templates/task.md','templates/handoff.md','scripts/validate-state.ps1','scripts/doctor.ps1')
        foreach ($relative in $files) {
            $source = Join-Path $liteRoot $relative
            Assert-NoReparse $source -AllowSourceCloud
            if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Lite source missing: $relative" }
            $items.Add([pscustomobject]@{path=('docs/engrelay-lite/' + $relative);kind='file';source=$source})
        }
        $items.Add([pscustomobject]@{path='docs/engrelay-lite.config.md';kind='project-document';source=(Join-Path $liteRoot 'templates/project-config.md')})
        $items.Add([pscustomobject]@{path='AGENTS.md';kind='agents';source=(Join-Path $liteRoot 'agent-rules.md')})
        $items.Add([pscustomobject]@{path='.gitignore';kind='gitignore';source=$null})
        return $items.ToArray()
    }
    foreach ($file in Get-ChildItem -LiteralPath $payload -Recurse -File) {
        Assert-NoReparse $file.FullName -AllowSourceCloud
        $relative = $file.FullName.Substring($payload.Length + 1).Replace('\', '/')
        if ($relative.StartsWith('docs/ai-collaboration/lite/', [StringComparison]::Ordinal)) { continue }
        if ($relative -notmatch '^docs/ai-collaboration/' -and $relative -notin @(
            'docs/reviews/README.md', 'docs/solutions/README.md', 'docs/solutions/solution.template.md')) {
            throw "Unexpected payload file: $relative"
        }
        $items.Add([pscustomobject]@{ path = $relative; kind = 'file'; source = $file.FullName })
    }
    $rules = Join-Path $packageRoot 'agent-rules.md'
    Assert-NoReparse $rules -AllowSourceCloud
    $items.Add([pscustomobject]@{ path = 'AGENTS.md'; kind = 'agents'; source = $rules })
    $items.Add([pscustomobject]@{ path = '.gitignore'; kind = 'gitignore'; source = $null })
    return $items.ToArray()
}

function Get-Plan([string]$SelectedTarget) {
    if ($script:resolvedProfile -eq 'lite' -and $SelectedTarget -ne 'none') { throw 'Lite supports SkillTarget none only; use explicit RULES.md reading' }
    if ($SelectedTarget -ne 'none' -and -not $targets.ContainsKey($SelectedTarget)) { throw 'Invalid Skill target' }
    $items = New-Object 'Collections.Generic.List[object]'
    foreach ($item in @(Get-BasePlan)) {
        $items.Add($item)
        $copyPath = Get-SkillCopyPath ([string]$item.path) $SelectedTarget
        if ($null -ne $copyPath) { $items.Add([pscustomobject]@{ path = $copyPath; kind = 'file'; source = $item.source }) }
    }
    return $items.ToArray()
}

function Write-InstallDiscoveryGuidance([string]$SelectedTarget) {
    if ($script:resolvedProfile -eq 'lite') {
        Write-Information 'WorkflowProfile: lite; SkillTarget: none; explicitly read docs/engrelay-lite/RULES.md and docs/engrelay-lite.config.md. No dedicated Skill or host discovery copies. Host loading=unknown.' -InformationAction Continue
        return
    }
    $canonicalRelative = 'docs/ai-collaboration/skills/ai-collab-start/SKILL.md'
    $canonicalFull = [IO.Path]::GetFullPath((Join-Path $ProjectRoot ($canonicalRelative -replace '/', '\')))
    Write-Information ("SkillTarget: " + $SelectedTarget) -InformationAction Continue
    Write-Information ("ProjectRoot: " + $ProjectRoot) -InformationAction Continue
    Write-Information ("Canonical Skills: " + $canonicalFull) -InformationAction Continue
    if ($SelectedTarget -eq 'none') {
        Write-Information 'This install did not deploy package-managed host discovery copies for this target.' -InformationAction Continue
    }
    else {
        $discoveryRelative = ($targets[$SelectedTarget] + '/skills') -replace '/', '\'
        $discoveryFull = [IO.Path]::GetFullPath((Join-Path $ProjectRoot $discoveryRelative))
        Write-Information ("Package-managed discovery copies: " + $discoveryFull) -InformationAction Continue
    }
    Write-Information 'File placement does not prove host discovery or loading; confirm in an actual host session.' -InformationAction Continue
}

function Test-SafeRelative([string]$Relative) {
    return (-not [string]::IsNullOrWhiteSpace($Relative)) -and $Relative -notmatch '[:\\]' -and
        -not $Relative.StartsWith('/') -and $Relative -notmatch '(^|/)\.\.?(/|$)'
}

function Get-LegacyCatalogue {
    $path = Join-Path $packageRoot 'payload/docs/ai-collaboration/legacy-adoption.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Legacy adoption catalogue missing' }
    try { $catalogue = (Read-FileInfo $path).Text | ConvertFrom-Json } catch { throw 'Invalid legacy adoption catalogue' }
    if ($catalogue.schemaVersion -ne 1 -or @($catalogue.profiles).Count -eq 0) { throw 'Invalid legacy adoption catalogue' }
    foreach ($profile in @($catalogue.profiles)) {
        if ([string]$profile.id -notmatch '^[A-Za-z0-9_.-]+$' -or @($profile.canonical).Count -eq 0) { throw 'Invalid legacy adoption profile' }
        $seen = @{}
        foreach ($item in @($profile.canonical)) {
            if (-not (Test-SafeRelative ([string]$item.path)) -or [string]$item.hash -notmatch '^[a-f0-9]{64}$' -or $seen.ContainsKey([string]$item.path)) { throw 'Invalid legacy adoption path or hash' }
            $seen[[string]$item.path] = $true
        }
        foreach ($item in @($profile.legacyEntries)) {
            if (-not (Test-SafeRelative ([string]$item.path)) -or [string]$item.hash -notmatch '^[a-f0-9]{64}$' -or [string]$item.marker -eq '') { throw 'Invalid legacy entry catalogue' }
        }
        foreach ($item in @($profile.legacyEntryChanges)) {
            if (-not (Test-SafeRelative ([string]$item.path)) -or [string]$item.fragmentHash -notmatch '^[a-f0-9]{64}$' -or [string]$item.marker -eq '') { throw 'Invalid legacy entry change catalogue' }
        }
    }
    return $catalogue
}

function Get-LegacyProfile {
    $catalogue = Get-LegacyCatalogue
    $supplementalOptionalPath = 'docs/solutions/solution.template.md'
    $matches = New-Object 'Collections.Generic.List[object]'
    $diagnostics = New-Object 'Collections.Generic.List[string]'
    foreach ($profile in @($catalogue.profiles)) {
        $matched = $true
        foreach ($item in @($profile.canonical)) {
            $path = Resolve-ProjectFile ([string]$item.path)
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
                if ([string]$item.path -eq $supplementalOptionalPath) { continue }
                $matched = $false; $diagnostics.Add("$($profile.id): missing $($item.path)"); break
            }
            if (-not (Test-CatalogueHash $path ([string]$item.hash))) { $matched = $false; $diagnostics.Add("$($profile.id): changed $($item.path)"); break }
        }
        foreach ($item in @($profile.legacyEntries)) {
            $path = Resolve-ProjectFile ([string]$item.path)
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $matched = $false; $diagnostics.Add("$($profile.id): missing $($item.path)"); break }
        }
        if ($matched) { $matches.Add($profile) }
    }
    if ($matches.Count -ne 1) { throw "Legacy adoption requires one complete known profile; matched=$($matches.Count); conflicts=$($diagnostics -join ', ')" }
    return $matches[0]
}

function Get-LegacyEntryReplacement([string]$Path, [string]$Text, [string]$Mode, [string]$ExpectedFragmentHash) {
    $marker = '## Multi-Agent Collaboration Standard'
    $markerMatches = [regex]::Matches($Text, '(?m)^## Multi-Agent Collaboration Standard\s*$')
    if ($markerMatches.Count -ne 1) { throw "Known legacy entry is not unique: $Path" }
    $start = $markerMatches[0].Index
    $lineStart = $Text.LastIndexOf("`n", $start)
    $lineStart = if ($lineStart -lt 0) { 0 } else { $lineStart + 1 }
    $nextMatch = [regex]::Match($Text.Substring($lineStart + $marker.Length), '(?m)^##\s+')
    $endAt = if ($nextMatch.Success) { $lineStart + $marker.Length + $nextMatch.Index } else { $Text.Length }
    $fragment = $Text.Substring($lineStart, $endAt - $lineStart).TrimEnd("`r","`n") -replace "`r`n", "`n"
    if ((Get-Hash ($utf8.GetBytes($fragment))) -ne $ExpectedFragmentHash) { throw "Known legacy entry fragment differs from catalogue: $Path" }
    $prefix = $Text.Substring(0, $lineStart)
    $suffix = $Text.Substring($endAt)
    $insertion = Get-ManagedInsertion 'agents' ($prefix + $suffix) $Mode
    return [pscustomobject]@{ Bytes = Encode-Text ($prefix + $insertion + $suffix) ((Read-FileInfo $Path).Bom); Insertion = $insertion }
}

function Get-LegacyFragmentReplacement([string]$Path, [string]$Text, [object]$Entry) {
    $fragment = [string]$Entry.fragment
    if ([regex]::Matches(($Text -replace "`r`n", "`n"), [regex]::Escape($fragment)).Count -ne 1) { throw "Known legacy host fragment is not unique: $Path" }
    $normalized = $fragment -replace "`r`n", "`n"
    if ((Get-Hash ($utf8.GetBytes($normalized))) -ne [string]$Entry.fragmentHash) { throw "Known legacy host fragment catalogue mismatch: $Path" }
    $index = $Text.IndexOf($fragment, [StringComparison]::Ordinal)
    if ($index -lt 0) { $index = $Text.IndexOf($fragment.Replace("`n", "`r`n"), [StringComparison]::Ordinal) }
    if ($index -lt 0) { throw "Known legacy host fragment is not present: $Path" }
    $length = if ($Text.Substring($index).StartsWith($fragment)) { $fragment.Length } else { $fragment.Replace("`n", "`r`n").Length }
    $prefix = $Text.Substring(0, $index); $suffix = $Text.Substring($index + $length)
    if ($suffix.StartsWith("`r`n")) { $suffix = $suffix.Substring(2) } elseif ($suffix.StartsWith("`n")) { $suffix = $suffix.Substring(1) }
    return [pscustomobject]@{ Bytes = Encode-Text ($prefix + [string]$Entry.replacement + $suffix) ((Read-FileInfo $Path).Bom); BeforeHash = Get-Hash ([IO.File]::ReadAllBytes($Path)); FragmentHash = [string]$Entry.fragmentHash }
}

function Assert-NoRetiredResidualActivation([object]$Profile) {
    if ([string]$Profile.id -ne 'retired-notice-2026-10') { return }
    $paths = @('AGENTS.md','CLAUDE.md','QWEN.md','IFLOW.md','GEMINI.md')
    $oldHandoff = '- Multi-agent handoff: read `docs/ai-collaboration/README.md` only when switching roles, handing work to another agent, or generating `.ai/handoff.md`.'
    foreach ($relative in $paths) {
        $path = Resolve-ProjectFile $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        $text = Read-Text $path
        if ($text.Contains($begin) -or $text.Contains($end) -or
            $text -match '(?im)^##\s+Multi-Agent Collaboration Standard\s*$' -or
            $text.Contains($oldHandoff)) {
            throw "Retired profile has residual legacy activation: $relative"
        }
    }
}

# Source-only registry of trusted v1 layouts. Unknown v1 versions are refused;
# nothing here is learned from a manifest or recalculated using new source bytes.
function Get-SupportedLayouts {
    $registryPath = Join-Path $PSScriptRoot 'supported-layouts.json'
    if (-not (Test-Path -LiteralPath $registryPath -PathType Leaf)) { throw 'Supported layout registry missing' }
    try { $registry = (Read-FileInfo $registryPath).Text | ConvertFrom-Json } catch { throw 'Invalid supported layout registry' }
    $entries = @(Get-StateValue $registry 'supportedPreviousLayouts' $null | Where-Object { $null -ne $_ })
    if ((Get-StateValue $registry 'schemaVersion') -ne 1 -or $entries.Count -eq 0) { throw 'Invalid supported layout registry' }
    foreach ($entry in $entries) {
        $fingerprints = @(Get-StateValue $entry 'deploymentFingerprints' | ForEach-Object { [string]$_ })
        if ([string](Get-StateValue $entry 'packageVersion') -notmatch '^\d+\.\d+\.\d+$' -or $fingerprints.Count -eq 0 -or
            @($fingerprints | Where-Object { $_ -notmatch '^[a-f0-9]{64}$' }).Count -gt 0 -or
            $null -eq $entry.PSObject.Properties['additions'] -or $null -eq $entry.PSObject.Properties['retirements']) { throw 'Invalid supported layout registry' }
        $seen = @{}
        foreach ($item in @(Get-StateValue $entry 'paths')) {
            if (-not (Test-SafeRelative ([string]$item.path)) -or [string]$item.kind -notin @('file', 'agents', 'gitignore') -or
                $seen.ContainsKey([string]$item.path)) { throw 'Invalid supported layout registry' }
            $seen[[string]$item.path] = $true
        }
    }
    return $entries
}

function Get-LayoutMap([object[]]$Items) {
    $map = @{}
    foreach ($item in @($Items)) { $map[[string]$item.path] = [string]$item.kind }
    return $map
}

# The layout a manifest claims is verified here, never inferred from the manifest's own records.
# v1 needs the trusted original registry; v2 binds its fixed profile and deployment set.
function Get-InstalledLayout([object]$State) {
    $selectedTarget = [string](Get-StateValue $State 'skillTarget' 'none')
    if ($selectedTarget -ne 'none' -and -not $targets.ContainsKey($selectedTarget)) { throw 'Invalid Skill target' }
    if ($State.version -eq 2) {
        $plan = @(Get-Plan $selectedTarget)
        $expected = @{}; foreach ($item in $plan) { $expected[$item.path] = $item }
        $entries = @(Get-StateValue $State 'deploymentSet' @())
        $seen = @{}
        foreach ($entry in $entries) {
            $path = [string](Get-StateValue $entry 'path' '')
            if (-not $expected.ContainsKey($path) -or $seen.ContainsKey($path)) { throw 'Invalid v2 deployment set path' }
            $item = $expected[$path]
            $source = if ($null -eq $item.source) { '-' } else { $item.source.Substring($packageRoot.Length + 1).Replace('\','/') }
            $size = [string](Get-StateValue $entry 'bytes' '')
            if ($path -cne $item.path -or [string](Get-StateValue $entry 'source' '') -cne $source -or [string](Get-StateValue $entry 'kind' '') -cne $item.kind -or
                [string](Get-StateValue $entry 'sha256' '') -cnotmatch '^[a-f0-9]{64}$' -or $size -notmatch '^(0|[1-9][0-9]{0,14})$') { throw 'Invalid v2 deployment set record' }
            $seen[$path] = $true
        }
        if ($seen.Count -ne $expected.Count -or (Get-ProfileFingerprint $State.packageVersion $script:resolvedProfile $selectedTarget $entries) -cne [string](Get-StateValue $State 'deploymentFingerprint' '')) { throw 'Invalid v2 deployment fingerprint or layout' }
        return [pscustomobject]@{Kind='current';Version=$State.packageVersion;Entry=$null;Base=$plan;Map=(Get-LayoutMap $plan)}
    }
    $claimed = Get-StateValue $State 'packageVersion'
    if ($null -ne $claimed -and -not [string]::IsNullOrWhiteSpace([string]$claimed)) {
        $entry = @(Get-SupportedLayouts | Where-Object { [string](Get-StateValue $_ 'packageVersion') -eq [string]$claimed }) | Select-Object -First 1
        if ($null -ne $entry) {
            $acceptedFingerprints = @(Get-StateValue $entry 'deploymentFingerprints' | ForEach-Object { [string]$_ })
            if ($acceptedFingerprints -notcontains [string](Get-StateValue $State 'deploymentFingerprint')) {
                throw "Installed packageVersion $claimed does not match its verified layout fingerprint; retain backups and reconcile manually"
            }
            $expanded = New-Object 'Collections.Generic.List[object]'
            foreach ($item in @(Get-StateValue $entry 'paths')) {
                $expanded.Add([pscustomobject]@{ path = [string]$item.path; kind = [string]$item.kind })
                $copyPath = Get-SkillCopyPath ([string]$item.path) $selectedTarget
                if ($null -ne $copyPath) { $expanded.Add([pscustomobject]@{ path = $copyPath; kind = 'file' }) }
            }
            return [pscustomobject]@{ Kind = 'supported'; Version = [string]$claimed; Entry = $entry
                Base = @(Get-StateValue $entry 'paths'); Map = (Get-LayoutMap $expanded.ToArray()) }
        }
    }
    throw 'Unknown v1 installation: a trusted original layout and fingerprint are required; retain the original package and backups'
}

function New-ManifestRecord([string]$Path, [string]$Kind, [string]$Hash, [bool]$Preexisting, [string]$BeforeHash, [string]$Backup, [string]$Insertion) {
    return [pscustomobject]@{ path = $Path; kind = $Kind; hash = $Hash; preexisting = $Preexisting
        beforeHash = $BeforeHash; backup = $Backup; insertion = $Insertion }
}

function Assert-NoFileAncestor([string]$Path) {
    $cursor = Split-Path -Parent $Path
    while ($cursor.Length -gt $ProjectRoot.Length) {
        if (Test-Path -LiteralPath $cursor -PathType Leaf) { throw "Cannot create a managed path below an existing file: $cursor" }
        $cursor = Split-Path -Parent $cursor
    }
}

# Complete read-only preflight for Upgrade and CheckVersion. It validates the registered
# transition, the common files, the added paths and the retired paths before any write.
function Get-UpgradePlan([object]$State) {
    $selectedTarget = [string](Get-StateValue $State 'skillTarget' 'none')
    $candidatePlan = @(Get-Plan $selectedTarget)
    $candidateByPath = @{}
    foreach ($item in $candidatePlan) { $candidateByPath[[string]$item.path] = $item }
    $layout = $script:installedLayout
    if ($layout.Kind -eq 'supported') {
        $candidateBase = @(Get-BasePlan)
        $candidateBaseMap = Get-LayoutMap $candidateBase
        $installedBaseMap = Get-LayoutMap $layout.Base
        $addedBase = @($candidateBase | Where-Object { -not $installedBaseMap.ContainsKey([string]$_.path) } | ForEach-Object { [string]$_.path } | Sort-Object)
        $retiredBase = @($layout.Base | Where-Object { -not $candidateBaseMap.ContainsKey([string]$_.path) } | ForEach-Object { [string]$_.path } | Sort-Object)
        $declaredAdded = @(Get-StateValue $layout.Entry 'additions' | ForEach-Object { [string]$_ } | Sort-Object)
        $declaredRetired = @(Get-StateValue $layout.Entry 'retirements' | ForEach-Object { [string]$_ } | Sort-Object)
        if (($addedBase -join "`n") -ne ($declaredAdded -join "`n")) {
            throw "Manifest layout does not match this package: additions from $($layout.Version) are not the registered set"
        }
        if (($retiredBase -join "`n") -ne ($declaredRetired -join "`n")) {
            throw "Manifest layout does not match this package: retirements from $($layout.Version) are not the registered set"
        }
        foreach ($item in @($layout.Base)) {
            $path = [string]$item.path
            if ($candidateBaseMap.ContainsKey($path) -and $candidateBaseMap[$path] -ne [string]$item.kind) {
                throw "Manifest layout does not match this package: kind changed for $path"
            }
        }
    }
    $planned = @{}
    $records = New-Object 'Collections.Generic.List[object]'
    $recovery = New-Object 'Collections.Generic.List[object]'
    $created = New-Object 'Collections.Generic.List[string]'
    $retired = New-Object 'Collections.Generic.List[string]'
    $deletes = New-Object 'Collections.Generic.List[string]'
    $modeValue = Get-StateValue $State 'workflowMode'
    $mode = if ($null -eq $modeValue) { 'default' } else { ([string]$modeValue).ToLowerInvariant() }
    foreach ($record in @($State.files)) {
        $relative = [string]$record.path
        $path = Resolve-ProjectFile $relative
        if ([string]$record.kind -eq 'project-document') {
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Project configuration missing: $relative; restore the project-owned content before Upgrade" }
            $records.Add($record)
            continue
        }
        $currentBytes = [IO.File]::ReadAllBytes($path)
        $currentHash = Get-Hash $currentBytes
        $recovery.Add([pscustomobject]@{ path = $relative; hash = $currentHash; bytes = [Convert]::ToBase64String($currentBytes) })
        if (-not $candidateByPath.ContainsKey($relative)) {
            if ([string]$record.kind -ne 'file') { throw "Managed block retirement is not supported: $relative" }
            if ($currentHash -ne [string]$record.hash) { throw "Owned file drifted: $relative" }
            $retired.Add($relative)
            if (-not [bool]$record.preexisting) { $deletes.Add($path) }
            continue
        }
        $item = $candidateByPath[$relative]
        if ([string]$item.kind -ne [string]$record.kind) {
            throw 'Existing installation layout is not supported by this package; use original package for migration'
        }
        if ([string]$record.kind -eq 'file') {
            $source = [IO.File]::ReadAllBytes($item.source)
            $sourceHash = Get-Hash $source
            if ([string](Get-StateValue $record 'adoption' '') -eq 'project-document') {
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Project document missing: $relative" }
                $keep = New-ManifestRecord $relative 'file' $currentHash $true ([string]$record.beforeHash) ([string]$record.backup) $null
                $keep | Add-Member -MemberType NoteProperty -Name adoption -Value 'project-document'
                $keep | Add-Member -MemberType NoteProperty -Name legacyProfile -Value ([string](Get-StateValue $record 'legacyProfile' ''))
                $records.Add($keep)
                continue
            }
            $adoptedCanonical = [string](Get-StateValue $record 'adoption' '') -eq 'canonical-legacy'
            if ([bool]$record.preexisting -and -not $adoptedCanonical -and $currentHash -ne $sourceHash) { throw "Refusing to overwrite preexisting file: $relative" }
            if ($currentHash -ne [string]$record.hash -and $currentHash -ne $sourceHash) { throw "Owned file drifted: $relative" }
            if ($currentHash -ne $sourceHash) { $planned[$relative] = $source }
            $next = New-ManifestRecord $relative 'file' $sourceHash ([bool]$record.preexisting) ([string]$record.beforeHash) ([string]$record.backup) $null
            foreach ($n in @('adoption','legacyProfile')) { $v = Get-StateValue $record $n $null; if ($null -ne $v) { $next | Add-Member -MemberType NoteProperty -Name $n -Value $v } }
            $records.Add($next)
        }
        else {
            $replacement = Get-ManagedReplacement $record $path $mode
            $planned[$relative] = $replacement.Bytes
            $records.Add((New-ManifestRecord $relative ([string]$record.kind) (Get-Hash $replacement.Bytes) ([bool]$record.preexisting) ([string]$record.beforeHash) ([string]$record.backup) $replacement.Insertion))
        }
    }
    foreach ($item in $candidatePlan) {
        $relative = [string]$item.path
        if ($layout.Map.ContainsKey($relative)) { continue }
        if ([string]$item.kind -ne 'file') { throw "Added managed block is not supported: $relative" }
        $path = Resolve-ProjectFile $relative
        Assert-NoFileAncestor $path
        $source = [IO.File]::ReadAllBytes($item.source)
        $sourceHash = Get-Hash $source
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $existing = [IO.File]::ReadAllBytes($path)
            if ((Get-Hash $existing) -ne $sourceHash) { throw "Refusing to overwrite preexisting file: $relative" }
            $records.Add((New-ManifestRecord $relative 'file' $sourceHash $true (Get-Hash $existing) ([Convert]::ToBase64String($existing)) $null))
        }
        else {
            $planned[$relative] = $source
            $created.Add($relative)
            $records.Add((New-ManifestRecord $relative 'file' $sourceHash $false (Get-Hash ([byte[]]@())) '' $null))
        }
    }
    return [pscustomobject]@{ Records = $records.ToArray(); Planned = $planned; Recovery = $recovery.ToArray()
        Created = $created.ToArray(); Retired = $retired.ToArray(); Deletes = $deletes.ToArray() }
}


function Get-Snapshot {
    if (-not (Test-Path -LiteralPath $snapshotPath -PathType Leaf)) { throw 'snapshot.json missing' }
    try { $snapshot = (Read-FileInfo $snapshotPath).Text | ConvertFrom-Json } catch { throw 'Invalid snapshot.json' }
    if ($snapshot.schemaVersion -ne 1 -or [string]::IsNullOrWhiteSpace([string]$snapshot.packageVersion) -or
        [string]$snapshot.packageVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid package snapshot metadata' }
    return $snapshot
}

function Assert-PackageIntegrity {
    $snapshot = Get-Snapshot
    $listed = @{}
    foreach ($entry in @($snapshot.files)) {
        if ($null -eq $entry -or [string]::IsNullOrWhiteSpace([string]$entry.path) -or
            -not (Test-SafeRelative ([string]$entry.path)) -or $entry.path -eq 'snapshot.json' -or
            [string]$entry.sha256 -notmatch '^[a-fA-F0-9]{64}$' -or [string]$entry.bytes -notmatch '^(0|[1-9][0-9]{0,14})$' -or
            $listed.ContainsKey($entry.path)) { throw 'Invalid snapshot file list' }
        $path = Join-Path $packageRoot ($entry.path.Replace('/', '\'))
        Assert-NoReparse $path -AllowSourceCloud
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Snapshot file missing: $($entry.path)" }
        $bytes = [IO.File]::ReadAllBytes($path)
        if ($bytes.Length -ne [int64]$entry.bytes -or
            (Get-Hash $bytes) -ne ([string]$entry.sha256).ToLowerInvariant()) { throw "Package integrity mismatch: $($entry.path)" }
        $listed[$entry.path] = $true
    }
    $actual = @(Get-ChildItem -LiteralPath $packageRoot -Recurse -File |
        ForEach-Object { $_.FullName.Substring($packageRoot.Length + 1).Replace('\', '/') } |
        Where-Object { $_ -ne 'snapshot.json' -and $_ -notmatch '(^|/)(\.git|\.ai)(/|$)' })
    if (@($actual | Where-Object { -not $listed.ContainsKey($_) }).Count -gt 0 -or
        @($listed.Keys | Where-Object { $_ -notin $actual }).Count -gt 0) { throw 'Package file set differs from snapshot' }
    return $snapshot
}

function Get-LegacyDeploymentFingerprint([object]$Snapshot) {
    # Ordinal path order keeps the fingerprint identical on PowerShell 7 and Windows PowerShell 5.1.
    # Culture-sorted 1.2.0 fingerprints are recorded per host in supported-layouts.json.
    $lines = New-Object 'Collections.Generic.List[string]'
    $lines.Add('packageVersion=' + [string]$Snapshot.packageVersion)
    $selected = @($Snapshot.files | Where-Object { $_.path -eq 'agent-rules.md' -or $_.path -like 'payload/*' })
    $paths = [string[]]@($selected | ForEach-Object { [string]$_.path })
    [Array]::Sort($paths, [StringComparer]::Ordinal)
    foreach ($path in $paths) {
        $entry = @($selected | Where-Object { [string]$_.path -ceq $path })[0]
        $lines.Add(([string]$entry.path) + '|' + ([string]$entry.sha256).ToLowerInvariant() + '|' + [string]$entry.bytes)
    }
    return Get-Hash ($utf8.GetBytes(($lines -join [Environment]::NewLine)))
}

function Get-DeploymentSet([object]$Snapshot, [string]$SelectedTarget) {
    $sourceEntries = @{}; foreach ($entry in $Snapshot.files) { $sourceEntries[[string]$entry.path] = $entry }
    foreach ($item in @(Get-Plan $SelectedTarget)) {
        $source = if ($null -eq $item.source) { '-' } else { $item.source.Substring($packageRoot.Length + 1).Replace('\','/') }
        if ($source -eq '-') { $hash = Get-Hash ([byte[]]@()); $size = 0 }
        else {
            if (-not $sourceEntries.ContainsKey($source)) { throw "Deployment source missing from inventory: $source" }
            $hash = [string]$sourceEntries[$source].sha256; $size = [int64]$sourceEntries[$source].bytes
        }
        [pscustomobject]@{source=$source;path=$item.path;kind=$item.kind;sha256=$hash;bytes=$size}
    }
}

function Get-ProfileFingerprint([string]$Version, [string]$Profile, [string]$SelectedTarget, [object[]]$Entries) {
    $lines = New-Object 'Collections.Generic.List[string]'
    foreach ($header in @('deployment-v2',('packageVersion='+$Version),('workflowProfile='+$Profile),('skillTarget='+$SelectedTarget))) { $lines.Add($header) }
    $paths = [string[]]@($Entries | ForEach-Object { [string]$_.path }); [Array]::Sort($paths,[StringComparer]::Ordinal)
    foreach ($path in $paths) {
        $entry = @($Entries | Where-Object { [string]$_.path -ceq $path })[0]
        $lines.Add($entry.source+'|'+$entry.path+'|'+$entry.kind+'|'+$entry.sha256+'|'+[string]$entry.bytes)
    }
    return Get-Hash ($utf8.GetBytes(($lines -join "`n")))
}

function Get-DeploymentFingerprint([object]$Snapshot) {
    return Get-ProfileFingerprint $Snapshot.packageVersion $script:resolvedProfile $SkillTarget @(Get-DeploymentSet $Snapshot $SkillTarget)
}

function Get-VersionParts([string]$Version) {
    if ($Version -notmatch '^(\d+)\.(\d+)\.(\d+)$') { return $null }
    return @([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
}

function Compare-Version([string]$A, [string]$B) {
    $aa = Get-VersionParts $A; $bb = Get-VersionParts $B
    if ($null -eq $aa -or $null -eq $bb) { throw 'Package version is not semantic' }
    foreach ($i in 0..2) {
        if ($aa[$i] -lt $bb[$i]) { return -1 }
        if ($aa[$i] -gt $bb[$i]) { return 1 }
    }
    return 0
}

function Read-State {
    $script:installedLayout = $null
    Assert-NoReparse $manifestPath
    if (-not (Test-Path -LiteralPath $manifestPath)) { return $null }
    $state = (Read-Text $manifestPath) | ConvertFrom-Json
    if ($state.version -notin @(1,2) -or $state.projectRoot -ne $ProjectRoot -or $state.phase -notin @('installed', 'inactive')) {
        throw 'Invalid, moved or interrupted installation manifest; retain backups and reconcile manually'
    }
    if ($state.version -eq 2) {
        $profile = [string](Get-StateValue $state 'workflowProfile' '')
        if ($profile -cnotin @('full','lite') -or [string](Get-StateValue $state 'workflowMode' '') -cnotin @('optional','default','disabled') -or
            [string](Get-StateValue $state 'packageVersion' '') -notmatch '^\d+\.\d+\.\d+$' -or $null -eq (Get-StateValue $state 'skillTarget' $null)) { throw 'Invalid v2 workflow profile or metadata' }
        $script:resolvedProfile = $profile
    }
    $script:installedLayout = Get-InstalledLayout $state
    $allowedLayout = $script:installedLayout.Map
    $seen = @{}
    foreach ($record in @($state.files)) {
        $allowedKind = if ($allowedLayout.ContainsKey([string]$record.path)) { $allowedLayout[[string]$record.path] } else { $null }
        if ($null -eq $allowedKind -or $seen.ContainsKey($record.path) -or
            $record.kind -ne $allowedKind -or $record.hash -notmatch '^[a-f0-9]{64}$' -or
            $record.preexisting -isnot [bool]) { throw 'Manifest file record is not allowed' }
        $seen[$record.path] = $true
        $null = Resolve-ProjectFile $record.path
          if ($record.kind -eq 'project-document') {
              if ($state.version -ne 2 -or $script:resolvedProfile -ne 'lite' -or $record.path -cne 'docs/engrelay-lite.config.md' -or
                  $null -ne (Get-StateValue $record 'adoption' $null) -or $null -ne (Get-StateValue $record 'backup' $null) -or
                  $null -ne (Get-StateValue $record 'insertion' $null) -or $null -ne (Get-StateValue $record 'legacyProfile' $null)) { throw 'Invalid project-document ownership record' }
              continue
          }
        if ($record.preexisting) {
            $before = [Convert]::FromBase64String($record.backup)
            if ((Get-Hash $before) -ne $record.beforeHash) { throw 'Corrupt original backup' }
        }
        $adoption = Get-StateValue $record 'adoption' $null
        if ($null -ne $adoption -and [string]$adoption -notin @('canonical-legacy','project-document','legacy-entry')) { throw 'Invalid adoption record' }
        if ($null -ne $adoption -and [string]$record.legacyProfile -notmatch '^[A-Za-z0-9_.-]+$') { throw 'Invalid adoption profile' }
        if ($null -ne $adoption) {
            if (-not [bool]$record.preexisting) { throw 'Adoption record must retain a preexisting file' }
            $catalogue = Get-LegacyCatalogue
            $profile = @($catalogue.profiles | Where-Object { [string]$_.id -eq [string]$record.legacyProfile }) | Select-Object -First 1
            if ($null -eq $profile) { throw 'Adoption profile is not in the trusted catalogue' }
            $knownCount = if ([string]$adoption -eq 'canonical-legacy') { @($profile.canonical | Where-Object { [string]$_.path -eq [string]$record.path }).Count } elseif ([string]$adoption -eq 'legacy-entry') { @($profile.legacyEntries | Where-Object { [string]$_.path -eq [string]$record.path }).Count } else { @($profile.projectDocuments | Where-Object { [string]$_ -eq [string]$record.path }).Count }
            if ([int]$knownCount -ne 1) { throw 'Adoption record path is not allowed by its trusted profile' }
            if ([string]$adoption -eq 'legacy-entry' -and [string]$record.kind -ne 'agents') { throw 'Legacy entry adoption kind is invalid' }
            if ([string]$adoption -in @('canonical-legacy','project-document') -and [string]$record.kind -ne 'file') { throw 'File adoption kind is invalid' }
        }
        if ($record.kind -ne 'file') {
            if ([string]::IsNullOrEmpty($record.insertion) -or $record.insertion.IndexOf($begin) -lt 0 -or
                $record.insertion.IndexOf($end) -lt 0) { throw 'Invalid managed block record' }
        }
    }
    $seenLegacyChanges = @{}
    foreach ($change in @(Get-StateValue $state 'legacyEntryChanges' @())) {
        $changePath = [string]$change.path
        if ([string]$change.kind -ne 'legacy-entry' -or $changePath -notmatch '^(QWEN|IFLOW)\.md$' -or $seenLegacyChanges.ContainsKey($changePath) -or [string]$change.legacyProfile -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$' -or [string]$change.hash -notmatch '^[a-f0-9]{64}$' -or [string]$change.fragmentHash -notmatch '^[a-f0-9]{64}$' -or [string]$change.beforeHash -notmatch '^[a-f0-9]{64}$' -or [string]::IsNullOrWhiteSpace([string]$change.backup)) { throw 'Invalid legacy entry change record' }
        $seenLegacyChanges[$changePath] = $true
        $catalogue = Get-LegacyCatalogue; $profile = @($catalogue.profiles | Where-Object { [string]$_.id -eq [string]$change.legacyProfile }) | Select-Object -First 1
        if ($null -eq $profile -or @($profile.legacyEntryChanges | Where-Object { [string]$_.path -eq $changePath -and [string]$_.fragmentHash -eq [string]$change.fragmentHash }).Count -ne 1) { throw 'Legacy entry change is not trusted by catalogue' }
        $before = [Convert]::FromBase64String([string]$change.backup)
        if ((Get-Hash $before) -ne [string]$change.beforeHash) { throw 'Corrupt legacy entry original backup' }
        $resolvedChangePath = Resolve-ProjectFile $changePath
        if (-not (Test-Path -LiteralPath $resolvedChangePath -PathType Leaf)) { throw "Legacy entry change path missing: $changePath" }
    }
    if ($seen.Count -eq 0 -or $seen.Count -ne $allowedLayout.Count) { throw 'Manifest layout does not match this package' }
    return $state
}

function Save-State($State) {
    Write-Bytes $manifestPath ($utf8.GetBytes(($State | ConvertTo-Json -Depth 8)))
}

function Get-StateValue([object]$State, [string]$Name, [object]$Default = $null) {
    $property = $State.PSObject.Properties[$Name]
    if ($null -eq $property) { return $Default }
    return $property.Value
}

function Set-StateValue([object]$State, [string]$Name, [object]$Value) {
    $property = $State.PSObject.Properties[$Name]
    if ($null -eq $property) { $State | Add-Member -MemberType NoteProperty -Name $Name -Value $Value }
    else { $property.Value = $Value }
}

function Assert-Installed($State, [switch]$AllowMissingNew) {
    foreach ($record in @($State.files)) {
        $path = Resolve-ProjectFile $record.path
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            if ($AllowMissingNew -and $record.kind -eq 'project-document') { continue }
            if ($AllowMissingNew -and -not $record.preexisting -and $record.kind -eq 'file') { continue }
            throw "Installed file missing: $($record.path)"
        }
        if ($record.kind -eq 'project-document') { continue }
        if ($record.kind -eq 'file') {
            if ([string](Get-StateValue $record 'adoption' '') -eq 'project-document') {
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Project document missing: $($record.path)" }
                continue
            }
            if ((Get-Hash ([IO.File]::ReadAllBytes($path))) -ne $record.hash) {
                throw "Modified installed file: $($record.path)"
            }
        }
        else {
            $text = Read-Text $path
            if ([regex]::Matches($text, [regex]::Escape($begin)).Count -ne 1 -or
                [regex]::Matches($text, [regex]::Escape($end)).Count -ne 1 -or
                -not $text.Contains($record.insertion)) { throw "Managed block drifted: $($record.path)" }
        }
    }
}

function Get-Newline([string]$Text) {
    if ($Text.Contains([char]13 + [char]10)) { return [char]13 + [char]10 }
    return [char]10
}

function Get-ManagedInsertion([string]$Kind, [string]$Text, [string]$Mode, [string]$ExistingInsertion = '') {
    $newline = Get-Newline $Text
    $prefix = ''
    if ($ExistingInsertion -and ($ExistingInsertion.StartsWith([char]13 + [char]10) -or $ExistingInsertion.StartsWith([char]10))) {
        $prefix = $newline
    } elseif ($Text.Length -gt 0 -and -not $Text.EndsWith([char]10)) {
        $prefix = $newline
    }
    if ($Kind -eq 'agents') {
        $rulesRelative = if ($script:resolvedProfile -eq 'lite') { 'payload/docs/ai-collaboration/lite/agent-rules.md' } else { 'agent-rules.md' }
        $canonical = (Read-FileInfo (Join-Path $packageRoot $rulesRelative)).Text.TrimEnd([char]13, [char]10) -replace '\r?\n', $newline
        $body = '## ai-collaboration Workflow policy' + $newline +
            '- WorkflowMode: ' + $Mode + $newline +
            '- WorkflowProfile: ' + $script:resolvedProfile + $newline +
            '- Package version: ' + [string]((Get-Snapshot).packageVersion) + $newline +
            '- This declaration controls the project default; an explicit task choice takes precedence.' + $newline + $newline + $canonical
    } else {
        $body = '.ai/' + $newline + '.ai-collaboration-install/'
    }
    return $prefix + $begin + $newline + $body + $newline + $end + $newline
}

function Get-ManagedReplacement([object]$Record, [string]$Path, [string]$Mode) {
    $info = Read-FileInfo $Path
    $index = $info.Text.IndexOf([string]$Record.insertion, [StringComparison]::Ordinal)
    if ($index -lt 0) { throw "Managed block drifted: $($Record.path)" }
    $newInsertion = Get-ManagedInsertion $Record.kind $info.Text $Mode ([string]$Record.insertion)
    $text = $info.Text.Substring(0, $index) + $newInsertion +
        $info.Text.Substring($index + $Record.insertion.Length)
    return [pscustomobject]@{ Bytes = (Encode-Text $text $info.Bom); Insertion = $newInsertion }
}

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) { throw 'ProjectRoot must be an existing directory' }
if ($ProjectRoot -eq [IO.Path]::GetPathRoot($ProjectRoot).TrimEnd('\', '/')) { throw 'A drive root is not a project' }
Assert-NoReparse $ProjectRoot
$separator = [IO.Path]::DirectorySeparatorChar
if ($ProjectRoot -eq $packageRoot -or $ProjectRoot.StartsWith($packageRoot + $separator, [StringComparison]::OrdinalIgnoreCase) -or
    $packageRoot.StartsWith($ProjectRoot + $separator, [StringComparison]::OrdinalIgnoreCase)) { throw 'Project/package overlap is not allowed' }
$state = Read-State
if ($null -eq $state -and $PSBoundParameters.ContainsKey('WorkflowProfile')) { $script:resolvedProfile = $WorkflowProfile }
$reinstallInactive = $null -ne $state -and $state.phase -eq 'inactive' -and $Action -eq 'Install'
if ($reinstallInactive -and $PSBoundParameters.ContainsKey('WorkflowProfile')) { $script:resolvedProfile = $WorkflowProfile }
if ($null -ne $state -and -not $reinstallInactive -and $PSBoundParameters.ContainsKey('WorkflowProfile') -and $WorkflowProfile -cne $script:resolvedProfile) { throw 'WorkflowProfile conflict: preserve evidence, coordinate project entries, then use protected Uninstall/Install to switch; tasks are never migrated automatically' }
if ($null -ne $state) {
    $installedTarget = [string](Get-StateValue $state 'skillTarget' 'none')
    if (-not $reinstallInactive -and $PSBoundParameters.ContainsKey('SkillTarget') -and $SkillTarget -cne $installedTarget) { throw 'Uninstall before changing the Skill target' }
    if (-not $reinstallInactive -or -not $PSBoundParameters.ContainsKey('SkillTarget')) { $SkillTarget = $installedTarget }
}
if ($script:resolvedProfile -eq 'lite' -and $SkillTarget -ne 'none') { throw 'Lite supports SkillTarget none only; use explicit RULES.md reading' }
if ($Action -eq 'Adopt' -and $script:resolvedProfile -eq 'lite') { throw 'Private Lite adoption is unsupported; preserve its inputs and coordinate entries before a clean install' }
if ($Preview -and $Action -ne 'Adopt') { throw 'Preview is supported only for Adopt; no files written' }

if ($Action -eq 'CheckVersion') {
    $snapshot = Assert-PackageIntegrity
    Write-Output ('WorkflowProfile=' + $script:resolvedProfile)
    $available = [string]$snapshot.packageVersion
    if ($null -eq $state) {
        Write-Output "Available packageVersion=$available; installed=not-installed; upgrade=install"
        return
    }
    if ($state.phase -eq 'inactive') {
        $inactiveVersion = Get-StateValue $state 'packageVersion' 'unknown'
        Write-Output "Available packageVersion=$available; installed=$inactiveVersion; state=inactive; upgrade=install"
        return
    }
    if ($state.phase -eq 'installed') { Assert-Installed $state }
    $installedVersion = Get-StateValue $state 'packageVersion'
    $installed = if ($null -eq $installedVersion -or [string]::IsNullOrWhiteSpace([string]$installedVersion)) { 'unknown' } else { [string]$installedVersion }
    $modeValue = Get-StateValue $state 'workflowMode'
    $mode = if ($null -eq $modeValue) { 'default (legacy)' } else { [string]$modeValue }
    if ($installed -eq 'unknown') {
        try { $null = Get-UpgradePlan $state }
        catch {
            Write-Output "Available packageVersion=$available; installed=unknown; workflowMode=$mode; upgrade=not-possible ($($_.Exception.Message))"
            return
        }
        Write-Output "Available packageVersion=$available; installed=unknown; workflowMode=$mode; upgrade=allowed (same layout only)"
        return
    }
    $cmp = Compare-Version $available $installed
    if ($cmp -lt 0) { throw "Refusing implicit downgrade: installed $installed is newer than package $available" }
    if ($cmp -eq 0 -and ([string](Get-StateValue $state 'deploymentFingerprint') -ne (Get-DeploymentFingerprint $snapshot))) {
        throw 'Same packageVersion has a different deployment fingerprint; use the matching package'
    }
    if ($cmp -gt 0) {
        try { $null = Get-UpgradePlan $state }
        catch {
            Write-Output "Available packageVersion=$available; installed=$installed; workflowMode=$mode; upgrade=not-possible ($($_.Exception.Message))"
            return
        }
    }
    $upgrade = if ($cmp -gt 0) { 'available' } else { 'current' }
    Write-Output "Available packageVersion=$available; installed=$installed; workflowMode=$mode; upgrade=$upgrade"
    return
}

if ($Action -in @('Install', 'Adopt', 'Upgrade', 'SetMode')) {
    $snapshot = Assert-PackageIntegrity
    $packageVersion = [string]$snapshot.packageVersion
    $deploymentFingerprint = Get-DeploymentFingerprint $snapshot
    $snapshotFingerprint = Get-Hash ([IO.File]::ReadAllBytes($snapshotPath))
}

if ($Action -eq 'Status') {
    Write-Output ('WorkflowProfile=' + $script:resolvedProfile)
    if ($null -eq $state) { Write-Output 'Not installed' }
    elseif ($state.phase -eq 'inactive') {
        $inactiveValue = Get-StateValue $state 'packageVersion'
        $inactiveVersion = if ($null -eq $inactiveValue) { 'unknown' } else { [string]$inactiveValue }
        Write-Output "Inactive (packageVersion=$inactiveVersion)"
    }
    else {
        Assert-Installed $state
        $versionValue = Get-StateValue $state 'packageVersion'
        $version = if ($null -eq $versionValue) { 'unknown' } else { [string]$versionValue }
        $modeValue = Get-StateValue $state 'workflowMode'
        $mode = if ($null -eq $modeValue) { 'default (legacy)' } else { [string]$modeValue }
        Write-Output "Installed (managed files checked); packageVersion=$version; workflowMode=$mode; Skill target=$([string](Get-StateValue $state 'skillTarget' 'none'))"
    }
    return
}

if ($Action -eq 'Install') {
    if ($null -ne $state -and $state.phase -eq 'installed') {
        Assert-Installed $state
        if ($PSBoundParameters.ContainsKey('SkillTarget') -and $SkillTarget -ne $state.skillTarget) {
            throw 'Uninstall before changing the Skill target'
        }
        Write-Output 'Already installed (no writes)'
        return
    }
    $records = New-Object 'Collections.Generic.List[object]'
    $plannedBytes = @{}
    if ($null -eq $state -or $script:resolvedProfile -eq 'lite') {
        $liteDirectory = Join-Path $ProjectRoot 'docs/engrelay-lite'
        if (($null -eq $state -or [string](Get-StateValue $state 'workflowProfile' 'full') -ne 'lite') -and (Test-Path -LiteralPath $liteDirectory)) { throw 'Unmanaged Lite directory: preserve inputs and coordinate the old entry before a clean install' }
        $entryPath = Resolve-ProjectFile 'AGENTS.md'
        if ($null -eq $state -and (Test-Path -LiteralPath $entryPath -PathType Leaf) -and (Read-Text $entryPath) -match '(?i)EngRelay-Lite|engrelay-lite/|engrelay-lite\.config|\.ai/engrelay-lite') { throw 'Unmanaged Lite entry: preserve and coordinate project-owned instructions before installing' }
    }
    foreach ($item in Get-Plan $SkillTarget) {
        $path = Resolve-ProjectFile $item.path
        Assert-NoFileAncestor $path
        $existed = Test-Path -LiteralPath $path -PathType Leaf
        [byte[]]$before = @()
        if ($existed) { $before = [IO.File]::ReadAllBytes($path) }
        $insertion = $null
        if ($item.kind -eq 'project-document') {
            $after = if ($existed) { $before } else { [IO.File]::ReadAllBytes($item.source) }
            if (-not $existed) { $plannedBytes[$item.path] = $after }
            $records.Add([pscustomobject]@{path=$item.path;kind='project-document';hash=(Get-Hash $after);preexisting=[bool]$existed})
            continue
        }
        if ($item.kind -eq 'file') {
            [byte[]]$after = [IO.File]::ReadAllBytes($item.source)
            if ($existed -and (Get-Hash $before) -ne (Get-Hash $after)) { throw "Refusing differing existing file: $($item.path)" }
        }
        else {
            $info = if ($existed) { Read-FileInfo $path } else { [pscustomobject]@{ Text = ''; Bom = $false } }
            $text = $info.Text
            if ($text.Contains($begin) -or $text.Contains($end)) { throw "Unmanaged or partial markers: $($item.path)" }
            if ($item.kind -eq 'agents' -and $text -match '(?im)^##\s+Multi-Agent Collaboration Standard\s*$') {
                throw 'Unmanaged legacy rules detected; follow README legacy migration before installing'
            }
            $insertion = Get-ManagedInsertion $item.kind $text $WorkflowMode
            [byte[]]$after = Encode-Text ($text + $insertion) $info.Bom
        }
        $plannedBytes[$item.path] = $after
        $records.Add([pscustomobject]@{
            path = $item.path; kind = $item.kind; hash = (Get-Hash $after); preexisting = [bool]$existed
            beforeHash = (Get-Hash $before); backup = [Convert]::ToBase64String($before); insertion = $insertion
        })
    }
    # Persist recovery bytes before touching project-owned content. An interrupted
    # run is refused on the next invocation rather than silently claimed complete.
    if ($null -ne $state) {
        $history = Join-Path $stateRoot ('manifest-inactive-' + [guid]::NewGuid().ToString('N') + '.json')
        Write-Bytes $history ([IO.File]::ReadAllBytes($manifestPath))
    }
    $state = [pscustomobject]@{ version = 2; workflowProfile = $script:resolvedProfile; deploymentSet = @(Get-DeploymentSet $snapshot $SkillTarget); projectRoot = $ProjectRoot; packageVersion = $packageVersion
        packageSource = $packageRoot; snapshotFingerprint = $snapshotFingerprint
        deploymentFingerprint = $deploymentFingerprint; workflowMode = $WorkflowMode
        skillTarget = $SkillTarget; phase = 'installing'; files = $records.ToArray() }
    Save-State $state
    foreach ($record in $state.files) {
        if ($record.kind -eq 'project-document' -and $record.preexisting) { continue }
        if ($record.kind -eq 'file' -and $record.preexisting) { continue }
        Write-Bytes (Resolve-ProjectFile $record.path) $plannedBytes[$record.path]
    }
    $state.phase = 'installed'
    Save-State $state
    Write-Output ('Installed: ' + $state.files.Count + ' tracked files; Skill target ' + $SkillTarget + '; WorkflowMode ' + $WorkflowMode)
    Write-InstallDiscoveryGuidance $SkillTarget
    return
}

if ($Action -eq 'Adopt') {
    if ($null -ne $state) { throw 'Cannot adopt a project with an existing installation manifest; use Upgrade or reconcile the retained state' }
    $profile = Get-LegacyProfile
    Assert-NoRetiredResidualActivation $profile
    $canonical = @{}
    foreach ($item in @($profile.canonical)) { $canonical[[string]$item.path] = [string]$item.hash }
    $legacyEntries = @{}
    foreach ($item in @($profile.legacyEntries)) { $legacyEntries[[string]$item.path] = [string]$item.hash }
    $plan = @(Get-Plan $SkillTarget)
    $records = New-Object 'Collections.Generic.List[object]'
    $legacyChanges = New-Object 'Collections.Generic.List[object]'
    $plannedBytes = @{}
    foreach ($item in $plan) {
        $relative = [string]$item.path
        $path = Resolve-ProjectFile $relative
        $existed = Test-Path -LiteralPath $path -PathType Leaf
        [byte[]]$before = @()
        if ($existed) { [byte[]]$before = [IO.File]::ReadAllBytes($path) }
        $adoption = $null
        $insertion = $null
        if ($relative -in @('docs/reviews/README.md','docs/solutions/README.md') -and $existed) {
            $after = $before; $adoption = 'project-document'
        } elseif ($item.kind -eq 'agents' -and $existed) {
            $text = Read-Text $path
            if ($legacyEntries.ContainsKey($relative)) {
                $entry = @($profile.legacyEntries | Where-Object { [string]$_.path -eq $relative })[0]
                $replacement = Get-LegacyEntryReplacement $path $text $WorkflowMode ([string]$entry.fragmentHash)
                $after = $replacement.Bytes; $insertion = $replacement.Insertion; $adoption = 'legacy-entry'
            } else {
                if ($text.Contains($begin) -or $text.Contains($end) -or
                    $text -match '(?im)^##\s+Multi-Agent Collaboration Standard\s*$') {
                    throw "Residual legacy or partial managed markers: $relative"
                }
                $insertion = Get-ManagedInsertion 'agents' $text $WorkflowMode
                [byte[]]$after = Encode-Text ($text + $insertion) (Read-FileInfo $path).Bom
            }
        } elseif ($item.kind -eq 'file' -and $existed) {
            if (-not $canonical.ContainsKey($relative) -or -not (Test-CatalogueHash $path $canonical[$relative])) { throw "Known legacy file does not match catalogue: $relative" }
            [byte[]]$after = [IO.File]::ReadAllBytes($item.source); $adoption = 'canonical-legacy'
        } elseif ($item.kind -eq 'file') {
            [byte[]]$after = [IO.File]::ReadAllBytes($item.source)
        } else {
            $info = if ($existed) { Read-FileInfo $path } else { [pscustomobject]@{ Text = ''; Bom = $false } }
            if ($info.Text.Contains($begin) -or $info.Text.Contains($end)) { throw "Unmanaged or partial markers: $relative" }
            $insertion = Get-ManagedInsertion $item.kind $info.Text $WorkflowMode
            [byte[]]$after = Encode-Text ($info.Text + $insertion) $info.Bom
        }
        $plannedBytes[$relative] = $after
        $records.Add([pscustomobject]@{ path=$relative; kind=[string]$item.kind; hash=(Get-Hash $after); preexisting=[bool]$existed
            beforeHash=(Get-Hash $before); backup=[Convert]::ToBase64String($before); insertion=$insertion; adoption=$adoption; legacyProfile=[string]$profile.id })
    }
    foreach ($entry in @($profile.legacyEntryChanges)) {
        $relative = [string]$entry.path; $path = Resolve-ProjectFile $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Known legacy host entry is missing: $relative" }
        $before = [IO.File]::ReadAllBytes($path)
        $whole = @($profile.legacyEntries | Where-Object { [string]$_.path -eq $relative })[0]
        if ($null -eq $whole) { throw "Known legacy host entry is not registered in catalogue: $relative" }
        $replacement = Get-LegacyFragmentReplacement $path (Read-Text $path) $entry
        $plannedBytes[$relative] = $replacement.Bytes
        $legacyChanges.Add([pscustomobject]@{ path=$relative; kind='legacy-entry'; beforeHash=$replacement.BeforeHash; backup=[Convert]::ToBase64String($before); fragmentHash=$replacement.FragmentHash; hash=(Get-Hash $replacement.Bytes); legacyProfile=[string]$profile.id })
    }
    if ($Preview) {
        Write-Output "Adoption preview: profile=$($profile.id); tracked=$($records.Count); legacyEntryChanges=$($legacyChanges.Count); writes=$(@($plannedBytes.Keys).Count); no files written"
        return
    }
    $state = [pscustomobject]@{ version=2; workflowProfile=$script:resolvedProfile; deploymentSet=@(Get-DeploymentSet $snapshot $SkillTarget); projectRoot=$ProjectRoot; packageVersion=$packageVersion; packageSource=$packageRoot
        snapshotFingerprint=$snapshotFingerprint; deploymentFingerprint=$deploymentFingerprint; workflowMode=$WorkflowMode; skillTarget=$SkillTarget
        phase='adopting'; adoptionProfile=[string]$profile.id; legacyEntryChanges=$legacyChanges.ToArray(); files=$records.ToArray() }
    Save-State $state
    foreach ($record in @($state.files)) {
        if ($record.adoption -eq 'project-document') { continue }
        Write-Bytes (Resolve-ProjectFile $record.path) $plannedBytes[$record.path]
    }
    foreach ($change in @($state.legacyEntryChanges)) { Write-Bytes (Resolve-ProjectFile $change.path) $plannedBytes[$change.path] }
    $state.phase = 'installed'
    Save-State $state
    Write-Output "Adopted legacy profile=$($profile.id); tracked files=$($state.files.Count); WorkflowMode=$WorkflowMode"
    return
}

if ($null -eq $state) { Write-Output 'Not installed by this package; use README legacy migration'; return }
if ($Action -eq 'SetMode') {
    if ($state.phase -eq 'inactive') { throw 'Cannot change mode on an inactive installation; install again' }
    Assert-Installed $state
    $planned = @{}
    foreach ($record in @($state.files)) {
        if ($record.kind -eq 'agents') {
            $path = Resolve-ProjectFile $record.path
            $info = Read-FileInfo $path
            $index = $info.Text.IndexOf([string]$record.insertion, [StringComparison]::Ordinal)
            if ($index -lt 0 -or [string]$record.insertion -notmatch '(?m)^- WorkflowMode: (optional|default|disabled)\r?$') {
                throw 'SetMode requires an installed 1.1.0 managed policy; run Upgrade first'
            }
            $updatedInsertion = [regex]::Replace([string]$record.insertion,
                '(?m)^(- WorkflowMode: )(optional|default|disabled)(\r?)$',
                { param($m) $m.Groups[1].Value + $WorkflowMode + $m.Groups[3].Value })
            $replacement = [pscustomobject]@{
                Bytes = Encode-Text ($info.Text.Substring(0, $index) + $updatedInsertion +
                    $info.Text.Substring($index + $record.insertion.Length)) $info.Bom
                Insertion = $updatedInsertion
            }
            $planned[$record.path] = $replacement
            $record.insertion = $replacement.Insertion
            $record.hash = Get-Hash $replacement.Bytes
        }
    }
    foreach ($record in @($state.files)) {
        if ($planned.ContainsKey($record.path)) { Write-Bytes (Resolve-ProjectFile $record.path) $planned[$record.path].Bytes }
    }
    Set-StateValue $state 'workflowMode' $WorkflowMode
    Save-State $state
    Write-Output "WorkflowMode set to $WorkflowMode; managed block and manifest refreshed"
    return
}
if ($Action -eq 'Upgrade') {
    if ($state.phase -eq 'inactive') { throw 'Cannot upgrade an inactive installation; install again' }
    $oldVersionValue = Get-StateValue $state 'packageVersion'
    $oldVersion = if ($null -eq $oldVersionValue -or [string]::IsNullOrWhiteSpace([string]$oldVersionValue)) { 'unknown' } else { [string]$oldVersionValue }
    if ($oldVersion -ne 'unknown') {
        $cmp = Compare-Version $packageVersion $oldVersion
        if ($cmp -lt 0) { throw "Refusing implicit downgrade: installed $oldVersion is newer than package $packageVersion" }
        if ($cmp -eq 0 -and [string](Get-StateValue $state 'deploymentFingerprint') -ne $deploymentFingerprint) { throw 'Same packageVersion has a different deployment fingerprint; use the matching package' }
    }
    Assert-Installed $state
    # Complete read-only preflight first: no target, metadata or recovery write happens before this succeeds.
    $plan = Get-UpgradePlan $state
    Write-Bytes (Join-Path $stateRoot ('manifest-upgrade-' + [guid]::NewGuid().ToString('N') + '.json')) ([IO.File]::ReadAllBytes($manifestPath))
    $recovery = [pscustomobject]@{ packageVersion = $packageVersion; files = @($plan.Recovery); created = @($plan.Created); retired = @($plan.Retired) }
    Write-Bytes (Join-Path $stateRoot ('upgrade-files-' + [guid]::NewGuid().ToString('N') + '.json')) ($utf8.GetBytes(($recovery | ConvertTo-Json -Depth 8)))
    $state.phase = 'upgrading'
    if ($state.version -eq 1) { Set-StateValue $state 'legacyDeploymentFingerprint' $state.deploymentFingerprint }
    Save-State $state
    foreach ($relative in $plan.Planned.Keys) { Write-Bytes (Resolve-ProjectFile $relative) $plan.Planned[$relative] }
    foreach ($path in @($plan.Deletes)) { Assert-NoReparse $path; Remove-Item -LiteralPath $path -Force }
    Set-StateValue $state 'packageVersion' $packageVersion
    Set-StateValue $state 'version' 2
    Set-StateValue $state 'workflowProfile' $script:resolvedProfile
    Set-StateValue $state 'deploymentSet' @(Get-DeploymentSet $snapshot $SkillTarget)
    Set-StateValue $state 'packageSource' $packageRoot
    Set-StateValue $state 'snapshotFingerprint' $snapshotFingerprint
    Set-StateValue $state 'deploymentFingerprint' $deploymentFingerprint
    Set-StateValue $state 'workflowMode' ([string](Get-StateValue $state 'workflowMode' 'default')).ToLowerInvariant()
    Set-StateValue $state 'files' @($plan.Records)
    Set-StateValue $state 'phase' 'installed'
    Save-State $state
    Write-Output "Upgraded to packageVersion=$packageVersion; managed files and manifest refreshed; added=$(@($plan.Created).Count); retired=$(@($plan.Retired).Count)"
    return
}
if ($state.phase -eq 'inactive') { Write-Output 'Already inactive (no writes)'; return }
Assert-Installed $state -AllowMissingNew
$state.phase = 'uninstalling'
Save-State $state
foreach ($record in $state.files) {
    $path = Resolve-ProjectFile $record.path
    if ($record.kind -eq 'project-document') { continue }
    if ($record.kind -eq 'file') {
        if ([string](Get-StateValue $record 'adoption' '') -eq 'project-document') { continue }
        if ([string](Get-StateValue $record 'adoption' '') -eq 'canonical-legacy') {
            if ((Get-Hash ([IO.File]::ReadAllBytes($path))) -ne [string]$record.hash) { throw "Adopted file drifted: $($record.path)" }
            Write-Bytes $path ([Convert]::FromBase64String([string]$record.backup))
            continue
        }
        if (-not $record.preexisting -and (Test-Path -LiteralPath $path -PathType Leaf)) {
            Remove-Item -LiteralPath $path -Force
        }
    }
    else {
        $info = Read-FileInfo $path
        $text = $info.Text
        $index = $text.IndexOf($record.insertion, [StringComparison]::Ordinal)
        $before = $text.Substring(0, $index)
        $after = $text.Substring($index + $record.insertion.Length)
        $separator = ''
        # The insertion owns its leading newline only while no later suffix needs it.
        # Restore original bytes without a suffix; never restore over outside edits.
        if ($before.Length -gt 0 -and $after.Length -gt 0 -and
            -not $before.EndsWith("`n") -and -not $after.StartsWith("`n") -and
            -not $after.StartsWith("`r`n")) {
            $separator = "`n"
            if ($record.insertion.StartsWith("`r`n")) { $separator = "`r`n" }
        }
        $remainder = $before + $separator + $after
        if (-not $record.preexisting -and $remainder.Length -eq 0) { Remove-Item -LiteralPath $path -Force }
        else { Write-Bytes $path (Encode-Text $remainder $info.Bom) }
    }
}
if ($script:resolvedProfile -eq 'lite') {
    # Only consider parents of non-preexisting Lite package files. Never recurse
    # into unknown directories or remove a directory containing any entry.
    $liteRoot = Join-Path $ProjectRoot 'docs/engrelay-lite'
    $liteDirectories = @{}
    foreach ($record in $state.files) {
        if ($record.kind -ne 'file' -or $record.preexisting -or -not $record.path.StartsWith('docs/engrelay-lite/', [StringComparison]::Ordinal)) { continue }
        $parent = Split-Path -Parent (Resolve-ProjectFile $record.path)
        while ($parent -eq $liteRoot -or $parent.StartsWith($liteRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            $liteDirectories[$parent] = $true
            $parent = Split-Path -Parent $parent
        }
    }
    foreach ($directory in @($liteDirectories.Keys | Sort-Object Length -Descending)) {
        Assert-NoReparse $directory
        if ((Test-Path -LiteralPath $directory -PathType Container) -and @(Get-ChildItem -LiteralPath $directory -Force).Count -eq 0) {
            Remove-Item -LiteralPath $directory -Force
        }
    }
}
$state.phase = 'inactive'
Save-State $state
Write-Output 'Uninstalled; recovery metadata retained; histories and runtime untouched'
