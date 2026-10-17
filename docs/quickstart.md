# EngRelay Quickstart (First Trial Guide)

[简体中文](quickstart.zh-CN.md) · [README](../README.md) · [Operator Guide](../payload/docs/ai-collaboration/operator-guide.md)

This guide walks through a first trial of EngRelay in a clean, disposable project.
It covers directory boundaries, environment prerequisites, an inspectable Git
baseline, the handoff between Session A and Session B, Windows troubleshooting,
and offline package handling.

EngRelay does not bundle sample product applications or mock fixtures. This guide
assumes you already have a prepared task input with clear objectives.

## 1. Directory boundaries

Keep these three directories separate during your trial:

| Directory | Role | Description |
| --- | --- | --- |
| **Development source** | Maintenance only | The working git checkout of EngRelay itself (e.g. `engrelay-github`). Do not install from this checkout, and do not use it as a trial project. |
| **Complete release package** | Installation source | A trusted, extracted release ZIP (e.g. `engrelay-1.8.0/`) containing `snapshot.json`. Files must remain unchanged. |
| **Disposable trial project** | Target project | A fresh, isolated directory (e.g. `E:\Projects\trial-project`) created specifically for this trial. |

## 2. Environment prerequisite: PowerShell 7 (`pwsh`)

This trial requires PowerShell 7 (`pwsh`). While EngRelay supports both Windows
PowerShell 5.1 and PowerShell 7 for general usage, this trial procedure relies on
`pwsh`.

Before starting Session A, check that `pwsh` is available and has major version 7 or newer:

```powershell
pwsh -NoProfile -Command 'if ($PSVersionTable.PSVersion.Major -ge 7) { $PSVersionTable.PSVersion } else { throw "PowerShell 7 (pwsh) is required" }'
```

If `pwsh` is not found, or if only Windows PowerShell 5.1 (`powershell.exe`) is
present, the prerequisite is not met. Stop and install PowerShell 7 through your
approved administrative process before proceeding. Do not treat `powershell.exe`
as meeting this requirement. This guide does not automatically install software
or alter your global execution policy.

## 3. Offline package acquisition (when GitHub is unreachable)

If your environment cannot access GitHub directly:

1. A collaborator with access downloads the complete official release ZIP
   (e.g., `engrelay-1.8.0.zip`) from the trusted GitHub release page and records
   any published integrity information. If no checksum is published, the trusted
   collaborator computes the ZIP's SHA256 with `Get-FileHash -Algorithm SHA256`
   before transfer and sends that hash through a separate trusted channel.
2. The collaborator transfers the ZIP without modification, accompanied by the
   exact release version, source URL, and the available checksum and its origin.
3. The recipient verifies the transferred ZIP before extracting (SHA256 checks
   transfer integrity; it is not a publisher signature):

```powershell
$zipPath = 'E:\Transfers\engrelay-1.8.0.zip'
$expectedSha256 = '<published-or-separately-transferred-sha256>'
$actualSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash
if ($actualSha256 -ne $expectedSha256) {
    throw "ZIP SHA256 mismatch: expected $expectedSha256 but got $actualSha256"
}
```

4. The recipient extracts the package into an independent directory that stays
   separate from the disposable trial project (complete release package root,
   not a source-code archive).
5. Create the disposable trial project as its own empty directory if it does not
   already exist (for example `E:\Projects\trial-project`). Do not use the
   development source checkout or place the trial project inside the package
   tree.
6. From the extracted complete package root, run a read-only check against
   `snapshot.json` with the trial project as `ProjectRoot`:

```powershell
# Complete package root (not the trial project):
$engrelayPackageRoot = 'E:\Packages\engrelay-1.8.0'
$trialProject = 'E:\Projects\trial-project'
if (-not (Test-Path -LiteralPath $trialProject -PathType Container)) {
    New-Item -ItemType Directory -Path $trialProject | Out-Null
}
Push-Location $engrelayPackageRoot
& .\scripts\manage.ps1 -Action CheckVersion -ProjectRoot $trialProject
Pop-Location
```

On success, output includes `installed=not-installed`. Recognize two
different failure outcomes:

- **Trial project directory does not exist** (step 5 skipped): the command stops
  with `ProjectRoot must be an existing directory`.
- **Package file set or per-file hash does not match `snapshot.json`**: errors
  such as `Package file set differs from snapshot` or
  `Package integrity mismatch: <path>`.

- Always distinguish the complete release package from a source code archive
  (a source ZIP cannot be assumed to match the release inventory, even if it
  contains `snapshot.json`).
- Do not invent unofficial mirror URLs.
- Do not edit `snapshot.json` to conceal missing files.
- A matching SHA256 checks transfer integrity; it is not a publisher signature
  and does not independently establish source trust. Confirm the release source
  and the collaborator through trusted channels.
- If the source cannot be confirmed or the inventory does not match, obtain a
  trusted package again before installing.

## 4. Trial setup: Git baseline

Before opening Session A, establish a clean, inspectable Git baseline in your
disposable trial project:

1. In the disposable project directory, initialize Git:

```powershell
cd E:\Projects\trial-project
git init
```

2. Configure `.gitignore` so that runtime state, installation backups, and host
   caches are not tracked:

```gitignore
.ai/
.ai-collaboration-install/
.agents/
.codex/
```

