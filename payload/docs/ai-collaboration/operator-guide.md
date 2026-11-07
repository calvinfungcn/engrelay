# Operator guide

[简体中文](operator-guide.zh-CN.md)

Human-oriented guide for using EngRelay in a project. Role contracts, machine
fields, and validators live in [README.md](README.md) and [handoff-schema.md](handoff-schema.md);
this file does not replace them.

## Activation

Package-managed projects use `WorkflowMode` **optional** (new-install default),
**default**, or **disabled** as described under
[optional activation](README.md#optional-activation-and-coexistence). An explicit
request for this workflow takes priority over a project **default** selection. In
**optional** mode, select EngRelay on the current request; in **default** mode,
the project’s configured default may apply without repeating the selection each
time. Installing the kit, discovering Skills, or finding a `.ai/` folder does
not by itself start a batch.

If `WorkflowMode` is `disabled`, re-enable it before use. If another controller
owns the task, follow that controller and write no collaboration runtime files.

## Entries

| Entry | When to use |
| --- | --- |
| `ai-collab-start` | Recommended for a new task with a stated goal |
| `ai-collab-requirements` | Explicit business requirements dialogue before design |
| `ai-collab-continue` | Resume the latest authorized handoff |

Without a host discovery copy, ask the agent to read the canonical Skill under
`docs/ai-collaboration/skills/<name>/SKILL.md` in the installed project.

### Start (recommended)

- **Clear goal:** Task Intake prepares minimum task input and routes by risk
  (for example Chief Designer, Implementation Engineer, or Code Reviewer) without
  a fixed requirements stage.
- **Material business ambiguity:** the same session runs the conditional
  [Requirements Analyst](workflows.md#requirements-analyst-conditional-role-action)
  action; the owner is not asked to invoke `ai-collab-requirements` separately.
- **Technical uncertainty** with a clear business goal goes to Chief Designer,
  not a business interview.
- **Already confirmed** requirements are reused; no repeated final confirmation.

### Requirements (explicit shortcut)

Same analyst contract as start, but activated only when the owner explicitly
chooses a requirements-first dialogue. After owner confirmation, dispatch goes
only to Chief Designer.

### Continue

Read `.ai/current-task.md` and `.ai/handoff.md`, then the rule sections and named
evidence needed for the actual route. Follow the latest applicable action; do not
reset review counts or replay closed batches. Reuse only references already read
in the same session and known unchanged; a new agent, missing context, changed
input or rule question requires refreshing the affected material. Project and
triggered-Skill required reading still applies.

Check `Human Action Required` first: `none` means no current business decision
(`awaiting-decision`) or unmet immediate human-only environment preparation (`awaiting-environment`).
Under manual relay for new Full tasks, the field remains `none` on agent dispatch,
but the operator must relay the Operator Command to the chosen AI tool. Disclose
the known limitation that legacy machine consumers might read `none` literally as
"no human action required at all"; the top blockquote notice and final response make
the operator transfer explicit. A later-only environment notice must state that no
action or reply is needed now. Recheck the actual status and prerequisites if an
older handoff omits this summary.

New Full tasks default to manual relay across platforms on formal agent dispatch.
The agent saves, reads back, and validates the handoff, adds a top transfer notice
(`> 人工接力：请由你选择 AI 工具，将本交接中的 Operator Command 转交给 <Next role>。`
or `> Manual Relay: Please select an AI tool and relay the Operator Command from this handoff to <Next role>.`),
explains the next role, recommended capability tier (C1–C5), and Operator Command in
chat, and ends the turn. The user selects the tool, model, and reasoning effort
best suited for that role, without repeating business authorization. If `Constraints`
explicitly authorizes automated cross-role progression and the host supports it,
the workflow advances autonomously. In-role micro-steps and user-launched executable
`continue` proceed directly without pausing at every tool call.

Portable relay across workspaces:
- **Shared workspace**: The successor tool accesses the same repository directory,
  reads `.ai/handoff.md` and `.ai/current-task.md`, verifies execution ownership
  and review capacity, and proceeds.
- **Non-shared or read-only tools**: The operator provides only a minimal vetted excerpt;
  the tool returns a response handoff, and a permitted writer in the primary workspace
  verifies source revision and SHA256 match before persisting. Never copy whole
  repositories or credentials; no platform automatically sanitizes data. Tool or
  model separation does not establish review independence.

Executable `continue` includes a `### Continuation Command` under Current
Status. An active capable agent follows it directly after checking latest
authority and execution ownership. If a single-turn CLI has exited, the operator
or an existing runner can copy the block into a replacement session. Ending a
turn is not an environment blocker. The agent chooses a local CLI/IDE host
within authorized offline work without asking the owner; actual permissions,
decisions, review limits and independent review still apply. EngRelay itself
does not wake stopped processes. See
[autonomous continuation](handoff-schema.md#autonomous-continuation).

## Handoffs and reviews

- One next action: `continue`, `dispatch`, or `close`.
- Agent dispatch includes a complete Operator Command for the next role.
- Agent dispatch must show one advisory line under `Current Status`:
  `Recommended capability tier: C3` (example). Tiers C1–C5 are short hints for
  choosing model and reasoning strength for the **next** work item only; they do
  not approve models, block work, or replace independent review. Definitions and
  the fixed next-role defaults live in
  [handoff-schema.md#capability-tier-guidance](handoff-schema.md#capability-tier-guidance).
  Human decision dispatch, `continue`, and `close` omit the line. The line is a
  suggestion, not a gate; an older handoff without it stays valid, and a structure
  check does not confirm the line.
- Owner decisions use `awaiting-owner-decision` and an Owner Decision Brief;
  silence is not approval.
- Each dispatch names its writable handoff outputs. A read-only code review does
  not by itself forbid `.ai/` updates; a real user, higher-priority instruction
  or tool limit does, and then the final response carries the complete handoff.
- At each real boundary the writing agent saves `.ai/handoff.md`, reads it back,
  and runs `validate-runtime-state.ps1` with the batch, action, next role and
  Review round it decided (`-ExpectedBatchId`, `-ExpectedNextAction`,
  `-ExpectedNextRole`, `-ExpectedReviewRound`, and `-ExpectedStateRevision` when a
  revision exists). A pass confirms the stated values and structure only.
- A read-only subagent's result is published or saved by the still-active, permitted agent that
  delegated it, at the same boundary, and states its findings in that reply. With no permitted agent, the response
  handoff says it is not persisted.
- When a completed same-batch review record, or a result or response file named by
  the live handoff (including its Next output files) or the current task, is newer than
  the live handoff, `ai-collab-continue` first restores that transfer after matching its
  real SHA256 fingerprint and revision; see
  [source-matched recovery](handoff-schema.md#source-matched-recovery). A new container
  must carry a real SHA256; only legacy index-linked review records and legacy response
  handoffs may omit it. A batch restores at most one pending transfer.
  It never recounts a verdict or replays a command.
- A planned end of the active session is a handoff boundary even for the same role.
  A long check may leave one checkpoint with its external log, stated as not yet passed.
- These checks do not wake processes, authenticate the saved log, or certify
  acceptance.
- Medium-risk batches need independent code review; see
  [review limits](README.md#review-round-circuit-breaker).

Results and formal review rounds are indexed under `docs/reviews/` when recorded.

## Closing and verification

After closure, the reply states the actual mapped result, known remaining work or
unknowns, no next role or Operator Command for that batch, and one useful next step.
It distinguishes ordinary acceptance, limited owner acceptance, stopped and superseded.
A bare “continue” does not select unfinished parent work: the agent names known items
and offers a request such as “Use EngRelay: implement <change> item <id>.” If no work
remains, it offers start for a new stated goal. Missing/conflicting evidence is named.
A status answer leaves files intact.

If your current request clearly identifies and authorizes follow-up work, the agent
uses the existing Task Intake in the same session; you need not resend it through
start. It checks scope and dependencies, preserves old closure and same-acceptance
review counts, and honors actual waits and controller boundaries. A single authorized
post-closure review retains its finite scope and independence; it grants no new
three-cycle repair allowance. See [closed-batch guidance](README.md#closed-batch-guidance).

Ordinary `accepted` closure means the mapped batch is complete under the
recorded acceptance criteria, not that every parent OpenSpec item or business
check passed. Before you treat a batch as verified:

- The responsible agent finalizes `.ai/current-task.md`, mapped `tasks.md`,
  and a `close` handoff, then runs the project's
  `validate-runtime-state.ps1` on those **final** inputs.
- Command, exit code, diagnostics, and which inputs were checked belong in a
  linked result or review file, not pasted into handoff evidence backticks.
- Validation output is recorded **outside** the validated handoff so the check
  does not circularly modify what it inspects.
- If validation fails or the environment is unavailable, the batch stays on
  `continue` or `dispatch`; use `blocked` with a resume condition instead of
  closing. Chief Designer may still record explicit **limited owner acceptance**
  with `Acceptance basis: owner-decision`; that is not the same as a technical
  pass.

Full rules:
[handoff-schema.md#accepted-closure-validation](handoff-schema.md#accepted-closure-validation).
Source-repository follow-up items (for example deferred demo work) live in the
public EngRelay OpenSpec navigation on GitHub, not in the installed package
export.

## Evidence and read-only return examples

These examples are illustrative. The hypothetical figures do not record a real run.

- **Externalize large output.** Write a long check to a named file outside the handoff,
  such as `.ai/<batch>/checks/unit.log`. Return only the exit code, a short summary and
  the path. Record the command and exit code in the result file's `Checks Run` table,
  not in handoff evidence backticks.
- **One minimal capture first.** When acceptance needs evidence of real Agent calls and
  the capture method is unproven, run one minimal end-to-end call first. Confirm that it
  links the input, the returned output, the produced artifact and the final handoff check.
  Record unobtainable host facts as unknown; never fill in a status after the fact.
- **Count erratum.** A summary says "seven launches", but the named source table lists six
  Agent invocations. Add a dated erratum beside the summary that cites that source and
  states six. Report launches, follow-up inputs, failures and shared coordination
  separately, and do not treat a missing record as zero. Recheck only the affected totals
  and leave the original report unchanged.
- **Evidence correspondence.** Citing an old upload result cannot prove that the current
  FileId entrypoint succeeds. When the entrypoint, input, or environment does not correspond
  to claimed acceptance, keep the item unverified and disclose the exact gap, rather than
  substituting an offline fake or narrative assertion.
- **Privacy-safe reporting and minimal redaction.** Never include real credentials, invoice
  fields, or private customer identifiers in review reports, handoffs, or commit diffs;
  use fictional aliases, synthetic counts, and mock states. If an existing report contains
  prohibited sensitive values, apply minimal redaction under applicable authorization
  without exposing values in diffs, preserving facts, verdicts, and a value-free explanation.
- **Post-closure review and capacity.** When the Task Owner requests a single additional
  review on already-closed work, keep historical closure records and counts intact. The
  single review evaluates only that authorized scope without reopening the batch or granting
  three new fix cycles. Genuinely new defects require applicable authorization to start a
  linked repair batch.
- **Bounded archive check.** Archive verification focuses on spec delta / main spec
  correspondence, completeness, tasks, index links, and delivery privacy. Passing the check
  concludes it; unrelated historical failures in global checks are reported separately without
  blocking current closure or falsely claiming global pass.
- **Fully read-only return.** A read-only reviewer returns its complete verdict, findings
  and Response Handoff, including source role, source Agent, work producer, source Execution
  Batch ID, Task ID, prior State revision, prior live SHA256, target State revision and
  cumulative Review round. The still-active writer then applies
  [source-matched recovery](handoff-schema.md#source-matched-recovery): the source batch must
  match the current task, and the prior revision and live SHA256 must match the live handoff,
  so the candidate is pending. A conflict, an advanced state or a missing attribution item
  stops here; the live handoff stays unchanged and the complete return remains an unpersisted
  response handoff. Only when the writer is permitted to write the handoff does it save the
  complete return to the named container, re-read the live bytes, publish the complete
  Action State as `.ai/handoff.md`, read it back, and run expected-state validation with the
  decided batch, action, next role, Review round and target revision. The verdict is counted
  once. Only unambiguous formatting may change; never rewrite a technical conclusion to fit
  a format.

## Cost and authority

Focused checks match affected behavior. Before substantial low-benefit or
high-cost work, the responsible agent explains options and waits for an owner
choice. Owner acceptance, Git operations, and deployment stay outside the
workflow entries.

## Adoption and hosts

- [Project adoption](project-adoption.md) — install, upgrade, adopt, uninstall.
- [Host capabilities](host-capabilities.md) — SkillTarget discovery paths.

Use paths relative to this directory after installation (`docs/ai-collaboration/`).
