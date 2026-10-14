# Example - Risk-Based Action States

This fictional feature demonstrates the collaboration protocol:

> Show a mobile reminder for employee incentive points expiring within 30 days.

The canonical example below is one risk `M` Execution Batch. Its runtime
artifacts are complete and copyable after replacing the fictional paths and
agent names. The later `S` and `H` flows describe separate task variants and
are intentionally non-copyable summaries.

## Canonical M Current Task

`.ai/current-task.md` remains stable for the complete batch:

```markdown
# Current Task - Mobile points expiry reminder

## Task Identity

- Task ID: `mobile-points-expiry-reminder`
- Change ID: `add-mobile-points-expiry-reminder`
- Module(s): `mis_app/`
- Source: `openspec/changes/add-mobile-points-expiry-reminder/`
- Created on: `2026-08-04`

## Batch Classification

- Execution Batch ID: `points-reminder-ui`
- Risk level: `M`
- Risk reason: `The change adds shared mobile presentation behavior with localized state transitions.`
- OpenSpec checklist items:
  - `2.1`
  - `2.2`
- Existing capability to reuse: `existing points API and controller-backed page`
- First demonstrable outcome: `eligible points show one localized reminder and the reminder disappears when eligibility changes; inspect the points page in each eligibility state`
- Justified complexity exceptions: `none`
- Stop condition: `the existing API cannot identify expiry within 30 days`
- Expected implementation sessions: `1`
- Broad regression command: `flutter test`

## Initial Assignment

- Initial role: `Implementation Engineer`
- Recommended agent: `mobile-capable agent`
- Initial prompt template:
  - `docs/ai-collaboration/agent-prompts.md#implementation-engineer`

## Required Reading

- `AGENTS.md`
- `mis_app/AGENTS.md`
- `docs/ai-collaboration/workflows.md#6-implementation`
- `docs/ai-collaboration/agent-prompts.md#implementation-engineer`
- `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`
- `openspec/changes/add-mobile-points-expiry-reminder/specs/points-reminder/spec.md`
- `mis_app/lib/pages/points_page.dart`
- `mis_app/test/points_expiry_reminder_test.dart`

## Goal

Show one localized reminder using the existing points API and keep it aligned
with the current eligibility state.

## Scope

- Reminder presentation, localization, state transition, and focused widget tests.

## Out of Scope

- Points calculation and notification scheduling.

## Must Not Touch

- Backend points accounting and unrelated mobile pages.

## Acceptance Criteria

- Eligible points show the localized reminder.
- Ineligible points do not show it.
- The reminder disappears when an eligible state becomes ineligible.

## Constraints

- Reuse the existing points API and page controller.
- Do not add a notification service or backend contract.

## Required Checks

- `flutter test test/points_expiry_reminder_test.dart`
- `flutter analyze`
- `flutter test`

## Output Requirements

- Update the scoped mobile code and tests.
- Record implementation evidence in `.ai/round-01-result.md`.
- End with exactly one Next Action in `.ai/handoff.md`.
```

Live status and routing are never written back into this file.

## Canonical M Review Dispatch

After implementation, `.ai/handoff.md` contains the complete dispatch state:

````markdown
# Handoff - points-reminder-ui implementation

## Routing

- Next action: `dispatch`
- Current role: `Implementation Engineer`
- Current agent: `mobile-capable agent`
- Current status: `ready-for-review`
- Next role: `Code Reviewer`
- Recommended next agent: `independent review-capable agent`
- Next input files:
  - `.ai/current-task.md`
  - `.ai/round-01-result.md`
  - `docs/reviews/README.md`
  - `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`
  - `openspec/changes/add-mobile-points-expiry-reminder/specs/points-reminder/spec.md`
  - `mis_app/lib/pages/points_page.dart`
  - `mis_app/test/points_expiry_reminder_test.dart`
- Next output files:
  - `docs/reviews/add-mobile-points-expiry-reminder/2026-08-04-round-01.md`
  - `docs/reviews/add-mobile-points-expiry-reminder/index.md`
  - `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`
  - `.ai/handoff.md`
- Next prompt template:
  - `docs/ai-collaboration/agent-prompts.md#code-reviewer`