3. Stage only your prepared task input files and `.gitignore`:

```powershell
$paths = @(
    'E:\Projects\trial-project\TASK.md'
)
git add .gitignore @paths
```

4. If Git user identity is not set, configure it locally for this trial repository
   only (do not modify global Git settings):

```powershell
git config user.name "Trial User"
git config user.email "trial@example.com"
```

5. Commit the baseline:

```powershell
git commit -m "chore: initial baseline for trial"
```

6. Verify the baseline:

```powershell
git log -1
git status --short
```

Confirm that the initial commit exists, `git status --short` is clean or explainable,
and that `.ai/`, `.ai-collaboration-install/`, and host cache directories remain
untracked.

## 5. Install EngRelay into the trial project

Run the installer from your complete release package directory:

```powershell
$engrelayProject = 'E:\Projects\trial-project'
Set-Location 'E:\Packages\engrelay-1.8.0'
& .\scripts\manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowMode optional
```

For Codex host discovery on a fresh setup, you may optionally pass `-SkillTarget agents`.

## 6. Session A and Session B handoff

The trial splits duties between two sessions: Session A prepares the handoff;
Session B performs implementation.

After installation, switch the console back to the disposable trial project.
All `.ai/` paths below are relative to that project, not the package directory:

```powershell
Set-Location 'E:\Projects\trial-project'
```

Open both agent sessions with this trial project as their working directory.

### Session A: Prepare handoff

Installation in `optional` mode does not activate the workflow. Explicitly select
EngRelay for this task. With the default `SkillTarget none`, ask Session A to read
the installed canonical Skill directly; a host discovery copy is not required.
For the prepared `TASK.md` input above, send:

```text
Use EngRelay for this task. Read docs/ai-collaboration/skills/ai-collab-start/SKILL.md
in this trial project and use ai-collab-start for the prepared task in TASK.md.
Prepare only .ai/current-task.md and a complete .ai/handoff.md for Session B;
do not implement the task in Session A.
```

Replace `TASK.md` with your actual prepared input path if different. The entry
prepares the batch and routes the next role according to the existing
[operator guide](../payload/docs/ai-collaboration/operator-guide.md); it does not
implement the work. Continue with B only when the live handoff authorizes
implementation. If it first requires a design or owner decision, complete that
required preparation before proceeding.

Once Session A produces a valid `.ai/handoff.md`, preserve it before launching Session B:

1. Back up Session A's handoff:

```powershell
if (Test-Path .ai/handoff.A.md) {
    throw '.ai/handoff.A.md already exists. Do not overwrite existing backup.'
} else {
    Copy-Item -Path .ai/handoff.md -Destination .ai/handoff.A.md
}
$backupHash = (Get-FileHash -Algorithm SHA256 -LiteralPath .ai/handoff.A.md).Hash
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath .ai/handoff.md).Hash
if ($backupHash -ne $sourceHash) {
    throw 'Backup hash does not match .ai/handoff.md. Stop before Session B.'
}
```

2. Confirm that `.ai/handoff.A.md` matches `.ai/handoff.md` (the hash check
   above). The `Test-Path` check prevents silently overwriting an existing backup.
3. This backup is a local reference for inspecting Session A's output; do not
   commit it to Git. Session B will read the active `.ai/handoff.md`, not the backup.

### Session B: Execute implementation

1. Open a new agent session (Session B) in the disposable trial project.
2. Locate the `## Operator Command` block in the live `.ai/handoff.md`.
3. Copy the complete command text verbatim and paste it into Session B.
4. Do not paste placeholder text (such as `<next role>`, `<batch id>`, or
   `<authoritative paths>`). Placeholders are explanatory labels, not executable
   instructions.
5. If `.ai/handoff.md` is missing, contains unfilled placeholders, or specifies
   a mismatched role, stop. Return to Session A to generate a valid, complete
   handoff. Do not bypass role validation or guess authorization.

## 7. Windows troubleshooting

This section addresses only two specific, observed Windows issues. It does not
cover broad system diagnostics.

### Issue 1: File or directory in use

- **Symptom**: A script or command fails with an error stating that a file or
  directory is locked or in use by another process.
- **Action**:
  1. Close any editor, IDE tab, or viewer that has the target file open.
  2. If a PowerShell console has its working directory inside the target directory,
     navigate out (e.g. `cd ..`).
  3. Retry only the failed operation.
- **Do not**: Run `taskkill`, force-kill background processes, or force-delete
  directories with recursive scripts.

### Issue 2: Codex sandbox blocks writes

- **Symptom**: The host or agent reports that a file write was blocked by the
  sandbox environment.
- **Action**:
  1. Check that the command's working directory (`Cwd`) matches the authorized
     workspace path.
  2. Follow your host's supported permission request workflow to grant write
     access to the target path.
  3. Retry the operation after access is granted. If writes are still blocked,
     record the error and report that the issue is unresolved.
- **Do not**: Attempt to bypass sandbox restrictions, disable host security
  features, or grant global system permissions.

## 8. Related reading

- [README](../README.md) · [简体中文](quickstart.zh-CN.md)
- [Operator Guide](../payload/docs/ai-collaboration/operator-guide.md)
- [Maintained Role Contracts](../payload/docs/ai-collaboration/README.md)
