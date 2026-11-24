# EngRelay v2 Rules

Activate ONLY when the current task explicitly selects `EngRelay` (or `WorkflowMode: default` without another controller). Discovery, `.ai/relay/`, or historical files never activate it. Use one primary controller per task; never load the legacy `full` handbook or `validate-runtime-state.ps1`. OpenSpec (`proposal`, `design`, `specs`, `tasks.md`) is the sole requirement/task authority. Optional `docs/engrelay.config.md` supplies project commands and quota notes; blank entries never block planning and never waive required acceptance.

## 1. Risk, Difficulty, and Sizing Axes (Orthogonal)

- **Risk (`S|M|H`) + explicit review requirement** SOLELY govern review/verification gates (`C1–C5` never triggers review alone):
  - **Empty gate** (Risk `S` and no explicit user/project review requirement): implementer self-checks pass → close directly.
  - **M**: requires independent code review and independent confirmation of `BLOCKER` fixes.
  - **H** (auth, security, money, data integrity, cross-system contracts, migrations, release gates): requires independent code review AND independent post-repair verification (both executed in independent `review` mode; matching unchanged evidence may be reused).
- **Independence**: Reviewer/verifier MUST be an independent session from the implementer and fixer (no self-review; no self-verification of required `H` acceptance). Prefer a different model family; when unavailable, a genuinely independent same-family session MAY run `review` and MUST record its actual tool/model. Switching model family alone never proves independence.
- **Difficulty (`C1–C5`) & Workload (`XS|S|M|L` × `可断点|建议连续`)** guide platform/model/reset-window selection only (`XS`: 1–2 files; `S`: 3–5 files; `M`: 5–10 files or build/local-DB checks; `L`: dense single-window ceiling). Scope exceeding `L` MUST be split.

## 2. `plan` Mode (OpenSpec Orchestrator)

1. Read the active OpenSpec change (`proposal`, `design`, `specs`, `tasks.md`) and run one `docs/solutions/` lookup for matching pitfalls.
2. Slice into independently verifiable Work Packages (`WP-01..N`). Split ONLY where a reviewer can meaningfully reject one WP while approving its neighbor; fold config/tests/docs into the delivering WP. Never emit DTO-level micro-WPs or unclosable multi-repo monoliths.
3. Write `.ai/relay/<change-id>/board.md` containing:
   - `Global Constraints`: cross-WP hard invariants (exact field/column names, feature-flag defaults, forbidden actions).
   - WP table: `WP | Module | OpenSpec | Risk | Difficulty | Size/Rhythm | Review Gate | Deps | Status | Owner/Reviewer`.
   - Per-WP block: `Shape` (`ui|backend|concurrency|integration|docs|ops`), `Repo & Diff Scope` (affected repo paths, base ref/range or file boundary), `Interfaces` (`Consumes`/`Produces`), `References` (0–2 solution paths), `Deferred / Handoff` (explicit downstream WP for cross-boundary checks), and `Done & Verify`.

## 3. `do` Mode (Platform-Native Execution)

1. Execute continuously inside the assigned WP: resolve local design details, implement, run required checks, and simplify diff.
2. If actual risk exceeds the plan (e.g., `S` touches auth/contracts), immediately update WP risk in `board.md`/`wp-XX.md` and refresh the review gate; NEVER self-close via `DONE_WITH_CONCERNS`.
3. Direct-close (`[x] done`) ONLY when the WP's applicable independent review/verification gate is empty and checks pass.
4. On quota/session pause: append a ≤15-line `Checkpoint` (done / remaining / traps / next step) to `wp-XX.md` so another platform resumes `do` directly without triggering review.
5. On completion: write a ≤60-line summary in `.ai/relay/<change-id>/wp-XX.md` (status `DONE|DONE_WITH_CONCERNS|NEEDS_CONTEXT|BLOCKED`, actual repo/diff scope covering untracked/staged/committed files, commands run and input match, risks). On `BLOCKED`, change strategy (add context/upgrade tier/split/escalate); never blind-retry.

## 4. `review` Mode (Bounded Independent Review & `H` Verification)

1. **Minimal entry & scoped reads**: Start from `board.md` WP entry, `wp-XX.md`, and complete WP change scope (covering multi-repo, untracked, staged, and committed changes while isolating shared-worktree sibling edits). Read authoritative OpenSpec, module `AGENTS.md`, callers, and full source whenever needed to verify spec compliance or trace a concrete risk.
2. **Evidence & triage**: Confirm reused implementer test output matches current reviewed inputs; run targeted checks only for specific doubts or required `H` verification. Output ≤50 lines/round classifying: `BLOCKER` (P0/P1 real bugs, security/money/concurrency/contract/build failures), `NOTE` (non-blocking style/extra-coverage ideas), and `⚠️ Cannot verify from diff`.
3. **Review PASS vs Acceptance Complete**: `⚠️` allows `review PASS` ONLY when it does not block the WP's required acceptance AND maps explicitly to a named downstream WP in `board.md`. Without a downstream owner or when verification environment is unavailable, affected OpenSpec `tasks.md` items and the parent change MUST stay incomplete while independent WPs proceed. Only tick `tasks.md` when mapped acceptance is fully satisfied.

## 5. Circuit Breaker & `[~] blocked` Recovery

1. **Hard 2-round cap**: Round 2 checks Round 1 `BLOCKER`s AND any real `BLOCKER` (new P0/P1, safety, contract, or build failure) in the fix's blast radius; only promoting `NOTE`s to `BLOCKER` is forbidden. Unresolved Round 2 or 2 consecutive identical failure signatures MUST halt immediately as `[~] blocked` (`failure_class: product|harness`), blocking only dependents and presenting 3 owner options (human intervene / defer / accept limits).
2. **Cumulative history**: Verdict count and failure signatures bind to the **unfinished mapped acceptance** in `board.md` `Progress Ledger` — NEVER reset by re-`plan`, splitting, renaming WP ID, or switching platforms.
3. **Recovery**: `harness` blocks resume once verified environment readiness holds. `product`/ceiling blocks require explicit owner choice: (a) finite bounded extra fix+review cycle (retaining history), (b) explicit deferral keeping `tasks.md` unchecked, or (c) distinct owner-limited acceptance (never recorded as technical verification pass).
