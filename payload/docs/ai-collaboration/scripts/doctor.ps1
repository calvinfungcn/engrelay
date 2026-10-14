[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
    [string]$PackageRoot = '',
    [Alias('Host')][string]$HostTarget = ''
)
# Read-only ai-collaboration diagnosis. It writes no file, starts no host or installer,
# makes no network request and does not select a controller. Each category is reported
# separately: source integrity, installation ownership, activation entry, selected host and
# actual host loading. Exit 0 means no demonstrated required failure; warn/skip/unknown are advisory.
# Exit 1 means a required check failed or a requested input was unsafe, malformed or unreadable.
# A path whose chain contains a reparse point is reported and never followed or read.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$begin = '<!-- ai-collaboration:begin -->'
$end = '<!-- ai-collaboration:end -->'
$skillNames = @('ce-code-review', 'ce-debug', 'ce-simplify-code', 'ce-compound', 'ai-collab-requirements', 'ai-collab-start', 'ai-collab-continue')
# Entry Skills first appear in package 1.6.0. Older installed layouts do not own them yet.
$entrySkillNames = @('ai-collab-requirements', 'ai-collab-start', 'ai-collab-continue')
# Classifies by the installed manifest's recorded packageVersion, not by whether a matching package was supplied.
function Test-PredatesEntrySkills([string]$InstalledVersion) {
    if ($InstalledVersion -notmatch '^\d+\.\d+\.\d+$') { return $false }
    return ([version]$InstalledVersion) -lt [version]'1.6.0'
}
$modes = @('optional', 'default', 'disabled')
$script:rows = New-Object 'Collections.Generic.List[object]'
$script:requiredInputFailed = $false
$script:snapshot = $null

function Add-Row([string]$Category, [string]$Status, [string]$Message, [string]$Path = '', [string]$Advice = '') {
    $script:rows.Add([pscustomobject]@{ Category = $Category; Status = $Status; Message = $Message; Path = $Path; Advice = $Advice })
}

function Get-Prop([object]$Object, [string]$Name, [object]$Default = $null) {
    if ($null -eq $Object) { return $Default }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $Default }
    return $property.Value
}

function Get-Hash([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Read-Utf8([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 2 -and (($bytes[0] -eq 255 -and $bytes[1] -eq 254) -or ($bytes[0] -eq 254 -and $bytes[1] -eq 255))) {
        throw 'UTF-16 is unsupported'
    }
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) { $offset = 3 }
    return $utf8.GetString($bytes, $offset, $bytes.Length - $offset)
}

function Test-SafeRelativePath([string]$Relative) {
    return (-not [string]::IsNullOrWhiteSpace($Relative)) -and $Relative -notmatch '[:\\]' -and
        -not $Relative.StartsWith('/') -and $Relative -notmatch '(^|/)\.\.?(/|$)'
}

# Any reparse point on the path chain (the path itself or an ancestor up to the drive root) is unsafe.
function Test-ReparseChain([string]$Path) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { return $true }
        }
        $parent = Split-Path -Parent $cursor
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $cursor) { break }
        $cursor = $parent
    }
    return $false
}

function Get-HostTable([string]$ScriptDirectory) {
    # The nine targets come from the deployed compound-skills.manifest.json, the same data the
    # manager reads. Each destination must be a plain skills directory below a dot-root.
    $path = Join-Path $ScriptDirectory '..\compound-skills.manifest.json'
    if (Test-ReparseChain $path) { throw 'compound-skills.manifest.json path contains a reparse point' }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'compound-skills.manifest.json is missing' }
    $manifest = (Read-Utf8 $path) | ConvertFrom-Json
    $table = @{}
    foreach ($property in $manifest.targets.PSObject.Properties) {
        $directory = [string]$property.Value
        if ($directory -notmatch '^\.[A-Za-z0-9_-]+/skills$') { throw "target directory is not a supported skills path: $($property.Name)" }
        $table[[string]$property.Name] = $directory
    }
    return $table
}

function Test-AllowedRecord([string]$Relative, [string]$Kind, [string]$TargetDirectory) {
    # A conservative prefix check of manifest-declared paths. It does not trust the manifest:
    # the record is only read after this check and the reparse check. Exact layout validation
    # is owned by manage.ps1, which knows the supported layout registry.
    if (-not (Test-SafeRelativePath $Relative)) { return $false }
    if ($Relative -eq 'AGENTS.md') { return $Kind -eq 'agents' }
    if ($Relative -eq '.gitignore') { return $Kind -eq 'gitignore' }
    if ($Kind -ne 'file') { return $false }
    if ($Relative -match '^docs/ai-collaboration/') { return $true }
    if ($Relative -in @('docs/reviews/README.md', 'docs/solutions/README.md', 'docs/solutions/solution.template.md')) { return $true }
    if (-not [string]::IsNullOrEmpty($TargetDirectory) -and
        $Relative -match ('^' + [regex]::Escape($TargetDirectory) + '/(ce-code-review|ce-debug|ce-simplify-code|ce-compound|ai-collab-requirements|ai-collab-start|ai-collab-continue)/.+$')) { return $true }
    return $false
}

