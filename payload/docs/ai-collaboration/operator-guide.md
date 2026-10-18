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

Read `.ai/current-task.md` and `.ai/handoff.md`. Follow the recorded Next
action only; do not reset review counts or replay closed batches.

## Handoffs and reviews

- One next action: `continue`, `dispatch`, or `close`.
- Agent dispatch includes a complete Operator Command for the next role.
- Agent dispatch may also show one advisory line under `Current Status`:
  `Recommended capability tier: C3` (example). Tiers C1–C5 are short hints for
  choosing model and reasoning strength for the **next** work item only; they do
  not approve models, block work, or replace independent review. Definitions and
  the fixed next-role defaults live in
  [handoff-schema.md#capability-tier-guidance](handoff-schema.md#capability-tier-guidance).
  Human decision dispatch, `continue`, and `close` omit the line.
- Owner decisions use `awaiting-owner-decision` and an Owner Decision Brief;
  silence is not approval.
- Medium-risk batches need independent code review; see
  [review limits](README.md#review-round-circuit-breaker).

Results and formal review rounds are indexed under `docs/reviews/` when recorded.

## Cost and authority

Focused checks match affected behavior. Before substantial low-benefit or
high-cost work, the responsible agent explains options and waits for an owner
choice. Owner acceptance, Git operations, and deployment stay outside the
workflow entries.

## Adoption and hosts

- [Project adoption](project-adoption.md) — install, upgrade, adopt, uninstall.
- [Host capabilities](host-capabilities.md) — SkillTarget discovery paths.

Use paths relative to this directory after installation (`docs/ai-collaboration/`).
