[CmdletBinding()]
param([string[]]$CaseFilter = @())

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$validator = Join-Path $PSScriptRoot "validate-runtime-state.ps1"
$powershell = (Get-Process -Id $PID).Path
$tempName = ".tmp-collaboration-validator-" + [guid]::NewGuid().ToString("N")
$tempRoot = Join-Path $workspaceRoot $tempName
$caseCount = 0

function Invoke-ValidatorCase {
    param(
        [string]$Name,
        [string]$CurrentTaskRelativePath,
        [string]$HandoffRelativePath,
        [int]$ExpectedExitCode,
        [string[]]$ExpectedWarnings = @(),
        [string[]]$ExpectedErrors = @(),
        [switch]$ExpectNoWarnings
    )

    if ($CaseFilter.Count -gt 0 -and -not @($CaseFilter | Where-Object { $Name -like $_ }).Count) {
        return
    }

    $output = & $powershell `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $validator `
        -WorkspaceRoot $tempRoot `
        -CurrentTaskPath $CurrentTaskRelativePath `
        -HandoffPath $HandoffRelativePath 2>&1
    $actualExitCode = $LASTEXITCODE

    if ($actualExitCode -ne $ExpectedExitCode) {
        throw (
            "Case '$Name' expected exit $ExpectedExitCode but got " +
            "$actualExitCode.`n$($output -join "`n")"
        )
    }

    $outputText = $output -join "`n"
    if ($ExpectNoWarnings) {
        if ($outputText -match "Advisory .*warnings:") {
            throw "Case '$Name' expected no warnings but got:`n$outputText"
        }
    }

    foreach ($expectedWarning in $ExpectedWarnings) {
        if (-not ($outputText -match [regex]::Escape($expectedWarning))) {
            throw (
                "Case '$Name' expected warning matching '$expectedWarning' but got:`n" +
                $outputText
            )
        }
    }

    foreach ($expectedError in $ExpectedErrors) {
        if (-not ($outputText -match [regex]::Escape($expectedError))) {
            throw (
                "Case '$Name' expected error matching '$expectedError' but got:`n" +
                $outputText
            )
        }
    }

    Write-Host "PASS: $Name"
    $script:caseCount++
}

function Convert-ToNonDispatchHandoff {
    param(
        [string]$Handoff,
        [ValidateSet("continue", "close")]
        [string]$Action
    )

    $result = $Handoff.Replace(
        '- Next action: `dispatch`',
        "- Next action: ``$Action``"
    )
    $emptyNextRoute = @'
- Next role: `none`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

'@
    $result = [regex]::Replace(
        $result,
        "(?ms)^- Next role:.*?(?=^## Current Status)",
        $emptyNextRoute
    )
    $result = [regex]::Replace(
        $result,
        "(?ms)\r?\n## Operator Command\s*\r?\n.*\z",
        ""
    )

    if ($Action -eq "close") {
        $result += @'

## Process Metrics
- Role actions: `3`
- Review/fix/verification loops: `1`
- Broad regression runs: `1`
- Elapsed time: `2h`
- Token usage: `unknown`
'@
    }

    return $result
}

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    foreach ($relativeDirectory in @(
        ".ai",
        "docs\ai-collaboration\templates",
        "openspec\changes\validator-change"
    )) {
        New-Item `
            -ItemType Directory `
            -Path (Join-Path $tempRoot $relativeDirectory) `
            -Force | Out-Null
    }

    Copy-Item `
        -LiteralPath (Join-Path $workspaceRoot "docs\ai-collaboration\agent-prompts.md") `
        -Destination (Join-Path $tempRoot "docs\ai-collaboration\agent-prompts.md")
    foreach ($templateName in @(
        "current-task.template.md",
        "handoff.template.md",
        "implementation-result.template.md",
        "requirement-baseline.template.md"
    )) {
        Copy-Item `
            -LiteralPath (Join-Path $workspaceRoot "docs\ai-collaboration\templates\$templateName") `
            -Destination (Join-Path $tempRoot "docs\ai-collaboration\templates\$templateName")
    }

    $currentTaskRelativePath = ".ai/current-task.md"
    $handoffRelativePath = ".ai/handoff.md"
    $currentTaskCopy = Join-Path $tempRoot $currentTaskRelativePath
    $handoffCopy = Join-Path $tempRoot $handoffRelativePath
    $originalCurrentTask = @'
# Current Task

## Task Identity

- Task ID: `VALIDATOR-001`
- Change ID: `validator-change`
- Module(s): `workspace process documentation`
- Source: `validator test fixture`
- Created on: `2026-08-04`

## Batch Classification

- Execution Batch ID: `validator-mapped-items`
- Risk level: `M`
- Risk reason: `The fixture validates shared collaboration state rules.`
- OpenSpec checklist items:
  - `1.1`
  - `1.2a.1`
- Existing capability to reuse: `the current runtime-state validator`
- First demonstrable outcome: `the validator accepts every mapped item only when each ID exists`
- Justified complexity exceptions: `none`
- Stop condition: `the fixture would require live workspace runtime state`
- Expected implementation sessions: `1`
- Broad regression command: `none`

## Initial Assignment

- Initial role: `Implementation Engineer`
- Recommended agent: `validator test`
- Initial prompt template:
  - `docs/ai-collaboration/agent-prompts.md#implementation-engineer`

## Required Reading

- `AGENTS.md`
- `docs/ai-collaboration/workflows.md#6-implementation`
- `docs/ai-collaboration/agent-prompts.md#implementation-engineer`
- `openspec/changes/validator-change/tasks.md`

## Goal

Validate a self-contained runtime-state fixture.

## Scope

- Runtime-state fixture validation.

## Out of Scope

- Product code.

## Must Not Touch

- Live workspace runtime state.

## Acceptance Criteria

- Every listed OpenSpec checklist ID is verified against the fixture tasks file.

## Constraints

- Use only the temporary fixture workspace.

## Required Checks

- Run the runtime-state validator.

## Output Requirements

- Produce valid dispatch state for the test case.
'@
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    $tasksFixture = @'
# Tasks

- [ ] 1.1 Validate the first mapped item.
- [ ] 1.2a.1 Validate the nested mapped item.
'@
    Set-Content `
        -LiteralPath (Join-Path $tempRoot "openspec\changes\validator-change\tasks.md") `
        -Value $tasksFixture `
        -NoNewline

    $batchIdMatch = [regex]::Match(
        $originalCurrentTask,
        "(?m)^- Execution Batch ID:\s*``(?<id>[^``]+)``\s*$"
    )
    if (-not $batchIdMatch.Success) {
        throw "Test fixture current task has no Execution Batch ID"
    }
    $batchId = $batchIdMatch.Groups["id"].Value
    $resultRelativePath = ".ai/round-99-result.md"
    $resultFullPath = Join-Path $tempRoot $resultRelativePath
    Copy-Item `
        -LiteralPath (
            Join-Path $tempRoot (
                "docs\ai-collaboration\templates\" +
                "implementation-result.template.md"
            )
        ) `
        -Destination $resultFullPath
    $originalHandoff = @'
# Handoff

## Routing

- Next action: `dispatch`
- Current role: `Implementation Engineer`
- Current agent: `validator test`
- Current status: `ready-for-review`
- Review round: `0`
- Next role: `Code Reviewer`
- Recommended next agent: `validator test`
- Next input files:
  - `.ai/current-task.md`
- Next output files:
  - `.ai/handoff.md`
- Next prompt template:
  - `docs/ai-collaboration/agent-prompts.md#code-reviewer`

## Current Status

The fixture implementation is ready for review.

## Delta Since Last Handoff

- Created isolated validator input files.

## Authoritative Evidence

- `.ai/current-task.md`

## Known Risks

- None beyond validator coverage.

## Blockers

- None.

## Review Or Task State Impact

- No formal review state changes.

## Operator Command
```text
You are the Code Reviewer for Execution Batch validator-mapped-items.
Read: .ai/current-task.md and .ai/handoff.md.
Objective: review the current batch.
Constraints: preserve unrelated changes.
Output: update the required review evidence and routing.
Follow: docs/ai-collaboration/agent-prompts.md#code-reviewer.
```
'@
    Set-Content -LiteralPath $handoffCopy -Value $originalHandoff -NoNewline

    $baselineFixturePath = Join-Path $tempRoot ".ai\requirement-baseline.md"
    $baselineDraftFixture = @'
# Requirement Baseline

## Requirement Maturity

`draft`

## Business Goal

Clarify which expiring benefit users should see and when.

## Actors And Behavior

### Current behavior

- Eligible users do not receive a consistent expiry explanation.

### Desired behavior

- Eligible users understand the relevant expiry window.

## Must-Have Requirements And Acceptance Criteria

- Must-have: state the eligible audience and observable expiry notice.
- Acceptance: the owner can confirm the goal and expected notice behavior.

## Business Rules And Constraints

- Business rules: preserve existing eligibility rules.
- Constraints: no technical solution is selected here.

## Non-Goals

- Non-goals: architecture, implementation, and rollout design.

## Assumptions And Open Questions

- Assumptions: the current eligibility behavior remains authoritative.
- Open questions: which audience and timing are required?

## Task Owner Decisions And Confirmation Summary

- Decisions: pending owner confirmation.
- Confirmation summary: goal, must-have, acceptance, and non-goal are drafted.
- Confirmation reply and effect: pending; keep maturity `draft`.
'@
    Set-Content -LiteralPath $baselineFixturePath -Value $baselineDraftFixture -NoNewline

    Invoke-ValidatorCase `
        -Name "valid dispatch with multiple mapped OpenSpec items" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    $reviewRoundTwoDispatch = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `2`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $reviewRoundTwoDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "review round 2 still permits agent dispatch" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    foreach ($overLimitRound in @('3', '4', '45')) {
        $overLimitDispatch = $originalHandoff.Replace(
            '- Review round: `0`',
            ("- Review round: " + [char]96 + $overLimitRound + [char]96)
        )
        Set-Content -LiteralPath $handoffCopy -Value $overLimitDispatch -NoNewline
        Invoke-ValidatorCase `
            -Name "review round $overLimitRound circuit breaker rejects agent dispatch" `
            -CurrentTaskRelativePath $currentTaskRelativePath `
            -HandoffRelativePath $handoffRelativePath `
            -ExpectedExitCode 1 `
            -ExpectedErrors @('Review round circuit breaker reached at 3; agent dispatch is not permitted')
    }

    $chiefDesignerOverLimitDispatch = $originalHandoff.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Chief Designer`'
    ).Replace(
        '- Current agent: `validator test`',
        '- Current agent: `validator design`'
    ).Replace(
        '- Review round: `0`',
        '- Review round: `3`'
    ).Replace(
        '- Next role: `Code Reviewer`',
        '- Next role: `Design Reviewer`'
    ).Replace(
        '- Recommended next agent: `validator test`',
        '- Recommended next agent: `validator design-review`'
    ).Replace(
        'You are the Code Reviewer for Execution Batch validator-mapped-items.',
        'You are the Design Reviewer for Execution Batch validator-mapped-items.'
    ).Replace(
        '#code-reviewer',
        '#design-reviewer'
    )
    Set-Content -LiteralPath $handoffCopy -Value $chiefDesignerOverLimitDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "review round 3 circuit breaker rejects Chief Designer agent dispatch" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Review round circuit breaker reached at 3; agent dispatch is not permitted')

    $missingReviewRound = $originalHandoff.Replace(
        '- Review round: `0`',
        ""
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingReviewRound -NoNewline
    Invoke-ValidatorCase `
        -Name "active review handoff requires Review round" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Active implementation/review/fix handoff requires Review round')

    $invalidReviewRound = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `three`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidReviewRound -NoNewline
    Invoke-ValidatorCase `
        -Name "Review round must be a nonnegative integer" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Review round must be a nonnegative integer')

    $ownerWaitAtCircuitBreaker = Convert-ToNonDispatchHandoff `
        ($originalHandoff.Replace('- Review round: `0`', '- Review round: `3`')) `
        "continue"
    $ownerWaitAtCircuitBreaker = $ownerWaitAtCircuitBreaker.Replace(
        '- Current status: `ready-for-review`',
        '- Current status: `awaiting-owner-decision`'
    )
    $ownerWaitAtCircuitBreaker += @'

## Owner Decision Brief

- Decision needed: Choose whether to close or revise the batch.
- Recommendation: Close after reviewing the recorded evidence because the circuit breaker has been reached.
- Alternatives: Continue with a bounded owner-approved action; consequence: the batch remains open.
- Reply needed: Reply `close` or `continue`.
- After the reply: Record the decision and continue the same role.
'@
    Set-Content -LiteralPath $handoffCopy -Value $ownerWaitAtCircuitBreaker -NoNewline
    Invoke-ValidatorCase `
        -Name "review round 3 permits continue awaiting owner decision" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    # Finite review-budget extension consumers (AC-P2-08). The structured
    # single-line extension lives in the existing Task Owner decision value;
    # fields split on ';' because owner identity may contain spaces. An
    # applicable unused extension permits the budgeted route; every other
    # over-limit route keeps the existing circuit-breaker rejection and no
    # other check is weakened.
    $budgetDecisionFor = {
        param([int]$From, [int]$Through, [string]$Extra = '')
        $line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; date=2026-10-02; batch=validator-mapped-items; from=' + $From + '; through=' + $Through + '; scope=budget recovery consumers; evidence=fixture decision'
        if ($Extra -ne '') { $line = $Extra }
        return $line
    }
    $budgetDispatchAtThree = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `3`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 0 5))
    )
    Set-Content -LiteralPath $handoffCopy -Value $budgetDispatchAtThree -NoNewline
    Invoke-ValidatorCase `
        -Name "review round 3 permits agent dispatch with applicable finite owner extension" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    $budgetDispatchAtFour = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `4`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 4 7))
    )
    Set-Content -LiteralPath $handoffCopy -Value $budgetDispatchAtFour -NoNewline
    Invoke-ValidatorCase `
        -Name "review round 4 permits agent dispatch with applicable finite owner extension" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    $budgetContinueAtThree = Convert-ToNonDispatchHandoff `
        ($originalHandoff.Replace('- Review round: `0`', '- Review round: `3`')) `
        "continue"
    $budgetContinueAtThree = $budgetContinueAtThree.Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 0 5))
    )
    Set-Content -LiteralPath $handoffCopy -Value $budgetContinueAtThree -NoNewline
    Invoke-ValidatorCase `
        -Name "review round 3 permits continue with applicable finite owner extension" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    $budgetRoleChange = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `4`'
    ).Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Fix Engineer`'
    ).Replace(
        '- Current agent: `validator test`',
        '- Current agent: `validator fix`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 3 7))
    )
    Set-Content -LiteralPath $handoffCopy -Value $budgetRoleChange -NoNewline
    Invoke-ValidatorCase `
        -Name "role change dispatches under unused finite owner extension" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    $exhaustedDispatch = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `5`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 3 5))
    )
    Set-Content -LiteralPath $handoffCopy -Value $exhaustedDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "exhausted ceiling rejects dispatch under finite owner extension" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Review round circuit breaker reached at 3; agent dispatch is not permitted')

    $replayedDispatch = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `4`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 0 3))
    )
    Set-Content -LiteralPath $handoffCopy -Value $replayedDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "replayed exhausted finite owner extension rejects dispatch" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Review round circuit breaker reached at 3; agent dispatch is not permitted')

    $ordinaryDispatchAtThree = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `3`'
    ).Replace(
        '- No formal review state changes.',
        '- No formal review state changes.' + "`n" + '- Task Owner decision: Task Owner Example 2026-10-02 authorized stopped for validator-mapped-items in chat'
    )
    Set-Content -LiteralPath $handoffCopy -Value $ordinaryDispatchAtThree -NoNewline
    Invoke-ValidatorCase `
        -Name "ordinary owner prose grants no budget capacity" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Review round circuit breaker reached at 3; agent dispatch is not permitted')

    foreach ($defectiveDecision in @(
        @{ Name = 'malformed'; Line = '- Task Owner decision: review-budget-extension owner without separators' },
        @{ Name = 'duplicate-key'; Line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; owner=Someone Else; date=2026-10-02; batch=validator-mapped-items; from=0; through=5; scope=budget recovery consumers; evidence=fixture decision' },
        @{ Name = 'cross-batch'; Line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; date=2026-10-02; batch=other-batch; from=0; through=5; scope=budget recovery consumers; evidence=fixture decision' },
        @{ Name = 'below-from'; Line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; date=2026-10-02; batch=validator-mapped-items; from=4; through=7; scope=budget recovery consumers; evidence=fixture decision' },
        @{ Name = 'overflow'; Line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; date=2026-10-02; batch=validator-mapped-items; from=0; through=99999999999999999999; scope=budget recovery consumers; evidence=fixture decision' },
        @{ Name = 'missing-ceiling'; Line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; date=2026-10-02; batch=validator-mapped-items; from=0; scope=budget recovery consumers; evidence=fixture decision' },
        @{ Name = 'unlimited'; Line = '- Task Owner decision: review-budget-extension; owner=Task Owner Example; date=2026-10-02; batch=validator-mapped-items; from=0; through=unlimited; scope=budget recovery consumers; evidence=fixture decision' }
    )) {
        $defectiveDispatch = $originalHandoff.Replace(
            '- Review round: `0`',
            '- Review round: `3`'
        ).Replace(
            '- No formal review state changes.',
            ('- No formal review state changes.' + "`n" + $defectiveDecision.Line)
        )
        Set-Content -LiteralPath $handoffCopy -Value $defectiveDispatch -NoNewline
        Invoke-ValidatorCase `
            -Name "$($defectiveDecision.Name) finite owner extension rejects dispatch" `
            -CurrentTaskRelativePath $currentTaskRelativePath `
            -HandoffRelativePath $handoffRelativePath `
            -ExpectedExitCode 1 `
            -ExpectedErrors @('Review round circuit breaker reached at 3; agent dispatch is not permitted')
    }

    $budgetTrailingProse = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `3`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" + (& $budgetDecisionFor 0 5) + "`n" + '- Completed verdicts stay 0; remaining allowance is owner-authorized.')
    )
    Set-Content -LiteralPath $handoffCopy -Value $budgetTrailingProse -NoNewline
    Invoke-ValidatorCase `
        -Name "finite owner extension with trailing review bullets still permits dispatch" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    $duplicateActiveThenExhausted = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `3`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" +
            (& $budgetDecisionFor 0 5) + "`n" +
            (& $budgetDecisionFor 5 5))
    )
    Set-Content -LiteralPath $handoffCopy -Value $duplicateActiveThenExhausted -NoNewline
    Invoke-ValidatorCase `
        -Name "duplicate active then exhausted owner decisions reject capacity" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('duplicate actual decision fields are not accepted')

    $duplicateActiveThenContrary = $originalHandoff.Replace(
        '- Review round: `0`',
        '- Review round: `3`'
    ).Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" +
            (& $budgetDecisionFor 0 5) + "`n" +
            '- Task Owner decision: Task Owner Example authorized close after review')
    )
    Set-Content -LiteralPath $handoffCopy -Value $duplicateActiveThenContrary -NoNewline
    Invoke-ValidatorCase `
        -Name "duplicate active then contrary owner decision rejects capacity" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('duplicate actual decision fields are not accepted')

    $duplicateNonWaitingContinue = Convert-ToNonDispatchHandoff `
        ($originalHandoff.Replace('- Review round: `0`', '- Review round: `3`')) `
        "continue"
    $duplicateNonWaitingContinue = $duplicateNonWaitingContinue.Replace(
        '- No formal review state changes.',
        ('- No formal review state changes.' + "`n" +
            (& $budgetDecisionFor 0 5) + "`n" +
            '- Task Owner decision: Task Owner Example authorized continue')
    )
    Set-Content -LiteralPath $handoffCopy -Value $duplicateNonWaitingContinue -NoNewline
    Invoke-ValidatorCase `
        -Name "duplicate owner decisions reject non-waiting continue capacity" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('duplicate actual decision fields are not accepted')

    $legacyStoppedAtBreaker = Convert-ToNonDispatchHandoff `
        ($originalHandoff.Replace('- Review round: `0`', '- Review round: `4`')) `
        "close"
    $legacyStoppedAtBreaker = $legacyStoppedAtBreaker.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Chief Designer`'
    ).Replace(
        '- Current agent: `validator test`',
        '- Current agent: `validator design`'
    ).Replace(
        '- No formal review state changes.',
        "- Closure outcome: ``stopped```n- Task Owner decision: ``Task Owner Example 2026-10-02 authorized stopped for validator-mapped-items in chat``"
    )
    Set-Content -LiteralPath $handoffCopy -Value $legacyStoppedAtBreaker -NoNewline
    Invoke-ValidatorCase `
        -Name "legacy stopped close with ordinary text decision still passes at circuit breaker" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings

    # Warning fixture 1: unanchored collaboration handbook in Required Reading
    $unanchoredHandbookTask = $originalCurrentTask.Replace(
        '- `docs/ai-collaboration/workflows.md#6-implementation`',
        '- `docs/ai-collaboration/workflows.md`'
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $unanchoredHandbookTask -NoNewline
    Invoke-ValidatorCase `
        -Name "unanchored collaboration handbook in Required Reading emits warning" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectedWarnings @(
            "$currentTaskRelativePath Required Reading references collaboration handbook without section anchor: docs/ai-collaboration/workflows.md"
        )
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    # Warning fixture 2: anchored collaboration handbook produces no warning
    $anchoredHandbookTask = $originalCurrentTask.Replace(
        '- `openspec/changes/validator-change/tasks.md`',
        '- `docs/ai-collaboration/README.md#token-efficiency-guardrails`'
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $anchoredHandbookTask -NoNewline
    Invoke-ValidatorCase `
        -Name "anchored collaboration handbook in Required Reading produces no warning" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    # Warning fixture 3: non-collaboration README produces no warning
    $nonCollaborationReadmeTask = $originalCurrentTask.Replace(
        '- `openspec/changes/validator-change/tasks.md`',
        '- `docs/reviews/README.md`'
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $nonCollaborationReadmeTask -NoNewline
    Invoke-ValidatorCase `
        -Name "non-collaboration README in Required Reading produces no warning" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectNoWarnings
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    # Warning fixture 4: oversized current-task file (> 12 KiB)
    $oversizedCurrentTaskPadding = "`n" + ("- Detailed constraint note line padding for size test`n" * 250)
    $oversizedCurrentTask = $originalCurrentTask.Replace(
        "## Constraints",
        "## Constraints$oversizedCurrentTaskPadding"
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $oversizedCurrentTask -NoNewline
    Invoke-ValidatorCase `
        -Name "oversized current-task emits advisory warning without failing" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectedWarnings @(
            "$currentTaskRelativePath size",
            "exceeds advisory 12 KiB threshold"
        )
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    # Warning fixture 5: oversized handoff file (> 8 KiB)
    $oversizedHandoffPadding = "`n" + ("- Detailed risk note line padding for size test`n" * 200)
    $oversizedHandoff = $originalHandoff.Replace(
        "## Known Risks",
        "## Known Risks$oversizedHandoffPadding"
    )
    Set-Content -LiteralPath $handoffCopy -Value $oversizedHandoff -NoNewline
    Invoke-ValidatorCase `
        -Name "oversized handoff emits advisory warning without failing" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0 `
        -ExpectedWarnings @(
            "$handoffRelativePath size",
            "exceeds advisory 8 KiB threshold"
        )
    Set-Content -LiteralPath $handoffCopy -Value $originalHandoff -NoNewline

    # Requirements Analyst fixture 1: Task Intake uses the conditional role
    # as the Initial role for material business ambiguity.
    $taskIntakeRequirementsTask = $originalCurrentTask.Replace(
        '- Initial role: `Implementation Engineer`',
        '- Initial role: `Requirements Analyst`'
    )
    $taskIntakeRequirementsTask = $taskIntakeRequirementsTask.Replace(
        'Validate a self-contained runtime-state fixture.',
        'Clarify an ambiguous request whose business goal and desired behavior cannot yet be safely summarized.'
    )
    $taskIntakeRequirementsHandoff = $originalHandoff
    $taskIntakeRequirementsHandoff = $taskIntakeRequirementsHandoff.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Task Intake`'
    )
    $taskIntakeRequirementsHandoff = $taskIntakeRequirementsHandoff.Replace(
        '- Next role: `Code Reviewer`',
        '- Next role: `Requirements Analyst`'
    )
    $taskIntakeRequirementsHandoff = $taskIntakeRequirementsHandoff.Replace(
        '- Recommended next agent: `validator test`',
        '- Recommended next agent: `validator requirements`'
    )
    $taskIntakeRequirementsHandoff = $taskIntakeRequirementsHandoff.Replace(
        'You are the Code Reviewer for Execution Batch validator-mapped-items.',
        'You are the Requirements Analyst for Execution Batch validator-mapped-items.'
    )
    $taskIntakeRequirementsHandoff = $taskIntakeRequirementsHandoff.Replace(
        '#code-reviewer',
        '#requirements-analyst'
    )
    $taskIntakeRequirementsHandoff = $taskIntakeRequirementsHandoff.Replace(
        'The fixture implementation is ready for review.',
        'Task Intake identified material business ambiguity and is routing the request for clarification.'
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $taskIntakeRequirementsTask -NoNewline
    Set-Content -LiteralPath $handoffCopy -Value $taskIntakeRequirementsHandoff -NoNewline
    Invoke-ValidatorCase `
        -Name "Requirements Analyst Task Intake material-ambiguity dispatch" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    # Requirements Analyst fixture 2: owner clarification stays on the
    # existing continue and awaiting-owner-decision path.
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline
    $requirementsDispatchHandoff = $originalHandoff.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Requirements Analyst`'
    )
    $requirementsDispatchHandoff = $requirementsDispatchHandoff.Replace(
        "## Authoritative Evidence",
        "## Authoritative Evidence`n`n- " + '`.ai/requirement-baseline.md`'
    )
    $requirementsOwnerWait = Convert-ToNonDispatchHandoff `
        $requirementsDispatchHandoff `
        "continue"
    $requirementsOwnerWait = $requirementsOwnerWait.Replace(
        '- Current status: `ready-for-review`',
        '- Current status: `awaiting-owner-decision`'
    )
    $requirementsOwnerWait = $requirementsOwnerWait.Replace(
        'The fixture implementation is ready for review.',
        'Requirements Analyst asks the owner to confirm the concise goal, must-haves, acceptance, non-goal, and open questions.'
    )
    $requirementsOwnerWait += @'