function Get-DisplayPath([string]$Value) {
    $text = [string]$Value
    if ($text.Length -gt 200) { return $text.Substring(0, 200) + '...' }
    return $text
}

# Snapshot schema: the inventory must be a well-formed package description before any byte comparison.
function Get-SnapshotProblems([object]$Snapshot) {
    $list = New-Object 'Collections.Generic.List[string]'
    if ($Snapshot -isnot [pscustomobject]) { $list.Add('top-level value is not an object'); return $list.ToArray() }
    if ((Get-Prop $Snapshot 'schemaVersion') -ne 1) { $list.Add('schemaVersion must be 1') }
    $version = Get-Prop $Snapshot 'packageVersion'
    if ($version -isnot [string] -or $version -notmatch '^\d+\.\d+\.\d+$') { $list.Add('packageVersion must be a semantic version string') }
    $files = Get-Prop $Snapshot 'files'
    if ($files -isnot [array] -or @($files).Count -eq 0) { $list.Add('files must be a non-empty array'); return $list.ToArray() }
    $seen = @{}
    foreach ($entry in @($files)) {
        if ($entry -isnot [pscustomobject]) { $list.Add('inventory entry is not an object'); continue }
        $path = Get-Prop $entry 'path'
        if ($path -isnot [string] -or -not (Test-SafeRelativePath $path) -or $path -eq 'snapshot.json') {
            $list.Add("inventory path is unsafe or invalid: $(Get-DisplayPath ([string]$path))"); continue
        }
        if ($seen.ContainsKey($path)) { $list.Add("duplicate inventory path: $path"); continue }
        $seen[$path] = $true
        $bytes = Get-Prop $entry 'bytes'
        if (($bytes -isnot [int] -and $bytes -isnot [long]) -or $bytes -lt 0) { $list.Add("inventory byte count is invalid: $path") }
        $sha = Get-Prop $entry 'sha256'
        if ($sha -isnot [string] -or $sha -notmatch '^[a-fA-F0-9]{64}$') { $list.Add("inventory sha256 is invalid: $path") }
    }
    return $list.ToArray()
}

