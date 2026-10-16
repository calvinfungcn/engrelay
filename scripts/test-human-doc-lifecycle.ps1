[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$PackageRoot,
    [string]$PreviousPackageRoot = '',
    [string]$PreviousGitRef = 'v1.7.1',
    [string]$SourceRepoRoot = '',
    [string]$LogPath = '',
    [ValidateSet('none', 'agents', 'codex')][string]$UpgradeTarget = 'none'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$started = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$scriptPath = $MyInvocation.MyCommand.Path
$scriptHash = $null
$candidate = [IO.Path]::GetFullPath($PackageRoot).TrimEnd('\', '/')
$explicitPrevious = if ([string]::IsNullOrWhiteSpace($PreviousPackageRoot)) { $null } else {
    [IO.Path]::GetFullPath($PreviousPackageRoot).TrimEnd('\', '/')
}
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')
$fixture = [IO.Path]::GetFullPath((Join-Path $tempBase ('engrelay-human-doc-test-' + [guid]::NewGuid().ToString('N'))))
$records = New-Object 'Collections.Generic.List[object]'
$calls = New-Object 'Collections.Generic.List[object]'
$ownedArtifacts = New-Object 'Collections.Generic.List[string]'
$extractedPreviousRoot = $null
$hostExe = (Get-Process -Id $PID).Path
$logFullPath = $null
$candidateSnapshotHash = $null
$previousSnapshotHash = $null
$newDocPaths = @(
    'docs/ai-collaboration/operator-guide.md',
    'docs/ai-collaboration/operator-guide.zh-CN.md',
    'docs/ai-collaboration/project-adoption.zh-CN.md',
    'docs/ai-collaboration/host-capabilities.zh-CN.md'
)
if ([string]::IsNullOrWhiteSpace($SourceRepoRoot)) {
    $scriptParent = Split-Path -Parent $scriptPath | Split-Path -Parent
    if (Test-Path -LiteralPath (Join-Path $scriptParent '.git') -PathType Container) {
        $SourceRepoRoot = $scriptParent
    }
}
if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    $logFullPath = [IO.Path]::GetFullPath($LogPath)
    foreach ($root in @($candidate, $explicitPrevious)) {
        if ($null -ne $root -and ($logFullPath -eq $root -or $logFullPath.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase))) {
            throw 'LogPath must be outside package roots'
        }
    }
}

function Get-Hash([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-FileHashText([string]$Path) { return Get-Hash ([IO.File]::ReadAllBytes($Path)) }

if (Test-Path -LiteralPath $scriptPath -PathType Leaf) {
    $scriptHash = Get-FileHashText $scriptPath
}

function Read-Json([string]$Path) { return (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json) }

function Register-OwnedArtifact([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    if ($ownedArtifacts -notcontains $full) { $ownedArtifacts.Add($full) | Out-Null }
}

function Remove-OwnedArtifacts {
    foreach ($path in @($ownedArtifacts.ToArray() | Sort-Object -Descending)) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $item = Get-Item -LiteralPath $path -Force
        if ($item.PSIsContainer) { Remove-Item -LiteralPath $path -Recurse -Force }
        else { Remove-Item -LiteralPath $path -Force }
    }
    $ownedArtifacts.Clear()
    $script:extractedPreviousRoot = $null
}

function Test-PathUnderRoot([string]$Path, [string]$Root) {
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    return ($full -eq $rootFull -or $full.StartsWith($rootFull + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase))
}

function Assert-PackageRootsDisjoint([string]$Left, [string]$Right, [string]$Message) {
    if ((Test-PathUnderRoot $Left $Right) -or (Test-PathUnderRoot $Right $Left)) { throw $Message }
}

function Assert-WritablePathOutsidePackageRoots([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    if (Test-PathUnderRoot $full $candidate) {
        throw "Path must not be inside candidate package root: $full"
    }
    if ($null -ne $explicitPrevious -and (Test-PathUnderRoot $full $explicitPrevious)) {
        throw "Path must not be inside explicit previous package root: $full"
    }
    return $full
}

function Assert-ExplicitPreviousInputRoot([string]$Root) {
    $full = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    if (-not (Test-Path -LiteralPath $full -PathType Container)) { throw "Explicit previous package root missing: $full" }
    Assert-PackageRootsDisjoint $full $candidate 'Candidate and explicit previous package roots must not overlap' | Out-Null
    return $full
}

function Assert-PackageMatchesSnapshot([string]$Root, [string]$Label) {
    $snapPath = Join-Path $Root 'snapshot.json'
    if (-not (Test-Path -LiteralPath $snapPath -PathType Leaf)) { throw "$Label package missing snapshot.json" }
    if (-not (Test-Path -LiteralPath (Join-Path $Root 'scripts/manage.ps1') -PathType Leaf)) { throw "$Label package missing scripts/manage.ps1" }
    $snap = Read-Json $snapPath
    if ([int]$snap.schemaVersion -ne 1) { throw "$Label snapshot schemaVersion mismatch" }
    foreach ($item in @($snap.files)) {
        $relative = [string]$item.path
        $path = Join-Path $Root ($relative -replace '/', '\')
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "$Label package missing snapshot file: $relative" }
        $bytes = [IO.File]::ReadAllBytes($path)
        if ($bytes.Length -ne [int]$item.bytes) { throw "$Label byte length mismatch: $relative" }
        if ((Get-Hash $bytes) -ne [string]$item.sha256) { throw "$Label hash mismatch: $relative" }
    }
    return (Get-FileHashText $snapPath)
}

function Get-PreviousPackageRoot {
    if ($null -ne $explicitPrevious) {
        $previousRoot = Assert-ExplicitPreviousInputRoot $explicitPrevious
        $hash = Assert-PackageMatchesSnapshot $previousRoot 'Explicit previous'
        $script:previousSnapshotHash = $hash
        return $previousRoot
    }
    if ([string]::IsNullOrWhiteSpace($SourceRepoRoot)) { throw 'PreviousPackageRoot or SourceRepoRoot with .git is required' }
    if (-not (Test-Path -LiteralPath (Join-Path $SourceRepoRoot '.git') -PathType Container)) {
        throw "SourceRepoRoot is not a git repository: $SourceRepoRoot"
    }
    if ([string]::IsNullOrWhiteSpace($PreviousGitRef)) { throw 'PreviousGitRef is required when PreviousPackageRoot is omitted' }
    $extractRoot = Join-Path $tempBase ('engrelay-human-prev-' + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $tempBase ('engrelay-human-prev-archive-' + [guid]::NewGuid().ToString('N') + '.zip')
    Register-OwnedArtifact $extractRoot
    Register-OwnedArtifact $zipPath
    Assert-WritablePathOutsidePackageRoots $extractRoot | Out-Null
    Assert-WritablePathOutsidePackageRoots $zipPath | Out-Null
    [IO.Directory]::CreateDirectory($extractRoot) | Out-Null
    & git -C $SourceRepoRoot archive -o $zipPath $PreviousGitRef
    if ($LASTEXITCODE -ne 0) { throw "git archive failed for $PreviousGitRef" }
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
        $zipFull = [IO.Path]::GetFullPath($zipPath).TrimEnd('\', '/')
        if ($ownedArtifacts.Contains($zipFull)) { $ownedArtifacts.Remove($zipFull) | Out-Null }
    }
    $hash = Assert-PackageMatchesSnapshot $extractRoot 'Archived previous'
    $script:previousSnapshotHash = $hash
    $script:extractedPreviousRoot = [IO.Path]::GetFullPath($extractRoot).TrimEnd('\', '/')
    return $script:extractedPreviousRoot
}

function Assert-Contained([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    if ($full -ne $fixture -and -not $full.StartsWith($fixture + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escaped disposable fixture: $full"
    }
    return $full
}

function Assert-SafeTree([string]$Root) {
    Assert-Contained $Root | Out-Null
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return }
    $pending = New-Object 'Collections.Generic.Stack[string]'; $pending.Push($Root)
    while ($pending.Count -gt 0) {
        foreach ($entryPath in [IO.Directory]::GetFileSystemEntries($pending.Pop())) {
            $entry = Get-Item -LiteralPath $entryPath -Force
            if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse point in fixture tree: $entryPath" }
            if ($entry.PSIsContainer) { $pending.Push($entry.FullName) }
        }
    }
}

function Get-ProjectFingerprint {
    Assert-SafeTree $fixture
    $paths = New-Object 'Collections.Generic.List[string]'
    $pending = New-Object 'Collections.Generic.Stack[string]'; $pending.Push($fixture)
    while ($pending.Count -gt 0) {
        foreach ($entryPath in [IO.Directory]::GetFileSystemEntries($pending.Pop())) {
            $entry = Get-Item -LiteralPath $entryPath -Force
            if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse point in fingerprint: $entryPath" }
            if ($entry.PSIsContainer) { $pending.Push($entry.FullName); continue }
            $relative = $entry.FullName.Substring($fixture.Length + 1).Replace('\', '/')
            $paths.Add($relative + '|' + (Get-FileHashText $entry.FullName))
        }
    }
    return (@($paths.ToArray() | Sort-Object) -join "`n")
}

function Write-FixtureText([string]$Relative, [string]$Text) {
    $path = Assert-Contained (Join-Path $fixture ($Relative -replace '/', '\'))
    [IO.Directory]::CreateDirectory((Split-Path -Parent $path)) | Out-Null
    [IO.File]::WriteAllText($path, $Text, $utf8)
}

function Quote-Arg([string]$Value) { return '"' + ($Value -replace '"', '\"') + '"' }

function Invoke-Native([string]$Name, [string]$Script, [string[]]$Arguments) {
    $quoted = @($Arguments | ForEach-Object { Quote-Arg ([string]$_) }) -join ' '
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $hostExe
    $psi.Arguments = '-NoProfile -ExecutionPolicy Bypass -File ' + (Quote-Arg $Script) + ' ' + $quoted
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $psi
    $watch = [Diagnostics.Stopwatch]::StartNew()
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $watch.Stop()
    $result = [pscustomobject]@{
        name = $Name
        childExit = [int]$process.ExitCode
        elapsedMs = [int64]$watch.Elapsed.TotalMilliseconds
        stdout = $stdout
        stderr = $stderr
    }
    $calls.Add($result) | Out-Null
    return $result
}

function Invoke-Manager([string]$Pkg, [string]$Root, [string]$Action, [string]$Target = '') {
    $manager = Join-Path $Pkg 'scripts/manage.ps1'
    $args = @('-Action', $Action, '-ProjectRoot', $Root)
    if (-not [string]::IsNullOrEmpty($Target)) { $args += @('-SkillTarget', $Target) }
    $args += @('-WorkflowMode', 'optional')
    return Invoke-Native ($Action + ':' + $Pkg) $manager $args
}

function Require-Exit($Result, [int]$Expected = 0) {
    if ($Result.childExit -ne $Expected) {
        throw "$($Result.name) exited $($Result.childExit), expected ${Expected}: $($Result.stderr.Trim()) $($Result.stdout.Trim())"
    }
}

function Record-Case([string]$Name, [scriptblock]$Body) {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try { & $Body; $status = 'PASS'; $errorText = '' }
    catch { $status = 'FAIL'; $errorText = $_.Exception.Message }
    $watch.Stop()
    $records.Add([pscustomobject]@{ name = $Name; status = $status; elapsedMs = [int64]$watch.Elapsed.TotalMilliseconds; error = $errorText }) | Out-Null
    if ($status -eq 'FAIL') { throw "[$Name] $errorText" }
}

function New-Fixture {
    if (Test-Path -LiteralPath $fixture) { throw "Unexpected fixture collision: $fixture" }
    Assert-Contained $fixture | Out-Null
    [IO.Directory]::CreateDirectory($fixture) | Out-Null
    Assert-SafeTree $fixture
}

function Remove-Fixture {
    if (Test-Path -LiteralPath $fixture) {
        Assert-SafeTree $fixture
        Remove-Item -LiteralPath $fixture -Recurse -Force
        if (Test-Path -LiteralPath $fixture) { throw "Fixture cleanup failed: $fixture" }
    }
}

function Seed-Project {
    Write-FixtureText 'AGENTS.md' "Project-owned instructions.`r`n"
    Write-FixtureText '.gitignore' ".ai/`r`n.ai-collaboration-install/`r`n"
    foreach ($sentinel in @('.ai/sentinel.md', 'openspec/sentinel.md', 'docs/reviews/sentinel.md', 'docs/solutions/sentinel.md')) {
        Write-FixtureText $sentinel ("sentinel:$sentinel`r`n")
    }
}

function Capture-Sentinels {
    $saved = @{}
    foreach ($relative in @('.ai/sentinel.md', 'openspec/sentinel.md', 'docs/reviews/sentinel.md', 'docs/solutions/sentinel.md')) {
        $saved[$relative] = Get-FileHashText (Join-Path $fixture ($relative -replace '/', '\'))
    }
    return $saved
}

function Assert-Sentinels([hashtable]$Expected) {
    foreach ($relative in $Expected.Keys) {
        $path = Join-Path $fixture ($relative -replace '/', '\')
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Sentinel disappeared: $relative" }
        if ((Get-FileHashText $path) -ne $Expected[$relative]) { throw "Sentinel changed: $relative" }
    }
}

function Assert-True([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

function Write-Summary([int]$OuterExit, [string]$ErrorText = '', [string]$PreviousRoot = '') {
    if ($started.IsRunning) { $started.Stop() }
    $caseRows = @($records | ForEach-Object {
        [pscustomobject]@{
            name = [string]$_.name
            status = [string]$_.status
            elapsedMs = [int64]$_.elapsedMs
            error = [string]$_.error
        }
    })
    $callRows = @($calls | ForEach-Object {
        [pscustomobject]@{
            name = [string]$_.name
            childExit = [int]$_.childExit
            elapsedMs = [int64]$_.elapsedMs
            stderr = if ($null -ne $_.stderr) { [string]$_.stderr } else { '' }
        }
    })
    $summary = [pscustomobject]@{
        schemaVersion = 1
        host = [IO.Path]::GetFileName($hostExe)
        hostVersion = [string]$PSVersionTable.PSVersion
        upgradeTarget = [string]$UpgradeTarget
        previousGitRef = [string]$PreviousGitRef
        inputHashes = [pscustomobject]@{
            testScriptSha256 = [string]$scriptHash
            candidateSnapshotSha256 = [string]$candidateSnapshotHash
            previousSnapshotSha256 = [string]$previousSnapshotHash
            candidateRoot = [string]$candidate
            previousRoot = [string]$PreviousRoot
        }
        cases = $caseRows
        calls = $callRows
        elapsedMs = [int64]$started.Elapsed.TotalMilliseconds
        outerExit = $OuterExit
        error = [string]$ErrorText
    }
    $json = $summary | ConvertTo-Json -Depth 8
    Write-Output $json
    if ($null -ne $logFullPath) { [IO.File]::WriteAllText($logFullPath, $json, $utf8) }
}

$previous = $null
try {
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { throw "Package root missing: $candidate" }
    $candidateSnapshotHash = Assert-PackageMatchesSnapshot $candidate 'Candidate'
    Assert-WritablePathOutsidePackageRoots $fixture | Out-Null
    if ($null -ne $logFullPath) { Assert-WritablePathOutsidePackageRoots $logFullPath | Out-Null }
    $previous = Get-PreviousPackageRoot
    if ($previous -eq $candidate) { throw 'Previous and candidate package roots must differ' }

    Record-Case 'upgrade-adds-four-human-docs' {
        New-Fixture; Seed-Project
        $agentsHash = Get-FileHashText (Join-Path $fixture 'AGENTS.md')
        $sentinels = Capture-Sentinels
        $installOld = Invoke-Manager $previous $fixture 'Install' $UpgradeTarget
        Require-Exit $installOld
        foreach ($rel in $newDocPaths) {
            if (Test-Path -LiteralPath (Join-Path $previous ('payload/' + $rel)) -PathType Leaf) { continue }
            if (Test-Path -LiteralPath (Join-Path $fixture $rel)) { throw "Pre-upgrade project already has $rel" }
        }
        $upgrade = Invoke-Manager $candidate $fixture 'Upgrade'
        Require-Exit $upgrade
        foreach ($rel in $newDocPaths) {
            $path = Join-Path $fixture ($rel -replace '/', '\')
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing after upgrade: $rel" }
        }
        $manifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
        $expectedTarget = if ($UpgradeTarget -eq 'none') { 'none' } else { $UpgradeTarget }
        Assert-True ([string]$manifest.skillTarget -eq $expectedTarget) 'Manifest skillTarget must match UpgradeTarget'
        $uninstall = Invoke-Manager $candidate $fixture 'Uninstall'
        Require-Exit $uninstall
        foreach ($rel in $newDocPaths) {
            if (Test-Path -LiteralPath (Join-Path $fixture ($rel -replace '/', '\'))) { throw "Package-created doc remained after uninstall: $rel" }
        }
        Assert-True ((Get-FileHashText (Join-Path $fixture 'AGENTS.md')) -eq $agentsHash) 'Project AGENTS.md changed'
        Assert-Sentinels $sentinels
        Remove-Fixture
    }

    Record-Case 'fresh-install-four-human-docs-managed' {
        New-Fixture; Seed-Project
        $agentsHash = Get-FileHashText (Join-Path $fixture 'AGENTS.md')
        $sentinels = Capture-Sentinels
        $install = Invoke-Manager $candidate $fixture 'Install' $UpgradeTarget
        Require-Exit $install
        foreach ($rel in $newDocPaths) {
            if (-not (Test-Path -LiteralPath (Join-Path $fixture ($rel -replace '/', '\')) -PathType Leaf)) { throw "Missing after install: $rel" }
        }
        $uninstall = Invoke-Manager $candidate $fixture 'Uninstall'
        Require-Exit $uninstall
        foreach ($rel in $newDocPaths) {
            if (Test-Path -LiteralPath (Join-Path $fixture ($rel -replace '/', '\'))) { throw "Doc remained after uninstall: $rel" }
        }
        Assert-True ((Get-FileHashText (Join-Path $fixture 'AGENTS.md')) -eq $agentsHash) 'Project AGENTS.md changed'
        Assert-Sentinels $sentinels
        Remove-Fixture
    }

    Record-Case 'preexisting-same-bytes-preserved' {
        New-Fixture; Seed-Project
        $installOld = Invoke-Manager $previous $fixture 'Install' $UpgradeTarget
        Require-Exit $installOld
        $relative = 'docs/ai-collaboration/operator-guide.zh-CN.md'
        $target = Join-Path $fixture ($relative -replace '/', '\')
        $sourcePath = Join-Path $candidate ('payload/' + $relative)
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Candidate source missing: $sourcePath" }
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        [IO.File]::Copy($sourcePath, $target, $true)
        $bytesBefore = [IO.File]::ReadAllBytes($target)
        $upgrade = Invoke-Manager $candidate $fixture 'Upgrade'
        Require-Exit $upgrade
        $bytesAfter = [IO.File]::ReadAllBytes($target)
        if ((Get-Hash $bytesBefore) -ne (Get-Hash $bytesAfter)) { throw 'Preexisting zh-CN operator guide bytes changed' }
        $uninstall = Invoke-Manager $candidate $fixture 'Uninstall'
        Require-Exit $uninstall
        $bytesAfterUninstall = [IO.File]::ReadAllBytes($target)
        if ((Get-Hash $bytesBefore) -ne (Get-Hash $bytesAfterUninstall)) { throw 'Preexisting file bytes changed after uninstall' }
        Remove-Fixture
    }

    Record-Case 'conflicting-bytes-zero-write' {
        New-Fixture; Seed-Project
        $installOld = Invoke-Manager $previous $fixture 'Install' $UpgradeTarget
        Require-Exit $installOld
        $target = Join-Path $fixture 'docs/ai-collaboration/operator-guide.zh-CN.md'
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        [IO.File]::WriteAllText($target, "different-bytes`r`n", $utf8)
        $before = Get-ProjectFingerprint
        $upgrade = Invoke-Manager $candidate $fixture 'Upgrade'
        Require-Exit $upgrade 1
        $after = Get-ProjectFingerprint
        if ($before -ne $after) { throw 'Conflict refusal modified the project tree' }
        Remove-Fixture
    }

    Record-Case 'managed-drift-zero-write' {
        New-Fixture; Seed-Project
        $installOld = Invoke-Manager $previous $fixture 'Install' $UpgradeTarget
        Require-Exit $installOld
        $target = Join-Path $fixture 'docs/ai-collaboration/project-adoption.md'
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'Expected managed project-adoption.md from previous install' }
        [IO.File]::WriteAllText($target, "drifted-managed-content`r`n", $utf8)
        $before = Get-ProjectFingerprint
        $upgrade = Invoke-Manager $candidate $fixture 'Upgrade'
        Require-Exit $upgrade 1
        $after = Get-ProjectFingerprint
        if ($before -ne $after) { throw 'Managed drift refusal modified the project tree' }
        Remove-Fixture
    }

    Write-Summary 0 '' $previous
    exit 0
}
catch {
    $message = $_.Exception.Message
    try { Remove-Fixture } catch { $message += '; fixture cleanup: ' + $_.Exception.Message }
    Write-Summary 1 $message $(if ($null -ne $previous) { $previous } else { '' })
    exit 1
}
finally {
    try { Remove-OwnedArtifacts } catch { }
}
