[CmdletBinding()]
param([string]$LogPath = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$sourceRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $sourceRoot 'payload/docs/ai-collaboration/lite/scripts/validate-state.ps1'
$hostExe = (Get-Process -Id $PID).Path
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('engrelay-lite-state-' + [guid]::NewGuid().ToString('N'))
$calls = New-Object 'Collections.Generic.List[object]'
$failed = New-Object 'Collections.Generic.List[string]'
$base = @'
# Test handoff
## Routing
- Schema version: lite-1
- Task ID: T01
- State revision: 4
- Current role: Executor
- Current agent: fixture-executor
- Current status: in-progress
- Next action: dispatch
- Human Action Required: none
- Review round: 0
- Next role: Reviewer
- Risk level: M
## Current Status
Recommended capability tier: C3
Implementation ready for independent review.
## Evidence
- Named result: .ai/engrelay-lite/tasks/T01-review-1.md
## Operator Command
```text
You are the Reviewer for task T01.
Read: AGENTS.md, docs/engrelay-lite/RULES.md and .ai/engrelay-lite/tasks/T01.md.
Objective: independently review the recorded acceptance.
Constraints: business code is read-only; independent of the producer; 0 completed verdicts, 3 available.
Output: .ai/engrelay-lite/tasks/T01-review-1.md and .ai/engrelay-lite/handoff.md are writable.
Follow: docs/engrelay-lite/RULES.md.
```
'@

function Write-Fixture([string]$Relative, [string]$Text) {
    $path = Join-Path $fixture $Relative
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force
    [IO.File]::WriteAllText($path, $Text, $utf8)
}
function Get-Tree {
    return (@(Get-ChildItem -LiteralPath $fixture -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
        $_.FullName.Substring($fixture.Length) + '|' + (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }) -join "`n")
}
function Invoke-Case([string]$Name, [string]$Text, [bool]$Pass, [string]$Diagnostic, [string[]]$Extra = @()) {
    Write-Fixture '.ai/engrelay-lite/handoff.md' $Text
    $before = Get-Tree
    $arguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$validator,'-WorkspaceRoot',$fixture) + $Extra
    # An encoded wrapper preserves explicit empty arguments on both PowerShell
    # hosts. Values are PowerShell single-quoted literals, never shell interpolation.
    $values = @('-WorkspaceRoot',$fixture) + $Extra
    $command = "& '" + $validator.Replace("'","''") + "'"
    for ($i=0; $i -lt $values.Count; $i+=2) {
        if ($values[$i] -notmatch '^-[A-Za-z]+$') { throw 'Invalid test parameter name' }
        $command += ' ' + $values[$i] + " '" + $values[$i+1].Replace("'","''") + "'"
    }
    $command += '; exit $LASTEXITCODE'
    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName=$hostExe; $start.Arguments='-NoProfile -ExecutionPolicy Bypass -EncodedCommand '+[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $start.UseShellExecute=$false; $start.CreateNoWindow=$true; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
    $process=New-Object Diagnostics.Process; $process.StartInfo=$start
    try {
        $null=$process.Start(); $stdout=$process.StandardOutput.ReadToEndAsync(); $stderr=$process.StandardError.ReadToEndAsync()
        $process.WaitForExit(); $output=$stdout.Result+$stderr.Result; $code=$process.ExitCode
    } finally { $process.Dispose() }
    $after = Get-Tree
    $ok = (($code -eq 0) -eq $Pass) -and $output.Contains($Diagnostic) -and ($before -ceq $after)
    $calls.Add([pscustomobject]@{ name=$Name; host=$hostExe; arguments=$arguments; exitCode=$code; output=$output
        expectedPass=$Pass; diagnostic=$Diagnostic; before=$before; after=$after; passed=$ok })
    if (-not $ok) { $failed.Add($Name); Write-Host "FAIL $Name : $output" }
}

try {
    $null = New-Item -ItemType Directory -Path $fixture
    Invoke-Case 'dispatch' $base $true 'Structure and supplied expectations match'
    Invoke-Case 'expected-match' $base $true 'expectations match' @('-ExpectedTaskId','T01','-ExpectedNextAction','dispatch','-ExpectedNextRole','Reviewer','-ExpectedReviewRound','0','-ExpectedStateRevision','4')
    Invoke-Case 'expected-mismatch' $base $false 'Expected Next role' @('-ExpectedTaskId','T01','-ExpectedNextRole','Executor')
    Invoke-Case 'expectation-without-task' $base $false 'ExpectedTaskId is required' @('-ExpectedStateRevision','5')
    Invoke-Case 'empty-expected-action' $base $false 'Expected Next action' @('-ExpectedTaskId','T01','-ExpectedNextAction','')
    Invoke-Case 'duplicate' ($base.Replace('- Next action: dispatch',"- Next action: dispatch`n- Next action: continue")) $false 'Duplicate Routing field'
    Invoke-Case 'missing' ($base.Replace('- Schema version: lite-1','')) $false 'Missing Routing field'
    Invoke-Case 'unknown-schema' ($base.Replace('lite-1','lite-9')) $false 'Invalid Schema version'
    Invoke-Case 'unknown-field' ($base.Replace('## Current Status',"- Extra: value`n## Current Status")) $false 'Unknown Routing field'
    Invoke-Case 'invalid-role' ($base.Replace('- Next role: Reviewer','- Next role: Designer')) $false 'Invalid Next role'
    Invoke-Case 'invalid-number' ($base.Replace('- Review round: 0','- Review round: -1')) $false 'Invalid Review round'
    Invoke-Case 'capacity' ($base.Replace('- Review round: 0','- Review round: 3')) $false 'Review allowance exhausted'
    Write-Fixture '.ai/engrelay-lite/owner-decision.md' 'Fictional scoped extension for T01.'
    $extended=$base.Replace('- Review round: 0','- Review round: 3').Replace('## Evidence',"## Evidence`n- Task Owner decision: review-budget-extension; owner=Fixture Owner; date=2026-10-22; batch=T01; from=3; through=5; scope=repair; evidence=.ai/engrelay-lite/owner-decision.md")
    Invoke-Case 'finite-extension' $extended $true 'expectations match'
    Invoke-Case 'extension-wrong-task' ($extended.Replace('batch=T01','batch=T99')) $false 'review-budget-extension task'
    Invoke-Case 'extension-exhausted' ($extended.Replace('Review round: 3','Review round: 5')) $false 'Review allowance exhausted'
    Invoke-Case 'extension-duplicate-key' ($extended.Replace('from=3','from=3; from=3')) $false 'review-budget-extension fields'
    Invoke-Case 'advisory' ($base.Replace('Recommended capability tier: C3','')) $true 'WARNING: Missing advisory capability'
    Invoke-Case 'fenced-routing' ($base + "`n## Example`n``````text`n- Next action: close`n``````") $true 'expectations match'
    $continuation = @'
### Continuation Command
```text
You are continuing as Executor for task T01.
Read: docs/engrelay-lite/RULES.md and .ai/engrelay-lite/tasks/T01.md.
Objective: finish the authorized offline work.
Constraints: keep scope and review count; check execution ownership.
Output: authorized files and next boundary handoff.
Follow: docs/engrelay-lite/RULES.md.
```
'@
    $continue = $base.Replace('- Next action: dispatch','- Next action: continue').Replace('- Next role: Reviewer','- Next role: none').Replace('Recommended capability tier: C3','')
    $continue = $continue.Substring(0,$continue.IndexOf('## Operator Command')).Replace('## Evidence',$continuation + "`n## Evidence")
    Invoke-Case 'continue' $continue $true 'expectations match'
    Invoke-Case 'continue-capacity-2' ($continue.Replace('Review round: 0','Review round: 2')) $true 'expectations match'
    Invoke-Case 'continue-capacity-3' ($continue.Replace('Review round: 0','Review round: 3')) $false 'Review allowance exhausted'
    Invoke-Case 'continue-capacity-8' ($continue.Replace('Review round: 0','Review round: 8')) $false 'Review allowance exhausted'
    $continueExtended = $continue.Replace('Review round: 0','Review round: 3').Replace('## Evidence',"## Evidence`n- Task Owner decision: review-budget-extension; owner=Fixture Owner; date=2026-10-22; batch=T01; from=3; through=5; scope=repair; evidence=.ai/engrelay-lite/owner-decision.md")
    Invoke-Case 'continue-extension' $continueExtended $true 'expectations match'
    Invoke-Case 'continue-extension-exhausted' ($continueExtended.Replace('Review round: 3','Review round: 5')) $false 'Review allowance exhausted'
    Invoke-Case 'continue-extension-wrong-task' ($continueExtended.Replace('batch=T01','batch=T99')) $false 'review-budget-extension task'
    Invoke-Case 'continue-extension-before-from' ($continueExtended.Replace('from=3','from=4')) $false 'Review allowance exhausted'
    Invoke-Case 'command-outside-label' ($base.Replace('Follow: docs/engrelay-lite/RULES.md.', 'Missing follow.') + "`nFollow: outside") $false 'Missing Operator Command Follow'
    foreach ($label in @('Read','Objective','Constraints','Output','Follow')) {
        Invoke-Case ('command-missing-'+$label) ([regex]::Replace($base, ('(?m)^' + $label + ':.*$'), ($label + ':'))) $false ('Missing Operator Command ' + $label)
    }
    Invoke-Case 'command-longer-task' ($base.Replace('task T01.','task T010.')) $false 'identity'
    Invoke-Case 'command-missing-role' ($base.Replace('You are the Reviewer','You are the Observer')) $false 'identity'
    Invoke-Case 'command-other-section-label' ($base.Replace('Follow: docs/engrelay-lite/RULES.md.', 'Missing follow.') + "`n## Other`nFollow: elsewhere") $false 'Missing Operator Command Follow'
    Invoke-Case 'command-tilde' ($base.Replace('```text','~~~text').Replace('```','~~~')) $true 'expectations match'
    Invoke-Case 'command-long-fence' ($base.Replace('```','````')) $true 'expectations match'
    Invoke-Case 'command-unclosed' ($base.Substring(0,$base.LastIndexOf('```'))) $false 'Unclosed code fence'
    Invoke-Case 'command-multiple' ($base + "`n``````text`nextra`n``````") $false 'multiple'
    $fakeHeading = "~~~~markdown`n### Continuation Command`n``````text`nIncomplete example`n```````n~~~~`n"
    Invoke-Case 'continue-fenced-heading' ($continue.Replace('### Continuation Command',($fakeHeading + '### Continuation Command'))) $true 'expectations match'
    Invoke-Case 'continue-only-fenced-heading' ($continue.Replace('### Continuation Command','### Example').Replace('## Evidence',($fakeHeading + "`n## Evidence"))) $false 'Continuation Command'
    Invoke-Case 'continue-no-command' ($continue.Replace('### Continuation Command','### Example')) $false 'Continuation Command'
    # Corrective CR-01: a longer legal task ID, including a dot, must not supply the
    # current identity. Correct dotted IDs and sentence-ending punctuation stay valid.
    Invoke-Case 'command-longer-dash-id' ($base.Replace('for task T01.','for task T01.-other')) $false 'identity'
    Invoke-Case 'command-longer-underscore-id' ($base.Replace('for task T01.','for task T01._other')) $false 'identity'
    Invoke-Case 'command-longer-dotdot-id' ($base.Replace('for task T01.','for task T01..other')) $false 'identity'
    Invoke-Case 'command-sentence-punctuation' ($base.Replace('for task T01.','for task T01.)')) $true 'expectations match'
    $dotted = $base.Replace('- Task ID: T01','- Task ID: T01.2').Replace('for task T01.','for task T01.2.')
    Invoke-Case 'command-dotted-id' $dotted $true 'expectations match'
    Invoke-Case 'command-shorter-than-dotted-id' ($dotted.Replace('for task T01.2.','for task T01.')) $false 'identity'
    # Corrective CR-02: a real higher heading ends the action section; H3 text and
    # fenced fake headings inside the section do not.
    Invoke-Case 'command-borrowed-across-h1' ($base.Replace("## Operator Command`n","## Operator Command`n# Other section`n")) $false 'identity'
    Invoke-Case 'command-h3-inside-section' ($base.Replace("## Operator Command`n","## Operator Command`n### Notes`n")) $true 'expectations match'
    Invoke-Case 'command-fenced-h1-inside-section' ($base.Replace("## Operator Command`n","## Operator Command`n~~~~markdown`n# Example heading`n~~~~`n")) $true 'expectations match'
    Invoke-Case 'continue-borrowed-across-h1' ($continue.Replace('Implementation ready for independent review.',"Implementation ready for independent review.`n# Other section")) $false 'Continuation Command'
    # Corrective CR-02 remainder: a real H1 with 0-3 leading spaces, a TAB separator
    # or an empty heading also ends the action section; four-space code and text stay.
    Invoke-Case 'command-indented-h1-borrowed' ($base.Replace("## Operator Command`n","## Operator Command`n # Other`n")) $false 'identity'
    Invoke-Case 'command-tab-h1-borrowed' ($base.Replace("## Operator Command`n","## Operator Command`n#`tOther`n")) $false 'identity'
    Invoke-Case 'command-empty-h1-borrowed' ($base.Replace("## Operator Command`n","## Operator Command`n#`n")) $false 'identity'
    Invoke-Case 'continue-indented-h1-borrowed' ($continue.Replace('Implementation ready for independent review.',"Implementation ready for independent review.`n # Other section")) $false 'Continuation Command'
    Invoke-Case 'continue-tab-h1-borrowed' ($continue.Replace('Implementation ready for independent review.',"Implementation ready for independent review.`n#`tOther section")) $false 'Continuation Command'
    Invoke-Case 'continue-empty-h1-borrowed' ($continue.Replace('Implementation ready for independent review.',"Implementation ready for independent review.`n#")) $false 'Continuation Command'
    Invoke-Case 'continue-indented-h1-inside-continuation' ($continue.Replace('### Continuation Command',"### Continuation Command`n # Other section")) $false 'Continuation Command'
    Invoke-Case 'command-four-space-hash-kept' ($base.Replace("## Operator Command`n","## Operator Command`n    # Example code`n")) $true 'expectations match'
    Invoke-Case 'command-hash-without-space-kept' ($base.Replace("## Operator Command`n","## Operator Command`n#Other`n")) $true 'expectations match'
    Invoke-Case 'command-fenced-indented-h1-kept' ($base.Replace("## Operator Command`n","## Operator Command`n~~~~markdown`n # Example heading`n~~~~`n")) $true 'expectations match'
    Invoke-Case 'continue-four-space-hash-kept' ($continue.Replace('Implementation ready for independent review.',"Implementation ready for independent review.`n    # Example code")) $true 'expectations match'
    # Corrective CR-03: the existing text info string keeps ordinal case-insensitive
    # compatibility; variants still count as one actual command block.
    Invoke-Case 'command-uppercase-text-fence' ($base.Replace('```text','```TEXT')) $true 'expectations match'
    Invoke-Case 'command-mixed-text-fence' ($base.Replace('```text','```Text')) $true 'expectations match'
    Invoke-Case 'continue-uppercase-text-fence' ($continue.Replace('```text','```TEXT')) $true 'expectations match'
    Invoke-Case 'command-text-case-variant-ambiguous' ($base + "`n``````TEXT`nextra`n``````") $false 'multiple'
    $withoutCommand = $continue.Substring(0,$continue.IndexOf('### Continuation Command')) + "`n## Evidence`nRecorded result."
    $blocked = $withoutCommand.Replace('in-progress','blocked') + "`n## Blockers`nTried one bounded retry. Resume condition: package host reachable."
    Invoke-Case 'tool-wait' $blocked $true 'expectations match'
    Invoke-Case 'blocked-at-capacity' ($blocked.Replace('Review round: 0','Review round: 8')) $true 'expectations match'
    Invoke-Case 'resumed-at-capacity' ($continue.Replace('Review round: 0','Review round: 8')) $false 'Review allowance exhausted'
    Invoke-Case 'human-wait-missing-preparation' ($blocked.Replace('Human Action Required: none','Human Action Required: awaiting-environment')) $false 'Human preparation'
    Invoke-Case 'human-wait' ($blocked.Replace('Human Action Required: none','Human Action Required: awaiting-environment') + "`nHuman preparation: Start the approved test session and report its address.") $true 'expectations match'
    Invoke-Case 'blocked-no-resume' ($blocked.Replace('Resume condition:','Later:')) $false 'Resume condition'
    $decision = $withoutCommand.Replace('in-progress','awaiting-owner-decision').Replace('Human Action Required: none','Human Action Required: awaiting-decision') + @'

## Owner Decision Brief
- Decision needed: May we expand the offline scope?
- Recommendation: Keep the authorized scope.
- Alternatives: Approve the named expansion and cost.
- Reply needed: Keep scope or approve expansion.
- After the reply: Executor updates task and handoff.
'@
    Invoke-Case 'decision-continue' $decision $true 'expectations match'
    Invoke-Case 'decision-at-capacity' ($decision.Replace('Review round: 0','Review round: 8')) $true 'expectations match'
    Invoke-Case 'decision-dispatch' ($decision.Replace('- Next action: continue','- Next action: dispatch').Replace('- Next role: none','- Next role: Task Owner')) $true 'expectations match'
    Invoke-Case 'false-human-wait' ($base.Replace('Human Action Required: none','Human Action Required: awaiting-decision')) $false 'Invalid route'
    $close = $withoutCommand.Replace('in-progress','completed').Replace('- Next action: continue','- Next action: close') + "`n## Outcome`naccepted; recorded checks and review in Evidence."
    Invoke-Case 'close' $close $true 'expectations match'
    Invoke-Case 'close-at-capacity' ($close.Replace('Review round: 0','Review round: 8')) $true 'expectations match'
    Invoke-Case 'close-with-command' ($close + "`n## Operator Command`nDo work.") $false 'Unexpected Operator Command'
    Invoke-Case 'path-escape' $base $false 'Path must stay inside WorkspaceRoot' @('-HandoffPath','../outside.md')

    Write-Fixture '.ai/engrelay-lite/prior.md' $base
    $priorHash = (Get-FileHash -LiteralPath (Join-Path $fixture '.ai/engrelay-lite/prior.md')).Hash
    $result = @"
- Task ID: T01
- Source role: Reviewer
- Source agent: fixture-reviewer
- Work producer: fixture-executor
- Named result: .ai/engrelay-lite/tasks/T01-review-1.md
- Prior revision: 4
- Prior handoff SHA256: $priorHash
- Target revision: 5
- Cumulative verdicts: 1
- Verdict: FAIL
"@
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' $result
    $candidate = $base.Replace('State revision: 4','State revision: 5').Replace('Review round: 0','Review round: 1').Replace('Current role: Executor','Current role: Reviewer').Replace('Current agent: fixture-executor','Current agent: fixture-reviewer').Replace('Next role: Reviewer','Next role: Executor').Replace('You are the Reviewer','You are the Executor')
    $sourceArgs = @('-SourceResultPath','.ai/engrelay-lite/tasks/T01-review-1.md','-PriorHandoffPath','.ai/engrelay-lite/prior.md')
    Invoke-Case 'source-matched' $candidate $true 'Source matches explicit prior input' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ("~~~text`n" + $result + "`n~~~")
    Invoke-Case 'source-fenced-only' $candidate $false 'Missing source' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ("``````text`n" + $result + "`n``````")
    Invoke-Case 'source-backtick-only' $candidate $false 'Missing source' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result + "`n~~~~markdown`n" + $candidate + "`n~~~~")
    Invoke-Case 'source-nested-response' $candidate $true 'Source matches explicit prior input' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result + "`n````````markdown`n" + $candidate + "`n````````")
    Invoke-Case 'source-backtick-nested-response' $candidate $true 'Source matches explicit prior input' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result + "`n- Task ID: T01")
    Invoke-Case 'source-duplicate-outside' $candidate $false 'Duplicate source field' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result + "`n~~~~markdown`n~~~`n```````n~~~~ trailing`n- Task ID: fake`n~~~~")
    Invoke-Case 'source-fake-closers' $candidate $true 'Source matches explicit prior input' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result + "`n~~~~markdown`n- Task ID: fake")
    Invoke-Case 'source-unclosed' $candidate $false 'Unclosed code fence' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' $result
    Write-Fixture '.ai/engrelay-lite/prior.md' ($base + "`nChanged input.")
    Invoke-Case 'source-hash-conflict' $candidate $false 'Prior handoff SHA256 mismatch' $sourceArgs
    Write-Fixture '.ai/engrelay-lite/prior.md' $base
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result.Replace('Task ID: T01','Task ID: T99'))
    Invoke-Case 'source-task-conflict' $candidate $false 'Source Task ID mismatch' $sourceArgs
    foreach ($mutation in @('revision','count','agent','producer','closed')) {
        Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' $result
        Write-Fixture '.ai/engrelay-lite/prior.md' $base
        $changed=$candidate
        switch ($mutation) {
            'revision' { Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result.Replace('Prior revision: 4','Prior revision: 3')) }
            'count' { $changed=$candidate.Replace('Review round: 1','Review round: 0') }
            'agent' { $changed=$candidate.Replace('Current agent: fixture-reviewer','Current agent: other') }
            'producer' { Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' ($result.Replace('Work producer: fixture-executor','Work producer: fixture-reviewer')) }
            'closed' { Write-Fixture '.ai/engrelay-lite/prior.md' ($base.Replace('in-progress','completed')) }
        }
        Invoke-Case ('source-conflict-'+$mutation) $changed $false 'ERROR:' $sourceArgs
    }
    Write-Fixture '.ai/engrelay-lite/prior.md' $base
    Write-Fixture '.ai/engrelay-lite/tasks/T01-review-1.md' $result
    Write-Fixture '.ai/engrelay-lite/prior.md' ($base.Replace('Named result: .ai/engrelay-lite/tasks/T01-review-1.md','Result: elsewhere.md'))
    Invoke-Case 'unnamed-source' $candidate $false 'Source result is not named by prior Evidence' $sourceArgs
} finally {
    if ($LogPath) {
        $log = [IO.Path]::GetFullPath($LogPath)
        if ($log.StartsWith($fixture + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'LogPath must be outside fixture' }
        $null = New-Item -ItemType Directory -Path (Split-Path -Parent $log) -Force
        $scriptHash = if (Test-Path -LiteralPath $validator) { (Get-FileHash -LiteralPath $validator).Hash } else { 'missing' }
        [IO.File]::WriteAllText($log,([ordered]@{ hostVersion=$PSVersionTable.PSVersion.ToString(); validatorHash=$scriptHash; calls=$calls.ToArray(); failures=$failed.ToArray() } | ConvertTo-Json -Depth 8),$utf8)
    }
    $temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
    $resolved = [IO.Path]::GetFullPath($fixture)
    if ((Split-Path -Parent $resolved) -ne $temp -or (Split-Path -Leaf $resolved) -notmatch '^engrelay-lite-state-[a-f0-9]{32}$') { throw 'Unsafe fixture cleanup' }
    if (@(Get-ChildItem -LiteralPath $resolved -Recurse -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) { throw 'Reparse point in fixture; retain for inspection' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
if ($failed.Count) { throw "$($failed.Count) Lite state cases failed: $($failed -join ', ')" }
Write-Output "PASS: $($calls.Count) Lite state cases; real subprocess exits and zero writes checked."
