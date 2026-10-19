# v1.9.4 release evidence

Date: 2026-10-19

## Source and package

- Product source commit: `a3fd74c32276d244f755fdfcb0aa038292a6d02b`.
- A clean `git archive` export was inventoried by its staging copy of
  `scripts/update-snapshot.ps1 -Version 1.9.4 -ForRelease`.
- The inventory contains 65 files and 991,234 bytes; the complete package has
  66 files including `snapshot.json`.
- Candidate snapshot SHA256:
  `08669531b08676d48e283b9c7b2fad7896fd28915b2bfea55bf5785dea311b8d`.
- The independent release auditor checked every inventory entry against its
  staging file and raw source-commit bytes: path, size and SHA256 all match.
  There are no extra or missing package files. `.ai/`, `openspec/` and
  `docs/reviews/` are excluded from the installation export.

The source commit includes the canonical protocol, templates and Skill changes,
paired public documentation, version expectations, synchronized main spec,
archived change and original review rounds. This report is source-only. The
candidate snapshot was copied back to the source; publication remains pending
until the metadata commit and a fresh export are checked against this candidate.

## Package and upgrade fixtures

Windows PowerShell 5.1 and PowerShell 7 each ran the staging package's
`scripts/test-public-package.ps1` with outer exit 0 and the snapshot hash above.
`new-install-status-doctor-uninstall` and
`owned-file-drift-zero-write-refusal` passed on both hosts. The frozen v1.6.1
case was explicitly skipped because that optional historical package was not
supplied; the v1.9.3 upgrade below is a separate fixture.

The official v1.9.3 ZIP has SHA256
`4dc84e76ac0e94ec6ef978d4ec6bec2904530f6a3417d27bc94b69052c726d37`,
matching its published checksum. A disposable v1.9.3-to-v1.9.4 upgrade and
uninstall fixture passed on each host. It checks preservation of `agents`
SkillTarget and `optional` mode, the original AGENTS.md backup, all seven
canonical and discovery Skill hashes, the response-handoff template, project
sentinels and an AGENTS.md edit outside the managed block. A modified discovery
Skill causes uninstall exit 1 with the expected path diagnostic and preserves
the edit. Restoring that owned file permits uninstall, preserving project
content and the outside edit. The fixture roots are removed; no real project
was upgraded.

The release auditor read the upgrade harness and checked that these assertions
precede its PASS result. Retained ignored evidence is identified below; hashes
identify bytes and do not authenticate the logs or their origin.

| Input or log | SHA256 |
| --- | --- |
| Public package JSON, Windows PowerShell 5.1 | `d5411b31ce7a81b61ff4c76a963c038c02b0a85b2b7f3f100671ff7280364df0` |
| Public package JSON, PowerShell 7 | `5fc414f8f6db9d530675db00e625cd7a29c0e26a2509b5dbd53bf03e9a3772c3` |
| v1.9.3 upgrade, Windows PowerShell 5.1 | `831186f690eba1f650a08c01a391744ec66350fe01d6670a7fa6be11b7c58840` |
| v1.9.3 upgrade, PowerShell 7 | `e74b90064f588b0ec6232525681404c7ee8487a4b80d89a250d308a71ebafbbe` |
| One-time upgrade harness | `b60b90b4fbc13376ae61ced68e5be72d1bdbab78e0e177feb19bf74ca03faaa2` |

## Protocol evidence and archive

All ten [archived tasks](../../openspec/changes/archive/2026-10-19-harden-handoff-recovery/tasks.md)
are complete. The [final independent review](harden-handoff-recovery/2026-10-19-round-04.md)
is PASS and the batch is ordinary `accepted`, cumulative review count 4/4
under its finite owner authorization. All assigned findings are verified. The
four original review reports retain their recorded SHA256 values; archive and
release preparation add no product verdict and do not reset the count.

The existing repair rehearsal logs show 47/47 cases on each of Windows
PowerShell 5.1 and PowerShell 7. The final independent follow-up logs show
17/17 focused cases on each. These are protocol-oracle and synthetic file
operation checks. The release auditor matched 45 product/runtime inputs to
the final review boundary's hashes, with no differences, before release-only
metadata preparation. The canonical runtime validator remains:
`0deb5c616cbfb2dc038b0f7a157cb5ee910b25bf4de10c859a8a9aecc286e6bd`.
Its historical full suite was not rerun for this protocol change. The final
accepted handoff's expected-state check and OpenSpec strict check have recorded
exit 0 in the existing external boundary evidence.

`LOCAL-ENTRY-01` remains deferred to the target project's maintainer / Task
Intake; `OBS-01` remains separately deferred. Their status and ownership are
preserved in the [review index](harden-handoff-recovery/index.md#deferred-follow-up)
and source navigation. Product completion does not claim the project-side rule
correction has been performed.

## Documentation, privacy and limits

Both README, changelog and development-guide editions agree on v1.9.4 and the
47/17 evidence scope. The maintainer checked 136 local file links in 13 affected
public navigation and human documents without errors. MIT and both third-party
notice files match the source commit.

The selected contribution files contain no detected real-project path, personal
workstation directory or common credential pattern in the bounded scan; this
is not an exhaustive secret scan. Private runtime state, authorization notes,
fixtures, logs, installation backups, downloaded packages, host settings and
graph caches remain ignored. No additional redaction or license change was
required. The protected original round-02 report retains its final blank line:
the full whitespace check reports that single known EOF exception; it is not
removed by rewriting review history.

Checks cover the stated source/package bytes and disposable fixtures. They do
not prove actual Agent or host loading/adherence, automatic process wake-up,
unexpected-disconnect zero-loss recovery, source authenticity, real-project
deployment or business acceptance. The change introduces no runtime scheduler
or global configuration modification. Final export equality and GitHub
publication are subsequent release steps, not outcomes claimed by this record.
