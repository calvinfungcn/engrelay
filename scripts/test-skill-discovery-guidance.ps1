[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [string]$LogPath = '',
    [string]$SourceRepoRoot = '',
    [string]$BaselineGitRef = '9c26c22266625aa04822637baf8f283763362677'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$started = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object Text.UTF8Encoding($false, $true)
if ([string]::IsNullOrWhiteSpace($PackageRoot)) { $PackageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent }
$package = [IO.Path]::GetFullPath($PackageRoot).TrimEnd('\', '/')
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')
$fixture = [IO.Path]::GetFullPath((Join-Path $tempBase ('engrelay-guidance-test-' + [guid]::NewGuid().ToString('N'))))
$records = New-Object 'Collections.Generic.List[object]'
$calls = New-Object 'Collections.Generic.List[object]'
$hostExe = (Get-Process -Id $PID).Path
$snapshotHash = $null
$managerHash = $null
$logFullPath = $null
if ([string]::IsNullOrWhiteSpace($SourceRepoRoot)) {
    $scriptRootParent = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
    if (Test-Path -LiteralPath (Join-Path $scriptRootParent '.git') -PathType Container) {
        $SourceRepoRoot = $scriptRootParent
    }
}
$baselineCases = New-Object 'Collections.Generic.List[object]'
$ownedBaselineArtifacts = New-Object 'Collections.Generic.List[string]'
$baselinePackageRoot = $null
if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    $logFullPath = [IO.Path]::GetFullPath($LogPath)
    if ($logFullPath -eq $package -or $logFullPath.StartsWith($package + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'LogPath must be outside the public package root'
    }
}

function Assert-Contained([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    if ($full -ne $fixture -and -not $full.StartsWith($fixture + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escaped disposable fixture: $full"
    }
    $cursor = $full
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse point in fixture ancestry: $cursor" }
        }
        $parent = Split-Path -Parent $cursor
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $cursor) { break }
        $cursor = $parent
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

function Get-Hash([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-FileHashText([string]$Path) { return Get-Hash ([IO.File]::ReadAllBytes($Path)) }

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
    $sorted = @($paths.ToArray() | Sort-Object)
    return ($sorted -join "`n")
}

function Write-FixtureText([string]$Relative, [string]$Text) {
    $path = Assert-Contained (Join-Path $fixture ($Relative -replace '/', '\'))
    [IO.Directory]::CreateDirectory((Split-Path -Parent $path)) | Out-Null
    [IO.File]::WriteAllText($path, $Text, $utf8)
}

function Read-Json([string]$Path) { return (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json) }
function Quote-Arg([string]$Value) { return '"' + ($Value -replace '"', '\"') + '"' }

function Convert-PublicText([string]$Text) {
    if ($null -eq $Text) { return '' }
    $value = [string]$Text
    $pairs = New-Object 'Collections.Generic.List[object]'
    $pairs.Add(@($package, '<package-root>'))
    $pairs.Add(@($fixture, '<fixture-root>'))
    $pairs.Add(@($tempBase, '<temp-root>'))
    $pairs.Add(@($hostExe, '<native-host>'))
    $pairs.Add(@([Environment]::GetFolderPath('UserProfile'), '<user-profile>'))
    foreach ($pair in $pairs) {
        if (-not [string]::IsNullOrEmpty([string]$pair[0])) {
            $value = [regex]::Replace($value, [regex]::Escape([string]$pair[0]), [string]$pair[1])
        }
    }
    $value = [regex]::Replace($value, '(?i)\b[A-Z]:\\(?:Users|Temp|ProgramData|Windows)\\[^\s"''<>]+', '<local-path>')
    return $value
}

function Convert-PublicCall($Call) {
    return [pscustomobject]@{
        name = Convert-PublicText ([string]$Call.name)
        childExit = [int]$Call.childExit
        elapsedMs = [int64]$Call.elapsedMs
        stdout = Convert-PublicText ([string]$Call.stdout)
        stderr = Convert-PublicText ([string]$Call.stderr)
    }
}

function Convert-PublicCase($Case) {
    return [pscustomobject]@{
        name = Convert-PublicText ([string]$Case.name)
        status = [string]$Case.status
        elapsedMs = [int64]$Case.elapsedMs
        error = Convert-PublicText ([string]$Case.error)
    }
}

function Write-GuidanceSummary([int]$OuterExit, [string]$ErrorText = '') {
    $started.Stop()
    $summary = [ordered]@{
        schemaVersion = 1
        focus = 'skill-discovery-guidance'
        packageVersion = '1.8.0'
        snapshotSha256 = $snapshotHash
        managerSha256 = $managerHash
        baselineGitRef = $BaselineGitRef
        host = [IO.Path]::GetFileName($hostExe)
        outputSafety = 'redacted'
        baselineCases = @($baselineCases | ForEach-Object { Convert-PublicCase $_ })
        cases = @($records | ForEach-Object { Convert-PublicCase $_ })
        calls = @($calls | ForEach-Object { Convert-PublicCall $_ })
        elapsedMs = [int64]$started.Elapsed.TotalMilliseconds
        outerExit = $OuterExit
    }
    if (-not [string]::IsNullOrEmpty($ErrorText)) { $summary.error = Convert-PublicText $ErrorText }
    $json = $summary | ConvertTo-Json -Depth 8
    Write-Output $json
    if ($null -ne $logFullPath) { [IO.File]::WriteAllText($logFullPath, $json, $utf8) }
}

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
    $result = [pscustomobject]@{ name = $Name; childExit = [int]$process.ExitCode; elapsedMs = [int64]$watch.Elapsed.TotalMilliseconds; stdout = $stdout; stderr = $stderr }
    $calls.Add($result) | Out-Null
    return $result
}

function Invoke-ManagerNative([string]$Name, [string]$Root, [string]$Action, [string]$Target = '') {
    $manager = Join-Path $package 'scripts/manage.ps1'
    $args = @('-Action', $Action, '-ProjectRoot', $Root)
    if (-not [string]::IsNullOrEmpty($Target)) { $args += @('-SkillTarget', $Target) }
    $args += @('-WorkflowMode', 'optional')
    return Invoke-Native ($Name + ':' + $Action) $manager $args
}

function Invoke-ManagerStreams([string]$Root, [string]$Action, [string]$Target = '', [string]$ManagerPath = '', [string]$PackageRootForManager = '') {
    $pkgRoot = if ([string]::IsNullOrWhiteSpace($PackageRootForManager)) { $package } else { [IO.Path]::GetFullPath($PackageRootForManager).TrimEnd('\', '/') }
    $manager = if ([string]::IsNullOrWhiteSpace($ManagerPath)) { Join-Path $pkgRoot 'scripts/manage.ps1' } else { $ManagerPath }
    $params = @{ Action = $Action; ProjectRoot = $Root; WorkflowMode = 'optional' }
    if (-not [string]::IsNullOrEmpty($Target)) { $params.SkillTarget = $Target }
    $information = New-Object 'Collections.Generic.List[string]'
    $childExit = 0
    $errorText = ''
    try {
        $success = & $manager @params 6>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.InformationRecord]) {
                $information.Add([string]$_.ToString()) | Out-Null
                return
            }
            $_
        }
    }
    catch {
        $childExit = 1
        $errorText = $_.Exception.Message
        throw
    }
    return [pscustomobject]@{
        success = @($success | ForEach-Object { [string]$_ })
        information = $information.ToArray()
        childExit = $childExit
        errorText = $errorText
    }
}

function Invoke-ManagerStreamsAllowFail([string]$Root, [string]$Action, [string]$Target = '', [string]$ManagerPath = '', [string]$PackageRootForManager = '') {
    $pkgRoot = if ([string]::IsNullOrWhiteSpace($PackageRootForManager)) { $package } else { [IO.Path]::GetFullPath($PackageRootForManager).TrimEnd('\', '/') }
    $manager = if ([string]::IsNullOrWhiteSpace($ManagerPath)) { Join-Path $pkgRoot 'scripts/manage.ps1' } else { $ManagerPath }
    $params = @{ Action = $Action; ProjectRoot = $Root; WorkflowMode = 'optional' }
    if (-not [string]::IsNullOrEmpty($Target)) { $params.SkillTarget = $Target }
    $information = New-Object 'Collections.Generic.List[string]'
    $childExit = 0
    $errorText = ''
    $success = @()
    try {
        $success = @(& $manager @params 6>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.InformationRecord]) {
                $information.Add([string]$_.ToString()) | Out-Null
                return
            }
            $_
        } | ForEach-Object { [string]$_ })
    }
    catch {
        $childExit = 1
        $errorText = $_.Exception.Message
    }
    return [pscustomobject]@{
        success = $success
        information = $information.ToArray()
        childExit = $childExit
        errorText = $errorText
    }
}

function Assert-OwnedBaselineArtifact([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    if ($full -ne $tempBase -and -not $full.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Baseline artifact escapes temp root: $full"
    }
    $name = [IO.Path]::GetFileName($full)
    if ($name -notmatch '^engrelay-baseline-(pkg|archive)-[0-9a-f]{32}(\.zip)?$') {
        throw "Unexpected baseline artifact name: $name"
    }
    if (Test-Path -LiteralPath $full) {
        $cursor = $full
        while ($cursor) {
            if (Test-Path -LiteralPath $cursor) {
                $item = Get-Item -LiteralPath $cursor -Force
                if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse point on baseline artifact path: $cursor" }
            }
            $parent = Split-Path -Parent $cursor
            if ([string]::IsNullOrEmpty($parent) -or $parent -eq $cursor) { break }
            $cursor = $parent
        }
    }
    return $full
}

function Register-OwnedBaselineArtifact([string]$Path) {
    $full = Assert-OwnedBaselineArtifact $Path
    if (-not $ownedBaselineArtifacts.Contains($full)) { $ownedBaselineArtifacts.Add($full) | Out-Null }
}

function Remove-OwnedBaselineArtifacts {
    foreach ($path in @($ownedBaselineArtifacts.ToArray() | Sort-Object { $_.Length } -Descending)) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        Assert-OwnedBaselineArtifact $path | Out-Null
        if (Test-Path -LiteralPath $path -PathType Container) {
            Remove-Item -LiteralPath $path -Recurse -Force
        }
        else {
            Remove-Item -LiteralPath $path -Force
        }
        if (Test-Path -LiteralPath $path) { throw "Baseline artifact cleanup failed: $path" }
    }
    $ownedBaselineArtifacts.Clear()
    $script:baselinePackageRoot = $null
}

function Get-BaselinePackageRoot {
    if ([string]::IsNullOrWhiteSpace($SourceRepoRoot)) { throw 'SourceRepoRoot is required to extract baseline package' }
    if (-not (Test-Path -LiteralPath (Join-Path $SourceRepoRoot '.git') -PathType Container)) {
        throw "SourceRepoRoot is not a git repository: $SourceRepoRoot"
    }
    if ([string]::IsNullOrWhiteSpace($BaselineGitRef)) { throw 'BaselineGitRef is required' }
    $extractRoot = Join-Path $tempBase ('engrelay-baseline-pkg-' + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $tempBase ('engrelay-baseline-archive-' + [guid]::NewGuid().ToString('N') + '.zip')
    Register-OwnedBaselineArtifact $extractRoot
    Register-OwnedBaselineArtifact $zipPath
    [IO.Directory]::CreateDirectory($extractRoot) | Out-Null
    & git -C $SourceRepoRoot archive -o $zipPath $BaselineGitRef
    if ($LASTEXITCODE -ne 0) { throw "git archive failed for baseline ref $BaselineGitRef" }
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
        if (Test-Path -LiteralPath $zipPath) { throw "Baseline archive zip cleanup failed: $zipPath" }
        $zipFull = [IO.Path]::GetFullPath($zipPath).TrimEnd('\', '/')
        if ($ownedBaselineArtifacts.Contains($zipFull)) { $ownedBaselineArtifacts.Remove($zipFull) | Out-Null }
    }
    $baselinePath = Join-Path $extractRoot 'scripts\manage.ps1'
    if (-not (Test-Path -LiteralPath $baselinePath -PathType Leaf)) { throw 'Baseline manage.ps1 missing after archive extract' }
    $text = [IO.File]::ReadAllText($baselinePath)
    if ($text -match 'Write-InstallDiscoveryGuidance') {
        throw "Baseline ref $BaselineGitRef still contains install guidance; choose an earlier ref with -BaselineGitRef"
    }
    $script:baselinePackageRoot = [IO.Path]::GetFullPath($extractRoot).TrimEnd('\', '/')
    return $script:baselinePackageRoot
}

function Record-BaselineCase([string]$Name, [scriptblock]$Body) {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try { & $Body; $status = 'PASS'; $errorText = '' }
    catch { $status = 'FAIL'; $errorText = $_.Exception.Message }
    $watch.Stop()
    $baselineCases.Add([pscustomobject]@{ name = $Name; status = $status; elapsedMs = [int64]$watch.Elapsed.TotalMilliseconds; error = $errorText }) | Out-Null
    if ($status -eq 'FAIL') { throw "[baseline:$Name] $errorText" }
}

function Assert-NoInstallGuidance([string[]]$Information, [string[]]$Success) {
    if ($Information.Count -gt 0) { throw 'Expected no information-stream install guidance' }
    $joined = ($Success -join "`n")
    if ($joined -match 'Canonical Skills:') { throw 'Success stream unexpectedly contains guidance text' }
}

function Invoke-ManagerStreamsSuppressInfo([string]$Root, [string]$Action, [string]$Target = '') {
    $manager = Join-Path $package 'scripts/manage.ps1'
    $params = @{ Action = $Action; ProjectRoot = $Root; WorkflowMode = 'optional' }
    if (-not [string]::IsNullOrEmpty($Target)) { $params.SkillTarget = $Target }
    $success = @(& $manager @params 6>$null)
    return @($success | ForEach-Object { [string]$_ })
}

function Require-Exit($Result, [int]$Expected = 0) {
    if ($Result.childExit -ne $Expected) { throw "$($Result.name) exited $($Result.childExit), expected ${Expected}" }
}

function Assert-InstallGuidancePresent([string[]]$Information, [string]$Target, [string]$ProjectRoot) {
    $joined = ($Information -join "`n")
    $rootNorm = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\', '/')
    if ($Information.Count -lt 4) { throw 'Expected install guidance on the information stream' }
    if ($joined -notmatch [regex]::Escape('SkillTarget: ' + $Target)) { throw "SkillTarget label missing for $Target" }
    if ($joined -notmatch [regex]::Escape('ProjectRoot: ' + $rootNorm)) { throw 'ProjectRoot missing from guidance' }
    $canonicalFull = [IO.Path]::GetFullPath((Join-Path $rootNorm 'docs/ai-collaboration/skills/ai-collab-start/SKILL.md'))
    if ($joined -notmatch [regex]::Escape($canonicalFull)) { throw 'Canonical full path missing from guidance' }
    if (-not (Test-Path -LiteralPath $canonicalFull -PathType Leaf)) { throw 'Canonical path in guidance does not exist on disk' }
    if ($joined -notmatch 'host discovery or loading') { throw 'Host loading caveat missing from guidance' }
    if ($Target -eq 'none') {
        if ($joined -notmatch 'did not deploy package-managed host discovery') { throw 'none guidance missing no-copy statement' }
    }
    elseif ($Target -eq 'agents') {
        $discoveryFull = [IO.Path]::GetFullPath((Join-Path $rootNorm '.agents/skills'))
        if ($joined -notmatch [regex]::Escape($discoveryFull)) { throw 'agents discovery full path missing from guidance' }
        Assert-True (Test-Path -LiteralPath (Join-Path $discoveryFull 'ai-collab-start/SKILL.md') -PathType Leaf) 'agents discovery file missing'
    }
    elseif ($Target -eq 'codex') {
        $discoveryFull = [IO.Path]::GetFullPath((Join-Path $rootNorm '.codex/skills'))
        if ($joined -notmatch [regex]::Escape($discoveryFull)) { throw 'codex discovery full path missing from guidance' }
        Assert-True (Test-Path -LiteralPath (Join-Path $discoveryFull 'ai-collab-start/SKILL.md') -PathType Leaf) 'codex discovery file missing'
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

function Assert-True([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Assert-Equal([object]$Actual, [object]$Expected, [string]$Message) { if ($Actual -ne $Expected) { throw "$Message (actual=$Actual expected=$Expected)" } }

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
        Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Sentinel disappeared: $relative"
        Assert-Equal (Get-FileHashText $path) $Expected[$relative] "Sentinel changed: $relative"
    }
}

$script:runError = ''
try {
    if (-not (Test-Path -LiteralPath $package -PathType Container)) { throw "Package root is missing: $package" }
    if (-not (Test-Path -LiteralPath (Join-Path $package 'snapshot.json') -PathType Leaf)) { throw 'Public snapshot is missing; run update-snapshot.ps1 first' }
    $snapshot = Read-Json (Join-Path $package 'snapshot.json')
    $snapshotHash = Get-FileHashText (Join-Path $package 'snapshot.json')
    $managerPath = Join-Path $package 'scripts/manage.ps1'
    Assert-True (Test-Path -LiteralPath $managerPath -PathType Leaf) 'Public manager missing'
    $managerHash = Get-FileHashText $managerPath
    Assert-Equal $snapshot.schemaVersion 1 'Public snapshot schema mismatch'
    Assert-Equal ([string]$snapshot.packageVersion) '1.8.0' 'Public snapshot version mismatch'

    $baselinePackage = Get-BaselinePackageRoot
    foreach ($baselineTarget in @(@{ name = 'baseline-none'; target = '' }, @{ name = 'baseline-agents'; target = 'agents' }, @{ name = 'baseline-codex'; target = 'codex' })) {
        $caseName = [string]$baselineTarget.name
        $targetValue = [string]$baselineTarget.target
        Record-BaselineCase $caseName {
            New-Fixture; Seed-Project
            $result = Invoke-ManagerStreamsAllowFail $fixture 'Install' $targetValue '' $baselinePackage
            Assert-Equal $result.childExit 0 'Baseline install should succeed'
            Assert-NoInstallGuidance $result.information $result.success
            Remove-Fixture
        }
    }

    Record-Case 'default-none-streams-and-files' {
        New-Fixture; Seed-Project
        $userCopy = '.agents/skills/user-owned-sentinel/SKILL.md'
        Write-FixtureText $userCopy "user-owned`r`n"
        $userHash = Get-FileHashText (Join-Path $fixture ($userCopy -replace '/', '\'))
        $result = Invoke-ManagerStreams $fixture 'Install'
        Assert-Equal $result.childExit 0 'Install failed'
        Assert-Equal $result.success.Count 1 'Success stream should contain only the original install line'
        Assert-True ($result.success[0] -match '^Installed: \d+ tracked files; Skill target none;') 'Original success message missing'
        Assert-InstallGuidancePresent $result.information 'none' $fixture
        $manifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
        Assert-Equal ([string]$manifest.skillTarget) 'none' 'Manifest skillTarget should be none'
        Assert-True (Test-Path -LiteralPath (Join-Path $fixture 'docs/ai-collaboration/skills/ai-collab-start/SKILL.md') -PathType Leaf) 'Canonical skill missing'
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $fixture '.agents/skills/ai-collab-start/SKILL.md') -PathType Leaf)) 'Package-managed agents discovery copy should not exist for none'
        Assert-Equal (Get-FileHashText (Join-Path $fixture ($userCopy -replace '/', '\'))) $userHash 'User-owned discovery copy changed'
        Remove-Fixture
    }

    Record-Case 'agents-target-discovery-copy' {
        New-Fixture; Seed-Project
        $result = Invoke-ManagerStreams $fixture 'Install' 'agents'
        Assert-Equal $result.childExit 0 'Install failed'
        Assert-InstallGuidancePresent $result.information 'agents' $fixture
        Assert-True (Test-Path -LiteralPath (Join-Path $fixture '.agents/skills/ai-collab-start/SKILL.md') -PathType Leaf) 'agents discovery copy missing'
        $manifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
        Assert-Equal ([string]$manifest.skillTarget) 'agents' 'Manifest skillTarget should be agents'
        Remove-Fixture
    }

    Record-Case 'codex-compatible-target' {
        New-Fixture; Seed-Project
        $result = Invoke-ManagerStreams $fixture 'Install' 'codex'
        Assert-Equal $result.childExit 0 'Install failed'
        Assert-InstallGuidancePresent $result.information 'codex' $fixture
        Assert-True (Test-Path -LiteralPath (Join-Path $fixture '.codex/skills/ai-collab-start/SKILL.md') -PathType Leaf) 'codex discovery copy missing'
        $manifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
        Assert-Equal ([string]$manifest.skillTarget) 'codex' 'Manifest skillTarget should be codex'
        Remove-Fixture
    }

    Record-Case 'repeat-install-and-upgrade-no-guidance' {
        New-Fixture; Seed-Project
        $first = Invoke-ManagerStreams $fixture 'Install' 'agents'
        Assert-InstallGuidancePresent $first.information 'agents' $fixture
        $fingerprintAfterFirst = Get-ProjectFingerprint
        $repeat = Invoke-ManagerStreams $fixture 'Install' 'agents'
        Assert-Equal $repeat.success.Count 1 'Repeat install success stream'
        Assert-True ($repeat.success[0] -eq 'Already installed (no writes)') 'Repeat install message'
        Assert-Equal $repeat.information.Count 0 'Repeat install should not emit guidance'
        Assert-Equal (Get-ProjectFingerprint) $fingerprintAfterFirst 'Repeat install changed project fingerprint'
        $upgrade = Invoke-ManagerStreams $fixture 'Upgrade'
        Assert-True ($upgrade.success[0] -match '^Upgraded to packageVersion=') 'Upgrade success message'
        Assert-Equal $upgrade.information.Count 0 'Upgrade should not emit install guidance'
        $manifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
        Assert-Equal ([string]$manifest.skillTarget) 'agents' 'Upgrade must preserve SkillTarget'
        Remove-Fixture
    }

    Record-Case 'stream-suppress-and-warning-preference' {
        New-Fixture; Seed-Project
        $warnBefore = $WarningPreference
        try {
            $WarningPreference = 'Stop'
            $suppressed = @(Invoke-ManagerStreamsSuppressInfo $fixture 'Install')
            Assert-Equal $suppressed.Count 1 'Suppressed install should keep success stream only'
            Assert-True ($suppressed[0] -match '^Installed: ') 'Suppressed success line missing'
        }
        finally { $WarningPreference = $warnBefore }
        Remove-Fixture
    }

    Record-Case 'conflict-install-native-fail-no-guidance' {
        New-Fixture; Seed-Project
        Write-FixtureText 'docs/ai-collaboration/README.md' "preexisting-conflict`r`n"
        $before = Get-ProjectFingerprint
        $conflict = Invoke-ManagerNative 'conflict:install' $fixture 'Install'
        Require-Exit $conflict 1
        Assert-True ($conflict.stderr -match 'Refusing differing existing file') 'Conflict stderr missing refusal'
        Assert-True ($conflict.stdout -notmatch 'Canonical Skills:') 'Conflict stdout must not contain success guidance'
        Assert-Equal (Get-ProjectFingerprint) $before 'Conflict install must not write project files'
        $stream = Invoke-ManagerStreamsAllowFail $fixture 'Install'
        Assert-Equal $stream.childExit 1 'Conflict install stream call must fail'
        Assert-NoInstallGuidance $stream.information $stream.success
        Remove-Fixture
    }

    Record-Case 'installed-drift-install-fail-no-guidance' {
        New-Fixture; Seed-Project
        $install = Invoke-ManagerNative 'drift-install:install' $fixture 'Install'; Require-Exit $install
        $driftPath = Join-Path $fixture 'docs/ai-collaboration/README.md'
        [IO.File]::AppendAllText($driftPath, "owned-drift`r`n", $utf8)
        $before = Get-ProjectFingerprint
        $retry = Invoke-ManagerNative 'drift-install:retry-install' $fixture 'Install'
        Require-Exit $retry 1
        Assert-True (($retry.stderr + $retry.stdout) -match 'Modified installed file') 'Drift retry Install must refuse'
        Assert-True ($retry.stdout -notmatch 'Canonical Skills:') 'Drift Install failure must not emit success guidance'
        Assert-Equal (Get-ProjectFingerprint) $before 'Drift Install retry must not write project files'
        $stream = Invoke-ManagerStreamsAllowFail $fixture 'Install'
        Assert-Equal $stream.childExit 1 'Drift Install stream call must fail'
        Assert-NoInstallGuidance $stream.information $stream.success
        Remove-Fixture
    }

    Record-Case 'owned-drift-upgrade-zero-write' {
        New-Fixture; Seed-Project
        $install = Invoke-ManagerNative 'drift:install' $fixture 'Install'; Require-Exit $install
        $driftPath = Join-Path $fixture 'docs/ai-collaboration/README.md'
        [IO.File]::AppendAllText($driftPath, "owned-drift`r`n", $utf8)
        $before = Get-ProjectFingerprint
        $upgrade = Invoke-ManagerNative 'drift:upgrade' $fixture 'Upgrade'
        Require-Exit $upgrade 1
        $after = Get-ProjectFingerprint
        Assert-Equal $after $before 'Owned-file drift Upgrade refusal wrote to the project'
        Remove-Fixture
    }

    Record-Case 'guidance-paths-from-package-cwd' {
        New-Fixture; Seed-Project
        $previous = Get-Location
        try {
            Set-Location -LiteralPath $package
            $result = Invoke-ManagerStreams $fixture 'Install' 'agents'
            Assert-Equal $result.childExit 0 'Install from package cwd failed'
            Assert-InstallGuidancePresent $result.information 'agents' $fixture
        }
        finally { Set-Location -LiteralPath $previous.Path }
        Remove-Fixture
    }

    Remove-Fixture
}
catch {
    $script:runError = $_.Exception.Message
}
finally {
    try { Remove-Fixture } catch {
        if ([string]::IsNullOrEmpty($script:runError)) { $script:runError = $_.Exception.Message }
        else { $script:runError += '; fixture cleanup: ' + $_.Exception.Message }
    }
    try { Remove-OwnedBaselineArtifacts } catch {
        if ([string]::IsNullOrEmpty($script:runError)) { $script:runError = $_.Exception.Message }
        else { $script:runError += '; baseline cleanup: ' + $_.Exception.Message }
    }
    if (-not [string]::IsNullOrEmpty($script:baselinePackageRoot) -or $ownedBaselineArtifacts.Count -gt 0) {
        if ([string]::IsNullOrEmpty($script:runError)) {
            $script:runError = 'Baseline artifacts remained registered after cleanup'
        }
    }
}
if ([string]::IsNullOrEmpty($script:runError)) {
    Write-GuidanceSummary 0
    exit 0
}
Write-GuidanceSummary 1 $script:runError
exit 1
