# v1.10.2 release evidence

Date: 2026-11-03

## Accepted scope and history

The [archived change](../../openspec/changes/archive/2026-11-03-improve-review-closure-and-evidence-quality/proposal.md)
completes its [eight mapped tasks](../../openspec/changes/archive/2026-11-03-improve-review-closure-and-evidence-quality/tasks.md).
The initial implementation review passed with a 5/5 rating. The owner-requested
complete pre-release review then failed with a 3/5 rating because scenario provenance,
scenario-2 delivery privacy and the complete-candidate whitespace check were insufficient.
The owner authorized one concentrated correction and one independent verification,
limited to PR-01, PR-02 and PR-03. The [independent verification](improve-review-closure-and-evidence-quality/2026-11-03-correction-verification.md)
passed, verified all three findings and rated that correction 5/5. The cumulative
verdict count is three. Earlier reports, ratings and original closure remain intact.

Actual delegated Agent returns cover the five fictional scenarios, including both
finite-authorization variants; scenario 2 has a real redacted deliverable. Thirteen
rule/input/return/artifact fingerprints matched in independent verification. Two
prohibited fictional markers had zero matches in the deliverable, Agent return,
workspace summary and staged summary. Raw fictional inputs and returns remain private.
The same scenario Agent read Full before Lite, and the parent lacks its raw per-tool
transcript; this does not prove fresh Lite-session isolation or universal adherence.

The final implementation handoff was saved, read back and checked against close,
no next role, cumulative round 3 and revision 8. After archive-path mapping, revision 9
also passed expected-state validation. The validator proves structure and stated
value correspondence, not business acceptance or reviewer independence.

## Archive and contribution preparation

Both affected main specifications are synchronized with all six delta requirements
and 29 scenarios. Existing titles, Purpose text and unrelated requirements remain.
The bounded archive comparison caught and corrected one omitted attribution paragraph
before commit. Both main specs passed strict validation, and no active changes remain.
This archive check adds no formal product verdict or repair cycle.

Product source commit: `9c2be4aa4b7d349e69d426e8ecefe36a023b404c`.

The source preparation contains 35 files: reviewed product rules and existing
templates, paired public README/changelog/development/quickstart information,
current test-version expectations, the archived proposal, synchronized specs and
navigation, preserved reviews and corrected scenario evidence. The release includes
the previously committed source-only first-handoff sample guidance; external G0
remains incomplete. Its sample files are excluded from installation exports.

A bounded source check covered 231 local links, found no common credential patterns,
and verified 19 protected inputs unchanged. Historical report targets are resolved
through the archived-path mapping in the review index; original report bodies remain.
This is not exhaustive secret detection. Private runtime, fixtures, logs, host tools,
caches and build products remain ignored. License and third-party notices are unchanged.
The final metadata contribution contains the generated snapshot, this evidence record,
and a source-only archive-summary count correction; it changes no tested package bytes
other than copying the already-tested snapshot back to source.

## Clean export and inventory

The product source commit was exported with git archive into a fresh private staging
directory. Its own update-snapshot.ps1 ran with Version 1.10.2 and ForRelease.
An independent Python inventory comparison checked exact paths, lengths and SHA256,
and all non-snapshot bytes matched the committed export.

- Inventory: 78 entries, 1,175,808 bytes.
- Complete package: 79 files, 1,187,259 bytes, including an 11,451-byte snapshot.
- Snapshot SHA256: `21429a4c61449e42baa124462a5db4c5c35b8d9cec1eee3716c857b192f1c3fe`.
- Package paths are unchanged from the verified v1.10.1 complete export.

Export attributes exclude openspec/, root docs/reviews/ and the first-handoff sample.
The staging snapshot is copied back as release metadata. The final commit's ZIP must
match the tested staging package byte-for-byte before publication. ZIP integrity is
recorded separately in SHA256SUMS to avoid a circular package hash.

## Focused package checks

Windows PowerShell 5.1 and PowerShell 7 each ran the actual staging copy of
test-public-package.ps1. Per host, two cases passed, the optional frozen v1.6.1
upgrade case was explicitly skipped because no historical fixture was supplied,
and the outer exit was zero. Seven child calls covered Full install, read-only
Status/CheckVersion/doctor, uninstall preservation and zero-write refusal of an edited
owned file. That refusal's nonzero child exit is expected.

The focused Lite upgrade harness also passed on both hosts: six child calls and
14 assertions each. It installed the verified original v1.10.1 Lite package into a
GUID-named disposable project and upgraded with the actual 1.10.2 manager. It checked
manifest/profile/target/version, preserved project-owned configuration and runtime,
byte-matched upgraded content, checked read-only status/version/doctor, and checked
uninstall preservation. Together these package checks made 26 child calls.

No real project or the development source checkout was installed. Cleanup used
resolved disposable paths and reparse checks. The complete candidate inventory is
rechecked after the tests. Host loading, external G0, actual business acceptance,
all-host rule compliance and token savings are not claimed.

| Private check evidence | SHA256 |
| --- | --- |
| Public package, PowerShell 7 | `cf152775484f6d525ec0f85e1b09171eb53435352c85ea2d100eaa0f2bde450e` |
| Public package, PowerShell 5.1 | `dd5bb0d33778751650b4a548d4175f6f94c4e9973ed668c1e11a3b76114c2ce5` |
| Lite upgrade, PowerShell 7 | `7f086548eefa04aea36c973d0d785b51aa8cfa0a47a803dab875d19385ae8724` |
| Lite upgrade, PowerShell 5.1 | `3c7747f523d614b702089ba86e549793ea3cdee6967e01233c2edfdf3d7d60aa` |
