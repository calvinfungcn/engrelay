# Multi-Agent Workflows

This document describes the standard role-based workflows for the workspace.

## Activation And Proportionality

These transitions apply only after selecting ai-collaboration for the current
task under README.md#optional-activation-and-coexistence. Inactive historical
state cannot trigger a dispatch. Package maintenance commands do not start a
business workflow, and another selected controller owns its own execution.

Choose specialist roles for named needs, not because the role table lists them.
Prefer one qualified aggregated review over serial reviews of the same evidence;
preserve actual independence and H verification. Continue adjacent local actions
with the same agent and persist state at actual transfer/wait/interruption/closure.
Cumulative Review round is the circuit-breaker authority. Local design-round
labels are display/context only; they cannot authorize more cumulative verdicts.

## Workflow Principles

- Work in coherent Execution Batches sized by behavior and risk.
- Assign one owner to each role action; reuse an existing agent session when
  independence does not require a fresh agent.
- Keep scope and next routing explicit in every handoff.
- Do not use chat history as the source of truth.
- Use `.ai/` for local handoff state.
- Use `docs/reviews/` for durable workspace-level review evidence.
- Keep OpenSpec execution state in `openspec/changes/<change-id>/tasks.md`.
- Use finding-specific or focused checks for local changes. Reuse broad
  regression evidence when its causal inputs are unchanged, and run broad
  regression once for the final candidate only when a relevant dependency,
  failure or unknown impact requires it. A role, handoff, prose, source
  inventory or bookkeeping change alone does not require every suite again.
- Allow at most one review -> fix -> verification loop per batch.
- Every role exit and transition table below is subject to
  README.md#review-round-circuit-breaker: count design/code/verification/
  adjudication verdicts cumulatively; at >=3 no Agent dispatch or local retry.
  Use supported closure or Task Owner decision. Explicit owner-limited
  acceptance uses Chief Designer, Acceptance basis: owner-decision and the
  scoped Task Owner decision; retain all unchecked mappings and known risks.
- Keep one responsible owner across adjacent non-independent steps. Use
  same-session `continue` at meaningful boundaries; do not require manual
  dispatch for every micro-step. Handoff is for an actual agent change,
  owner-decision wait, operational interruption, or batch closure.
- A batch is independently closable. Unfinished parent OpenSpec work remains
  pending and does not block acceptance of the mapped batch.

## Scope Authority

