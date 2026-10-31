# Submission preparation record

Date: 2026-10-31

## Scope and disposition

This is a source-maintenance submission against version 1.10.1. The intended
source commit scope includes the handoff demo and its fixture, bilingual public
guides and entry points, the redacted review records and trial summary, paired
roadmaps and OpenSpec navigation, the archived change and baseline spec, and
both Unreleased changelog entries. Review round 03 passed; the cumulative review
history is 3/3. The earlier round 01 and round 02 files remain preserved.

The sample is source-only and excluded from installation exports. The public
record preserves the two repaired internal S A/B closures, the earlier partial
and failed attempts, affected behavior and independent review. It makes no
external G0, ten-minute completion, host-loading, or all-host adherence claim.

## Version, snapshot, and public identity

No package version change is made. The tracked root `snapshot.json` continues to
describe the previous release; it was not refreshed to absorb development-only
source bytes. A future release must export the reviewed commit to clean staging,
regenerate and verify the staging snapshot, and then update release metadata.
That release work is outside this preparation.

Source commit: `304aa95702f106da262bcc741576293dfbeddc8d`.
It was committed and pushed to `origin/main` on 2026-10-31 after the complete
independent review passed. A new Git clone from the public GitHub repository was
checked out at this exact commit; all eight fixture files matched their reviewed
SHA256 values. The later documentation commit records these observations without
rewriting the earlier reviews or claiming a new release.

An actual `git archive` export of that commit contained 79 files, with the same
file set as the previous release inventory. The sample, OpenSpec and root review
directories were excluded. Seven root documentation/attribute files differ from
the previous release hashes, as expected. The tracked snapshot was not refreshed;
this source export is not an installation package with a matching inventory.

The GitHub API also confirmed the existing non-draft, non-prerelease `v1.10.1`
release with `engrelay-1.10.1.zip` and `SHA256SUMS`. That check confirms asset
availability; it is not a new download or checksum verification. Internal exercises
used the already recorded, locally verified complete package. Source checkout,
complete installation package and disposable target remain separate.

## Privacy, language, and scope checks

The public review material is redacted evidence and summaries; it does not include
private project directories, account credentials, raw chat transcripts, or raw
runtime logs. The private preparation log and runtime material remain under the
ignored `.ai/` directory. Existing ignore rules cover `.ai/`, installation
backups, host copies, caches, and generated build output; no ignore change is
needed. The two changelog entries and existing human-facing README/Quickstart
entry points were checked for paired language and matching claims.

The post-review P3 wording correction in `trial-evidence.md` clarifies that the
blank-label case already asserts a single-item output array, while a separate
single-element input is not in the four checks. It does not change the sample,
assertions, historical review files, or the round 03 verdict. The limitation
concerning a `$null` element remains.

## Checks and remaining work

Preparation checks include reading the repository maintenance instructions,
development/release guidance, OpenSpec configuration and change artifacts;
checking the pending Git scope and existing ignore rules; reviewing the public
trial evidence and review history; and checking bilingual changelog wording.
No full historical test suite, installation, release export, Git index update,
commit, push, or publication was performed by the preparation subagent. The parent
subsequently performed the source commit, export, push and fresh source checkout
recorded above. No tag or GitHub Release was created.

The round 01 review keeps its historical filename `2026-10-30-round-01.md`,
although that record states the actual review date as 2026-10-31. The existing
review index link uses that filename. This historical naming is retained. Its
recorded EOF blank-line diagnostic is also historical and was not edited here.
