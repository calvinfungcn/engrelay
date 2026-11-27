[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PackageRoot, [string]$LogPath='')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$hostExe=(Get-Process -Id $PID).Path
$utf8=New-Object Text.UTF8Encoding($false,$true)
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('engrelay-v2-test-'+[guid]::NewGuid().ToString('N'))
$calls=New-Object 'Collections.Generic.List[object]'
$checks=New-Object 'Collections.Generic.List[string]'
$failed=New-Object 'Collections.Generic.List[string]'
function Assert([bool]$Value,[string]$Message) { if (-not $Value) { throw $Message }; $checks.Add($Message) }
function New-Project([string]$Name) { $path=Join-Path $fixture $Name; $null=New-Item -ItemType Directory -Path $path -Force; return $path }
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
        $ErrorActionPreference='Continue'
        $output=@(& $hostExe @argsList 2>&1 | ForEach-Object { [string]$_ }) -join "`n"
        $code=$LASTEXITCODE
    } finally { $ErrorActionPreference='Stop' }
    $after=Tree $Project
    $ok=(($code -eq 0) -eq $Pass) -and ((-not $ReadOnly) -or ($before -ceq $after)) -and ((-not $Diagnostic) -or $output.Contains($Diagnostic))
    $calls.Add([pscustomobject]@{name=$Name;host=$hostExe;arguments=$argsList;exitCode=$code;output=$output;passed=$ok})
    if (-not $ok) { $failed.Add($Name); throw "FAIL $Name : exit $code : $output" }
    return $output
}
function Doctor([string]$Name,[string]$Project,[string]$Relative,[bool]$Pass=$true,[string]$Source=$PackageRoot,[string]$Diagnostic='') {
    $before=Tree $Project
    $arguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $Source $Relative),'-WorkspaceRoot',$Project,'-PackageRoot',$Source)
    try {
        $ErrorActionPreference='Continue'
        $output=@(& $hostExe @arguments 2>&1 | ForEach-Object { [string]$_ }) -join "`n"; $code=$LASTEXITCODE
    } finally { $ErrorActionPreference='Stop' }
    $after=Tree $Project
    $ok=(($code -eq 0) -eq $Pass) -and ($before -ceq $after) -and ((-not $Diagnostic) -or $output.Contains($Diagnostic))
    $calls.Add([pscustomobject]@{name=$Name;host=$hostExe;arguments=$arguments;exitCode=$code;output=$output;passed=$ok})
    if (-not $ok) { $failed.Add($Name); throw "FAIL $Name : exit $code : $output" }
    return $output
}
function State([string]$Project) { return (Get-Content -LiteralPath (Join-Path $Project '.ai-collaboration-install/manifest.json') -Raw | ConvertFrom-Json) }
try {
    $null=New-Item -ItemType Directory -Path $fixture -Force

    # 1. Hard line-count budgets on package source
    $rulesLines=@((Get-Content -LiteralPath (Join-Path $PackageRoot 'payload/docs/ai-collaboration/v2/RULES.md'))).Count
    $skillLines=@((Get-Content -LiteralPath (Join-Path $PackageRoot 'payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md'))).Count
    $agentLines=@((Get-Content -LiteralPath (Join-Path $PackageRoot 'payload/docs/ai-collaboration/v2/agent-rules.md'))).Count
    Assert (($rulesLines+$skillLines) -le 150) "v2 RULES+SKILL line budget <= 150 (actual $($rulesLines+$skillLines))"
    Assert ($agentLines -le 18) "v2 agent-rules line budget <= 18 (actual $agentLines)"

    # 2. Default Install selects v2, optional, none
    $v2=New-Project 'default-v2'
    Write-Project $v2 'AGENTS.md' 'Original project rules.'
    $out=Call 'V2-01 default install' $v2 @('-Action','Install')
    Assert ($out.Contains('WorkflowProfile: v2')) 'Default install emits v2 guidance'
    $s=State $v2
    Assert ($s.version -eq 2 -and $s.workflowProfile -ceq 'v2' -and $s.workflowMode -ceq 'optional' -and $s.skillTarget -ceq 'none') 'Default install manifest is v2/optional/none'
    Assert (Test-Path -LiteralPath (Join-Path $v2 'docs/engrelay/RULES.md') -PathType Leaf) 'v2 RULES.md deployed'
    Assert (Test-Path -LiteralPath (Join-Path $v2 'docs/engrelay/skills/engrelay/SKILL.md') -PathType Leaf) 'v2 SKILL.md deployed'
    Assert (Test-Path -LiteralPath (Join-Path $v2 'docs/engrelay.config.md') -PathType Leaf) 'v2 project config deployed'
    Assert (-not (Test-Path -LiteralPath (Join-Path $v2 'docs/ai-collaboration'))) 'v2 excludes Full'
    Assert (-not (Test-Path -LiteralPath (Join-Path $v2 'docs/engrelay-lite'))) 'v2 excludes Lite'

    # 3. Read-only doctor & Full doctor forwarding
    $docOut=Doctor 'V2-02 doctor none' $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $true $PackageRoot 'WorkflowProfile=v2'
    Assert ($docOut.Contains('coreLines=')) 'Doctor reports core line budget'
    $null=Doctor 'V2-03 Full doctor forwards v2' $v2 'payload/docs/ai-collaboration/scripts/doctor.ps1' $true $PackageRoot 'WorkflowProfile=v2'

    # 4. Runtime & config preservation across SetMode, Upgrade, Uninstall
    $cfg='Custom v2 build and quota calibration.'
    Write-Project $v2 'docs/engrelay.config.md' $cfg
    Write-Project $v2 '.ai/relay/demo-change/board.md' '# Relay Board: demo-change'
    Write-Project $v2 '.ai/relay/demo-change/wp-01.md' '# WP-01'
    [IO.File]::AppendAllText((Join-Path $v2 'AGENTS.md'),"`nProject custom rule.",$utf8)
    foreach ($mode in @('default','disabled','optional')) {
        $null=Call ('V2-04 SetMode '+$mode) $v2 @('-Action','SetMode','-WorkflowMode',$mode)
        Assert ((State $v2).workflowProfile -ceq 'v2' -and (State $v2).workflowMode -ceq $mode) ('SetMode preserves v2 in '+$mode)
    }
    $null=Call 'V2-05 Upgrade preserves config and runtime' $v2 @('-Action','Upgrade')
    Assert (([IO.File]::ReadAllText((Join-Path $v2 'docs/engrelay.config.md'))) -ceq $cfg) 'Upgrade preserves docs/engrelay.config.md'
    Assert (([IO.File]::ReadAllText((Join-Path $v2 'AGENTS.md'))).Contains('Project custom rule.')) 'Upgrade preserves AGENTS outside text'
    Assert (Test-Path -LiteralPath (Join-Path $v2 '.ai/relay/demo-change/board.md') -PathType Leaf) 'Upgrade preserves .ai/relay runtime'

    # 4b. CURRENT pointer: valid, stale, illegal or traversal; doctor stays zero-write
    $currentPath=Join-Path $v2 '.ai/relay/CURRENT'
    Write-Project $v2 '.ai/relay/CURRENT' "  demo-change`n"
    $validOut=Doctor 'V2-15 CURRENT valid' $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $true $PackageRoot 'Active relay change=demo-change (valid)'
    Assert ($validOut.Contains('no files written')) 'Valid CURRENT doctor reports no files written'
    Write-Project $v2 '.ai/relay/CURRENT' "archived-change`r`n"
    $staleBytes=[IO.File]::ReadAllBytes($currentPath)
    $staleOut=Doctor 'V2-16 CURRENT stale' $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $true $PackageRoot 'Active relay pointer stale: archived-change (board.md missing)'
    Assert ($staleOut.Contains('no files written')) 'Stale CURRENT doctor reports no files written'
    Assert ([Linq.Enumerable]::SequenceEqual($staleBytes,[IO.File]::ReadAllBytes($currentPath))) 'Stale CURRENT bytes unchanged'
    $badCases=@(
        @{ name='space'; text='not valid' },
        @{ name='slash'; text='foo/bar' },
        @{ name='traversal'; text='..\..\outside' },
        @{ name='dotdot'; text='a..b' },
        @{ name='empty'; text='' }
    )
    foreach ($bad in $badCases) {
        Write-Project $v2 '.ai/relay/CURRENT' $bad.text
        $beforeHash=(Get-FileHash -LiteralPath $currentPath -Algorithm SHA256).Hash
        $null=Doctor ('V2-17 CURRENT reject '+$bad.name) $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $false $PackageRoot 'Invalid relay CURRENT pointer'
        Assert ((Get-FileHash -LiteralPath $currentPath -Algorithm SHA256).Hash -ceq $beforeHash) ('Rejected CURRENT is not rewritten ('+$bad.name+')')
    }
    Remove-Item -LiteralPath $currentPath
    $absentOut=Doctor 'V2-17b CURRENT absent' $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $true $PackageRoot 'Runtime relay boards found='
    Assert (-not $absentOut.Contains('Active relay')) 'Absent CURRENT adds no active-pointer diagnostic'
    Assert (-not (Test-Path -LiteralPath $currentPath)) 'Absent CURRENT is not created'
    $reparseProj=New-Project 'current-reparse'
    Write-Project $reparseProj 'AGENTS.md' 'Original project rules.'
    $null=Call 'V2-18 reparse install' $reparseProj @('-Action','Install')
    $outside=Join-Path $fixture 'reparse-outside'
    $null=New-Item -ItemType Directory -Path $outside -Force
    $null=New-Item -ItemType Directory -Path (Join-Path $reparseProj '.ai') -Force
    $relayLink=Join-Path $reparseProj '.ai\relay'
    New-Item -ItemType Junction -Path $relayLink -Target $outside | Out-Null
    try {
        [IO.File]::WriteAllText((Join-Path $outside 'CURRENT'),"demo-change`n",$utf8)
        $null=Doctor 'V2-18 CURRENT reparse' $reparseProj 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $false $PackageRoot 'Reparse point in diagnostic input'
    } finally {
        if (Test-Path -LiteralPath $relayLink) { [IO.Directory]::Delete($relayLink, $false) }
    }

    # 4c. Pre-plan change-review pointer: valid without board.md, stale without anchor, reparse-point rejection
    $doctorRel='payload/docs/ai-collaboration/v2/scripts/doctor.ps1'
    $reviewProj=New-Project 'change-review-pointer'
    Write-Project $reviewProj 'AGENTS.md' 'Original project rules.'
    $null=Call 'V2-19 change-review install' $reviewProj @('-Action','Install')
    Write-Project $reviewProj 'openspec/changes/pre-plan/proposal.md' '# Proposal pre-plan'
    Write-Project $reviewProj '.ai/relay/pre-plan/review-proposal.md' '# Review proposal'
    Write-Project $reviewProj '.ai/relay/CURRENT' "pre-plan`n"
    $preOut=Doctor 'V2-19 pre-plan proposal pointer' $reviewProj $doctorRel $true $PackageRoot 'Active relay change=pre-plan (valid: change review, no board yet)'
    Assert ($preOut.Contains('Change review reports found=1')) 'Doctor counts pre-plan review report read-only'
    Write-Project $reviewProj 'openspec/changes/pre-review/tasks.md' '# Tasks pre-review'
    Write-Project $reviewProj '.ai/relay/pre-review/review-change.md' '# Review change'
    Write-Project $reviewProj '.ai/relay/CURRENT' "pre-review`n"
    $null=Doctor 'V2-19 pre-review change pointer' $reviewProj $doctorRel $true $PackageRoot 'Active relay change=pre-review (valid: change review, no board yet)'
    Write-Project $reviewProj '.ai/relay/ghost-change/review-proposal.md' '# Orphan report'
    Write-Project $reviewProj '.ai/relay/CURRENT' "ghost-change`n"
    $ghostOut=Doctor 'V2-19 missing anchor is stale' $reviewProj $doctorRel $true $PackageRoot 'Active relay pointer stale: ghost-change (board.md missing)'
    Assert (-not $ghostOut.Contains('Active relay change=ghost-change')) 'Missing openspec anchor is not reported active'
    Write-Project $reviewProj 'openspec/changes/no-report/proposal.md' '# No report yet'
    Write-Project $reviewProj '.ai/relay/CURRENT' "no-report`n"
    $null=Doctor 'V2-19 anchor without report is stale' $reviewProj $doctorRel $true $PackageRoot 'Active relay pointer stale: no-report (board.md missing)'
    Write-Project $reviewProj 'openspec/changes/archive/old/proposal.md' '# Archived'
    Write-Project $reviewProj '.ai/relay/archive/review-change.md' '# Archived review'
    Write-Project $reviewProj '.ai/relay/CURRENT' "archive`n"
    $null=Doctor 'V2-19 archive id is never active' $reviewProj $doctorRel $true $PackageRoot 'Active relay pointer stale: archive (board.md missing)'
    $anchorOutside=Join-Path $fixture 'anchor-outside'
    $null=New-Item -ItemType Directory -Path $anchorOutside -Force
    $anchorLink=Join-Path $reviewProj 'openspec\changes\linked-change'
    New-Item -ItemType Junction -Path $anchorLink -Target $anchorOutside | Out-Null
    Write-Project $reviewProj '.ai/relay/linked-change/review-change.md' '# Linked review'
    Write-Project $reviewProj '.ai/relay/CURRENT' "linked-change`n"
    try {
        $null=Doctor 'V2-20 openspec anchor junction rejected' $reviewProj $doctorRel $false $PackageRoot 'Reparse point in diagnostic input'
    } finally {
        if (Test-Path -LiteralPath $anchorLink) { [IO.Directory]::Delete($anchorLink, $false) }
    }
    $reviewOutside=Join-Path $fixture 'review-outside'
    $null=New-Item -ItemType Directory -Path $reviewOutside -Force
    [IO.File]::WriteAllText((Join-Path $reviewOutside 'review-proposal.md'),'# Outside review',$utf8)
    Write-Project $reviewProj 'openspec/changes/file-link/proposal.md' '# File link'
    $reviewDirLink=Join-Path $reviewProj '.ai\relay\file-link'
    New-Item -ItemType Junction -Path $reviewDirLink -Target $reviewOutside | Out-Null
    Write-Project $reviewProj '.ai/relay/CURRENT' "file-link`n"
    try {
        $null=Doctor 'V2-20 review report path junction rejected' $reviewProj $doctorRel $false $PackageRoot 'Reparse point in diagnostic input'
    } finally {
        if (Test-Path -LiteralPath $reviewDirLink) { [IO.Directory]::Delete($reviewDirLink, $false) }
    }
    # V2-21: a junction that is not the CURRENT target must still stop the report scan (no CURRENT-branch masking)
    $linkedOutside=Join-Path $fixture 'linked-proposal-outside'
    $null=New-Item -ItemType Directory -Path $linkedOutside -Force
    [IO.File]::WriteAllText((Join-Path $linkedOutside 'review-proposal.md'),'# Outside linked proposal',$utf8)
    $linkedReportLink=Join-Path $reviewProj '.ai\relay\linked-proposal'
    New-Item -ItemType Junction -Path $linkedReportLink -Target $linkedOutside | Out-Null
    Write-Project $reviewProj '.ai/relay/CURRENT' "pre-plan`n"
    try {
        $null=Doctor 'V2-21 unrelated report junction rejected by scan' $reviewProj $doctorRel $false $PackageRoot 'Reparse point in diagnostic input'
    } finally {
        if (Test-Path -LiteralPath $linkedReportLink) { [IO.Directory]::Delete($linkedReportLink, $false) }
    }
    # File-level symlink: needs symlink privilege (often absent under Windows PowerShell 5.1); skipped with an explicit note otherwise.
    $reviewFileTarget=Join-Path $reviewOutside 'review-change.md'
    [IO.File]::WriteAllText($reviewFileTarget,'# Outside change review',$utf8)
    Write-Project $reviewProj 'openspec/changes/file-symlink/proposal.md' '# File symlink'
    $null=New-Item -ItemType Directory -Path (Join-Path $reviewProj '.ai/relay/file-symlink') -Force
    $reviewFileLink=Join-Path $reviewProj '.ai/relay/file-symlink/review-change.md'
    try { New-Item -ItemType SymbolicLink -Path $reviewFileLink -Target $reviewFileTarget | Out-Null } catch { $reviewFileLink=$null; Write-Output "SKIP V2-20 file symlink case: $($_.Exception.Message)" }
    if ($reviewFileLink) {
        Write-Project $reviewProj '.ai/relay/CURRENT' "file-symlink`n"
        try {
            $null=Doctor 'V2-20 review report file symlink rejected' $reviewProj $doctorRel $false $PackageRoot 'Reparse point in diagnostic input'
        } finally {
            if (Test-Path -LiteralPath $reviewFileLink) { [IO.File]::Delete($reviewFileLink) }
        }
    }

    # 5. Owned file drift & missing config fail-closed
    $rulesPath=Join-Path $v2 'docs/engrelay/RULES.md'; $rulesBytes=[IO.File]::ReadAllBytes($rulesPath)
    [IO.File]::AppendAllText($rulesPath,"`nDrifted.",$utf8)
    $null=Call 'V2-06 owned drift Upgrade refuses' $v2 @('-Action','Upgrade') $false $true
    $null=Doctor 'V2-06 doctor catches drift' $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $false
    [IO.File]::WriteAllBytes($rulesPath,$rulesBytes)
    Remove-Item -LiteralPath (Join-Path $v2 'docs/engrelay.config.md')
    $null=Call 'V2-07 missing config Upgrade refuses' $v2 @('-Action','Upgrade') $false $true
    $null=Doctor 'V2-07 doctor catches missing config' $v2 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $false
    Write-Project $v2 'docs/engrelay.config.md' $cfg

    # 6. Profile conflict refusal & Uninstall preserves project content and removes empty v2 dirs; reinstall after Uninstall preserves retained config
    $null=Call 'V2-08 cross-profile Upgrade refuses' $v2 @('-Action','Upgrade','-WorkflowProfile','full') $false $true $PackageRoot 'WorkflowProfile conflict'
    $null=Call 'V2-09 Uninstall v2' $v2 @('-Action','Uninstall')
    Assert (-not (Test-Path -LiteralPath (Join-Path $v2 'docs/engrelay'))) 'Uninstall removes empty docs/engrelay dir'
    Assert (([IO.File]::ReadAllText((Join-Path $v2 'docs/engrelay.config.md'))) -ceq $cfg) 'Uninstall preserves docs/engrelay.config.md'
    Assert (Test-Path -LiteralPath (Join-Path $v2 '.ai/relay/demo-change/board.md') -PathType Leaf) 'Uninstall preserves .ai/relay'
    Assert (([IO.File]::ReadAllText((Join-Path $v2 'AGENTS.md'))) -ceq "Original project rules.`nProject custom rule.") 'Uninstall restores AGENTS outside text'
    $null=Call 'V2-09b reinstall after protected Uninstall preserves config' $v2 @('-Action','Install')
    Assert (([IO.File]::ReadAllText((Join-Path $v2 'docs/engrelay.config.md'))) -ceq $cfg) 'Reinstall after Uninstall preserves retained docs/engrelay.config.md'

    # 7. Single host SkillTarget support (cursor / agents)
    $v2Cursor=New-Project 'v2-cursor'
    $null=Call 'V2-10 cursor skill target install' $v2Cursor @('-Action','Install','-WorkflowProfile','v2','-SkillTarget','cursor')
    Assert (Test-Path -LiteralPath (Join-Path $v2Cursor '.cursor/skills/engrelay/SKILL.md') -PathType Leaf) 'v2 copies unified engrelay skill to .cursor'
    Assert (-not (Test-Path -LiteralPath (Join-Path $v2Cursor '.cursor/skills/ai-collab-start'))) 'v2 does not copy Full skills'
    $null=Doctor 'V2-10 doctor with cursor target' $v2Cursor 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $true $PackageRoot 'SkillTarget=cursor'
    $null=Call 'V2-10 cursor uninstall' $v2Cursor @('-Action','Uninstall')
    Assert (-not (Test-Path -LiteralPath (Join-Path $v2Cursor '.cursor/skills/engrelay'))) 'v2 uninstall removes empty .cursor/skills/engrelay'

    # 8. Private v2 layout refusal on Install & Adopt (dir, entry, and standalone config)
    $privateDir=New-Project 'private-v2-dir'
    Write-Project $privateDir 'docs/engrelay/RULES.md' 'Private v2 rules.'
    $null=Call 'V2-11 private dir Install refuses' $privateDir @('-Action','Install') $false $true $PackageRoot 'Unmanaged v2 directory'
    $null=Call 'V2-11 private dir Adopt refuses' $privateDir @('-Action','Adopt','-WorkflowProfile','v2') $false $true $PackageRoot 'Private v2 adoption is unsupported'
    $privateEntry=New-Project 'private-v2-entry'
    Write-Project $privateEntry 'AGENTS.md' 'Use docs/engrelay/RULES.md directly.'
    $null=Call 'V2-11 private entry Install refuses' $privateEntry @('-Action','Install') $false $true $PackageRoot 'Unmanaged v2 entry'
    $privateConfig=New-Project 'private-v2-config'
    Write-Project $privateConfig 'docs/engrelay.config.md' 'Private v2 config only.'
    $null=Call 'V2-11 private config Install refuses zero-write' $privateConfig @('-Action','Install') $false $true $PackageRoot 'Unmanaged v2 config'
    $null=Call 'V2-11 private config Adopt refuses zero-write' $privateConfig @('-Action','Adopt') $false $true $PackageRoot 'Unmanaged v2 layout'

    # 9. Existing full & lite preserve profile on omitted-parameter Upgrade/SetMode, and Full excludes v2
    $full=New-Project 'keep-full'
    $null=Call 'V2-12 explicit Full install' $full @('-Action','Install','-WorkflowProfile','full')
    Assert (-not (Test-Path -LiteralPath (Join-Path $full 'docs/ai-collaboration/v2')) -and -not (Test-Path -LiteralPath (Join-Path $full 'docs/engrelay'))) 'Full excludes v2 subtree'
    $null=Call 'V2-12 Full Upgrade without profile' $full @('-Action','Upgrade')
    Assert ((State $full).workflowProfile -ceq 'full') 'Full Upgrade preserves full profile'
    $lite=New-Project 'keep-lite'
    $null=Call 'V2-12 explicit Lite install' $lite @('-Action','Install','-WorkflowProfile','lite')
    $null=Call 'V2-12 Lite Upgrade without profile' $lite @('-Action','Upgrade')
    Assert ((State $lite).workflowProfile -ceq 'lite') 'Lite Upgrade preserves lite profile'

    # 10. Package integrity & exact 149/150/151 line-count budget boundaries (LF, CRLF, no trailing newline)
    $mutPkg=Join-Path $fixture 'mutated-package'
    Copy-Item -LiteralPath $PackageRoot -Destination $mutPkg -Recurse
    $mutRules=Join-Path $mutPkg 'payload/docs/ai-collaboration/v2/RULES.md'
    $baseRules=@((Get-Content -LiteralPath $mutRules))
    $curSkill=@((Get-Content -LiteralPath (Join-Path $mutPkg 'payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md'))).Count
    $cases=@(
        @{ label='149-lf';   total=149; nl="`n";   trailing=$true;  pass=$true;  diag='coreLines=149/150' },
        @{ label='150-lf';   total=150; nl="`n";   trailing=$true;  pass=$true;  diag='coreLines=150/150' },
        @{ label='150-crlf'; total=150; nl="`r`n"; trailing=$true;  pass=$true;  diag='coreLines=150/150' },
        @{ label='150-nonl'; total=150; nl="`n";   trailing=$false; pass=$true;  diag='coreLines=150/150' },
        @{ label='151-lf';   total=151; nl="`n";   trailing=$true;  pass=$false; diag='exceeds 150-line budget: 151 lines' }
    )
    foreach ($c in $cases) {
        $needRules=$c.total-$curSkill
        $padCount=$needRules-$baseRules.Count
        $lines=@($baseRules)+(1..$padCount | ForEach-Object { "Pad line $_" })
        $content=($lines -join $c.nl)+$(if ($c.trailing) { $c.nl } else { '' })
        [IO.File]::WriteAllText($mutRules,$content,$utf8)
        Assert ((@((Get-Content -LiteralPath $mutRules)).Count + $curSkill) -eq $c.total) ("Fixture logical total lines eq $($c.total) for $($c.label)")
        & (Join-Path $mutPkg 'scripts/update-snapshot.ps1') -PackageRoot $mutPkg -Version '9.0.0' -ForRelease | Out-Null
        $proj=New-Project ('budget-'+$c.label)
        $null=Call ("V2-13 install "+$c.label) $proj @('-Action','Install') $true $false $mutPkg
        $null=Doctor ("V2-13 doctor "+$c.label) $proj 'payload/docs/ai-collaboration/v2/scripts/doctor.ps1' $c.pass $mutPkg $c.diag
    }

    # 11. Missing unselected source refuses v2 install, and update-snapshot rejects missing file or missing whole v2 dir
    $missing=New-Project 'missing-unselected'
    $fullOnly=Join-Path $mutPkg 'payload/docs/ai-collaboration/agent-prompts.md'
    Remove-Item -LiteralPath $fullOnly
    $null=Call 'V2-14 missing unselected file refuses v2' $missing @('-Action','Install') $false $true $mutPkg 'Snapshot file missing'
    $incompleteV2=Join-Path $fixture 'incomplete-v2-pkg'
    Copy-Item -LiteralPath $PackageRoot -Destination $incompleteV2 -Recurse
    Remove-Item -LiteralPath (Join-Path $incompleteV2 'payload/docs/ai-collaboration/v2/templates/wp.md')
    $snapThrew=$false
    try { & (Join-Path $incompleteV2 'scripts/update-snapshot.ps1') -PackageRoot $incompleteV2 -Version '9.0.0' -ForRelease | Out-Null }
    catch { $snapThrew=$true }
    Assert $snapThrew 'update-snapshot rejects incomplete v2 source projection'
    $missingWholeV2=Join-Path $fixture 'missing-whole-v2-pkg'
    Copy-Item -LiteralPath $PackageRoot -Destination $missingWholeV2 -Recurse
    Remove-Item -LiteralPath (Join-Path $missingWholeV2 'payload/docs/ai-collaboration/v2') -Recurse -Force
    $wholeThrew=$false
    try { & (Join-Path $missingWholeV2 'scripts/update-snapshot.ps1') -PackageRoot $missingWholeV2 -Version '9.0.0' -ForRelease | Out-Null }
    catch { $wholeThrew=$true }
    Assert $wholeThrew 'update-snapshot rejects missing whole v2 projection directory'
} finally {
    if ($LogPath) {
        $path=[IO.Path]::GetFullPath($LogPath); $null=New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force
        [IO.File]::WriteAllText($path,([ordered]@{hostVersion=$PSVersionTable.PSVersion.ToString();calls=$calls.ToArray();checks=$checks.ToArray();failures=$failed.ToArray()} | ConvertTo-Json -Depth 8),$utf8)
    }
    $resolved=[IO.Path]::GetFullPath($fixture); $temp=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
    if ((Split-Path -Parent $resolved) -eq $temp -and (Split-Path -Leaf $resolved) -match '^engrelay-v2-test-[a-f0-9]{32}$') {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
Write-Output "PASS: $($calls.Count) v2 calls; $($checks.Count) outcome checks."
