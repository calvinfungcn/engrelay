# EngRelay v1.8.0 release checks

Recorded on: 2026-10-16. Package version: 1.8.0.

## Inputs and scope

- Candidate source commit: `ca297a7c735dcd13461402ae541cf65198f0396c`, exported with git archive into a disposable staging directory.
- Candidate inventory: 63 entries plus snapshot.json; the staging snapshot was generated with `-Version 1.8.0 -ForRelease`.
- Candidate snapshot SHA256: `0d66028d02a4e1f1df3d716b27ea04ec8f6479e93735c491a977bc7ca7a04af8`.
- Historical inputs were clean git archive exports of immutable public tags v1.7.0 and v1.7.1. Their complete inventories were checked without refreshing either old snapshot.
- v1.7.0 snapshot SHA256: `f5c4085549cb2b983e98076021c6799419acf31ddf53d7ede472d721d2ff9612`.
- v1.7.1 snapshot SHA256: `16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743`.
- The completed OpenSpec change is archived. Its four delta requirements match the main specification, its ten unrelated requirements and Purpose are preserved, and the four original Review rounds remain unchanged. The cumulative review count remains four; these release checks do not create another verdict.
- The lifecycle script SHA256 remains `53d6bdf407f9080664ae4e6de1e8b375417ab184c67dbe3154de93259d2fca3c`, matching the accepted final Review.

## Results

| Check | Host | Result |
| --- | --- | --- |
| Human-document lifecycle, v1.7.1 / none | PowerShell 7.6.6 | 5/5 PASS |
| Human-document lifecycle, v1.7.1 / agents | Windows PowerShell 5.1 | 5/5 PASS |
| Human-document lifecycle, v1.7.0 / codex | PowerShell 7.6.6 | 5/5 PASS |
| Install/status/version/doctor/uninstall and drift refusal | PowerShell 7.6.6 | 2/2 PASS |
| Install/status/version/doctor/uninstall and drift refusal | Windows PowerShell 5.1 | 2/2 PASS |

Each lifecycle run covers upgrade, fresh installation, preservation of identical preexisting documents, refusal of conflicting documents before writes, and refusal of managed-content drift before writes. The checks use GUID-named disposable projects and explicit complete previous-package roots, with logs outside all input packages. The v1.7.0 run's unused `previousGitRef` log field retains its default; the explicit input and snapshot hash identify the actual previous package.

The optional frozen v1.6.1 case was skipped once per host because that separate fixture was not supplied: 19 PASS, 2 SKIP, 0 FAIL overall. No new v1.6.1 compatibility result is claimed.

OpenSpec strict main-spec validation, delta synchronization comparison, whitespace checks and staged-path privacy checks passed. Prior independent Review evidence remains applicable to unchanged product contracts; live Agent/host behavior was not inferred from these fixtures.

## Evidence hashes

Raw logs remain local and outside Git and the package.

| Log | SHA256 |
| --- | --- |
| lifecycle-170-codex-ps7.txt | `751fe5989abbf32a168b21933490ce30758b0b80d46b2df63a8b0232f0d76399` |
| lifecycle-171-agents-ps5.txt | `425be21f30374bff7e106a2f037c2b087d3407fc43e213eae4ba1643407ac6d7` |
| lifecycle-171-none-ps7.txt | `a56fa3ebb58cbd9e7a4abc7ee2f75497f56ac95f6c78a9715d1de8369bb89604` |
| public-package-ps5.txt | `0cfa8ff8e9aa83557babcf022bac906e4b2ebc30967a8158572924cedf7f8eac` |
| public-package-ps7.txt | `eb9b8960111bd6841904a2db2bd4a9bf0365259d308cc14d0cf071b6f17f1b93` |

## Release boundary

The final metadata commit records the tested staging snapshot and this source-only report. Its fresh export must match the tested candidate byte for byte before upload. OpenSpec and Review archives stay in Git but are excluded from the complete installation ZIP. Local runtime, credentials, host copies, caches and raw logs remain ignored.

The complete ZIP and SHA256SUMS are release assets. Historical tags and assets are preserved. File/inventory checks and pattern scans have a bounded scope; they do not establish live Agent behavior, host loading, real-project deployment, business acceptance, or the absence of every possible secret format. C1–C5 handoff capability guidance remains a separate requirement outside v1.8.0.
