# v1.10.1 release evidence

Date: 2026-10-30

## Accepted scope and preserved history

The [archived change](../../openspec/changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md)
completes all [seven mapped tasks](../../openspec/changes/archive/2026-10-30-harden-lite-handoff-validation/tasks.md).
The explicitly requested [complete independent review](harden-lite-handoff-validation/2026-10-30-round-05.md)
returned PASS with no must-fix or unaddressed assigned should-fix findings, and an
advisory delivery rating of 5/5. The cumulative count is five; the original round 04
accepted closure at 4/4 and all earlier findings, ratings and verdicts remain intact.
This requested additional review does not grant another autonomous repair cycle.

The final review ran the Lite suite on Windows PowerShell 5.1 and PowerShell 7:
97/97 per host, exit 0, with unchanged input trees. Twenty-four further independent
command-boundary calls passed and made no input writes. Validator and test hashes
still match the reviewed inputs. The only post-review change to Lite RULES.md removes
the already reported extra EOF blank line; no executable product code changed.

The workflow-profiles delta is synchronized to the main specification. Its Purpose
and every unrelated requirement remain unchanged. Strict specification validation
passed and the active change list is empty. Archive files retain their original bytes.
Thirteen protected inputs, including original reviews, planning files, validator,
test and closed runtime records, match their pre-release hashes after path mapping.
Original handoff SHA256:
0938f1a1a5ede7a17a0f29624dc76d034bd9f81e331534f53705d1ad97415529.

F3 SetMode recovery and F4 trusted v2 layout evolution remain explicitly pending in
the [follow-up navigation](../../openspec/README.md#follow-up-items). This patch adds
or retires no package or managed deployment path. Release preparation issues no
additional product verdict and does not reopen the closed execution batch.

## Source contribution and privacy

Product source commit: 0ae0e9882dd92a692a7d0ba042d9233d90b13507.

That preparation commit contains 32 files: the reviewed Lite validator/rules/tests,
paired public README/changelog/development/quickstart updates, version expectations,
the proposal archive, synchronized main specification and navigation, and preserved
reviews plus round 05. The release metadata commit adds only snapshot.json and this
source-only evidence record.

Private runtime, original fixtures, raw logs, host tooling, caches and build artifacts
remain ignored. Existing ignore rules suffice. A bounded pending-source check found
no common credential patterns and checked 180 local links. Two historical round 03/04
links retain their former active proposal path; the review index records its archived
replacement without rewriting those reports. Current links resolve. This scan is not
exhaustive secret detection. Licensing and third-party notices remain unchanged.

## Clean export and matching inventory

The actual source commit was exported with git archive to a fresh private staging
directory, then inventoried by its own scripts/update-snapshot.ps1 using Version
1.10.1 and ForRelease. All non-snapshot bytes matched the committed export.
Every path, size and SHA256 was independently compared with the inventory.

- Inventory: 78 entries, 1,148,387 bytes.
- Complete package: 79 files, 1,159,837 bytes, including the 11,450-byte snapshot.
- Snapshot SHA256: 1a71383fade05adbe57e56ec9b159438607b402753c2922dd9500585f4084747.
- File set: identical to the verified original v1.10.0 complete export.

Committed export attributes exclude openspec/ and root docs/reviews/ from the
installation package. No private runtime or tool directories are included.
The staging snapshot is copied back as source release metadata. Publication requires
the final metadata commit export to match this tested package byte-for-byte.
The complete ZIP and SHA256SUMS provide the final asset integrity record separately
to avoid a self-referential package record.

## Fresh package checks

Both Windows PowerShell 5.1 and PowerShell 7 ran the staging copy of
scripts/test-public-package.ps1 with an external LogPath. Per host, two cases passed,
the optional frozen v1.6.1 case was explicitly skipped because its PreviousPackageRoot
was not supplied, and the outer exit was 0. Seven child calls checked Full installation,
read-only Status/CheckVersion/doctor, uninstall preservation and zero-write refusal
of a modified owned file. The refusal's nonzero child exit is the expected result.

A private focused Lite upgrade harness also passed on both hosts: six child calls
and fourteen assertions per host. It installed the verified original v1.10.0 Lite
package into a fresh GUID disposable project and upgraded with the actual 1.10.1
manager. It checked manifest v2/profile/target/version, preserved old-style project
configuration, byte-matched the upgraded validator/rules/templates, exercised read-only
Status/CheckVersion/doctor and verified uninstall preservation of configuration and
private runtime evidence. Together the package checks made 26 child calls.

No real project or source checkout was installed. Disposable cleanup checked resolved
paths and reparse points. After checks, the candidate still matched all inventory entries.
No broader Full regression suite or installation matrix was repeated for this Lite patch.

| Private evidence | SHA256 |
| --- | --- |
| Public package, PowerShell 7 | 3074d518f1f07c684e04fd8b5ca49ca7886bea07a4133ba80125ef8eec635613 |
| Public package, PowerShell 5.1 | abdf7ad8c843b88e801444c5b99d0e66651da6b0eea25a950f3fd5e0c9218fb3 |
| Lite upgrade, PowerShell 7 | 1ea5ed4f4859032f2a6717c2626bb6d08bfa452ee1d132a11ad66f16e91b1aab |
| Lite upgrade, PowerShell 5.1 | 1018adc3d333a2993b3622ae7d704600f52739469d00a663f5d41ef2a4d0ea1e |
| Lite upgrade harness | 4d005e00cbf7083bae7eb53176781bf54541c5cc656ee82019be691679b4a72a |

## Compatibility and limits

Previously accepted malformed or over-budget executable Lite handoffs may now fail
with a diagnostic. The authorized writer corrects the record; validation never rewrites
it. Existing valid commands, finite owner extensions, non-executable waits and advisory
capability behavior remain supported. Full remains the new-install default and Lite
still supports SkillTarget none. Existing profile switching and manager protection
rules remain in force.

These checks establish only their recorded parser, installation and inventory behavior.
They do not authenticate review authors or original host transcripts, prove host Skill
loading, all-agent adherence, business acceptance, token savings or real deployment.
The release adds no background scheduler or global configuration change.