## Current Status

Implementation and required checks are complete; the risk `M` batch requires
one independent review.

## Delta Since Last Handoff

- Added the localized reminder and eligibility transition behavior.
- Added focused widget coverage and recorded the broad regression result.

## Authoritative Evidence

- `.ai/round-01-result.md`
- `openspec/changes/add-mobile-points-expiry-reminder/specs/points-reminder/spec.md`

## Known Risks

- Review must confirm the reminder is removed after eligibility changes.

## Blockers

- None.

## Review Or Task State Impact

- No formal review or OpenSpec checkbox has changed yet.

## Operator Command
```text
You are the Code Reviewer for Execution Batch points-reminder-ui (risk M).
Read: AGENTS.md, mis_app/AGENTS.md, docs/reviews/README.md, .ai/current-task.md, .ai/handoff.md, .ai/round-01-result.md, the mapped OpenSpec spec and tasks, and the changed points page and tests.
Objective: Review the complete mapped acceptance, final diff, and recorded evidence; report all high-confidence findings together and give a clear verdict.
Constraints: Read-only for implementation code and tests; preserve unrelated changes. Required review and .ai handoff artifacts remain writable.
Output: Create docs/reviews/add-mobile-points-expiry-reminder/2026-08-04-round-01.md and update docs/reviews/add-mobile-points-expiry-reminder/index.md and .ai/handoff.md. If clean, mark OpenSpec items 2.1 and 2.2 complete in openspec/changes/add-mobile-points-expiry-reminder/tasks.md before close; otherwise preserve their task state and dispatch one Fix Engineer with all assigned findings in one copy-ready Operator Command.
Follow: docs/ai-collaboration/agent-prompts.md#code-reviewer.
```
````

## Canonical M Clean Close

A clean reviewer replaces the live handoff with this complete close state:

```markdown
# Handoff - points-reminder-ui review

## Routing

- Next action: `close`
- Current role: `Code Reviewer`
- Current agent: `independent review-capable agent`
- Current status: `closed`
- Next role: `none`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

The independent review found no actionable issues and the mapped acceptance is
complete. Task Owner progress summary: eligible points show one localized
reminder and it disappears when eligibility changes; inspect the points page in
each eligibility state and consult the focused widget test output. Acceptance
criteria `2.1` and `2.2` are satisfied and OpenSpec items `2.1` and `2.2` are
complete. There are no deviations beyond normal release validation, and no
remaining work is mapped to this batch; later work requires separate Task
Intake.

## Delta Since Last Handoff

- Reviewed the final diff, focused tests, analysis, and broad regression evidence.
- Created formal review Round 01 and updated the durable review index.
- Marked OpenSpec items `2.1` and `2.2` complete after recording the review evidence.

## Authoritative Evidence

- `.ai/round-01-result.md`
- `docs/reviews/add-mobile-points-expiry-reminder/2026-08-04-round-01.md`
- `docs/reviews/add-mobile-points-expiry-reminder/index.md`
- `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`

## Known Risks

- None beyond normal release validation.

## Blockers

- None.

## Review Or Task State Impact

- Formal review Round 01 is indexed with no unresolved assigned finding.
- OpenSpec items `2.1` and `2.2` are marked complete in
  `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`.
- Remaining work for this completed batch: none; unrelated or later work is
  not implicitly started by closure.

## Process Metrics

- Role actions: `2`
- Review/fix/verification loops: `0`
- Broad regression runs: `1`
- Elapsed time: `1h 20m`
- Token usage: `unknown`
```

