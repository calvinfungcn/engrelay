# Handoff - <task id or round>

## Routing

- Next action: `<dispatch|continue|close>`
- Current role: `<role>`
- Current agent: `<agent/tool>`
- Current status: `<operational status>`
- Review round: `0`
<!-- Cumulative completed review/verification/adjudication verdicts, not artifact
     numbering. Increment on verdict; never reset on REVISE. At >=3 only supported
     close or awaiting-owner-decision; no agent dispatch. -->
<!-- Optional: Execution Batch ID matching current-task; State revision as a
     positive integer for manual comparison, not automatic stale-write protection. -->
- Next role: `<role>`
- Recommended next agent: `<agent/tool>`
- Next input files:
  - `.ai/current-task.md`
  - `.ai/handoff.md`
- Next output files:
  - `<path>`
- Next prompt template:
  - `docs/ai-collaboration/agent-prompts.md#<section>`

<!-- Action-specific routing rules:
- For `continue` or `close`: set every `Next ...` field above to single-line `none`.
- For human decision `dispatch` (`Next role` is `Task Owner`, `User`, or `Data Owner`):
  Set Current status to `awaiting-owner-decision`. Set `Recommended next agent`,
  `Next input files`, `Next output files`, and `Next prompt template` to `none`.
  Omit `## Operator Command` and include `## Owner Decision Brief`.
  The current AI retains responsibility for updating all workflow artifacts after the reply.
- For same-session decision wait: use `continue`, set Current status to
  `awaiting-owner-decision`, keep the current role and agent, and include `## Owner Decision Brief`.
- For bounded local evaluation or fix step with stable batch scope, acceptance, and risk:
  use `continue` with the same role and agent, omit Operator Command, and record next local step below.
- For unavailable environment: use continue + blocked, omit Owner Decision Brief,
  and put - Resume condition: ... under Blockers. Do not close blocked work.
  Before dispatch, notify foreseeable human-only setup in Environment Preparation
  and chat. Wait in-role if the next action depends on it; allow safe offline work
  if only a later check needs it. Keep outstanding notices across handoffs.
- See docs/ai-collaboration/README.md#routing-contract and handoff-schema.md for role-specific guidance.
- Apply README.md#proportional-checks-and-owner-choice: record affected inputs
  and focused/reused evidence. Before a substantial low-benefit or unexpected
  cost, use the existing Owner Decision Brief with benefit, effort/unknowns,
  smaller option and recommendation; silence is not approval. A filtered
  check must report an actual matched case and child exit/diagnostic/elapsed
  evidence.
-->

## Current Status

<!-- Recommendations and assumptions are evidence or context only; they do not
     authorize new product scope without the applicable evidence or owner
     decision. -->

<One paragraph describing where the task stands now. At coherent batch completion, summarize observable outcome and inspection evidence.>

## Delta Since Last Handoff

- <only what changed since the previous owner received the batch>

## Authoritative Evidence

- Implementation or fix result: `<workspace file path or none>`
- Formal review or verification round: `<workspace file path or none>`
- OpenSpec checklist: `<tasks.md path>` items `<dotted ids such as 1.1>`
<!-- File evidence only: backtick values must be real paths (or none), not commands.
     Put exact commands, observed output, and exit codes in the linked result file
     Checks Run section; cite that result path above instead of pasting the command. -->
<!-- OpenSpec checklist: keep the path inside backticks and list mapped item IDs
     outside the path (see handoff-schema.md). -->
<!-- If human evidence is needed, ask briefly in existing fields/chat;
     no extra evidence-request field or guide is required. -->
<!-- Link inspection evidence, test output, review rounds, or baselines rather than copying long content. -->

## Known Risks

- <risk or "None known">

## Blockers

- <blocker or "None">

## Owner Decision Brief

<!-- Required only for `awaiting-owner-decision`; otherwise omit. -->

- Decision needed: `<one plain-language question or decision needed>`
- Recommendation: `<one recommended option>` (Reason: `<why it is recommended>`)
- Alternatives:
  - `<alternative 1>` (Consequence: `<plain-language consequence>`)
  - `<alternative 2>` (Consequence: `<plain-language consequence>`)
- Reply needed: `<exact reply or short choice, preferably quoted or inline code>`
- After the reply: `<what the current AI role will do next; no workflow tasks assigned to the human>`

## Environment Preparation

<!-- Conditional: omit this entire section if no human-only setup is needed.
     Use one ### heading per prerequisite; retain outstanding items across handoffs.
     Facts are not new Routing statuses. Repeat the plain-language notice in chat.
     pending/unknown + yes prevents agent dispatch: continue + blocked + Resume condition.
     pending/unknown + no permits safe work; recheck before the dependent step. -->

### <human-only environment prerequisite>

- Readiness: `<ready|pending|unknown>`
- Needed before next action: `<yes|no>`
- Human action: <who should do what, why, and when, in ordinary language>
- Confirmation and check: <short human confirmation and agent check; include observed evidence if ready>
- Work that can proceed: <safe unaffected work or none>

<!-- Blocked/environment instructions must appear here: where/what/why and the
     smallest reply. File/CLI actions require exact verified paths and copy-ready
     snippets; UI-only actions name application/screen/steps, no invented code.
     Separate recommended recovery from optional deeper diagnostics. -->

## Review Or Task State Impact

- Formal review status impact: `<none/open/fixed-not-verified/verified/deferred>`
- OpenSpec task impact: `<none or task reference>`
<!-- For close only, add: - Closure outcome: `accepted|stopped|superseded`.
     accepted covers mapped batch acceptance only, not all parent proposal work.
     stopped/superseded require Chief Designer disposition AND explicit applicable
     Task Owner authorization, not acceptance. Also add in this section:
     - Task Owner decision: <identity, date, batch, approved outcome, scoped reply or stable evidence link>.
     Without authorization use awaiting-owner-decision + Owner Decision Brief;
     existing applicable authorization needs no repeated approval. -->
<!-- Only for Chief Designer recording explicit owner acceptance of incomplete
     delivery: add - Acceptance basis: owner-decision and - Task Owner decision:
     with identity/date/batch/scoped reply. Retain mapped tasks unchecked and
     list unmet acceptance in Known Risks; never label it verified. -->

## Operator Command

<!-- Required for agent `dispatch`; omit this section for `continue`, `close`, or human decision `dispatch`. -->
<!-- Read-only permits artifact writes only when explicitly authorized. -->

```text
You are the <next role> for Execution Batch <batch id>.
Read: <authoritative paths from Routing>.
Objective: <specific next outcome>.
Constraints: <scope and must-not-do summary>.
Output: <required files, evidence, and closure or routing decision>.
Follow: docs/ai-collaboration/agent-prompts.md#<section>.
```

## Process Metrics

<!-- Optional on every action: omit this section if no useful actual data.
     Include only available fields; no five-field form or invented counts.
     Role actions counts meaningful routing boundaries, not every local step. -->

- Role actions: `<integer or unknown>`
- Review/fix/verification loops: `<integer or unknown>`
- Broad regression runs: `<integer or unknown>`
- Elapsed time: `<duration or unknown>`
- Token usage: `<integer or unknown>`
