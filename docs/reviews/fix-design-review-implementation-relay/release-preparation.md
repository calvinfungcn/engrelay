# EngRelay 1.11.1 release preparation

[Simplified Chinese](release-preparation.zh-CN.md)

Date: 2026-11-17. The owner requested a complete review, archive, GitHub submission and Release publication. This record covers archive and release preparation; it adds no technical verdict or repair allowance.

## Completion and archive

All five items in the [archived checklist](../../../openspec/changes/archive/2026-11-17-fix-design-review-implementation-relay/tasks.md) are complete. [Round 03](2026-11-17-round-03.md) passed at the original batch's cumulative verdict 3. The separately authorized [post-closure complete review](2026-11-17-post-closure-review.md) also passed, with advisory delivery quality 4/5; it preserves the original accepted closure, counts and failed reviews.

The two modified requirements were synchronized into the main collaboration specification, preserving all 11 prior scenarios and adding nine. Main-spec strict validation passed 2/2; archived strict validation passed 19/19. The archive retains all five artifacts, including `.openspec.yaml`; the review index points to archived tasks. Historical round 01–03 files retain their pre-archive SHA256 values. There is no active change remaining.

## Submission and privacy

Commit the canonical Full guidance, paired README/operator guides/changelogs, source-only archive and review records, synchronized specifications and navigation, version metadata and the release snapshot. Current README downloads, development baselines, OpenSpec baseline, smoke expectations and snapshot-generator default are coordinated at 1.11.1. Release-script edits change version literals only.

Keep `.ai/`, generated host Skills, `.agents/`, `.codex/`, tool caches, raw logs, fixture exports and installation backups ignored. Staged content scans found no common credential patterns or private source-project paths; no additional redaction was needed. These heuristics are not exhaustive. Private fixture evidence is referenced for traceability and is not included in Git or installation packages. MIT and third-party notices are unchanged.

## Candidate and checks

The clean candidate comes from `git archive` of source commit `e7943f51d575294724c55fdc5aac5bcbca67d984`. The staging copy of `update-snapshot.ps1 -Version 1.11.1 -ForRelease` produced 78 inventory entries, excluding snapshot.json itself, totaling 1,264,898 bytes. Snapshot SHA256: `7C003341AAD98C0ECD761FE655AA1140407A50CC0C68F633E95BF3F2B0FC1122`.

| Check | Observed result |
| --- | --- |
| Exact inventory and export exclusions | File set, byte lengths and SHA256 match; private/tool directories, OpenSpec, reviews and the source-only example are absent. |
| Public smoke, PowerShell 7.6.10 and Windows PowerShell 5.1.26100.9818 | Each exits 0: seven lifecycle calls cover Full install/status/version/doctor/uninstall and zero-write drift refusal. The optional frozen 1.6.1 case is explicitly skipped. |
| Protected 1.11.0 to 1.11.1 upgrade, both hosts | Each passes 20 real lifecycle calls and 209 inventory/preservation assertions across Full and Lite. The old package is an exact verified export of local tag v1.11.0. |
| Changed Full deployment | All ten changed canonical Full files, generated start/continue Skills and the managed relay rule are installed from matching candidate bytes. |
| Protection and preservation | Profile, SkillTarget, mode, outside managed-block text, project evidence and Lite configuration/runtime are retained. Both doctors are read-only; repeated upgrade passes; drift refuses with zero writes; uninstall preserves project-owned content. Disposable upgrade fixtures are removed. |
| Reused implementation evidence | The independent complete review matched all 12 scenario input hashes and the existing 16 dual-host structural runs. Unchanged validator suites are not rerun for a guidance patch. |

Bounded independent preparation verification matched the archive, paired version metadata, these records and the actual lifecycle logs; it found no discrepancy and added no technical verdict.

Logs remain outside the package and Git. The validated staging snapshot is copied back as source release metadata; a fresh final commit export must match that inventory before publication. The release assets are a ZIP with one `engrelay-1.11.1` root and a separate `SHA256SUMS` file.

## Limits

This patch coordinates Full's design-to-implementation guidance. Lite behavior, manager and validator logic, deployment paths and machine fields are unchanged; Upgrade retains the selected profile. Fixture and structural checks do not prove consistent model adherence, host loading, business acceptance or token savings. No real project was installed or deployed. The GitHub tag and published Release are the authority for publication status.
