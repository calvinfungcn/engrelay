# Response Handoff

<Use for an actual handoff when read-only instructions or tool permissions
prevent updating `.ai/handoff.md`. Response-only consultation does not take over
another batch's live state. Report review findings before this section.>

- Next action: `<dispatch|continue|close>`
- Current role: `<role>`
- Current agent: `<agent or tool>`
- Current status: `<operational status>`
- Review round: `<cumulative completed review verdicts; preserve current count>`
- Next role: `<role or none>`
- Recommended next agent: `<agent or tool, or none>`
- Next input files: `<authoritative paths or none>`
- Next output files: `<required paths or response artifacts, or none>`
- Next prompt template: `docs/ai-collaboration/agent-prompts.md#<section or none>`
- Handoff persistence: `.ai/handoff.md was not updated because <constraint>. Persist this Action State before relying on the file.`
<!-- Explicit limited acceptance by Chief Designer may use Acceptance basis:
     owner-decision plus Task Owner decision, retaining unmet mapping/tasks and
     disclosing uncompleted acceptance. Not technical verification or merge permission. -->
<!-- For close include Closure outcome accepted|stopped|superseded;
     Process Metrics is optional. For blocked continue, include Resume condition.
     Human decision dispatch: status awaiting-owner-decision, next agent/files/
     prompt none, Owner Decision Brief instead of Operator Command.
     stopped/superseded additionally require an explicit applicable Task Owner
     decision (identity/date/batch/outcome and scoped reply or stable evidence link).
     For human-only setup, include Environment Preparation per handoff-schema.md:
     one ### prerequisite with Readiness, Needed before next action, Human action,
     Confirmation and check, Work that can proceed. Notify in plain language;
     pending/unknown + yes uses continue/blocked rather than agent dispatch.
     Give actionable instructions in the response itself; exact paths/snippets
     for file/CLI actions, precise UI steps otherwise. No fixed guide required. -->
<!-- Apply README.md#proportional-checks-and-owner-choice. Report affected
     inputs, focused or reused evidence, child exit/diagnostics/elapsed for
     filtered checks, and the smaller option plus Owner Decision Brief before
     any substantial low-benefit or unexpected-cost expansion. -->

## Environment Preparation

<!-- Conditional: omit unless human-only preparation is needed. Repeat in chat.
     One ### heading per prerequisite; retain pending later-check notices.
     pending/unknown + yes means continue/blocked with Resume condition in Blockers.
     Add Blockers and the resume condition to this response when waiting. -->

### <human-only environment prerequisite>

- Readiness: `<ready|pending|unknown>`
- Needed before next action: `<yes|no>`
- Human action: <who should do what, why, and when, in ordinary language>
- Confirmation and check: <short confirmation and agent check, with observed evidence if ready>
- Work that can proceed: <safe unaffected work or none>

<!-- Give blocked/environment instructions in this response: where/what/why,
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
