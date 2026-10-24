# EngRelay Lite

[简体中文](README.zh-CN.md) · [Rules](RULES.md)

This guide covers the local 1.10.0 candidate, not pushed or published. The latest
published release, 1.9.6, does not contain Lite.

Lite is a fixed profile in the shared EngRelay package. It uses Executor and
Reviewer responsibilities and a sequential approved queue. Full keeps the seven
canonical Skills and role chain; Lite has no dedicated Skill or discovery copies.
The unified package version is reported by the manager, with the selected profile.

From a verified complete package outside the project:

```powershell
& ./scripts/manage.ps1 -Action Install -ProjectRoot $project -WorkflowProfile lite -SkillTarget none
& ./scripts/manage.ps1 -Action Status -ProjectRoot $project
```

Installation is optional by default; it creates no business task. In the installed
project tell the agent: "Use EngRelay-Lite for this approved task. Read AGENTS.md,
docs/engrelay-lite/RULES.md, docs/engrelay-lite.config.md and the current task."
A host that does not auto-read AGENTS.md must receive that explicit reading prompt.
EngRelay also selects the installed Lite profile. Full-only ai-collaboration and
ai-collab-* entries are mismatches, not automatic profile switches.

Fill the project-owned docs/engrelay-lite.config.md with verified project commands
and restrictions. Use the [queue](templates/queue.md), [task](templates/task.md)
and [handoff](templates/handoff.md) templates under .ai/engrelay-lite/. Do not copy
another project's live state. Existing OpenSpec scope and tasks.md stay authoritative.
Templates alone do not approve work. Read actual code and module instructions as needed.

For example, an approved S documentation correction with defined acceptance may
finish after relevant self-checks. An M implementation needs independent review
and confirmation of must-fix repairs; an H change retains applicable design review
and independent verification. The default total of three completed verdicts never
resets when changing phase, model or profile. At capacity unresolved work waits
for the owner; there is no fourth autonomous loop.

At each real boundary decide the next values, save/read back and check them:

```powershell
& ./docs/engrelay-lite/scripts/validate-state.ps1 -WorkspaceRoot $PWD.Path `
  -ExpectedTaskId T01 -ExpectedNextAction continue -ExpectedNextRole none `
  -ExpectedReviewRound 0 -ExpectedStateRevision 2
& ./docs/engrelay-lite/scripts/doctor.ps1 -WorkspaceRoot $PWD.Path
```

These example values must be replaced with the state you actually decided. Success
checks structure and supplied expectations only. Diagnostics are read-only. Missing
dispatch capability advice only warns. Current human waits need a real decision or
environment prerequisite; a future notice needs no current action or reply. On
same-role session end save an executable Continuation Command. A later agent must
be started by the actual host; this package does not wake processes automatically.

For a fully read-only review return, pre-name its path in prior Evidence; retain
complete findings and response handoff with metadata: Task ID, Source role, Source
agent, Work producer, Named result, Prior revision, Prior handoff SHA256, Target
revision, Cumulative verdicts and Verdict. Use unique `- Field: value` lines outside
fenced response text. The optional SourceResultPath and PriorHandoffPath arguments
check that explicitly supplied review source against prior bytes. They do not
recover or publish. The authorized writer checks the whole action and ownership,
preserves the full return and publishes once. Conflicts do not apply; never scan
directories or pick the highest revision. Historical Full runtime stays isolated.

Upgrade and SetMode omit WorkflowProfile to retain Lite. To switch profiles, preserve
task evidence and project configuration, coordinate historical project instructions,
then use protected Uninstall/Install with explicit authorization. There is no private
Lite adoption or task migration. Never delete a manifest to bypass a refusal.
Configuration instances and runtime belong to the project and survive uninstall;
package files still reject drift. If configuration is missing, restore project-owned
content deliberately; Upgrade does not silently recreate it.

Keep the matching complete package/manager and original recovery materials. New
manifest v2 cannot be maintained by the v1.9.6 manager. Rollback uses the matching
new manager's protected uninstall or an explicitly approved recovery. Uninstall
retains an inactive v2 manifest: the old manager still refuses it. Before installing
the trusted old package, obtain explicit authorization to archive that inactive
recovery directory intact outside the official state path; retain config/runtime
and original backups. Do not delete an active, interrupted or conflicting manifest
to bypass checks. This is not a direct downgrade. This guidance does not perform
Git operations, deployment or owner acceptance.

See [LICENSE](LICENSE) for retained EngRelay and supplied Lite MIT notices. The
reference-input fingerprint fixes bytes; it does not authenticate authorship or
establish an exhaustive expression/source audit. The existing entry-file baseline
shows 86.3% fewer static AGENTS.md bytes in Lite; this is not a reduction in total
context, tokens or latency. Single-artifact task/review records are a protocol design,
not proof of runtime adherence. The bounded Phase 3 S/M/H and queue pilot now has
invocation evidence; its results and independent review status are recorded in the
source review history. Evidence covers fictional samples on observed hosts; broader
host adherence is unverified. Independent candidate review is complete. A complete
candidate package requires an actual committed export and matching inventory under
the documented build flow; its export evidence is recorded separately. Publication
requires a separate request.
