# EngRelay 1.11.2 release preparation

[Simplified Chinese](release-preparation.zh-CN.md)

Date: 2026-11-17. The owner authorized the relay clarification, complete independent review, necessary repairs, archive, GitHub submission and Release publication.

## Completion and archive

The [archived checklist](../../../openspec/changes/archive/2026-11-17-fix-task-scope-preservation/tasks.md) is complete, 7/7. Original round 03 accepted the batch at related cumulative verdict 6. The separately recorded [complete pre-release review](2026-11-17-pre-release-review.md) passed, including the additional manual relay clarification, with advisory delivery quality 5/5 and related cumulative verdict 7. The original accepted closure and failed reviews remain unchanged.

The main specification preserves all 12 prior routing scenarios and adds four routing scenarios plus seven source-grounded scope scenarios. Main-spec strict validation passed 2/2; archived strict validation passed 20/20. All five change artifacts, including `.openspec.yaml`, are archived. Original round 01–03 files retain their pre-archive SHA256 values. No active change remains.

## Submission and privacy

Commit canonical Full contracts, paired README/operator guides/changelogs, source-only proposal/review archives and navigation, synchronized main specifications, version metadata and the validated release snapshot. README release links, development baselines, OpenSpec baseline, snapshot-generator default and public smoke expectations agree on 1.11.2. Script changes update version literals only.

Keep `.ai/`, generated host Skills, `.agents/`, `.codex/`, tool caches, original project material, raw logs and fixture/installation backups ignored. A content scan of changed public files found no common high-confidence credential patterns or private source-project paths; no additional redaction was required. These heuristics are not exhaustive. Private fixture evidence is referenced, never bundled. MIT and third-party notices remain unchanged.

## Candidate and actual checks

The candidate was exported with `git archive` from source commit `030c1a2c39b39fbff60102d9cb51fc7fed06ba5b`. Its staging copy of `update-snapshot.ps1 -Version 1.11.2 -ForRelease` produced 78 entries, excluding snapshot.json itself, totaling 1,279,786 bytes. Snapshot SHA256: `C37F378A44D0EE63432992C2EF724E15983441C45AC3FA20DA6490E4ABF71D2A`.

| Check | Observed result |
| --- | --- |
| Exact inventory and export exclusions | File set, byte lengths and SHA256 match; private/tool directories, OpenSpec, source reviews and the source-only example are absent. |
| Public smoke, PowerShell 7.6.10 and Windows PowerShell 5.1.26100.9818 | Each exits 0 with seven lifecycle calls covering install/status/version/doctor/uninstall and zero-write drift refusal. The optional frozen 1.6.1 fixture is explicitly skipped. |
| Protected 1.11.1 to 1.11.2 upgrade, both hosts | Each exits 0 with 20 real lifecycle calls and 209 inventory/preservation assertions across Full and Lite. The old package is an exact inventory-verified export of local tag v1.11.1. |
| Deployed Full guidance | All ten affected canonical Full files, generated start/continue Skills and the managed relay rule match the candidate bytes. |
| Ownership protection | Profile, SkillTarget, mode, outside managed-block text, project evidence and Lite configuration/runtime survive upgrade and uninstall. Doctors are read-only; repeated upgrade passes; drift refuses with zero writes. Disposable fixtures are removed. |
| Reused implementation evidence | The complete independent review matched 42 input-hash checks and 22 existing dual-host structural runs. The unchanged validator suites were not rerun for this guidance patch. |

Raw lifecycle logs remain outside the package and Git. The validated staging snapshot is copied back as release metadata; a fresh final commit export must match it before publication. Release assets are a ZIP with one `engrelay-1.11.2` root and a separate `SHA256SUMS` file.

## Limits

This patch clarifies Full task scope and manual handoff guidance. Lite behavior, manager/validator logic, machine fields and deployment paths are unchanged. Fixture and structural checks do not establish consistent model adherence, host loading, business acceptance or token savings. No real project is installed or deployed. The published GitHub tag and Release determine publication status. Archive and release checks add no technical verdict or repair allowance.
