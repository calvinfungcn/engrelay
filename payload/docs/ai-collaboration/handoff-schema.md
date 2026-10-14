# Handoff Schema

This document defines the required structure for local `.ai/` runtime files and
how they relate to durable review files.

## Applicability

These requirements apply to tasks explicitly using ai-collaboration or selected
by its project default, as defined in README.md#optional-activation-and-coexistence.
They do not activate a task from the existence of .ai or historical records.
Another selected workflow does not have to manufacture these files or pass this
validator. Switching modes preserves incomplete acceptance and evidence without
inventing accepted closure. No new routing action/status is introduced.

## General Rules

- Keep `.ai/` files short enough for the next agent to read quickly.
- Prefer links to source artifacts instead of pasting long content.
- Include exact paths for every input and output.
- Apply [Actionable Human Instructions](#actionable-human-instructions) when
  blocked, preparing an environment, or requesting operator runtime evidence.
  Internal shorthand alone is never an executable instruction for a human.
- Every role action must choose exactly one Next Action: `dispatch`,
  `continue`, or `close`.
- Update `.ai/handoff.md` at an actual routing boundary: agent handoff,
  owner-decision wait, operational interruption, or batch closure. Same-owner
  local steps do not require a manual dispatch or a new handoff for every
  micro-step; record a materially changed next step or evidence when needed.
- Read-only prohibits file writes unless the assignment explicitly authorizes
  named review or handoff outputs. Response-only consultation reports in chat
  without changing live business batch state.
- Do not use `.ai/` as the final home for workspace-level review findings.
- Do not invent alternate formal status values.
- Apply README.md#minimal-authority-rule: OpenSpec and
  `.ai/current-task.md` authorize product scope; handoff recommendations and
  assumptions provide evidence or routing context but do not silently enlarge
  that scope.
- A mandatory item must be an accepted outcome, an evidenced existing
  constraint, or the smallest condition causally necessary for accepted
  behavior or evidenced safety/correctness risk. Material additions use the
  existing Owner Decision Brief; silence is not approval.
- Do not duplicate changed-file tables, findings, or command output across
  current-task, handoff, result, and formal review files.
- A technical `REVISE` is `dispatch` from Chief Designer to Design Reviewer;
  material revision may restart design review at round 1, but never resets the
  cumulative batch `Review round` or overrides the default-three circuit
  breaker. At an exhausted allowance without an applicable finite owner
  authorization, use accepted closure with evidence or the Task Owner decision
  route; no agent dispatch is permitted. An applicable finite owner
  authorization permits the budgeted route as defined in
  README.md#review-round-circuit-breaker. `STOP` and `SPLIT` may
  use `close` with Next role `none` only after explicit, applicable Task Owner
  authorization; otherwise wait via the existing Owner Decision Brief and
  `awaiting-owner-decision`. Record the approved reason and incomplete work
  durably, and require separate Task Intake before a split successor.
- After Design Review round 2 returns unresolved `must-address` findings,
  Design Reviewer may dispatch Chief Designer only below the cumulative
  allowance; at an exhausted allowance without an applicable finite owner
  authorization it uses the Task Owner decision route. A third review of an
  unchanged design is forbidden.
- A disputed assigned finding is dispatched by Fix Engineer to the original
  Code Reviewer for adjudication only below the cumulative review allowance.
  A new adjudication verdict consumes a review round, even inside the same loop.
  Test assertion preferences and hypothetical mutations are advisory, not a
  reason to route to Chief Designer; apply README.md's test-only convergence rule.
  An unrelated cross-batch finding is tracked durably with a stable ID as
  `deferred`, evidence, rationale, and Task Intake ownership; `.ai/` alone is
  insufficient.
- If `M` implementation discovers scope requiring `H`, it dispatches Chief
  Designer before that scope is implemented. Chief Designer confirms `H` and
  independent verification, rejects the escalation with evidence, or splits;
  `H` alone does not force Design Review.
- Evidence-driven iteration is conditional guidance inside one Execution Batch.
  Put its critical unknown in `Goal` or `Acceptance Criteria`, its evaluation
  method in `Required Checks`, and deferred non-required work in `Out Of Scope`
  or `Constraints`; add no mode, field, artifact, or status.
- Optional solution exploration remains inside one Chief Designer-owned
  Execution Batch. Supporting analyses are bounded contributor tasks, not
  formal roles; default to two and allow a third only for a named missing
  material lens. Use only existing `continue` while the owner collects evidence
  or `dispatch` to the same formal Chief Designer role when another agent takes
  over synthesis. Contributor prompts are supporting instructions, not `.ai`
  routing actions; the active handoff remains with Chief Designer while they
  run.
- Temporary alternatives and synthesis may use a unique temporary path declared
  in the current task as non-authoritative helpers under the existing Runtime
  Artifact Budget. Link them rather than copying them into handoff, and clean
  them up or archive them before the next batch only when no durable record
  references them. Do not create default
  `docs/requirements/` or `docs/explorations/` authorities.
- Requirements Analyst is a conditional role action only when Task Intake
  cannot safely summarize material business ambiguity in the goal, actors,
  desired behavior, scope, acceptance, priority, business rules, or
  user-experience intent. Clear work and sufficiently explicit OpenSpec work
  retain existing shortcuts; technical ambiguity remains with Chief Designer.
- Requirements Analyst records only problem-space evidence. It must not choose
  technical design, slicing, implementation, review, exploration, or technical
  disposition. It asks two to five highest-value related questions; already
  answered or deferrable technical questions do not block confirmation. It
  keeps ownership while using `continue` or human decision `dispatch` with
  `awaiting-owner-decision` and a complete Owner Decision Brief; human
  recipients provide only the decision and are never routed as workflow agents
  or artifact authors.
- The optional `.ai/requirement-baseline.md` is temporary evidence, linked
  rather than copied into handoff, and is non-authoritative when active OpenSpec
  exists. Its only maturity labels are `draft` and `confirmed`; those labels
  stay inside the baseline and are never copied into handoff Current status,
  routing, action, or formal review values. The existing generic operational
status list remains unchanged. The eight-section committed template is
`docs/ai-collaboration/templates/requirement-baseline.template.md`.
- If a later OpenSpec change adopts the evidence, it supersedes or explicitly
  reconciles the baseline before downstream work relies on it; the baseline is
  not a competing source of truth.
- After explicit confirmation, Requirements Analyst may dispatch only Chief
  Designer with the linked baseline. A requirements-only `close` is valid only
  when current-task permits it and the named durable artifact or the baseline,
  current-task, and final handoff are archived under
  `.ai/archive/<current Execution Batch ID>/`. A material business change after
  design or implementation returns through Requirements Analyst to Chief
  Designer, who owns technical recommendations; termination/replacement still
  requires the Task Owner decision defined below.

An Execution Batch is independently closable. Unfinished parent OpenSpec work
does not block an accepted mapped batch; later work requires separate Task
Intake. Risk is read from `.ai/current-task.md` and any handoff risk metadata
must agree with it rather than inheriting a parent proposal's highest level.
An unavailable environment uses `continue` with status `blocked` and a
`- Resume condition: ...` entry under `Blockers`; `blocked` cannot be closed.
A directly reported S-level defect may use Fix Engineer self-verification
without a formal review round.

## Naming

Recommended local runtime files:

```text
.ai/current-task.md
.ai/handoff.md
.ai/round-XX-result.md
.ai/role-roster.md
.ai/review-request.md
```

Use the same round number as the associated formal review round when possible.
For example, if the next review round is
`docs/reviews/add-mobile-vat-invoicing/2026-06-08-round-29.md`, the
implementation result can be `.ai/round-29-result.md`.

## `.ai/current-task.md`

Purpose:

Define the current Execution Batch. This is the entry point for agents and
remains stable until the batch closes or is explicitly rescoped.

Required sections:

```markdown
# Current Task - <short title>

## Task Identity
## Batch Classification
## Initial Assignment
## Required Reading
## Goal
## Scope
## Out of Scope
## Must Not Touch
## Acceptance Criteria
## Constraints
## Required Checks
## Output Requirements
```

Rules:

- Define one coherent Execution Batch only.
- Map one or more closely related OpenSpec items when they jointly deliver the
  same observable behavior and validation evidence.
- Do not define a batch whose only outcome is a file, class, type, method, DTO,
  database field, endpoint, UI component, private foundation type, or
  individual test. Keep those as implementation steps unless this is a bounded
  spike that names the critical unknown it will close and requires an explicit,
  evidence-based conclusion.
- Split only at a distinct observable behavior, material contract boundary,
  owner approval, deployment, rollback, unrelated module behavior,
  independently releasable capability, or when the work cannot fit reliably in
  one or two implementation sessions.
- Include risk level `S`, `M`, or `H` and the reason.
- List every mapped OpenSpec checklist item or sub-item exactly as it appears in
  the authoritative task file.
- Include the OpenSpec change ID when one exists.
- Limit default required reading to `AGENTS.md`, applicable module instruction
  files, the assigned role sections in `workflows.md` and `agent-prompts.md`,
  and batch-specific authoritative inputs.
- Include exact validation commands when known.
- Identify foreseeable prerequisites for implementation and checks in existing
  `Constraints` or `Required Checks`. Live environment readiness and human
  preparation notices belong in handoff, not current-task routing.
- Include the first assigned role and recommended agent/tool under
  `Initial Assignment`.
- Record the reuse baseline, first demonstrable outcome, justified complexity
  exceptions, and stop condition under `Batch Classification`.
- Make `First demonstrable outcome` observable and independently testable; risk
  `H` alone is not a reason to reduce the batch to a technical prerequisite.
- Express `First demonstrable outcome` in owner-observable terms and name how
  it can be inspected. Keep detailed observable conditions in `Acceptance
  Criteria` and exact automated or manual inspection steps in `Required Checks`.
- For a design-bound batch, these fields may be marked
  `to be confirmed by Chief Designer`; the design handoff records the
  evidence-backed decisions before implementation.
- Keep mandatory Scope, Acceptance Criteria, and Constraints within the Minimal
  Authority Rule. Suggestions and assumptions may be recorded as context, but
  do not become current requirements, tasks, or acceptance by being copied here.
- Do not write current status, Next Action, or live routing here. Those belong
  only in `.ai/handoff.md`.
- For an uncertainty-driven batch, keep the critical unknown in `Goal` or
  `Acceptance Criteria`, the evaluation method in `Required Checks`, and
  deferred non-required work in `Out Of Scope` or `Constraints`.
- If optional solution exploration is used, keep the Chief Designer as the
  formal owner and describe contributors, lenses, temporary evidence paths,
  and the comparison question in existing task fields. Do not add a role,
  action, status, mode, runtime field, or authority source.

## `.ai/handoff.md`

Purpose:

Record the current Action State at an actual routing boundary. For `dispatch`,
tell the next role what changed and provide the operator command. For
`continue` or `close`, make the lack of operator dispatch explicit. Same-owner
local steps can continue without a handoff update for every micro-step. Keep
details in authoritative evidence files instead of compressing or duplicating
them here.

Required sections:

```markdown
# Handoff - <task id or round>

## Routing
## Current Status
## Delta Since Last Handoff
## Authoritative Evidence
## Known Risks
## Blockers
## Review Or Task State Impact
```

Rules:

- The `Routing` section must be complete.
- `Next action` must be exactly one of `dispatch`, `continue`, or `close`.
- Keep change details and command output in their authoritative result or
  review artifact; link those files under `Authoritative Evidence`.
- Existing handoff sections may record recommendations, assumptions, and
  blockers, but they do not authorize product scope. For a material scope
  surprise or unsupported necessity, stop only the affected work, record
  evidence, the smallest in-scope option, and the recommendation in those
  sections, then route to Chief Designer; safe unaffected work may continue.
- At a completed coherent Execution Batch boundary, reuse the existing
  sections for an informational Task Owner progress summary: `Current Status`
  states the observable outcome, `Authoritative Evidence` links inspection
  evidence or steps, `Known Risks` records deviations or risks, and `Review Or
  Task State Impact` states satisfied acceptance/OpenSpec work and remaining
  mapped work. For evaluation-driven work, state whether evidence supports,
  rejects, or cannot yet resolve the direction; this conclusion is plain
  language, not a new status or recommendation. Do not add a field, artifact,
  approval gate, or routing state.
- For `dispatch`, there are two distinct forms:
  - **Agent dispatch**: Routes work to another AI role. Must include `## Operator Command`.
    It must be directly copyable, and name the next role and batch, authoritative inputs,
    specific objective, constraints, outputs, and role prompt. Link evidence instead of
    copying it. `Current status` must not be `awaiting-owner-decision`.
  - **Human decision dispatch**: Routes an explicit asynchronous or cross-person business,
    data-authority, approval, scope, priority, experience, production, real-user, or risk
    decision to a human target (`Task Owner`, `User`, or `Data Owner`). `Current status`
    must be `awaiting-owner-decision`. `Recommended next agent`, `Next input files`,
    `Next output files`, and `Next prompt template` must be `none`. Forbid `Operator Command`.
    Requires `## Owner Decision Brief` adhering to the 5-field schema and plain-language rules.
    The current AI role retains responsibility for all workflow and runtime artifacts.
- For `continue`, omit Operator Command, keep the same responsible owner and
  agent, and name the next local step under `Current Status`. Adjacent
  non-independent role work may remain in the same session. When waiting for a decision in the active
  session, use status `awaiting-owner-decision`; add `## Owner Decision Brief`
  with one recommendation (with reason), alternatives and consequences, the smallest exact
  reply needed, and the agent's next action. Present the same brief in chat and
  remain responsible for updating all files.
- A bounded local evaluation or fix step may use `continue` only when the
  batch identity, scope, acceptance, and risk remain stable. It does not start
  a review or role handoff; record the step and evidence in the existing
  sections. At closure, distinguish evaluation evidence from production and
  OpenSpec completion and state any remaining uncertainty or deferred work.
- For optional solution exploration, contributor outputs and any synthesis are
  non-authoritative temporary helpers. Link their unique `.ai/explorations/`
  paths from existing evidence or delta sections when needed; do not paste
  alternatives into handoff. A Chief Designer who changes agent while retaining
  ownership uses `dispatch` to the same formal role with a complete Operator
  Command. The final design handoff or OpenSpec artifact must restate the
  selected direction before implementation.
- After the Task Owner answers, record the decision and its routing/scope effect
  under `Delta Since Last Handoff` before changing the status.
- Stop, wait and close boundaries keep the last valid progress, remaining mapped
  work, evidence links and the Resume condition in the existing sections. A delayed
  notice is compared with the latest Execution Batch ID, `State revision` and
  evidence before action; it does not re-dispatch an already-advanced batch or
  reopen a closed one. New evidence it carries is evaluated through the normal route.
- When Requirements Analyst owns clarification, each owner question and the
  final confirmation use either same-session `continue` or human decision
  `dispatch` with `awaiting-owner-decision` and a complete Owner Decision Brief.
  The confirmation brief summarizes goal, must-haves, acceptance, non-goals, and
  unresolved open questions; downstream roles use that summary and the linked
  baseline rather than a full transcript. Only an explicit owner reply changes
  baseline maturity from `draft` to `confirmed`.
- A confirmed Requirements Analyst exit uses `dispatch` only to Chief Designer
  with the optional baseline linked as evidence. A direct route to any other
  role is invalid. If a requirements-only batch is explicitly permitted to
  close, archive the baseline, current-task, and final handoff together under
  `.ai/archive/<current Execution Batch ID>/` unless the current task names a
  non-duplicate durable artifact instead.
- For `close`, omit Operator Command, set next-role fields to `none`, and
  include this exact field under
  `## Review Or Task State Impact`:
  `Closure outcome: accepted|stopped|superseded`. `accepted` covers only
  the mapped tasks and acceptance criteria of the current batch.
  Chief Designer records `stopped` or `superseded` only with explicit, applicable
  Task Owner authorization; neither means accepted. Include `Task Owner decision`
  in this same section: the human's scoped reply or stable evidence reference,
  owner identity, date, batch, and approved stopped/superseded outcome.
  Initial implementation approval, silence, environment unavailability, budget
  limits, and AI advice are insufficient. Reuse applicable prior authorization;
  otherwise explain the reason, recommendation, viable alternatives and their
  consequences via the existing Owner Decision Brief before closing.
- An explicit Task Owner acceptance decision may disposition named residual
  concerns without claiming they were fixed or verified. Record the scoped
  decision and limitations in this section and Known Risks; keep deferred work
  visible. Acceptance never authorizes a Git merge or proves missing business
  evidence. Do not mark unmet OpenSpec tasks complete merely to pass validation.
  When the owner explicitly accepts existing delivery despite incomplete mapped
  acceptance, Chief Designer records `Acceptance basis: owner-decision` plus
  the existing `Task Owner decision` (identity, date, batch, scoped reply/evidence)
  under Review Or Task State Impact. Keep the original mapping and unchecked
  tasks, and name the uncompleted acceptance in Known Risks. This optional,
  explicit limited-acceptance path permits close/accepted without pretending
  technical acceptance is complete. Without it, all mapped tasks must be complete.
  Other roles cannot use this override. It does not bypass environment routing
  or review independence and grants no deployment/merge authority.
- If formal review is next, route to Code Reviewer and point to
  `docs/ai-collaboration/agent-prompts.md#code-reviewer`.
- If a workspace review round was created, link it.
- If the assigned task explicitly prohibits `.ai/` writes, a higher-priority
  instruction prohibits every file write, or tool permissions prevent the
  update, do not silently omit the handoff. Put complete Routing in the final
  response, include Operator Command for `dispatch`, and state that the file
  handoff remains stale. This response handoff is a degraded fallback, not a
  replacement for `.ai/handoff.md` when file writes are allowed.

## Environment Preparation

Use this conditional handoff section only when the assigned work or required
checks need human-only environment preparation. Omit it when none is needed;
it is not a universal approval gate or a new operational status. Preserve
outstanding notices across handoffs until the dependent checks are complete or
the Task Owner has explicitly authorized termination/replacement removing them.
Use one level-three heading per prerequisite so a ready environment cannot
conceal another pending prerequisite. Each item has these five fields:

```markdown
## Environment Preparation

### WebForms page verification

- Readiness: `pending`
- Needed before next action: `no`
- Human action: 请在页面验证前，在 Visual Studio 中启动 WebForms 调试并保持 IIS Express 运行；页面验证需要 http://localhost:3000/ 可访问。
- Confirmation and check: 启动后回复“已启动”；当前 Agent 检查目标地址是否可访问，再继续页面验证。记录实际结果，登录页可访问不等同于业务页面验收。
- Work that can proceed: 可以先修改代码、编译和执行离线测试；页面验证完成前不声称批次已验收。
```

`Readiness` is an environment fact, exactly `ready`, `pending`, or `unknown`;
it never replaces Routing `Current status`. `Needed before next action` is
exactly `yes` or `no`, relative to the first executable step of the proposed
assignment or resumption. A prerequisite for a later required check is `no`
until that check is next; do not use `no` to omit or conceal required checks.
`Human action` names who should do what, why, and at what point in ordinary
language. `Confirmation and check` gives the smallest human confirmation and
the agent's readiness check; for `ready` it includes observed evidence.
`Work that can proceed` names safe unaffected work, or states that none can
proceed. Repeat the notice in chat before dispatch so the Task Owner sees it.

If any item is `pending` or `unknown` and `Needed before next action: yes`,
do not dispatch an AI role into that dependency. Use `continue` with `blocked`,
keep the current agent responsible, and record `- Resume condition: ...` in
`Blockers`. An unverified condition should first receive a cheap read-only
probe when practical. The same agent resumes after confirmation and checks.
An engineer who discovers this situation follows the same wait instead of
routing routine setup back to Chief Designer. If resolution changes a business
or design boundary, use the existing escalation or owner-decision route.
Pure preparation does not use an Owner Decision Brief. Pending later-step
preparation (`no`) allows safe offline dispatch and remains visible.

The runtime validator can check declared fields and routing consistency. It
cannot prove that prerequisites were exhaustively identified, a notification
was seen, an environment is live, or a human authorization is authentic;
the responsible role and independent review must check the actual evidence.

## Actionable Human Instructions

This is a required human communication rule, not a prose-parsing validation gate.
Every blocked handoff or Environment Preparation notice must contain actionable
instructions in the handoff itself; chat alone does not suffice.
When asking the Task Owner/Operator to act, give a short notice in their language:
where to act, what to do and why, and what small reply/result lets the agent
continue. Use existing Human action, Confirmation and check, Blockers or chat;
repeat an important handoff notice in chat so it is visible.

For file/configuration or CLI actions, give the exact verified path (and working
directory where relevant), paste/merge location and a copy-ready snippet for
the requested action. Do not give a full replacement config if only a merge is
intended. For UI-only actions, name the application, screen and precise action;
explain briefly that no configuration/CLI snippet applies. Prefer a safe inexpensive step,
with deeper diagnosis only if needed. Explain impact/undo for temporary changes.
If no safe fix is known, say so and ask for the smallest sanitized evidence;
do not invent keys, credentials or commands. Never use unexplained theory codes
as the entire instruction.

An optional Operator Action Guide may organize longer instructions. Clearly
separate the recommended recovery step from optional deeper diagnostics when
both are present. No fixed heading, four-field checklist or evidence-request
flag is required. Existing guides remain readable; the validator does not
pretend to prove that an instruction or snippet is safe or useful.
Environment Preparation, Resume condition, owner authorization and the three
actions retain their existing rules. A human notice is not the AI Operator Command.

Example, needing no extra guide/code: 请在 Visual Studio 中启动 WebForms 调试并
保持 IIS Express 运行；页面检查需要 http://localhost:3000/ 可访问。启动后回复
“已启动”，我会检查地址再继续；离线修改可先进行。This illustrates the known
local WebForms runtime, not authorization to change an API configuration.

Further examples (illustrative; verify the real path, screen or output first):

- File/CLI, merge-only: in `E:/Projects/your-project` run
  `powershell -NoProfile -ExecutionPolicy Bypass -File docs/ai-collaboration/scripts/validate-runtime-state.ps1 -WorkspaceRoot 'E:/Projects/your-project'`
  and reply with the first error line, or "通过" if it passes. Nothing else changes.
- Blocked wait: the handoff records `- Resume condition: 用户回复“已启动”后，当前 Agent
  检查 http://localhost:3000/ 可访问再继续`. Offline edits and unit tests may continue
  meanwhile; the same agent resumes after the check.
- Late notice: a message "请开始 Code Review" arrives after the handoff already shows a
  later `State revision` with that review closed. The agent records it as stale and
  does not dispatch again; a new defect it reports is still evaluated normally.

## `.ai/round-XX-result.md`

Purpose:

Summarize an implementation or fix round that changed code, tests, or runtime
configuration.

Required sections:

```markdown
# Round XX Result

## Paths Created Or Updated
## Work Summary
## Evidence Per Finding Or Requirement
## Checks Run
## Review Impact
## OpenSpec Task Impact
## Remaining Risks
## Next Action
```

Rules:

- Record exact commands and observed results once.
- Link any durable review round created or updated.
- State whether OpenSpec `tasks.md` changed.
- If code files changed, record graph update action when required by
  `AGENTS.md`.
- Do not create a result file for a review, verification, or documentation-only
  action when the formal review round or handoff already owns that evidence.

## `.ai/role-roster.md`

Purpose:

Map functional roles to concrete agents/tools for the current operator.

Required sections:

```markdown
# Role Roster

## Default Assignments
## Task-Specific Overrides
## Notes
```

Rules:

- Keep this file local because it may include personal tool preferences.
- Use roles as the stable contract.
- Change agent/tool assignments without changing workflow definitions.

## `.ai/review-request.md`

Purpose:

Package a review request when the next step is formal or local review.

Required sections:

```markdown
# Review Request - <task id>

## Review Target
## Required Reading
## Scope
## Evidence To Check
## Output Requirements
```

Rules:

- For workspace-level review, output must be a new
  `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` file and an updated
  `docs/reviews/<change-id>/index.md`.
- Do not ask the reviewer to modify legacy review artifacts.

## Durable Review Round

The durable review round schema is defined by `docs/reviews/README.md`.

Use `templates/review-round.template.md` only as a convenience copy of the
workspace review shape plus a Next Action decision. If the two documents conflict,
`docs/reviews/README.md` wins.

Review rounds may include priority labels in addition to formal status:

```text
must-fix
should-fix
nice-to-have
```

Priority controls routing and fix scope. Status controls durable review state.

## Routing Section Schema

Use this required core shape in `.ai/handoff.md`:

```markdown
## Routing

- Next action: `<dispatch|continue|close>`
- Current role: `<role>`
- Current agent: `<agent or tool>`
- Current status: `<operational status>`
- Review round: `<cumulative completed review verdicts>`
- Next role: `<role>`
- Recommended next agent: `<agent or tool>`
- Next input files:
  - `<path>`
- Next output files:
  - `<path>`
- Next prompt template:
  - `<path#section>`
```

`Review round` is the cumulative number of completed design/code review, verification or
finding-adjudication verdicts for this Execution Batch, starting at 0 before
review. Record it in Routing and increment it when issuing a verdict, not for
each file edit or historical artifact filename. Preserve it across role changes,
REVISE and disputed-finding routes. A design-cycle counter, State revision and
optional Process Metrics are not substitutes. Never reset the count by renaming
the same unfinished batch.

At `Review round: 3` or higher, only evidence-supported `close`, a Task Owner
decision route (`continue`/human `dispatch` with `awaiting-owner-decision`),
or a route covered by an applicable finite owner authorization under
README.md#review-round-circuit-breaker is allowed. No fourth agent review,
fix, or design dispatch is allowed without one. Existing
closure, owner-authorization and independence checks still apply. For migrated
over-limit batches preserve the actual known count and converge immediately;
do not fabricate history. See README.md#review-round-circuit-breaker.

The validator requires this count for every agent dispatch and for active
Chief Designer, Design Reviewer, Implementation Engineer, Code Reviewer,
Fix Engineer and Verification Reviewer handoffs. Legacy closed records may
omit it for compatibility; new records include it. This is a structural guard,
not an authenticated audit log: the responsible role must reconcile the count
against actual verdicts; the script cannot detect a fabricated lower count.

`Risk level` and `Design review round` are optional Routing metadata. Other
state belongs in the sections below Routing rather than new routing fields.
Optional manual-handoff metadata may also include:

```markdown
- Execution Batch ID: `<batch-id>`
- State revision: `<positive integer>`
```

When present, the batch ID and risk must match `.ai/current-task.md`.
`State revision` supports manual comparison against the latest handoff; the
validator checks syntax only, not freshness or atomic locking. These metadata
fields are optional. Legacy close missing Closure outcome emits a compatibility
warning. New close records must include the closure outcome;
`blocked` handoffs must use `continue` and include `- Resume condition: ...`.

For `continue` or `close`, use `none` for fields that do not apply. For `continue`
with status `awaiting-owner-decision`, the handoff must include `## Owner Decision Brief`.

For `dispatch` to an AI role:
Every next-role field is mandatory (non-`none`), status cannot be `awaiting-owner-decision`,
and the handoff must contain `## Operator Command`:

````markdown
## Operator Command

```text
You are the <next role> for Execution Batch <batch id>.
Read: <authoritative paths>.
Objective: <specific next outcome>.
Constraints: <scope and must-not-do summary>.
Output: <required files or closure decision>.
Follow: docs/ai-collaboration/agent-prompts.md#<role-section>.
```
````

For human decision `dispatch` (`Next role` is `Task Owner`, `User`, or `Data Owner`):
`Current status` must be `awaiting-owner-decision`. `Recommended next agent`, `Next input files`,
`Next output files`, and `Next prompt template` must be `none`. `Operator Command` is forbidden.
The handoff must contain `## Owner Decision Brief`:

````markdown
## Owner Decision Brief

- Decision needed: <one plain-language question or decision needed>
- Recommendation: <recommended choice> (Reason: <plain-language reason>)
- Alternatives:
  - <alternative 1> (Consequence: <consequence of alternative 1>)
  - <alternative 2> (Consequence: <consequence of alternative 2>)
- Reply needed: `<exact reply or short choice>`
- After the reply: <what the current AI role will do after the reply>
````

The brief must ask for one decision only, put one recommendation first with its reason,
detail viable alternatives with consequences, provide the smallest exact reply (rendered
in quotes or inline code), state what the current AI will do next without assigning workflow
or artifact duties to the human, and use audience-appropriate language free of internal process jargon.

Legacy `Next Instruction` sections are accepted when reading old handoffs, but
new or updated agent dispatch handoffs must use `Operator Command`.

## Response Handoff Fallback

Use this only when strict read-only instructions or tool permissions prevent
updating `.ai/handoff.md`. The final response must contain this directly
copyable structure for `dispatch`:

````markdown
## Response Handoff

- Next action: `dispatch`
- Current role: `<role>`
- Current agent: `<agent or tool>`
- Current status: `<operational status>`
- Review round: `<cumulative completed review verdicts>`
- Next role: `<role>`
- Recommended next agent: `<agent or tool>`
- Next input files: `<authoritative paths>`
- Next output files: `<required paths or response artifacts>`
- Next prompt template: `docs/ai-collaboration/agent-prompts.md#<section>`
- Handoff persistence: `.ai/handoff.md was not updated because <constraint>. Persist this Action State before relying on the file.`

## Operator Command

```text
You are the <next role> for Execution Batch <batch id>.
Read: <authoritative paths>.
Objective: <specific next outcome>.
Constraints: <scope and must-not-do summary>.
Assigned findings: <finding IDs, evidence paths or lines, and required outcomes>.
Output: <required files or closure decision>.
Follow: docs/ai-collaboration/agent-prompts.md#<role-section>.
```
````

For `continue` or `close`, use the same `Response Handoff` fields with
next-role values set to `none` and omit `Operator Command`. A `close` response
must explicitly say that no next role or command exists and include
`Closure outcome: accepted|stopped|superseded` when closing. The next write-capable
role must persist the response handoff before treating `.ai/handoff.md` as the
live Action State.

When strict read-only also prohibits a formal or local review artifact, the
findings in the final response are the only review evidence. Report the full
finding set before `Response Handoff`. For `dispatch`, embed every assigned
finding's ID, evidence path or line, and required outcome inside the Operator
Command; do not refer only to "the findings above" or assume the next agent can
see the reviewer conversation.

Process Metrics is optional for dispatch, continue and close. If useful, add
`## Process Metrics` and only available fields: Role actions,
Review/fix/verification loops, Broad regression runs, Elapsed time or Token usage.
Do not invent totals or add a ledger to obtain them. Supplied count values must
be nonnegative integers or legacy unknown; omitted fields are not errors.
Historical full/unknown records remain readable. Known target overruns stay
advisory and do not add approvals or authorize repeated review/fix loops.

Recommended operational statuses:

```text
draft
ready-for-design-review
design-review-in-progress
ready-for-architecture-review
ready-for-ui-review
ready-for-implementation
ready-for-review
ready-for-fix
ready-for-verification
ready-for-closure
awaiting-owner-decision
blocked
```

Formal review status must still use only:

```text
open
fixed-not-verified
verified
deferred
```

## Source Of Truth Rules

| Data | Write it here |
| --- | --- |
| Task scope and acceptance criteria | `.ai/current-task.md` |
| Current Action State and next role | `.ai/handoff.md` |
| Implementation or fix evidence | `.ai/round-XX-result.md` |
| Formal findings and verification evidence | `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` |
| Current review status | `docs/reviews/<change-id>/index.md` |
| Execution checklist state | `openspec/changes/<change-id>/tasks.md` |

## Anti-Patterns

- Pasting an entire chat transcript into a handoff.
- Asking a reviewer to infer scope from git diff alone.
- Recording workspace review findings only in `.ai/`.
- Marking a topic `verified` without fresh evidence.
- Letting a Fix Engineer work on Nice to Have items outside the assigned batch.
- Handing off without a next role and recommended next agent/tool.
- Resetting cumulative review rounds through REVISE, role changes, adjudication
  or renaming unchanged work; at the batch ceiling use closure or Task Owner,
  never another Chief Designer or reviewer dispatch without an applicable
  finite owner authorization.
- Creating one fix round per finding instead of aggregating assigned findings.
- Starting a separate Verification Reviewer round after a clean review.
- Rerunning an unchanged broad regression in every role action.
- Creating a Documentation Steward round only to copy an already verified
  status into OpenSpec.
- Naming runtime sub-items that are absent from the authoritative OpenSpec
  checklist.
- Using agent `dispatch` without a copy-ready Operator Command, or using human decision `dispatch` with an Operator Command.
- Treating review-only as permission to omit the Action State or next-role
  prompt.
- Forbidding `.ai/handoff.md` edits in a generated reviewer prompt without
  requiring the response handoff fallback.
- Routing a human target with agent-dispatch fields (agent, files, prompt, or Operator Command), or using `dispatch` to make a Task Owner, User, or Data Owner act as an agent or edit runtime files.
- Using `close` when another agent still needs to act or an owner decision is pending.
- Deferring mechanical closure to a Documentation Steward when the reviewing
  role can safely reconcile it.
- Leaving an earlier `dispatch` handoff unchanged after `continue` or `close`.
- Treating unfinished parent OpenSpec work as a blocker for an accepted mapped
  batch.
- Using `close` for a blocked operational handoff; record the resume condition
  and use `continue` instead.
- Writing live routing into `.ai/current-task.md`.
- Closing with an unresolved assigned `should-fix`.
