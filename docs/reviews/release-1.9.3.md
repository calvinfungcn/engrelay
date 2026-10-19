# v1.9.3 release evidence

Date: 2026-10-19

## Source and package

- Product source commit: `19ef810acb87d843f4570c482ff5af7db64e8cf8`.
- The clean `git archive` export was inventoried with the staging copy of
  `scripts/update-snapshot.ps1 -Version 1.9.3 -ForRelease`.
- The inventory contains 65 files and 973,731 bytes; the complete package has
  66 files including `snapshot.json`.
- Candidate snapshot SHA256:
  `9208713ae963f4b7c070d41efc4a0c311f4b66e8f9b22e121810e1b8c6827df5`.
- The independent release audit read every inventory entry and matched its
  path, size and SHA256 to the candidate and to raw bytes from the source commit.
  It found no missing or additional package files.
- The six paired README, development and operator documents passed 70 local-file
  link checks, including 24 anchor checks. MIT and both third-party notice
  editions match the source commit. A bounded credential/private-path scan found
  no matches; this is not an exhaustive secret scan.

The source commit contains canonical contracts, templates, Skills, validator and
tests; paired release documentation and version expectations; the synchronized
main specification, archived proposal and formal review history. This evidence
record is source-only. The final snapshot is committed separately after the
candidate audit; a fresh export must match the candidate before publication.

Private `.ai` evidence, authorization notes, fixtures, raw logs, installation
backups, downloaded archives, distribution files, host settings and graph caches
remain outside Git and the installation package. Existing ignore rules suffice.
No additional redaction or license change was required for the selected files.

## Package and upgrade fixtures

Both Windows PowerShell 5.1 and PowerShell 7 ran the candidate's
`scripts/test-public-package.ps1` with exit 0 and the snapshot hash above.
`new-install-status-doctor-uninstall` and
`owned-file-drift-zero-write-refusal` passed. The frozen v1.6.1 case was explicitly
skipped because that historical package was not supplied.

The official v1.9.2 ZIP used as the previous package had SHA256
`93e5758627c12a50e68a1141ed84b267ee8312970574c9f1e348b13b7e9f7c18`,
matching the published checksum. A disposable upgrade fixture on each host
passed v1.9.2 to v1.9.3 upgrade and uninstall checks. The fixtures checked the
`agents` SkillTarget and `optional` mode, original AGENTS.md backup retention,
all seven canonical and discovery Skill hashes, the response-handoff template,
project sentinels and an outside AGENTS.md edit. A modified discovery Skill
caused uninstall exit 1 with the expected path diagnostic and preserved the
edit; after restoring that owned file, uninstall succeeded and preserved project
content. Both fixture roots were removed. No real project was upgraded.

| Retained ignored input or log | SHA256 |
| --- | --- |
| Public package, Windows PowerShell 5.1 | `dd8fd28c812cbeda55b380d51d3d843f42cbea56bdc3f0f2714a5cdf1a52c0c9` |
| Public package, PowerShell 7 | `9e82e0790a143954b0fe1613e319b1b5768d5e2498dcdcf88e7a40d31da311a4` |
| v1.9.2 upgrade fixture, Windows PowerShell 5.1 | `c62b597d073ac1401d433945d369065866fe3662ae119aabac294159abc51b78` |
| v1.9.2 upgrade fixture, PowerShell 7 | `5e56e4d2eaa527f92f05814ceef723f6d0b2155973e44c31ef249b478919d93d` |
| One-time upgrade harness | `376fd70a1c0a9694a52ff80fcf88595769f41a3e7476b9dc98e708ef893e9c5c` |

The independent release auditor read the harness and checked that these
assertions precede its PASS result. Hashes identify retained bytes; they do not
authenticate logs or their source.

## Protocol evidence and archive

The [final independent review](fix-handoff-persistence/2026-10-19-round-04.md)
closed the batch as ordinary `accepted`, cumulative review count 4 under the
recorded finite authorization. All nine [archived tasks](../../openspec/changes/archive/2026-10-19-fix-handoff-persistence/tasks.md)
are complete. The four original review reports remain unchanged; archive and
release preparation introduce no new product verdict or count reset.

The review's Windows PowerShell 5.1 and PowerShell 7 evidence covers 262 full
validator cases per host. Pre-release status verification reran 33 expected-state
cases and 43 recovery-protocol checks on each host. Reused full-suite evidence
matches the unchanged validator and test bytes:

| Input | SHA256 |
| --- | --- |
| Validator | `0deb5c616cbfb2dc038b0f7a157cb5ee910b25bf4de10c859a8a9aecc286e6bd` |
| Validator tests | `10fe8deebca81c371ca94637aec8da82a496a9f20787056e81cda98e1e5077f4` |
| Handoff schema | `398a3239e8459c37c74efb928f2326b83cffde847632c6c58c72e236dd3d48f2` |

Main-spec strict validation and all seven archived-change strict checks passed.
OBS-01 remains deferred for Task Intake in the [review index](fix-handoff-persistence/index.md#deferred-follow-up)
and paired OpenSpec navigation. Legacy no-fingerprint recovery has static review
only; no dynamic coverage is claimed for that branch.

## Scope and limits

Checks cover the recorded source/package bytes and disposable fixtures. They do
not prove actual agent or host loading/adherence, automatic process wake-up,
unexpected-disconnect zero-loss recovery, natural-language authority, evidence
authenticity, real-project deployment or business acceptance. Multi-file writes
are not atomic transactions. No runtime orchestration engine or global
configuration change is included.