## Owner Decision Brief

- Decision needed: `confirm the concise business baseline`
- Recommendation: `confirm because the material ambiguity is resolved`
- Alternatives: `correct the goal, acceptance, or non-goal summary; Consequence: re-clarify the unconfirmed items`
- Reply needed: `confirm or correct`
- After the reply: `record the decision and continue the same role`
'@
    Set-Content -LiteralPath $handoffCopy -Value $requirementsOwnerWait -NoNewline
    Invoke-ValidatorCase `
        -Name "Requirements Analyst owner-decision wait" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $baselineConfirmedFixture = $baselineDraftFixture.Replace(
        '`draft`',
        '`confirmed`'
    ).Replace(
        'pending owner confirmation.',
        'Owner explicitly confirmed the business baseline.'
    ).Replace(
        'pending; keep maturity `confirmed`.',
        'recorded; maturity is `confirmed`.'
    )
    Set-Content -LiteralPath $baselineFixturePath -Value $baselineConfirmedFixture -NoNewline

    # Requirements Analyst fixture 3: explicit confirmation exits only to
    # Chief Designer.
    $requirementsChiefHandoff = $requirementsDispatchHandoff.Replace(
        '- Next role: `Code Reviewer`',
        '- Next role: `Chief Designer`'
    )
    $requirementsChiefHandoff = $requirementsChiefHandoff.Replace(
        '- Recommended next agent: `validator test`',
        '- Recommended next agent: `validator design`'
    )
    $requirementsChiefHandoff = $requirementsChiefHandoff.Replace(
        'You are the Code Reviewer for Execution Batch validator-mapped-items.',
        'You are the Chief Designer for Execution Batch validator-mapped-items.'
    )
    $requirementsChiefHandoff = $requirementsChiefHandoff.Replace(
        '#code-reviewer',
        '#chief-designer'
    )
    $requirementsChiefHandoff = $requirementsChiefHandoff.Replace(
        'The fixture implementation is ready for review.',
        'The owner explicitly confirmed the concise business baseline; Chief Designer must reconcile it before design.'
    )
    Set-Content -LiteralPath $handoffCopy -Value $requirementsChiefHandoff -NoNewline
    Invoke-ValidatorCase `
        -Name "Requirements Analyst confirmed dispatch to Chief Designer" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    # Requirements Analyst fixture 4: direct implementation dispatch is
    # rejected by the narrow role-exit allowlist.
    $requirementsIllegalHandoff = $requirementsChiefHandoff.Replace(
        '- Next role: `Chief Designer`',
        '- Next role: `Implementation Engineer`'
    )
    $requirementsIllegalHandoff = $requirementsIllegalHandoff.Replace(
        '- Recommended next agent: `validator design`',
        '- Recommended next agent: `validator implementation`'
    )
    $requirementsIllegalHandoff = $requirementsIllegalHandoff.Replace(
        'You are the Chief Designer for Execution Batch validator-mapped-items.',
        'You are the Implementation Engineer for Execution Batch validator-mapped-items.'
    )
    $requirementsIllegalHandoff = $requirementsIllegalHandoff.Replace(
        '#chief-designer',
        '#implementation-engineer'
    )
    Set-Content -LiteralPath $handoffCopy -Value $requirementsIllegalHandoff -NoNewline
    Invoke-ValidatorCase `
        -Name "Requirements Analyst direct dispatch to Implementation Engineer rejected" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline
    Set-Content -LiteralPath $handoffCopy -Value $originalHandoff -NoNewline

    $missingMappedItem = $originalCurrentTask.Replace(
        '  - `1.2a.1`',
        '  - `9.9`'
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $missingMappedItem -NoNewline
    Invoke-ValidatorCase `
        -Name "mapped OpenSpec item missing from tasks file" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    $legalAngleBrackets = $originalCurrentTask.Replace(
        "## Required Checks",
        "Legal technical text: <noreply@example.com>, <br>, and x < y > z.`n`n## Required Checks"
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $legalAngleBrackets -NoNewline
    Invoke-ValidatorCase `
        -Name "legal angle-bracket content" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $actualPlaceholder = $originalCurrentTask.Replace(
        "- Task ID:",
        "- Placeholder check: `<task-id>``n- Task ID:"
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $actualPlaceholder -NoNewline
    Invoke-ValidatorCase `
        -Name "known template placeholder" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $wrongBatchCommand = $originalHandoff.Replace(
        "Execution Batch $batchId",
        "Execution Batch wrong-batch"
    )
    Set-Content -LiteralPath $handoffCopy -Value $wrongBatchCommand -NoNewline
    Invoke-ValidatorCase `
        -Name "Operator Command without current batch ID" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline
    $incompleteCommand = $originalHandoff.Replace(
        "Objective: review the current batch.",
        "Goal: review the current batch."
    )
    Set-Content -LiteralPath $handoffCopy -Value $incompleteCommand -NoNewline
    Invoke-ValidatorCase `
        -Name "dispatch with incomplete Operator Command" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingPromptAnchor = $originalHandoff.Replace(
        "#code-reviewer",
        "#missing-role"
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingPromptAnchor -NoNewline
    Invoke-ValidatorCase `
        -Name "dispatch with missing prompt anchor" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidCurrentRole = $originalHandoff.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Implementaton Engineer`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidCurrentRole -NoNewline
    Invoke-ValidatorCase `
        -Name "handoff with undefined current role" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingEvidence = $originalHandoff.Replace(
        "## Authoritative Evidence",
        "## Authoritative Evidence`n`n" + '- `.ai/missing-evidence.md`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingEvidence -NoNewline
    Invoke-ValidatorCase `
        -Name "handoff with missing authoritative evidence" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $validResultReference = $originalHandoff.Replace(
        "## Authoritative Evidence",
        "## Authoritative Evidence`n`n" + '- `' + $resultRelativePath + '`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $validResultReference -NoNewline
    Invoke-ValidatorCase `
        -Name "handoff with valid referenced result" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $invalidResult = (
        Get-Content -LiteralPath $resultFullPath -Raw
    ).Replace("## Checks Run", "## Missing Checks")
    Set-Content -LiteralPath $resultFullPath -Value $invalidResult -NoNewline
    Set-Content -LiteralPath $handoffCopy -Value $validResultReference -NoNewline
    Invoke-ValidatorCase `
        -Name "handoff with malformed referenced result" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $longStatus = (
        1..80 |
            ForEach-Object { "- Referenced evidence item $_" }
    ) -join "`n"
    $longHandoff = $originalHandoff.Replace(
        "## Delta Since Last Handoff",
        "$longStatus`n`n## Delta Since Last Handoff"
    )
    Set-Content -LiteralPath $handoffCopy -Value $longHandoff -NoNewline
    Invoke-ValidatorCase `
        -Name "long structured handoff" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    Set-Content -LiteralPath $handoffCopy -Value $originalHandoff -NoNewline
    $validContinue = Convert-ToNonDispatchHandoff $originalHandoff "continue"
    Set-Content -LiteralPath $handoffCopy -Value $validContinue -NoNewline
    Invoke-ValidatorCase `
        -Name "valid continue" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $validAwaitingOwner = $validContinue.Replace(
        '- Current status: `ready-for-review`',
        '- Current status: `awaiting-owner-decision`'
    )
    if ($validAwaitingOwner -notmatch "(?m)^## Owner Decision Brief\s*$") {
        $validAwaitingOwner += @'

## Owner Decision Brief

- Decision needed: `approve the bounded scope`
- Recommendation: `approve because acceptance evidence is complete; Reason: all required checks passed`
- Alternatives: `revise scope; Consequence: rerun Task Intake and update the task baseline`
- Reply needed: `approve or revise`
- After the reply: `record the decision and continue the same role`
'@
    }
    Set-Content -LiteralPath $handoffCopy -Value $validAwaitingOwner -NoNewline
    Invoke-ValidatorCase `
        -Name "valid awaiting owner decision" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $invalidAwaitingDispatch = $originalHandoff.Replace(
        '- Current status: `ready-for-review`',
        '- Current status: `awaiting-owner-decision`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidAwaitingDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "awaiting owner decision with dispatch" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingOwnerBrief = [regex]::Replace(
        $validAwaitingOwner,
        "(?ms)\r?\n## Owner Decision Brief\s*\r?\n.*?(?=^## |\z)",
        ""
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingOwnerBrief -NoNewline
    Invoke-ValidatorCase `
        -Name "awaiting owner decision without brief" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingOwnerRecommendation = $validAwaitingOwner.Replace(
        "- Recommendation:",
        "- Suggested:"
    )
    Set-Content `
        -LiteralPath $handoffCopy `
        -Value $missingOwnerRecommendation `
        -NoNewline
    Invoke-ValidatorCase `
        -Name "owner decision brief missing one field" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $validTaskIntakeWait = $validAwaitingOwner.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Task Intake`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $validTaskIntakeWait -NoNewline
    Invoke-ValidatorCase `
        -Name "valid Task Intake owner wait" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $invalidTaskIntakeDispatch = $originalHandoff.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Task Intake`'
    )
    Set-Content `
        -LiteralPath $handoffCopy `
        -Value $invalidTaskIntakeDispatch `
        -NoNewline
    Invoke-ValidatorCase `
        -Name "Task Intake dispatches non-initial role" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    # Human decision dispatch fixtures
    $validHumanDispatchBase = @'
# Handoff

## Routing

- Next action: `dispatch`
- Current role: `Implementation Engineer`
- Current agent: `validator test`
- Current status: `awaiting-owner-decision`
- Review round: `0`
- Next role: `Task Owner`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

Implementation paused awaiting owner decision on optional caching.

## Delta Since Last Handoff

- Identified need for owner decision.

## Authoritative Evidence

- `.ai/current-task.md`

## Known Risks

- None beyond owner decision.

## Blockers

- Pending owner decision.

## Owner Decision Brief

- Decision needed: `choose cache expiration strategy`
- Recommendation: `use 30-day TTL; Reason: matches user session expectation`
- Alternatives: `no caching; Consequence: increases query load`
- Reply needed: `30-day TTL`
- After the reply: `Implementation Engineer will update cache configuration`

## Review Or Task State Impact

- No formal review state changes.
'@

    Set-Content -LiteralPath $handoffCopy -Value $validHumanDispatchBase -NoNewline
    Invoke-ValidatorCase `
        -Name "valid human decision dispatch - Task Owner" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $validUserDispatch = $validHumanDispatchBase.Replace(
        '- Next role: `Task Owner`',
        '- Next role: `User`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $validUserDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "valid human decision dispatch - User" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $validDataOwnerDispatch = $validHumanDispatchBase.Replace(
        '- Next role: `Task Owner`',
        '- Next role: `Data Owner`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $validDataOwnerDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "valid human decision dispatch - Data Owner" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $validTaskIntakeHumanDispatch = $validHumanDispatchBase.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Task Intake`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $validTaskIntakeHumanDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "valid human decision dispatch - Task Intake" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $validRequirementsHumanDispatch = $validHumanDispatchBase.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Requirements Analyst`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $validRequirementsHumanDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "valid human decision dispatch - Requirements Analyst" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $invalidHumanRecipient = $validHumanDispatchBase.Replace(
        '- Next role: `Task Owner`',
        '- Next role: `Product Manager`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanRecipient -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection of recipient outside exact human allowlist" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingRecReason = $validHumanDispatchBase.Replace(
        '; Reason: matches user session expectation',
        ''
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingRecReason -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when recommendation reason is missing" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingAltConsequence = $validHumanDispatchBase.Replace(
        '; Consequence: increases query load',
        '; increases query load'
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingAltConsequence -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when alternative consequence is missing" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingExactReply = $validHumanDispatchBase.Replace(
        '- Reply needed: `30-day TTL`',
        '- Reply needed: 30-day TTL'
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingExactReply -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when exact reply structure is missing" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidHumanNextAgent = $validHumanDispatchBase.Replace(
        '- Recommended next agent: `none`',
        '- Recommended next agent: `validator test`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanNextAgent -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch contains non-none next agent" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidHumanNextInput = $validHumanDispatchBase.Replace(
        '- Next input files: `none`',
        ("- Next input files:`r`n  - " + '`.ai/current-task.md`')
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanNextInput -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch contains non-none next input files" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidHumanNextOutput = $validHumanDispatchBase.Replace(
        '- Next output files: `none`',
        ("- Next output files:`r`n  - " + '`.ai/handoff.md`')
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanNextOutput -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch contains non-none next output files" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidHumanNextPrompt = $validHumanDispatchBase.Replace(
        '- Next prompt template: `none`',
        ("- Next prompt template:`r`n  - " + '`docs/ai-collaboration/agent-prompts.md#task-owner`')
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanNextPrompt -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch contains non-none next prompt template" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidHumanCommand = $validHumanDispatchBase + @'

## Operator Command
```text
You are the Task Owner for Execution Batch validator-mapped-items.
Read: .ai/current-task.md.
Objective: answer the question.
Constraints: none.
Output: none.
Follow: docs/ai-collaboration/agent-prompts.md#task-owner.
```
'@
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanCommand -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch contains Operator Command" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidHumanArtifactAssignment = $validHumanDispatchBase.Replace(
        '- After the reply: `Implementation Engineer will update cache configuration`',
        '- After the reply: `Task Owner will update .ai/handoff.md with the decision`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidHumanArtifactAssignment -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch contains forbidden human artifact assignment" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $missingBriefHumanDispatch = [regex]::Replace(
        $validHumanDispatchBase,
        "(?ms)\r?\n## Owner Decision Brief\s*\r?\n.*?(?=^## |\z)",
        ""
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingBriefHumanDispatch -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch lacks Owner Decision Brief" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidCurrentRoleShape = $validHumanDispatchBase.Replace(
        '- Current role: `Implementation Engineer`',
        '- Current role: `Task Owner`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidCurrentRoleShape -NoNewline
    Invoke-ValidatorCase `
        -Name "rejection when human dispatch changes responsible Current role/agent shape" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $validClose = Convert-ToNonDispatchHandoff $originalHandoff "close"
    Set-Content -LiteralPath $handoffCopy -Value $validClose -NoNewline
    Invoke-ValidatorCase `
        -Name "valid close" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 0

    $invalidCloseMetrics = $validClose.Replace(
        '- Role actions: `3`',
        '- Role actions: `three`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidCloseMetrics -NoNewline
    Invoke-ValidatorCase `
        -Name "close with non-integer metrics" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @('Process Metrics requires integer or unknown: Role actions')

    # Partial known costs must not force users to fill unknown-only paperwork.
    # Invalid supplied counts and closure guards remain separate checks below.
    foreach ($actionFixture in @(
        @{ Action = 'dispatch'; Handoff = $originalHandoff },
        @{ Action = 'continue'; Handoff = $validContinue },
        @{ Action = 'close'; Handoff = [regex]::Replace($validClose, '(?ms)^## Process Metrics.*\z', '').TrimEnd() }
    )) {
        foreach ($metricsSuffix in @('', "`n`n## Process Metrics`n- Role actions: ``2``")) {
            Set-Content -LiteralPath $handoffCopy -Value ($actionFixture.Handoff + $metricsSuffix) -NoNewline
            $metricsKind = if ($metricsSuffix) { 'partial known metrics' } else { 'no metrics' }
            $expectedMetricWarnings = if ($actionFixture.Action -eq 'close') { @('Legacy close has no Closure outcome') } else { @() }
            Invoke-ValidatorCase "optional metrics $($actionFixture.Action) with $metricsKind passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectedWarnings $expectedMetricWarnings -ExpectNoWarnings:($actionFixture.Action -ne 'close')
        }
    }

    foreach ($metricName in @(
        "Review/fix/verification loops",
        "Broad regression runs"
    )) {
        $invalidMetric = $validClose.Replace(
            "- ${metricName}: ``1``",
            "- ${metricName}: ``invalid``"
        )
        Set-Content -LiteralPath $handoffCopy -Value $invalidMetric -NoNewline
        Invoke-ValidatorCase `
            -Name "close with non-integer $metricName" `
            -CurrentTaskRelativePath $currentTaskRelativePath `
            -HandoffRelativePath $handoffRelativePath `
            -ExpectedExitCode 1 `
            -ExpectedErrors @("Process Metrics requires integer or unknown: $metricName")
    }

    # Lean workflow regressions use only this disposable fixture workspace.
    $tasksCopy = Join-Path $tempRoot "openspec\changes\validator-change\tasks.md"
    $acceptedClose = $validClose.Replace(
        '- No formal review state changes.',
        '- Closure outcome: `accepted`'
    ).Replace('- Current role: `Implementation Engineer`', '- Current role: `Code Reviewer`')
    Set-Content -LiteralPath $handoffCopy -Value $acceptedClose -NoNewline
    Invoke-ValidatorCase "accepted cannot conceal unfinished mapped tasks" $currentTaskRelativePath $handoffRelativePath 1

    $ownerAcceptanceFields = (
        "- Acceptance basis: " + [char]96 + "owner-decision" + [char]96 + [Environment]::NewLine +
        "- Task Owner decision: " + [char]96 + "Task Owner Example 2026-10-05 authorized accepted for validator-mapped-items in chat" + [char]96 + [Environment]::NewLine +
        [Environment]::NewLine + "## Operator Command"
    )
    $ownerAcceptedClose = $acceptedClose.Replace(
        '- Current role: `Code Reviewer`',
        '- Current role: `Chief Designer`'
    ).Replace("## Process Metrics", $ownerAcceptanceFields.Replace("## Operator Command", "## Process Metrics"))
    Set-Content -LiteralPath $handoffCopy -Value $ownerAcceptedClose -NoNewline
    Invoke-ValidatorCase "owner-authorized accepted closure permits incomplete mapped tasks" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    # An owner acceptance marker must not be carried as approval on an active dispatch.
    $dispatchWithAcceptance = $originalHandoff.Replace(
        '## Review Or Task State Impact',
        "## Review Or Task State Impact`n`n- Acceptance basis: owner-decision"
    )
    Set-Content -LiteralPath $handoffCopy -Value $dispatchWithAcceptance -NoNewline
    Invoke-ValidatorCase "owner acceptance basis cannot authorize active dispatch" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Acceptance basis is only valid for accepted close')

    $ownerAcceptanceMissingDecision = $ownerAcceptedClose.Replace(
        "- Task Owner decision: " + [char]96 + "Task Owner Example 2026-10-05 authorized accepted for validator-mapped-items in chat" + [char]96 + [Environment]::NewLine,
        ""
    )
    Set-Content -LiteralPath $handoffCopy -Value $ownerAcceptanceMissingDecision -NoNewline
    Invoke-ValidatorCase "owner-authorized accepted closure requires decision" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Owner-decision accepted closure requires Task Owner decision in Review Or Task State Impact')

    $ownerAcceptanceWrongRole = $ownerAcceptedClose.Replace(
        '- Current role: `Chief Designer`',
        '- Current role: `Code Reviewer`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $ownerAcceptanceWrongRole -NoNewline
    Invoke-ValidatorCase "owner-authorized accepted closure requires Chief Designer" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Owner-decision accepted closure requires Chief Designer disposition')

    $invalidAcceptanceBasis = $ownerAcceptedClose.Replace(
        "- Acceptance basis: " + [char]96 + "owner-decision" + [char]96,
        "- Acceptance basis: " + [char]96 + "test-only" + [char]96
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidAcceptanceBasis -NoNewline
    Invoke-ValidatorCase "accepted closure rejects unsupported acceptance basis" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Accepted closure Acceptance basis must be owner-decision when supplied')

    $ownerAcceptanceAtCircuitBreaker = $ownerAcceptedClose.Replace('- Review round: `0`', '- Review round: `3`')
    Set-Content -LiteralPath $handoffCopy -Value $ownerAcceptanceAtCircuitBreaker -NoNewline
    Invoke-ValidatorCase "owner-authorized accepted closure remains permitted at circuit breaker" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    # CR-CB-01: a later subsection cannot authorize closing incomplete mapped tasks.
    $ownerDecisionLine = '- Task Owner decision: ' + [char]96 +
        'Task Owner Example 2026-10-05 authorized accepted for validator-mapped-items in chat' + [char]96
    foreach ($headingLevel in @(3, 4)) {
        foreach ($emptyDecision in @(
            @{ Name = 'empty'; Value = '' },
            @{ Name = 'none'; Value = 'none' },
            @{ Name = 'space'; Value = ' ' },
            @{ Name = 'tab'; Value = "`t" }
        )) {
            $nonAuthorization = '- Task Owner decision:' + $emptyDecision.Value + "`n" +
                ('#' * $headingLevel) + " Verification limits`nNo Task Owner authorization has been supplied."
            $invalidOwnerSubsection = $ownerAcceptedClose.Replace($ownerDecisionLine, $nonAuthorization)
            Set-Content -LiteralPath $handoffCopy -Value $invalidOwnerSubsection -NoNewline
            Invoke-ValidatorCase "CR-CB-01 accepted $($emptyDecision.Name) before heading $headingLevel rejects borrowed authorization" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Owner-decision accepted closure requires Task Owner decision in Review Or Task State Impact')
        }
    }
    foreach ($titleTail in @(
        @{ Name = 'empty'; Value = '' },
        @{ Name = 'space'; Value = ' ' },
        @{ Name = 'tab'; Value = "`t" }
    )) {
        $validDecision = '- Task Owner decision:' + $titleTail.Value +
            "`n  Task Owner Example 2026-10-05 authorized accepted for validator-mapped-items in chat`n  via recorded decision`n### Verification limits`nRemaining acceptance stays unchecked."
        $validOwnerSubsection = $ownerAcceptedClose.Replace($ownerDecisionLine, $validDecision)
        Set-Content -LiteralPath $handoffCopy -Value $validOwnerSubsection -NoNewline
        Invoke-ValidatorCase "CR-CB-01 accepted multiline $($titleTail.Name) before subsection passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    }
    $fencedDecision = $ownerDecisionLine + "`n" + @'
```text
### Authorization evidence note
#### Nested evidence note
```
  Existing owner decision remains applicable.
### Verification limits
Remaining acceptance stays unchecked.
'@
    Set-Content -LiteralPath $handoffCopy -Value $ownerAcceptedClose.Replace($ownerDecisionLine, $fencedDecision) -NoNewline
    Invoke-ValidatorCase "CR-CB-01 accepted fenced heading content remains valid" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    $doneTasks = $tasksFixture.Replace('[ ]', '[x]') + "`n- [ ] 9.1 Unrelated parent work remains pending."
    Set-Content -LiteralPath $tasksCopy -Value $doneTasks -NoNewline
    Invoke-ValidatorCase "accepted batch does not require entire parent completion" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    $selfClose = $acceptedClose.Replace('- Current role: `Code Reviewer`', '- Current role: `Fix Engineer`')
    Set-Content -LiteralPath $handoffCopy -Value $selfClose -NoNewline
    Invoke-ValidatorCase "M fixer cannot self-accept" $currentTaskRelativePath $handoffRelativePath 1
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask.Replace('Risk level: `M`', 'Risk level: `S`') -NoNewline
    Invoke-ValidatorCase "S user-reported fix closes without formal review artifact" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline
    Set-Content -LiteralPath $tasksCopy -Value $tasksFixture -NoNewline

    foreach ($outcome in @('stopped', 'superseded')) {
        $decisionText = "`n- Task Owner decision: ``Task Owner Example 2026-10-02 authorized $($outcome) for validator-mapped-items in chat``"
        $endedWithDecision = $acceptedClose.Replace('`accepted`', ('`' + $outcome + '`' + $decisionText)).Replace(
            '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
        )
        Set-Content -LiteralPath $handoffCopy -Value $endedWithDecision -NoNewline
        Invoke-ValidatorCase "$outcome preserves unfinished acceptance" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

        $multilineDecisionText = "`n- Task Owner decision:`n  Task Owner Example 2026-10-02 authorized $($outcome) for validator-mapped-items in chat`n  via meeting record"
        $endedWithMultilineDecision = $acceptedClose.Replace('`accepted`', ('`' + $outcome + '`' + $multilineDecisionText)).Replace(
            '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
        )
        Set-Content -LiteralPath $handoffCopy -Value $endedWithMultilineDecision -NoNewline
        Invoke-ValidatorCase "$outcome with multiline Task Owner decision passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

        $endedWithBorrowedSubsection = $endedWithDecision.Replace(
            $decisionText,
            "`n- Task Owner decision:`n### Verification limits`nNo Task Owner authorization has been supplied."
        )
        Set-Content -LiteralPath $handoffCopy -Value $endedWithBorrowedSubsection -NoNewline
        Invoke-ValidatorCase "CR-CB-01 $outcome rejects borrowed subsection authorization" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact')

        $endedWithoutDecision = $acceptedClose.Replace('`accepted`', ('`' + $outcome + '`')).Replace(
            '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
        )
        Set-Content -LiteralPath $handoffCopy -Value $endedWithoutDecision -NoNewline
        Invoke-ValidatorCase `
            -Name "$outcome without Task Owner decision fails" `
            -CurrentTaskRelativePath $currentTaskRelativePath `
            -HandoffRelativePath $handoffRelativePath `
            -ExpectedExitCode 1 `
            -ExpectedErrors @("Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact")

        $emptyDecisionWithFollowingField = "``$outcome```n- Task Owner decision:`n- Review summary: No approval has been received."
        $endedEmptyDecisionWithFollowingField = $acceptedClose.Replace('`accepted`', $emptyDecisionWithFollowingField).Replace(
            '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
        )
        Set-Content -LiteralPath $handoffCopy -Value $endedEmptyDecisionWithFollowingField -NoNewline
        Invoke-ValidatorCase `
            -Name "$outcome with empty Task Owner decision followed by review summary fails" `
            -CurrentTaskRelativePath $currentTaskRelativePath `
            -HandoffRelativePath $handoffRelativePath `
            -ExpectedExitCode 1 `
            -ExpectedErrors @("Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact")

        $emptyDecisionOnly = "``$outcome```n- Task Owner decision:   "
        $endedEmptyDecisionOnly = $acceptedClose.Replace('`accepted`', $emptyDecisionOnly).Replace(
            '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
        )
        Set-Content -LiteralPath $handoffCopy -Value $endedEmptyDecisionOnly -NoNewline
        Invoke-ValidatorCase `
            -Name "$outcome with whitespace-only Task Owner decision fails" `
            -CurrentTaskRelativePath $currentTaskRelativePath `
            -HandoffRelativePath $handoffRelativePath `
            -ExpectedExitCode 1 `
            -ExpectedErrors @("Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact")

        foreach ($sep in @(@{ Name = "space"; Char = " " }, @{ Name = "tab"; Char = "`t" })) {
            $sepName = $sep.Name
            $sepChar = $sep.Char

            $validIndentedContinuation = "`n- Task Owner decision:$sepChar`n  Task Owner Example 2026-10-02 authorized $($outcome) for validator-mapped-items in chat"
            $endedWithValidContinuation = $acceptedClose.Replace('`accepted`', ('`' + $outcome + '`' + $validIndentedContinuation)).Replace(
                '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
            )
            Set-Content -LiteralPath $handoffCopy -Value $endedWithValidContinuation -NoNewline
            Invoke-ValidatorCase "$outcome with $sepName after colon and valid indented continuation passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

            $whitespaceOnlyContinuation = "`n- Task Owner decision:$sepChar`n    `n- Review summary: No approval has been received."
            $endedWithWhitespaceOnlyContinuation = $acceptedClose.Replace('`accepted`', ('`' + $outcome + '`' + $whitespaceOnlyContinuation)).Replace(
                '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
            )
            Set-Content -LiteralPath $handoffCopy -Value $endedWithWhitespaceOnlyContinuation -NoNewline
            Invoke-ValidatorCase `
                -Name "$outcome with $sepName after colon and whitespace-only continuation fails" `
                -CurrentTaskRelativePath $currentTaskRelativePath `
                -HandoffRelativePath $handoffRelativePath `
                -ExpectedExitCode 1 `
                -ExpectedErrors @("Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact")

            $followingFieldContinuation = "`n- Task Owner decision:$sepChar`n- Review summary: No approval has been received."
            $endedWithFollowingFieldContinuation = $acceptedClose.Replace('`accepted`', ('`' + $outcome + '`' + $followingFieldContinuation)).Replace(
                '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
            )
            Set-Content -LiteralPath $handoffCopy -Value $endedWithFollowingFieldContinuation -NoNewline
            Invoke-ValidatorCase `
                -Name "$outcome with $sepName after colon followed immediately by review summary fails" `
                -CurrentTaskRelativePath $currentTaskRelativePath `
                -HandoffRelativePath $handoffRelativePath `
                -ExpectedExitCode 1 `
                -ExpectedErrors @("Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact")
        }

        foreach ($badDecision in @('none', 'pending', 'unknown')) {
            $replacementText = "``$outcome```n- Task Owner decision: ``$badDecision``"
            $endedBadDecision = $acceptedClose.Replace('`accepted`', $replacementText).Replace(
                '- Current role: `Code Reviewer`', '- Current role: `Chief Designer`'
            )
            Set-Content -LiteralPath $handoffCopy -Value $endedBadDecision -NoNewline
            Invoke-ValidatorCase `
                -Name "$outcome with Task Owner decision $badDecision fails" `
                -CurrentTaskRelativePath $currentTaskRelativePath `
                -HandoffRelativePath $handoffRelativePath `
                -ExpectedExitCode 1 `
                -ExpectedErrors @("Stopped or superseded closure requires Task Owner decision in Review Or Task State Impact")
        }

        $endedNonChief = $endedWithDecision.Replace('- Current role: `Chief Designer`', '- Current role: `Code Reviewer`')
        Set-Content -LiteralPath $handoffCopy -Value $endedNonChief -NoNewline
        Invoke-ValidatorCase "$outcome closure by non-Chief Designer fails" $currentTaskRelativePath $handoffRelativePath 1
    }

    $envSectionPendingNeeded = @'

## Environment Preparation

### WebForms page verification
- Readiness: `pending`
- Needed before next action: `yes`
- Human action: Launch WebForms debugging in Visual Studio and keep IIS Express running.
- Confirmation and check: Reply started once ready, then verify http://localhost:3000/ is reachable.
- Work that can proceed: none
'@

    $envSectionPendingNotNeeded = @'

## Environment Preparation

### WebForms page verification
- Readiness: `pending`
- Needed before next action: `no`
- Human action: Launch WebForms debugging in Visual Studio and keep IIS Express running before page checks.
- Confirmation and check: Reply started once ready, then verify http://localhost:3000/ is reachable.
- Work that can proceed: Code edits and offline tests can proceed.
'@

    $envSectionReadyNeeded = @'

## Environment Preparation

### WebForms page verification
- Readiness: `ready`
- Needed before next action: `yes`
- Human action: Launch WebForms debugging in Visual Studio and keep IIS Express running.
- Confirmation and check: Verified http://localhost:3000/ returned HTTP 200.
- Work that can proceed: Page verification can proceed.
'@

    $envSectionMultiPrereqFirstReadySecondPending = @'

## Environment Preparation

### WebForms page verification
- Readiness: `ready`
- Needed before next action: `yes`
- Human action: Launch WebForms debugging in Visual Studio and keep IIS Express running.
- Confirmation and check: Verified http://localhost:3000/ returned HTTP 200.
- Work that can proceed: Page verification can proceed.

### Database test instance
- Readiness: `pending`
- Needed before next action: `yes`
- Human action: Ensure local SQL Server test instance is running.
- Confirmation and check: Test connection string connects successfully.
- Work that can proceed: none
'@

    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionPendingNeeded) -NoNewline
    Invoke-ValidatorCase "agent dispatch rejected when prerequisite is pending and needed" $currentTaskRelativePath $handoffRelativePath 1

    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionPendingNeeded.Replace('`pending`', '`unknown`')) -NoNewline
    Invoke-ValidatorCase "agent dispatch rejected when prerequisite is unknown and needed" $currentTaskRelativePath $handoffRelativePath 1

    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionMultiPrereqFirstReadySecondPending) -NoNewline
    Invoke-ValidatorCase "agent dispatch rejected when second prerequisite is pending and needed" $currentTaskRelativePath $handoffRelativePath 1

    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionPendingNotNeeded) -NoNewline
    Invoke-ValidatorCase "safe offline dispatch allowed when prerequisite not needed before next action" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    # Autonomous continuation uses synthetic state only; no host process is started.
    $continuationBlock = @'

### Continuation Command

```text
You are continuing as Implementation Engineer for Execution Batch validator-mapped-items.
Read: .ai/current-task.md, .ai/handoff.md and the mapped OpenSpec tasks.
Objective: finish the authorized offline implementation step.
Constraints: preserve scope, review independence and cumulative Review round; check latest state first.
Output: .ai/round-02-result.md and the next boundary handoff.
Follow: docs/ai-collaboration/agent-prompts.md#implementation-engineer.
```

'@
    $modernContinue = $validContinue.Replace(
        '- Next action: `continue`',
        "- Next action: ``continue```n- Human Action Required: ``none``"
    ).Replace('## Delta Since Last Handoff', ($continuationBlock + '## Delta Since Last Handoff'))
    $neutralNotice = $envSectionPendingNotNeeded.Replace(
        'Launch WebForms debugging in Visual Studio and keep IIS Express running before page checks.',
        'none'
    ).Replace(
        'Reply started once ready, then verify http://localhost:3000/ is reachable.',
        'The agent checks reachability before later page verification; no action or reply is needed now.'
    )
    $modernBlocked = $validContinue.Replace(
        '- Next action: `continue`',
        "- Next action: ``continue```n- Human Action Required: ``awaiting-environment``"
    ).Replace('`ready-for-review`', '`blocked`').Replace(
        '- None.', '- Resume condition: Visual Studio debugging is running and the agent checks reachability.'
    ) + $envSectionPendingNeeded
    $modernOwnerWait = $validAwaitingOwner.Replace(
        '- Next action: `continue`',
        "- Next action: ``continue```n- Human Action Required: ``awaiting-decision``"
    )
    $modernDispatch = $originalHandoff.Replace(
        '- Next action: `dispatch`',
        "- Next action: ``dispatch```n- Human Action Required: ``none``"
    )

    $continuationCases = @(
        @{ Name = 'neutral forward notice permits no human action'; Text = $modernContinue + $neutralNotice; Exit = 0 },
        @{ Name = 'legacy forward notice remains structurally readable'; Text = $validContinue + $envSectionPendingNotNeeded; Exit = 0 },
        @{ Name = 'legacy continue without new fields passes'; Text = $validContinue; Exit = 0 },
        @{ Name = 'current continue with self-contained command passes'; Text = $modernContinue; Exit = 0 },
        @{ Name = 'agent dispatch with no human action passes'; Text = $modernDispatch + $neutralNotice; Exit = 0 },
        @{ Name = 'owner wait with matching summary passes'; Text = $modernOwnerWait; Exit = 0 },
        @{ Name = 'owner wait cannot report none'; Text = $modernOwnerWait.Replace('Required: `awaiting-decision`', 'Required: `none`'); Exit = 1; Error = 'awaiting-owner-decision requires Human Action Required: awaiting-decision' },
        @{ Name = 'owner wait cannot auto-execute continuation'; Text = $modernOwnerWait.Replace('## Delta Since Last Handoff', ($continuationBlock + '## Delta Since Last Handoff')); Exit = 1; Error = 'Continuation Command is permitted only for executable continue' },
        @{ Name = 'continue command cannot override review limit'; Text = $modernContinue.Replace('Review round: `0`', 'Review round: `3`'); Exit = 1; Error = 'Review round circuit breaker reached at 3' },
        @{ Name = 'invalid human action enum fails'; Text = $modernContinue.Replace('Required: `none`', 'Required: `maybe`'); Exit = 1; Error = 'Human Action Required must be none, awaiting-decision, or awaiting-environment' },
        @{ Name = 'empty human action fails'; Text = $modernContinue.Replace('Required: `none`', 'Required:'); Exit = 1; Error = 'Human Action Required must be none, awaiting-decision, or awaiting-environment' },
        @{ Name = 'duplicate human action fails'; Text = $modernContinue.Replace('Required: `none`', "Required: ``none```n- Human Action Required: ``none``"); Exit = 1; Error = 'Routing must contain at most one Human Action Required' },
        @{ Name = 'false decision wait fails'; Text = $modernContinue.Replace('Required: `none`', 'Required: `awaiting-decision`'); Exit = 1; Error = 'awaiting-decision requires awaiting-owner-decision' },
        @{ Name = 'forward notice cannot claim environment wait'; Text = ($modernContinue + $neutralNotice).Replace('Required: `none`', 'Required: `awaiting-environment`'); Exit = 1; Error = 'awaiting-environment requires continue/blocked and an unmet immediate environment prerequisite' },
        @{ Name = 'missing current continuation command fails'; Text = $modernContinue.Replace($continuationBlock, ''); Exit = 1; Error = 'Executable continue with Human Action Required requires ### Continuation Command under Current Status' },
        @{ Name = 'empty continuation heading fails'; Text = $modernContinue.Replace($continuationBlock, "`n### Continuation Command`n`n"); Exit = 1; Error = 'Continuation Command requires one text code block' },
        @{ Name = 'wrong continuation location fails'; Text = $modernContinue.Replace($continuationBlock, '') + $continuationBlock; Exit = 1; Error = 'Continuation Command must be under Current Status' },
        @{ Name = 'duplicate continuation command fails'; Text = $modernContinue.Replace($continuationBlock, ($continuationBlock + $continuationBlock)); Exit = 1; Error = 'Handoff must contain at most one Continuation Command' },
        @{ Name = 'missing continuation objective fails'; Text = $modernContinue.Replace('Objective:', 'Missing:'); Exit = 1; Error = 'Continuation Command is missing: Objective:' },
        @{ Name = 'empty continuation objective fails'; Text = $modernContinue.Replace('Objective: finish the authorized offline implementation step.', 'Objective:'); Exit = 1; Error = 'Continuation Command is missing: Objective:' },
        @{ Name = 'wrong continuation follow role fails'; Text = $modernContinue.Replace('agent-prompts.md#implementation-engineer', 'agent-prompts.md#chief-designer'); Exit = 1; Error = 'Continuation Command Follow must match Current role prompt' },
        @{ Name = 'multiple continuation text blocks fail'; Text = $modernContinue.Replace('Objective: finish', ('```' + "`n" + '```text' + "`nObjective: finish")); Exit = 1; Error = 'Continuation Command requires one text code block' },
        @{ Name = 'wrong continuation batch fails'; Text = $modernContinue.Replace('Execution Batch validator-mapped-items', 'Execution Batch unrelated-batch'); Exit = 1; Error = 'Continuation Command must name Execution Batch: validator-mapped-items' },
        @{ Name = 'batch suffix cannot match current batch'; Text = $modernContinue.Replace('Execution Batch validator-mapped-items.', 'Execution Batch validator-mapped-items.stale.'); Exit = 1; Error = 'Continuation Command must name Execution Batch: validator-mapped-items' },
        @{ Name = 'wrong continuation role fails'; Text = $modernContinue.Replace('continuing as Implementation Engineer', 'continuing as Chief Designer'); Exit = 1; Error = 'Continuation Command must name Current role: Implementation Engineer' },
        @{ Name = 'environment wait with immediate prerequisite passes'; Text = $modernBlocked; Exit = 0 },
        @{ Name = 'environment wait cannot report no human action'; Text = $modernBlocked.Replace('Required: `awaiting-environment`', 'Required: `none`'); Exit = 1; Error = 'Unmet immediate environment prerequisite requires Human Action Required: awaiting-environment' },
        @{ Name = 'environment wait cannot auto-execute continuation'; Text = $modernBlocked.Replace('## Delta Since Last Handoff', ($continuationBlock + '## Delta Since Last Handoff')); Exit = 1; Error = 'Continuation Command is permitted only for executable continue' },
        @{ Name = 'immediate environment prerequisite cannot remain executable'; Text = $validContinue + $envSectionPendingNeeded; Exit = 1; Error = 'Unmet immediate environment prerequisite requires continue/blocked' },
        @{ Name = 'ready environment cannot claim wait'; Text = $modernBlocked.Replace('Readiness: `pending`', 'Readiness: `ready`'); Exit = 1; Error = 'awaiting-environment requires continue/blocked and an unmet immediate environment prerequisite' },
        @{ Name = 'dispatch forbids continuation command'; Text = $originalHandoff.Replace('## Delta Since Last Handoff', ($continuationBlock + '## Delta Since Last Handoff')); Exit = 1; Error = 'Continuation Command is permitted only for executable continue' },
        @{ Name = 'close forbids continuation command'; Text = $validClose.Replace('## Delta Since Last Handoff', ($continuationBlock + '## Delta Since Last Handoff')); Exit = 1; Error = 'Continuation Command is permitted only for executable continue' }
    )
    $closingHashBlock = $continuationBlock.Replace('### Continuation Command', '### Continuation Command ###')
    foreach ($waitShape in @(
        @{ Name = 'blocked'; Text = $modernBlocked },
        @{ Name = 'owner wait'; Text = $modernOwnerWait },
        @{ Name = 'dispatch'; Text = $originalHandoff },
        @{ Name = 'close'; Text = $validClose }
    )) {
        $continuationCases += @{
            Name = "closing hashes cannot bypass $($waitShape.Name) prohibition"
            Text = $waitShape.Text.Replace('## Delta Since Last Handoff', ($closingHashBlock + '## Delta Since Last Handoff'))
            Exit = 1
            Error = 'Continuation Command is permitted only for executable continue'
        }
    }
    $continuationCases += @{
        Name = 'closing hashes cannot hide duplicate continuation'
        Text = $modernContinue.Replace($continuationBlock, ($continuationBlock + $closingHashBlock))
        Exit = 1
        Error = 'Handoff must contain at most one Continuation Command'
    }
    $fence = [string][char]96 * 3
    $continuationCases += @{
        Name = 'fenced command example does not satisfy continuation'
        Text = $modernContinue.Replace($continuationBlock, '') + "`n## Notes`n$($fence)markdown`n### Continuation Command`n$($fence)"
        Exit = 1
        Error = 'Executable continue with Human Action Required requires ### Continuation Command under Current Status'
    }
    $continuationCases += @{
        Name = 'fenced human action example is not a live field'
        Text = $validContinue.Replace('## Current Status', "$($fence)markdown`n- Human Action Required: ``invalid```n$fence`n`n## Current Status")
        Exit = 0
    }
    foreach ($case in $continuationCases) {
        Set-Content -Encoding UTF8 -LiteralPath $handoffCopy -Value $case.Text -NoNewline
        $expected = if ($case.ContainsKey('Error')) { @($case.Error) } else { @() }
        Invoke-ValidatorCase ('autonomous continuation ' + $case.Name) $currentTaskRelativePath $handoffRelativePath $case.Exit -ExpectedErrors $expected -ExpectNoWarnings:($case.Exit -eq 0)
    }

    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionReadyNeeded) -NoNewline
    Invoke-ValidatorCase "agent dispatch allowed when prerequisite is ready" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    $blockedWithEnv = $validContinue.Replace('- Current status: `ready-for-review`', '- Current status: `blocked`').Replace(
        '- None.', '- Resume condition: `WebForms debug running and http://localhost:3000/ returns 200`'
    ) + $envSectionPendingNeeded
    Set-Content -LiteralPath $handoffCopy -Value $blockedWithEnv -NoNewline
    Invoke-ValidatorCase "blocked continue with environment preparation and resume condition passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    # These subprocess cases catch mandatory-guide gates rejecting useful prose,
    # and code samples being mistaken for required or forbidden runtime sections.
    $blockedProse = $validContinue.Replace('- Current status: `ready-for-review`', '- Current status: `blocked`').Replace(
        '- None.', '- Resume condition: `Visual Studio debugging is running`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $blockedProse -NoNewline
    Invoke-ValidatorCase "plain guidance blocked prose without guide or code passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    foreach ($optionalGuide in @(
        "`n`n## Operator Action Guide`nStart debugging in Visual Studio and reply when the page opens.",
        "`n`n## Operator Action Guide`n### Local notes`n- Target path: optional`n#### Other details`nUse the current debug session."
    )) {
        Set-Content -LiteralPath $handoffCopy -Value ($blockedWithEnv + $optionalGuide) -NoNewline
        $guideKind = if ($optionalGuide.Contains('### Local notes')) { 'custom' } else { 'incomplete' }
        Invoke-ValidatorCase "plain guidance optional $guideKind guide passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    }

    foreach ($evidenceLine in @(
        'Please open the page in Visual Studio and reply with the status shown.',
        '- Operator evidence request: Return the API startup log and health-check output.'
    )) {
        $evidenceProse = $validContinue.Replace(
            '- `.ai/current-task.md`',
            ('- `.ai/current-task.md`' + [Environment]::NewLine + $evidenceLine)
        )
        Set-Content -LiteralPath $handoffCopy -Value $evidenceProse -NoNewline
        $requestKind = if ($evidenceLine.StartsWith('- Operator evidence request:')) { 'existing one-line field' } else { 'free-form prose' }
        Invoke-ValidatorCase "plain guidance human evidence $requestKind without guide passes" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    }

    $fenceMarker = [string][char]96 * 3
    foreach ($reservedHeading in @('Environment Preparation', 'Operator Command', 'Owner Decision Brief')) {
        $fencedNotes = "`n`n## Optional Notes`n$($fenceMarker)powershell title=example`n## $reservedHeading`nGet-Item .ai`n$fenceMarker"
        Set-Content -LiteralPath $handoffCopy -Value ($blockedWithEnv + $fencedNotes) -NoNewline
        Invoke-ValidatorCase "fence guards fenced $reservedHeading preserves runtime sections" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    }

    $fencedTaskReservedHeadings = "$($fenceMarker)powershell`n## Routing`n## Status`n## Scope`nGet-Item .ai`n$fenceMarker"
    $taskWithFencedReservedHeadings = $originalCurrentTask.Replace('## Required Checks', "$fencedTaskReservedHeadings`n`n## Required Checks")
    Set-Content -LiteralPath $currentTaskCopy -Value $taskWithFencedReservedHeadings -NoNewline
    Set-Content -LiteralPath $handoffCopy -Value $blockedWithEnv -NoNewline
    Invoke-ValidatorCase "fence guards fenced Routing Status and Scope are not live sections" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    $missingScopeWithFencedHeading = [regex]::Replace(
        $taskWithFencedReservedHeadings,
        '(?ms)^## Scope\s*\r?\n.*?(?=^## Out of Scope)',
        ''
    )
    Set-Content -LiteralPath $currentTaskCopy -Value $missingScopeWithFencedHeading -NoNewline
    Invoke-ValidatorCase "fence guards fenced Scope does not satisfy missing live Scope" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @("$currentTaskRelativePath is missing heading: ## Scope")
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    $envWithFencedPrerequisite = $blockedWithEnv.Replace(
        '- Work that can proceed: none',
        "- Work that can proceed: none`n$($fenceMarker)powershell`n### Read-only metadata probe`nGet-Item .ai`n$fenceMarker"
    )
    Set-Content -LiteralPath $handoffCopy -Value $envWithFencedPrerequisite -NoNewline
    Invoke-ValidatorCase "fence guards fenced level-3 heading does not split Environment Preparation" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings

    $emptyEnvironmentPreparation = $blockedWithEnv.Replace($envSectionPendingNeeded, "`n## Environment Preparation")
    Set-Content -LiteralPath $handoffCopy -Value $emptyEnvironmentPreparation -NoNewline
    Invoke-ValidatorCase "fence guards real empty Environment Preparation fails" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Environment Preparation requires at least one prerequisite heading (### ...)')

    $realOperatorCommandInContinue = $validContinue + "`n`n## Operator Command`n$($fenceMarker)text`nRole: Code Reviewer`n$fenceMarker"
    Set-Content -LiteralPath $handoffCopy -Value $realOperatorCommandInContinue -NoNewline
    Invoke-ValidatorCase "fence guards real Operator Command in continue fails" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('continue must not include ## Operator Command')

    $realOwnerDecisionBriefInBlocked = $blockedWithEnv + "`n`n## Owner Decision Brief`n- Decision needed: none"
    Set-Content -LiteralPath $handoffCopy -Value $realOwnerDecisionBriefInBlocked -NoNewline
    Invoke-ValidatorCase "fence guards real Owner Decision Brief in blocked fails" $currentTaskRelativePath $handoffRelativePath 1 -ExpectedErrors @('Environment blocked state must not include Owner Decision Brief; use awaiting-owner-decision for a real decision')

    $badEnvNoHeading = @'

## Environment Preparation

- Readiness: `ready`
- Needed before next action: `yes`
- Human action: Launch debugging.
- Confirmation and check: Verified 200 OK.
- Work that can proceed: none
'@
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoHeading) -NoNewline
    Invoke-ValidatorCase "Environment Preparation missing prerequisite heading fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvNoReadiness = $envSectionReadyNeeded.Replace('- Readiness: `ready`', '')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoReadiness) -NoNewline
    Invoke-ValidatorCase "Environment Preparation missing Readiness fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvInvalidReadiness = $envSectionReadyNeeded.Replace('- Readiness: `ready`', '- Readiness: `invalid-status`')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvInvalidReadiness) -NoNewline
    Invoke-ValidatorCase "Environment Preparation invalid Readiness fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvNoNeeded = $envSectionReadyNeeded.Replace('- Needed before next action: `yes`', '')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoNeeded) -NoNewline
    Invoke-ValidatorCase "Environment Preparation missing Needed before next action fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvInvalidNeeded = $envSectionReadyNeeded.Replace('- Needed before next action: `yes`', '- Needed before next action: `maybe`')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvInvalidNeeded) -NoNewline
    Invoke-ValidatorCase "Environment Preparation invalid Needed before next action fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvNoHumanAction = $envSectionReadyNeeded.Replace('- Human action: Launch WebForms debugging in Visual Studio and keep IIS Express running.', '')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoHumanAction) -NoNewline
    Invoke-ValidatorCase "Environment Preparation missing Human action fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvNoneHumanAction = $envSectionReadyNeeded.Replace('Launch WebForms debugging in Visual Studio and keep IIS Express running.', 'none')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoneHumanAction) -NoNewline
    Invoke-ValidatorCase "Environment Preparation Human action none fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvNoConfirm = $envSectionReadyNeeded.Replace('- Confirmation and check: Verified http://localhost:3000/ returned HTTP 200.', '')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoConfirm) -NoNewline
    Invoke-ValidatorCase "Environment Preparation missing Confirmation and check fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvPendingConfirm = $envSectionReadyNeeded.Replace('Verified http://localhost:3000/ returned HTTP 200.', 'pending')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvPendingConfirm) -NoNewline
    Invoke-ValidatorCase "Environment Preparation Confirmation and check pending fails" $currentTaskRelativePath $handoffRelativePath 1

    $badEnvNoWork = $envSectionReadyNeeded.Replace('- Work that can proceed: Page verification can proceed.', '')
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $badEnvNoWork) -NoNewline
    Invoke-ValidatorCase "Environment Preparation missing Work that can proceed fails" $currentTaskRelativePath $handoffRelativePath 1

    $envSectionReadyPlusTrailingEmptyWithoutNewline = $envSectionReadyNeeded + "`n`n### Missing prerequisite"
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionReadyPlusTrailingEmptyWithoutNewline) -NoNewline
    Invoke-ValidatorCase `
        -Name "trailing empty prerequisite without newline fails with locating diagnostics" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @(
            "Environment Preparation 'Missing prerequisite' is missing: Readiness",
            "Environment Preparation 'Missing prerequisite' is missing: Needed before next action",
            "Environment Preparation 'Missing prerequisite' is missing: Human action",
            "Environment Preparation 'Missing prerequisite' is missing: Confirmation and check",
            "Environment Preparation 'Missing prerequisite' is missing: Work that can proceed"
        )

    $envSectionReadyPlusTrailingEmptyWithNewline = $envSectionReadyNeeded + "`n`n### Missing prerequisite`n"
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionReadyPlusTrailingEmptyWithNewline) -NoNewline
    Invoke-ValidatorCase `
        -Name "trailing empty prerequisite with newline fails with locating diagnostics" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @(
            "Environment Preparation 'Missing prerequisite' is missing: Readiness",
            "Environment Preparation 'Missing prerequisite' is missing: Needed before next action",
            "Environment Preparation 'Missing prerequisite' is missing: Human action",
            "Environment Preparation 'Missing prerequisite' is missing: Confirmation and check",
            "Environment Preparation 'Missing prerequisite' is missing: Work that can proceed"
        )

    $envSectionMiddleEmptyPrereq = $envSectionReadyNeeded + "`n`n### Empty middle prerequisite`n`n### Database test instance`n- Readiness: ``ready```n- Needed before next action: ``yes```n- Human action: Launch database.`n- Confirmation and check: Port 1433 open.`n- Work that can proceed: all"
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionMiddleEmptyPrereq) -NoNewline
    Invoke-ValidatorCase `
        -Name "middle empty prerequisite fails with locating diagnostics" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1 `
        -ExpectedErrors @(
            "Environment Preparation 'Empty middle prerequisite' is missing: Readiness",
            "Environment Preparation 'Empty middle prerequisite' is missing: Needed before next action",
            "Environment Preparation 'Empty middle prerequisite' is missing: Human action",
            "Environment Preparation 'Empty middle prerequisite' is missing: Confirmation and check",
            "Environment Preparation 'Empty middle prerequisite' is missing: Work that can proceed"
        )

    $envSectionMultiReady = $envSectionReadyNeeded + "`n`n### Database test instance`n- Readiness: ``ready```n- Needed before next action: ``yes```n- Human action: Launch database.`n- Confirmation and check: Port 1433 open.`n- Work that can proceed: all"
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + $envSectionMultiReady) -NoNewline
    Invoke-ValidatorCase "agent dispatch allowed when all multiple prerequisites are ready" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings



    $blocked = $validContinue.Replace('- Current status: `ready-for-review`', '- Current status: `blocked`').Replace(
        '- None.', '- Resume condition: `test service available; retry once when notified`'
    )
    foreach ($role in @('Implementation Engineer', 'Task Intake')) {
        Set-Content -LiteralPath $handoffCopy -Value $blocked.Replace('Current role: `Implementation Engineer`', ('Current role: `' + $role + '`')) -NoNewline
        Invoke-ValidatorCase "$role environment wait needs no owner approval" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    }
    Set-Content -LiteralPath $handoffCopy -Value $blocked.Replace('Resume condition:', 'Missing condition:') -NoNewline
    Invoke-ValidatorCase "blocked requires actionable resumption" $currentTaskRelativePath $handoffRelativePath 1
    Set-Content -LiteralPath $handoffCopy -Value $validClose.Replace('`ready-for-review`', '`blocked`') -NoNewline
    Invoke-ValidatorCase "blocked cannot close" $currentTaskRelativePath $handoffRelativePath 1

    $metrics = Get-Content -LiteralPath $handoffCopy -Raw
    $metrics = [regex]::Match($metrics, '(?ms)^## Process Metrics.*\z').Value
    Set-Content -LiteralPath $handoffCopy -Value ($originalHandoff + "`n`n" + $metrics) -NoNewline
    Invoke-ValidatorCase "dispatch records running costs and warns at target" $currentTaskRelativePath $handoffRelativePath 0 -ExpectedWarnings @('Role action target reached')
    Set-Content -LiteralPath $handoffCopy -Value ($validHumanDispatchBase + "`n`n" + $metrics) -NoNewline
    Invoke-ValidatorCase "human dispatch retains running costs" $currentTaskRelativePath $handoffRelativePath 0
    Set-Content -LiteralPath $handoffCopy -Value ($validContinue + "`n`n" + $metrics.Replace('`1`', '`2`')) -NoNewline
    Invoke-ValidatorCase "repeated loops and broad runs are visible" $currentTaskRelativePath $handoffRelativePath 0 -ExpectedWarnings @('Fix loop target exceeded', 'Multiple broad regression runs')
    Set-Content -LiteralPath $handoffCopy -Value $validClose.Replace('Role actions: `3`', 'Role actions: `unknown`') -NoNewline
    Invoke-ValidatorCase "legacy counts are not fabricated" $currentTaskRelativePath $handoffRelativePath 0 -ExpectedWarnings @('Legacy close has no Closure outcome', 'Role actions is unknown')

    foreach ($badMetadata in @('- Risk level: `H`', '- Execution Batch ID: `other-batch`', '- State revision: `0`')) {
        Set-Content -LiteralPath $handoffCopy -Value $originalHandoff.Replace('## Routing', ("## Routing`n`n" + $badMetadata)) -NoNewline
        Invoke-ValidatorCase "reject mismatched or malformed $badMetadata" $currentTaskRelativePath $handoffRelativePath 1
    }
    $goodMetadata = "## Routing`n`n" + '- Risk level: `M`' + "`n" + '- Execution Batch ID: `validator-mapped-items`' + "`n" + '- State revision: `2`'
    Set-Content -LiteralPath $handoffCopy -Value $originalHandoff.Replace('## Routing', $goodMetadata) -NoNewline
    Invoke-ValidatorCase "optional state identity matches the batch" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask.Replace('Risk level: `M`', 'Risk level: `X`') -NoNewline
    Invoke-ValidatorCase "reject invalid batch risk" $currentTaskRelativePath $handoffRelativePath 1
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    $fixVerification = $originalHandoff.Replace('Current role: `Implementation Engineer`', 'Current role: `Fix Engineer`').Replace('`ready-for-review`', '`ready-for-verification`')
    Set-Content -LiteralPath $handoffCopy -Value $fixVerification -NoNewline
    Invoke-ValidatorCase "M fix returns to code reviewer" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask.Replace('Risk level: `M`', 'Risk level: `H`') -NoNewline
    Invoke-ValidatorCase "H fix requires verification role" $currentTaskRelativePath $handoffRelativePath 1
    $fixVerification = $fixVerification.Replace('Code Reviewer', 'Verification Reviewer').Replace('#code-reviewer', '#verification-reviewer')
    Set-Content -LiteralPath $handoffCopy -Value $fixVerification -NoNewline
    Invoke-ValidatorCase "H fix routes to verification reviewer" $currentTaskRelativePath $handoffRelativePath 0 -ExpectNoWarnings
    Set-Content -LiteralPath $currentTaskCopy -Value $originalCurrentTask -NoNewline

    $missingCommand = [regex]::Replace(
        $originalHandoff,
        "(?ms)\r?\n## Operator Command\s*\r?\n.*\z",
        ""
    )
    Set-Content -LiteralPath $handoffCopy -Value $missingCommand -NoNewline
    Invoke-ValidatorCase `
        -Name "dispatch without Operator Command" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidClose = $originalHandoff.Replace(
        '- Next action: `dispatch`',
        '- Next action: `close`'
    )
    Set-Content -LiteralPath $handoffCopy -Value $invalidClose -NoNewline
    Invoke-ValidatorCase `
        -Name "close with stale dispatch fields" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    Set-Content -LiteralPath $handoffCopy -Value $originalHandoff -NoNewline
    $invalidCurrentTask = (
        Get-Content -LiteralPath $currentTaskCopy -Raw
    ).Replace("## Initial Assignment", "## Routing")
    Set-Content -LiteralPath $currentTaskCopy -Value $invalidCurrentTask -NoNewline
    Invoke-ValidatorCase `
        -Name "current task contains live Routing" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1

    $invalidStatusTask = (
        Get-Content -LiteralPath $currentTaskCopy -Raw
    ).Replace("## Routing", "## Initial Assignment") + "`n`n## Status`nopen"
    Set-Content -LiteralPath $currentTaskCopy -Value $invalidStatusTask -NoNewline
    Invoke-ValidatorCase `
        -Name "current task contains live Status" `
        -CurrentTaskRelativePath $currentTaskRelativePath `
        -HandoffRelativePath $handoffRelativePath `
        -ExpectedExitCode 1
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTempRoot = [IO.Path]::GetFullPath($tempRoot)
        $rootPrefix = [IO.Path]::GetFullPath($workspaceRoot).TrimEnd("\", "/") +
            [IO.Path]::DirectorySeparatorChar
        if ($resolvedTempRoot.StartsWith(
            $rootPrefix,
            [StringComparison]::OrdinalIgnoreCase
        )) {
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }
}

if ($caseCount -eq 0) {
    throw "No runtime-state validator cases matched CaseFilter."
}
if ($CaseFilter.Count -gt 0) {
    Write-Host "Selected runtime-state validator tests passed ($caseCount cases)."
} else {
    Write-Host "All runtime-state validator tests passed ($caseCount cases)."
}
$global:LASTEXITCODE = 0
