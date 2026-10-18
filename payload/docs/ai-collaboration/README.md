# Multi-Agent Collaboration Standard

EngRelay is the public package alias for ai-collaboration. Selecting EngRelay
explicitly selects the same workflow; role, field, and WorkflowMode semantics
remain unchanged.

## Optional Activation And Coexistence

Installation stores these contracts; it does not by itself select them for a task.
For package-managed deployments, the managed AGENTS WorkflowMode is optional
(new-install default), default, or disabled. Explicit task selection takes priority
over a project default. In optional mode, select ai-collaboration explicitly;
in disabled mode, first explicitly re-enable it. Existing .ai state, historical
references, role names and installed Skills do not imply selection.

When another workflow such as OpenCode + OmO owns the task, this role graph,
handoff fields, validator and package-adapted CE contracts are inactive.
Project requirements, module facts, security and independent quality constraints
still apply under the selected workflow. Do not interpret merely reading this
handbook or consulting about it as adoption. Multiple packages may be installed;
only one primary controller owns a particular task.

When switching active work, keep a concise completed/remaining/evidence summary.
Do not fabricate acceptance or remove old evidence; the selected workflow takes
responsibility for the remaining work. Package Install/CheckVersion/Upgrade/
SetMode/Uninstall do not create a business batch or require this role lifecycle.

When explicitly selected, the remainder of this handbook applies in full.
Small tasks may instead choose another workflow; no new parallel S lifecycle
or exemption from an active M/H independent-review requirement is introduced.
Use the package README for prompt version checking, protected upgrades and
project default selection; no network updater is added. Human-oriented guides
(operator flow, adoption, hosts) live in
[operator-guide.md](operator-guide.md) /
[operator-guide.zh-CN.md](operator-guide.zh-CN.md),
[project-adoption.md](project-adoption.md) /
[project-adoption.zh-CN.md](project-adoption.zh-CN.md), and
[host-capabilities.md](host-capabilities.md) /
[host-capabilities.zh-CN.md](host-capabilities.zh-CN.md); they index this
handbook rather than replacing role contracts.

This directory defines the workspace standard for handing work between multiple
AI coding agents without copying long chat transcripts.

The standard is role-based. A role defines a responsibility and an output
contract. A concrete AI tool or agent performs one role action; the same
session may perform adjacent actions when independence is not required.
Role lists are available responsibilities, not a mandatory session checklist.
Trigger specialist review only for a named material gap or independent boundary;
one aggregated review can cover architecture, UI and test concerns when qualified.
Preserve independent M review and required independent H verification.

## Goals

- Make each Execution Batch easy for the next agent to understand.
- Make the next agent for each step explicit.
- Keep temporary handoff state out of git.
- Keep formal review history durable and consistent with
  `docs/reviews/README.md`.
- Reduce scope drift by separating task definition, implementation, review,
  fixes, verification, and documentation.
- Keep collaboration overhead proportional to delivery risk.
- Review coherent behavior changes instead of routing every micro-step through
  a complete lifecycle.
- Apply selected Compound Engineering techniques without creating a competing
  planning or lifecycle authority.

## Storage Model

| Location | Purpose | Commit policy |
| --- | --- | --- |
| `docs/ai-collaboration/` | Reusable collaboration standard, workflows, prompts, and templates | Commit |
| `.ai/` | Local runtime handoff files between agents | Do not commit |
| `docs/reviews/<change-id>/` | Durable workspace-level review history | Commit |
| `openspec/changes/<change-id>/tasks.md` | Execution state for an OpenSpec change | Commit when task state changes |
| `docs/solutions/` | Verified, reusable, non-obvious engineering knowledge | Commit |

The `.ai/` directory is local working memory. It should answer "what should the
next agent do now?"

The `docs/reviews/` directory is durable review history. It should answer "what
was reviewed, what evidence was used, and what is the current status?"

## Required Runtime Files

For an active task, keep these local files under `.ai/`:

```text
.ai/current-task.md
.ai/handoff.md
```

Create `.ai/round-XX-result.md` only for an implementation/fix round that
changed code, tests or runtime configuration; do not create empty results for
intake, design, review, verification or documentation-only work. Keep evidence
in one authoritative artifact and link it from handoff.

Optional local files:

```text
.ai/role-roster.md
.ai/review-request.md
```

Use the committed templates from `docs/ai-collaboration/templates/` to create
these local runtime files.

For a strict read-only response fallback, use
`docs/ai-collaboration/templates/response-handoff.template.md` in the final
response without creating a local runtime file.

## Source Of Truth

| Question | Source of truth |
| --- | --- |
| What is the current execution batch? | `.ai/current-task.md` |
| What is the current action and who acts next? | `.ai/handoff.md` |
| What did the last implementation or fix round do? | `.ai/round-XX-result.md` |
| What is the durable review status? | `docs/reviews/<change-id>/index.md` |
| What evidence supports a review status? | `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` |
| Which OpenSpec tasks are complete or still open? | `openspec/changes/<change-id>/tasks.md` |
| What verified engineering knowledge can be reused? | `docs/solutions/` |

## Minimal Authority Rule

OpenSpec is the authority for product requirements and tasks;
`.ai/current-task.md` defines the current batch, and `.ai/handoff.md`
carries live routing and evidence. A material must-have may enter current scope
only when it is:

- an outcome or trade-off explicitly requested or approved by the Task Owner,
  User, or Data Owner;
- a verified existing system, data, security, legal, or external-contract
  constraint with evidence; or
- the smallest necessary engineering condition causally tied to accepted
  behavior or an evidenced safety/correctness risk.

AI should challenge feasibility, expose risks, recommend improvements, and
choose local reversible details that preserve accepted behavior and material
cost. Suggestions, assumptions, future flexibility, completeness, generic best
practice, deferred ideas, and rejected ideas remain non-authoritative; they
cannot become a current OpenSpec requirement or task, current-task acceptance,
handoff implementation scope, implementation prerequisite, or review failure
without the applicable evidence or owner decision. Optional labels such as
`USER`, `EXISTING`, and `REQUIRED` may clarify evidence, but no per-line
taxonomy is required.

A material addition that changes product behavior, a business restriction, data
meaning, an external dependency or account, deployment, an irreversible
operation, ongoing cost, or acceptance uses the existing Owner Decision Brief;
silence is not approval. Without such an addition, the Chief Designer records
one concise no-expansion sentence in an existing `Current Status` or
`Delta Since Last Handoff` entry and proceeds without an extra approval step.

### Disclose Adverse Effects Before Proceeding

