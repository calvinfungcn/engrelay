# EngRelay 2.0.0 release preparation

[Simplified Chinese](release-preparation.zh-CN.md)

Date: 2026-11-24. Change: `introduce-engrelay-v2-workflow`.

## Completion and archive

All 10 tasks are complete. [Independent implementation review](2026-11-24-round-01.md) is **PASS**, with advisory quality **5/5** and no findings. Earlier local reproduction results and fictional drills are retained as evidence, not recounted as formal verdicts. A bounded independent release-document and inventory check also passed without adding a product review round.

The change is archived at `openspec/changes/archive/2026-11-24-introduce-engrelay-v2-workflow/`, preserving `.openspec.yaml` and all artifacts. Main specs contain 10 new v2 requirements and four workflow-profile modifications. Strict validation passed for 3/3 main specs and 22/22 archived changes; no active change remains. The archived task's relative drill link was adjusted after the move.

## Version and compatibility

Release **2.0.0** marks the breaking fresh-install default: an omitted `WorkflowProfile` selects v2. Existing Full/Lite installations retain their profile on upgrade. Defaults remain `WorkflowMode=optional` and `SkillTarget=none`. Upgrade, repeated Install and SetMode do not switch profiles; a requested switch uses protected uninstall/reinstall, preserving project evidence and coordinating project instructions. Unfinished work is not automatically migrated.

Both README, CHANGELOG, development and quickstart editions were checked together. Current version references, download names, OpenSpec context, smoke expectations and the snapshot script default are 2.0.0. The historical 1.10.2 quickstart example remains an explicitly Full offline-package example. Shared rhythm enum values are explained in English without changing protocol identifiers.

## Exact candidate checks

The candidate was exported with `git archive` from reviewed source commit `3b2b55e`, then its staging copy generated the release snapshot. No package was installed into the source checkout or a real project.

| Check | Actual result | Scope |
| --- | --- | --- |
| Inventory | 89 tracked inventory files plus snapshot; all sizes and SHA256 values match | No private runtime/tool paths, OpenSpec archive or source Review files in installation export |
| `test-v2-workflow.ps1` | PASS on Windows PowerShell 5.1.26100.9818 and PowerShell 7.6.10; each 37 calls / 34 checks / 0 failures | Default v2, protected legacy profiles, Skill copies, config/runtime preservation, doctor read-only behavior, line-count boundaries and snapshot completeness |
| `test-public-package.ps1` | PASS on both hosts; each 7 calls, 2 passing cases, 1 skipped historical case, exit 0 | Explicit Full lifecycle and zero-write drift refusal; frozen v1.6.1 not supplied |
| Exact v1.11.3 to v2.0.0 upgrade | PASS on PowerShell 7.6.10; 16 lifecycle calls / 47 assertions | Full/Lite profile, target and mode retention; matching installed bytes, generated Full Skills, read-only status/version/doctor, repeat upgrade, drift refusal and project-content preservation on uninstall |
| Release metadata and privacy | PASS, including independent read-only check | Bilingual consistency, local links, archived task link, version expectations, filename/path and credential-pattern scan |

Candidate snapshot SHA256: `0e213d5475dfd87dfb3ba8902e0596747eef10344a2c1b5c7ba0903f59bfd8d2`. Inventory byte total: 1,375,193. The previous v1.11.3 upgrade input was an exact clean tag export, snapshot SHA256 `be2700101c954c59675f841f968cb004d58bb0286a11729dedd8c38a941bae72`.

The matching input manifest and earlier lifecycle evidence support focused reuse: the product review matched 72 payload/script files before version-only preparation. Existing profile tests report 83 calls / 32 checks on both hosts, human-document lifecycle five cases on both hosts, and Lite state 121 cases on Windows PowerShell 5.1. These are prior matching-scope results, not additional runs on the final candidate. The discovery test's synthetic 1.8.0 baseline does not establish authentic historical-binary compatibility.

## Commit contents and privacy

Commit product source, scripts and focused tests; paired public documentation and changelogs; version metadata and the staging-generated snapshot; main specs and archived proposal/design/tasks/deltas; redacted review, drill and release summaries. Source-only OpenSpec and Review records stay in Git but are excluded from installation exports by `.gitattributes`.

Do not commit `.ai/` runtime, raw logs, candidate/previous packages, local helpers, generated host Skills, credentials or private caches. Existing ignore rules cover those paths. Changed public files had no matches in the applied private-user/business-path and token/private-key heuristics; this is a bounded scan, not a guarantee that every possible secret format is detected. Third-party notices and original MIT licensing remain present.

Raw candidate/check evidence stays in the ignored local release directory. The final release metadata commit carries this tested snapshot; a fresh final-commit export must match the tested package file for file before publication. The downloadable ZIP is published together with `SHA256SUMS`.

## Limits

No actual external Codex/Cursor/Claude loading, real multi-platform quota switching, token savings or business acceptance is claimed. Frozen v1.6.1 and the original v1.9.6 conversion checks were not repeated. Independent sessions and fictional drills do not prove all hosts obey the protocol. These limits do not change the recorded passing package checks.
