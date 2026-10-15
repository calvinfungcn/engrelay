[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [string]$PreviousPackageRoot = '',
    [string]$LogPath = '',
    [switch]$RedactionOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$started = [Diagnostics.Stopwatch]::StartNew()
$utf8 = New-Object Text.UTF8Encoding($false, $true)
if ([string]::IsNullOrWhiteSpace($PackageRoot)) { $PackageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent }
$package = [IO.Path]::GetFullPath($PackageRoot).TrimEnd('\', '/')
$previous = if ([string]::IsNullOrWhiteSpace($PreviousPackageRoot)) { $null } else { [IO.Path]::GetFullPath($PreviousPackageRoot).TrimEnd('\', '/') }
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')
$fixture = [IO.Path]::GetFullPath((Join-Path $tempBase ('engrelay-public-test-' + [guid]::NewGuid().ToString('N'))))
$records = New-Object 'Collections.Generic.List[object]'
$calls = New-Object 'Collections.Generic.List[object]'
$hostExe = (Get-Process -Id $PID).Path
$snapshotHash = $null
$logFullPath = $null
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
    if ($null -ne $previous) { $pairs.Add(@($previous, '<previous-package-root>')) }
    $pairs.Add(@($fixture, '<fixture-root>'))
    $pairs.Add(@($tempBase, '<temp-root>'))
    $pairs.Add(@($hostExe, '<native-host>'))
    $pairs.Add(@([Environment]::GetFolderPath('UserProfile'), '<user-profile>'))
    foreach ($pair in $pairs) {
        if (-not [string]::IsNullOrEmpty([string]$pair[0])) {
            $value = [regex]::Replace($value, [regex]::Escape([string]$pair[0]), [string]$pair[1])
        }
    }
    # Known roots above are replaced first. This final narrow scrub catches a
    # user/temp/Windows absolute path emitted by a child diagnostic without
    # pretending to be an exhaustive secret scanner.
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

function Write-PublicSummary([int]$OuterExit, [string]$ErrorText = '') {
    $started.Stop()
    $summary = [ordered]@{
        schemaVersion = 1
        packageVersion = '1.7.1'
        snapshotSha256 = $snapshotHash
        host = [IO.Path]::GetFileName($hostExe)
        previousPackageVersion = if ($null -eq $previous) { $null } else { '1.6.1' }
        outputSafety = 'redacted'
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

function Invoke-Manager([string]$Name, [string]$Root, [string]$Action, [string]$Target = '') {
    $manager = Join-Path $Name 'scripts/manage.ps1'
    $args = @('-Action', $Action, '-ProjectRoot', $Root)
    if (-not [string]::IsNullOrEmpty($Target)) { $args += @('-SkillTarget', $Target) }
    $args += @('-WorkflowMode', 'optional')
    return Invoke-Native ($Name + ':' + $Action) $manager $args
}

function Invoke-Doctor([string]$Name, [string]$Root) {
    $doctor = Join-Path $Name 'payload/docs/ai-collaboration/scripts/doctor.ps1'
    return Invoke-Native ($Name + ':doctor-unknown-host') $doctor @('-WorkspaceRoot', $Root, '-PackageRoot', $Name, '-HostTarget', 'unknown-public-host')
}

function Require-Exit($Result, [int]$Expected = 0) {
    if ($Result.childExit -ne $Expected) { throw "$($Result.name) exited $($Result.childExit), expected ${Expected}: $($Result.stderr.Trim()) $($Result.stdout.Trim())" }
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

function Assert-Sentinels([hashtable]$Expected) {
    foreach ($relative in $Expected.Keys) {
        $path = Join-Path $fixture ($relative -replace '/', '\')
        Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Sentinel disappeared: $relative"
        Assert-Equal (Get-FileHashText $path) $Expected[$relative] "Sentinel changed: $relative"
    }
}

function Capture-Sentinels {
    $saved = @{}
    foreach ($relative in @('.ai/sentinel.md', 'openspec/sentinel.md', 'docs/reviews/sentinel.md', 'docs/solutions/sentinel.md')) {
        $saved[$relative] = Get-FileHashText (Join-Path $fixture ($relative -replace '/', '\'))
    }
    return $saved
}

try {
    if (-not (Test-Path -LiteralPath $package -PathType Container)) { throw "Package root is missing: $package" }
    if (-not (Test-Path -LiteralPath (Join-Path $package 'snapshot.json') -PathType Leaf)) { throw 'Public snapshot is missing; run update-snapshot.ps1 first' }
    $snapshot = Read-Json (Join-Path $package 'snapshot.json')
    $snapshotHash = Get-FileHashText (Join-Path $package 'snapshot.json')
    Assert-Equal $snapshot.schemaVersion 1 'Public snapshot schema mismatch'
    Assert-Equal ([string]$snapshot.packageVersion) '1.7.1' 'Public snapshot version mismatch'
    Assert-True (-not ($snapshot.PSObject.Properties.Name -contains 'sourceRoot')) 'Public snapshot contains a sourceRoot proof path'
    Assert-True (-not ($snapshot.PSObject.Properties.Name -contains 'archiveRoot')) 'Public snapshot contains an archive proof path'
    Assert-True (Test-Path -LiteralPath (Join-Path $package 'scripts/manage.ps1') -PathType Leaf) 'Public manager missing'
    Assert-True (Test-Path -LiteralPath (Join-Path $package 'payload/docs/ai-collaboration/scripts/doctor.ps1') -PathType Leaf) 'Public doctor missing'
    if ($null -ne $previous) {
        if (-not (Test-Path -LiteralPath $previous -PathType Container)) { throw "Previous package root is missing: $previous" }
        $oldSnapshot = Read-Json (Join-Path $previous 'snapshot.json')
        Assert-Equal ([string]$oldSnapshot.packageVersion) '1.6.1' 'Previous package is not 1.6.1'
    }
    if ($RedactionOnly) {
        $calls.Add([pscustomobject]@{
            name = $package + ':redaction-sample'
            childExit = 0
            elapsedMs = 0
            stdout = "package=$package previous=$previous fixture=$fixture temp=$tempBase host=$hostExe"
            stderr = "diagnostic=$package/scripts/manage.ps1"
        }) | Out-Null
        $records.Add([pscustomobject]@{ name = 'redaction-only'; status = 'PASS'; elapsedMs = 0; error = '' }) | Out-Null
        Write-PublicSummary 0
        exit 0
    }

    Record-Case 'new-install-status-doctor-uninstall' {
        New-Fixture; Seed-Project
        $sentinels = Capture-Sentinels
        $agentsPath = Join-Path $fixture 'AGENTS.md'
        $originalAgents = [IO.File]::ReadAllBytes($agentsPath)
        $install = Invoke-Manager $package $fixture 'Install'
        Require-Exit $install
        $status = Invoke-Manager $package $fixture 'Status'; Require-Exit $status
        $version = Invoke-Manager $package $fixture 'CheckVersion'; Require-Exit $version
        $doctor = Invoke-Doctor $package $fixture; Require-Exit $doctor
        Assert-True ($doctor.stdout -match 'UNKNOWN: host') 'Unknown host was not reported honestly'
        [IO.File]::AppendAllText($agentsPath, "outside-new-cycle`r`n", $utf8)
        $uninstall = Invoke-Manager $package $fixture 'Uninstall'; Require-Exit $uninstall
        Assert-True ([Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($agentsPath)).Contains('outside-new-cycle')) 'Outside AGENTS edit was lost'
        Assert-Equal (Get-Hash ([IO.File]::ReadAllBytes($agentsPath))) (Get-Hash ($originalAgents + $utf8.GetBytes("outside-new-cycle`r`n"))) 'AGENTS backup/bytes were not restored'
        Assert-Sentinels $sentinels
        Remove-Fixture
    }

    if ($null -ne $previous) {
        Record-Case 'frozen-161-codex-upgrade-status-doctor-uninstall' {
            New-Fixture; Seed-Project
            $sentinels = Capture-Sentinels
            $agentsPath = Join-Path $fixture 'AGENTS.md'
            $originalAgents = [IO.File]::ReadAllBytes($agentsPath)
            $installOld = Invoke-Manager $previous $fixture 'Install' 'codex'; Require-Exit $installOld
            $oldManifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
            $oldAgentRecord = @($oldManifest.files | Where-Object { $_.path -eq 'AGENTS.md' })[0]
            Assert-Equal ([Convert]::FromBase64String([string]$oldAgentRecord.backup)).Length $originalAgents.Length 'Original AGENTS backup missing'
            Assert-Equal (Get-Hash ([Convert]::FromBase64String([string]$oldAgentRecord.backup))) (Get-Hash $originalAgents) 'Original AGENTS backup differs'
            [IO.File]::AppendAllText($agentsPath, "outside-upgrade-cycle`r`n", $utf8)
            $status = Invoke-Manager $package $fixture 'Status'; Require-Exit $status
            $version = Invoke-Manager $package $fixture 'CheckVersion'; Require-Exit $version
            $upgrade = Invoke-Manager $package $fixture 'Upgrade'; Require-Exit $upgrade
            $manifest = Read-Json (Join-Path $fixture '.ai-collaboration-install/manifest.json')
            Assert-Equal ([string]$manifest.packageVersion) '1.7.1' 'Upgrade did not record package version'
            Assert-Equal ([string]$manifest.skillTarget) 'codex' 'Upgrade did not preserve codex SkillTarget'
            Assert-Equal ([string]$manifest.workflowMode) 'optional' 'Upgrade did not preserve WorkflowMode'
            $agentsText = [IO.File]::ReadAllText($agentsPath)
            Assert-True ($agentsText.Contains('EngRelay') -and $agentsText.Contains('public package alias for ai-collaboration')) 'EngRelay alias semantics were not installed'
            $doctor = Invoke-Doctor $package $fixture; Require-Exit $doctor
            Assert-True ($doctor.stdout -match 'UNKNOWN: host') 'Unknown host was not reported honestly after upgrade'
            Assert-True (Test-Path -LiteralPath (Join-Path $fixture '.codex/skills/ce-code-review/SKILL.md') -PathType Leaf) 'Codex discovery copy was not retained'
            $uninstall = Invoke-Manager $package $fixture 'Uninstall'; Require-Exit $uninstall
            $after = [IO.File]::ReadAllText($agentsPath)
            Assert-True ($after.Contains('outside-upgrade-cycle')) 'Outside AGENTS edit was lost during upgrade/uninstall'
            Assert-Sentinels $sentinels
            Remove-Fixture
        }
    }
    else {
        $records.Add([pscustomobject]@{ name = 'frozen-161-codex-upgrade-status-doctor-uninstall'; status = 'SKIP'; elapsedMs = 0; error = 'PreviousPackageRoot was not supplied' }) | Out-Null
    }

    Record-Case 'owned-file-drift-zero-write-refusal' {
        New-Fixture; Seed-Project
        $install = Invoke-Manager $package $fixture 'Install'; Require-Exit $install
        $driftPath = Join-Path $fixture 'docs/ai-collaboration/README.md'
        Assert-True (Test-Path -LiteralPath $driftPath -PathType Leaf) 'Owned drift fixture file is missing'
        [IO.File]::AppendAllText($driftPath, "owned-drift`r`n", $utf8)
        $before = Get-ProjectFingerprint
        $upgrade = Invoke-Manager $package $fixture 'Upgrade'
        Require-Exit $upgrade 1
        $after = Get-ProjectFingerprint
        Assert-Equal $after $before 'Owned-file drift refusal wrote to the project'
        Remove-Fixture
    }
    Remove-Fixture
    Write-PublicSummary 0
    exit 0
}
catch {
    $message = $_.Exception.Message
    try { Remove-Fixture } catch { $message += '; cleanup: ' + $_.Exception.Message }
    Write-PublicSummary 1 $message
    exit 1
}
