# 1.10.0 local candidate export record

Recorded: 2026-10-24. This is release preparation evidence, not another review
verdict, a publication record, or a grant of deployment authority.

## Authority and reviewed inputs

The owner explicitly authorized necessary local commits, clean exports and
proposal/review archiving for the 1.10.0 candidate. Push, publication and real
project installation remain outside that authorization.

The final independent candidate review is [round 11](2026-10-24-round-11.md),
PASS at cumulative 8/8. Its exact reviewed working-tree package remains a distinct
historical input. After that review, ten bilingual release documents were aligned
to local candidate status and four current-version literals in two scripts were
changed from 1.9.6 to 1.10.0. Normalizing those literals reproduces the reviewed
script hashes exactly. Installer, validator, projection and protection behavior
were unchanged; these metadata edits were inspected and checked separately.

## Actual committed export

- Source commit: `c7d24c4ddd8d05b4de2b0e2e9e6912fe4941a1af`.
- Actual operation: `git archive --format=zip` of that commit into a new disposable
  directory, followed by its own snapshot generator with `-Version 1.10.0 -ForRelease`.
- Complete package: 79 files, including snapshot.json; inventory: 78 entries.
- Snapshot SHA256: `9E18066A2BDC14E39F8C109886A55C872EE876483D58290F38D80F7E180A3D71`.
- Every exported non-snapshot file matched the checked preview by path and SHA256;
  every inventory entry matched its actual byte count and hash. Generated snapshot
  bytes also matched the preview. Default and explicit 1.10.0 generator results
  were identical. The validated staging snapshot was copied back as source metadata.
- Actual archive contents exclude openspec/, docs/reviews/, private runtime and
  host tooling. Both roadmap language editions are committed source documents and
  are excluded from installation exports through the openspec export-ignore rule.

## Checks and limits

Fresh public-package smoke runs on PowerShell 5.1 and 7 each passed installation,
read-only diagnosis, uninstall preservation and modified-file zero-write refusal:
two PASS cases and seven manager/doctor processes per host. Expected refusal exits
were checked by the harness, not counted as unexpected failures. The optional
frozen 1.6.1 upgrade fixture was SKIP because PreviousPackageRoot was not supplied.
These runs used the preview whose full package bytes match the committed export.

The earlier two-profile 16-process candidate checks and independent H/protection
evidence are reused only within matching behavior inputs and their original
coverage. No historical full suite or actual-agent pilot was repeated for metadata.
No claim of all-host adherence, business acceptance, token savings or automatic
wake-up follows from these checks.

Known private-path/credential-pattern and tracked-file checks found no matches;
this is not an exhaustive secret audit. Diff checks passed except the already
recorded historical EOF blank lines in rounds 04 and 06, whose original bytes are
preserved. Raw process output, inventories, metadata deltas and runtime snapshots
remain in ignored local storage. Review 01–11 and the accepted closed batches are
preserved; this record neither resets the cumulative count nor issues verdict 9.
