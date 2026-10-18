# v1.9.1 release evidence

Date: 2026-10-18

## Source and package

- Source commit: `38ec9798a660d0157c4a9ae696d266a14d2ecd57`.
- The release candidate was exported from that commit and inventoried with
  `scripts/update-snapshot.ps1 -Version 1.9.1 -ForRelease`.
- The inventory contains 65 files and 894,286 bytes; the complete package has
  66 files including `snapshot.json`. Every inventoried path, length and SHA256
  matched a fresh source archive and the independent package audit.
- Candidate `snapshot.json` SHA256:
  `4757a94c08b9efa1e83d8f8b907b35a0f9fef9c80e6be6a29326937bc56be7fc`.
- The independent audit found all 20 README local links in each language edition
  and all 10 local links in each operator guide. Required MIT and third-party
  notices remain present.

## Focused package fixtures

The staged `scripts/test-public-package.ps1` completed on Windows PowerShell 5.1
and PowerShell 7. Both hosts passed `new-install-status-doctor-uninstall` and
`owned-file-drift-zero-write-refusal`. The frozen v1.6.1 upgrade case was skipped
because no v1.6.1 package was supplied.

A disposable fixture installed the clean v1.9.0 package, upgraded with v1.9.1,
and uninstalled on both hosts. Both runs passed, including checks for preserved
project-owned sentinels, an outside AGENTS.md edit, the original backup, and all
seven canonical and discovery Skills. Both fixture cleanup checks passed.

| Log | SHA256 |
| --- | --- |
| Public package, Windows PowerShell 5.1 | `cf30892019da26f046459ee77cd14cabe691efa22292488c42b5bf1af07808e2` |
| Public package, PowerShell 7 | `7c8e3005d133a3ac1b5e76aa2e08a0f7fc8dd897847d2466e7c267b1b497672f` |
| Upgrade fixture, Windows PowerShell 5.1 | `da56590bfa006b8ec5d09dfc35384cd62dadc1b701c2ac9e8245bfdf9b47c13d` |
| Upgrade fixture, PowerShell 7 | `4335154dcd6c02431b7b17a95e3e964822a8868879b259191a3e567c02f0e84d` |

These hashes identify the retained local logs; they do not authenticate them.

## Scope and limits

The bounded package audit found no matches in its selected private-path,
filename, or sensitive-content checks. It is not an exhaustive secret scan.
The checks cover package bytes and the recorded disposable fixtures. They do not
establish actual host loading or adherence, real-project deployment, or business
acceptance. Logs and temporary fixtures remain outside the public package.
