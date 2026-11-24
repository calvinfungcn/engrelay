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

## Diagnostics & Ownership

- Read-only check: `& ./docs/engrelay/scripts/doctor.ps1 -WorkspaceRoot $PWD.Path`
- Project-owned config: `docs/engrelay.config.md` (preserved across `Upgrade` and `Uninstall`)
- Runtime state: `.ai/relay/<change-id>/` (excluded from Git; isolated from legacy `.ai/` state)