Chief Designer and Requirements Analyst disclose foreseeable adverse effects
before implementation/requirement confirmation, with concrete impact, evidence
or uncertainty, and a smaller/safer recommendation. Follow
[the disclosure rule](README.md#disclose-adverse-effects-before-proceeding);
use existing owner boundaries, not a new universal approval stage.

Apply the [Minimal Authority Rule](README.md#minimal-authority-rule) across
every step. OpenSpec and `.ai/current-task.md` define authorized product
scope; `.ai/handoff.md` carries routing, evidence, and recommendations but
does not silently enlarge that scope.

Task Intake and Chief Designer may challenge feasibility and recommend better
options. Local, reversible engineering details and ordinary safety/correctness
measures remain autonomous when they preserve accepted behavior and material
cost. Suggestions, assumptions, future flexibility, generic best practice,
deferred ideas, and rejected ideas stay non-authoritative until the applicable
evidence or owner decision exists. A material addition uses the existing Owner
Decision Brief; silence is not approval.

Design Review treats unauthorized scope or an unsupported claim of necessity as
`must-address`; Code Review treats implemented unauthorized scope or an
unsupported mandatory condition as `must-fix`. Reviewer-originated optional
suggestions outside the accepted batch remain non-blocking `should-consider`
or `nice-to-have` priorities and do not become current acceptance by being
written into a review or handoff. The existing `should-fix` priority remains
actionable only for an explicitly assigned issue within approved scope and
must still be assigned, deferred, or reclassified before closure.

When a new fact appears, solve a local reversible issue in-role. For a material
scope surprise or hard constraint, stop only the affected work, record
evidence, the smallest in-scope option, and the recommendation in existing
handoff sections, then route to Chief Designer; safe unaffected work may
continue.

## Role Exit Contract

Every role action ends with exactly one decision:

- `dispatch`: another role or human decision recipient must act. For agent
  dispatch, update `.ai/handoff.md` with complete Routing and a copy-ready
  Operator Command, and add the advisory capability tier line under
  `Current Status` per
  [handoff-schema.md#capability-tier-guidance](handoff-schema.md#capability-tier-guidance).
  For human decision dispatch (`Task Owner`, `User`, or
  `Data Owner`), set Current status to `awaiting-owner-decision`, set
  Recommended next agent and next files/prompt fields to `none`, strictly omit
  Operator Command and the capability tier line, and provide a complete
  plain-language Owner Decision Brief in `.ai/handoff.md` and chat; the current
  AI retains artifact and execution responsibility.
- `continue`: the same responsible agent continues, including adjacent
  non-independent duties. Record the active responsibility and next local step in
  `.ai/handoff.md`; omit Operator Command. When waiting for a same-session
  owner decision, set status `awaiting-owner-decision` and include the Owner
  Decision Brief.
- `close`: this batch route ends. Reconcile review and OpenSpec state in the
  same role action, update `.ai/handoff.md` with no next role, record a
  `Closure outcome: accepted|stopped|superseded`; Process Metrics is optional.
  Ordinary `accepted` closure also follows
  [handoff-schema.md#accepted-closure-validation](handoff-schema.md#accepted-closure-validation).

Read-only prohibits file writes unless named review or handoff outputs are
explicitly authorized. Response-only consultation preserves live business
state and reports findings in chat. For an actual handoff, if the task
explicitly prohibits `.ai/` writes, a higher-priority instruction prohibits
every file write, or tool permissions prevent the update, return complete
Routing in the final response and include the copy-ready Operator Command for
agent `dispatch`. State that `.ai/handoff.md` remains stale. Never finish a
review with findings and a verdict but no Next Action.
When strict read-only also prohibits review artifacts, report the complete
finding set in the final response and embed assigned finding IDs, evidence
locations, and required outcomes in the Operator Command. The command must not
depend on access to the reviewer conversation.

When business outcome, priority, scope change, production or real-user
approval, or explicit risk acceptance requires an owner decision, use
same-session `continue` when the current role and agent can reasonably receive
the small decision in the active exchange, or explicit human decision `dispatch`
targeting `Task Owner`, `User`, or `Data Owner` for an explicit asynchronous or
cross-person handoff. In both forms, use status `awaiting-owner-decision` and
present a complete plain-language Owner Decision Brief in chat and
`.ai/handoff.md`: the decision, one recommended option with its reason, viable
alternatives and consequences, the smallest exact reply needed (preferably as
inline code or quotes), and what the current AI will do next. Do not replace a
decision brief with a list of prerequisites or ask the recipient to prepare
workflow artifacts. Never leave an agent Next role without an Operator Command,
and never provide an Operator Command for a human decision dispatch.
After the answer, the operator re-invokes the same current role; that AI records
the decision and its effect under `Delta Since Last Handoff` before selecting the
next normal action.

An unavailable test or development environment is not automatically an owner
decision. Record it under `Blockers`, use `continue` with status `blocked`, and
include `- Resume condition: ...`. A blocked handoff cannot use `close`.
Apply [environment preparation before dispatch](README.md#environment-preparation-before-dispatch):
identify foreseeable human-only setup at intake/design, notify in handoff and
chat before dispatch, and keep the current responsible agent waiting when the
next action depends on it. Notify early but allow safe offline work if only a
later check needs it. Every dispatching role checks prerequisites for its next
assignment; operational setup does not require a return to Chief Designer.
For human action, use the short plain-language guidance in
[Actionable Human Instructions](handoff-schema.md#actionable-human-instructions).
Write the guidance in the handoff and chat: state the exact verified path or
screen, action, purpose, and smallest reply. For file/CLI actions include a
copy-ready verified snippet; for UI-only setup give the exact screen/action and
no invented code. Do not add a separate approval gate or diagnosis stage.

For a technical `REVISE`, Chief Designer materially revises the design and
uses `dispatch` to Design Reviewer only while the cumulative batch review
allowance has not been reached; a design counter may restart at round 1 for
readability, but it cannot reset the batch counter. For `STOP`, after
explicit, applicable Task Owner authorization, Chief Designer uses `close` with
`Closure outcome: stopped` and Next role `none`, records the technical reason in a
durable review or authoritative task source, leaves unmet OpenSpec items
incomplete, and states that acceptance did not complete. For `SPLIT`, after
explicit, applicable Task Owner authorization, Chief Designer uses `close` with
`Closure outcome: superseded` and Next role `none` for the superseded batch, records
the split reason and proposed coherent successor outcomes durably, leaves the
original mapped work incomplete, and requires separate Task Intake before a
successor batch starts.
Record `Task Owner decision` under `Review Or Task State Impact` with the scoped
human reply or stable evidence reference, owner, batch, and approved outcome.
Without that authorization, Chief Designer explains why, recommends one option,
offers viable alternatives and consequences, and waits using the existing
Owner Decision Brief and `awaiting-owner-decision`; it must not close. Existing
applicable authorization is reused without another approval request. Pausing
unsafe work, review limits, or environment waits do not authorize termination.

## Task Owner Progress Visibility

Use one completed coherent Execution Batch as the normal Task Owner progress
checkpoint. Do not create a checkpoint after every role action, file,
prerequisite, or implementation session. During Task Intake and design,
express `First demonstrable outcome` in owner-observable terms and name its
inspection method; keep detailed conditions in `Acceptance Criteria` and
exact automated or manual steps in `Required Checks`.

At completion, the closing role must reuse the existing handoff sections:
`Current Status` states the outcome available now; `Authoritative Evidence`
links demonstrations, responses, screenshots, reports, traces, dry runs, or
tests; `Known Risks` records deviations and risks; and `Review Or Task State
Impact` states satisfied acceptance/OpenSpec work and remaining mapped work.
The final response repeats this as a concise Task Owner progress summary.
This is informational by default and does not pause work or require approval.
Use `continue` with `awaiting-owner-decision` only for an existing Task Owner
Boundary decision. Non-visual work may use API behavior, reports, traces, dry
runs, focused tests, or exact inspection steps. Remaining work is reported;
later execution still starts with separate Task Intake.

## Evidence-Driven Iteration Within an Execution Batch

Use this guidance only when a critical unknown can be answered by bounded
evaluation inside the existing Execution Batch. Record the unknown in
`Goal` or `Acceptance Criteria`, the evaluation method in `Required Checks`,
and intentionally deferred non-required work in `Out Of Scope` or
`Constraints`; do not create a mode, lifecycle, field, or artifact.

When scope, acceptance, risk, and batch identity remain stable, the same
implementation or fix role may use `continue` for bounded local evaluation
steps. Keep the same role and agent responsible, record the next local step
and evidence in the existing handoff sections, and do not trigger a role
handoff or review for each iteration. Once the unknown is answered,
inconclusive, or causes scope, acceptance, or risk to change, follow normal
batch routing.

The complete coherent batch receives only its existing risk-required aggregated
review and at most the existing one fix/verification loop. The closing summary
must state whether the evidence supports the direction, rejects it, or cannot
yet resolve it, plus remaining uncertainty and deferred work. Evaluation-ready
evidence is not production-ready and cannot complete an OpenSpec item whose
acceptance remains unmet. Implementation and Fix Engineer may reuse one agent
session only when Code Reviewer independence and, for `H`, Verification
Reviewer independence remain intact.
Existing technical dispositions and `dispatch`, `continue`, and `close` retain
their current meanings; the evidence conclusion is plain language, not a new
status or recommendation.

## Optional Solution Exploration

Use `solution-exploration.md` only when repository/reuse inspection leaves at
least two materially plausible directions and the cost of a wrong choice
justifies bounded independent analysis. This is optional guidance inside one
Chief Designer-owned Execution Batch, not a new workflow or Development Mode.

The Chief Designer remains the sole formal owner. Supporting analyses are
contributor tasks, not roles. They read the authoritative requirement and only
the repository evidence needed for their assigned lens; they do not read other
alternatives, change `.ai` Action State, modify implementation, or edit another
output. The default is two contributors. A third is allowed only for a named
missing material lens; there is no default fourth challenger.

The Chief Designer records the baseline interpretation, creates unique
temporary paths under `.ai/explorations/<batch-id>/`, and uses `continue` while
collecting evidence. If another agent takes over synthesis, dispatch the same
formal Chief Designer role with a complete Operator Command. Shared-workspace
execution remains serialized unless the existing explicit parallel/worktree
rules apply. Temporary alternatives and synthesis are non-authoritative helpers
under the existing Runtime Artifact Budget: link them rather than copying them
into the handoff, and remove or archive them before the next batch. Contributor
prompts are bounded supporting instructions, not `.ai` routing actions; the
active handoff remains with Chief Designer while they run. Do not
create default `docs/requirements/` or `docs/explorations/` authorities.

Synthesis compares requirement and repository evidence rather than votes. It
must record the selected direction, deferred or rejected ideas, remaining
unknowns, risks, and First Demonstrable Outcome in the normal design handoff or
the authoritative OpenSpec artifact before implementation. Implementation reads
normal authoritative inputs and explicitly cited evidence; it does not read
rejected option files by default. OpenSpec remains authoritative, and Task
Owner decisions retain their existing boundary.

Unresolved empirical questions use the existing bounded-spike or
evidence-driven-iteration rules. Exploration does not add a role, action,
status, mode, runtime field, source of truth, or Design Review trigger. Stop
when one smallest justified direction is clear, the question needs a bounded
spike, or scope, acceptance, risk, or ownership changes; then use normal
Chief Designer routing and technical disposition contracts.

## Selected Compound Engineering Capabilities

The workspace adopts four Compound Engineering techniques through the
canonical project Skills described in `compound-engineering.md`. They remain
inside existing role actions:

```text
Implementation or Fix
  -> focused checks
  -> ce-simplify-code when a meaningful code diff warrants it
  -> existing risk-required review

Non-obvious defect
  -> ce-debug inside Implementation or Fix
  -> normal review and verification

Verified reusable learning
  -> ce-compound Learning Worthy Gate
  -> docs/solutions entry or no durable learning
```

Code Reviewer uses `ce-code-review` as its evidence-led review method. Existing
role work uses the targeted retrieval and conditional learning decision in
`compound-engineering.md#retrieve-and-reuse` and `#learning-worthy-gate`.
Any current closing role can capture eligible learning; no Documentation
Steward handoff is needed solely for that action. Formal
findings still use the workspace status and priority values and remain in the
existing review artifacts. A Skill invocation does not add a role action,
handoff, status, review round, or Process Metric count.

For cross-tool review or specialist work, Routing names the functional role
first and the recommended tool second. The receiving tool reads the same
OpenSpec, repository diff, evidence, and role contract. Do not copy the prior
agent's narrative as review authority, and do not repeat the same review across
every available model without a named independent lens.

Do not run `ce-brainstorm`, `ce-plan`, `ce-work`, or `lfg` as the controller of
an active OpenSpec change. Use the existing Design Reviewer for document review
of authoritative OpenSpec artifacts instead of creating a parallel CE plan.
See `compound-engineering.md` for deployment and the Learning Worthy Gate.

## Risk-Based Workflows

Classify every batch as `S`, `M`, or `H` during Task Intake.

Classify from the actual behavior and boundaries changed by this batch and
record the reason in `.ai/current-task.md`; do not inherit a parent proposal's
highest risk. Configuration and UI changes are not automatically low risk.

Mandatory design routing takes precedence over the risk-level shortcuts below.
If Task Intake suspects a complexity exception or no demonstrable first batch,
route to Chief Designer. If the Chief Designer confirms either condition,
Design Review is required before implementation.

### S - Low Risk

```text
Implementation Engineer -> closure
```

Independent review is optional. The implementer must still run applicable
checks and review the final diff.

A directly reported S-level defect may use the same fast path in the Fix
Engineer role without a formal review round: the user report is the input,
focused checks are required, and the Fix Engineer may close after
self-verification.

### M - Normal Risk

```text
Implementation Engineer
  -> Code Reviewer
  -> closure, when no assigned actionable finding remains
  -> Fix Engineer, when findings require fixes
  -> original Code Reviewer verifies and closes
```

The reviewer may close a clean batch in the same review round. A separate
Verification Reviewer is not required unless the batch risk is raised.
Stable-scope local issues found during implementation continue in the same role
with `continue`; they add no specialist reviewer or extra dispatch.

### H - High Risk

```text
Chief Designer or Architect, when design risk exists
  -> Implementation Engineer
  -> Code Reviewer
  -> closure, when independent evidence is sufficient and no assigned actionable finding remains
  -> Fix Engineer, when findings require fixes
  -> independent Verification Reviewer
  -> closure
```

Use `H` for authorization, security, money, data integrity, cross-system
contracts, migrations, and release gates. UI Designer and Test Engineer remain
conditional roles, not mandatory stops.

## Design-Heavy Workflow

Use this for cross-module, high-risk, or ambiguous work:

```text
Chief Designer
  -> Design Reviewer, when mandatory or recommended (max 2 rounds)
  -> Chief Designer, to confirm or revise after design review
  -> Architect, when architecture risk exists
  -> UI Designer, if UI is involved
  -> Test Engineer, when test strategy needs separate ownership
  -> Implementation Engineer
  -> Code Reviewer
  -> closure, if clean
  -> Fix Engineer, if findings require fixes
  -> independent Verification Reviewer
```

The Design Reviewer is optional unless a complexity exception exists or the
first batch cannot produce a demonstrable vertical result. In other cases, the
Chief Designer decides based on task complexity and risk. When review is
optional and skipped, work routes directly to Architect or Implementation
Engineer.

Design-heavy work is normally `H`, but design review still has a maximum of two
rounds before Chief Designer makes a technical disposition.

## Review-Only Workflow

Use this when implementation already exists and the next action is review:

```text
Code Reviewer
  -> closure, if clean
  -> Fix Engineer, if findings are open
  -> original Code Reviewer for `M`, or independent Verification Reviewer for `H`
```

For workspace-level review, the Code Reviewer must follow
`docs/reviews/README.md`.

## Fix-Only Workflow

Use this when a review round already exists and the task is to resolve findings:

```text
Fix Engineer
  -> original Code Reviewer for `M`, or independent Verification Reviewer for `H`
  -> closure or Chief Designer disposition
```

The Fix Engineer should read the latest review round and fix only `Must Fix`
items plus explicitly assigned `Should Fix` items.

For a directly reported S-level defect with no formal review round, the user
report is the assigned input. The Fix Engineer performs the focused fix and
checks, may use `close` with `Closure outcome: accepted` after self-verification,
and does not manufacture a review artifact.

## Step Contracts

### 1. Task Intake

Owner: Active agent

Inputs:

- OpenSpec change, issue, user request, or prior review round
- relevant module instructions
- known constraints

Outputs:

- `.ai/current-task.md`
- optional `.ai/role-roster.md`

Required decisions:

- task ID
- change ID, if any
- Execution Batch ID and one or more closely related mapped OpenSpec checklist
  items
- risk level `S`, `M`, or `H`, with a short reason
- user outcome and a small set of observable must-have acceptance criteria
- module scope and explicit out-of-scope work
- required checks
- first assigned role and recommended agent/tool
- whether the first executable action is available or crosses an owner
  approval, deployment, rollback, or external-environment boundary

The active agent drafts these decisions. A clear user request confirms only its
explicit outcome and scope; ask when an implicit expansion, business outcome,
priority, scope change, production or real-user approval, or explicit risk
acceptance requires it.

Task Intake may identify constraints and recommend a smaller outcome, but it
must not promote a suggestion or assumption into current acceptance, an
implementation prerequisite, or a review blocker. A material addition follows
the existing Owner Decision Brief path; otherwise keep the recommendation
non-authoritative in the existing scope or constraint text.

Task Intake must make the existing `First demonstrable outcome`, Acceptance
Criteria, and Required Checks understandable to the Task Owner: state the
observable behavior, how it can be inspected, and the exact evidence or steps
that will show it. This is planning visibility, not a new approval gate.

For an uncertainty-driven batch, Task Intake also identifies the critical
unknown in `Goal` or `Acceptance Criteria`, its evaluation method in `Required
Checks`, and deferred non-required work in `Out Of Scope` or `Constraints`.

Before routing directly to Implementation Engineer, Task Intake records an
evidence-backed reuse baseline, first demonstrable outcome, justified
complexity exceptions, and stop condition. When Chief Designer is next, these
fields are optional hypotheses to be confirmed in the design handoff; Task
Intake does not duplicate technical discovery.

Task Intake must reject a proposed batch whose outcome is only a file, class,
type, method, DTO, database field, endpoint, UI component, private foundation
type, or individual test. Keep those as implementation steps and combine the
related OpenSpec items until the batch delivers one observable, independently
testable behavior. A bounded spike is allowed only when it closes a named
critical unknown with an explicit evidence-based conclusion.

Do not split a batch merely because it is risk `H`. Split only at a distinct
observable behavior, material contract boundary, owner approval, deployment,
rollback, unrelated module behavior, independently releasable capability, or
when the work cannot fit reliably in one or two implementation sessions.

Do not dispatch Implementation Engineer when the first executable action is
blocked by an owner decision. Keep the active agent at Task Intake with
same-session `continue` or human decision `dispatch` (to `Task Owner`, `User`,
or `Data Owner`), status `awaiting-owner-decision`, and an Owner Decision
Brief. An unavailable external environment uses `continue` with status
`blocked`, a `Blockers` entry containing `- Resume condition: ...`, and no
Owner Decision Brief. For foreseeable human-only setup, include the conditional
`Environment Preparation` notice and present it in chat before dispatch; if only
a later check needs it, allow safe offline work and name the dependent step.
Split later execution from any subsequent acceptance or
deployment decision.

Role exit options:
- Agent `dispatch` to the recorded Initial role (Chief Designer, Implementation
  Engineer, Code Reviewer, or Requirements Analyst) with an Operator Command;
- Same-session owner wait via `continue` with `awaiting-owner-decision` and an
  Owner Decision Brief; or
- Human decision `dispatch` to `Task Owner`, `User`, or `Data Owner` with
  `awaiting-owner-decision` and an Owner Decision Brief (the human recipient does
  not have to equal the Initial role).

When none of those existing shortcuts safely summarizes a material ambiguity
in the business goal, actors, desired behavior, scope, acceptance, priority,
business rules, or user-experience intent, Task Intake may dispatch the
conditional Requirements Analyst as the Initial role. Clear requests and
sufficiently explicit OpenSpec work keep their existing routes; technical
ambiguity and design risk remain Chief Designer concerns.
Any model or tool suggestions in the non-normative reference guide are
optional; concrete role assignments remain replaceable in role-roster data.

#### Requirements Analyst (conditional role action)

Owner: Requirements Analyst

Use this existing role action only for the material business ambiguity
condition above. It does not add a lifecycle stage, a second requirements
authority, or a new action.

The analyst defines the problem space and performs an early requirement-quality challenge:
- coherence between goal, actors, desired behavior, and must-haves;
- user or business value and observable acceptance;
- contradictions, missing business rules, and unintended effects;
- data availability, data authority, and decision ownership;
- operational burden and obvious business infeasibility or disproportionality.
The analyst recommends requirement-level corrections, clarifications, priority
choices, or smaller business outcomes in plain language, and flags technical
claims as assumptions for Chief Designer. It must not choose architecture,
dependencies, services, repositories, DTOs, schemas, APIs, storage,
authentication, rollout, technical risk controls, solution exploration,
Execution Batch slicing, implementation, review, or technical disposition, and
must not declare implementation feasibility without evidence.

Ask two to five highest-value related questions at a time. Do not block on
low-impact or technical questions that Chief Designer can resolve. Already
answered or deferrable technical questions do not block confirmation. While
any owner input is needed, keep Requirements Analyst as the current role and use
same-session `continue` or explicit human decision `dispatch` (to `Task Owner`,
`User`, or `Data Owner`) with Current status `awaiting-owner-decision` and a
complete plain-language Owner Decision Brief. Decision recipients are routing
targets, not AI roles, and do not prepare workflow artifacts; the analyst
retains all artifact responsibility. Record evolving business
evidence in the optional local `.ai/requirement-baseline.md` working copy and
the existing handoff; do not write live routing into `.ai/current-task.md` or
rewrite the provisional intake scope. Inspect only limited current-behavior
evidence needed to clarify the problem; repository discovery must not become
technical solution design.

The baseline is the compact template at
`templates/requirement-baseline.template.md` with exactly these sections:
Requirement Maturity; Business Goal; Actors And Behavior (current and
desired); Must-Have Requirements And Acceptance Criteria; Business Rules And
Constraints; Non-Goals; Assumptions And Open Questions; and Task Owner
Decisions And Confirmation Summary. Its `draft` and `confirmed` labels are
requirement maturity only. The baseline is optional, local, temporary, and
linked rather than copied into handoff; active OpenSpec remains authoritative.
If a later OpenSpec change adopts this evidence, that OpenSpec artifact
supersedes or explicitly reconciles the baseline before downstream work relies
on it.
For normal delivery, keep the local baseline with the active batch until
closure.

The final confirmation uses the same owner-wait path (`continue` or human
decision `dispatch` with `awaiting-owner-decision` and Owner Decision Brief).
Present one concise summary of goal, must-haves, acceptance, non-goals, and
unresolved open questions in plain language and request the smallest exact
confirmation or correction. Only an explicit Task Owner reply changes the
baseline from `draft` to `confirmed`; record the decision and scope effect under
`Delta Since Last Handoff` before leaving the wait. The summary is the
context-compression boundary, so downstream roles do not read a full interview
transcript by default.
The existing Task Owner confirmation is the requirement-correctness gate for
the clarified business baseline; Design Reviewer remains responsible for
design review and no Requirement Reviewer is added.

Role exit options:
- Agent `dispatch` to Chief Designer only, with a complete Operator Command and
  the confirmed baseline linked as evidence;
- Same-session owner wait via `continue` with `awaiting-owner-decision` and an
  Owner Decision Brief; or
- Human decision `dispatch` to `Task Owner`, `User`, or `Data Owner` with
  `awaiting-owner-decision` and an Owner Decision Brief.
Requirements Analyst never dispatches an agent directly to contributors,
Architect, UI Designer, Test Engineer, Design Reviewer, Implementation
Engineer, Code Reviewer, or Fix Engineer.

An explicitly requirements-only batch may use `close` only when current-task
permits that exit and either an explicitly requested non-duplicate durable
artifact exists at a path named by current-task or the baseline, current-task,
and final handoff are archived together under
`.ai/archive/<current Execution Batch ID>/`. If active OpenSpec
conflicts or intended downstream design remain, dispatch Chief Designer
instead. Later design or delivery starts through separate Task Intake. If a
material business requirement changes after design or implementation starts,
the current role stops expansion, may dispatch Requirements Analyst for
reconfirmation, and Requirements Analyst returns only to Chief Designer;
Chief Designer owns technical rescope and disposition recommendations;
termination/replacement requires the explicit Task Owner decision in Role Exit
Contract.

### 2. Design

Owner: Chief Designer

Inputs:

- `.ai/current-task.md`
- OpenSpec artifacts, if any
- relevant module guides
- design review findings from `.ai/handoff.md`, if returning from Design Review
- confirmed Requirements Analyst baseline linked from `.ai/handoff.md`, when
  the conditional role was used

Outputs:

- design notes in `.ai/handoff.md`, or a committed design document when the
  task requires durable design history
- routing to Design Reviewer, Architect, UI Designer, Test Engineer, or
  Implementation Engineer

Required decisions:

- goal and non-goals
- user or operator flow
- acceptance criteria
- authority check: each material must-have is an explicitly accepted outcome,
  a verified existing constraint with evidence, or the smallest condition
  causally necessary for accepted behavior or an evidenced safety/correctness
  risk
- existing-code evidence and reusable capability
- Minimal Option: the smallest change that satisfies current acceptance
- complexity exceptions: each new service, dependency, data object, public
  API, authentication model, or reusable abstraction mapped to a current
  acceptance criterion or evidenced risk
- risks and assumptions
- foreseeable implementation/check prerequisites, human-only preparation,
  observed readiness, and, when human-only preparation is needed, an early notice under
  `Environment Preparation`; wait before a dependent assignment, but allow
  safe work that does not depend on the unavailable environment
- technical-feasibility challenge:
  - challenge whether the literal request is reasonable and capable of meeting its stated outcome;
  - map each must-have to a plausible end-to-end path using repository, system, data, integration, environment, or operational evidence;
  - distinguish confirmed evidence, assumptions, and critical unknowns;
  - identify infeasible or disproportionate requirements and recommend the smallest bounded outcome that still delivers useful behavior;
  - state why the Minimal Option can achieve acceptance, or what is required before implementation; and
  - record an explicit end-to-end feasibility decision in the design summary
- first demonstrable vertical slice, or a bounded spike that names the critical
  unknown it will close and requires an explicit, evidence-based conclusion
- stop conditions and suggested task grouping or slicing
- design review decision: whether Design Reviewer should review this proposal,
  with a brief reason based on complexity and risk

Pre-implementation feasibility outcomes use existing mechanisms only:
- proceed with the smallest evidenced design and normal Design Review rules;
- use a bounded spike only for a named critical unknown with an explicit evidence-based conclusion;
- request an owner decision via same-session `continue` or human decision `dispatch` (to `Task Owner`, `User`, or `Data Owner`) with an Owner Decision Brief;
- propose a smaller coherent design; or
- propose existing `STOP` or `SPLIT` when technical-disposition conditions apply;
  close only after the explicit, applicable Task Owner decision is recorded.
`REVISE` is not a pre-review feasibility outcome; it remains reserved for post-review revision.

The Chief Designer must phrase the first demonstrable vertical slice in
owner-observable terms, identify its inspection evidence or steps, and ensure
Acceptance Criteria and Required Checks cover the claimed result. This remains
an informational progress contract and does not add a Task Owner approval
step.

When the direction is uncertainty-driven, Chief Designer confirms that the
unknown is answerable by a bounded evaluation, keeps the batch coherent, and
does not turn local experiments or deferred hardening into technical
micro-batches.

When optional solution exploration is justified, Chief Designer remains the
owner: select two independent material lenses, name any missing lens before
adding a third, isolate temporary non-authoritative outputs under the existing
`.ai` artifact budget, and synthesize before normal design routing. Contributors
are supporting analysis tasks, not formal roles. Multiple contributors do not
themselves require Design Review.

When a confirmed Requirements Analyst baseline is present, Chief Designer
checks it against `.ai/current-task.md` and active OpenSpec before relying on
it, reconciles any confirmed requirement change into OpenSpec, and remains the
sole owner of technical decisions, batch sizing, and optional exploration.
Requirements Analyst does not choose a technical route or create contributor
prompts.

Design Review is required when the design contains a complexity exception or
the first batch cannot produce a demonstrable vertical result. Otherwise it
remains optional.

The Chief Designer must treat a file, class, type, method, DTO, database field,
API endpoint, UI component, private foundation type, or individual test as an
internal implementation step. Each proposed Execution Batch must state one
observable behavior and include all closely related technical work needed to
satisfy its acceptance criteria. Prefer one coherent batch over several
prerequisite-only micro-batches when the work shares the same contract and
validation evidence. A bounded spike is valid as a standalone batch only when
it names the critical unknown it will close and requires an explicit,
evidence-based conclusion.

### 2b. Design Review

Owner: Design Reviewer

Use this step when the Chief Designer recommends review for a complex or
high-risk proposal, or when a mandatory design trigger applies.

Inputs:

- `.ai/current-task.md`
- `.ai/handoff.md` with design notes and design review decision from Chief
  Designer
- OpenSpec artifacts, if any

Outputs:

- design review findings in `.ai/handoff.md`, classified by priority:
  - `must-address`: must be resolved before implementation can begin
  - `should-consider`: recommended but does not block implementation
  - `observation`: informational note, no action required

Required decisions:

- authority: confirm that mandatory scope and necessity claims satisfy the
  Minimal Authority Rule; unauthorized scope or unsupported necessity is
  `must-address`, while an optional reviewer improvement remains non-blocking
- necessity: is each added concept required by current acceptance or an
  evidenced risk?
- reuse: does the design use suitable existing project capability?
- proportionality: are the controls appropriate for the current outcome?
- early result: can the first batch demonstrate a vertical result or bounded
  spike conclusion?
- acceptance criteria alignment: do criteria match the stated goal?
- batch validity: does every proposed batch deliver an observable behavior, or
  is it only a technical prerequisite that should be combined with adjacent
  work?
- always check Chief Designer end-to-end feasibility evidence; treat a missing
  or unsupported feasibility decision as a must-address finding
- if Requirements Analyst was used, verify the material-business-ambiguity
  trigger, problem-space-only boundary, requirement-quality challenge, owner
  confirmation path, baseline authority, and single Chief Designer exit. If
  material business-quality ambiguity remains in design inputs, require it to be
  resolved without inserting Requirements Analyst for already-clear work.
- completeness, risk coverage, and feasibility, after the design passes the
  preceding checks

Unnecessary complexity is `must-address` with a recommendation to simplify,
defer, or remove it. A reviewer proposal that adds complexity carries the same
acceptance-or-evidence burden as the original design.

An unjustified micro-batch is `must-address`. Recommend the smallest coherent
combination that produces an independently testable outcome. Do not require a
file-, class-, type-, method-, DTO-, database-field-, API-endpoint-,
UI-component-, private-foundation-type-, or individual-test-level batch merely
to reduce review size. Split only at a distinct observable behavior, material
contract boundary, owner approval, deployment, rollback, unrelated module
behavior, independently releasable capability, or when the work cannot fit
reliably in one or two implementation sessions. A bounded spike is valid as a
standalone batch only when it names the critical unknown it will close and
requires an explicit, evidence-based conclusion.

Round tracking:

- Record `design-review-round: N` in `.ai/handoff.md`
- Default limit is 2 rounds
- After round 2, if `must-address` findings remain unresolved, route to Chief
  Designer only while the cumulative batch review ceiling permits it. In that
  role action, Chief Designer must materially `REVISE` and dispatch a new
  round-1 review, or propose `STOP` or `SPLIT` for the required Task Owner
  decision; a third review of an unchanged design is forbidden.

Next role:

- Chief Designer, if `must-address` findings exist and round limit is not
  reached
- Architect or Implementation Engineer, if approved or only observations remain
- Chief Designer for a technical recommendation and any required Task Owner decision, if `must-address` findings
  remain after round 2

### 3. Architecture Review

Owner: Architect

Inputs:

- `.ai/current-task.md`
- design notes
- relevant code structure and contracts
- OpenSpec specs, if any

Outputs:

- architecture findings and decisions in `.ai/handoff.md`
- for formal workspace review, a new `docs/reviews/<change-id>/...round-##.md`

Required decisions:

- module boundaries
- data flow
- API contracts
- compatibility and migration risks
- validation strategy

Next role:

- Chief Designer, if design changes are required
- Implementation Engineer, if approved
- current agent awaiting owner decision, if business outcome, priority, scope
  change, production or real-user approval, or explicit risk acceptance is
  required

### 4. UI Review

Owner: UI Designer

Use this step when UI screens, workflows, layout, visual hierarchy, or mobile
interaction states are involved.

Inputs:

- `.ai/current-task.md`
- design notes
- existing UI files
- module UI standard, such as `mis_app/docs/mobile_ui_design_standard.md`

Outputs:

- UI decisions and risks in `.ai/handoff.md`
- screenshots or verification notes when available

Required decisions:

- screen structure
- normal, loading, empty, error, and disabled states
- navigation and confirmation behavior
- accessibility and localization considerations
- consistency with module UI standards

### 5. Test Strategy

Owner: Test Engineer

Inputs:

- `.ai/current-task.md`
- design and architecture notes
- current tests

Outputs:

- test plan or coverage audit in `.ai/handoff.md`

Required decisions:

- which production code paths must be covered
- regression cases
- boundary cases
- validation commands
- risks from mocks, copied widgets, or test-only seams

### 6. Implementation

Owner: Implementation Engineer

Trigger: an assigned Execution Batch whose design route is complete, or a returned
batch after a Chief Designer decision. Local defects and checks stay in role with
`continue`; escalation follows the conditions below.

Inputs:

- `.ai/current-task.md`
- `.ai/handoff.md`
- latest review round, if implementing review fixes
- current git diff

Outputs:

- code and tests
- `.ai/round-XX-result.md` only when implementation or fix work changes code,
  tests, or runtime configuration; docs-only or handoff-only work may omit it
- updated `.ai/handoff.md`; include a copy-ready Operator Command only for
  `dispatch`

Required decisions:

- files changed
- checks run
- risks and limitations
- scope authority: do not silently add a suggestion, assumption, or future
  preference to OpenSpec, current-task acceptance, or implementation scope;
  route a material addition through the existing Chief Designer/Owner Decision
  path
- for the first implementation batch, whether a demonstrable result or bounded
  spike conclusion exists and whether approved scope or expected effort
  changed materially
- exact next routing

Before routing completion, Implementation Engineer must be able to state the
owner-observable outcome, how to inspect it, which acceptance/OpenSpec work is
satisfied, deviations or risks, and remaining mapped work using the existing
handoff sections. Include that concise summary in the final response as well.

If the batch is uncertainty-driven and scope, acceptance, risk, and identity
remain stable, Implementation Engineer may use `continue` for bounded local
evaluation iterations under the same role. Record the next local step and
evidence in the existing handoff; do not dispatch a reviewer until the
coherent batch boundary. An evaluation result must not be described as
production-ready or used to complete unmet OpenSpec acceptance.

If optional solution exploration was used, Implementation Engineer receives the
normal authoritative inputs and only explicitly cited supporting evidence; do
not read rejected option files by default. The final Chief Designer design
handoff or authoritative OpenSpec artifact remains the implementation basis.

If a material business requirement changes after design or implementation
starts, the current role stops expansion, records why the current scope cannot
continue unchanged in the existing handoff, and may dispatch Requirements
Analyst only to reconfirm that business change. Requirements Analyst uses the existing
owner-decision path when needed and then dispatches only Chief Designer;
Requirements Analyst does not choose technical disposition. Chief Designer
reconciles the confirmed evidence with current-task and active OpenSpec and
owns technical rescope and disposition recommendations; termination/replacement
requires the explicit Task Owner decision in Role Exit Contract.

Downstream roles use the Requirements Analyst confirmation summary and its
linked baseline as the context-compressed evidence boundary. They do not read a
full clarification transcript by default.

Any new or changed complexity exception discovered during implementation stops
the current work before that exception is implemented. Dispatch Chief Designer
to assess it. An unsupported exception must be simplified, removed, or deferred;
a confirmed exception requires Design Reviewer approval before implementation
resumes.

If an `M` batch discovers authorization, security, money, data integrity,
cross-system-contract, migration, release-gate, or equivalent blast-radius
work that requires `H`, stop before implementing that scope and dispatch Chief
Designer. Chief Designer must explicitly rescope the current task: confirm
`H` and its independent-verification requirement, reject the escalation with
evidence, or choose `SPLIT`. `H` alone does not force Design Review unless an
existing design trigger also applies.

Here, a complexity exception means a material architecture, external
dependency, data/public contract, authentication, ownership, or cross-feature
reuse boundary. Local helpers and private implementation details inside the
approved design do not trigger this stop.

Every role applies the same proportional-check rule. If a proposed check or
implementation is expected to consume substantial time, tokens or maintenance
for little added benefit, or to exceed the stated cost, the responsible role
first records an Owner Decision Brief with benefit, effort range and unknowns,
evidence, a smaller option and a recommendation. The role waits for one
explicit owner choice before adopting that expensive option and reuses an
applicable choice. Ordinary focused checks continue autonomously; necessary
expensive acceptance checks disclose the risk of skipping them. A filtered
check must have at least one actual matched case and preserve child exit,
diagnostic and elapsed evidence.

If the first batch invalidates a design assumption, cannot demonstrate the
planned result, or changes approved scope or expected effort materially, do not
automatically start the next batch. Recommend `GO`, `REVISE`, `STOP`, or
`SPLIT`; request a Task Owner decision only when its business boundary is
involved. Termination or replacement of the current batch crosses that boundary.

Before a dependent implementation/check step, verify the recorded environment
preparation. If unavailable, notify the Task Owner in handoff and chat using
`Environment Preparation`, keep responsibility with `continue` plus `blocked`
and a resume condition, and resume after checking readiness. Safe unaffected
work may proceed; an operational wait alone is not a Chief Designer handoff.

Next role:

- closure for risk `S` after required checks
- Code Reviewer for risk `M` or `H`
- current agent awaiting owner decision only when the blocker requires business
  outcome, priority, scope change, production or real-user approval, or
  explicit risk acceptance

The same responsible agent may continue into an adjacent non-independent role
or local step with `continue`; do not create a manual dispatch solely to move
from design to implementation or from implementation to a required local
check. Use `dispatch` when another agent must act or independence is required.

### 7. Formal Review

Owner: Code Reviewer

Inputs:

- `.ai/current-task.md`
- `.ai/handoff.md`
- current git diff
- `docs/reviews/README.md`
- the "Workspace Review System" section in `AGENTS.md`

Outputs for workspace-level review:

- `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md`
- updated `docs/reviews/<change-id>/index.md`

Outputs for local-only review:

- findings and verdict in the final response or `.ai/review-request.md`, as
  requested
- `.ai/handoff.md` as the required Action State

Required decisions:

- verdict or status
- all high-confidence actual defects in the current batch, reported together in one
  round with no fixed count cap; preferences and test-only style remain advisory
- evidence
- scope authority: judge implementation against authorized current-task/OpenSpec
  acceptance and evidenced necessary constraints; unauthorized scope or an
  unsupported mandatory condition is `must-fix`; optional improvements outside
  approved scope remain `nice-to-have`, and explicitly assigned in-scope
  `should-fix` work follows the existing disposition rule
- whether OpenSpec `tasks.md` should change
- next routing

Closure rules:

- If there are no `must-fix` findings and evidence is sufficient, close the
  batch in this review round, reconcile OpenSpec state, and record Next action
  `close` with `Closure outcome: accepted` when the current batch's mapped
  acceptance is complete. Remaining parent OpenSpec work stays pending.
- Route all assigned findings to one aggregated Fix Engineer round.
- Finding routing uses Next action `dispatch` and includes a copy-ready
  Operator Command.
- A clean review uses Next action `close` and states explicitly that no next
  role or Operator Command exists.
- Before closure, disposition every `should-fix`: assign it to the current fix
  batch, defer it with rationale and owner, or reclassify it as
  `nice-to-have`.
- Assign `should-fix` work only when it stays within the approved batch scope
  and expected implementation-session budget.
- Do not require a separate verification round only to restate a clean review.

When closing a clean batch, Code Reviewer verifies that the existing handoff
sections expose the outcome, inspection evidence or steps, acceptance/OpenSpec
coverage, deviations or risks, and remaining work. The final response gives
the same concise Task Owner progress summary; this is informational unless the
existing Task Owner Boundary requires a decision.

Review the complete coherent batch once, not each same-role evaluation
iteration. Treat evaluation evidence as evidence about direction; do not call
it production readiness or complete unmet OpenSpec work.
When the recorded batch baseline shows no production behavior file changed in
the staged or unstaged diff, and all suites selected for the batch are green,
mock strictness, assertion preference, test-only seams, and mutation-only
hypotheticals are advisory. Keep a test-only finding blocking only when it
demonstrates an accepted-behavior, security, data-integrity, regression, or
evidence-validity defect. Evidence-validity means a falsified result, a check
that does not exercise the claimed production path, or a concrete unmet
authorized behavior; a preferred mock edge or surviving theoretical mutant
alone is insufficient.
Record `Review round: N` monotonically for every review, verification, or
finding-adjudication verdict for the same batch and acceptance. Three is the
default autonomous allowance; role changes, `REVISE`, new finding IDs, and new
review files do not reset it. At the third verdict, close on evidenced
acceptance or use the existing Task Owner decision route for a material
limitation; an exhausted allowance without acceptance returns analysis plus an
owner recommendation under README.md#review-round-circuit-breaker, and only an
applicable finite owner authorization permits a further route. Do not start a
fourth review/fix cycle without one.

For an unrelated cross-batch finding, record a stable ID as `deferred` in the
durable review round and index, with evidence, rationale, and Task Intake
ownership. For local-only work, use the existing authoritative issue or
OpenSpec source; `.ai/` alone is not sufficient. A later Task Intake action
must cite and disposition the ID before creating its owning batch.

Important rule:

Do not record final workspace-level review results only in `.ai/`.

### 8. Fix Round

Owner: Fix Engineer

Inputs:

- `.ai/current-task.md`
- latest formal review round, or user defect report for a direct S-level repair
- current git diff

Outputs:

- scoped code and test fixes
- `.ai/handoff.md`
- `.ai/round-XX-result.md` only when code, tests, or runtime configuration changed

Required decisions:

- which findings were fixed
- which findings are disputed, with evidence
- checks run
- remaining risks
- next routing to the original Code Reviewer for `M`, or an independent
  Verification Reviewer for `H`
- for a direct S-level repair, accepted closure after focused checks and diff review

Fix all assigned findings together. Do not create one fix round per finding.

Fix Engineer may reuse the Implementation Engineer's concrete agent session for
adjacent fix work only when the Code Reviewer remains independent and, for `H`,
the Verification Reviewer remains independent. Fix iterations stay inside the
existing single fix/verification loop; use `continue` only for bounded local
steps under the same Fix Engineer role.

Fix Engineer must not turn a suggestion, assumption, or reviewer preference
into new mandatory scope. If a fix would materially change behavior, cost,
dependency, data meaning, deployment, or acceptance, record the evidence and
smallest option in existing handoff sections and route to Chief Designer.

If Fix Engineer disputes an assigned finding, record the evidence and dispatch
the original Code Reviewer for adjudication for both `M` and `H` only while
the cumulative allowance has not been reached. Adjudication
increments that count. If accepted with fresh evidence, the reviewer may mark
the topic `verified`; if rejected, it remains `open` within the same assigned
fix path. At an exhausted allowance without an applicable finite owner
authorization, use the Task Owner decision route rather than
dispatching another agent. Risk `H` fixes still require an independent
Verification Reviewer while the allowance permits that review.

### 9. Verification

Owner: Verification Reviewer

Inputs:

- `.ai/current-task.md`
- latest implementation result
- latest review round
- current git diff

Outputs for workspace-level review:

- new verification round under `docs/reviews/<change-id>/`
- updated review index

Required decisions:

- whether each topic is `open`, `fixed-not-verified`, `verified`, or `deferred`
- whether fresh evidence is sufficient
- whether OpenSpec `tasks.md` should change
- next routing

Verification scope:

- verify prior findings first
- judge only against authorized current-task/OpenSpec acceptance and evidenced
  necessary constraints; do not fail the batch because an unapproved
  suggestion or assumption was not implemented
- run finding-specific and directly affected tests
- reuse broad regression evidence produced after the latest relevant change
  when no relevant input changed
- treat only regressions caused by the fix as new blocking findings; route
  unrelated discoveries to a later batch
- close the batch and perform documentation reconciliation when verification
  succeeds; use `Closure outcome: accepted` only for this batch's mapped
  acceptance

On successful verification, Verification Reviewer records the owner-observable
outcome, inspection evidence, satisfied and remaining acceptance/OpenSpec work,
and deviations or risks through the existing handoff sections, then repeats a
concise summary in the final response. This does not create a later batch or a
new approval step.

Verification distinguishes evaluation evidence from production readiness and
OpenSpec completion. If acceptance remains unmet or direction remains
inconclusive, record that result and remaining work; do not mark the item
complete or treat evaluation evidence as production completion.

Successful verification closes only the current Execution Batch. Do not create
or dispatch a later OpenSpec batch from Verification; remaining checklist work
must begin with a separate Task Intake action.

If evidence verifies only a bounded slice but the mapped OpenSpec item still
contains unresolved acceptance criteria, route to Chief Designer for technical
reconciliation. Continuing with unchanged acceptance is a technical decision;
changing business scope/acceptance or proposing STOP/SPLIT uses the required
Task Owner decision route. Do not silently close the larger item or route a
mechanical documentation-only round.

If verification fails after the batch's normal single allowed fix loop and the
batch remains below the cumulative allowance, the current agent
routes the evidence to Chief Designer for technical `REVISE`, `STOP`, or
`SPLIT` instead of starting another automatic loop. At an exhausted allowance
without an applicable finite owner authorization, use only
evidenced acceptance or the existing Task Owner decision route; do not start
another review or send the same test-only disagreement to Chief Designer.

Important rule:

Do not mark a topic `verified` without fresh evidence in the current round.

### 10. Documentation Closure

Owner: Documentation Steward (optional)

Inputs:

- `.ai/current-task.md`
- latest handoff/result files
- latest review index and round
- OpenSpec task file

Outputs:

- updated OpenSpec `tasks.md`, if task state changed
- updated `.ai/handoff.md` with the final Next Action
- final notes for the Task Owner

Do not create a separate Documentation Steward role action when the Code
Reviewer or Verification Reviewer can reconcile the same files during closure.

Required decisions:

- whether the Execution Batch is complete
- whether follow-up work should become a new Execution Batch
- whether review status and task state are aligned

For an explicitly requirements-only batch, close only when current-task
permits that exit and either an explicitly requested non-duplicate durable
artifact exists at a path named by current-task or `.ai/requirement-baseline.md`,
current-task, and final handoff have been archived together under
`.ai/archive/<current Execution Batch ID>/`. Active OpenSpec conflicts or
intended downstream design require dispatch to Chief Designer instead; later
work begins through separate Task Intake.

If this optional role performs closure, Documentation Steward uses the same
existing handoff sections to make the completed outcome, inspection evidence,
acceptance/OpenSpec coverage, deviations or risks, and remaining work visible
to the Task Owner, and includes the concise summary in the final response.

For an uncertainty-driven batch, the closure summary must say whether evidence
supports, rejects, or cannot yet resolve the direction and must retain deferred
work and remaining uncertainty without creating a new lifecycle or batch.

## Routing Matrix

| Current step | Result | Next role |
| --- | --- | --- |
| Task Intake | scope unclear | Chief Designer |
| Task Intake | possible complexity exception or no demonstrable first batch | Chief Designer |
| Task Intake | `S` or `M`, scope clear and no mandatory design trigger | Implementation Engineer |
| Task Intake | `H`, design risk exists | Chief Designer or Architect |
| Task Intake | existing implementation needs review | Code Reviewer |
| Task Intake | material business ambiguity in goal, actors, desired behavior, scope, acceptance, priority, business rules, or user-experience intent that Task Intake cannot safely summarize | Requirements Analyst as Initial role |
| Task Intake | blocked by owner decision | same-session `continue` or human decision `dispatch` (`Task Owner`, `User`, `Data Owner`) awaiting owner decision |
| Task Intake | next assigned action requires unavailable human-prepared environment | notify Task Owner before dispatch; `continue` with `blocked`, `Environment Preparation`, and `Resume condition` |
| Requirements Analyst | owner clarification or confirmation needed | same-session `continue` or human decision `dispatch` (`Task Owner`, `User`, `Data Owner`) awaiting owner decision |
| Requirements Analyst | confirmed business baseline ready for design | Chief Designer via agent `dispatch` only |
| Design | complexity exception or no demonstrable first batch | Design Reviewer |
| Design | other complex or high-risk proposal | Design Reviewer when recommended |
| Design | architecture risk exists | Architect |
| Design | UI behavior involved | UI Designer |
| Design | testing risk exists | Test Engineer |
| Design | optional exploration justified | Chief Designer via `continue`; same formal role via `dispatch` if synthesis changes agent |
| Design | owner decision needed on feasibility trade-off | same-session `continue` or human decision `dispatch` (`Task Owner`, `User`, `Data Owner`) awaiting owner decision |
| Design | next assigned action requires unavailable human-prepared environment | notify Task Owner before dispatch; same responsible agent waits with `continue` plus `blocked` and resume condition |
| Design | approved and scoped | Implementation Engineer |
| Design Review | `must-address` findings exist, round ≤ 2 | Chief Designer |
| Design Review | approved or only observations | Architect or Implementation Engineer |
| Chief Designer disposition | `REVISE` | `dispatch` to Design Reviewer for round 1 |
| Chief Designer disposition | proposed `STOP`/`SPLIT`, no applicable Task Owner authorization | explain evidence, alternatives, recommendation; `continue` or human decision `dispatch` with `awaiting-owner-decision` and Owner Decision Brief |
| Chief Designer disposition | Task Owner authorized `STOP` | `close`; `Closure outcome: stopped`, `Task Owner decision`, Next role `none` |
| Chief Designer disposition | Task Owner authorized `SPLIT` | `close`; `Closure outcome: superseded`, `Task Owner decision`, Next role `none` |
| Architecture Review | design issue found | Chief Designer |
| Architecture Review | approved | Implementation Engineer |
| UI Review | UI issue found | Chief Designer or Implementation Engineer |
| UI Review | approved | Implementation Engineer |
| Test Strategy | coverage plan ready | Implementation Engineer |
| Implementation | new or changed complexity exception | Chief Designer; Design Reviewer if confirmed |
| Implementation | `M` discovers work requiring `H` | Chief Designer rescoping; stop before that scope |
| Implementation | `S` complete with evidence | closure with `Closure outcome: accepted` |
| Implementation | `M` or `H` complete | Code Reviewer |
| Implementation or Fix | bounded local evaluation with stable scope and acceptance | same role via `continue` |
| Implementation | blocker requires business outcome, priority, scope change, production/real-user approval, or risk acceptance | same-session `continue` or human decision `dispatch` (`Task Owner`, `User`, `Data Owner`) awaiting owner decision |
| Implementation or Fix | dependent step requires unavailable operational environment | notify Task Owner for human-only setup; same responsible agent waits with `continue` plus `blocked` and resume condition, without routine Chief Designer dispatch |
| Code Review | assigned `open` findings | Fix Engineer |
| Code Review | no unresolved assigned actionable finding and evidence sufficient | closure and OpenSpec reconciliation |
| Fix Round | `M` complete | original Code Reviewer verification |
| Fix Round | `H` complete | independent Verification Reviewer |
| Fix Round | assigned finding disputed | `dispatch` to original Code Reviewer within the existing loop |
| Verification | failed after normal fix loop and batch review round < 3 | Chief Designer technical disposition |
| Any review verdict | batch review round = 3 | close on evidenced mapped acceptance or Task Owner decision; no agent dispatch |
| Verification | verified | closure and OpenSpec reconciliation |
| Any step | business outcome, priority, scope change, production/real-user approval, or risk acceptance required | same-session `continue` or human decision `dispatch` (`Task Owner`, `User`, `Data Owner`) awaiting owner decision |

## Workspace Review Integration

Use `docs/reviews/` when the review is for:

- a root `openspec/changes/*` item
- cross-module behavior
- workspace-level process or architecture
- any review that should be durable and auditable

Do not append new review content to legacy review artifacts after a change has a
home under `docs/reviews/`.

## OpenSpec Task State

Review documents explain why a topic is open, fixed, deferred, or verified.
OpenSpec `tasks.md` records execution state.

When review status changes task state, record the review evidence first, then
update `tasks.md` separately.
