# WP-XX: <Title>

## Execution Summary (<= 60 lines)

- **Exit status**: `DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED`
- **Producer**: `<platform / model family & session>`
- **Risk check**: `<unchanged: S|M|H | escalated to M|H (reason)>`
- **Repo & Diff Scope**: `<repo(s), commit base..head or staged/unstaged/untracked WP files>`
- **Changes**: `<concise file/behavior summary>`
- **Checks & Input Match**: `<exact command, result, and confirmation that inputs match current scope>`
- **Known limits / Concerns**: `<none or concrete item>`

## Checkpoint (optional, <= 15 lines; quota/session pause only)

- **At**: `<YYYY-MM-DD, platform/model>`
- **Done**: `<verified sub-steps>`
- **Remaining**: `<exact remaining work>`
- **Traps / Next**: `<environment notes + exact starting point for resumed do>`

## Review / Verification (<= 50 lines per round; max 2 rounds)

### Round 1
- **Reviewer**: `<tool/model (independent of producer/fixer; heterogeneous preferred)>`
- **Verdict**: `PASS | FIX REQUIRED`
- **BLOCKER**: `<none or P0/P1 real defect with file:line & impact>`
- **NOTE**: `<non-blocking suggestion>`
- **Cannot verify from diff (`⚠️`)**: `<none or item + named downstream WP in board.md>`

### Round 2 (if Round 1 had BLOCKERs)
- **Reviewer**: `<independent tool/model>`
- **Verdict**: `PASS | BLOCKED` (checks Round 1 BLOCKERs + fix-scope real regressions; no NOTE escalation)
- **Outcome / Failure class**: `<if unresolved or 2x same signature -> [~] blocked; failure_class: product|harness; 3 owner options>`
- **Recovery / Owner disposition**: `<harness resume evidence | bounded extra cycle | deferred | owner-limited acceptance (never marked as technical pass)>`
