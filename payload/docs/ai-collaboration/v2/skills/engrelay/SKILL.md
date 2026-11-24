---
name: engrelay
description: >
  Use only when the current task explicitly selects EngRelay (v2). Supports
  plan (OpenSpec orchestrator), do (platform-native execution/checkpoint), and
  review (independent M/H review and verification). Never self-activates.
---

# EngRelay v2

Apply only when EngRelay v2 is selected for this task under `AGENTS.md` and `docs/engrelay/RULES.md`. Read `docs/engrelay/RULES.md`, optional `docs/engrelay.config.md`, and `.ai/relay/<change-id>/board.md` (plus `wp-XX.md` for `do`/`review`).

## Mode: `plan <change-id>`
1. Read `openspec/changes/<change-id>/` (`proposal.md`, `design.md`, `specs/`, `tasks.md`) and run one `docs/solutions/` check.
2. Slice into ≤`L` Work Packages (`WP-01..N`) along independent review boundaries; add a downstream integration WP whenever cross-WP boundaries need joint verification.
3. Assign orthogonal `Risk (S|M|H)`, `Difficulty (C1–C5)`, `Shape`, `Size (XS|S|M|L)`, `Rhythm (可断点|建议连续)`, and explicit review gate (`S` + no explicit review = none; `M` = independent review; `H` = independent review + post-repair verification).
4. Write `.ai/relay/<change-id>/board.md` with `Global Constraints`, `Repo & Diff Scope`, `Interfaces`, `Deferred / Handoff`, and `Done & Verify`. Preserve existing cumulative verdicts/failure signatures if re-planning unfinished acceptance.

## Mode: `do <WP-XX>`
1. Check `board.md` (and `wp-XX.md` checkpoint if resuming). Work continuously within WP scope and `Global Constraints`; run required checks and simplify diff.
2. If risk escalates (e.g., `S` → `M`/`H`), update risk and refresh the review gate immediately; never self-close via `DONE_WITH_CONCERNS`.
3. If quota/context runs low, append a ≤15-line `Checkpoint` to `wp-XX.md` and stop cleanly without triggering review.
4. On exit, write a ≤60-line summary (`DONE|DONE_WITH_CONCERNS|NEEDS_CONTEXT|BLOCKED`, actual repo/diff scope, commands & input match). Mark `[x] done` ONLY if the applicable review/verification gate is empty and checks pass.

## Mode: `review <WP-XX>`
1. Confirm session independence from implementer and fixer (prefer heterogeneous family; same-family independent session allowed when unavailable, recording actual tool/model).
2. Inspect `board.md` WP entry, `wp-XX.md`, complete WP change scope (untracked/staged/committed across declared repos, isolating sibling WPs), and targeted OpenSpec/module guides/source as needed. Verify reused test evidence matches current inputs.
3. Output ≤50 lines: verdict (`PASS|FIX REQUIRED`), `BLOCKER`s, `NOTE`s, and `⚠️ Cannot verify from diff`.
   - `PASS` with `⚠️` is allowed ONLY if `⚠️` does not block this WP's required acceptance and names a downstream WP; sync `tasks.md` ONLY when mapped acceptance is complete.
   - Round 2 checks Round 1 `BLOCKER`s plus any real P0/P1/safety/contract/build regression in fix scope (never escalate `NOTE`s).
   - Unresolved Round 2 or 2 consecutive identical failure signatures → mark `[~] blocked` (`failure_class: product|harness`), block dependents only, and present the 3 owner options.

MIT License: Copyright (c) 2026 calvinfungcn and EngRelay contributors (see `docs/engrelay/LICENSE`).
