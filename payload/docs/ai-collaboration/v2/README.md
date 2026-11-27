# EngRelay v2

[简体中文](README.zh-CN.md) · [Rules](RULES.md) · [Skill](skills/engrelay/SKILL.md)

EngRelay v2 is the lean cross-platform relay profile for OpenSpec changes, designed for small-quota multi-platform subscriptions. It replaces heavyweight role chains and per-handoff validation with three clear actions (`plan`, `do`, `review`), orthogonal risk (`S|M|H`) and capability/workload (`C1–C5` × `XS|S|M|L`) sizing, and a hard two-round review circuit breaker.

## Install

Run from an extracted trusted package outside the target project:

```powershell
& ./scripts/manage.ps1 -Action Install -ProjectRoot $project
# Optional host skill discovery copy:
& ./scripts/manage.ps1 -Action Install -ProjectRoot $project -WorkflowProfile v2 -SkillTarget cursor
```

New installs default to `WorkflowProfile=v2`, `WorkflowMode=optional`, and `SkillTarget=none`. Existing `full` and `lite` installations retain their recorded profile on `Upgrade` and `SetMode`.

## Daily Workflow

1. **Plan once (`plan <change-id>`)**: Read OpenSpec and `docs/solutions/`, slice into ≤`L` Work Packages in `.ai/relay/<change-id>/board.md`, extract `Global Constraints` and `Interfaces`, and label Risk (`S|M|H`) + Difficulty (`C1–C5`) + Size/Rhythm (`XS|S|M|L` × `可断点|建议连续`, meaning breakable or preferably continuous).
2. **Execute (`do <WP-XX>`)**: Let the chosen platform finish coding, tests, and diff cleanup continuously. Append a ≤15-line checkpoint in `wp-XX.md` to switch platforms mid-WP without triggering review. Risk `S` without explicit review closes directly on passing self-checks.
3. **Independent review (`review <WP-XX>`)**: Required for `M`, `H` (including post-repair independent verification), and explicit review requests. Use an independent session (different model family preferred; same-family independent session allowed when heterogeneous quota is unavailable). Max 2 rounds; unresolved defects halt cleanly as `[~] blocked`.

## Relay ergonomics

- A review session may write `.ai/relay/<change-id>/`, `.ai/relay/CURRENT` when the command names a change id or when a missing or stale pointer has exactly one board, and `tasks.md` only when mapped acceptance is fully satisfied. It does not edit product source, config, or tests. After `FIX REQUIRED`, or after a recorded `(a)` authorization, it stops. The fixer session runs `do <change-id> <WP-XX>`, and the same review session can take the next round.
- `plan`, `do`, and `review` end with a Next Step card whose body is always five lines: `Primary`, `Command` (or `Wait`), `Axes` (Risk, Difficulty, Size/Rhythm), `Gate` or recovery, and `Alternate` (`none` when empty). One action is primary. Commands that another session will copy always include the change id. An unauthorized product or ceiling block, and a harness block whose recovery is not verified, use `Command: Wait` for that work package.
- `.ai/relay/CURRENT` stores one change id. An explicit id wins and stays locked for that call. The reply starts with `Change: <change-id>`. Shorthand `do WP-XX` / `review WP-XX` follows a valid pointer even when several boards exist. If the pointer is missing or stale and more than one board exists, the session lists the candidates and stops. The file does not activate EngRelay.
- Change-level relay (before `plan` and before archive) uses the same Skill: `review proposal <change-id>` / `fix proposal <change-id>` append to `.ai/relay/<change-id>/review-proposal.md`, and `review change <change-id>` / `fix change <change-id>` append to `review-change.md`. Reviews stay read-only for OpenSpec and product files; `fix proposal` revises only `openspec/changes/<change-id>/*`, and `fix change` never commits, archives, or releases. A same-acceptance block recorded for a WP carries into change review, and the reverse, so neither path resets the two-round count. A fix is refused with zero writes (`CURRENT` included) when the report is missing, already `PASS`, or blocked without recorded authorization.

## Diagnostics & Ownership

- Read-only check: `& ./docs/engrelay/scripts/doctor.ps1 -WorkspaceRoot $PWD.Path`
- Project-owned config: `docs/engrelay.config.md` (preserved across `Upgrade` and `Uninstall`)
- Runtime state: `.ai/relay/<change-id>/` (excluded from Git; isolated from legacy `.ai/` state). `.ai/relay/CURRENT` is the one-line active-change pointer in that same ignored directory. `doctor.ps1` reads it and does not create, repair, or delete it.
