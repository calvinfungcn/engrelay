# EngRelay v1.7.1 release checks

Recorded on: 2026-10-15. Package version: 1.7.1.

## Inputs and scope

- Candidate source commit: `ed1b146623a8c80d3f4c6e874f5e667f26081b99`, exported with git archive into a disposable staging directory.
- Candidate inventory: 54 entries plus snapshot.json; complete file set, byte lengths and SHA256 verified.
- Candidate snapshot SHA256: `16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743`.
- Published v1.7.0 baseline ZIP SHA256: `9b9bfcb50bf62847574ec3ed5dfdbac0a20b98bd0999efdbf712350024670d99`, checked against the GitHub asset digest before extraction.
- Canonical payload and agent-rules.md match the v1.7.0 inventory. Version-sensitive deployment fingerprints are refreshed during upgrade.
- OpenSpec change is archived; its 3 added requirements are merged into the main specification. Review 01–03 remain at stable paths with workstation paths redacted; cumulative review count remains 3.
- The maintainer starting prompt in docs/development.md is in English, as requested.

## Results

| Check | Windows PowerShell 5.1 | PowerShell 7 |
| --- | --- | --- |
| Skill guidance baseline | 3/3 PASS | 3/3 PASS |
| Skill guidance behavior | 9/9 PASS | 9/9 PASS |
| Install/status/version/doctor/uninstall and drift refusal | 2/2 PASS | 2/2 PASS |
| Published 1.7.0 to 1.7.1 upgrade, none and codex | 2/2 PASS | 2/2 PASS |

Upgrade fixtures verified the new version, preserved target/mode/original backup, project-owned files and outside-block edits, and successful uninstall. Upgrade fixture cleanup succeeded. The optional frozen v1.6.1 test was explicitly skipped because that fixture was not supplied; no new v1.6.1 result is claimed.

Both focused scripts initially rejected the new candidate because two version expectations still read 1.7.0. Those expectations were updated to 1.7.1 and the complete affected checks reran on the rebuilt candidate. A local upgrade fixture initially treated the version-sensitive fingerprint as a pure payload hash; its assertion was corrected after reading the existing algorithm, with no product change.

PowerShell syntax parsing, strict main-spec validation, whitespace checks and a sensitive-pattern scan passed. The scan found no matches in tracked/publishable files; pattern scanning is bounded and does not prove that every possible secret format is absent.

## Evidence hashes

Raw logs remain local, outside the package and Git. These hashes identify the final runs.

| Log | SHA256 |
| --- | --- |
| guidance-winps-final.json | `88a352631563974893ebe1e047d3381fa4b41dce4c3a177c647df36c8440426d` |
| guidance-pwsh-final.json | `f539064593c06a2cc3a5e79e74ae8ad77cfc0afe6fa17ef4caab88f9d3bb0461` |
| public-winps-final.json | `f784841a2353aa5ba5b0737f8ce9a9c2672e8ef149a11f4099f7b575d0bf4063` |
| public-pwsh-final.json | `42607acbefdbcda2b40690bceccb46b0b5f0ca7ac9c9dae00177d62e75fc58df` |
| upgrade-winps-final.json | `abba200c8dffeeeac02bcfe3c1d4b1b3ef1ce08409cfaa01a0bfc9e9e37bb1ac` |
| upgrade-pwsh-final.json | `bbd943ecdbda42b02d60754c457315d7f9a030a07ca89c5949412e80ff57a1be` |

## Release boundary

The final metadata commit adds the matching snapshot and this source-only report. The final commit export must match the tested candidate byte for byte before upload. OpenSpec, Review, local runtime, host settings, caches and build products are excluded from the complete installation ZIP.

Host loading, real-project deployment and business acceptance remain unverified. C1–C5 handoff capability guidance is a future requirement and is not included in 1.7.1.
