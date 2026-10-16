---
name: ai-collab-requirements
description: >
  Use only when the user explicitly invokes this entry to start or continue a
  business requirements dialogue for a task that uses ai-collaboration in this
  project. Discovery or a similar request does not select the workflow. Runs the
  conditional Requirements Analyst contract, keeps a temporary baseline, and hands
  only an owner-confirmed summary to Chief Designer.
---

# AI Collab Requirements

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

- `.ai/current-task.md` and `.ai/handoff.md`, when they exist, for current state
- `docs/ai-collaboration/agent-prompts.md#requirements-analyst`
- `docs/ai-collaboration/workflows.md#1-task-intake` (conditional analyst rule)
- `docs/ai-collaboration/templates/requirement-baseline.template.md`
- the active `openspec/changes/<change-id>/` artifacts, when one is named

Do not read a full clarification transcript or unrelated batches by default.

## Procedure

1. Task Intake: check whether the requested work already has an active batch or
   change. Reuse that identity. If an unfinished, unrelated batch is live, do not
   overwrite it; explain the conflict and ask for the smallest owner choice, or
   discuss in the reply only. This explicit entry uses the same conditional
   Requirements Analyst contract as `ai-collab-start`; prefer `ai-collab-start`
   for a general new task unless the owner explicitly wants a requirements-only
   dialogue.
   When no current task exists for this work, Task Intake first writes the minimum
   coherent `.ai/current-task.md` and `.ai/handoff.md` before any draft wait. The
   current task carries the task ID, change ID if any, Execution Batch ID, a
   provisional risk `S`, `M` or `H` with a reason marked for Chief Designer
   confirmation, the owner's goal as the observable outcome, must-have acceptance
   drafted from the owner's words, out-of-scope items, required checks marked for
   design, the first role `Requirements Analyst` and the draft baseline path as
   linked evidence. Technical classification and batch slicing stay design-bound
   for Chief Designer; this role does not decide them.
2. Apply the Requirements Analyst role only when Task Intake cannot safely summarize
   material ambiguity in the goal, actors, behavior, scope, acceptance, priority,
   business rules or user experience. A clear request keeps its existing route.
3. Ask two to five highest-value related questions at a time. Reuse answers the owner
   already gave. Leave architecture, storage, API and other technical questions to
   Chief Designer.
4. Before confirmation, state foreseeable adverse business effects and any smaller
   or safer requirement-level alternative.
5. Record evolving evidence in `.ai/requirement-baseline.md` from the template. Its
   maturity is `draft` until the owner explicitly confirms it. The baseline is
   temporary and non-authoritative when an active OpenSpec change exists.
6. Present one plain-language summary (goal, must-haves, acceptance, non-goals and
   open questions) and ask for the smallest exact confirmation or correction.
7. While owner input is pending, keep this role and use same-session `continue`
   with `awaiting-owner-decision` and an Owner Decision Brief. Use human decision
   `dispatch` only when the Task Owner is a separate person.
8. After explicit confirmation, mark the baseline confirmed, update
   `.ai/current-task.md` to link that confirmed baseline and its status, then
   dispatch only Chief Designer with a complete Operator Command that links the
   confirmed baseline as evidence. Chief Designer reconciles technical and OpenSpec
   state. Do not dispatch Implementation Engineer, Code Reviewer, Design Reviewer or
   any other role directly.

## Boundaries

- Do not write code, choose architecture or dependencies, slice batches, or tick
  OpenSpec tasks.
- A requirement confirmation is business-understanding evidence. It is not technical
  approval, production authorization, risk acceptance or OpenSpec completion.
- An already confirmed requirement that covers the request is reused; do not add a
  repeated final confirmation.

## Output

Write `.ai/current-task.md` (when missing, as in step 1) and `.ai/handoff.md` at each
real boundary with complete Routing, the Operator Command (after confirmation) or the
Owner Decision Brief (while waiting), as defined by
`docs/ai-collaboration/handoff-schema.md`.

EngRelay material and modifications: Copyright (c) 2026 calvinfungcn and EngRelay
contributors, MIT. The full notice accompanies the installed kit at the project-root
path `docs/ai-collaboration/README.md#engrelay-license`. Preserve it and any upstream
notice when redistributing a standalone Skill.

