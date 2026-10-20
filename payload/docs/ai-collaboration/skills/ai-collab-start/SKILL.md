---
name: ai-collab-start
description: >
  Use only when the user explicitly invokes this entry to start a clearly stated
  task under ai-collaboration in this project. Recommended general entry: reuses
  existing Task Intake shortcuts, the same conditional Requirements Analyst
  contract as ai-collab-requirements when needed, prepares the minimum coherent
  task input, and routes by risk. Discovery alone does not select the workflow.
---

# AI Collab Start

## Activation

Apply this entry only when the current request explicitly selects ai-collaboration
under `docs/ai-collaboration/README.md#optional-activation-and-coexistence`.

- If the project WorkflowMode is `disabled`, explain that explicit re-enabling is
  required and stop. Do not change the mode or start a lifecycle.
- If the user selected another controller for this request, follow that controller.
  Write no collaboration runtime file and dispatch no role.
- Discovery, a `.ai/` folder, role names or an installed Skill do not activate it.

## Read First

Use project-relative paths only:

- `docs/ai-collaboration/workflows.md#1-task-intake`
- `docs/ai-collaboration/workflows.md#requirements-analyst-conditional-role-action`
- `docs/ai-collaboration/agent-prompts.md#requirements-analyst`
- `docs/ai-collaboration/templates/current-task.template.md`
- `docs/ai-collaboration/templates/handoff.template.md`
- `.ai/current-task.md` and `.ai/handoff.md`, when they exist
- the named `openspec/changes/<change-id>/` artifacts, when the user names a change

## Procedure

1. Same-work check: if the goal belongs to an existing active change or unfinished
   batch, reuse its identity, acceptance and cumulative review count. Do not reset
   the count and do not create a duplicate batch. Continue it through
   `ai-collab-continue`, which first applies its source-matched recovery to a
   same-batch completed review or response handoff that the live file predates
   (`docs/ai-collaboration/handoff-schema.md#source-matched-recovery`).
2. Unrelated unfinished batch: keep its live `.ai` inputs untouched. Explain the
   conflict and request the smallest owner choice. Replacement needs explicit owner
   authorization. Response-only discussion may proceed without writes.
3. Closed previous batch: archive its current-task, handoff and any baseline under
   `.ai/archive/<batch id>/` by the existing closure rule. Referenced evidence stays
   where it is.
4. Prepare the minimum coherent `.ai/current-task.md`: task ID, change ID if any,
   Execution Batch ID mapped to OpenSpec checklist items, risk `S`, `M` or `H` with a
   reason, the observable outcome, must-have acceptance, out-of-scope work, required
   checks and the first role. Keep `openspec/changes/<change-id>/tasks.md` as the
   only implementation checklist; do not create a second task list.
5. Route by the existing rules:
   - material business ambiguity that Task Intake cannot safely summarize: set
     Initial role to Requirements Analyst and run the conditional role action in
     this same responsible session per
     `workflows.md#requirements-analyst-conditional-role-action`. Do not ask the
     owner to invoke `ai-collab-requirements` separately; technical ambiguity
     stays with Chief Designer;
   - a new contract, a complexity exception, risk `H` or missing design basis goes to
     Chief Designer with a complete Operator Command;
   - a clear, bounded `S` or `M` scope goes to Implementation Engineer;
   - an existing implementation that needs review goes to Code Reviewer.
   Reuse an already confirmed requirement baseline; do not add a repeated final
   confirmation.
6. If the first executable action needs an owner decision, keep this role with
   same-session `continue` and `awaiting-owner-decision` plus an Owner Decision
   Brief. Do not dispatch an implementer.

## Boundaries

- Do not implement the work in this entry. It only prepares the input and route.
- Do not reopen closed evidence or write over unfinished unrelated work.
- Owner acceptance and deployment remain outside this entry.

## Output

Write `.ai/current-task.md` and `.ai/handoff.md` at each real boundary. The handoff
must carry complete Routing and a copy-ready Operator Command for an agent dispatch,
or an Owner Decision Brief for a wait, as defined by
`docs/ai-collaboration/handoff-schema.md`.

For an agent `dispatch`, the first `Current Status` line is the advisory
`Recommended capability tier: Cn` (`docs/ai-collaboration/handoff-schema.md#capability-tier-guidance`).
Confirm it at the same readback and echo the same tier in the final reply; a
response-only fallback carries the same line.

EngRelay material and modifications: Copyright (c) 2026 calvinfungcn and EngRelay
contributors, MIT. The full notice accompanies the installed kit at the project-root
path `docs/ai-collaboration/README.md#engrelay-license`. Preserve it and any upstream
notice when redistributing a standalone Skill.

