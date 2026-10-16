# 宿主能力

[English](host-capabilities.md)

本文描述九个受支持的项目本地 SkillTarget。这是静态能力视图：说明所选包副本会在何处被发现，以及规范阅读路径在哪里。它不能证明宿主会加载规则、遵循规则或激活 ai-collaboration。

## 规范阅读始终适用

包安装后，规范契约可在以下位置阅读：

- `docs/ai-collaboration/README.md` 与 `docs/ai-collaboration/agent-prompts.md`
- 七个包 Skill 位于 `docs/ai-collaboration/skills/<name>/SKILL.md`：
  - 四个 CE Skill：`ce-code-review`、`ce-debug`、`ce-simplify-code`、`ce-compound`；
  - 三个入口 Skill：`ai-collab-requirements`、`ai-collab-start`、`ai-collab-continue`。
  每个入口 Skill 是简短操作契约，指回受维护的角色契约；不替代它们。

无法发现副本的工具可直接阅读这些文件。缺少可选副本不是缺少前置条件。规范阅读与所选副本使用相同说明；切勿手工编辑生成的工具目录。

## 九个目标

下列目的地来自 `docs/ai-collaboration/compound-skills.manifest.json`。管理器自身表格由包测试对照此文件校验。

| SkillTarget | 项目本地发现目录 | 说明 |
| --- | --- | --- |
| `agents` | `.agents/skills/` | 通用 agents 目录 |
| `codex` | `.codex/skills/` | Codex 项目 Skill |
| `claude` | `.claude/skills/` | Claude 项目 Skill |
| `cursor` | `.cursor/skills/` | Cursor 项目 Skill |
| `opencode` | `.opencode/skills/` | OpenCode 项目 Skill |
| `antigravity` | `.agent/skills/` | Antigravity 使用 `.agent` 根 |
| `gemini` | `.gemini/skills/` | Gemini 项目 Skill |
| `iflow` | `.iflow/skills/` | iFlow 项目 Skill |
| `qwen` | `.qwen/skills/` | Qwen 项目 Skill |

`none` 为默认：不安装发现副本，规范文件即为唯一部署契约。

## 选择规则

- 每次安装最多选择一个 SkillTarget：`manage.ps1 -SkillTarget <target>`。更改须卸载后重新安装；管理器从不添加第二个控制器或第二个目标。
- 管理器仅在所选目标下写入七个包 Skill，并在归属清单中记录每个副本。它不触碰其他 Skill、全局 Skill 目录或宿主设置。
- 入口 Skill 仅作为规范文件在所选目标下的副本安装。`none` 为默认，仅部署规范文件。

## Codex 发现说明

- 新 Codex 部署推荐的 SkillTarget 是 `agents`（`.agents/skills/`），即官方 Codex Skills 文档列出的项目发现与显式 `$` 调用的仓库 Skill 位置。
- 现有 `codex` 目标（`.codex/skills/`）为兼容早期安装而保留。不要手工切换已安装目标；请卸载后重新安装。
- 特定宿主是否加载任一副本，须在有授权试点中的真实宿主会话确认前均为未知。在此之前，对 `docs/ai-collaboration/skills/<name>/SKILL.md` 的规范阅读是受支持的回退。
- 同名但未拥有的 Skill 属于项目内容，在 install、upgrade 与 uninstall 后仍保留。

## 阅读 Doctor 输出

对所选目标运行只读诊断：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.8.0' -Host codex
```

对 `-Host <target>`，报告为以下三者之一：

- `pass`：所选发现副本存在于目标目录下。这仅表示可发现性；宿主加载仍为 `unknown`。
- `warn` 并附升级说明：来自较旧包的安装尚无入口 Skill 副本。请用携带它们的包升级；诊断从不手工复制。
- `warn`：不存在副本。可选副本缺失，适用规范阅读。这不导致诊断失败。
- `fail`：拥有的副本缺失或漂移。在任何管理动作前先协调该路径。

未知或不支持的宿主报告 `unknown` 及规范阅读路径。不会被阻塞，也不推断任何集成。

## 本文不确立的内容

- 实际加载、规则遵循与工具特定行为不能由文件存在证明。它们需要授权试点中的真实宿主会话。
- 所选 Skill 副本不授权任务。任务选择、disabled 模式、角色限制与负责人授权仍在 `AGENTS.md` 与 `README.md` 中。
- 包不修改任何全局 Skill、宿主设置、网络源或生成目录。
