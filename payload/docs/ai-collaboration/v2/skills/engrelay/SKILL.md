---
name: engrelay
description: >
  Use only when the current task explicitly selects EngRelay (v2). Supports
  plan (OpenSpec orchestrator), do (platform-native execution/checkpoint), and
  review (independent M/H review and verification). Never self-activates.
---

# EngRelay v2

Apply only when EngRelay v2 is selected for this task under `AGENTS.md` and `docs/engrelay/RULES.md`. Read `docs/engrelay/RULES.md`, optional `docs/engrelay.config.md`, and `.ai/relay/<change-id>/board.md` (plus `wp-XX.md` for `do`/`review`). `.ai/relay/` including `CURRENT` never activates this workflow.

## Target lock
Explicit `<change-id>` wins and stays locked for the whole call. Otherwise a valid `.ai/relay/CURRENT` (one trimmed line matching `^[A-Za-z0-9][A-Za-z0-9._-]*$`, no `..` or separators, and a live `board.md`) resolves shorthand even when several boards exist. Only a missing or stale pointer falls back: one valid board may be chosen and written; zero or two-plus boards list candidates and stop. Echo `Change: <change-id>` first. An explicit id, or that unique-board fallback, writes `CURRENT` once its board exists. Every cross-session command keeps `<change-id>`.

## Mode: `plan <change-id>`
1. Read `openspec/changes/<change-id>/` (`proposal.md`, `design.md`, `specs/`, `tasks.md`) and run one `docs/solutions/` check.
2. Slice into ≤`L` Work Packages (`WP-01..N`) along independent review boundaries; add a downstream integration WP whenever cross-WP boundaries need joint verification.
3. Assign orthogonal `Risk (S|M|H)`, `Difficulty (C1–C5)`, `Shape`, `Size (XS|S|M|L)`, `Rhythm (可断点|建议连续)`, and explicit review gate (`S` + no explicit review = none; `M` = independent review; `H` = independent review + post-repair verification).
4. Write `.ai/relay/<change-id>/board.md` with `Global Constraints`, `Repo & Diff Scope`, `Interfaces`, `Deferred / Handoff`, and `Done & Verify`. Preserve existing cumulative verdicts/failure signatures if re-planning unfinished acceptance. Then write `.ai/relay/CURRENT`.
5. End with the five-line Next Step body from the rules (`Primary`, `Command`, `Axes`, `Gate`, `Alternate`). `Command` is one ready `do <change-id> <WP-XX>`. `Alternate` is another ready WP or `none`. Do not start `do`.

## Mode: `do <change-id> <WP-XX>`
Shorthand `do <WP-XX>` uses Target lock. A fix also reads the latest unresolved `BLOCKER`s and any recorded `(a)` scope.
1. Check `board.md` (and `wp-XX.md` checkpoint if resuming). Work continuously within WP scope and `Global Constraints`; run required checks and simplify diff.
2. If risk escalates (e.g., `S` → `M`/`H`), update risk and refresh the review gate immediately; never self-close via `DONE_WITH_CONCERNS`.
3. If quota/context runs low, append a ≤15-line `Checkpoint` to `wp-XX.md` and stop cleanly without triggering review.
4. On exit, write a ≤60-line summary (`DONE|DONE_WITH_CONCERNS|NEEDS_CONTEXT|BLOCKED`, actual repo/diff scope, commands & input match). Mark `[x] done` ONLY if the applicable review/verification gate is empty and checks pass.
5. Emit that same five-line Next Step body. Checkpoint `Command` is `do <change-id> <WP-XX>` and does not start review. Gated completion `Command` is `review <change-id> <WP-XX>`. Empty-gate close `Command` is the next ready `do <change-id> <WP-YY>`. `Alternate` is a parallel ready WP or `none`.

## Mode: `review <change-id> <WP-XX>`
Shorthand `review <WP-XX>` uses Target lock. Update `CURRENT` only for an explicit id or the unique-board fallback. Write only `.ai/relay/<change-id>/`, that allowed `CURRENT` line, and `tasks.md` when mapped acceptance is fully satisfied. Never edit product source, config, or tests.
1. Confirm session independence from implementer and fixer (prefer heterogeneous family; same-family independent session allowed when unavailable, recording actual tool/model).
2. Inspect `board.md` WP entry, `wp-XX.md`, complete WP change scope (untracked/staged/committed across declared repos, isolating sibling WPs), and targeted OpenSpec/module guides/source as needed. Verify reused test evidence matches current inputs.
3. Output ≤50 lines: verdict (`PASS|FIX REQUIRED`), `BLOCKER`s, `NOTE`s, and `⚠️ Cannot verify from diff`.
   - `PASS` with `⚠️` is allowed ONLY if `⚠️` does not block this WP's required acceptance and names a downstream WP; sync `tasks.md` ONLY when mapped acceptance is complete.
   - Round 2 checks Round 1 `BLOCKER`s plus any real P0/P1/safety/contract/build regression in fix scope (never escalate `NOTE`s).
   - Unresolved Round 2 or 2 consecutive identical failure signatures → mark `[~] blocked` (`failure_class: product|harness`), block dependents only, and present the 3 owner options.
4. On `FIX REQUIRED` or an in-session `(a)`, record the verdict or authorization, keep the cumulative count, and stop without editing product files. Emit the same five-line Next Step body. In-budget `FIX REQUIRED` or a recorded confirmed `(a)` sets `Command` to `do <change-id> <WP-XX>` (do not ask again or grant quota). An unauthorized `product`/ceiling `[~] blocked`, or a `harness` block whose recovery is not verified, sets `Command` to `Wait` and names the unmet check in `Gate`; do not put a repair or same-input rerun in `Command`. On `PASS`, `Command` is the next ready `do <change-id> <WP-YY>`, or `none` when nothing is ready. `Alternate` is an independent ready WP or `none`.

MIT License: Copyright (c) 2026 calvinfungcn and EngRelay contributors (see `docs/engrelay/LICENSE`).
