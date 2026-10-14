# Optional Solution Exploration

This is a bounded convenience procedure inside one existing Execution Batch.
It helps a Chief Designer compare materially plausible directions when choosing
incorrectly would cost more than two short independent analyses. It is optional;
ordinary design does not require it.

## Contract

- The active `.ai/current-task.md` defines the batch and `.ai/handoff.md`
  remains the only live Action State. The Chief Designer remains the sole
  formal owner.
- Supporting analyses are bounded contributor tasks, not formal roles. They do
  not change Action State, implementation files, another contributor's output,
  or Task Owner responsibilities.
- Use the existing `dispatch`, `continue`, and `close` actions. Multiple
  contributors do not create a new status, mode, lifecycle, review trigger, or
  source of truth.
- Default to two independent contributors. Add a third only for a named
  missing material lens; never add a default fourth challenger.
- Exploration evidence is non-authoritative. The Chief Designer must restate
  selected decisions in the normal design handoff or the applicable
  authoritative OpenSpec artifact before implementation.

## Trigger and stop conditions

Start only when all of the following hold:

1. Repository and reuse inspection leave at least two materially plausible
   directions.
2. The likely cost of choosing incorrectly justifies two bounded analyses.
3. The question fits the current coherent batch and has a useful comparison
   outcome.

Do not start exploration for ordinary design uncertainty, a missing Task Owner
decision, or a question already answerable by a small existing check. Stop when
one direction is clearly the smallest justified option, the analyses agree
without a material unresolved question, the unknown needs a bounded spike, or
scope, acceptance, risk, or ownership changes. Multiple contributors alone do
not trigger Design Review.

## Authority and reading order

Read in this order:

1. The Task Owner request and `.ai/current-task.md`.
2. Active OpenSpec requirements, design, specs, and tasks, when present.
3. A confirmed `.ai/requirement-baseline.md`, when present, as non-authoritative
   business evidence after the current task and active OpenSpec.
4. Necessary repository code and formal project documentation.
5. Temporary contributor evidence, only after the Chief Designer has recorded a
   baseline interpretation.

OpenSpec remains the implementation authority when a change exists. A Task
Owner decision that changes requirements or acceptance must be reconciled into
OpenSpec before implementation. Repository code is capability evidence, not
acceptance authority. This guide and its temporary files are not product
requirements. The active agent prepares prompts and workflow artifacts; the
Task Owner decides only within the existing Task Owner Boundary and is not
asked to write requirements, prompts, or runtime files.

## Ownership and routing

The Chief Designer selects the lenses, writes the contributor prompts, creates
unique temporary output paths, and owns comparison and synthesis. While the
same Chief Designer session collects evidence, it uses `continue` and records
the next local step in the existing handoff. If another agent takes over
synthesis, dispatch the same formal `Chief Designer` role with a complete
Operator Command; do not create an explorer or synthesizer role. Contributor
prompts are bounded supporting instructions, not `.ai` routing actions; the
active handoff remains with Chief Designer while they run.

Shared-workspace execution is serialized by default. Parallel contribution
requires an explicit request and the existing non-overlapping/worktree rules.
Each contributor reads the authoritative requirement and only the repository
evidence needed for its lens. It must not read another contributor's output.

Requirements Analyst may clarify the business baseline before exploration, but
does not recommend a route or create contributor prompts. Chief Designer
remains the sole formal exploration owner and decides whether exploration is
justified.

The default location for temporary alternatives and synthesis is a unique path
within:

```text
.ai/explorations/<batch-id>/
```

The current task may declare another unique temporary path; use that path in
contributor prompts and synthesis links. Preserve paths referenced by durable
evidence rather than moving those files during cleanup.

These files are non-authoritative helpers under the existing Runtime Artifact
Budget. Link them when useful; do not copy their full contents into the
handoff. Remove or archive unreferenced helpers under that budget before the
next batch. Keep any path cited by durable evidence stable. Do not
create default `docs/requirements/` or `docs/explorations/` authorities. A
durable exploration document is allowed only when explicitly required and must
not duplicate an active OpenSpec source.

