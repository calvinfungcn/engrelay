# v1.9.0 release candidate evidence

Date: 2026-10-18

## Source and package inventory

- Source commit: `639755024a64d9cfe0925a9145d42ba23d76b2d4`.
- Candidate generated from that commit with `git archive`, then `update-snapshot.ps1 -Version 1.9.0 -ForRelease` in a new disposable directory.
- Candidate inventory: 65 files, 883,302 bytes; every path, byte length and SHA256 matched the staged `snapshot.json`.
- Candidate snapshot SHA256: `13cae6aba14a59de18a7e7ee42bd721cf9f110220c915ea2711a487a4798882e`.
- Independent package audit matched all 65 non-snapshot package files byte-for-byte to the source archive; the complete inventory is 66 entries including `snapshot.json`.
- Clean v1.8.0 tag export: 63 files, 843,392 bytes; every path, byte length and SHA256 matched its unchanged historical snapshot.
- Both exports passed checks for private/tool trees. The release inventory script is a gate for known paths and filename patterns, not an exhaustive secret scan.
- The independent audit found all 22 README local links in each language edition, confirmed required license text, and found no likely matches in its bounded secret-file/content scan. These checks do not constitute an exhaustive secret review.
- The nine reviewed payload product inputs retained their original independent-review SHA256 values (9/9).
- Strict main-spec validation and Git whitespace checks passed.

## Focused package fixture

The existing `test-public-package.ps1` ran against the staged v1.9.0 package on both Windows PowerShell 5.1 and PowerShell 7. Each host reported two PASS cases (`new-install-status-doctor-uninstall` and `owned-file-drift-zero-write-refusal`) and one SKIP (`frozen-161-codex-upgrade-status-doctor-uninstall`) because no v1.6.1 package was supplied. The logs were stored outside both packages.

| Log | SHA256 |
| --- | --- |
| `public-package-ps51.json` | `dc77dd2b9e67ff22bce4883163bc8345ddcf6999fa186818a750395b420c2103` |
| `public-package-ps7.json` | `6dd82406e2788f1d38794d174130db212ebca8d938b0b963654b866cf172fb27` |

## v1.8.0 to v1.9.0 upgrade fixture

A disposable project was installed from the clean v1.8.0 export with `SkillTarget=agents` and `WorkflowMode=optional`, then upgraded using the staged v1.9.0 package. The check passed: seven canonical Skills and seven discovery copies matched the v1.9.0 payload hashes; the manifest recorded v1.9.0 and retained the target, mode and original AGENTS backup; an outside edit and four protected sentinels survived upgrade and uninstall.

Upgrade log SHA256: `f4d2d8d3cf73639e37519140d5333d358bf901378a350db559ea36a71f1631b3`.

The one-off fixture harness had preliminary assertion/name-resolution errors. The corrected final run passed; these were harness-only errors and did not result in product changes.

## Review and evidence limits

The original independent Review 1 was accepted. A separate release audit found no concrete product or release-metadata defect within its stated scope; it was not an unqualified business acceptance. The review count remains one and was not reset.

No fixture establishes actual model behavior, host loading, real-project deployment or business acceptance. The Quickstart's host troubleshooting and complete end-to-end inventory walkthrough were not separately exercised. Package inventory checks are not an exhaustive secret scan. Logs and temporary fixtures remain outside the public package.
