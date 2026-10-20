# v1.9.5 release evidence

Date: 2026-10-20

## Accepted product scope

The [archived tasks](../../openspec/changes/archive/2026-10-20-improve-lean-progress-and-capability-handoff/tasks.md)
are complete (6/6). The final independent [round 03](improve-lean-progress-and-capability-handoff/2026-10-20-round-03.md)
is PASS, CR-01 is verified, and the batch closed as ordinary `accepted` with
cumulative Review round 3/3. Release preparation adds no product verdict and
does not reset the count. The review index retains the three original reports
and their SHA256 values.

Before release metadata edits, the maintainer matched all 16 product and public
documentation inputs from the original review inventory. The final accepted
handoff still matches the external boundary evidence; its structure and expected
state validation recorded exit 0. The runtime validator and package manager
remain unchanged. The historical validator and recovery suites are not repeated
for this documentation and prompt-output change.

The main spec now includes two added requirements and the capability guidance
update. OpenSpec archive strict validation passed 9 items, with no failures;
the active change list is empty. Both README and changelog editions describe
the new behavior and v1.9.5. Automatic process statistics remain a pending
decision, outside this release.

## Contribution and privacy boundary

The contribution includes canonical protocol and Skill documentation, paired
public documents and release version expectations, the synchronized main spec,
archived OpenSpec artifacts, and the review records. Private runtime state,
raw agent transcripts, fixtures, logs, build packages, host settings and caches
remain ignored. A bounded candidate scan found no real-project paths, user
directories or common credential patterns requiring redaction. Public example
project paths are intentional. This is not an exhaustive secret scan.

Original material remains MIT licensed; applicable third-party notices are
unchanged. No real project is installed into or used as a fixture.

## Package verification

Product source commit: `1b56131b15ae213df93499a51431f29b42a48905`.
A clean `git archive` export was inventoried by its staging copy of
`scripts/update-snapshot.ps1 -PackageRoot <package-root> -Version 1.9.5 -ForRelease`.
The snapshot contains 65 files and 997,164 bytes; the complete package contains
66 files including `snapshot.json`. Its snapshot SHA256 is
`bdb66394eed672f963056d0d83d868b89af5640130a3397996f709c7d222f692`.

A separate release-check worker matched every inventory path, size and SHA256
to the candidate and checked each inventoried file against the source commit's
Git blob ID and size. The exact exported file set matches, with no extra or
missing files. OpenSpec, reviews, runtime state and host tooling are excluded
from the installation export. The candidate snapshot has been copied back to
source as release metadata; a fresh final export must match before publication.

On each of Windows PowerShell 5.1 and PowerShell 7, the staging package's
`scripts/test-public-package.ps1 -PackageRoot <package-root> -LogPath <external-log>`
returned outer exit 0. New install/status/CheckVersion/doctor/uninstall and
owned-file drift refusal passed. The optional frozen v1.6.1 fixture was explicitly
skipped because that historical package was not supplied.

A separate disposable v1.9.4-to-v1.9.5 upgrade fixture passed on both hosts,
using the exact v1.9.4 tag export as its previous package. Install and Upgrade
returned exit 0; `agents` SkillTarget, `optional` mode, original AGENTS.md backup,
project sentinels and an edit outside the managed block were preserved. All seven
canonical/discovery Skill pairs and the five changed installed documents match
candidate hashes. A modified discovery Skill causes uninstall exit 1 with the
expected diagnostic and preserves the edit. Restoring the owned file permits
uninstall exit 0 while preserving project content. GUID fixture roots were
removed. The maintainer read the harness assertions and confirmed the log results.

These checks are release preparation, not another product review round.
Retained private logs and the one-time upgrade harness have these SHA256 values:

| Evidence | SHA256 |
| --- | --- |
| Public package, Windows PowerShell 5.1 | `1e144c4b1b3815c614dc731c39e62fe386e88684e21ba96b8a62add6bf0054c3` |
| Public package, PowerShell 7 | `51b835eca71d1445e2a7ba4be2edf1494dd284f3312410f64898892974e2d43a` |
| v1.9.4 upgrade, Windows PowerShell 5.1 | `e9644ba5478f98478567bdfe1db5b10f5977036b6207cdb1827cc8fa9bac516b` |
| v1.9.4 upgrade, PowerShell 7 | `cc8bbf1afd357ef2980e291f50ef0c40b77031024415b6d35e93c28a3aaa926f` |
| Upgrade harness | `b9a7f8caeb0a609f3b4ffe4ffc2178d56e9336d402a6b6a230db32424953da1e` |
| Independent inventory check | `25ddf5a99ebfe000733d0a83279924fbb67f813bb0a96b7dd55814a76f831eba` |

Before the source preparation commit, the maintainer checked 136 local file
links across 30 contribution files, with no broken targets, private paths or
common credential patterns found. Whitespace checks passed. The release-metadata
commit and its fresh export remain the final publication inputs; the release
asset checksum is distributed separately in `SHA256SUMS`.

## Limits

The accepted checks cover the documented protocol and limited fictional-agent
samples. They do not guarantee models never omit a field, host loading or
adherence, log authenticity, automatic process wake-up, real deployment or
business acceptance. Capability tiers remain advisory; older handoffs remain
valid. No runtime orchestration engine or global configuration change is added.