## Contributor task (not a formal role)

Use this compact, copy-ready task for each independent analysis:

```text
Task: Supporting solution analysis (not a formal role)
Execution Batch: <batch id>
Authoritative inputs: <requirement and necessary repository evidence>
Assigned lens: <minimal/reuse, product/domain, architecture/risk, or named
missing material lens>
Assigned output: <declared temporary path or default .ai/explorations/<batch-id>>/<unique-file>.md

Analyze the assigned lens independently. Do not read other contributor outputs,
change .ai Action State, modify implementation files, or modify another output.
Prefer existing capability and distinguish confirmed facts, inferences, and
unknowns. This output is NON-AUTHORITATIVE EXPLORATION.

Return only:
- requirement and constraint interpretation
- repository evidence and capability to reuse
- recommended direction and one material alternative, if any
- assumptions, critical unknowns, risks, and trade-offs
- First Demonstrable Outcome and inspection evidence or steps
- deferred or rejected ideas and confidence
```

Use two materially different lenses, normally minimal/reuse and
product/domain or architecture/risk. A third task is permitted only when the
Chief Designer names the missing material lens and why the first two cannot
cover it. Do not require a fourteen-section proposal.

## Chief Designer synthesis

After the contributor tasks finish, the Chief Designer reads the authoritative
inputs again, then the valid temporary outputs. Compare evidence rather than
vote or merge every idea. For each material disagreement, record the relevant
requirement evidence, repository evidence, risk, complexity, reversibility,
testability, and cost. Prefer the smallest reusable and reversible direction.

The synthesis may be a temporary file under the path above. Its compact format
is:

```markdown
# Solution Exploration Synthesis

## Baseline
- Requirement and must-have outcome:
- Constraints and out of scope:
- Important unknowns:

## Evidence Compared
- Contributor A:
- Contributor B:
- Contributor C (only when named):
- Material disagreements and evidence:

## Direction
- Selected direction and why it is smallest justified:
- Deferred or rejected ideas:
- Remaining unknowns and existing bounded-spike/evidence-driven-iteration
  method:
- First Demonstrable Outcome and inspection method:
- Main risks and complexity exceptions:
- Design Review required: yes/no, with the existing trigger:
```

This synthesis is evidence, not implementation authority. Before routing
implementation, the Chief Designer restates the selected direction, acceptance,
risks, and First Demonstrable Outcome in the normal design handoff or the
authoritative OpenSpec artifact. The implementation agent receives normal
authoritative inputs plus explicitly cited evidence; it does not read rejected
option files by default.

## Unknowns, validation, and normal review

An unresolved empirical question uses the existing bounded-spike or
evidence-driven-iteration guidance. Put the unknown in `Goal` or `Acceptance
Criteria`, its method in `Required Checks`, and deferred work in `Out Of Scope`
or `Constraints`. Use `continue` for stable-scope local evaluation; do not
invent `Rapid Validation` as a mode, status, lifecycle, or completion shortcut.

Exploration does not weaken S/M/H review, Design Review triggers, Task Owner
boundaries, OpenSpec authority, or the one-loop lifecycle limit. Review the
complete coherent batch once at its normal risk-required boundary. If the
selected direction changes scope, acceptance, risk, or ownership, stop and use
the normal Chief Designer routing and technical disposition contracts.

## Exit checklist

Before leaving the batch's design action, confirm:

- the trigger and contributor count were justified;
- every contributor output is isolated, temporary, and non-authoritative;
- the selected direction, evidence, risks, unknowns, and First Demonstrable
  Outcome are recorded in the normal design handoff or OpenSpec source;
- no default requirement/exploration authority, role, status, action, mode, or
  runtime field was introduced; and
- the next action is the existing `continue` or `dispatch` required by the
  current Chief Designer workflow.