Chief Designer and Requirements Analyst must tell the Task Owner about
foreseeable adverse effects before implementation or requirement confirmation,
even when the literal request asks for the problematic approach. Explain the
concrete impact (for example false blocking, extra operator work or maintenance
cost), evidence versus uncertainty, and recommend a smaller/safer option or
omitting a nonessential feature. Do not bury the warning in theory codes or
promise zero risk. Requirements Analyst flags business/operational effects and
technical assumptions; Chief Designer owns technical assessment and design.
Use the existing Owner Decision Brief only for a material owner trade-off;
minor reversible details need no new approval. Add no role, report or validator
gate. Do not knowingly ship a flaw merely because it was requested.

When a new fact appears, solve local reversible engineering issues in-role. For
a material scope surprise or unsupported necessity, stop only the affected
work, use existing `Blockers` to record evidence, the smallest in-scope
option, and a recommendation, then dispatch Chief Designer; safe unaffected
work may continue.

## Execution Batch

The default unit of delivery is an **Execution Batch**. A batch groups the
smallest set of related changes that produces one coherent, reviewable, and
testable outcome. It sits between an OpenSpec change and an agent round.

```text
OpenSpec change
  -> one or more Execution Batches
       -> implementation
       -> one aggregated review
       -> one fix/verification loop when required
```

A normal batch should:

- implement one observable user, operator, or system behavior, contract
  boundary, or vertical workflow
- map to one or more explicit, closely related OpenSpec checklist items or
  sub-items
- share the same primary fixtures, feature flag, and validation commands
- fit in one or two implementation sessions
- remain understandable in one focused diff review

An Execution Batch is independently closable. Unfinished work in the parent
OpenSpec change or proposal does not enter this batch or block its closure.
Later work starts through separate Task Intake and names its own mapped
acceptance.

A batch is invalid when its outcome can only be described as creating or
changing a file, class, type, method, DTO, database field, API endpoint, UI
component, private foundation type, or individual test. These are
implementation steps inside a batch, not collaboration units. The exception is
a bounded spike that closes a named critical unknown and produces an explicit
evidence-based conclusion.

Prefer combining adjacent OpenSpec items when they jointly deliver the same
observable behavior, change the same contract, and must be tested together.
Risk level changes review rigor; it does not justify making the batch smaller
than a coherent testable outcome. Classify risk from the behavior and
boundaries changed by this batch. Do not inherit the parent proposal's highest
risk merely because the batch belongs to that proposal; read the selected risk
from `.ai/current-task.md` and keep any handoff risk metadata consistent with
it.

Combine work when it changes the same contract and must be tested together.
Split only at a distinct observable behavior, material contract boundary,
owner approval, deployment, rollback, unrelated module behavior, independently
releasable capability, or when the work cannot fit reliably in one or two
implementation sessions.
Do not start an implementation batch whose first executable action is blocked
by a business decision. Keep it at Task Intake and use the owner-decision path.
An unavailable test or development environment is an operational blocker:
record it in `Blockers`, use `continue` with status `blocked`, and include
`- Resume condition: ...`. A blocked handoff cannot use `close`; the same
responsible agent or role resumes when the condition is met.

### Environment Preparation Before Dispatch

Task Intake and Chief Designer identify foreseeable prerequisites for the
assigned work and required checks from the applicable module guide and known
runtime constraints. Before any agent dispatch, the dispatching role checks
those prerequisites and performs a cheap read-only readiness probe when useful.
Do not claim an environment is ready without evidence or invent a human-only
step when the agent can perform an authorized preparation itself.