There is no Operator Command because no role remains. If review finds an
actionable issue, use `dispatch` and send every assigned finding together to
one Fix Engineer. If strict read-only instructions prohibit `.ai` writes, use
the complete response fallback in
`docs/ai-collaboration/handoff-schema.md#response-handoff-fallback`.

## Separate Risk Variants

These flow summaries are not runtime artifacts and must not be copied into the
risk `M` example above.

- A separately classified risk `S` documentation or mechanical task may use
  `Implementation Engineer -> close` after self-verification.
- A separately classified risk `H` security or data-integrity task may use
  `Implementation Engineer -> Code Reviewer -> Fix Engineer -> independent
  Verification Reviewer -> close` when findings require fixes.
- A clean `H` review may close directly when its required evidence is complete.
- If the single allowed fix and verification loop fails, dispatch Chief
  Designer for `REVISE`, `STOP`, or `SPLIT` instead of starting another loop.

## Owner Decision Examples

### Same-Session Continue

Use `continue` when the same role and agent can receive the decision in the active session:

```markdown
# Handoff - points-reminder-ui clarify copy

## Routing

- Next action: `continue`
- Current role: `Implementation Engineer`
- Current agent: `mobile-capable agent`
- Current status: `awaiting-owner-decision`
- Next role: `none`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

Awaiting Task Owner decision on reminder banner copy before completing widget implementation.

## Delta Since Last Handoff

- Identified two viable copy options for the 30-day reminder.

## Authoritative Evidence

- Implementation or fix result: `none`
- Formal review or verification round: `none`
- OpenSpec checklist: `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`

## Known Risks

- None.

## Blockers

- Awaiting copy decision.

## Owner Decision Brief

- Decision needed: Which banner text should appear when employee incentive points expire within 30 days?
- Recommendation: Use concise warning text (Reason: Fits mobile card header without truncation across screen sizes)
- Alternatives:
  - Use detailed text with exact point balance breakdown (Consequence: Wraps to three lines and pushes actions below fold)
- Reply needed: `concise`
- After the reply: Implementation Engineer will apply the chosen copy string and run widget tests.

## Review Or Task State Impact

- Formal review status impact: `none`
- OpenSpec task impact: `none`
```

### Human Decision Dispatch

Use human decision `dispatch` for an explicit asynchronous or cross-person business, data-authority, or approval decision:

```markdown
# Handoff - points-reminder-ui owner approval

## Routing

- Next action: `dispatch`
- Current role: `Implementation Engineer`
- Current agent: `mobile-capable agent`
- Current status: `awaiting-owner-decision`
- Next role: `Task Owner`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

Awaiting Task Owner confirmation on whether points expiring on the 30th day are inclusive.

## Delta Since Last Handoff

- Implemented boundary check logic; seeking owner decision on day-30 inclusion.

## Authoritative Evidence

- Implementation or fix result: `none`
- Formal review or verification round: `none`
- OpenSpec checklist: `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`

## Known Risks

- None.

## Blockers

- Awaiting owner boundary decision.

## Owner Decision Brief

- Decision needed: Should points expiring on exactly day 30 be included in the reminder?
- Recommendation: Include day 30 (Reason: Gives employees full 30-day notice before expiry)
- Alternatives:
  - Exclude day 30 and start at day 29 (Consequence: Reduces notice window by 24 hours)
- Reply needed: `inclusive`
- After the reply: Implementation Engineer will finalize the comparator logic and run flutter test.

## Review Or Task State Impact

- Formal review status impact: `none`
- OpenSpec task impact: `none`
```

## Operator Checklist

1. Read `.ai/handoff.md`.
2. For agent `dispatch`, copy its Operator Command to the recommended agent.
3. For human decision `dispatch`, present the Owner Decision Brief to the named human target, collect their reply, and re-invoke the same role/agent.
4. For `continue`, leave the same agent running.
5. For `close`, do not send another prompt for this batch.
6. Run `docs/ai-collaboration/scripts/validate-runtime-state.ps1` before
   accepting the role exit.
