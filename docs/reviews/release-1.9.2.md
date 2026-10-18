# v1.9.2 release evidence

Date: 2026-10-18

## Source and package

- Product source commit: `d8ff3faaa8e5c936cefd2dc341fd5fad98711b79`.
- The clean export from that commit was inventoried with
  `scripts/update-snapshot.ps1 -Version 1.9.2 -ForRelease`.
- The inventory contains 65 files and 930,906 bytes; the complete package has
  66 files including `snapshot.json`. The independent audit exported the source
  commit again and matched every inventoried path, byte length and SHA256 to the
  staged package and manifest.
- Candidate `snapshot.json` SHA256:
  `b5ad0e86305c11495fc5e8b8131821f24206e26c49dc580cc810eefffbca843e`.
- The audit found the required MIT license and third-party notices. It checked
  21 local links in each README language edition and 11 in each operator guide;
  the new autonomous-continuation anchor was present.
- The bounded scan found no matches in selected private-path and credential
  checks. This is not an exhaustive secret scan.

The product source commit contains the contract, template, validator and
package-smoke changes; both README and CHANGELOG language editions; development
baseline updates; OpenSpec main-spec and archived-change records; and the
autonomous-continuation review record. This release-evidence record and the
final `snapshot.json` are source-only release metadata. Ignored `.ai` staging,
logs, fixtures, downloaded archives, `.agents` and `.codex` tooling/configuration
and caches remain outside Git and the package; no `.gitignore` change was needed.

## Package and upgrade fixtures

The staged `scripts/test-public-package.ps1` completed under Windows PowerShell
5.1 and PowerShell 7 with exit 0 and the candidate snapshot hash. Both hosts
passed `new-install-status-doctor-uninstall` and
`owned-file-drift-zero-write-refusal`. The frozen v1.6.1 case was skipped because
that historical package was not supplied.

The official v1.9.1 ZIP used for the upgrade fixture had SHA256
`859798675f46823ab1c6dae8762ff689151151167a2d10de237aed0436ca77f7`. Fresh
disposable fixtures on both hosts passed the v1.9.1 to v1.9.2 upgrade and
uninstall checks. They verified the `agents` SkillTarget and `optional` mode,
the original AGENTS.md backup, project sentinels, an outside AGENTS.md edit, all
seven canonical and discovery Skill hashes, and the response-handoff template
hash. Uninstall preserved a locally modified discovery Skill: the child process
returned exit 1 with the expected modified-file diagnostic and made no loss;
after restoring that owned file, uninstall succeeded and retained the project
sentinels and external AGENTS.md edit. Both fixtures were cleaned.

The first Windows PowerShell 5.1 harness run exposed a harness capture issue:
PowerShell promoted the expected native uninstall-refusal stderr before the
harness recorded its child exit. The ignored log preserves that run. The harness
was corrected to capture the actual child exit and diagnostic; final runs on
both hosts report uninstall-refusal exit 1 and a matching diagnostic.

| Retained local log | SHA256 |
| --- | --- |
| Public package, Windows PowerShell 5.1 | `ecdf484a37965b0fcffe9ff21aa17e78daeb6edb6fdae314e142c73019bd1deb` |
| Public package, PowerShell 7 | `de12420006892437de2e34efce6f38fad15f76bffc6dbf664fad3c7f086b87e3` |
| v1.9.1 upgrade fixture, Windows PowerShell 5.1 | `d25d6a7f3c5324595127f86137c9d17c3222eac81a0383a97be0f5185c657bcd` |
| v1.9.1 upgrade fixture, PowerShell 7 | `de5a2bcea866c6b6b99550fe199d51f0c8541e7e8376e0b10acf1ef185ee6bbb` |
| Initial PS5.1 harness capture failure record | `12f1b1ef59b9981372f2f3aed56c9fe043b2533625c59e4f48eb3fcf6c6d31f3` |

These hashes identify retained ignored logs; they do not authenticate them.

## Reused protocol evidence and review

The source verification record for autonomous continuation reports 229
validator cases passed under each PowerShell host. The final validator and test
inputs still match that evidence by SHA256:

| Input | SHA256 |
| --- | --- |
| `payload/docs/ai-collaboration/scripts/validate-runtime-state.ps1` | `42518cd4ff7cf021525effb33dcc2ed79736dffd9b991d690acf11c418c20a50` |
| `payload/docs/ai-collaboration/scripts/test-validate-runtime-state.ps1` | `19aceb093bb00972c301a289709cb63c99305cfe7df1566473404dd3cba18a1a` |

The response-handoff template received the focused third independent review
(`PASS`, AC-03 verified); its reviewed SHA256 is
`894059eaa83016e0982b02b90bd9e4a613097df64f987a5751d931fac32e9265`. The
autonomous-continuation review history remains cumulative at three verdicts;
the count was not reset.

## Scope and limits

These checks cover the recorded source/package bytes and disposable fixtures.
They do not prove actual host loading or compliance, automatic process
resumption, real-project deployment, natural-language authorization, or business
acceptance. The package audit is a structure and inventory check, not an
exhaustive security scan. Logs, downloaded archives and fixtures remain outside
the public package.
