# Response Handoff

<Use for an actual handoff when read-only instructions or tool permissions
prevent updating `.ai/handoff.md`. Response-only consultation does not take over
another batch's live state. Report review findings before this section.>

- Next action: `<dispatch|continue|close>`
- Human Action Required: `<none|awaiting-decision|awaiting-environment>`
- Current role: `<role>`
- Current agent: `<agent or tool>`
- Current status: `<operational status>`
- Review round: `<cumulative completed review verdicts; preserve current count>`
- Next role: `<role or none>`
- Recommended next agent: `<agent or tool, or none>`
- Next input files: `<workspace file path or none>`
- Next output files: `<workspace file path or none>`
- Next prompt template: `docs/ai-collaboration/agent-prompts.md#<section or none>`
- Handoff persistence: `.ai/handoff.md was not updated because <constraint>. Persist this Action State before relying on the file.`
<!-- Source-linked narration when this replaces or restores a live handoff: state the
     source role and Agent, the batch, the verdict, the cumulative Review round, the prior
     State revision if one exists, and the SHA256 of the live handoff bytes this response
     was based on (or that the fingerprint is unavailable). A read-only subagent result
     is persisted by the active permitted writer at the same boundary, not left here. -->
<!-- For agent dispatch keep Current Status with the capability line first.
     For executable continue keep Current Status with Continuation Command;
     omit the capability line for human decision dispatch, continue and close.
     Human Action Required summarizes actual intervention: none unless waiting
     for a decision or unmet immediate human-only environment preparation. -->
<!-- Explicit limited acceptance by Chief Designer may use Acceptance basis:
     owner-decision plus Task Owner decision, retaining unmet mapping/tasks and
     disclosing uncompleted acceptance. Not technical verification or merge permission. -->
<!-- For close include Closure outcome accepted|stopped|superseded;
     ordinary accepted follows handoff-schema.md#accepted-closure-validation
     (external evidence, no post-validation handoff write-back). Process Metrics
     is optional. For blocked continue, include Resume condition.
     Human decision dispatch: status awaiting-owner-decision, next agent/files/
     prompt none, Owner Decision Brief instead of Operator Command.
     stopped/superseded additionally require an explicit applicable Task Owner
     decision (identity/date/batch/outcome and scoped reply or stable evidence link).
     For human-only setup, include Environment Preparation per handoff-schema.md:
     one ### prerequisite with Readiness, Needed before next action, Human action,
     Confirmation and check, Work that can proceed. Notify in plain language;
     pending/unknown + yes uses continue/blocked rather than agent dispatch.
     Give actionable instructions only for current human intervention; exact paths/snippets
     for file/CLI actions, precise UI steps otherwise. No fixed guide required. -->
<!-- Apply README.md#proportional-checks-and-owner-choice. Report affected
     inputs, focused or reused evidence, child exit/diagnostics/elapsed for
     filtered checks, and the smaller option plus Owner Decision Brief before
     any substantial low-benefit or unexpected-cost expansion. -->
<!-- When this response replaces a stale handoff, mirror the same evidence rules:
     file paths only in evidence-style lists (Next input files are paths; do not
     substitute a shell command for a missing result path). Record commands and
     exit codes in the result file Checks Run and cite that path when the live
     handoff is persisted. -->

## Current Status

Recommended capability tier: C3

<Status prose. Keep the capability line only for agent dispatch. For executable continue keep the continuation block below; actual waits, dispatch and close omit that block.>

### Continuation Command

<!-- Executable continue only. Read latest authority and execution ownership;
     preserve role, batch and review count, and record actual Current agent on
     session takeover. Local CLI/IDE choice is not an owner decision. -->

```text
You are continuing as <current role> for Execution Batch <batch id>.
Use EngRelay for this task; resume only the latest authorized continue.
Read: AGENTS.md, .ai/current-task.md, .ai/handoff.md, <authoritative tasks and evidence>.
Objective: <specific authorized next step>.
Constraints: Check latest state and execution ownership; preserve scope, risk, review allowance and independence; <task limits>.
Output: <result evidence and next boundary handoff>.
Follow: docs/ai-collaboration/agent-prompts.md#<current-role-section>.
```

## Environment Preparation

<!-- Conditional: omit unless human-only preparation is needed. Repeat in chat.
     One ### heading per prerequisite; retain pending later-check notices.
     pending/unknown + yes means continue/blocked with Resume condition in Blockers.
     Add Blockers and the resume condition to this response when waiting.
     needed=no: neutral future dependency/check only, no imperative setup or
     confirmation request; explicitly say no current human action/reply is needed.
     needed=yes and unmet: actionable setup and smallest reply.
     ready: observed evidence, no repeated human confirmation. -->

### <human-only environment prerequisite>

- Readiness: `<ready|pending|unknown>`
- Needed before next action: `<yes|no>`
- Human action: <none or neutral later dependency for no; concrete human setup for unmet yes>
- Confirmation and check: <future agent check and no current reply for no; smallest confirmation and check for unmet yes; observed evidence if ready>
- Work that can proceed: <safe unaffected work or none>

<!-- When current human intervention is needed, give instructions here: where/what/why,
     smallest reply; file/CLI actions need exact verified paths and copy-ready
     snippets. UI-only actions need exact application/screen/steps, not code.
     At Review round >=3 only supported close or owner decision, no agent dispatch. -->

## Operator Command

<Required for agent `dispatch`; omit for human dispatch, `continue` or `close`. The command must be
self-contained and must not assume access to the reviewer conversation.>

```text
You are the <next role> for Execution Batch <batch id>.
Read: <authoritative paths>.
Objective: <specific next outcome>.
Constraints: <scope and must-not-do summary>.
Assigned findings: <finding IDs, evidence paths or lines, and required outcomes>.
Output: <required files or closure decision>.
Follow: docs/ai-collaboration/agent-prompts.md#<role-section>.
```
