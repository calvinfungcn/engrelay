# EngRelay 2.0.1 release preparation

[简体中文](release-preparation.zh-CN.md)

Date: 2026-11-25. Change: `refine-v2-relay-ergonomics`.

All six tasks are complete. The [review summary](2026-11-25-review.md) preserves the initial I1 output-contract finding, its subsequent targeted independent PASS, and the advisory 4/5 rating. Release checks do not reset that history or add a product review verdict. The latest `Command: none` clarification and non-recursive `[IO.Directory]::Delete` junction cleanup are included in the reviewed release inputs.

## Archive and source checks

- `openspec validate refine-v2-relay-ergonomics --strict`: `Change 'refine-v2-relay-ergonomics' is valid`.
- `openspec archive refine-v2-relay-ergonomics --yes --json`: synchronized one added and two modified requirements, then archived to `openspec/changes/archive/2026-11-25-refine-v2-relay-ergonomics/`, preserving all artifacts and `.openspec.yaml`.
- `openspec list`: `No active changes found.`
- `openspec validate --all --strict`: `Totals: 3 passed, 0 failed (3 items)`.
- `openspec validate --archived --strict`: 23/23 passed.
- Main v2 spec matches the delta. Changed Markdown local links and `git diff --check` passed. The public smoke script's three version expectations and snapshot default are 2.0.1; bilingual current release metadata uses 2026-11-25.

## Clean candidate results

Commit 1: `de1c712c17c9d4dcc102a9c12c851e514e114421`. A clean `git archive HEAD` export was created in a new GUID directory under the system temporary directory. Only its staging copy ran `update-snapshot.ps1 -Version 2.0.1 -ForRelease`. Separate byte-identical package copies were used for each host; suites ran sequentially within each copy because profile tests temporarily remove a source file. Logs were outside the package in a separate temporary directory.

| Suite | Windows PowerShell 5.1.26100.9818 | PowerShell 7.6.10 |
| --- | --- | --- |
| `test-v2-workflow.ps1` | PASS: 47 calls / 44 checks, exit 0 | PASS: 47 calls / 44 checks, exit 0 |
| `test-workflow-profiles.ps1` | PASS: 83 calls / 32 checks, exit 0 | PASS: 83 calls / 32 checks, exit 0 |
| `test-public-package.ps1` | PASS: 7 calls, 2 passing cases / 1 historical skip, exit 0 | PASS: 7 calls, 2 passing cases / 1 historical skip, exit 0 |

These are actual final-candidate runs with the committed scripts, including the junction cleanup revision; they are not the earlier adapted staging tests. Each host's package inventory remained unchanged after all suites. The frozen v1.6.1 case and original v1.9.6 conversion input were not supplied. Synthetic Adopt checks are not proof of historical-binary compatibility.

Snapshot SHA256: `436998b2d1a7bac0e1cb4460103ad3d17898643b140e338ed3e518b1bf4287ec`. The snapshot inventories 89 files totaling 1,393,232 bytes; the complete package contains 90 files including snapshot. Every file size/hash and the exact set were checked; source-only OpenSpec/Review and private runtime/tool directories were excluded. The tested snapshot is copied back for commit 2; the staged-tree and final HEAD archives are compared with the tested candidate before publication. The ZIP and `SHA256SUMS` use the final HEAD, and uploaded assets are downloaded again for hash comparison.

## Privacy and limits

New archive background and drill records were redacted to remove workstation paths and real private business project names. Original `.ai/` review/log inputs stay ignored; only summaries and fictional fixtures are tracked. Changed public files were scanned for private user/business paths, credentials, tokens and private keys. No remaining matches were found in the applied patterns. This is a bounded scan, not a claim of exhaustive secret detection. Original v2 material remains MIT; no new third-party text was imported, and `LICENSE` and `THIRD-PARTY-NOTICES*` were preserved. Generated Skills, graph caches, backups and package artifacts are excluded from Git.

No package was installed into this source checkout or a real project. External Codex/Cursor/Claude loading, real quota switching, token savings and universal agent compliance remain unverified. Temporary build, test-log and downloaded artifact directories are removed after final integrity checks; private evidence copies remain only under ignored local `.ai/`.
