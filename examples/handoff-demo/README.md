# EngRelay Handoff Demo (source-only sample)

[简体中文](README.zh-CN.md) · [Quickstart](../../docs/quickstart.md) · [Source README](../../README.md)

This sample gives the first handoff trial a fixed, small task, so you do not need to
write your own requirement. Session A prepares a handoff. A new Session B, with no
chat history from A, reads the live files and finishes the work.

This directory is **source only**. `.gitattributes` marks `/examples/handoff-demo`
with `export-ignore`, so installation packages and GitHub's automatic source ZIP do
not contain it. The package installer never copies it into a target project.

## Status

- Sample source commit: `304aa95702f106da262bcc741576293dfbeddc8d`. On 2026-10-31,
  a fresh checkout from GitHub matched all eight fixture files. See the
  [submission record](../../docs/reviews/improve-first-handoff-trial/submission-preparation.md).
- Two fresh trial runs and the external first-user trial (G0) are tracked in
  [trial evidence](../../docs/reviews/improve-first-handoff-trial/trial-evidence.md).
  Until they are recorded there, the sample is not a verified ten-minute path.

## What the sample contains

| Path | Purpose |
| --- | --- |
| `fixture/AGENTS.md` | Short English instructions for the demo project |
| `fixture/.gitignore` | Ignores runtime state, installation backups and host copies |
| `fixture/labels.ps1` | `Normalize-DemoLabels`, with one initial defect |
| `fixture/test-labels.ps1` | Four behavior checks; exits with code 1 on any failure |
| `fixture/openspec/` | The `normalize-demo-labels` requirement and its single unfinished task |

The original fixture has two visible symptoms and exits with code 1:

- blank labels are kept: `blank values are ignored` fails with `expected [a] actual [, a]`;
- an empty result comes back as `$null` instead of an empty array: `empty array` fails
  with `result is $null, not an array`.

The other two checks pass. The checks capture the return value directly, so they detect
an unrolled scalar or `$null` instead of hiding it.

## Three directories

| Directory | Role |
| --- | --- |
| Source checkout | Read-only source of this `fixture/` folder. Do not install into it or use it as the trial project. |
| Complete package | The trusted, unchanged v1.10.1 Full package (`engrelay-1.10.1`). Its SHA256 must match the release record. |
| Disposable project | A new, empty directory for one run. Keep it separate from the other two. |

Prerequisites are the same as the [Quickstart](../../docs/quickstart.md): Windows, Git
and PowerShell 7 (`pwsh`). Do not treat Windows PowerShell 5.1 as meeting this.

## Get the sample

Use one of these two sources:

1. A Git checkout of the verified source commit below. Record the commit SHA.
2. An offline copy of this `fixture/` folder whose file SHA256 hashes match the values
   recorded in the trial evidence.

```powershell
git clone https://github.com/calvinfungcn/engrelay.git engrelay-demo-source
git -C engrelay-demo-source checkout --detach 304aa95702f106da262bcc741576293dfbeddc8d
```

The fixture is under `engrelay-demo-source/examples/handoff-demo/fixture/`.
Obtain the complete installation package separately from the trusted v1.10.1 release.

Do not use GitHub's automatic source ZIP for this sample. It is produced by
`git archive`, and `export-ignore` removes this directory from that output.

## Steps

### 1. Create the disposable project

```powershell
$trial = 'E:\Projects\handoff-demo-run-01'
New-Item -ItemType Directory -Path $trial | Out-Null
Copy-Item -Recurse -Path 'E:\Path\to\engrelay\examples\handoff-demo\fixture\*' -Destination $trial
Set-Location $trial
git init
git add .
git -c user.name="Demo User" -c user.email="demo@example.com" commit -m "chore: initial baseline for handoff demo"
git status --short
```

The commit identity is passed to this one command only. Do not change global Git settings.
`git status --short` should be empty after the commit.

### 2. Confirm the initial defect

```powershell
pwsh -NoProfile -File ./test-labels.ps1
```

Expected: two `FAIL` lines (`empty array` and `blank values are ignored`) and exit code 1.

### 3. Install the complete package

Run the installer from the extracted complete package root, not from the source
checkout. Full is the default profile and `none` is the default SkillTarget.

```powershell
Set-Location 'E:\Packages\engrelay-1.10.1'
& .\scripts\manage.ps1 -Action Install -ProjectRoot $trial -WorkflowMode optional
Set-Location $trial
```

### 4. Session A: prepare the handoff (start only)

Open Session A in the disposable project and send:

```text
Use EngRelay for this task. Read docs/ai-collaboration/skills/ai-collab-start/SKILL.md
in this trial project and use ai-collab-start for the OpenSpec change
openspec/changes/normalize-demo-labels/.
Prepare only .ai/current-task.md and a complete .ai/handoff.md for Session B;
do not implement the task in Session A. Communicate in English.
```

Session A should route the work to an implementation role with a complete Operator
Command. If it routes to another step first, complete that step before Session B.

### 5. Back up Session A's handoff

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

Keep `.ai/handoff.A.md` local. Session B reads the active `.ai/handoff.md`, not the backup.

### 6. Session B: continue in a new session

Open a new agent session in the same disposable project. Do not paste Session A's chat.
Send the words below, then the complete `## Operator Command` block copied verbatim
from the live `.ai/handoff.md`:

```text
Use ai-collab-continue: continue the latest authorized handoff in this project.
The Operator Command follows.
```

Do not paste placeholders such as `<batch id>`. If the command is missing or incomplete,
return to Session A.

### 7. Check the result

```powershell
pwsh -NoProfile -File ./test-labels.ps1
```

Expected: four `PASS` lines and exit code 0. Also confirm that
`openspec/changes/normalize-demo-labels/tasks.md` has its item checked by Session B, and
that the final handoff names a valid next action. Run the structure check the handoff
names, for example:

```powershell
& .\docs\ai-collaboration\scripts\validate-runtime-state.ps1 -WorkspaceRoot $trial
```

A passing structure check does not prove business behavior or host loading. The four
behavior checks prove only this sample's function.

## Record a trial (G0 minimal record)

Write these fields in your notes. Use `not measured` when a value is unknown:

- anonymous participant ID;
- package and source version, and source commit or fixture hashes;
- environment: Windows version, `pwsh` version and agent host;
- first attempt or retry, and whether a helper supplied any missing information;
- standard operations and any extra rescue (for example, explained requirements or a
  copied command edited by an observer);
- result: pass or fail, with the exit code observed;
- core elapsed time and full elapsed time;
- the hardest step and whether the participant would use the workflow again.

No token, cost or telemetry field is required. Keep private paths and account names out
of shared material.

## Limits

- The sample's change is designed as one S-level check. The first two observed runs (02
  and 03) classified it as `M`, so the route ended at an independent Code Reviewer
  dispatch. After the scope note was added to `fixture/AGENTS.md`, the repair-round runs
  classified it as `S` and closed by self-check. A self-check never replaces an
  independent review.
- Passing this sample does not prove host loading, all-host adherence or token savings.
- External first-user trials are not part of this sample. A failed or rescued attempt
  is recorded as it occurred.
