# v1.9.6 release evidence

Date: 2026-10-21

## Accepted product scope

The [archived tasks](../../openspec/changes/archive/2026-10-21-link-sizing-guidance-and-pilot-lean-rules/tasks.md)
are complete (7/7). The independent [round 07](link-sizing-guidance-and-pilot-lean-rules/2026-10-21-round-07.md)
is PASS and the batch closed as ordinary `accepted`, with cumulative Review
round 7/7 under the owner's finite extension. All seven original reports remain
at their original paths, with hashes in the [review index](link-sizing-guidance-and-pilot-lean-rules/index.md).
Release checks add no product verdict and do not reset or reopen that history.

The only product changes are two short references to the existing shared sizing
definition in `agent-prompts.md` and consistent `Initial role` wording in
`ai-collab-start`. The package manager, templates, runtime validator and recovery
logic are unchanged. Both README and changelog language editions describe
v1.9.6 and the actual scope. Main-spec synchronization and archive are complete;
strict validation passed all 10 archived changes, and the active change list is
empty.

Before release preparation, the maintainer recorded 22 accepted inputs. All still
match, with the five OpenSpec files mapped to their archive paths. The final
handoff remains unchanged with SHA256
`fb4fbca7297da55ba818496a6f4f3c3607fcdacaa763ecd370936e986bcd6dba`.
Its original final-input boundary evidence is retained privately; release
bookkeeping does not rerun or replace that completed product verdict.

## Contribution and privacy boundary

The source preparation commit includes 30 files: the two canonical product
documents, sanitized pilot evidence, seven review reports and their navigation,
the archived proposal and synchronized main spec, paired public documentation,
and release version expectations. The final release-metadata commit adds the
matching snapshot and this evidence record. Private runtime state, original
agent sessions, logs, fixtures, packages, host copies, settings and caches stay
ignored. Existing ignore rules cover them; no new ignore rules are necessary.

A bounded scan of the 30 contribution files found no workstation/project paths
or common credential patterns requiring redaction. The two README occurrences
of a project path are intentional placeholder examples. All 122
checked local file links resolve. This is not exhaustive secret detection.
Original material remains MIT licensed; third-party notices are unchanged.

## Package verification

Product source commit: `bfb3fe4f7c06a4cbe214cb406cbf134ee808e6d0`.
The candidate is a clean `git archive` export, inventoried by its staging copy of
`scripts/update-snapshot.ps1 -PackageRoot <package-root> -Version 1.9.6 -ForRelease`.
The inventory contains 65 files and 999,665 bytes. The complete package contains
66 files and 1,009,171 bytes including its 9,506-byte snapshot, whose SHA256 is
`b8ab159e6d1d2df0fa88f7f3b092b94cd9798cabc188b48cbc21351eec9a6e08`.

A separate read-only release checker matched the exact candidate file set,
sizes and SHA256 values to its inventory, and all 65 non-snapshot files to an
independent in-memory archive of the source commit. The previous package also
matches the exact v1.9.5 tag export and its inventory. OpenSpec, root review
records, runtime state, host tools and caches are absent from the installation
export. The final source snapshot is copied from the tested candidate; a fresh
export of the release-metadata commit must match it before publication.

On Windows PowerShell 5.1 and PowerShell 7, the staging
`scripts/test-public-package.ps1 -PackageRoot <package-root> -LogPath <external-log>`
returned outer exit 0. New install, Status, CheckVersion, doctor and uninstall
passed. Modified managed files caused the expected zero-write Upgrade refusal
(child exit 1). The optional frozen v1.6.1 fixture was explicitly skipped because
that historical package was not supplied.

A separate disposable v1.9.5-to-v1.9.6 upgrade harness passed on both hosts.
Install and Upgrade returned exit 0. The `agents` SkillTarget, `optional` mode,
original AGENTS.md backup, five project sentinels and an edit outside the managed
block were preserved. All seven canonical/discovery Skill pairs and both changed
installed product files match candidate hashes. A modified discovery Skill
caused uninstall exit 1 with its expected path diagnostic, preserving the edit
and project data. Restoring that owned file allowed uninstall exit 0, retaining
the original AGENTS.md and external edit. The GUID fixture roots were removed.
The independent checker reviewed the harness and logs; its assertions preserve
the prior harness's ownership protections. These are release checks, not a new
product review round. No real project was used as a fixture.

The retained private evidence has these SHA256 values:

| Evidence | SHA256 |
| --- | --- |
| Public package, Windows PowerShell 5.1 | `61f603b0909b187c50b95062434b00587f4139684df21a25723b7c06f0466036` |
| Public package, PowerShell 7 | `fae64498f1deed8c38b8c15d289cbfce5854bb12de4e7b3d5040b9d594b596fe` |
| v1.9.5 upgrade, Windows PowerShell 5.1 | `5bf86431cfb6c2f2eccba14b665976535e9b62e9b6938228f6b9dd7741be302d` |
| v1.9.5 upgrade, PowerShell 7 | `66ef3df0fe63903082cea1a771efde4e5d10ebda1e75ab70d4fbe843e129c72a` |
| Upgrade harness | `ceeb11b994c73ae629d629a888a1183c98b707730068d3d235467390a12a0989` |
| Independent release integrity check | `5813d41c115d4b82c0e43b1a6b3bd66eacb73e4d3697d7688139da111fbca88d` |

The release asset checksum is distributed separately in `SHA256SUMS`.

## Limits

The [pilot evidence](link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md)
retains primary-host S5-S7 gaps and Codex substitutions. Both baseline and
candidate reached the existing sizing guidance; this small fictional sample
does not establish performance improvement or causal effect. Search/probe counts
are syntax sites, not proof of branch execution. P2 and context consolidation
remain pending decisions. Release inventory, installation and protection checks
do not establish model-wide adherence, actual host loading, log authenticity or
business acceptance. No orchestration engine or global configuration is added.
