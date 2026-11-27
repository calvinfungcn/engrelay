# EngRelay 2.1.0 release preparation

[简体中文](release-preparation.zh-CN.md)

Date: 2026-11-27. Change: `add-v2-change-review-relay`.

All five implementation tasks are complete. The [review summary](index.md) records the final implementation PASS, closure of R1–R4, and the remaining non-blocking first-line `Change:` adherence note. Prior findings and repair feedback remain historical evidence; release preparation adds no implementation verdict and resets no count. Reuse of independent results still requires matching inputs, the same mapped acceptance, and all applicable gates, including H-level independent post-repair verification.

## Archive and source checks

- `openspec validate add-v2-change-review-relay --strict`: `Change 'add-v2-change-review-relay' is valid`.
- `openspec archive add-v2-change-review-relay --yes --json`: archived to `openspec/changes/archive/2026-11-27-add-v2-change-review-relay/`, with `specsUpdated: true`; one added and three modified requirements, none removed or renamed.
- `openspec list`: `No active changes found.`
- `openspec validate --all --strict`: `Totals: 3 passed, 0 failed (3 items)` after archiving.
- The main v2 spec contains all four delta requirement blocks verbatim. The five task boxes remain checked, and new archive/review local Markdown links resolve.
- Current bilingual version metadata, smoke expectations, and the snapshot default are 2.1.0. Historical release sections remain unchanged. The staged privacy scan and `git diff --cached --check` passed after refreshing the staged archive and fixing two Markdown trailing spaces.

## Clean candidate results

Source commit: `53415abc6704a55022025f8881d551a9efd41b9e`. A new GUID directory under `%TEMP%` received `git archive HEAD`. Only the staging copy ran `scripts/update-snapshot.ps1 -PackageRoot <staging-package> -Version 2.1.0 -ForRelease`. Separate byte-identical copies were used for each host; suites ran sequentially inside each copy, with logs outside the package.

| Suite | Windows PowerShell 5.1.26100.9818 | PowerShell 7.6.10 |
| --- | --- | --- |
| `test-v2-workflow.ps1` | PASS: 56 calls / 46 checks, exit 0 | PASS: 57 calls / 46 checks, exit 0 |
| `test-workflow-profiles.ps1` | PASS: 83 calls / 32 checks, exit 0 | PASS: 83 calls / 32 checks, exit 0 |
| `test-public-package.ps1` | PASS: 7 calls, 2 passing cases / 1 historical skip, exit 0 | PASS: 7 calls, 2 passing cases / 1 historical skip, exit 0 |

Windows PowerShell 5.1 explicitly skipped the file-symlink case because the operation requires administrator privilege; PowerShell 7 ran that case, and both hosts ran directory-junction checks. The optional frozen v1.6.1 package and original v1.9.6 input were not supplied. Synthetic adoption and compatibility fixtures do not establish compatibility with every historical package.

Snapshot SHA256: `92c62089b386f542481ab04d2a37a6616250836bc052096ca643237898eb47e5`. It inventories 89 files totaling 1,416,583 bytes; the complete package contains 90 files including `snapshot.json`. Both host copies retained the exact file set, file sizes, hashes, and snapshot bytes after all suites. The tested snapshot is copied back for the release metadata commit; the final-HEAD export must match this same tested inventory before publication.

The final release uses a fresh final-HEAD ZIP and `SHA256SUMS`. Publication verifies downloaded draft assets against their local hashes before making the release public. OpenSpec and source review records are excluded by `.gitattributes`; ignored runtime state, host copies, caches, and backups are not export inputs.

## Privacy and limits

Workstation-specific file URLs were replaced with valid relative links. Raw private review evidence stays ignored; the tracked summary and fictional drill preserve conclusions and limits without importing those files. A bounded scan of changed tracked files checked private user/project paths, known private project names, credential-like token formats, and private-key headers. It found no unresolved matches; the existing documented fictional install path is a placeholder. This is not an exhaustive secret-detection claim. Original v2 material remains MIT; no new third-party text was imported, and license and third-party notice files were preserved.

No package was installed into this source checkout or a real project. Fictional agent drills and automated structure/lifecycle checks do not prove external Codex/Cursor/Claude loading, actual multi-platform quotas, token savings, universal agent compliance, or business acceptance. The existing drill explicitly limits the evidence of reviewer independence. Temporary build/log/download directories are cleaned after publication checks; private evidence copies remain under ignored local `.ai/`.
