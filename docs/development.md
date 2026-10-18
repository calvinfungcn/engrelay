# EngRelay development and maintenance

[Simplified Chinese](development.zh-CN.md)

The GitHub repository is the maintained public source. The initial public baseline
is v1.7.0, commit `9c26c22266625aa04822637baf8f283763362677`, under MIT.
The current release baseline is v1.9.2. Local maintenance setup does not create an active
business batch or authorize publication.

## Start here

Read AGENTS.md, the README in your language, this guide, openspec/config.yaml,
the baseline spec, and any relevant active change. Read .ai/current-task.md and
.ai/handoff.md only when the current task explicitly uses the role workflow and
those files actually exist. Do not copy old closed runtime state into this clone.

The source responsibilities are:

| Path | Responsibility |
| --- | --- |
| payload/ | Canonical product rules, templates, Skills and runtime tools |
| agent-rules.md | Managed activation and role-entry rules |
| scripts/ | Official package management, snapshot and focused fixture checks |
| openspec/ | Source-only maintenance requirements, designs, tasks and archives |
| docs/development.md | Maintainer workflow; not a second task checklist |
| .ai/ | Ignored local notes, fixtures, logs and build artifacts |
| .agents/, .codex/ | Ignored local host tooling; not deployable product Skills |

Generated OpenSpec Skills are local tool entry points. Keep them generated;
change product Skills only under payload/. If a workstation has the ignored
`.codex/bin/apply_patch.ps1`, use it for patch edits. It is a local helper, not a
portable package dependency. Do not copy workstation config or credentials.

## Local Superpowers copies

The public package does not bundle Superpowers. If ignored host copies show
outdated env-var examples in systematic-debugging, refresh from the original
install source as a separate machine maintenance task; do not edit generated
copies in this repository.

## Requirements and work

The baseline spec summarizes the released contracts; product source and fresh
evidence determine actual behavior. It is not a fresh acceptance report or a
second copy of the old review history. New behavior requires an appropriate
OpenSpec change. Use that change's tasks.md as the sole implementation checklist.
Do not automatically create another lifecycle or reopen a closed historical batch.

Small stable-scope tasks stay with the current responsible agent. Preserve role
capability limits, independent M code review, required independent H verification,
and the cumulative verdict/finite owner-continuation rules. Only an explicitly
selected role workflow creates runtime task/handoff records.

Current scope does not include an OmO-style runtime scheduler, dependency-graph
engine, automatic wake-up or background agent manager. Evaluate such additions
as new requirements with costs and alternatives. Existing role/handoff methods
can use host delegation capabilities when actually available.

## Source checkout versus complete package

The development checkout contains source-only OpenSpec files and ignored host
tools. Do not install from it or regenerate its last-release snapshot merely to
absorb development files. The tracked snapshot.json identifies the previous
release inventory until the next reviewed release refreshes it from staging.

The downloaded complete release is immutable installation input. Never install
EngRelay into this source repository. Lifecycle tests use checked GUID-named
disposable roots, not real projects. Real deployments require their own task.

## Build and release flow

1. Finish a coherent change and its relevant review; synchronize both README
   editions when public behavior changes. Choose the intended package version
   and update CHANGELOG.md with its date, changes, and verification limits before
   exporting the release candidate.
2. Export an explicitly reviewed commit into a new disposable staging directory
   using git archive. The committed .gitattributes excludes openspec/ and
   docs/reviews/ from this installation export. Ignored runtime/host directories
   are not Git input.
3. Run the staging copy of scripts/update-snapshot.ps1 with -Version <version>
   and -ForRelease. This records actual export bytes and rejects private/tool
   directories and common sensitive filenames. It is not an exhaustive secret scan.
4. Check the exact file set and hashes, and run only checks justified by changed
   behavior. Run lifecycle fixtures on the staging package, keeping logs outside
   it. Test version expectations must be updated when the release version changes;
   the current smoke script contains v1.9.2 expectations; its optional frozen
   v1.6.1 fixture remains a separate historical check.
5. After the release candidate is stable, copy its snapshot.json back to the
   source as release metadata and ensure a fresh export matches. Keep immutable
   tags/archives and old packages. Publishing or pushing is a separately requested
   operation; development setup does not perform it.

Example export after the intended changes and attributes are committed:

```powershell
$engrelayBuild = Join-Path ([IO.Path]::GetTempPath()) ('engrelay-build-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $engrelayBuild | Out-Null
git archive --format=zip --output "$engrelayBuild/source.zip" HEAD
Expand-Archive -LiteralPath "$engrelayBuild/source.zip" -DestinationPath "$engrelayBuild/package"
& "$engrelayBuild/package/scripts/update-snapshot.ps1" -PackageRoot "$engrelayBuild/package" -Version '<next-version>' -ForRelease
```

Replace <next-version> with the chosen major.minor.patch value. Check command
failures before continuing. The example is an export workflow, not an automatic
installer, release, rollback, cleanup or permission grant.

## Proportional verification

Documentation/configuration preparation needs structural/reference checks and
review of the actual diff. An OpenSpec validation pass proves artifact structure.
It does not prove business behavior, host loading, authorization or independence.
Reuse prior evidence only within its matching inputs and scope. Explain a
substantial low-benefit or unexpectedly expensive option and recommend a smaller
one before asking the owner to choose it. Do not repeat the full historical suite
because an agent, role, handoff, filename or bookkeeping record changed.

`scripts/test-skill-discovery-guidance.ps1` builds its no-guidance baseline from
git ref `9c26c22266625aa04822637baf8f283763362677` by default (`-BaselineGitRef`
overrides). Candidate verification uses the supplied complete package root.

## Local setup and next conversation

Continue maintenance in the current source checkout. Keep workstation setup
notes under the ignored .ai/ directory; those notes do not become a live task.

Copyable starting prompt:

```text
Working directory: <your EngRelay source directory>.
First read AGENTS.md, README.md, docs/development.md, and openspec/config.yaml,
then check the active changes against the actual code.
Current requirement: <describe the requirement>.
Handle small tasks according to their actual impact; use the existing OpenSpec
capabilities when a formal change is needed.
During implementation, maintain only the relevant change's tasks.md. Do not copy
runtime state from earlier batches or reset the cumulative review count.
Check only the affected behavior. Before proposing an option with high cost and
limited benefit, explain its cost, a smaller alternative, and your recommendation.
This task does not automatically authorize publication, real deployment, global
configuration changes, or building a runtime orchestration engine.
```
