---
name: ai-collab-continue
description: >
  Use only when the user explicitly invokes this entry to resume the current
  ai-collaboration task in this project. Reads the latest task, batch, handoff,
  evidence and review allowance, then follows only the authorized next step for the
  current agent. It never self-reviews, resets a count or reopens a closed batch.
  Discovery alone does not select the workflow.
---

# AI Collab Continue

## Activation

Apply this entry only when the current request explicitly selects ai-collaboration
under `docs/ai-collaboration/README.md#optional-activation-and-coexistence`.

- If the project WorkflowMode is `disabled`, explain that explicit re-enabling is
  required and stop. Do not change the mode or start a lifecycle.
- If another controller owns the task, follow that controller. Write no
  collaboration runtime file and dispatch no role.
- Discovery, a `.ai/` folder, role names or an installed Skill do not activate it.

## Read First

Use project-relative paths only:

- `.ai/current-task.md` and `.ai/handoff.md`, the latest authority for Next action
- `docs/ai-collaboration/handoff-schema.md` for Routing and Operator Command rules
- `docs/ai-collaboration/README.md#routing-contract` and
  `docs/ai-collaboration/README.md#review-round-circuit-breaker`
- the authoritative artifacts named by the handoff, such as the OpenSpec tasks,
  `docs/reviews/<change-id>/index.md` and the latest review round

## Procedure

1. Compare the request with the latest state: change ID, Execution Batch ID, State
   revision, Review round, current role, current agent and status. A delayed or
   duplicate message is checked against that state before any action.
2. Branch on the recorded Next action:
   - `continue`: the same responsible agent performs only the stated next local step,
     then records progress at the boundary. Do not change role.
   - `dispatch` to an agent: follow the complete Operator Command only if the current
     agent is the named role and is independent of the producer of the work under
     review. A reviewer never reviews its own design or implementation. If not
     eligible, do not perform the review; present the original Operator Command for
     the correct recipient and the reason.
   - `dispatch` to a human decision recipient (or any status `awaiting-owner-decision`):
     present the recorded Owner Decision
     Brief in chat. Resume only after the owner's reply clearly answers the decision.
     Silence is not approval.
   - exhausted review capacity: keep the batch open. Present the evidenced remaining
     defects, the smallest repair-and-review plan with reasons, alternatives and the
     exact reply needed. Never start a fourth review or fix cycle and never reset the
     count. Honor a recorded finite owner extension only within its stated bounds.
   - `close`: report the actual closure outcome and any unfinished scope. Do not
     reopen the batch or replay its dispatch. A new necessary repair starts through
     `ai-collab-start` as new work.
   - blocked (`continue` with status `blocked`): report the recorded resume
     condition and wait for it.
3. A request that targets a closed batch or an earlier revision reports the latest
   actual state. It does not replay a dispatch or change prior acceptance.
4. If the authoritative inputs are missing or conflicting, name the exact file and
   conflict, and give the smallest recovery direction. Never invent a role, verdict,
   count or acceptance from chat history.

## Boundaries

- Keep full Operator Commands and Owner Decision Briefs intact when you copy or
  update them.
- Update `.ai/handoff.md` only at a real boundary. Do not add state fields.
- A read-only request uses the response handoff fallback described in
  `docs/ai-collaboration/handoff-schema.md`.
- Owner acceptance, Git operations and deployment remain outside this entry.

## Output

State the Next action you followed, the evidence you checked, and any unfinished
mapped work. For an agent dispatch, confirm where the Operator Command is written. For
a human decision, present the brief. For `close`, state that no next role exists.

EngRelay material and modifications: Copyright (c) 2026 calvinfungcn and EngRelay
contributors, MIT. The full notice accompanies the installed kit at the project-root
path `docs/ai-collaboration/README.md#engrelay-license`. Preserve it and any upstream
notice when redistributing a standalone Skill.

