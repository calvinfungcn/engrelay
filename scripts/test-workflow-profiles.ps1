[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PackageRoot, [string]$OriginalRoot='', [string]$LogPath='', [switch]$RoundtripOnly)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$hostExe=(Get-Process -Id $PID).Path
$utf8=New-Object Text.UTF8Encoding($false,$true)
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('engrelay-profile-test-'+[guid]::NewGuid().ToString('N'))
$calls=New-Object 'Collections.Generic.List[object]'
$checks=New-Object 'Collections.Generic.List[string]'
$failed=New-Object 'Collections.Generic.List[string]'
$fingerprints=@{}
function Assert([bool]$Value,[string]$Message) { if (-not $Value) { throw $Message }; $checks.Add($Message) }
function New-Project([string]$Name) { $path=Join-Path $fixture $Name; $null=New-Item -ItemType Directory -Path $path; return $path }
function Write-Project([string]$Project,[string]$Relative,[string]$Text) {
    $path=Join-Path $Project $Relative; $null=New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force
    [IO.File]::WriteAllText($path,$Text,$utf8)
}
function Tree([string]$Project) {
    return (@(Get-ChildItem -LiteralPath $Project -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
        $_.FullName.Substring($Project.Length+1).Replace('\','/')+'|'+(Get-FileHash -LiteralPath $_.FullName).Hash
    }) -join "`n")
}
function Call([string]$Name,[string]$Project,[string[]]$Arguments,[bool]$Pass=$true,[bool]$ReadOnly=$false,[string]$Source=$PackageRoot,[string]$Diagnostic='') {
    $before=Tree $Project
    $argsList=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $Source 'scripts/manage.ps1'),'-ProjectRoot',$Project)+$Arguments
    try {
        $ErrorActionPreference='Continue' # Windows PowerShell wraps native stderr as ErrorRecord.
        $output=@(& $hostExe @argsList 2>&1 | ForEach-Object { [string]$_ }) -join "`n"
        $code=$LASTEXITCODE
    } finally { $ErrorActionPreference='Stop' }
    $after=Tree $Project
    $ok=(($code -eq 0) -eq $Pass) -and ((-not $ReadOnly) -or ($before -ceq $after)) -and ((-not $Diagnostic) -or $output.Contains($Diagnostic))
    $calls.Add([pscustomobject]@{name=$Name;host=$hostExe;arguments=$argsList;sourceSnapshot=(Get-FileHash -LiteralPath (Join-Path $Source 'snapshot.json')).Hash;exitCode=$code;output=$output;before=$before;after=$after;passed=$ok})
    if (-not $ok) { $failed.Add($Name); throw "FAIL $Name : exit $code : $output" }
}
function State([string]$Project) { return (Get-Content -LiteralPath (Join-Path $Project '.ai-collaboration-install/manifest.json') -Raw | ConvertFrom-Json) }
function Save-State([string]$Project,$Value) { Write-Project $Project '.ai-collaboration-install/manifest.json' ($Value | ConvertTo-Json -Depth 12) }
function Doctor([string]$Name,[string]$Project,[string]$Relative,[bool]$Pass=$true) {
    $before=Tree $Project
    $arguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $PackageRoot $Relative),'-WorkspaceRoot',$Project,'-PackageRoot',$PackageRoot)
    try {
        $ErrorActionPreference='Continue'
        $output=@(& $hostExe @arguments 2>&1 | ForEach-Object { [string]$_ }) -join "`n"; $code=$LASTEXITCODE
    } finally { $ErrorActionPreference='Stop' }
    $after=Tree $Project
    $ok=(($code -eq 0) -eq $Pass) -and ($before -ceq $after)
    $calls.Add([pscustomobject]@{name=$Name;host=$hostExe;arguments=$arguments;exitCode=$code;output=$output;before=$before;after=$after;passed=$ok})
    if (-not $ok) { $failed.Add($Name); throw "FAIL $Name : $output" }
}
function Test-ProfileRoundtrip {
    $project=New-Project 'roundtrip'
    Call 'CR-01 initial Lite install' $project @('-Action','Install','-WorkflowProfile','lite')
    Write-Project $project 'docs/engrelay-lite.config.md' 'Edited project config.'
    Write-Project $project '.ai/engrelay-lite/evidence.md' 'Retained runtime evidence.'
    [IO.File]::AppendAllText((Join-Path $project 'AGENTS.md'),"`nOutside managed block.",$utf8)
    $preserved=@{}
    foreach ($relative in @('docs/engrelay-lite.config.md','.ai/engrelay-lite/evidence.md')) {
        $preserved[$relative]=(Get-FileHash -LiteralPath (Join-Path $project $relative)).Hash
    }
    Call 'CR-01 Lite uninstall' $project @('-Action','Uninstall')
    $liteInactive=(Get-FileHash -LiteralPath (Join-Path $project '.ai-collaboration-install/manifest.json')).Hash
    Call 'CR-01 Full install' $project @('-Action','Install','-WorkflowProfile','full')
    Call 'CR-01 Full uninstall' $project @('-Action','Uninstall')
    $fullInactive=(Get-FileHash -LiteralPath (Join-Path $project '.ai-collaboration-install/manifest.json')).Hash
    Call 'CR-01 Lite reinstall after Full' $project @('-Action','Install','-WorkflowProfile','lite')
    Assert ((State $project).workflowProfile -ceq 'lite') 'CR-01 explicit Lite Full Lite roundtrip'
    foreach ($relative in $preserved.Keys) {
        Assert ((Get-FileHash -LiteralPath (Join-Path $project $relative)).Hash -ceq $preserved[$relative]) ('CR-01 roundtrip preserves '+$relative)
    }
    Assert (([IO.File]::ReadAllText((Join-Path $project 'AGENTS.md'))).Contains('Outside managed block.')) 'CR-01 roundtrip preserves outside text'
    $history=@(Get-ChildItem -LiteralPath (Join-Path $project '.ai-collaboration-install') -Filter 'manifest-inactive-*.json' -File | ForEach-Object { (Get-FileHash -LiteralPath $_.FullName).Hash })
    Assert ($history.Count -eq 2 -and $history -ccontains $liteInactive -and $history -ccontains $fullInactive) 'CR-01 retains both exact inactive recovery manifests'
    foreach ($kind in @('file','hidden-file','empty-directory','junction')) {
        $guard=New-Project ('roundtrip-guard-'+$kind)
        Call ('CR-01 guard install '+$kind) $guard @('-Action','Install','-WorkflowProfile','lite')
        $unknown=Join-Path $guard 'docs/engrelay-lite/unknown'
        $target=''
        try {
            if ($kind -eq 'empty-directory') { $null=New-Item -ItemType Directory -Path $unknown }
            elseif ($kind -eq 'junction') {
                $target=New-Project 'junction-target'
                Write-Project $target 'private.md' 'Outside Lite tree; preserve.'
                $targetBefore=Tree $target
                $null=New-Item -ItemType Junction -Path $unknown -Target $target
            } else {
                Write-Project $guard 'docs/engrelay-lite/unknown' 'Unknown private bytes.'
                if ($kind -eq 'hidden-file') { (Get-Item -LiteralPath $unknown).Attributes=[IO.FileAttributes]::Hidden }
                $unknownHash=(Get-FileHash -LiteralPath $unknown).Hash
            }
            Call ('CR-01 guard uninstall '+$kind) $guard @('-Action','Uninstall')
            Assert (Test-Path -LiteralPath $unknown) ('CR-01 uninstall preserves unknown '+$kind)
            if ($kind -in @('file','hidden-file')) { Assert ((Get-FileHash -LiteralPath $unknown).Hash -ceq $unknownHash) ('CR-01 unknown bytes preserved '+$kind) }
            Call ('CR-01 guard Full install '+$kind) $guard @('-Action','Install','-WorkflowProfile','full')
            Call ('CR-01 guard Full uninstall '+$kind) $guard @('-Action','Uninstall')
            Call ('CR-01 guard Lite refuses '+$kind) $guard @('-Action','Install','-WorkflowProfile','lite') $false $true $PackageRoot 'Unmanaged Lite directory'
            if ($target) { Assert ((Tree $target) -ceq $targetBefore) 'CR-01 junction target untouched' }
        } finally {
            if ($target -and (Test-Path -LiteralPath $unknown)) {
                if (-not ((Get-Item -LiteralPath $unknown -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Expected fixture junction' }
                [IO.Directory]::Delete($unknown) # Remove only this link, never its target.
            }
        }
    }
    $private=New-Project 'private-empty-lite'
    $null=New-Item -ItemType Directory -Path (Join-Path $private 'docs/engrelay-lite') -Force
    Call 'CR-01 private empty Lite directory refuses' $private @('-Action','Install','-WorkflowProfile','lite') $false $true $PackageRoot 'Unmanaged Lite directory'
    $private=New-Project 'private-known-lite'
    Write-Project $private 'docs/engrelay-lite/RULES.md' 'Private original.'
    Call 'CR-01 private Lite file refuses' $private @('-Action','Install','-WorkflowProfile','lite') $false $true $PackageRoot 'Unmanaged Lite directory'
    $linked=New-Project 'known-path-junction'
    Call 'CR-01 known-path install' $linked @('-Action','Install','-WorkflowProfile','lite')
    $link=Join-Path $linked 'docs/engrelay-lite/templates'
    $target=Join-Path $linked 'retained-templates'
    Move-Item -LiteralPath $link -Destination $target
    $null=New-Item -ItemType Junction -Path $link -Target $target
    try {
        Call 'CR-01 known-path reparse refuses before writes' $linked @('-Action','Uninstall') $false $true $PackageRoot 'Reparse point'
    } finally { [IO.Directory]::Delete($link) }
}
try {
    $null=New-Item -ItemType Directory -Path $fixture
    Test-ProfileRoundtrip
    if ($RoundtripOnly) { Write-Output "PASS: $($calls.Count) roundtrip calls; $($checks.Count) outcome checks."; return }
    $lite=New-Project 'lite'
    Call 'I02 Lite install' $lite @('-Action','Install','-WorkflowProfile','LiTe','-WorkflowMode','OpTiOnAl','-SkillTarget','NoNe')
    $s=State $lite
    $fingerprints['lite']=$s.deploymentFingerprint
    Assert ($s.version -eq 2 -and $s.workflowProfile -ceq 'lite') 'Lite manifest v2'
    Assert (-not (Test-Path (Join-Path $lite 'docs/ai-collaboration'))) 'Lite excludes Full'
    Assert (Test-Path (Join-Path $lite 'docs/engrelay-lite/RULES.md')) 'Lite rules installed'
    Call 'I05 repeated Lite' $lite @('-Action','Install') $true $true
    Call 'I04 unsupported target' (New-Project 'bad-target') @('-Action','Install','-WorkflowProfile','lite','-SkillTarget','agents') $false $true $PackageRoot 'none'
    Call 'Lite CheckVersion' $lite @('-Action','CheckVersion') $true $true $PackageRoot 'WorkflowProfile=lite'
    Call 'Lite Status' $lite @('-Action','Status') $true $true
    Doctor 'Lite doctor' $lite 'payload/docs/ai-collaboration/lite/scripts/doctor.ps1'
    Doctor 'Full doctor forwards Lite' $lite 'payload/docs/ai-collaboration/scripts/doctor.ps1'
    $config='Project-owned custom configuration.'
    Write-Project $lite 'docs/engrelay-lite.config.md' $config
    Write-Project $lite '.ai/engrelay-lite/retained-evidence.md' 'Runtime evidence must survive.'
    $agentsPath=Join-Path $lite 'AGENTS.md'
    [IO.File]::AppendAllText($agentsPath,"`nOutside managed block.",$utf8)
    foreach ($mode in @('default','disabled','optional')) {
        Call ('I05 SetMode '+$mode) $lite @('-Action','SetMode','-WorkflowMode',$mode)
        $s=State $lite
        Assert ($s.workflowProfile -ceq 'lite' -and $s.workflowMode -ceq $mode) ('Lite preserves profile in '+$mode)
    }
    Call 'I10 Lite upgrade preserves content' $lite @('-Action','Upgrade')
    Assert (([IO.File]::ReadAllText((Join-Path $lite 'docs/engrelay-lite.config.md'))) -ceq $config) 'Upgrade preserves edited config'
    Assert (([IO.File]::ReadAllText($agentsPath)).Contains('Outside managed block.')) 'Upgrade preserves block-external text'
    $pristine=State $lite
    $agentsBefore=[IO.File]::ReadAllBytes($agentsPath)
    [IO.File]::AppendAllText($agentsPath,"`n<!-- ai-collaboration:begin -->",$utf8)
    Call 'I11 duplicate managed marker' $lite @('-Action','Upgrade') $false $true
    [IO.File]::WriteAllBytes($agentsPath,$agentsBefore)
    $manifestText=[IO.File]::ReadAllText((Join-Path $lite '.ai-collaboration-install/manifest.json'))
    $mutations=@('profile','duplicate','missing-record','path','kind','set','fingerprint','backup','phase','missing')
    foreach ($mutation in $mutations) {
        $bad=$manifestText | ConvertFrom-Json
        switch ($mutation) {
            'profile' { $bad.workflowProfile='unknown' }
            'duplicate' { $bad.files=@($bad.files)+@($bad.files[0]) }
            'missing-record' { $bad.files=@($bad.files | Select-Object -Skip 1) }
            'path' { $bad.files[0].path='../outside.md' }
            'kind' { $bad.files[0].kind='project-document' }
            'set' { $bad.deploymentSet=@($bad.deploymentSet | Select-Object -Skip 1) }
            'fingerprint' { $bad.deploymentFingerprint='0'*64 }
            'backup' { $record=@($bad.files | Where-Object { $_.kind -eq 'agents' })[0]; $record.preexisting=$true; $record.backup='corrupt!' }
            'phase' { $bad.phase='upgrading' }
            'missing' { $bad.PSObject.Properties.Remove('workflowProfile') }
        }
        Save-State $lite $bad
        Call ('I11 malformed '+$mutation) $lite @('-Action','Upgrade') $false $true
        Write-Project $lite '.ai-collaboration-install/manifest.json' $manifestText
    }
    $rulesPath=Join-Path $lite 'docs/engrelay-lite/RULES.md'; $rulesBytes=[IO.File]::ReadAllBytes($rulesPath)
    [IO.File]::AppendAllText($rulesPath,"`nOwned drift.",$utf8)
    Call 'I11 ordinary file drift' $lite @('-Action','Upgrade') $false $true
    [IO.File]::WriteAllBytes($rulesPath,$rulesBytes)
    Remove-Item -LiteralPath (Join-Path $lite 'docs/engrelay-lite.config.md')
    Call 'Missing config not auto recreated' $lite @('-Action','Upgrade') $false $true
    Doctor 'Missing config diagnosed' $lite 'payload/docs/ai-collaboration/lite/scripts/doctor.ps1' $false
    Write-Project $lite 'docs/engrelay-lite.config.md' $config
    Call 'I06 explicit profile conflict Lite' $lite @('-Action','Upgrade','-WorkflowProfile','full') $false $true $PackageRoot 'WorkflowProfile conflict'
    Call 'Unsupported Preview refuses' $lite @('-Action','Upgrade','-Preview') $false $true
    $full=New-Project 'full'
    Write-Project $full 'AGENTS.md' 'Original Full project text.'
    Call 'I01 default Full' $full @('-Action','Install')
    $fs=State $full
    $fingerprints['full']=$fs.deploymentFingerprint
    Assert ($fs.version -eq 2 -and $fs.workflowProfile -ceq 'full' -and $fs.workflowMode -ceq 'optional' -and $fs.skillTarget -ceq 'none') 'Default Full optional none'
    Assert (-not (Test-Path (Join-Path $full 'docs/ai-collaboration/lite')) -and -not (Test-Path (Join-Path $full 'docs/engrelay-lite'))) 'Full excludes Lite sources'
    Call 'I06 repeated Install profile conflict' $full @('-Action','Install','-WorkflowProfile','lite') $false $true
    Call 'I06 Upgrade profile conflict' $full @('-Action','Upgrade','-WorkflowProfile','lite') $false $true
    Doctor 'Full doctor v2' $full 'payload/docs/ai-collaboration/scripts/doctor.ps1'
    $agents=New-Project 'agents'
    Call 'Full agents install' $agents @('-Action','Install','-SkillTarget','agents')
    Assert (Test-Path (Join-Path $agents '.agents/skills/ai-collab-start/SKILL.md')) 'Full agents discovery target'
    Call 'Full agents upgrade' $agents @('-Action','Upgrade')
    Call 'Full agents uninstall' $agents @('-Action','Uninstall')
    $preconfig=New-Project 'preconfig'
    Write-Project $preconfig 'docs/engrelay-lite.config.md' 'Existing project configuration.'
    Call 'I13 preexisting config' $preconfig @('-Action','Install','-WorkflowProfile','lite')
    Assert (([IO.File]::ReadAllText((Join-Path $preconfig 'docs/engrelay-lite.config.md'))) -ceq 'Existing project configuration.') 'Existing config preserved'
    Call 'I13 uninstall keeps config' $preconfig @('-Action','Uninstall')
    Call 'Reinstall inactive Lite preserves profile' $preconfig @('-Action','Install')
    Assert ((State $preconfig).workflowProfile -ceq 'lite') 'Inactive Lite remains Lite when omitted'
    Call 'Uninstall before explicit switch' $preconfig @('-Action','Uninstall')
    Call 'Explicit inactive Lite to Full switch' $preconfig @('-Action','Install','-WorkflowProfile','full','-SkillTarget','none')
    Assert ((State $preconfig).workflowProfile -ceq 'full' -and (Test-Path (Join-Path $preconfig 'docs/engrelay-lite.config.md'))) 'Protected switch preserves project config'
    $private=New-Project 'private'
    Write-Project $private 'docs/engrelay-lite/RULES.md' 'Private original.'
    Call 'I12 private Lite Install refusal' $private @('-Action','Install','-WorkflowProfile','lite') $false $true
    Call 'I12 private Lite Adopt refusal' $private @('-Action','Adopt','-WorkflowProfile','lite') $false $true
    $entry=New-Project 'private-entry'; Write-Project $entry 'AGENTS.md' 'Read docs/engrelay-lite/RULES.md for the private workflow.'
    Call 'I12 private Lite entry refusal' $entry @('-Action','Install','-WorkflowProfile','lite') $false $true
    $conflict=New-Project 'new-target-conflict'
    Write-Project $conflict 'docs/ai-collaboration/README.md' 'Project-owned conflicting target.'
    Call 'I11 new differing target refusal' $conflict @('-Action','Install') $false $true
    $directory=New-Project 'config-directory'; $null=New-Item -ItemType Directory -Path (Join-Path $directory 'docs/engrelay-lite.config.md') -Force
    Call 'I13 config directory refuses' $directory @('-Action','Install','-WorkflowProfile','lite') $false $true
    foreach ($profile in @('full','lite')) {
        $missing=New-Project ('missing-'+$profile)
        $sourceFile=if ($profile -eq 'lite') { 'payload/docs/ai-collaboration/agent-prompts.md' } else { 'payload/docs/ai-collaboration/lite/RULES.md' }
        $sourcePath=Join-Path $PackageRoot $sourceFile; $sourceBytes=[IO.File]::ReadAllBytes($sourcePath)
        try {
            Remove-Item -LiteralPath $sourcePath
            Call ('I03 missing unselected source '+$profile) $missing @('-Action','Install','-WorkflowProfile',$profile) $false $true $PackageRoot 'Snapshot file missing'
        } finally { [IO.File]::WriteAllBytes($sourcePath,$sourceBytes) }
    }
    if ($OriginalRoot) {
        foreach ($project in @($lite,$full)) {
            Call 'I09 actual old reader refuses v2' $project @('-Action','Uninstall') $false $true $OriginalRoot 'Invalid, moved or interrupted'
        }
        $old=New-Project 'old'
        Write-Project $old 'AGENTS.md' 'Preserved original project.'
        Call 'I07 original v1 Install' $old @('-Action','Install','-SkillTarget','agents','-WorkflowMode','default') $true $false $OriginalRoot
        $v1=State $old; $originalBackup=@($v1.files | Where-Object { $_.path -eq 'AGENTS.md' })[0].backup
        Assert ($v1.version -eq 1) 'Original manager really produces v1'
        Call 'v1 Status does not convert' $old @('-Action','Status') $true $true
        $bad=State $old; $bad.deploymentFingerprint='f'*64; Save-State $old $bad
        Call 'I08 fake v1 fingerprint refuses' $old @('-Action','Upgrade') $false $true
        Save-State $old $v1
        Call 'I07 original v1 Upgrade' $old @('-Action','Upgrade')
        $converted=State $old
        Assert ($converted.version -eq 2 -and $converted.workflowProfile -ceq 'full' -and $converted.workflowMode -ceq 'default' -and $converted.skillTarget -ceq 'agents') 'Trusted v1 converted with mode target preserved'
        Assert (@($converted.files | Where-Object { $_.path -eq 'AGENTS.md' })[0].backup -ceq $originalBackup) 'Original backup retained across v1 conversion'
        Assert ($converted.legacyDeploymentFingerprint -ceq $v1.deploymentFingerprint) 'Original fingerprint retained'
        Call 'I07 converted uninstall' $old @('-Action','Uninstall')
        Assert (([IO.File]::ReadAllText((Join-Path $old 'AGENTS.md'))) -ceq 'Preserved original project.') 'Converted uninstall preserves original project'
    }
    Call 'I10 Lite uninstall' $lite @('-Action','Uninstall')
    Assert (([IO.File]::ReadAllText((Join-Path $lite 'docs/engrelay-lite.config.md'))) -ceq $config) 'Uninstall preserves config'
    Assert (Test-Path (Join-Path $lite '.ai/engrelay-lite/retained-evidence.md')) 'Uninstall preserves runtime evidence'
    Assert (([IO.File]::ReadAllText($agentsPath)).Contains('Outside managed block.')) 'Uninstall preserves later outside text'
    Call 'Inactive uninstall idempotent' $lite @('-Action','Uninstall') $true $true
    if ($OriginalRoot) { Call 'I16 old reader refuses retained inactive v2' $lite @('-Action','Install') $false $true $OriginalRoot }
    $interrupted=New-Project 'interrupted'
    Write-Project $interrupted 'AGENTS.md' 'Read-only project entry.'
    $readonly=Get-Item -LiteralPath (Join-Path $interrupted 'AGENTS.md'); $readonly.IsReadOnly=$true
    try {
        Call 'I15 actual write interruption' $interrupted @('-Action','Install','-WorkflowProfile','lite') $false $false
        $interruptedState=State $interrupted
        Assert ($interruptedState.phase -ceq 'installing') 'Interrupted install retains phase and original recovery backup'
        Assert (@($interruptedState.files | Where-Object { $_.path -ceq 'AGENTS.md' })[0].backup -ne '') 'Interrupted install retains project bytes'
        Call 'I15 interrupted state refuses retry' $interrupted @('-Action','Install') $false $true
    } finally { (Get-Item -LiteralPath $readonly.FullName).IsReadOnly=$false }
    # Exercise the supported catalogue branch with a declared synthetic source,
    # not a real project's private historical bytes or an expanded production catalogue.
    $adoptPackage=Join-Path $fixture 'synthetic-adopt-package'
    Copy-Item -LiteralPath $PackageRoot -Destination $adoptPackage -Recurse
    $adopt=New-Project 'synthetic-adopt-project'
    $canonical='docs/ai-collaboration/README.md'
    $canonicalSource=Join-Path $adoptPackage ('payload/'+$canonical)
    Write-Project $adopt $canonical ([IO.File]::ReadAllText($canonicalSource,$utf8))
    $catalogue=@{schemaVersion=1;profiles=@(@{id='fixture-known-profile';canonical=@(@{path=$canonical;hash=(Get-FileHash -LiteralPath (Join-Path $adopt $canonical)).Hash.ToLowerInvariant()});legacyEntries=@();legacyEntryChanges=@();projectDocuments=@()})}
    Write-Project $adoptPackage 'payload/docs/ai-collaboration/legacy-adoption.json' ($catalogue | ConvertTo-Json -Depth 8)
    & (Join-Path $adoptPackage 'scripts/update-snapshot.ps1') -PackageRoot $adoptPackage -Version '9.0.0' -ForRelease | Out-Null
    Call 'I14 supported synthetic Adopt Preview' $adopt @('-Action','Adopt','-Preview') $true $true $adoptPackage 'no files written'
    Call 'Supported synthetic Adopt' $adopt @('-Action','Adopt') $true $false $adoptPackage
    Assert ((State $adopt).version -eq 2 -and (State $adopt).workflowProfile -ceq 'full') 'Adopt remains Full and writes v2'
    Call 'Synthetic adopted Status' $adopt @('-Action','Status') $true $true $adoptPackage
    Call 'Synthetic adopted Uninstall' $adopt @('-Action','Uninstall') $true $false $adoptPackage
} finally {
    if ($LogPath) {
        $path=[IO.Path]::GetFullPath($LogPath); $null=New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force
        if ($path.StartsWith($fixture+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'LogPath inside disposable fixture' }
        [IO.File]::WriteAllText($path,([ordered]@{hostVersion=$PSVersionTable.PSVersion.ToString();testScriptHash=(Get-FileHash -LiteralPath $PSCommandPath).Hash;packageSnapshot=(Get-FileHash (Join-Path $PackageRoot 'snapshot.json')).Hash;deploymentFingerprints=$fingerprints;calls=$calls.ToArray();checks=$checks.ToArray();failures=$failed.ToArray()} | ConvertTo-Json -Depth 8),$utf8)
    }
    $resolved=[IO.Path]::GetFullPath($fixture); $temp=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
    if ((Split-Path -Parent $resolved) -ne $temp -or (Split-Path -Leaf $resolved) -notmatch '^engrelay-profile-test-[a-f0-9]{32}$') { throw 'Unsafe cleanup' }
    if (@(Get-ChildItem -LiteralPath $resolved -Recurse -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) { throw 'Unsafe fixture tree; retained' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
Write-Output "PASS: $($calls.Count) profile calls; $($checks.Count) outcome checks."
