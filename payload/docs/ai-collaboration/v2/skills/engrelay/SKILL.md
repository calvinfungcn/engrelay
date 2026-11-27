---
name: engrelay
description: >
  Use only when the current task explicitly selects EngRelay (v2). Supports
  plan (OpenSpec orchestrator), do (platform-native execution/checkpoint), review
  (independent M/H review and verification), and change-level review/fix for
  OpenSpec proposals and changes. Never self-activates.
---

# EngRelay v2

Apply only when EngRelay v2 is selected for this task under `AGENTS.md` and `docs/engrelay/RULES.md`. Read `docs/engrelay/RULES.md`, optional `docs/engrelay.config.md`, and `.ai/relay/<change-id>/board.md` (plus `wp-XX.md` for `do`/`review`). `.ai/relay/` including `CURRENT` never activates this workflow.

## Target lock
Explicit `<change-id>` wins and stays locked for the whole call. Otherwise a valid `.ai/relay/CURRENT` (one trimmed line matching `^[A-Za-z0-9][A-Za-z0-9._-]*$`, no `..` or separators) resolves shorthand even when several anchors exist. Anchor: `board.md` for WP commands; an active `openspec/changes/<id>/` (not `archive/`) for `proposal` commands; for `change` commands, that directory or an existing `board.md`. Review reports never filter candidates. Only a missing or stale pointer falls back: one candidate may be chosen; zero or two-plus list candidates and stop. Echo `Change: <change-id>` first. Write `CURRENT` (explicit id or fallback) only after identity and admission pass; a refused call leaves it byte-identical or absent. Every cross-session command keeps `<change-id>`.

## Mode: `plan <change-id>`
1. Read `openspec/changes/<change-id>/` (`proposal.md`, `design.md`, `specs/`, `tasks.md`) and run one `docs/solutions/` check.
2. Slice into ≤`L` Work Packages (`WP-01..N`) along independent review boundaries; add a downstream integration WP whenever cross-WP boundaries need joint verification.
3. Assign orthogonal `Risk (S|M|H)`, `Difficulty (C1–C5)`, `Shape`, `Size (XS|S|M|L)`, `Rhythm (可断点|建议连续)`, and explicit review gate (`S` + no explicit review = none; `M` = independent review; `H` = independent review + post-repair verification).
4. Write `.ai/relay/<change-id>/board.md` with `Global Constraints`, `Repo & Diff Scope`, `Interfaces`, `Deferred / Handoff`, and `Done & Verify`. Preserve existing cumulative verdicts/failure signatures if re-planning unfinished acceptance. Then write `.ai/relay/CURRENT`.
5. End with the five-line Next Step body from the rules (`Primary`, `Command`, `Axes`, `Gate`, `Alternate`). `Command` is one ready `do <change-id> <WP-XX>`. `Alternate` is another ready WP or `none`. Do not start `do`.

## Mode: `do <change-id> <WP-XX>`
Shorthand `do <WP-XX>` uses Target lock. A fix also reads the latest unresolved `BLOCKER`s and any recorded `(a)` scope.
1. Check `board.md` (and `wp-XX.md` checkpoint if resuming). Mirror any newer change-level verdict for these acceptance items into the ledger row and WP table status first (RULES §7.3). Work continuously within WP scope and `Global Constraints`; run required checks and simplify diff. If a change-level report blocks this same acceptance (RULES §7.3), stop with `Command: Wait`.
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

## Mode: `review proposal [<change-id>]` / `review change [<change-id>]`
1. Echo `Change: <change-id>` after Target lock. Read `openspec/changes/<id>/` (`proposal.md`, `design.md`, `specs/`, `tasks.md`) and related code or specs read-only. For `change`, also review the complete change diff, OpenSpec compliance, docs, and evidence. Read `board.md` for inherited same-acceptance history (RULES §7.3).
2. Output ≤50 lines per round: verdict (`PASS|FIX REQUIRED`), `BLOCKER`s, `NOTE`s, and `⚠️ Cannot verify`. Append as `## Round N` to `review-proposal.md` or `review-change.md`. Round 2 checks Round 1 `BLOCKER`s plus fix-scope regressions; an unresolved Round 2, or two identical failure signatures, → `[~] blocked` (`failure_class: product|harness`).
3. Write only the report and CURRENT per Target lock. Never edit `board.md`, OpenSpec, product, config, or tests, even after `FIX REQUIRED` or an in-session `(a)`; record it and stop.
4. Five-line card: in-budget `FIX REQUIRED` or recorded `(a)` → `Command: fix proposal <change-id>` (`fix change` for `review change`); unauthorized or inherited `[~] blocked` → `Command: Wait`; `PASS` → proposal: `plan <change-id>`, change: `none` (owner decides archive, commit, release). `Alternate` is `none`.

## Mode: `fix proposal [<change-id>]`
1. Echo `Change: <change-id>` after Target lock. The anchor is the active change directory; `review-proposal.md` is not required to resolve it. Apply RULES §7.4 admission before any write. A refusal's card names the missing `review proposal <change-id>` command, or `plan <change-id>` after `PASS`, or uses `Wait` for a block.
2. Only after admission, write CURRENT (explicit id or fallback selection; skip only when it already holds this id). Revise only confirmed items under `openspec/changes/<change-id>/*` (never product code). Append `## Revision Feedback (Round N)` to `review-proposal.md`, mapping each finding to a fix or a reasoned rejection.
3. Five-line card: `Primary` is the same unpolluted proposal review session; `Command: review proposal <change-id>`; `Gate` is recheck of blockers and conflicts introduced by revisions; `Alternate` is `none`.

## Mode: `fix change [<change-id>]`
1. Echo `Change: <change-id>` after Target lock. Resolve the anchor and apply RULES §7.4 admission before any write. A refusal's card names `review change <change-id>` when the report is missing, `none` after `PASS`, or uses `Wait` for a block.
2. Only after admission, write CURRENT (explicit id or fallback selection; skip only when it already holds this id). For each confirmed finding, fix the defect within change scope, run targeted checks, update affected docs and `tasks.md` only when mapped acceptance is fully satisfied. Do not write `board.md`; the next WP session mirrors the report verdict. Append `## Revision Feedback (Round N)` with checks and input match. Do not reopen unrelated items, commit, archive, or release.
3. Five-line card: `Primary` is independent change review; `Command: review change <change-id>`; `Gate` is fresh review of fixed defects and regression surface; `Alternate` is `none`.

MIT License: Copyright (c) 2026 calvinfungcn and EngRelay contributors (see `docs/engrelay/LICENSE`).
