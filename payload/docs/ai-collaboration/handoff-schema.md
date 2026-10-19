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
  owner-decision wait, operational interruption, planned session end, or batch
  closure. A planned session end is a boundary even when the role does not change;
  it keeps the same responsibility and counts. Same-owner local steps inside one
  active session do not require a manual dispatch or a new handoff for every
  micro-step; record a materially changed next step or evidence when needed.
- At each such boundary, the role permitted to write saves the complete Action
  State, reads back the saved Routing (batch, action, next role, cumulative
  Review round, and State revision when present), and runs the structure
  validator with the expected state it decided; see
  [expected state validation](#expected-state-validation). The final response
  states in one sentence whether the file was updated or why it was not.
  Same-owner micro-steps inside the active session need neither write-back nor a
  new check; a planned session end does not count as a micro-step.
- Read-only prohibits file writes unless the assignment explicitly authorizes
  named review or handoff outputs. Response-only consultation reports in chat
  without changing live business batch state.
- A formal dispatch lists each writable output in its Operator Command and
  Next output files: the review record, the review index, `.ai/handoff.md`, and
  any other named artifact. Business code, tests and unrelated files stay
  read-only unless they are named. A dispatcher must not add a `.ai/` write ban
  only because a review is independent, generically read-only, or preferred that
  way. Such a ban requires an explicit user or higher-priority instruction, or an
  actual tool permission limit, and the command names that source. Under such a
  limit use the response handoff fallback; it never overrides the limit.
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

A result file must not collide with an older file under `.ai/`. When the
round-numbered name is already in use (for example by an earlier batch), write the
result to a batch-scoped path such as a per-batch folder under `.ai/`. Never
overwrite an existing result file, and never reuse a round number already used by
the same batch.

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
- OpenSpec task mapping uses exactly one authoritative checklist file:
  `openspec/changes/<change-id>/tasks.md`. That file groups work under `## 1.`,
  `## 2.`, and so on, and lists actionable items with dotted IDs such as
  `- [ ] 1.1` and `- [ ] 1.2`. In `Batch Classification`, list each mapped ID
  on its own bullet (for example `` `1.1` ``) so the runtime validator can match
  the same ID in tasks.md. Do not treat a flat `- [ ] 1.` line or a bare section
  number as a substitute for a dotted sub-item, and do not maintain a parallel
  checklist outside tasks.md.

  Example tasks.md excerpt:

  ```markdown
  ## 1. First group

  - [ ] 1.1 First mapped item.
  - [ ] 1.2 Second mapped item.

  ## 2. Second group

  - [ ] 2.1 Item in the next group.
  ```

  Example `OpenSpec checklist items` mapping for batch `1.1` and `1.2`:

  ```markdown
  - OpenSpec checklist items:
    - `1.1`
    - `1.2`
  ```
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
- In `Authoritative Evidence`, backtick values that contain path separators must
  be real files that exist in the workspace. Do not put shell commands in any
  evidence backtick. Record the exact command, observed
  output (or summary), exit code, and any log path in `.ai/round-XX-result.md`
  under `Checks Run`, then link that result file here.
- For `OpenSpec checklist`, put the tasks file path in backticks and state the
  mapped item IDs outside the path (for example
  ``openspec/changes/<change-id>/tasks.md`` items `1.1`, `1.2`). Do not embed
  the whole command line inside the path backtick.
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
  role, and name the next local step under `Current Status`. An eligible
  replacement session may assume the same responsibility after checking latest
  authority and exclusive execution ownership; record the actual Current agent.
  This does not replace a role dispatch or required independent review. Adjacent
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
- Ordinary `accepted` closure also follows
  [Accepted closure validation](#accepted-closure-validation). A structural
  validator exit 0 alone is not sufficient to report ordinary verification
  success.
- For agent `dispatch`, put one advisory capability line as the first line under
  `Current Status` and briefly echo the same tier in the final response. Omit it
  for human decision `dispatch`, `continue`, and `close`. See
  [Capability tier guidance](#capability-tier-guidance).
- If formal review is next, route to Code Reviewer and point to
  `docs/ai-collaboration/agent-prompts.md#code-reviewer`.
- If a workspace review round was created, link it.
- If the assigned task explicitly prohibits `.ai/` writes, a higher-priority
  instruction prohibits every file write, or tool permissions prevent the
  update, do not silently omit the handoff. Put complete Routing in the final
  response, include Operator Command for `dispatch`, and state that the file
  handoff remains stale. This response handoff is a degraded fallback, not a
  replacement for `.ai/handoff.md` when file writes are allowed. Its
  [source-matched narration](#source-matched-recovery) names the batch, the
  source role and Agent, the prior `State revision` when one exists, the SHA256
  of the live handoff bytes it was based on and the target `State revision`, or
  states that the fingerprint is unavailable only for a legacy record; a new container carries a real 64-hexadecimal SHA256.
- When a read-only subagent returns a valid same-batch result and the parent or
  responsible Agent is still active and permitted to write the handoff, that
  Agent checks the source, execution ownership and actual verdict. It then either
  publishes the transfer directly to `.ai/handoff.md`, or first saves a complete
  recovery container in the batch's own result file when a durable copy is needed.
  Either way it reads back the saved bytes, runs expected-state validation before
  its boundary ends, and states the subagent's findings in its own reply. The
  subagent remains read-only, the verdict is counted once, and the saved
  attribution keeps the originating role. An existing result file is never
  overwritten to save it. If no permitted writer is active, or a higher-priority
  prohibition binds that writer too, keep the complete response handoff and state
  that it is not persisted.

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
- Human action: None now. Later page verification depends on a running Visual Studio WebForms debug session with IIS Express.
- Confirmation and check: Before page verification, the agent will check http://localhost:3000/ reachability and request preparation only if still needed. No action or reply is needed during offline implementation.
- Work that can proceed: Code edits, build, and offline tests may continue; do not claim batch acceptance before page verification completes.
```

`Readiness` is an environment fact, exactly `ready`, `pending`, or `unknown`;
it never replaces Routing `Current status`. `Needed before next action` is
exactly `yes` or `no`, relative to the first executable step of the proposed
assignment or resumption. A prerequisite for a later required check is `no`
until that check is next; do not use `no` to omit or conceal required checks.
For an **Immediate Blocker** (`yes` with `pending`/`unknown`), `Human action`
names who should do what, why, and where in ordinary language; `Confirmation
and check` gives the smallest human confirmation and the agent's check.
For a **Forward Notice** (`no`), both fields are neutral information only:
describe the later dependency and the agent's future check point, explicitly
state that no current human action or reply is needed, and never include an
imperative instruction, copy-ready human action, or request such as "reply
ready" (including translated equivalents). `Human action: none` is valid here.
Do not append current human instructions elsewhere to defeat this distinction.
For `ready`, record observed readiness evidence rather than a new reply request.
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
preparation (`no`) allows safe offline continue/dispatch and remains visible as
a neutral notice. Change it to `yes` and recheck when its dependent step is next;
do not silently drop it or close before required checks have evidence.
The human intervention summary is `none` for a forward notice and
`awaiting-environment` for an unmet human-only immediate prerequisite.

The runtime validator can check declared fields and routing consistency. It
cannot prove that prerequisites were exhaustively identified, a notification
was seen, an environment is live, or a human authorization is authentic;
the responsible role and independent review must check the actual evidence.

## Actionable Human Instructions

This is a required human communication rule, not a prose-parsing validation gate.
Every blocked handoff requiring human intervention must contain actionable
instructions in the handoff itself; chat alone does not suffice. A Forward
Notice is informational: the no-action rule above takes precedence, and no
current instructions or reply request are attached to it.
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

Example, needing no extra guide/code: Start WebForms debugging in Visual Studio and
keep IIS Express running; page checks need http://localhost:3000/ reachable. Reply
`started` when ready and the agent checks the address before continuing; offline
edits may proceed meanwhile. This illustrates the known local WebForms runtime,
not authorization to change an API configuration.

Further examples (illustrative; verify the real path, screen or output first):

- File/CLI, merge-only: in `E:/Projects/your-project` run
  `powershell -NoProfile -ExecutionPolicy Bypass -File docs/ai-collaboration/scripts/validate-runtime-state.ps1 -WorkspaceRoot 'E:/Projects/your-project'`
  and reply with the first error line, or `pass` if it passes. Nothing else changes.
- Blocked wait: the handoff records `- Resume condition: After the owner replies started, the current agent checks http://localhost:3000/ reachability before continuing`. Offline edits and unit tests may continue meanwhile; the same agent resumes after the check.
- Late notice: a message "start Code Review" arrives after the handoff already shows a
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

- Record exact commands, observed results, and exit codes once in `Checks Run`
  (use the `Result` column for output summary and exit code). Handoff
  `Authoritative Evidence` links this file instead of repeating command text.
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

## Accepted closure validation

Ordinary `close` with `Closure outcome: accepted` states mapped-batch
acceptance, not completion of every parent OpenSpec item, log authenticity,
host Skill loading, or business verification. These rules apply to new or
normally updated closures; they do not rewrite historical archives or reopen
closed batches.

This section is the single authoritative explanation. README Routing Contract,
workflows Role Exit Contract, and Common Preflight cite it instead of restating
the full sequence.

### Ordinary accepted sequence

Before reporting ordinary acceptance to the Task Owner or persisting a final
`accepted` close, the responsible role:

1. Confirms mapped acceptance, required independent review, cumulative
   `Review round`, and OpenSpec task state. Do not check off unfinished mapped
   tasks to pass structure validation.
2. Chooses an existing result file, formal review record, or boundary log as
   the evidence container. Pre-create real sections; mark not-yet-run work
   honestly instead of empty success placeholders.
3. Finalizes `.ai/current-task.md`, mapped `tasks.md`, and `.ai/handoff.md`
   for `close` with `Closure outcome: accepted` and links the evidence
   container from `Authoritative Evidence`. Do not report closure as verified
   yet; record version or hash identifiers for structural inputs used.
4. Runs `docs/ai-collaboration/scripts/validate-runtime-state.ps1` against the
   final inputs. Record the full launch command, observed exit code,
   diagnostics or warnings, and input correspondence in the evidence
   container outside the validated handoff. Appending log output must not
   change validated handoff bytes.
5. Confirms inputs are unchanged. Report ordinary acceptance only when
   validation actually succeeded and other acceptance requirements are met.
   Do not write exit codes, timestamps, or hashes back into the handoff after
   validation; any input that affects the conclusion requires re-validation.

Minimum input correspondence covers `.ai/current-task.md`, `.ai/handoff.md`,
and whichever tasks, scripts, role cards, and templates actually participated
in the structural decision for this closure.

### Failures, blocked environments, and limited owner acceptance

Non-zero exit codes stay recorded; do not publish ordinary `accepted`
conclusions. Fix within role authority, update final inputs, and re-validate.
When repair or environment is unavailable in this action, revert to a truthful
`continue` or `dispatch`. Environment waits use `continue` with status
`blocked` and `- Resume condition: ...`; blocked work cannot `close`.
Use `awaiting-owner-decision` only for substantive owner decisions, not as a
substitute for validation failure.

Chief Designer's explicit limited acceptance still uses `Acceptance basis:
owner-decision` and `Task Owner decision`. Unchecked mapped tasks and unmet
technical acceptance stay visible in Known Risks. Structure validation success
does not mean those technical items are verified. This path does not bypass
invalid Routing, blocked-to-close, independence, or cumulative review limits.

### Response handoff and legacy records

File and response closures follow the same evidence rules. When read-only or
tool limits prevent updating `.ai/handoff.md`, state the actual objects checked,
that the live file may remain stale, and do not claim a new ordinary `accepted`
closure from an old file's exit 0 alone. When a permitted independent snapshot
is used, name the snapshot scope and that persistence of `.ai/` is not proven.

Legacy closed handoffs without the newer evidence narration remain readable;
do not reopen closed batches or reset review counts to add narration
retroactively.

### Validator boundary

`validate-runtime-state.ps1` checks structural shape and declared paths; it
does not certify exit-code logs, command transcripts, input freshness, agent
compliance, host loading, or business acceptance. Missing matching evidence may
still yield exit 0 on structure; the responsible role must not treat that as
ordinary verification success. Its optional expected-state parameters compare
only the values the role supplies with the saved Routing; they add no
authenticity or freshness proof. A structure-only exit 0 is not the expected-state
check for an updated boundary.

## Capability tier guidance

Advisory only: helps operators choose model and reasoning strength for the
**next** dispatched work item. It is not a qualification gate, approval step,
machine field, or blocker. It does not change role duties, S/M/H, tool
permissions, independent review, cumulative `Review round`, or closure rules. It
does not select models, change host configuration, or start orchestration.

### Tier definitions

| Tier | Meaning |
| --- | --- |
| C1 | Basic execution: follow given steps for mechanical, explicit work |
| C2 | Routine implementation: bounded local tasks with clear edges |
| C3 | Integrated engineering: coordinate implementation, checks, and routine review |
| C4 | Deep analysis: design trade-offs or complex cross-module reasoning |
| C5 | High-difficulty reasoning: exceptional reasoning explicitly required by the task |

Maintain this table only in this section. Human guides may provide translated
short glosses that link here; do not maintain a second role-default table
elsewhere.

### Default mapping by next role

Look up the **next role** in `Routing` (the role receiving the Operator
Command). Use exactly one line as the first content under `## Current Status`:

`Recommended capability tier: Cn`

| Default tier | Next roles |
| --- | --- |
| C1 | Documentation Steward |
| C2 | Task Intake, Requirements Analyst, UI Designer, Test Engineer |
| C3 | Implementation Engineer, Fix Engineer, Code Reviewer, Verification Reviewer |
| C4 | Chief Designer, Design Reviewer, Architect |
| C5 | *(no default role)* |

Task Intake follows the same table when it is the next role.

### Overrides using existing task information only

When the current authorized task already states difficulty for **this** next
handoff, prefer that over the role default:

- Explicit mechanical step-following work → C1
- Explicit routine local bounded work → C2
- Explicit deep cross-module analysis → C4
- Explicit requirement for exceptional high-difficulty reasoning → C5

When no explicit override exists, use the role default. Do not investigate,
score models, write tier justification in the handoff, paste this table, or add
per-dispatch reasoning reports. Do not derive tier from S/M/H labels, review
round count, or a single failed attempt. Never default any role to C5 without
explicit task basis for this handoff.

The tier describes the suggested capability for **this** next item of work, not
a permanent rating of the role, agent, or model.

### When to show or omit the line

| Situation | Capability line |
| --- | --- |
| Agent `dispatch` | Required as the first line under `Current Status`; briefly echo the same `Cn` in the final response |
| Human decision `dispatch` | Omit |
| `continue` (including `awaiting-owner-decision` and `blocked`) | Omit |
| `close` | Omit |

Do not add the line to `Routing`, Operator Command, or validator-checked machine
fields. File handoffs and the [response handoff fallback](#response-handoff-fallback)
use the same rule: for agent `dispatch`, include the line in `Current Status`
before other status prose.

Older handoffs without the line remain valid; continuation must not require
backfill or migration.

## Routing Section Schema

Use this required core shape in `.ai/handoff.md`:

```markdown
## Routing

- Next action: `<dispatch|continue|close>`
- Human Action Required: `<none|awaiting-decision|awaiting-environment>`
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

`Human Action Required` is a summary of current human intervention, not a new
action, status, authorization, or proof of readiness. New and normally updated
file/response handoffs include it once in Routing:

| Value | Meaning and consistency |
| --- | --- |
| `none` | No current human intervention; includes executable continue, agent dispatch, close, and operational waits requiring no human preparation |
| `awaiting-decision` | Current status is `awaiting-owner-decision`; retain the Owner Decision Brief |
| `awaiting-environment` | `continue` + `blocked`, with an unmet human-only prerequisite needed before the next action and a Resume condition |

A later-only notice or a ready prerequisite cannot require environment action
now. Old handoffs may omit this field without warning, migration or backfill;
read their actual status, decisions and prerequisites instead. Never use
`none` to override a real wait or the review circuit breaker.

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

### Expected state validation

`validate-runtime-state.ps1` accepts optional expectations: `-ExpectedBatchId`,
`-ExpectedNextAction`, `-ExpectedNextRole`, `-ExpectedReviewRound` and
`-ExpectedStateRevision`. They are compared only with the one real `## Routing`
section, fence-aware. A missing or duplicate field never borrows a value from an
example or another section.

- Supply `-ExpectedBatchId` whenever any other expectation is supplied. An empty
  value, an action other than `continue`, `dispatch` or `close`, a negative or
  non-numeric review count, or a zero revision returns exit 1. An explicit
  `0` for `-ExpectedReviewRound` is a valid expectation.
- A mismatch names the field, the expected value and the saved value. Structural
  errors are reported together with mismatches; a matching expectation never
  excuses a structural violation.
- Take expected values from the transfer the role has decided, never from the
  file being checked. A new transfer increments `State revision` and records the
  cumulative `Review round` after its verdict.
- An updated boundary passes the decided batch, action, next role and cumulative
  count, plus `-ExpectedStateRevision` when the handoff has a revision. A bare
  structural exit 0 does not prove that these expectations were checked. Calls
  without expectations keep their legacy meaning for existing callers and older
  records.
- The check is read-only and does not prove freshness, authenticity, reviewer
  independence or acceptance. Report it as a structure and stated-value check only.

```text
powershell -NoProfile -ExecutionPolicy Bypass -File docs/ai-collaboration/scripts/validate-runtime-state.ps1 -ExpectedBatchId <batch-id> -ExpectedNextAction dispatch -ExpectedNextRole "Fix Engineer" -ExpectedReviewRound 2 -ExpectedStateRevision 5
```

## Autonomous Continuation

An active, capable agent must immediately carry out an authorized executable
`continue` after checking latest task, batch, revision, evidence, review allowance
and execution ownership. Choosing a local CLI terminal or IDE conversation is an
agent execution detail within already authorized offline work, not a Task Owner
decision. Do not ask which host to use, request another "continue" confirmation,
or stop solely because a prior single-turn runner exited. Use available safe
tools; a missing permission or actual capability is a concrete limit to report.
Check an existing same-batch writer before taking over; do not duplicate writes,
launch competing agents, or kill another process to manufacture ownership.

At an executable `continue` boundary, new/updated handoffs include one compact
subsection **inside Current Status** (not in Routing):

````markdown
### Continuation Command

```text
You are continuing as <current role> for Execution Batch <batch id>.
Use EngRelay for this task; resume only the latest authorized continue.
Read: AGENTS.md, .ai/current-task.md, .ai/handoff.md, <authoritative tasks and evidence>.
Objective: <specific authorized next step>.
Constraints: Check latest state and execution ownership; retain scope, risk, review count and independence; <task limits>.
Output: <result evidence and handoff at the next real boundary>.
Follow: docs/ai-collaboration/agent-prompts.md#<current-role-section>.
```
````

It is an agent prompt, not a shell command or human preparation request. An
already active agent executes the step directly; an operator or existing runner
can use the block to start a replacement session without the preceding chat.
On takeover, record the actual Current agent in Routing and increment `State revision` in the same write; keep the responsible role, batch and
cumulative Review round. A transfer superseded by that takeover compares as advanced and is never replayed. A change of formal role, synthesis-agent transfer, or
independent review still uses `dispatch` with its Operator Command.

Omit the continuation block for `blocked`, `awaiting-owner-decision`, `dispatch`
and `close`. Those conditions, exhausted review allowance and conflicting inputs
take precedence over any stale command. Legacy executable continue without the
block resumes from Current Status and authoritative task inputs when sufficient;
missing new fields alone never requires owner approval. This protocol does not
wake processes, schedule background work, or promise unattended cross-turn execution.

### Planned session end and long-check checkpoint

Ending the active session on purpose, or handing unfinished work of the same role to
another session, is a real boundary even when the role does not change. Before ending,
save the current facts, the remaining work and the evidence in `.ai/handoff.md` with an
executable `continue` and its Continuation Command. The successor session checks latest
state and execution ownership first, records its actual Current agent, and increments
`State revision` in the same write; it does not start a second writer for work another
session may still be running.

A foreseeable long check, one that may exceed the session budget after material progress
has been made, may use this same `continue` as a checkpoint. Its Current Status records
the completed steps, the check that has not finished, the external log path, how to see
whether the process is still running, and that the check is not yet passed. Write the
checkpoint once per interruption, not before each step, and never report the check as
successful before its log shows completion. Logs stay in the external file. A checkpoint
does not promise that progress lost in a sudden termination was saved.

## Dispatch Commands

For `dispatch` to an AI role:
Every next-role field is mandatory (non-`none`), status cannot be `awaiting-owner-decision`,
and the handoff must contain `## Operator Command`. The command lists each writable
handoff output by name (see General Rules). If it prohibits `.ai/` writes for a named
source, it also states the response handoff fallback for that role:

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
- Human Action Required: `<none|awaiting-decision>`
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

## Current Status

Recommended capability tier: C3

<Status prose. Keep the capability line only for agent dispatch. For executable continue use the Current Status / Continuation Command form above; omit the capability line for human decision dispatch, continue and close.>

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
sets Human Action Required to `none`; executable `continue` responses include
the same Current Status / Continuation Command as file handoffs, while actual
waits show the matching human-intervention summary and omit that block. A close response
must explicitly say that no next role or command exists and include
`Closure outcome: accepted|stopped|superseded` when closing. Ordinary `accepted`
responses follow [Accepted closure validation](#accepted-closure-validation):
record matching validation evidence outside any validated snapshot and do not
claim a new ordinary acceptance from stale file checks alone. The next
write-capable role must persist the response handoff before treating
`.ai/handoff.md` as the live Action State.

When the same role may write a formal review record and index but not
`.ai/handoff.md`, keep one complete copy of the response handoff inside that
review record's existing `Next Actions` section. Wrap it in an outer fence longer
than the longest backtick run inside it (at least four), so the copy can be extracted without rewriting. Add the
source batch, source role, source Agent, work producer Agent, the actual verdict,
the cumulative Review round, the prior `State revision` (if any), the SHA256 of
the live handoff bytes it was based on (64 hexadecimal characters), and the target `State revision`; these
fields are the matching evidence for [source-matched recovery](#source-matched-recovery). The index only
links the record. Do not add a new section, a pending file or a template field.
A role without a change ID or without write permission for those outputs stays
with the response-only fallback.

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

## Source-matched recovery

Use this when the live `.ai/handoff.md` still routes to a superseded step, while a
newer transfer for the same batch is available in a named place: an index-linked
review record, or a result or response file whose path the live handoff (including
its Next output files) or the current task explicitly names. This is a targeted check of those named paths. It
does not scan directories, recurse into folders, or choose the newest file by
time or number.

A matching Next action, Next role and Review round is not evidence that a transfer
was applied: a transfer may change only the revision, the command or the required
inputs. Decide with the fingerprint and `State revision` correspondence below, in
this order.

Each candidate keeps its narration beside the container: source batch, source role,
source Agent, work producer Agent, verdict (or `none`), cumulative Review round,
prior `State revision`, prior live SHA256, and target `State revision`. This is
narration in the existing record, not a runtime field.

1. **Candidate.** Candidates are only:
   - records linked by the review index,
   - files whose path appears in backticks under the live handoff's
     `Authoritative Evidence` or `Next input files`, or in `.ai/current-task.md`, and
   - an implementation or fix result file, or a response file, that the live handoff's
     `Next output files` names by path (for example `.ai/handoff-recovery/round-01-result.md`).
     Other entries there, such as a review record, the index, `.ai/handoff.md`, source
     files, logs or configuration, are not candidates through this route.

   Each path is read once. Excluded: `.ai/current-task.md`, `.ai/handoff.md`,
   `tasks.md`, and any backticked path with a `#` anchor. A named path that does
   not exist is reported as missing and is not restored. A named file without a
   recovery container is not a candidate. A candidate whose source batch differs
   from the current task's Execution Batch ID is rejected and reported, and it
   never receives a write.
2. **Attribution.** Keep the originating role, Agent, verdict, cumulative Review
   round, scope and commands unchanged. Record the source role separately from
   the restoring role. A candidate missing any attribution item stops here and
   names the missing item.
3. **Protections first.** A candidate never overrides a closed live batch (it is
   not reopened) or a real wait (`blocked` or `awaiting-owner-decision`). A
   candidate whose cumulative Review round is 3 or more and that routes to
   another agent dispatch is protected unless its own complete handoff carries
   one valid, same-batch `review-budget-extension` line in the Task Owner
   decision field with `from <= N < through`, where N is that candidate's Review
   round (README.md#review-round-circuit-breaker). A missing, malformed,
   duplicate-key, unknown-key, cross-batch, below-`from` or at-`through`
   authorization grants no capacity. The live file's older authorization does
   not authorize a candidate that omits it. Each protected case keeps the live
   state and names the existing route: close, resume condition or Task Owner
   decision. A candidate protected by none of these continues to step 4.
   Human-decision and `close` candidates pass through the same protections; they
   have no Operator Command and are compared as described in step 4.
4. **Compare fingerprint and revision.** A new container must carry a real prior
   SHA256 (64 hexadecimal characters of the live bytes it was based on).
   - Live SHA256 equals the candidate's prior SHA256 and live `State revision`
     equals its prior revision: **pending**. The candidate is the unapplied
     transfer, even when Next action, Next role and Review round are unchanged.
   - Live `State revision` is above the target: **advanced**. A newer state
     exists; do not publish the candidate.
   - Live `State revision` equals the target: compare the **Routing section** and
     the **action section** named by the candidate's Next action, after
     line-ending normalization and trimming of blank lines at the section edges.
     Equal sections are **applied**. Any difference is **conflict**: keep the live
     state and name the differing section; never call it applied or overwrite it.
     Extract sections fence-aware, so a `##` line inside a fenced block is not a
     section boundary.

     | Candidate Next action | Action section compared after Routing |
     | --- | --- |
     | `dispatch` to an agent | `## Operator Command` |
     | `continue` | `## Current Status`, including any Continuation Command block; a prose difference, or a block present on one side only, is a difference |
     | `dispatch` to a human (`awaiting-owner-decision`) | `## Owner Decision Brief` |
     | `close` | `## Review Or Task State Impact` |

     Matching Next action, Next role and Review round alone never proves applied.
     Modification times and file names never decide applied or advanced.
   - Any other combination is a **conflict**: the live bytes differ from the
     recorded prior while the revision has not reached the target. Keep the valid
     live state and name the conflicting artifacts.
   - **Legacy compatibility.** Only a legacy index-linked review record or a legacy
     response handoff written before this rule may omit a real SHA256 and state that
     its fingerprint is unavailable. It is accepted only when it names the same batch,
     the same prior Review round and the routing that the live file still shows, and
     it states that the original handoff was not updated. Once the live revision
     already equals the target and the routing matches, the same Routing and
     action-section comparison above decides applied or conflict. A legacy record is
     still never forced across a byte change or a newline conversion.
   - **New containers.** Every named implementation or fix result, and every container
     written under this rule, must carry a real SHA256. Without one it is missing
     evidence (`missing-evidence:fingerprint`), is never treated as pending, and the
     legacy branch does not apply to it.
   - **Batch fail-closed.** Restore at most one pending transfer per batch, and only
     when every other same-batch candidate is advanced or applied. If two candidates
     are pending, or any same-batch candidate is conflict or missing evidence
     (including a transfer chained behind an unpublished predecessor, whose prior
     `State revision` is above the live revision), restore none, write nothing, and
     name each candidate with its reason. A candidate from another batch is rejected
     on its own and does not block.
5. **Authority.** Only a **pending** candidate may be written, and only by a
   restoring Agent permitted to write the handoff. Without that permission, keep
   the complete candidate as a response handoff and state that it was not
   persisted. Persisting copies the source decision; it is not a new verdict.
6. **Independence.** A restoring Agent that produced the work under review may
   publish a reviewer dispatch, but it must not execute that reviewer role. It
   presents the Operator Command for the correct recipient instead. Restoring
   never makes the restoring Agent the reviewer of its own work.
7. **Re-check and write.** Re-read the live bytes immediately before writing. A
   changed hash is a conflict, and nothing is overwritten. Write the candidate's
   complete handoff, read back the saved bytes and compare them with the
   candidate. A failed write is reported as not persisted. There is no atomic
   compare-and-swap.
8. **Then apply the existing gates.** Closed batches, real waits, the review
   allowance, role permissions and reviewer independence still decide the next
   step. After a successful read-back, run
   [expected state validation](#expected-state-validation) with the decided
   values from the candidate's route: batch, Next action, Next role, Review round
   and target `State revision`. Never take those values from the stale file.

Older records that lack the new narration are not backfilled. Closed batches and
exhausted review allowances are not reopened by a candidate.

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
- Mapping flat OpenSpec labels (for example bare `1` or section-only `1.`) when
  tasks.md only defines dotted items such as `1.1`.
- Putting validation or shell commands in `Authoritative Evidence` backticks
  instead of linking an existing result or log file.
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
- Turning a later-only environment notice into a current human reply request.
- Asking the owner to choose a local execution host within authorized offline work,
  or treating a runner's turn exit as an environment blocker.
- Obeying a stale Continuation Command over the latest wait, closure, review
  allowance, permission, or execution ownership; using continue for self-review.
- Reporting ordinary `accepted` closure without matching final-input validation
  evidence recorded outside the validated handoff (see
  [Accepted closure validation](#accepted-closure-validation)).
- Writing live routing into `.ai/current-task.md`.
- Restoring a named result without a real SHA256, or choosing a transfer from an unnamed file found by a directory scan.
- Closing with an unresolved assigned `should-fix`.
