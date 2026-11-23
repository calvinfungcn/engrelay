# EngRelay 1.11.3 release preparation

[Simplified Chinese](release-preparation.zh-CN.md)

Date: 2026-11-23. The owner explicitly authorized full independent review, necessary repairs, archive, GitHub submission and Release publication.

## Completion and archive

The [archived checklist](../../../openspec/changes/archive/2026-11-23-improve-review-readiness-and-convergence/tasks.md) is complete, 6/6. The original round 03 accepted closure remains intact. The [complete independent pre-release review](2026-11-23-round-04.md) passed with advisory delivery quality 5/5 and related cumulative verdict 4. No additional product repair was required.

Both existing main specifications retain their previous content and Purpose. Four Full requirements and one Lite requirement were added from the exact archived deltas. Main-spec strict validation passed 2/2, archived validation passed 21/21, all six change files including `.openspec.yaml` are archived, and no active change remains. Reviews keep their original paths and verdict chronology.

## Submission and privacy

Commit canonical Full/Lite guidance, paired README/operator guides/changelogs, synchronized main specifications, the source-only change and review archive/navigation, release version references and the validated snapshot. README download examples, development/OpenSpec baselines, snapshot-generator default and public smoke expectations agree on 1.11.3. The two executable scripts change version literals only. The independent release-preflight agent checked this delivery metadata and the selected relative Markdown links without finding a blocker.

Keep `.ai/`, generated host tooling, `.agents/`, `.codex/`, tool caches, raw logs, temporary fixtures and installation backups out of Git. The changed public files had no common credential-assignment or private business-source-path hits. Workstation-specific CLI/source/temp locations in round 01 and 03 were neutralized while preserving findings, verdicts, counters, command arguments and evidence hashes; originals remain in ignored local evidence. These scans are heuristic. MIT and third-party notices remain applicable.

## Candidate and observed checks

The clean candidate came from `git archive` of source commit `6bf3e1a1dc4a91f3ae78df66c2246af31e037b81`. Its staging copy of `update-snapshot.ps1 -Version 1.11.3 -ForRelease` produced 78 entries excluding snapshot.json, totaling 1,315,587 bytes. Snapshot SHA256: `BE2700101C954C59675F841F968CB004D58BB0286A11729DEDD8C38A941BAE72`.

| Check | Observed result |
| --- | --- |
| Exact package inventory | Paths, byte lengths and SHA256 match. Private/tool trees, OpenSpec, source reviews and the source-only example are absent. |
| Public smoke, PowerShell 7.6.10 and Windows PowerShell 5.1.26100.9818 | Both exit 0; seven lifecycle calls each cover install/status/version/doctor/uninstall and zero-write drift refusal. The optional frozen 1.6.1 fixture was skipped explicitly. |
| Protected 1.11.2 to 1.11.3 upgrade, both hosts | Both exit 0; 16 real calls and 47 assertions each cover Full/Lite, updated guidance and generated Codex Skills, preserved profile/target/mode, project configuration/evidence/outside entry text, read-only status/version/doctors, repeated upgrade, zero-write drift refusal and uninstall. Both roots were fictional disposable directories and were removed. |
| Historical human-document addition fixture | The stock `preexisting-same-bytes-preserved` case failed on both hosts because it overwrote an old manifest-owned guide with changed candidate bytes. This manufactured drift; the manager correctly refused. The fixture assumes that guide was previously unowned and is not applicable to this version pair. The protected transition checks above replaced it; neither product code nor ownership checks were weakened. |
| Independent contract review and metadata checks | Full implementation and mapped acceptance passed; bounded delivery checks confirmed additive archive sync, version literals and selected links. |

Raw logs and the executed one-off transition script remain outside Git/package, with their actual input fingerprints. A later local cleanup collision guard does not change the executed product-check sequence; the original executed script is retained. Copy back only the validated generated snapshot, then re-export the final commit and require the exact same inventory and snapshot before publication. Assets use one `engrelay-1.11.3` ZIP root plus a separate `SHA256SUMS`.

| Private evidence | SHA256 |
| --- | --- |
| Public smoke, PowerShell 7 | C46DB1590F2C40963AE24B9D980BD60877CF405394918C24133E6A095797E919 |
| Public smoke, Windows PowerShell 5.1 | A016DCB558DF44C6F6F65A3A556DD97408570DACFF8A5AF8AAC43090E60DD3D8 |
| Protected upgrade, PowerShell 7 | 77AFAA035054C269FCBFEE1E01E9D3D7F0E0BE58E808BDFE3BD0F68325C57DAD |
| Protected upgrade, Windows PowerShell 5.1 | C3E9777F3FA8D9F1F0ED6F722C0350AB24499530F17D0FE2ACE35A09C5F1D3F9 |

## Limits

These checks establish the reviewed text contract and the observed disposable package lifecycle. They do not prove actual host loading/adherence, runtime token savings, all platform behavior, real-project installation or business acceptance. No real project was installed or deployed.
