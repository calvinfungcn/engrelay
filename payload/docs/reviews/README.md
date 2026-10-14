# Workspace Review History

This directory is the durable home for **workspace-level** review history.

This file is intentionally written as an operational handbook. Agents and humans
should be able to follow it without additional project-specific prompting.

## Scope

Use this system for:

- root `openspec/changes/*` items
- cross-module reviews
- workspace-level process or architecture reviews

Do not force module-local review history into this structure unless the task
explicitly asks for migration.

## Hard Rules (MUST/NEVER)

### MUST

- Treat `docs/reviews/<change-id>/index.md` as the **current truth** entry point
  for one workspace change.
- Create a new round file for every new review action:
  `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md`.
- Keep the round file bounded and findings-first. Put evidence and conclusions
  in the round file, and keep `index.md` short.
- When a review changes the perceived execution state, record the evidence in a
  round first, then update OpenSpec task state separately.
- Use only these status values: `open`, `fixed-not-verified`, `verified`,
  `deferred`.

### NEVER

- Never append new review content to legacy review artifacts once a change has a
  home under `docs/reviews/`.
  Examples of legacy artifacts:
  - `openspec/changes/*/REVIEW.md`
  - `openspec/changes/*/CODE_REVIEW.md`
  - long running review logs under `docs/plans/*code-review*.md`
- Never mark a topic as `verified` without the evidence rules below.
- Never rewrite or delete legacy artifacts as part of migration. Link to them as
  source artifacts instead.

## Structure

- `docs/reviews/README.md` explains the workspace review system
- `docs/reviews/<change-id>/index.md` is the current-truth entry point for one
  workspace change
- `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` records one imported,
  created, or reconciled review round

## Status Values

### `open`

Unresolved review concerns remain. Use this when any of the following is true:

- required work is not done
- a decision gate is not closed
- evidence is missing

### `fixed-not-verified`

A fix is documented, but the latest linked round does not close the topic with
fresh enough evidence.

This is the default status when you believe the fix exists but cannot prove it
today.

### `verified`

The linked round contains concrete evidence that closes the topic.

Evidence is considered concrete only if it includes at least one of:

- a fresh command run and its result (tests, `openspec validate`, build)
- a reproducible verification procedure with observed outcomes
- a source artifact that itself includes the above evidence and clearly closes
  the topic

### `deferred`

The topic is acknowledged and intentionally postponed.

## Usage Rules

- Start every new workspace-level review in a fresh round file
- Update `index.md` only with the latest truth, topic links, and next actions
- Do not append new review findings to migrated legacy artifacts
- Keep change execution state in the OpenSpec task file (`tasks.md` or legacy
  variants such as `TASKS.md`)
- Use review docs to explain why a change or topic is still `open`,
  `fixed-not-verified`, `verified`, or `deferred`

## Required Templates

### `index.md` template

```markdown
# <change-id>

## Scope

<1-3 sentences describing what this change covers and which modules it spans>

## Overall Status

- `Current status`: `open|fixed-not-verified|verified|deferred`
- `Latest round`: `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md`
- `Legacy review sources`:
  - `<path/to/legacy-review-1.md>`
  - `<path/to/legacy-review-2.md>`
- `Current execution source`: `openspec/changes/<change-id>/tasks.md`

## Topic Index

| Topic | Current status | Latest round | First round | Notes |
| --- | --- | --- | --- | --- |
| <topic> | `open|fixed-not-verified|verified|deferred` | `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` | `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` | <short note> |

## Historical Rounds

| Round | Type | Source |
| --- | --- | --- |
| `YYYY-MM-DD-round-##.md` | <imported|re-review|reconciliation|verification> | <source artifact paths> |

## Next Actions

- <one or two concrete next actions>
```

### `round` template

```markdown
# Round ## - <Imported Legacy Review|Re-Review|Current-State Reconciliation|Verification>

## Metadata

- `Change`: `<change-id>`
- `Recorded on`: `YYYY-MM-DD`
- `Source artifacts`:
  - `<path/to/source-1>`
  - `<path/to/source-2>`
- `Round type`: <imported|re-review|reconciliation|verification>

## Scope

<What this round is checking and what is explicitly out of scope>

## Evidence

<Commands + results, or a clear procedure + observed outcomes. Include dates.>

## Findings

- `<status>` <finding>

## Conclusion

<What is true after this round, and what remains open>

## OpenSpec Impact

- <If tasks.md should change, specify which items and why>

## Next Actions

- <Concrete follow-up actions>
```

## Minimal Agent Prompt

Copy/paste this as a task prompt when you want an agent to strictly follow the
workspace review system:

```text
You are working in the current project repository. Use its actual root path.

Before doing any review work, you MUST read and follow:
1) `docs/reviews/README.md`
2) the "Workspace Review System" section in `AGENTS.md`

Hard constraints:
- This is workspace-level review only (root `openspec/changes/*` and cross-module work).
- Do NOT modify legacy review artifacts under `openspec/changes/*` or old `docs/plans/*code-review*.md`.
- For change `<change-id>`, you MUST:
  - create `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` for this round
  - update `docs/reviews/<change-id>/index.md` as the current-truth entry point
- Status values must be: `open`, `fixed-not-verified`, `verified`, `deferred`.
- Any `verified` claim MUST include fresh evidence in this round.

Now do: <task description>.

Output only:
- the paths you created/updated
- a concise list of findings and evidence
- whether OpenSpec `tasks.md` should change (and why)
```

## Project Review Registry

Read this project's existing change indexes when applicable. The portable
package intentionally does not import another project's business review registry.

## Migration Notes

- Legacy review files remain in their original locations as source artifacts
- New workspace-level review work should continue in `docs/reviews/`
- Module-local review systems, such as those under `pyserver/`, remain valid for
  module-local work
- Imported legacy rounds may use `verified` when the cited source artifact
  itself contains concrete closing evidence for the topic being migrated
