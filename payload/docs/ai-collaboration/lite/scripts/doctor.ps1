[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$WorkspaceRoot,[string]$PackageRoot='',[Alias('Host')][string]$HostTarget='')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$utf8=New-Object Text.UTF8Encoding($false,$true)
$root=[IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\','/')
function Safe-Path([string]$Base,[string]$Relative) {
    if ($Relative -match '[:\\]' -or $Relative.StartsWith('/') -or $Relative -match '(^|/)\.\.?(/|$)') { throw 'Unsafe diagnostic path' }
    $full=[IO.Path]::GetFullPath((Join-Path $Base $Relative)); $cursor=$full
    if (-not $full.StartsWith($Base+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Diagnostic path escaped root' }
    while ($cursor) {
        if ((Test-Path -LiteralPath $cursor) -and ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Reparse point in diagnostic input; not followed' }
        $parent=Split-Path -Parent $cursor; if ($parent -eq $cursor) { break }; $cursor=$parent
    }
    return $full
}
function Read-Text([string]$Path) { return $utf8.GetString([IO.File]::ReadAllBytes($Path)).TrimStart([char]0xfeff) }
try {
    $manifest=Safe-Path $root '.ai-collaboration-install/manifest.json'
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw 'WorkspaceRoot must exist' }
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        Write-Output 'EngRelay Lite doctor: not installed; host loading=unknown; no files written.'; exit 0
    }
    $state=(Read-Text $manifest) | ConvertFrom-Json
    if ($state.version -ne 2 -or $state.workflowProfile -cne 'lite' -or $state.projectRoot -ne $root -or $state.skillTarget -cne 'none' -or $state.workflowMode -cnotin @('optional','default','disabled')) { throw 'Invalid or mismatched Lite manifest; retain state and use the matching manager' }
    if ($state.phase -eq 'inactive') { Write-Output 'WorkflowProfile=lite; inactive; host loading=unknown; no files written.'; exit 0 }
    if ($state.phase -cne 'installed') { throw "Interrupted installation phase=$($state.phase); retain manifest backups and upgrade-files recovery material" }
    $expected=@{'AGENTS.md'='agents';'.gitignore'='gitignore';'docs/engrelay-lite.config.md'='project-document'}
    foreach ($file in @('RULES.md','README.md','README.zh-CN.md','LICENSE','templates/project-config.md','templates/queue.md','templates/task.md','templates/handoff.md','scripts/validate-state.ps1','scripts/doctor.ps1')) { $expected['docs/engrelay-lite/'+$file]='file' }
    $seen=@{}
    foreach ($record in $state.files) {
        if (-not $expected.ContainsKey([string]$record.path) -or $seen.ContainsKey([string]$record.path) -or $record.kind -cne $expected[$record.path] -or $record.preexisting -isnot [bool] -or $record.hash -cnotmatch '^[a-f0-9]{64}$') { throw 'Invalid Lite ownership record' }
        $seen[$record.path]=$true; $path=Safe-Path $root $record.path
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Installed file missing: $($record.path); project configuration must be restored deliberately, not auto-created" }
        if ($record.kind -eq 'project-document') { continue }
        if ($record.preexisting) {
            $backup=[Convert]::FromBase64String($record.backup)
            $sha=[Security.Cryptography.SHA256]::Create()
            try { $hash=([BitConverter]::ToString($sha.ComputeHash($backup))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
            if ($hash -cne $record.beforeHash) { throw 'Corrupt original backup' }
        }
        if ($record.kind -eq 'file') {
            if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $record.hash) { throw "Modified installed file: $($record.path)" }
        } else {
            $text=Read-Text $path
            if ([string]::IsNullOrEmpty($record.insertion) -or -not $text.Contains($record.insertion) -or
                [regex]::Matches($text,'<!-- ai-collaboration:begin -->').Count -ne 1 -or [regex]::Matches($text,'<!-- ai-collaboration:end -->').Count -ne 1) { throw "Managed block drifted: $($record.path)" }
            if ($record.kind -eq 'agents' -and ($record.insertion -notmatch '(?m)^- WorkflowProfile: lite\r?$' -or $record.insertion -notmatch ('(?m)^- WorkflowMode: '+$state.workflowMode+'\r?$'))) { throw 'Activation declaration conflicts with manifest' }
        }
    }
    if ($seen.Count -ne $expected.Count) { throw 'Incomplete Lite ownership set' }
    if ($PackageRoot) {
        $package=[IO.Path]::GetFullPath($PackageRoot).TrimEnd('\','/')
        $manager=Safe-Path $package 'scripts/manage.ps1'
        # Invoke only an explicitly supplied local manager, for its read-only complete
        # inventory and strict manifest checks. No installed script is auto-executed.
        & $manager -Action CheckVersion -ProjectRoot $root
        Write-Output 'Source/manifest checked by the supplied package manager.'
    } else { Write-Output 'Source integrity and deployment fingerprint=unknown; no PackageRoot supplied.' }
    $handoff=Safe-Path $root '.ai/engrelay-lite/handoff.md'
    if (Test-Path -LiteralPath $handoff -PathType Leaf) { Write-Output 'Runtime handoff present; inspect the named task and validate explicitly. No routing applied.' }
    else { Write-Output 'No live Lite task; installation does not create one.' }
    Write-Output "WorkflowProfile=lite; packageVersion=$($state.packageVersion); WorkflowMode=$($state.workflowMode); ownership files checked; Full absence expected; host loading=unknown; no files written."
    exit 0
} catch { Write-Output ('ERROR: '+$_.Exception.Message); exit 1 }