# Walks the package without following any reparse point. Returns regular file paths and records
# every redirecting entry as a problem; .git, .ai and the root snapshot.json are not inventory.
function Get-PackageEntries([string]$Root, [Collections.Generic.List[string]]$Problems) {
    $files = New-Object 'Collections.Generic.List[string]'
    $pending = New-Object 'Collections.Generic.Stack[string]'
    $pending.Push($Root)
    while ($pending.Count -gt 0) {
        $directory = $pending.Pop()
        foreach ($item in @(Get-ChildItem -LiteralPath $directory -Force)) {
            $relative = $item.FullName.Substring($Root.Length + 1).Replace('\', '/')
            if ($directory -eq $Root -and $item.Name -eq 'snapshot.json') { continue }
            if ($relative -match '(^|/)(\.git|\.ai)(/|$)') { continue }
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { $Problems.Add("reparse point in package, not followed: $relative"); continue }
            if ($item.PSIsContainer) { $pending.Push($item.FullName) } else { $files.Add($relative) }
        }
    }
    return $files.ToArray()
}

# Expected package-owned layout derived from a schema-valid inventory, mirroring the manager's
# base plan: payload/docs/... -> docs/..., agent-rules.md -> AGENTS.md, plus .gitignore and, for
# one selected SkillTarget, its copies of the seven canonical Skills.
function Get-ExpectedLayout([object]$Snapshot, [string]$Target, [string]$TargetDirectory) {
    $layout = @{ '.gitignore' = 'gitignore' }
    foreach ($entry in @(Get-Prop $Snapshot 'files' @())) {
        $relative = [string]$entry.path
        if ($relative -eq 'agent-rules.md') { $layout['AGENTS.md'] = 'agents' }
        elseif ($relative -like 'payload/*') { $layout[$relative.Substring(8)] = 'file' }
    }
    if ($Target -ne 'none') {
        foreach ($relative in @($layout.Keys)) {
            if ($relative -match '^docs/ai-collaboration/skills/(ce-code-review|ce-debug|ce-simplify-code|ce-compound|ai-collab-requirements|ai-collab-start|ai-collab-continue)/(.+)$') {
                $layout[$TargetDirectory + '/' + $Matches[1] + '/' + $Matches[2]] = 'file'
            }
        }
    }
    return $layout
}
# Input validation: a requested workspace that is unsafe or unreadable is a required failure.
$workspace = ''
try {
    if (-not [IO.Path]::IsPathRooted($WorkspaceRoot)) { throw 'WorkspaceRoot must be an absolute path' }
    $workspace = [IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\', '/')
    if (-not (Test-Path -LiteralPath $workspace -PathType Container)) { throw 'WorkspaceRoot is not an existing directory' }
    if (Test-ReparseChain $workspace) { throw 'WorkspaceRoot path contains a reparse point' }
}
catch {
    Add-Row 'input' 'fail' ('workspace not inspected: ' + $_.Exception.Message) $WorkspaceRoot 'Pass an absolute, existing project directory without reparse points.'
    $script:requiredInputFailed = $true
}

if ($script:requiredInputFailed) {
    Write-Output 'ai-collaboration doctor (read-only; no files written)'
    Add-Row 'summary' 'fail' 'stopped before inspection because the requested workspace is unusable'
}
else {
    # 1. Source integrity: only when a local package is named. Each category is isolated so one
    #    failure does not hide the facts from the other categories.
    if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
        Add-Row 'source' 'skip' 'no -PackageRoot given; source integrity was not evaluated'
    }
    else {
        try {
            $package = [IO.Path]::GetFullPath($PackageRoot).TrimEnd('\', '/')
            $snapshotPath = Join-Path $package 'snapshot.json'
            if (-not (Test-Path -LiteralPath $package -PathType Container)) {
                Add-Row 'source' 'fail' 'requested -PackageRoot is not a readable directory' $PackageRoot 'Pass the local package root that contains snapshot.json.'
                $script:requiredInputFailed = $true
            }
            elseif (Test-ReparseChain $package) {
                Add-Row 'source' 'fail' 'requested -PackageRoot path contains a reparse point; not followed' $package 'Use the real package directory, not a link or junction.'
                $script:requiredInputFailed = $true
            }
            elseif ((-not (Test-Path -LiteralPath $snapshotPath -PathType Leaf)) -or (Test-ReparseChain $snapshotPath)) {
                Add-Row 'source' 'fail' 'snapshot.json is missing or a reparse point; not followed' $snapshotPath 'Use a complete local package with a valid inventory; do not install from an unverified copy.'
                $script:requiredInputFailed = $true
            }
            else {
                $snapshot = $null
                $parsed = $true
                try { $snapshot = (Read-Utf8 $snapshotPath) | ConvertFrom-Json } catch { $parsed = $false }
                if (-not $parsed) {
                    Add-Row 'source' 'fail' 'snapshot.json is unreadable or not valid JSON' $snapshotPath 'Use a complete local package with a valid inventory; do not install from an unverified copy.'
                    $script:requiredInputFailed = $true
                }
                else {
                    $schemaProblems = @(Get-SnapshotProblems $snapshot)
                    if ($schemaProblems.Count -gt 0) {
                        Add-Row 'source' 'fail' ('snapshot.json has an invalid schema: ' + $schemaProblems[0]) $snapshotPath 'Use a complete local package with a valid inventory; do not install from an unverified copy.'
                        $script:requiredInputFailed = $true
                    }
                    else {
                        $script:snapshot = $snapshot
                        $problems = New-Object 'Collections.Generic.List[string]'
                        $listed = @{}
                        foreach ($entry in @($snapshot.files)) {
                            $relative = [string]$entry.path
                            $listed[$relative] = $true
                            $file = Join-Path $package $relative
                            if (Test-ReparseChain $file) { $problems.Add("reparse point, not followed: $relative"); continue }
                            if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { $problems.Add("missing package file: $relative"); continue }
                            try {
                                $bytes = [IO.File]::ReadAllBytes($file)
                                if ($bytes.Length -ne [int64]$entry.bytes -or (Get-Hash $bytes) -ne ([string]$entry.sha256).ToLowerInvariant()) {
                                    $problems.Add("package file differs from inventory: $relative")
                                }
                            }
                            catch { $problems.Add("package file unreadable: $relative ($($_.Exception.Message))") }
                        }
                        foreach ($path in @(Get-PackageEntries $package $problems)) {
                            if (-not $listed.ContainsKey($path)) { $problems.Add("unlisted package file: $path") }
                        }
                        if ($problems.Count -eq 0) {
                            Add-Row 'source' 'pass' ("package inventory matches snapshot.json; packageVersion=$([string]$snapshot.packageVersion); files=$($listed.Count)")
                        }
                        else {
                            $shown = @($problems | Select-Object -First 5)
                            Add-Row 'source' 'fail' ("package inventory differs from snapshot.json ($($problems.Count) problem(s); first: " + ($shown -join '; ') + ')') $package 'Use the matching frozen package or refresh the source inventory after reviewing the change. Do not install from this package.'
                            $script:requiredInputFailed = $true
                        }
                    }
                }
            }
        }
        catch {
            Add-Row 'source' 'fail' ('source category could not be completed: ' + $_.Exception.Message) $PackageRoot 'Preserve the package and retry with a readable local copy.'
            $script:requiredInputFailed = $true
        }
    }

    # 2. Installation ownership from the project's own manifest. Every record is validated and
    #    its owned file checked before it is read; the manifest is never trusted as a layout.
    $stateDirectory = Join-Path $workspace '.ai-collaboration-install'
    $manifestPath = Join-Path $stateDirectory 'manifest.json'
    $installed = $false
    $installedTarget = 'none'
    $targetDirectory = ''
    $manifestMode = ''
    try {
        if (Test-ReparseChain $stateDirectory) {
            Add-Row 'ownership' 'fail' 'installation state directory is a reparse point; not followed' $stateDirectory 'Keep it unchanged and reconcile manually; do not replace it with Force.'
            $script:requiredInputFailed = $true
        }
        elseif (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
            Add-Row 'ownership' 'skip' 'not installed: no installation manifest; no ownership files inspected and no file was created'
        }
        elseif (Test-ReparseChain $manifestPath) {
            Add-Row 'ownership' 'fail' 'installation manifest is a reparse point; not followed' $manifestPath 'Keep it unchanged and reconcile manually; do not replace it with Force.'
            $script:requiredInputFailed = $true
        }
        else {
            $state = $null
            $parseFailed = $false
            try { $state = (Read-Utf8 $manifestPath) | ConvertFrom-Json } catch { $parseFailed = $true }
            if ($parseFailed -or $null -eq $state -or $state -isnot [pscustomobject]) {
                Add-Row 'ownership' 'fail' 'installation manifest is unreadable or not valid JSON; ownership cannot be verified' $manifestPath 'Keep the manifest and every backup, do not use Force, and reconcile the project manually from the backups.'
                $script:requiredInputFailed = $true
            }
            else {
                $phase = [string](Get-Prop $state 'phase' 'unknown')
                $version = [string](Get-Prop $state 'packageVersion' 'unknown')
                $mode = [string](Get-Prop $state 'workflowMode' 'default (legacy)')
                $installedTarget = [string](Get-Prop $state 'skillTarget' 'none')
                if ($phase -eq 'inactive') {
                    Add-Row 'ownership' 'skip' "inactive installation (packageVersion=$version); package-owned files are not active; manifest retained"
                }
                elseif ($phase -ne 'installed') {
                    Add-Row 'ownership' 'fail' "installation is interrupted or in unknown phase '$phase' (packageVersion=$version); success is not claimed" $manifestPath 'Recovery evidence is retained in .ai-collaboration-install/ (manifest-*.json, upgrade-files-*.json). Reconcile manually before any management action.'
                    $script:requiredInputFailed = $true
                }
                else {
                    $installed = $true
                    $manifestMode = [string](Get-Prop $state 'workflowMode' '')
                    $problems = New-Object 'Collections.Generic.List[string]'
                    $verified = 0
                    $seen = @{}
                    if ([string](Get-Prop $state 'version' '') -ne '1') { $problems.Add('manifest version is not 1') }
                    if ([string](Get-Prop $state 'projectRoot' '') -ne $workspace) {
                        $problems.Add('manifest projectRoot differs from this workspace (moved or copied installation)')
                    }
                    $targetKnown = $true
                    if ($installedTarget -ne 'none') {
                        $table = $null
                        try { $table = Get-HostTable $PSScriptRoot } catch { $table = $null }
                        if ($null -eq $table -or -not $table.ContainsKey($installedTarget)) {
                            $targetKnown = $false
                            $problems.Add("manifest SkillTarget '$installedTarget' is not verified against the supported target table")
                        }
                        else { $targetDirectory = [string]$table[$installedTarget] }
                    }
                    $records = @()
                    $filesValue = Get-Prop $state 'files' $null
                    if ($filesValue -isnot [array] -or @($filesValue).Count -eq 0) { $problems.Add('manifest has no file records') }
                    else { $records = @($filesValue) }
                    if ($targetKnown) {
                        foreach ($record in $records) {
                            try {
                                $relative = [string](Get-Prop $record 'path' '')
                                $kind = [string](Get-Prop $record 'kind' '')
                                if (-not (Test-AllowedRecord $relative $kind $targetDirectory)) {
                                    $problems.Add("record outside package layout, not read: $(Get-DisplayPath $relative)")
                                    continue
                                }
                                if ($seen.ContainsKey($relative)) { $problems.Add("duplicate record: $relative"); continue }
                                $seen[$relative] = $kind
                                $preexisting = Get-Prop $record 'preexisting' $null
                                $hash = ([string](Get-Prop $record 'hash' '')).ToLowerInvariant()
                                if ($preexisting -isnot [bool] -or $hash -notmatch '^[a-f0-9]{64}$') {
                                    $problems.Add("record flags or hash are invalid: $relative")
                                    continue
                                }
                                $adoption = [string](Get-Prop $record 'adoption' '')
                                if ($adoption -ne '' -and $adoption -notin @('canonical-legacy','project-document','legacy-entry')) {
                                    $problems.Add("adoption value is invalid: $relative"); continue
                                }
                                if ($adoption -ne '') {
                                    if (-not [bool]$preexisting) { $problems.Add("adoption record is not preexisting: $relative"); continue }
                                    $cataloguePath = Join-Path $PSScriptRoot '..\legacy-adoption.json'
                                    try { $catalogue = (Read-Utf8 $cataloguePath) | ConvertFrom-Json } catch { $problems.Add('legacy adoption catalogue is unreadable'); continue }
                                    $profileName = [string](Get-Prop $record 'legacyProfile' '')
                                    $profile = @($catalogue.profiles | Where-Object { [string]$_.id -eq $profileName }) | Select-Object -First 1
                                    if ($null -eq $profile) { $problems.Add("adoption profile is not trusted: $relative"); continue }
                                    $knownCount = if ($adoption -eq 'canonical-legacy') { @($profile.canonical | Where-Object { [string]$_.path -eq $relative }).Count } elseif ($adoption -eq 'legacy-entry') { @($profile.legacyEntries | Where-Object { [string]$_.path -eq $relative }).Count } else { @($profile.projectDocuments | Where-Object { [string]$_ -eq $relative }).Count }
                                    if ([int]$knownCount -ne 1) { $problems.Add("adoption path is outside trusted profile: $relative"); continue }
                                    if (($adoption -eq 'legacy-entry' -and $kind -ne 'agents') -or ($adoption -in @('canonical-legacy','project-document') -and $kind -ne 'file')) { $problems.Add("adoption kind is invalid: $relative"); continue }
                                }
                                if ($preexisting) {
                                    $backup = $null
                                    try { $backup = [Convert]::FromBase64String([string](Get-Prop $record 'backup' '')) }
                                    catch { $problems.Add("original backup is not valid Base64: $relative"); continue }
                                    if ((Get-Hash $backup) -ne ([string](Get-Prop $record 'beforeHash' '')).ToLowerInvariant()) {
                                        $problems.Add("original backup does not match its beforeHash: $relative")
                                        continue
                                    }
                                }
                                $full = [IO.Path]::GetFullPath((Join-Path $workspace $relative))
                                if (-not $full.StartsWith($workspace + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
                                    $problems.Add("record escapes workspace, not read: $(Get-DisplayPath $relative)")
                                    continue
                                }
                                if (Test-ReparseChain $full) { $problems.Add("reparse point on owned path, not followed: $relative"); continue }
                                if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { $problems.Add("owned file missing: $relative"); continue }
                                if ($kind -eq 'file') {
                                    if ($adoption -eq 'project-document') {
                                        $verified++
                                    } elseif ((Get-Hash ([IO.File]::ReadAllBytes($full))) -ne $hash) {
                                        $problems.Add("owned file drifted from its ownership record: $relative")
                                    }
                                    else { $verified++ }
                                }
                                else {
                                    $text = Read-Utf8 $full
                                    $insertion = [string](Get-Prop $record 'insertion' '')
                                    if ([regex]::Matches($text, [regex]::Escape($begin)).Count -ne 1 -or
                                        [regex]::Matches($text, [regex]::Escape($end)).Count -ne 1 -or
                                        $insertion.Length -eq 0 -or -not $text.Contains($insertion)) {
                                        $problems.Add("managed block missing or drifted: $relative")
                                    }
                                    else { $verified++ }
                                }
                            }
                            catch {
                                $problems.Add("owned record could not be verified: $(Get-DisplayPath ([string](Get-Prop $record 'path' ''))) ($($_.Exception.Message))")
                            }
                        }
                    }
                    $seenLegacyChanges = @{}
                    foreach ($change in @(Get-Prop $state 'legacyEntryChanges' @())) {
                        $changePath = [string](Get-Prop $change 'path' '')
                        $changeHash = [string](Get-Prop $change 'hash' '')
                        $fragmentHash = [string](Get-Prop $change 'fragmentHash' '')
                        $beforeHash = [string](Get-Prop $change 'beforeHash' '')
                        $profileName = [string](Get-Prop $change 'legacyProfile' '')
                        $invalid = [string](Get-Prop $change 'kind' '') -ne 'legacy-entry' -or $changePath -notmatch '^(QWEN|IFLOW)\.md$' -or $seenLegacyChanges.ContainsKey($changePath) -or $profileName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$' -or $changeHash -notmatch '^[a-f0-9]{64}$' -or $fragmentHash -notmatch '^[a-f0-9]{64}$' -or $beforeHash -notmatch '^[a-f0-9]{64}$' -or [string]::IsNullOrWhiteSpace([string](Get-Prop $change 'backup' ''))
                        if ($invalid) { $problems.Add("legacy entry change record is invalid: $changePath"); continue }
                        $seenLegacyChanges[$changePath] = $true
                        $cataloguePath = Join-Path $PSScriptRoot '..\legacy-adoption.json'
                        try { $cat = (Read-Utf8 $cataloguePath) | ConvertFrom-Json } catch { $problems.Add('legacy adoption catalogue is unreadable'); continue }
                        $profile = @($cat.profiles | Where-Object { [string]$_.id -eq $profileName }) | Select-Object -First 1
                        if ($null -eq $profile -or @($profile.legacyEntryChanges | Where-Object { [string]$_.path -eq $changePath -and [string]$_.fragmentHash -eq [string](Get-Prop $change 'fragmentHash' '') }).Count -ne 1) { $problems.Add("legacy entry change is not trusted: $changePath"); continue }
                        try { $backup = [Convert]::FromBase64String([string](Get-Prop $change 'backup' '')); if ((Get-Hash $backup) -ne [string](Get-Prop $change 'beforeHash' '')) { $problems.Add("legacy entry backup hash mismatch: $changePath") } } catch { $problems.Add("legacy entry backup is invalid: $changePath") }
                    }
                    # Completeness: only a same-version package inventory can prove the full owned layout.
                    $completeness = 'unavailable'
                    $layoutNote = 'no -PackageRoot was supplied'
                    if (-not [string]::IsNullOrWhiteSpace($PackageRoot) -and $null -eq $script:snapshot) {
                        $layoutNote = 'the supplied -PackageRoot inventory did not pass schema validation'
                    }
                    elseif ($null -ne $script:snapshot) {
                        if ([string](Get-Prop $state 'packageVersion' '') -ne [string]$script:snapshot.packageVersion) {
                            $completeness = 'version-mismatch'
                            $layoutNote = "manifest packageVersion=$version differs from the supplied package $($script:snapshot.packageVersion)"
                        }
                        elseif ($targetKnown) {
                            $completeness = 'strict'
                            $expected = Get-ExpectedLayout $script:snapshot $installedTarget $targetDirectory
                            foreach ($path in @($expected.Keys | Sort-Object)) {
                                if (-not $seen.ContainsKey($path)) { $problems.Add("manifest omits package-owned path: $path") }
                                elseif ([string]$seen[$path] -ne [string]$expected[$path]) { $problems.Add("manifest kind differs from package layout: $path") }
                            }
                            foreach ($path in @($seen.Keys | Sort-Object)) {
                                if (-not $expected.ContainsKey($path)) { $problems.Add("manifest records a path outside the package layout: $path") }
                            }
                        }
                    }
                    if ($problems.Count -gt 0) {
                        $shown = @($problems | Select-Object -First 5)
                        Add-Row 'ownership' 'fail' ("$($problems.Count) ownership problem(s); first: " + ($shown -join '; ')) $manifestPath 'Compare the named file with the package copy and merge a bounded change; do not use Force or restore the whole project from the original backup.'
                        $script:requiredInputFailed = $true
                    }
                    elseif ($completeness -eq 'strict') {
                        Add-Row 'ownership' 'pass' "manifest verified: $verified owned record(s); layout matches this package; packageVersion=$version; workflowMode=$mode; SkillTarget=$installedTarget"
                    }
                    else {
                        Add-Row 'ownership' 'warn' "manifest records verified individually: $verified owned record(s); layout completeness not established ($layoutNote); packageVersion=$version; workflowMode=$mode; SkillTarget=$installedTarget" $manifestPath 'Run the doctor with -PackageRoot pointing at the matching local package to verify the complete layout.'
                    }
                }
            }
        }
    }
    catch {
        Add-Row 'ownership' 'fail' ('ownership category could not be completed: ' + $_.Exception.Message) $manifestPath 'Keep the manifest and every backup; reconcile manually.'
        $script:requiredInputFailed = $true
    }

    # 3. Activation entry: facts from AGENTS.md and the canonical handbook. No activation is inferred.
    #    Only the package managed block declares a mode; text outside the markers is project content.
    $agentsPath = Join-Path $workspace 'AGENTS.md'
    $declaredMode = ''
    try {
        if (Test-ReparseChain $agentsPath) {
            Add-Row 'entry' 'fail' 'AGENTS.md path contains a reparse point; not followed' $agentsPath 'Keep the link unchanged and reconcile manually.'
            $script:requiredInputFailed = $true
        }
        elseif (Test-Path -LiteralPath $agentsPath -PathType Container) {
            Add-Row 'entry' 'fail' 'AGENTS.md is a directory; the activation entry is not readable' $agentsPath 'Restore the file from a trusted copy or choose a different entry; do not replace the directory silently.'
            $script:requiredInputFailed = $true
        }
        elseif (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
            $agentsText = ''
            $agentsReadable = $true
            try { $agentsText = Read-Utf8 $agentsPath } catch { $agentsReadable = $false }
            if (-not $agentsReadable) {
                Add-Row 'entry' 'fail' 'AGENTS.md is not readable as UTF-8 text' $agentsPath 'Preserve the file and convert only with owner approval.'
                $script:requiredInputFailed = $true
            }
            else {
                $beginCount = [regex]::Matches($agentsText, [regex]::Escape($begin)).Count
                $endCount = [regex]::Matches($agentsText, [regex]::Escape($end)).Count
                $beginAt = $agentsText.IndexOf($begin, [StringComparison]::Ordinal)
                $endAt = $agentsText.IndexOf($end, [StringComparison]::Ordinal)
                if ($beginCount -eq 0 -and $endCount -eq 0) {
                    Add-Row 'entry' 'skip' 'AGENTS.md has no package managed block'
                }
                elseif ($beginCount -ne 1 -or $endCount -ne 1 -or $endAt -lt $beginAt) {
                    Add-Row 'entry' 'fail' 'AGENTS.md has partial, duplicated or misordered package markers' $agentsPath 'Keep the file; reconcile the markers manually before any management action.'
                    $script:requiredInputFailed = $true
                }
                else {
                    $block = $agentsText.Substring($beginAt, $endAt - $beginAt)
                    $match = [regex]::Match($block, '(?m)^- WorkflowMode: (optional|default|disabled)\r?$')
                    if ($match.Success) { $declaredMode = $match.Groups[1].Value }
                    if (-not $installed) {
                        Add-Row 'entry' 'warn' 'package managed block present without a verified ownership record' $agentsPath 'Treat it as legacy or manual content; use the bounded manual route in project-adoption.md.'
                    }
                    elseif ($declaredMode -eq '') {
                        Add-Row 'entry' 'warn' 'managed block has no WorkflowMode declaration line' $agentsPath 'Use SetMode to restore the declared mode.'
                    }
                    elseif ($modes -contains $manifestMode -and $manifestMode -ne $declaredMode) {
                        Add-Row 'entry' 'fail' "managed block declares WorkflowMode=$declaredMode but the manifest records workflowMode=$manifestMode" $agentsPath 'Use SetMode to restore the declared mode; do not edit the managed block by hand.'
                        $script:requiredInputFailed = $true
                    }
                    else {
                        $note = ''
                        if ($declaredMode -eq 'disabled') { $note = '; disabled is not enabled by this diagnosis' }
                        Add-Row 'entry' 'pass' "managed block present; declared WorkflowMode=$declaredMode$note; declaration is not proof that a task selected it"
                    }
                }
            }
        }
        else {
            Add-Row 'entry' 'skip' 'AGENTS.md is absent; no package activation entry'
        }
        $handbook = Join-Path $workspace 'docs\ai-collaboration\README.md'
        if (Test-ReparseChain $handbook) {
            Add-Row 'entry' 'fail' 'canonical handbook path contains a reparse point; not followed' $handbook 'Restore the owned file from the package copy; do not follow a link.'
            $script:requiredInputFailed = $true
        }
        elseif (Test-Path -LiteralPath $handbook -PathType Leaf) {
            Add-Row 'entry' 'pass' 'canonical handbook docs/ai-collaboration/README.md is present (readable; not evidence of host loading)'
        }
        elseif ($installed) {
            Add-Row 'entry' 'fail' 'installed package is missing its canonical handbook docs/ai-collaboration/README.md' $handbook 'Restore the owned file from the package copy; do not overwrite other project documents.'
            $script:requiredInputFailed = $true
        }
        else {
            Add-Row 'entry' 'skip' 'canonical handbook absent; package not installed'
        }
        $currentTask = Join-Path $workspace '.ai\current-task.md'
        if (Test-ReparseChain $currentTask) {
            Add-Row 'entry' 'unknown' 'the current task path contains a reparse point; not followed; task selection is unknown'
        }
        elseif (Test-Path -LiteralPath $currentTask -PathType Leaf) {
            Add-Row 'entry' 'unknown' 'a current task file exists; this diagnosis does not infer whether it selects ai-collaboration'
        }
        else {
            Add-Row 'entry' 'unknown' 'no current task file; task selection is unknown and is not inferred from documents'
        }
    }
    catch {
        Add-Row 'entry' 'fail' ('entry category could not be completed: ' + $_.Exception.Message) $agentsPath 'Preserve the entry files and reconcile manually.'
        $script:requiredInputFailed = $true
    }

    # 4. Selected host: a single supported SkillTarget or an explicit unsupported/unknown host.
    try {
        if ([string]::IsNullOrWhiteSpace($HostTarget)) {
            Add-Row 'host' 'skip' 'no -Host selected; pass -Host <target> for the target view (agents, codex, claude, cursor, opencode, antigravity, gemini, iflow, qwen)'
        }
        else {
            $table = $null
            try { $table = Get-HostTable $PSScriptRoot } catch { $table = $null }
            if ($null -eq $table) {
                Add-Row 'host' 'fail' 'host target table compound-skills.manifest.json is unreadable or unsafe' (Join-Path $PSScriptRoot '..\compound-skills.manifest.json') 'Restore the owned canonical file from the package copy.'
                $script:requiredInputFailed = $true
            }
            elseif (-not $table.ContainsKey($HostTarget)) {
                Add-Row 'host' 'unknown' "host '$HostTarget' is unsupported or unknown; no integration is claimed" '' 'Read docs/ai-collaboration/README.md and the canonical skills under docs/ai-collaboration/skills/<name>/SKILL.md directly.'
            }
            else {
                $directory = [string]$table[$HostTarget]
                $relativeDirectory = $directory.Replace('/', '\')
                $canonicalReparse = @($skillNames | Where-Object { Test-ReparseChain (Join-Path $workspace "docs\ai-collaboration\skills\$_\SKILL.md") })
                $canonicalMissing = @($skillNames | Where-Object { -not (Test-Path -LiteralPath (Join-Path $workspace "docs\ai-collaboration\skills\$_\SKILL.md") -PathType Leaf) })
                $copyReparse = @($skillNames | Where-Object { Test-ReparseChain (Join-Path $workspace ($relativeDirectory + "\$_\SKILL.md")) })
                $copyMissing = @($skillNames | Where-Object { -not (Test-Path -LiteralPath (Join-Path $workspace ($relativeDirectory + "\$_\SKILL.md")) -PathType Leaf) })
                $ownedHere = ($installed -and $installedTarget -eq $HostTarget)
                # An installed layout recorded before 1.6.0 cannot own the entry Skills yet: their absence is an
                # upgrade gap, not corruption, with or without a matching -PackageRoot. A 1.6.0-or-later layout
                # keeps the strict owned checks.
                $gapNames = @()
                if ($installed -and (Test-PredatesEntrySkills $version)) { $gapNames = @($entrySkillNames) }
                $canonicalMissingGap = @($canonicalMissing | Where-Object { $_ -in $gapNames })
                $canonicalMissing = @($canonicalMissing | Where-Object { $_ -notin $gapNames })
                $copyMissingGap = @($copyMissing | Where-Object { $_ -in $gapNames })
                $copyMissingRequired = @($copyMissing | Where-Object { $_ -notin $gapNames })
                if ($canonicalReparse.Count -gt 0) {
                    Add-Row 'host' 'fail' ("canonical skill path contains a reparse point; not followed: " + ($canonicalReparse -join ', ')) (Join-Path $workspace 'docs\ai-collaboration\skills') 'Restore the owned canonical files from the package copy; do not follow a link.'
                    $script:requiredInputFailed = $true
                }
                elseif ($canonicalMissing.Count -gt 0 -and $installed) {
                    Add-Row 'host' 'fail' ("canonical skill copies missing: " + ($canonicalMissing -join ', ')) (Join-Path $workspace 'docs\ai-collaboration\skills') 'Restore the owned canonical files from the package copy.'
                    $script:requiredInputFailed = $true
                }
                elseif ($canonicalMissingGap.Count -gt 0 -and $installed) {
                    Add-Row 'host' 'warn' ("canonical entry Skills are not in this installed layout: " + ($canonicalMissingGap -join ', ') + '; the installed packageVersion predates them') (Join-Path $workspace 'docs\ai-collaboration\skills') 'Upgrade the installation with the package that carries these entry Skills; no file is changed by this diagnosis.'
                }
                if ($copyReparse.Count -gt 0) {
                    Add-Row 'host' 'fail' ("discovery path under ${directory} contains a reparse point; not followed: " + ($copyReparse -join ', ')) (Join-Path $workspace $relativeDirectory) 'Keep the link unchanged and reconcile manually; never overwrite other Skills.'
                    $script:requiredInputFailed = $true
                }
                elseif ($copyMissing.Count -eq 0) {
                    Add-Row 'host' 'pass' "selected discovery copies present under $directory (discoverability only; actual host loading is unknown)"
                }
                elseif ($ownedHere -and $copyMissingRequired.Count -gt 0) {
                    Add-Row 'host' 'fail' ("owned discovery copies missing under ${directory}: " + ($copyMissingRequired -join ', ')) (Join-Path $workspace $relativeDirectory) 'Reinstall the owned copies or reconcile manually; never overwrite other Skills.'
                    $script:requiredInputFailed = $true
                }
                elseif ($ownedHere -and $copyMissingGap.Count -gt 0) {
                    Add-Row 'host' 'warn' ("owned layout predates entry Skill copies under ${directory}: " + ($copyMissingGap -join ', ')) (Join-Path $workspace $relativeDirectory) 'Upgrade the installation with the package that carries these entry Skills; never copy them by hand.'
                }
                else {
                    Add-Row 'host' 'warn' ("optional discovery copies absent under $directory; canonical reading remains available at docs/ai-collaboration/skills/<name>/SKILL.md") '' 'Read the canonical file directly, or install one SkillTarget deliberately.'
                }
                if ($installed -and $installedTarget -ne 'none' -and $installedTarget -ne $HostTarget) {
                    Add-Row 'host' 'warn' "installed SkillTarget is $installedTarget; host $HostTarget has no managed copies; canonical reading applies" '' 'Switching targets requires uninstall and reinstall; do not add a second controller silently.'
                }
            }
        }
    }
    catch {
        Add-Row 'host' 'fail' ('host category could not be completed: ' + $_.Exception.Message) '' 'Preserve the host paths and reconcile manually.'
        $script:requiredInputFailed = $true
    }

    # 5. Actual host loading cannot be established by reading files.
    Add-Row 'loading' 'unknown' 'actual host loading and rule compliance are not verified by file inspection'
}

$counts = @{}
foreach ($status in @('pass', 'warn', 'fail', 'skip', 'unknown')) { $counts[$status] = @($script:rows | Where-Object { $_.Status -eq $status }).Count }
Write-Output 'ai-collaboration doctor (read-only; no files written)'
if ($workspace) { Write-Output "workspace: $workspace" }
foreach ($row in $script:rows) {
    if ($row.Category -eq 'summary') { continue }
    Write-Output ("[{0}] {1}: {2}" -f $row.Category, $row.Status.ToUpperInvariant(), $row.Message)
    if ($row.Path) { Write-Output ("    path: " + (Get-DisplayPath $row.Path)) }
    if ($row.Advice) { Write-Output ("    advice: " + $row.Advice) }
}
Write-Output ("summary: pass={0} warn={1} fail={2} skip={3} unknown={4}" -f $counts['pass'], $counts['warn'], $counts['fail'], $counts['skip'], $counts['unknown'])
$exitCode = if ($counts['fail'] -gt 0 -or $script:requiredInputFailed) { 1 } else { 0 }
Write-Output ("result: exit $exitCode")
exit $exitCode
