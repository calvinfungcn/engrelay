# Host Capabilities

[Simplified Chinese](host-capabilities.zh-CN.md)

This note describes the nine supported project-local SkillTargets. It is a
static capability view: it explains where a selected package copy would be
discovered and where the canonical reading path is. It does not prove that a
host loads the rules, follows them or activates ai-collaboration.

## Canonical Reading Always Applies

When the package is installed, the canonical contracts are readable at:

- `docs/ai-collaboration/README.md` and `docs/ai-collaboration/agent-prompts.md`
- `docs/ai-collaboration/skills/<name>/SKILL.md` for the seven package Skills:
  - four CE skills: `ce-code-review`, `ce-debug`, `ce-simplify-code`, `ce-compound`;
  - three entry skills: `ai-collab-requirements`, `ai-collab-start`, `ai-collab-continue`.
  Each entry Skill is a short operation contract that points back to the maintained
  role contracts; it does not replace them.

A tool that cannot discover a copy may read these files directly. A missing
optional copy is not a missing prerequisite. Canonical reading and a selected
copy use the same instructions; never edit a generated tool directory by hand.

## The Nine Targets

The destinations below come from `docs/ai-collaboration/compound-skills.manifest.json`.
The manager's own table is checked against this file by the package tests.

| SkillTarget | Project-local discovery directory | Notes |
| --- | --- | --- |
| `agents` | `.agents/skills/` | Generic agents directory |
| `codex` | `.codex/skills/` | Codex project skills |
| `claude` | `.claude/skills/` | Claude project skills |
| `cursor` | `.cursor/skills/` | Cursor project skills |
| `opencode` | `.opencode/skills/` | OpenCode project skills |
| `antigravity` | `.agent/skills/` | Antigravity uses the `.agent` root |
| `gemini` | `.gemini/skills/` | Gemini project skills |
| `iflow` | `.iflow/skills/` | iFlow project skills |
| `qwen` | `.qwen/skills/` | Qwen project skills |

`none` is the default: no discovery copy is installed and the canonical files
are the only deployed contract.

## Selection Rules

- Select at most one SkillTarget per installation with
  `manage.ps1 -SkillTarget <target>`. Changing it requires uninstall and a fresh
  install; the manager never adds a second controller or a second target.
- The manager writes only the seven package Skills under the selected target
  and records each copy in the ownership manifest. It does not touch other
  Skills, global Skill directories or host settings.
- The entry Skills are installed only as copies of the canonical files under that
  one selected target. `none` is the default and deploys only the canonical files.

## Codex Discovery Note

- For a new Codex deployment, the recommended SkillTarget is `agents`
  (`.agents/skills/`), which is the repository skill location that the official
  Codex Skills documentation lists for project discovery and explicit `$` calls.
- The existing `codex` target (`.codex/skills/`) is kept unchanged for compatibility
  with earlier installations. Do not switch an installed target by hand; use
  uninstall and a fresh install.
- Whether a specific host loads either copy is unknown until a real host session in an
  authorized pilot confirms it. Until then, canonical reading of
  `docs/ai-collaboration/skills/<name>/SKILL.md` is the supported fallback.
- Unowned Skills with the same names are project content and survive install,
  upgrade and uninstall.

## Reading The Doctor Output

Run the read-only diagnosis for a selected target:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.8.0' -Host codex
```

For `-Host <target>` the report states one of three things:

- `pass`: the selected discovery copies are present under the target directory. This is
  discoverability only; host loading remains `unknown`.
- `warn` with an upgrade note: an installation from an older package has no entry
  Skill copies yet. Upgrade with the package that carries them; the diagnosis never
  copies them by hand.
- `warn`: no copies exist. The optional copy is absent and canonical reading
  applies. This does not fail the diagnosis.
- `fail`: an owned copy is missing or drifted. Reconcile that path before any
  management action.

An unknown or unsupported host reports `unknown` with the canonical reading
path. It is not blocked and no integration is inferred.

## What This Does Not Establish

- Actual loading, rule obedience and tool-specific behavior are not verified
  by file presence. They require a real host session in an authorized pilot.
- A selected Skill copy does not authorize a task. Task selection, disabled
  mode, role limits and owner authorization stay in `AGENTS.md` and
  `README.md`.
- No global Skill, host setting, network source or generated directory is
  modified by the package.
