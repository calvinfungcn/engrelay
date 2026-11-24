[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$WorkspaceRoot,[string]$PackageRoot='',[Alias('Host')][string]$HostTarget='')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$utf8=New-Object Text.UTF8Encoding($false,$true)
$root=[IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\','/')
$targets=@{agents='.agents';codex='.codex';claude='.claude';cursor='.cursor';opencode='.opencode';antigravity='.agent';gemini='.gemini';iflow='.iflow';qwen='.qwen'}
function Safe-Path([string]$Base,[string]$Relative) {
    if ([string]::IsNullOrWhiteSpace($Relative) -or $Relative -match '[:\\]' -or $Relative.StartsWith('/') -or $Relative -match '(^|/)\.\.?(/|$)') { throw 'Unsafe diagnostic path' }
    $full=[IO.Path]::GetFullPath((Join-Path $Base $Relative)); $cursor=$full
    if (-not $full.StartsWith($Base+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Diagnostic path escaped root' }
    while ($cursor) {
        if ((Test-Path -LiteralPath $cursor) -and ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Reparse point in diagnostic input; not followed' }
        $parent=Split-Path -Parent $cursor; if ($parent -eq $cursor) { break }; $cursor=$parent
    }
    return $full
}
function Read-Text([string]$Path) { return $utf8.GetString([IO.File]::ReadAllBytes($Path)).TrimStart([char]0xfeff) }
function Get-LineCount([string]$Path) {
    $text=Read-Text $Path
    if ([string]::IsNullOrEmpty($text)) { return 0 }
    $trimmed=[regex]::Replace($text,'\r?\n\z','')
    return @($trimmed -split "`r?`n").Count
}
try {
    $manifest=Safe-Path $root '.ai-collaboration-install/manifest.json'
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw 'WorkspaceRoot must exist' }
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        Write-Output 'EngRelay v2 doctor: not installed; host loading=unknown; no files written.'; exit 0
    }
    $state=(Read-Text $manifest) | ConvertFrom-Json
    if ($state.version -ne 2 -or $state.workflowProfile -cne 'v2' -or $state.projectRoot -ne $root -or
        ($state.skillTarget -cne 'none' -and -not $targets.ContainsKey([string]$state.skillTarget)) -or
        $state.workflowMode -cnotin @('optional','default','disabled')) {
        throw 'Invalid or mismatched v2 manifest; retain state and use the matching manager'
    }
    if ($state.phase -eq 'inactive') { Write-Output 'WorkflowProfile=v2; inactive; host loading=unknown; no files written.'; exit 0 }
    if ($state.phase -cne 'installed') { throw "Interrupted installation phase=$($state.phase); retain manifest backups and upgrade-files recovery material" }
    $expected=@{'AGENTS.md'='agents';'.gitignore'='gitignore';'docs/engrelay.config.md'='project-document'}
    foreach ($file in @('RULES.md','README.md','README.zh-CN.md','LICENSE','skills/engrelay/SKILL.md','templates/board.md','templates/wp.md','templates/project-config.md','scripts/doctor.ps1')) {
        $expected['docs/engrelay/'+$file]='file'
    }
    if ($state.skillTarget -cne 'none') {
        $expected[$targets[[string]$state.skillTarget]+'/skills/engrelay/SKILL.md']='file'
    }
    $seen=@{}
    foreach ($record in $state.files) {
        if (-not $expected.ContainsKey([string]$record.path) -or $seen.ContainsKey([string]$record.path) -or $record.kind -cne $expected[$record.path] -or $record.preexisting -isnot [bool] -or $record.hash -cnotmatch '^[a-f0-9]{64}$') {
            throw 'Invalid v2 ownership record'
        }
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
                [regex]::Matches($text,'<!-- ai-collaboration:begin -->').Count -ne 1 -or [regex]::Matches($text,'<!-- ai-collaboration:end -->').Count -ne 1) {
                throw "Managed block drifted: $($record.path)"
            }
            if ($record.kind -eq 'agents' -and ($record.insertion -notmatch '(?m)^- WorkflowProfile: v2\r?$' -or $record.insertion -notmatch ('(?m)^- WorkflowMode: '+$state.workflowMode+'\r?$'))) {
                throw 'Activation declaration conflicts with manifest'
            }
        }
    }
    if ($seen.Count -ne $expected.Count) { throw 'Incomplete v2 ownership set' }
    $rulesLines=Get-LineCount (Safe-Path $root 'docs/engrelay/RULES.md')
    $skillLines=Get-LineCount (Safe-Path $root 'docs/engrelay/skills/engrelay/SKILL.md')
    $totalLines=$rulesLines+$skillLines
    if ($totalLines -gt 150) { throw "Core v2 protocol exceeds 150-line budget: $totalLines lines" }
    if ($PackageRoot) {
        $package=[IO.Path]::GetFullPath($PackageRoot).TrimEnd('\','/')
        $manager=Safe-Path $package 'scripts/manage.ps1'
        & $manager -Action CheckVersion -ProjectRoot $root
        Write-Output 'Source/manifest checked by the supplied package manager.'
    } else { Write-Output 'Source integrity and deployment fingerprint=unknown; no PackageRoot supplied.' }
    $relayRoot=Safe-Path $root '.ai/relay'
    if (Test-Path -LiteralPath $relayRoot -PathType Container) {
        $boards=@(Get-ChildItem -LiteralPath $relayRoot -Filter 'board.md' -Recurse -File)
        foreach ($b in $boards) { $null=Safe-Path $root ($b.FullName.Substring($root.Length+1).Replace('\','/')) }
        Write-Output "Runtime relay boards found=$($boards.Count); read-only inspected."
    } else { Write-Output 'No live v2 relay board; installation does not create one.' }
    Write-Output "WorkflowProfile=v2; packageVersion=$($state.packageVersion); WorkflowMode=$($state.workflowMode); SkillTarget=$($state.skillTarget); coreLines=$totalLines/150; host loading=unknown; no files written."
    exit 0
} catch { Write-Output ('ERROR: '+$_.Exception.Message); exit 1 }
