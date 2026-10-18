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
- `docs/ai-collaboration/handoff-schema.md` for Routing, autonomous continuation
  and Operator Command rules
- `docs/ai-collaboration/README.md#routing-contract` and
  `docs/ai-collaboration/README.md#review-round-circuit-breaker`
- the authoritative artifacts named by the handoff, such as the OpenSpec tasks,
  `docs/reviews/<change-id>/index.md` and the latest review round

## Procedure

1. Compare the request with the latest state: change ID, Execution Batch ID, State
   revision, Review round, current role, current agent and status. A delayed or
   duplicate message is checked against that state before any action.
2. Resolve actual waits and limits before executing any command:
   - `close`: report the actual closure outcome and unfinished scope; never reopen
     the batch or replay its dispatch. Necessary new repair uses ai-collab-start.
   - `awaiting-owner-decision` (including human dispatch): present the recorded
     Owner Decision Brief; continue only after an applicable reply. Silence is
     not approval. Reuse an already answered decision without asking again.
   - `continue` + `blocked`: check the Resume condition and current evidence;
     perform a cheap safe check if available. Resume only if the actual condition
     is resolved; record that evidence and update the wait/summary before executing
     the authorized step. Otherwise retain the wait and report its resume condition.
     A no-action forward notice alone is not a blocker.
   - exhausted review capacity: follow the existing circuit breaker and any
     applicable finite owner extension. Never start a fourth autonomous cycle or
     reset the count. Use the evidenced owner-decision route when required.
3. Otherwise follow the latest executable Next action:
   - `continue`: immediately perform the stated authorized next step if capable
     and permitted. Read the Continuation Command under Current Status when
     present; on legacy records recover the step from Current Status and linked
     authority, without requiring new fields or owner approval. A replacement
     session may assume the same responsibility after checking latest state and
     other same-batch execution ownership; record actual Current agent, keep the
     responsible role, batch, scope, risk and Review round. Formal role transfers,
     synthesis-agent dispatch and independent reviews still use dispatch.
     Local CLI/IDE host choice within authorized offline work is your execution
     detail: never ask the owner where to run or to approve continue again.
     A prior runner exiting is not environment blockage; do not launch competing
     writers or kill another agent's process. Report a concrete capability or
     permission limit through the existing recovery route when needed.
   - `dispatch` to an agent: follow the complete Operator Command only if the current
     agent is the named role and is independent of the producer of the work under
     review. A reviewer never reviews its own design or implementation. If not
     eligible, do not perform the review; present the original Operator Command for
     the correct recipient and the reason.
4. A request that targets a closed batch or an earlier revision reports the latest
   actual state. It does not replay a dispatch or change prior acceptance.
5. If the authoritative inputs are missing or conflicting, name the exact file and
   conflict, and give the smallest recovery direction. Never invent a role, verdict,
   count or acceptance from chat history.

## Boundaries

- Keep full Operator Commands and Owner Decision Briefs intact when you copy or
  update them.
- Update `.ai/handoff.md` only at a real boundary using the canonical schema.
  Include Human Action Required in new/updated handoffs; for executable continue
  include its Continuation Command, and omit it on actual waits/dispatch/close.
  A forward notice needs no current human action/reply. This entry does not
  schedule or wake processes, change host configuration, or override disabled mode.
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

