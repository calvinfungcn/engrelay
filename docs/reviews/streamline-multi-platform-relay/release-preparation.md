# EngRelay 1.11.0 release preparation

[Simplified Chinese](release-preparation.zh-CN.md)

Date: 2026-11-15. This record covers archive and release checks; it adds no technical verdict or repair allowance.

## Completion and archive

- All 13 tasks are complete in the [archived checklist](../../../openspec/changes/archive/2026-11-15-streamline-multi-platform-relay/tasks.md). [Round 09](2026-11-14-round-09.md) independently verified R08-01 and R08-02 and returned PASS, with advisory delivery quality 5/5.
- The correction batch closed as accepted at related cumulative verdict 5/5. The nine numbered records and earlier phase closures/counts remain historical. No additional complete review was needed: the directly reviewed product inputs still match their recorded SHA256 values.
- Both main specifications were synchronized (3 requirements added, 8 modified). The archived change retains all six files, including OpenSpec metadata. Main-spec strict validation passed 2/2; archived strict validation passed 18/18.

## Submission and privacy

Commit canonical product rules, validators, tests, paired human guides and changelogs, source-only specifications and archived proposal/reviews, and release snapshot metadata. README, development guides, OpenSpec baseline, smoke expectations and snapshot-generator version default are coordinated at 1.11.0.

Keep `.ai/`, generated host Skills, `.codex/`, `.agents/`, tool caches, raw logs, original snapshots and installation backups ignored. Review 05/06 workstation paths were redacted; review 03 trailing whitespace was removed. Original verdicts, counts and historical input hashes were preserved, with redaction notes. Staged whitespace checks passed; heuristic credential and private-path scans found no publishable secrets. These scans are not exhaustive.

## Candidate and checks

The clean candidate comes from `git archive` of source commit `83fc5d200f1ad0dd25f05e730e6539bb9bf40e6c`. Its staging-only `update-snapshot.ps1 -Version 1.11.0 -ForRelease` produced 78 inventory entries, excluding snapshot.json itself, totaling 1,254,530 bytes. Snapshot SHA256: `EC1E8093B7C9B6C5BC9CA6B125BD10FF7A58F5DA758D2BD538103042BCB5551C`.

| Check | Observed result |
| --- | --- |
| Independent inventory comparison | Exact file set, size and SHA256 match; corresponding source bytes match; private/tool directories absent |
| Public smoke, PowerShell 7.6.10 and Windows PowerShell 5.1.26100.9818 | Each exits 0: Full install/status/doctor/uninstall and zero-write drift refusal pass; optional frozen 1.6.1 test explicitly skipped |
| Protected 1.10.4 to 1.11.0 upgrade, both hosts | Each passes 20 real lifecycle calls and 197 inventory/preservation assertions across Full and Lite |
| Upgrade preservation and diagnostics | Profile, SkillTarget, mode, project instructions outside the managed block, project-owned evidence and Lite config/runtime retained; Full discovery Skill and both validators match new package bytes; repeated upgrade succeeds; both doctors are read-only; drift refuses with zero writes; uninstall preserves project content |
| Reused technical checks | Existing Full 274-case result and independent Lite 121-case results on both hosts retained within their input scope; not rerun as release checks |

Private command logs remain outside the package and outside Git. A final clean export must match this candidate, including the copied-back snapshot. The published ZIP is to contain one `engrelay-1.11.0` root and a separate SHA256SUMS asset is to identify its checksum.

## Upgrade impact and limits

1.11.0 changes the former default three-verdict stop: count alone no longer blocks normal authorized work. Explicit finite authorizations still apply, and confirmed repeated lack of progress triggers technical analysis. Upgrade validators, rules and managed entries together; do not mix package versions. Installation and upgrade do not switch profiles.

Fixtures do not prove actual host adherence, reviewer independence, real authentication/data-path acceptance, or token savings. Host loading remains unknown where reported. No real project was installed or deployed. The authoritative publication status is the GitHub tag and Release, not this preparation record.