When human action is actually required, add the conditional
`Environment Preparation` section from [handoff-schema.md](handoff-schema.md#environment-preparation)
and repeat its plain-language notice in chat **before** dispatch. Name the
concrete action, why and when it is needed, how to confirm readiness, and work
that can proceed. For example: "Start WebForms debugging in Visual Studio and keep
IIS Express running. Page verification needs http://localhost:3000/ reachable; reply
'started' when ready and I will check reachability before page verification. Code
changes and offline tests may continue meanwhile."
Follow the module's runtime constraints; this example does not authorize an IIS
deployment or a different launch method.

If the next assigned action depends on a pending or unverified prerequisite,
keep the current responsible agent with `continue` plus `blocked`, a concrete
`Resume condition`, and the preparation notice. Do not dispatch an engineer
just to rediscover that blocker. Once notified, the same agent checks readiness
and resumes normal routing. If only a later check needs the environment, notify
early and dispatch safe offline work with that limit explicit; repeat the
readiness check before the dependent step. Do not omit an accepted check merely
to claim the work is unblocked or complete.

An engineer discovering an operational blocker uses the same in-role notice
and wait; it does not return to Chief Designer for routine environment setup.
Escalate only when the resolution changes scope, acceptance, dependency, cost,
or another existing Task Owner/design boundary. Pure preparation uses no Owner
Decision Brief; a real trade-off uses the existing owner-decision route.

Do not invent authoritative subtask state only in `.ai/`. If a large OpenSpec
task repeatedly needs named runtime slices such as `8.4a`, add those sub-items
to `tasks.md` before continuing.

### Actionable Human Instructions

When asking a human to act, use a short plain-language notice: where to act,
what to do, why, and the smallest reply or observable result needed to resume.
Name the exact verified file or working directory for a file/CLI action and
include a copy-ready JSON/YAML/CLI snippet when one is needed; a UI-only action
must name the exact screen and action and must not contain invented code.
State the purpose and the smallest reply or observable result. Prefer the
cheapest safe workaround before deeper diagnostics. Do not substitute theory
codes for instructions or invent a fix. Use existing Human action,
Confirmation and check, Blockers, or chat; do not create a new approval gate or
make a code block mandatory for a UI-only action.

### Batch Sizing Examples

Invalid collaboration batches:

- add a request DTO
- add one authority capture type
- add a database field
- wire one endpoint
- add tests for a helper

Valid collaboration batches:

- allow an employee to submit a contact number, validate and persist it, return
  it through the existing API, and cover the behavior with focused tests
- deliver a protected employee response only while authority remains stable,
  including capture, boundary checks, response integration, citations, and
  regression tests

The valid examples may contain all of the invalid examples as internal
implementation steps.

## Task Owner Progress Visibility

The normal Task Owner progress checkpoint is a completed coherent Execution
Batch, not every role action, file, prerequisite, or implementation session.
Task Intake and design must express the existing `First demonstrable outcome`
as an owner-observable behavior and name how it can be inspected. Keep the
detailed observable conditions in `Acceptance Criteria` and the exact
automated or manual inspection steps in `Required Checks`.

At batch completion, the closing role reuses the existing handoff sections for
a concise owner-facing summary:

- `Current Status` states the observable outcome available now.
- `Authoritative Evidence` links the inspection evidence: demonstrations,
  responses, screenshots, reports, traces, dry runs, or focused tests.
- `Known Risks` records deviations, limitations, or remaining risks.
- `Review Or Task State Impact` states which acceptance criteria and OpenSpec
  items are satisfied and what mapped work remains.

The closing role presents the same concise summary in its final response. This
reporting is informational by default: it does not pause work, require a new
approval, or create a role, action, artifact, or routing state. Use the
existing `continue` plus `awaiting-owner-decision` path only when the Task
Owner Boundary requires a business outcome, priority, scope, production,
real-user, user-experience direction, or explicit risk decision.

Evidence may be visual or non-visual. Valid inspection includes a UI
demonstration, API response, report, trace, dry run, focused test output, or
an exact reproducible inspection step. A completion report may identify
remaining OpenSpec work, but a later batch still begins through separate Task
Intake; the closing role does not create or dispatch it.

## Requirements Analyst (conditional role)

Requirements Analyst is a conditional role action inside the existing
Execution Batch, not a new intake stage or lifecycle. Task Intake uses it only
when material business ambiguity remains in the goal, actors, desired
behavior, scope, acceptance, priority, business rules, or user-experience
intent and cannot be safely summarized. Clear requests and sufficiently
explicit OpenSpec work keep their existing shortcuts; technical ambiguity,
complexity, and design risk remain Chief Designer concerns.
Any model or tool suggestions in the non-normative reference guide are
optional; this role contract is tool-agnostic and concrete assignments remain
replaceable in role-roster data.

The role defines the problem space only: current and desired behavior, actors,
must-haves, observable acceptance, business rules, constraints, non-goals,
assumptions, open questions, and Task Owner decisions. When this conditional
action runs, it also performs an early requirement-quality challenge: assessing
coherence between goal, actors, desired behavior, and must-haves; verifying
user or business value and observable acceptance; identifying contradictions,
missing business rules, and unintended effects; checking data availability,
data authority, and decision ownership; and assessing operational burden and
obvious business infeasibility or disproportionality. The analyst may recommend
requirement-level corrections, clarifications, priority choices, or smaller
business outcomes in plain language, and may flag technical claims as
assumptions for Chief Designer. It does not choose architecture, dependencies,
services, repositories, DTOs, schemas, APIs, storage, authentication, rollout,
technical risk controls, batch slicing, solution exploration, implementation,
review, or technical disposition, and must not declare implementation
feasibility without evidence. Ask two to five highest-value related questions
at a time; do not block on low-impact or technical questions that Chief Designer
can resolve. Already answered or deferrable technical questions do not block
confirmation.

Use the existing owner dialogue path for each clarification and the final
confirmation: same-session `continue` or explicit human decision `dispatch`
(targeting `Task Owner`, `User`, or `Data Owner`), current status
`awaiting-owner-decision`, and a complete Owner Decision Brief while
Requirements Analyst remains current. Decision recipients are routing targets,
not AI roles, and do not prepare workflow artifacts; the current AI retains
responsibility for all runtime and baseline files. Only an explicit owner reply
changes the optional baseline maturity from `draft` to `confirmed`; these
labels exist inside the baseline only, not as routing or review statuses. The
confirmation summary (goal, must-haves, acceptance, non-goals, and unresolved
open questions) is the context-compression boundary; downstream roles do not
read a full interview transcript by default. The existing Task Owner
confirmation is the requirement-correctness gate for this dialogue; Design
Reviewer remains responsible for design review, and no Requirement Reviewer is
added.

The optional local working copy is
`.ai/requirement-baseline.md`, created from
`templates/requirement-baseline.template.md`. It is temporary, linked rather
than copied into handoff, and non-authoritative whenever an active OpenSpec
change exists; for normal delivery it remains with the active batch until
closure. If a later OpenSpec change adopts this evidence, that OpenSpec
artifact supersedes or explicitly reconciles the baseline before downstream
work relies on it. Chief Designer independently reconciles confirmed evidence
with current-task and OpenSpec before design or implementation relies on it.
After confirmation, the normal route is one `dispatch` to Chief Designer with
the baseline linked as evidence. Requirements Analyst never dispatches
directly to another role. An explicitly requirements-only batch may `close`
only when current-task permits it and either an explicitly requested,
non-duplicate durable artifact exists at a path named by current-task or the
baseline, current-task, and final handoff are archived together under
`.ai/archive/<current Execution Batch ID>/`.
Otherwise it dispatches Chief Designer; later work starts through separate Task
Intake. A material business requirement change after design or implementation
may return to Requirements Analyst for reconfirmation, then returns to Chief
Designer, who owns technical rescope and disposition recommendations; termination
or replacement requires the explicit Task Owner decision defined below.

## Evidence-Driven Iteration Within an Execution Batch

When a direction has a critical unknown that can be answered by a bounded
evaluation, use evidence-driven iteration as conditional guidance inside the
existing Execution Batch. It is not a Development Mode or a second workflow.
Record the unknown in the existing `Goal` or `Acceptance Criteria`, the
evaluation method in `Required Checks`, and intentionally deferred non-required
work in `Out Of Scope` or `Constraints`.

While scope, acceptance criteria, risk, and the batch identity remain stable,
the same implementation or fix role may perform bounded local evaluation steps
with `continue`. Keep the same role and agent responsible, record the next
local step and evidence in the existing handoff sections, and do not trigger a
role handoff or review for each local iteration. Stop local iteration when the
unknown is answered, evidence is inconclusive, or scope, acceptance, or risk
changes; the coherent batch then follows its normal routing.

The complete batch receives only its existing risk-required aggregated review
and at most the existing one fix/verification loop. At closure, state in the
existing handoff sections whether evidence supports the current direction,
rejects it, or cannot yet resolve it, along with remaining uncertainty and
deferred work. Evaluation evidence is not production readiness and cannot
complete an OpenSpec item whose acceptance criteria remain unmet; production
and OpenSpec completion retain their existing gates and authority.
This guidance does not alter the meanings of existing technical dispositions or
`dispatch`, `continue`, and `close`, and adds no competing status or
recommendation vocabulary.

Implementation Engineer and Fix Engineer may reuse the same concrete agent
session for adjacent actions only when the independent Code Reviewer remains
independent and, for `H`, the Verification Reviewer remains independent from
both implementation and fixes. Session reuse does not merge role contracts or
change review and safety requirements.

## Optional Solution Exploration

`solution-exploration.md` describes an optional comparison procedure for one
Chief Designer-owned Execution Batch. Use it only when repository/reuse
inspection leaves at least two materially plausible directions and the cost of
choosing incorrectly justifies independent analysis. Ordinary design does not
fan out by default.

The Chief Designer is the sole formal owner. Supporting analyses are bounded
tasks, not roles: they read the authoritative requirement and necessary
repository evidence, do not read other alternatives, do not change `.ai`
Action State or implementation, and write only their assigned temporary output.
Use two contributors by default; allow a third only for a named missing
material lens, never a default fourth. Keep alternatives and synthesis at a
unique temporary path declared in the current task and treat them as
non-authoritative helpers under the existing Runtime Artifact Budget; link
rather than copy them, and remove or archive them before the next batch only
when no durable record references them. Do not create default
`docs/requirements/` or `docs/explorations/` authorities.

The owning Chief Designer uses existing `continue` while collecting evidence;
if another agent takes over synthesis, dispatch the same formal Chief Designer
role with a complete Operator Command. Synthesis informs the normal design
handoff or authoritative OpenSpec artifact but never authorizes implementation.
Implementation reads normal authoritative inputs and explicitly cited evidence,
not rejected option files by default. Unresolved empirical questions use the
existing bounded-spike or evidence-driven-iteration guidance, and exploration
does not change S/M/H review, Design Review triggers, Task Owner boundaries, or
the lifecycle limit. See [solution-exploration.md](solution-exploration.md).

## Risk Levels

| Level | Typical work | Required lifecycle |
| --- | --- | --- |
| `S` | Documentation, mechanical edits, low-risk local configuration, visual-only changes | Implement and self-verify; independent review is optional |
| `M` | Normal features, local APIs, shared behavior, non-trivial bugs | Implement, then one independent review; fix and verify only actionable findings |
| `H` | Authorization, security, money, data integrity, cross-system contracts, migration, release gates | Design or architecture review as needed, implementation, independent review, and independent verification after fixes |

When the impact is genuinely uncertain, choose the higher level and record the
reason in `.ai/current-task.md`. Configuration and UI changes are not
automatically low risk. A directly reported S-level defect may be implemented
and self-verified by the Fix Engineer even when no formal review round exists;
the user report and focused checks are the review input in that fast path.
For `H` work, Implementation Engineer and Fix Engineer must not also serve as
the Verification Reviewer for the same batch.

If `M` implementation discovers authorization, security, money, data
integrity, cross-system-contract, migration, release-gate, or equivalent
blast-radius work that requires `H`, it stops before implementing that scope
and dispatches Chief Designer. Chief Designer must explicitly rescope the
current task: confirm `H` and its independent-verification requirement, reject
the escalation with evidence, or choose `SPLIT`. `H` alone does not require
Design Review unless an existing design trigger also applies.

Stable-scope local defects, failing checks and local design details are handled
by the same role with `continue`. They are not an escalation and do not add a
specialist reviewer; only the material conditions above route to Chief Designer.

## Lifecycle Limits

### Review Round Circuit Breaker

`Review round: N` is a cumulative, monotonic count for every design review,
code review, verification, and finding-adjudication verdict for the same
Execution Batch and acceptance. Three is the default autonomous allowance. A
role change, `REVISE`, new finding ID, new review file, or successor wording
cannot reset the count. The normal path remains one aggregated review -> fix
-> verification loop. At the third verdict, the only exits are
evidence-supported `accepted` for the mapped acceptance, the existing Task
Owner decision route for a material limitation (including the
exhausted-capacity analysis and finite-extension recommendation below), or a
route covered by an applicable finite owner authorization. No agent may
dispatch another agent or begin a fourth review/fix cycle without one. Unmet
parent OpenSpec items remain pending and
must not be reported as verified.
If the Task Owner explicitly accepts a bounded mapped outcome despite known
unmet technical criteria, only Chief Designer may close it as `accepted` with
`Acceptance basis: owner-decision` and the scoped `Task Owner decision`.
Keep every original mapping, disclose unchecked or deferred work, and state
that owner acceptance is not technical verification, Git merge authorization,
or deployment authorization.

- A clean `M` or `H` review may close the batch without a separate
  Verification Reviewer round.
- A reviewer must report all high-confidence actual findings for the batch in one
  aggregated round, with no fixed numeric cap; the upstream three-finding limit
  is not adopted. Advisory preferences stay non-blocking.
- Before dispatching a verdict, state the cumulative count and the verdict it
  will become when that affects routing. For example, after two design verdicts
  the code verdict is round 3: it may record defects, but no autonomous fix or
  verification follows, so unresolved acceptance uses the existing owner-decision
  route.
- A Fix Engineer handles all assigned `must-fix` findings and selected
  `should-fix` findings together.
- Reuse the original reviewer session for verification when practical. For
  `H` work, the verifier remains independent from the implementation/fix role.
- Allow bounded same-role evaluation iterations with `continue` only while
  the batch scope, acceptance, risk, and identity remain stable; keep the
  normal review boundary and the cumulative review limit below unchanged.
- The normal path remains one aggregated review -> fix -> verification loop.
  Record monotonic `Review round: N` for every review, verification, or finding
  adjudication verdict for the same batch and acceptance. Three is the default
  autonomous allowance; a new role, `REVISE`, finding ID, or review file
  cannot reset or evade the count.
- Before the third verdict, a failed fix may still be routed to Chief Designer
  for one evidence-based technical disposition. At the third verdict, close
  only on evidenced mapped acceptance or use the existing Task Owner decision
  route for a material limitation. No autonomous fourth review, fix, or Chief
  Designer re-litigation is permitted without an applicable finite owner
  authorization.
- An exhausted default allowance produces analysis, not termination. When
  acceptance is still unmet, the responsible agent keeps the batch open with
  `continue`/`awaiting-owner-decision`, explains the remaining defects, impact,
  evidence, and why prior repair did not converge (or what is still unknown),
  recommends the smallest repair-and-independent-review plan with reasons,
  offers viable alternatives with consequences, and states the exact reply
  needed to resume. The agent never stops or replaces the batch merely because
  the count is exhausted, never asks the owner to edit workflow files, and
  never starts an unauthorized additional cycle. Unsafe steps may still pause
  separately with a resume path.
- A finite owner authorization permits scoped same-batch continuation without
  resetting the count. It is recorded as one structured line in the existing
  `Task Owner decision` field under `Review Or Task State Impact` (never a new
  Routing field):

```text
- Task Owner decision: review-budget-extension; owner=<identity>; date=<YYYY-MM-DD>; batch=<exact batch>; from=<completed N>; through=<absolute C>; scope=<bounded repair/review scope>; evidence=<stable reference or current-session quote>
```

  Fields split on `;` (owner identity may contain spaces); the structured
  line comes first and later prose in the same field adds no keys. Every
  structural key is unique and every value is non-empty; `from`/`through` are
  non-negative integers with `through` greater than `from`; the current
  completed count must lie within `from` and the absolute ceiling `through`,
  and only a count below `through` may take another route. A missing ceiling,
  unlimited or non-integer/overflowing bound, duplicate key, unknown key,
  cross-batch value, below-`from` count, or at-`through` count grants nothing.
  An ordinary prose decision stays readable and grants no capacity, and a
  structurally valid line still authenticates no owner, history, or
  independence: the responsible role checks actual authority, scope, count,
  and reviewer independence. When the finite allowance is exhausted again
  without acceptance, the agent updates the analysis and recommendation; there
  is no automatic renewal, rename, or reset.
- The agent that verifies a batch may also perform documentation closure; do
  not create a Documentation Steward round only to copy status between files.

## Technical Disposition Exit Contracts

When a role is routed to Chief Designer for a technical disposition, it must
select exactly one of these exits:

- `REVISE`: materially revise the design and use `dispatch` to Design Reviewer.
  This is allowed only while the cumulative ceiling has not been reached. The
  revised design may use its design-review counter for readability, but that
  counter does not reset the batch counter; unchanged wording or evidence
  cannot reset either counter.
- `STOP`: after explicit, applicable Task Owner authorization, use `close` with
  `Closure outcome: stopped` and Next role `none`. Record the technical reason
  in the durable review or authoritative task source, leave unmet OpenSpec items
  incomplete, and state that the batch ended without acceptance completion.
- `SPLIT`: after explicit, applicable Task Owner authorization, use `close` with
  `Closure outcome: superseded` and Next role `none` for the superseded batch.
  Record the split reason and proposed coherent successor outcomes durably, leave the
  original mapped work incomplete, and require a separate Task Intake action
  before any successor batch starts.

After Design Review round 2 returns unresolved `must-address` findings, Design
Reviewer dispatches Chief Designer only while the cumulative review ceiling
permits it. Chief Designer must select a technical direction in that role
action; a third review of an unchanged design is forbidden. This design-review
limit does not reset the Execution Batch's cumulative review ceiling. A
proposed STOP/SPLIT without owner authorization
waits through the existing owner-decision route instead of closing or
restarting an automatic review loop.

Technical authority permits recommending termination or replacement of the
current batch; the Task Owner authorizes that outcome. Before `stopped` or
`superseded`, explain the evidence and impact, recommend one option, and offer viable alternatives
with their consequences. Use `continue` or human decision `dispatch` with
`awaiting-owner-decision` and the existing Owner Decision Brief until the Task
Owner explicitly chooses. Record the scoped reply or a stable evidence reference
as `Task Owner decision` under `Review Or Task State Impact`, identifying the
owner, batch, and approved outcome. An explicit cancellation or still-applicable
prior authorization suffices; do not ask again. Silence, exhausted review/token
budgets, unavailable environments, and another agent's recommendation are not
authorization. Unsafe or infeasible steps may pause immediately while the batch
remains open awaiting preparation or a decision. Accepted closure and reversible
local implementation choices do not gain a new approval gate.

When Fix Engineer disputes an assigned finding, it records the evidence and
dispatches the original Code Reviewer for adjudication for both `M` and `H`
only while the cumulative allowance has not been reached.
Adjudication stays inside the existing aggregated fix/verification path and
increments the same cumulative verdict count; it cannot reset the count. If accepted with fresh evidence, the reviewer may
mark the topic `verified`; if rejected, it remains `open` within the same
assigned fix path while the allowance permits another action. At an exhausted
allowance without an applicable finite owner authorization, use the Task Owner
decision route rather than dispatching another agent. Risk
`H` fixes still require an
independent Verification Reviewer afterward.

### Test-Only Fast Convergence Gate

When the recorded batch baseline shows no production behavior file changed in
the staged or unstaged diff, and all suites selected for the batch are green,
a finding about mock strictness, assertion style, test-only seams, or a
mutation-only hypothetical is advisory. It cannot block mapped acceptance or
trigger a Chief Designer escalation. It remains blocking only when the
reviewer demonstrates a concrete accepted-behavior, security, data-integrity,
regression, or evidence-validity defect. Evidence-validity means a falsified
result, a check that does not exercise the claimed production path, or a
concrete unmet authorized behavior; a preferred mock edge or surviving
theoretical mutant alone is insufficient. The reviewer must state the changed
production path or concrete failure before assigning such a finding.

## Evidence Reuse

Fresh evidence means evidence produced after the latest relevant change. It
does not mean every role must rerun every unchanged command.

- Implementation runs focused tests and the batch's broad regression once.
- Review primarily inspects requirements and the diff, running focused checks
  only when needed.
- Verification reruns finding-specific and directly affected checks.
- Broad regression is rerun after a fix only when its inputs or blast radius
  changed; otherwise reuse the still-fresh recorded result.
- Blast radius means callers, consumers, shared contracts, configuration paths,
  or persisted state whose behavior can be affected by the fix.
- Full release suites remain mandatory at the applicable milestone or release
  gate.

Record each command and result in one authoritative artifact. For durable
review evidence, record the repository, base/diff or content hash, command,
and environment. Link to it from handoff files instead of copying the same
evidence into multiple files. Keep paths referenced by durable records stable;
do not move a referenced result merely to reduce the local `.ai/` file count.

## Selected Compound Engineering Capabilities

Use [compound-engineering.md](compound-engineering.md) for the selected
capability set and cross-tool deployment contract. The adopted capabilities
are `ce-code-review`, `ce-simplify-code`, `ce-debug`, and `ce-compound`.

Use the contract's targeted retrieval before non-obvious work and conditional
learning decision after verification. Cite actual reuse in existing result or
closing prose; learning capture adds no role, mandatory file, or closure gate.

They execute inside the existing Code Reviewer, Implementation Engineer, Fix
Engineer, or closing role action. They do not add a role, stage, action,
status, review loop, or runtime field. OpenSpec remains the sole planning
authority for an active change, so `ce-brainstorm`, `ce-plan`, `ce-work`, and
`lfg` are not default lifecycle controllers.

Install the canonical project Skills into supported local tool directories
with:

```powershell
powershell -ExecutionPolicy Bypass -File `
  docs/ai-collaboration/scripts/install-compound-skills.ps1 -Target all `
  -DisableOverlappingLifecycleSkills
```

Use `-Check` to detect missing or edited generated copies. Cross-tool review
still uses functional roles and the normal Routing contract; the tool name is
replaceable roster data, not a role definition.

## Runtime Artifact Budget

- The workspace-root `.ai/` directory supports one active Execution Batch.
  Serialize batches that share it; use separate worktrees only when parallel
  execution is explicitly requested.
- Keep `.ai/current-task.md` stable for the full batch. It contains the initial
  assignment, not live routing.
- Update `.ai/handoff.md` at an actual routing boundary: agent handoff,
  owner-decision wait, operational interruption, or batch closure. Same-owner
  local steps may use `continue` without a manual dispatch for every micro-step;
  record a materially changed next step or evidence when it matters. Keep the
  file focused on current state, deltas, risks, and routing.
- Create `.ai/round-XX-result.md` only for implementation or fix rounds that
  changed code, tests, or runtime configuration. Gaps are expected because
  review and verification rounds do not create result files.
- Store formal review and verification evidence only in `docs/reviews/`; do
  not duplicate full finding tables in `.ai/`.
- Do not move or rename an evidence file that is referenced by a durable review
  or closure record. Keep stable paths for referenced results; unreferenced
  temporary helpers may be archived or removed only after their durable
  evidence is confirmed. This avoids breaking historical links.
- Read only the role-specific workflow section plus current task context. The
  full collaboration handbook is reference material, not mandatory repeated
  preflight for every role.

### Token Efficiency Guardrails

- **Anchored role-specific reading**: In Required Reading, specify anchored sections
  (for example, `docs/ai-collaboration/workflows.md#6-implementation`) rather than
  unanchored collaboration handbook paths. The full handbooks are reference material,
  not repeated preflight reading.
- **Reference-not-copy evidence handling**: Link authoritative evidence files,
  review rounds, reports, and code locations rather than copying full finding tables,
  diff outputs, or terminal logs into `.ai/current-task.md` or `.ai/handoff.md`.
- **Concise Operator Commands**: Keep the agent `dispatch` Operator Command focused
  on the 5-part skeleton (Role/Batch, Read, Objective, Constraints, Output, Follow).
  Do not paste entire role contracts, handbooks, or evidence into the command.
- **Existing fast paths and continuity**: Use risk-proportional workflows (risk `S`
  direct close after self-verification; risk `M`/`H` aggregated review at coherent
  batch boundary). Use same-role `continue` for bounded local steps and in-session
  decisions without unnecessary role dispatches.
- **Advisory context budgets**: Conservative size thresholds (for example, ~12 KiB
  for `.ai/current-task.md` and ~8 KiB for `.ai/handoff.md`) serve as advisory
  context-growth guardrails. They prompt operators to check for excessive duplication
  or missing evidence links, but they are never blocking quality gates and must never
  override required quality, verification, or review rules.

## Routing Contract

Every role action must end with exactly one **Next Action**:

| Action | Meaning | Required output |
| --- | --- | --- |
| `dispatch` | Another role or human decision recipient must act | For agent dispatch: update `.ai/handoff.md` with complete Routing and a copy-ready Operator Command. For human decision dispatch (`Task Owner`, `User`, `Data Owner`): set status `awaiting-owner-decision`, next agent/files/prompt `none`, omit Operator Command, and provide a complete plain-language Owner Decision Brief in `.ai/handoff.md` and chat |
| `continue` | The same responsible agent continues without operator dispatch | Record the active responsibility and next local step at meaningful boundaries; omit Operator Command. Adjacent non-independent duties can stay in this session. For owner decisions, use `awaiting-owner-decision` and Owner Decision Brief |
| `close` | This batch route ends and no role remains | Reconcile review/OpenSpec state, update `.ai/handoff.md` with no next role, record the closure outcome (`accepted`, `stopped`, or `superseded`) ; metrics are optional |

`dispatch` has two strictly discriminated forms:

1. **Agent dispatch** routes work to another standard AI role. It requires a
   non-`none` recommended agent, non-empty next input/output files, a prompt
   template anchor matching the next role, and a copy-ready Operator Command.
   Status `awaiting-owner-decision` is forbidden for agent dispatch.
2. **Human decision dispatch** routes one named business, data-authority,
   approval, scope, priority, experience, production, real-user, or risk
   decision to exactly `Task Owner`, `User`, or `Data Owner`. It requires
   Current status `awaiting-owner-decision`, sets Recommended next agent and
   next input/output/prompt fields to single-line `none`, strictly forbids
   `## Operator Command`, and requires a complete `## Owner Decision Brief`.

Use same-session `continue` when the same owner and agent can reasonably
receive a small decision or adjacent non-independent step in the active
exchange. Use human decision `dispatch`
for an explicit asynchronous or cross-person decision handoff. In both forms,
the current AI role and agent retain complete responsibility for all workflow
artifacts (`.ai`, OpenSpec, review evidence, synthesis), present the
plain-language brief, and resume execution after the answer. Decision
recipients are routing targets, not Standard Agent Roles, and are never asked to
read repository files or produce workflow artifacts.

Use `continue` for a bounded local evaluation step when the same role and agent
remain responsible and the batch scope, acceptance, risk, and identity are
unchanged. This is not a review or a new batch; record the next local step and
its evidence in the existing handoff sections.

For agent `dispatch`, the Operator Command is an operator-facing, copy-ready
prompt. It must identify the next role and batch, list authoritative inputs,
state the specific objective and constraints, name required outputs, and link
the role contract. Keep it concise; do not copy the entire role contract or
evidence.

Agent `dispatch` also adds one advisory line under `Current Status`:
`Recommended capability tier: C1` through `C5`, using the fixed next-role
defaults and existing-task overrides in
[handoff-schema.md#capability-tier-guidance](handoff-schema.md#capability-tier-guidance).
Briefly echo the same tier in the final response. Omit the line for human
decision dispatch, `continue`, and `close`. The tier is a manual model-selection
hint only; it is not a machine field, qualification gate, or blocker.

Read-only means no file writes unless the assignment explicitly authorizes
named review or handoff outputs. Response-only consultation preserves the live
business batch state and reports findings in chat. For an actual role handoff,
any generated prompt that
prohibits `.ai/handoff.md` or every file write must require the response
handoff fallback: state complete Routing and, for `dispatch`, include the
copy-ready Operator Command in the final response. The response must also say
that `.ai/handoff.md` remains stale and must be persisted before relying on it.
When review artifacts are also forbidden, keep the complete findings in the
final response and embed every assigned finding's ID, evidence location, and
required outcome in the Operator Command so it remains self-contained after
being copied to another agent.

Every handoff must state:

- the Next Action
- the current role
- the current agent/tool
- the current status

For manual handoff, Routing may also include `Execution Batch ID` and a
positive-integer `State revision`. The batch ID and optional risk must match
`.ai/current-task.md`. Compare revisions manually against the latest handoff;
the validator checks only revision syntax, not freshness or atomic locking.

When `Next action` is `close`, `Review Or Task State Impact` must contain this
exact field:

```text
- Closure outcome: `accepted|stopped|superseded`
```

`accepted` applies only to the mapped tasks and acceptance criteria of the
current batch. Unfinished parent OpenSpec work remains pending and does not
block an accepted batch. A `blocked` handoff must use `continue` and include
`- Resume condition: ...` under `Blockers`; `blocked` cannot be closed.
Chief Designer records `stopped` or `superseded` for termination or replacement;
both require the explicit Task Owner decision described in
[Technical Disposition Exit Contracts](#technical-disposition-exit-contracts),
recorded as `Task Owner decision` under `Review Or Task State Impact`.
Neither means acceptance succeeded. Legacy close records missing the outcome
remain readable with a warning; add it when next updated, not by rewriting history.

An agent `dispatch` handoff must additionally state:

- the next role
- the recommended next agent/tool
- the files the next agent must read
- the files the next agent must create or update
- the prompt template the next agent should use
- a copy-ready Operator Command

A human decision `dispatch` handoff must instead state:

- the next role (`Task Owner`, `User`, or `Data Owner`)
- `Recommended next agent: none`
- `Next input files: none`
- `Next output files: none`
- `Next prompt template: none`
- a complete `## Owner Decision Brief` (and no Operator Command)

Every final role response must state the selected Next Action. For agent
`dispatch`, it must confirm where the Operator Command was written and
reproduce the command when the response fallback applied. For human decision
`dispatch`, it must present the Owner Decision Brief. For `close`, it must state
explicitly that no next role or Operator Command exists.

### Stop, Resume And Late Messages

- Choose exactly one Next Action at each real boundary. An unavailable
  environment uses `continue` with status `blocked` and a `Resume condition`; a
  blocked batch is never closed.
- Record the last valid progress, remaining mapped work, evidence links and the
  resume condition in the existing `Current Status`, `Delta Since Last Handoff`,
  `Authoritative Evidence` and `Blockers` sections. No state field, database or
  scheduler is added.
- A pending human decision keeps the batch open with `awaiting-owner-decision`.
  Pausing unsafe work is not termination and does not authorize `stopped`.
- A delayed or duplicate message is checked against the latest handoff (batch ID,
  `State revision`, recorded verdict count and evidence) before any action. If the
  batch has already advanced, do not repeat dispatch or reopen a closed batch
  because of the old notice. New evidence carried by the message is still
  evaluated, and a necessary repair is routed through the normal path.

## Task Owner Boundary

The active agent prepares batches, maintains `.ai/` files, reconciles evidence,
and recommends the next action. Before design, it summarizes the user outcome,
must-have acceptance criteria, and out-of-scope work. A clear user request
confirms only its explicitly stated outcome and scope; it does not authorize
implicit expansion, production or real-user action, or risk acceptance. The
human Task Owner, User, or Data Owner decides only business outcome, priority,
scope changes (including termination or replacement of the current batch),
production or real-user approval, and explicit risk acceptance.
The decision recipient never writes workflow artifacts, and the current AI
retains all artifact responsibility. Risk level alone does not create an owner
decision step.

Every communication across this boundary must use ordinary language, define
unavoidable specialist terms on first use, present one decision at a time, and
omit internal workflow jargon.

## Lean Design and Feasibility Rule

The Chief Designer starts with existing-code evidence and the smallest option
that meets the current acceptance criteria. Every new service, dependency,
data object, public API, authentication model, or reusable abstraction must map
to a current criterion or evidenced risk.

Inside each Design action, the Chief Designer performs an explicit
technical-feasibility challenge:
- challenge whether the literal request is reasonable and capable of meeting its
  stated outcome;
- map each must-have to a plausible end-to-end path using repository, system,
  data, integration, environment, or operational evidence;
- distinguish confirmed evidence, assumptions, and critical unknowns;
- identify infeasible or disproportionate requirements and recommend the
  smallest bounded outcome that still delivers useful behavior;
- state why the Minimal Option can achieve acceptance, or why further action is
  required before implementation; and
- record an explicit end-to-end feasibility decision in the design summary.

Pre-implementation feasibility outcomes use existing mechanisms only: proceed
with the smallest evidenced design; use a bounded spike for a named critical
unknown; request an owner decision via `continue` or human decision `dispatch`
(to `Task Owner`, `User`, or `Data Owner`); propose a smaller coherent design;
or propose `STOP` or `SPLIT` subject to the Task Owner authorization above.
`REVISE` is not a pre-review feasibility outcome; it
remains reserved for post-review revision.

The Design Reviewer checks necessity, reuse, proportionality, and an early
demonstrable result before completeness. The reviewer always checks Chief
Designer end-to-end feasibility evidence (missing or unsupported is a finding),
and checks Requirements Analyst quality challenge only when that role actually
ran or when material business-quality ambiguity remains in design inputs.
Design findings that block are limited to executable barriers: unsupported
necessity, invalid references or starting points, internal contradictions, or a
check that cannot be executed. A preference for other local wording or an
implementation detail is advisory and needs no extra role.
Implementation must stop for any new or changed complexity exception and route
it through Chief Designer. A confirmed exception requires Design Review before
implementation continues.

A complexity exception is a new or materially changed architecture, external
dependency, data or public contract, authentication boundary, ownership
boundary, or cross-feature reuse boundary. A local helper, private type, test
fixture, or implementation detail within the approved design is not an
exception.

### Proportional checks and owner choice

Assign checks to the behavior and inputs they can affect. Reuse a recorded
broad result only when the relevant code, configuration, deployment layout and
test inputs are unchanged and record that causal limit. Run broad regression
once for the final candidate only when an affected dependency, failure or
unknown impact makes it necessary; changing a role, handoff, prose, source
inventory or bookkeeping alone never requires every suite again. Existing
focused filters may be used, but a selected check must report a real match,
child exit code, diagnostics and elapsed time. A zero-match selection is
unverified.

Before adopting a one-time task that is expected to require substantial
time, tokens or maintenance for little added benefit, or that materially
exceeds the stated cost, the current role must use the existing Owner Decision
Brief. Explain the benefit, effort range and unknowns, evidence, smaller
option and recommendation. Wait for one explicit owner choice for the
expensive option; silence or a role change is not approval. Ordinary small
local checks continue without approval, and a necessary expensive acceptance
check must disclose its risk before the owner chooses whether to run it.
Reuse an applicable recorded choice without asking again. This is a cost
decision inside the existing lifecycle, not a new status, field, timeout or
approval stage.

## Standard Agent Roles

| Role | Responsibility |
| --- | --- |
| Chief Designer | Produces the smallest evidence-backed design that meets current acceptance criteria |
| Requirements Analyst | Clarifies material business ambiguity without making technical or routing decisions |
| Design Reviewer | Challenges necessity and reuse before completeness; required on lean-design triggers, otherwise optional |
| Architect | Reviews system boundaries, data flow, contracts, compatibility, and migration risk |
| UI Designer | Reviews user flow, screen states, interaction, and UI standards |
| Implementation Engineer | Writes code, tests, local validation, and implementation handoff |
| Test Engineer | Defines or audits test strategy and production-linked coverage |
| Code Reviewer | Performs formal review and records findings |
| Fix Engineer | Resolves review findings with minimal scoped changes |
| Verification Reviewer | Re-reviews fixes and closes topics only with fresh evidence |
| Documentation Steward | Keeps task, handoff, review, and OpenSpec state aligned |

The role names are stable. The agent/tool assigned to a role can change per
task or per round.

## Status Values

Formal workspace review status must use only the values from
`docs/reviews/README.md`:

```text
open
fixed-not-verified
verified
deferred
```

Local handoff files may use operational statuses such as `ready-for-review`,
`ready-for-fix`, or `blocked`, but they must not replace the formal review
status in `docs/reviews/<change-id>/index.md`.

## Review Priority

Review status and review priority are different.

| Field | Purpose | Allowed values |
| --- | --- | --- |
| Status | Whether the topic is currently closed or still needs evidence | `open`, `fixed-not-verified`, `verified`, `deferred` |
| Priority | How the next role should treat the finding | `must-fix`, `should-fix`, `nice-to-have` |

Fix Engineers should address `must-fix` findings and explicitly assigned
`should-fix` findings. They should not handle `nice-to-have` findings unless
they are explicitly included in the current batch.

A reviewer must disposition every `should-fix` before closure: assign it to the
current Fix Engineer batch, mark it `deferred` with rationale and owner, or
reclassify it as `nice-to-have`. A batch cannot close with an unresolved,
assigned actionable finding. Assign a `should-fix` only when it remains inside
the approved batch scope and expected implementation-session budget; otherwise
defer it or create a later batch.

An unrelated cross-batch finding must be recorded with a stable ID as
`deferred` in the durable review round and index, including evidence, rationale,
and Task Intake ownership. For local-only work, record it in the existing
authoritative issue or OpenSpec source; `.ai/` alone is not durable tracking. A
later Task Intake action must cite and disposition the ID before creating its
owning batch.

## Quick Start

1. Have the active agent select risk level `S`, `M`, or `H` and define one Execution Batch in
   `.ai/current-task.md`.
2. Map the batch to explicit OpenSpec checklist items or sub-items.
3. Ask the assigned role to use only its section in `agent-prompts.md` plus
   the batch-specific required reading.
4. Require the agent to update `.ai/handoff.md` with `dispatch`, `continue`, or
   `close`. For agent `dispatch`, require a copy-ready Operator Command; for
   human decision `dispatch`, require an Owner Decision Brief and omit the
   command.
5. For a required workspace-level review, create one aggregated
   `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` file and an updated
   `docs/reviews/<change-id>/index.md`.
6. Close a clean batch in the review round, or run at most one aggregated
   fix/verification loop. Record the monotonic `Review round: N`; no batch may
   exceed three cumulative review, verification, or finding-adjudication
   verdicts without an applicable finite owner authorization under
   #review-round-circuit-breaker.
7. Before every role stops, run:
   `powershell -ExecutionPolicy Bypass -File docs/ai-collaboration/scripts/validate-runtime-state.ps1`.

## Entry Skills

Three short entry Skills let an operator start or resume a task with one name and a
business goal or change ID. They only select an operation that already exists here:

- `ai-collab-requirements`: a requirements dialogue (conditional Requirements Analyst);
  only an explicit owner confirmation hands a summary to Chief Designer.
- `ai-collab-start`: a clearly stated goal, prepared through Task Intake and routed by
  risk without a forced requirements stage.
- `ai-collab-continue`: resumes the latest authorized handoff; it follows only the
  recorded Next action, never self-reviews, and never resets the review count.

Short prompts (the Skill must be named, so the entry is explicitly selected):

- Requirements: `Use ai-collab-requirements: I want an order export feature; clarify the requirement first.`
  Then, after the draft is reviewed: `Use ai-collab-requirements: confirmed, hand this requirement to the Chief Designer.`
- Start: `Use ai-collab-start: add install steps to the README, risk S.`
- Continue: `Use ai-collab-continue: continue`

Each one exists as `docs/ai-collaboration/skills/<name>/SKILL.md`. Discovery does not
select the workflow; the explicit request and the project's WorkflowMode do. If a host
has no discovery copy, read the canonical file directly. Host loading remains unverified
until a real host session confirms it.

## Process Metrics

When actual measurements are available and useful, optionally record:

- routing-boundary actions (dispatch, continue at a meaningful boundary, and
  close), target `<= 3` for `S/M` and `<= 5` for `H`
- review/fix/verification loops, target `<= 1`
- broad regression executions, target `<= 1` unless relevant inputs changed
- elapsed time and token usage
- escaped defects found after batch closure

Process Metrics is optional on every action. Record only available facts when
useful or explicitly requested; omit the section or unavailable fields rather
than fill a five-field form with unknown values. Do not reconstruct history or
add a ledger merely to collect these statistics. Historical unknown values
remain readable. Supplied integer counts retain validation and exceeded-target
advisories, but metrics never determine acceptance or authorize extra loops.
Partial sampling cannot establish a cross-batch efficiency trend. Escaped
defects may be assessed retrospectively when actual evidence is available.

During use, investigate any observed increase in escaped defects or reopened
findings. Unknown future trend data is not an extra closure gate; current
acceptance, verification and risk-required review remain mandatory.

An escaped defect found after `close` starts a new Execution Batch and, when
formal review applies, a new review round. Do not rewrite the closed handoff or
historical review artifact.

## Related Documents

- `docs/ai-collaboration/compound-engineering.md` - selected Compound
  Engineering capabilities, authority boundaries, and cross-tool deployment
- `docs/ai-collaboration/host-capabilities.md` - nine supported SkillTargets,
  canonical reading path, and what file presence does not prove
- `docs/ai-collaboration/project-adoption.md` - bounded adoption routes,
  upgrade and recovery boundaries, and verification limits
- `docs/ai-collaboration/scripts/doctor.ps1` - read-only installation and
  host-view diagnosis; never writes or repairs
- `docs/ai-collaboration/scripts/find-solutions.ps1` - read-only literal search of
  `docs/solutions/` entries with match reasons; never writes, indexes or applies a hit
- `docs/openspec-handoff-compound-engineering-workflow-v2.md` - non-normative
  historical memo; `docs/ai-collaboration/` and
  `docs/ai-collaboration/compound-engineering.md` are operationally
  authoritative. Do not implement its `.ai/review-notes.md`, P0-P3, v2 finding
  statuses, or `CODING_STANDARDS.md` suggestions.
- `docs/ai-collaboration/solution-exploration.md` - optional bounded solution
  exploration under one Chief Designer-owned Execution Batch
- `docs/solutions/README.md` - admission and storage rules for reusable,
  verified engineering knowledge
- `docs/ai-collaboration/templates/requirement-baseline.template.md` - compact
  optional Requirements Analyst working baseline
- `docs/handoff.md` - deprecated predecessor; do not use it for current runtime
  routing
- `docs/reviews/README.md` - mandatory workspace review handbook
- `AGENTS.md` - workspace agent guide
- `openspec/project.md` - workspace OpenSpec context

## Examples

- `docs/ai-collaboration/examples/mobile-points-expiry-reminder.md` - concise
  `S`, `M`, and `H` action-state examples
- `docs/ai-collaboration/examples/mobile-points-expiry-reminder-zh.md` - Chinese
  version of the concise examples

## EngRelay License

Original EngRelay material uses the following MIT License. Applicable third-party
notices, including those embedded in the CE Skills, remain in force. Preserve this
notice with redistributed copies of the installed kit.

MIT License

Copyright (c) 2026 calvinfungcn and EngRelay contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

