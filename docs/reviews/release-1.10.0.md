# v1.10.0 release evidence

Date: 2026-10-25

## Accepted scope and history

The [Lite/Full integration](../../openspec/changes/archive/2026-10-24-integrate-lite-full-profiles/tasks.md)
completed all 32 mapped tasks. Its [review history](integrate-lite-full-profiles/index.md),
closed phases and finite review extensions remain intact. Its earlier local candidate
and [export record](integrate-lite-full-profiles/local-export-1.10.0.md) remain historical inputs;
this release uses a new export rather than overwriting that package.

The [context and review feedback change](../../openspec/changes/archive/2026-10-25-improve-context-and-review-feedback/tasks.md)
completed 11/11 tasks. The independent [release audit](improve-context-and-review-feedback/2026-10-25-release-audit.md)
returned PASS with no must-fix or should-fix findings. That explicitly requested audit
is the third cumulative product verdict, 3/3. The original accepted closure at round 02,
its 2/3 count and both original reports remain unchanged; the [index](improve-context-and-review-feedback/index.md)
distinguishes these facts. Original implementation quality 3/5 and fix quality 5/5
are preserved; the audit rates the current delivery 5/5.

Both changed capabilities were synchronized to the main specifications, preserving
their Purpose sections and unrelated scenarios. The proposal is archived. Fresh strict
OpenSpec validation passed both main specifications, and the active change list is empty.
Release checks issue no additional product verdict and do not reopen any closed batch.

Twenty protected inputs still match their pre-release hashes after mapping planning
artifacts to their archive paths. The original closed handoff remains byte-identical,
SHA256 EB254EB60828937144556BACD4714F6ECDCED3F68EDD6F4630C1776712E0E510.

## Contribution and privacy

The source preparation commit contains 35 files: reviewed product documents/templates,
paired README/changelog/development/quickstart editions, the formal archive, synchronized
main specs and navigation, and preserved reviews plus the independent audit.
Version 1.10.0 combines the previously unpushed Lite/Full candidate work with the new
context and delivery-feedback changes. The earlier 1.9.6 and older changelog entries
remain unchanged. Version expectations in the existing scripts already target 1.10.0.

Private runtime, original fixtures, session returns, logs, tool copies, caches and build
artifacts stay ignored. Existing ignore rules suffice. A bounded scan of the pending
source found no common credential patterns; 258 local file links resolved. Fourteen
author-account temporary-path occurrences remain in preserved historical Lite/Full
review commands. They identify disposable test provenance; those historical reports
were not rewritten and are excluded from installation exports. This is not exhaustive
secret detection. Original MIT licensing and third-party notices are preserved.

## Clean export and inventory

Product source commit: 5dbedc2f1a6b3d207785861da2a9b16274406df6.

A new git archive export of that actual commit was inventoried by its own
scripts/update-snapshot.ps1 with Version 1.10.0 and ForRelease.
The inventory has 78 entries and 1,134,179 bytes. The complete package contains
79 files and 1,145,629 bytes, including its 11,450-byte snapshot.
Snapshot SHA256: 461f77d807da4538b5635b0e0d4ba929a52d064b9d015fc4fc62acf522abfeae.

An independent byte check matched every file, size and SHA256 to the inventory;
all non-snapshot bytes also matched the source commit export. OpenSpec and root
Review records are excluded through committed export attributes. No private runtime,
host tooling or caches are included. The actual v1.9.6 tag export was separately
checked against its complete original inventory before its manager was used.

The staging snapshot is copied back as source metadata only after the checks below.
A fresh final-commit export must match the tested package byte-for-byte before
publication. The final complete ZIP and SHA256SUMS carry the asset integrity evidence;
their final hash is retained separately to avoid a self-referential package record.

## Fresh package behavior checks

On Windows PowerShell 5.1 and PowerShell 7, the staging public-package smoke suite
returned outer exit 0: two PASS cases and one explicit SKIP per host, with seven
manager/doctor calls each. New Full installation, read-only Status/CheckVersion/doctor,
uninstall preservation and modified-owned-file zero-write refusal passed.
The optional frozen v1.6.1 upgrade case was skipped because its dedicated previous
package parameter was not supplied; it is distinct from the real v1.9.6 checks below.

A small private profile harness passed on both hosts, with 12 subprocess calls and
34 assertions each. It used fresh GUID disposable projects and covered:

- A real v1.9.6 Full Install followed by official 1.10.0 Upgrade, converting v1 to v2
  while retaining Full, optional mode, the agents discovery target and original backup.
- All seven upgraded canonical/discovery Skill pairs matching candidate bytes;
  read-only diagnosis; uninstall retaining original project rules, later text and evidence.
- Lite Install/Upgrade, preservation of old-style project configuration without new
  preference fields, matching rules/templates, read-only diagnosis, and uninstall
  preserving project configuration and runtime evidence.

The final successful suites contain 38 child calls. Initial harness attempts on both
hosts each made one failed call: an automatic-variable collision omitted Action and
ProjectRoot, and the old manager refused before writing. Both failure logs are retained.
An intermediate successful pair of profile runs contains 24 calls; after adding explicit
v2/mode assertions, only those profile runs were repeated. The retained logs therefore
contain 64 child calls in total. No product fix was needed. Final logs correspond to the
final harness. Disposable targets were checked for safe paths and reparse points before
cleanup; no real project or source checkout was installed.

The tested package still matches all 78 inventory entries after the checks.
The private evidence hashes are:

| Evidence | SHA256 |
| --- | --- |
| Public package, PowerShell 5.1 | ca35fd1ab46c6d5dcd2c96a703f9058859e9271b23785af64f31336dc107b9af |
| Public package, PowerShell 7 | 19bc51d90cc61b8090d189ddebc6fa623abda4eb1027ba7ea0c673f89d757d37 |
| Profile smoke, PowerShell 5.1 | 3de1cd064f631397b84c2ece8f75e1be55816da5ce5ad8ff9ed2d6df6ab84b69 |
| Profile smoke, PowerShell 7 | 7a61d2711aa438e2904292c61f95baf6c806b3dce42b3172f3e8a9ce73bbca21 |
| Final profile harness | b987034cc01183b6b6de8719d8420b259a995e0971898647cd69afe5d69a1b97 |

## Limits

The product audit retains the distinction between actual bounded S/M evidence and
fixed scoring, queue, count and read-only examples. Original host invocation transcripts
were not independently authenticated. The earlier Lite/Full exercises retain their
own host coverage and substitutions. These installation/inventory checks do not
establish agent identity, actual host Skill loading, all-model adherence, business
acceptance or token/cost savings. No background scheduler, real deployment or global
configuration change is added by this release.
