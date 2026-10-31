# EngRelay 交接演示（仅源码样例）

[English](README.md) · [快速上手](../../docs/quickstart.zh-CN.md) · [源码 README](../../README.zh-CN.md)

本样例为首次交接试用提供固定、简短的任务，使你无需自行编写需求。会话 A 准备交接；
没有 A 聊天历史的新会话 B 读取实时文件并完成工作。

本目录**仅属于源码**。`.gitattributes` 为 `/examples/handoff-demo` 设置了
`export-ignore`，因此安装包和 GitHub 自动生成的源码 ZIP 都不包含它，安装器也不会把它
复制到目标项目。

## 状态

- 本样例是**本地候选**。目前尚未发布包含它的公开提交 SHA。请记录你检出的提交，或离线副本
  已核对的文件哈希。
- 两次新目录内部演练与外部首次试用（G0）记录在
  [试用证据](../../docs/reviews/improve-first-handoff-trial/trial-evidence.md)。在那里记录前，
  本样例不应视为已验证的十分钟路径。

## 样例内容

| 路径 | 用途 |
| --- | --- |
| `fixture/AGENTS.md` | 演示项目的简短英文指令 |
| `fixture/.gitignore` | 忽略运行态、安装备份和宿主副本 |
| `fixture/labels.ps1` | `Normalize-DemoLabels`，含一个初始缺陷 |
| `fixture/test-labels.ps1` | 四组行为检查；任一失败时退出码为 1 |
| `fixture/openspec/` | `normalize-demo-labels` 需求及其唯一未完成的任务 |

原始样例有两个可见症状，退出码为 1：

- 空白标签被保留：`blank values are ignored` 失败，显示 `expected [a] actual [, a]`；
- 空结果返回 `$null` 而非空数组：`empty array` 失败，显示 `result is $null, not an array`。

其余两组通过。检查直接捕获返回值，因此能发现被展开的标量或 `$null`，而不会将其掩盖。

## 三个目录

| 目录 | 角色 |
| --- | --- |
| 源码检出 | 本 `fixture/` 文件夹的只读来源。不要安装到其中，也不要作为试用项目。 |
| 完整安装包 | 可信且未修改的 v1.10.1 Full 包（`engrelay-1.10.1`）。其 SHA256 必须与发布记录一致。 |
| 一次性项目 | 每次运行新建的空目录，与前两者分开。 |

前提与[快速上手](../../docs/quickstart.zh-CN.md)相同：Windows、Git 与 PowerShell 7（`pwsh`）。
Windows PowerShell 5.1 不满足该前提。

## 获取样例

二选一：

1. 包含本目录的提交的 Git 检出。记录提交 SHA。
2. 本 `fixture/` 文件夹的离线副本，且其文件 SHA256 与试用证据中记录的值一致。

不要用 GitHub 自动生成的源码 ZIP 获取本样例。它由 `git archive` 生成，而 `export-ignore`
会把本目录从该输出中去掉。

## 步骤

### 1. 建立一次性项目

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

提交身份只通过这一条命令传入，不修改全局 Git 设置。提交后 `git status --short` 应为空。

### 2. 确认初始缺陷

```powershell
pwsh -NoProfile -File ./test-labels.ps1
```

预期：出现两行 `FAIL`（`empty array` 与 `blank values are ignored`），退出码为 1。

### 3. 安装完整包

从已解压的完整包根目录运行安装器，而不是从源码检出。默认即为 Full 配置，SkillTarget 默认为 `none`。

```powershell
Set-Location 'E:\Packages\engrelay-1.10.1'
& .\scripts\manage.ps1 -Action Install -ProjectRoot $trial -WorkflowMode optional
Set-Location $trial
```

### 4. 会话 A：准备交接（仅 start）

在一次性项目中打开会话 A，并发送：

```text
Use EngRelay for this task. Read docs/ai-collaboration/skills/ai-collab-start/SKILL.md
in this trial project and use ai-collab-start for the OpenSpec change
openspec/changes/normalize-demo-labels/.
Prepare only .ai/current-task.md and a complete .ai/handoff.md for Session B;
do not implement the task in Session A. Communicate in Chinese.
```

会话 A 应把工作路由到实施角色，并给出完整的 Operator Command。若它先路由到其他步骤，
须先完成该步骤，再启动会话 B。

### 5. 备份会话 A 的交接

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

`.ai/handoff.A.md` 仅留在本地。会话 B 读取的是现行 `.ai/handoff.md`，而非备份。

### 6. 会话 B：在新会话中接续

在同一个一次性项目中打开新的代理会话。不要粘贴会话 A 的聊天内容。发送以下文字，然后从现行
`.ai/handoff.md` 中原样复制完整的 `## Operator Command` 代码块：

```text
Use ai-collab-continue: continue the latest authorized handoff in this project.
The Operator Command follows.
```

不要粘贴 `<batch id>` 之类的占位符。若命令缺失或不完整，应返回会话 A。

### 7. 检查结果

```powershell
pwsh -NoProfile -File ./test-labels.ps1
```

预期：四行 `PASS` 且退出码为 0。另确认会话 B 已勾选
`openspec/changes/normalize-demo-labels/tasks.md` 中的任务，且最终交接给出了有效的下一步。
运行现行交接所指定的结构检查，例如：

```powershell
& .\docs\ai-collaboration\scripts\validate-runtime-state.ps1 -WorkspaceRoot $trial
```

结构检查通过并不证明业务行为或宿主加载正确。四组行为检查只证明本样例功能。

## 记录一次试用（G0 最小记录）

在笔记中写下以下字段，未知时写 `未测`：

- 匿名参与者编号；
- 包版本与源码版本，以及源码提交或样例文件哈希；
- 环境：Windows 版本、`pwsh` 版本与代理宿主；
- 首次尝试还是重试，以及是否有人补充缺失信息；
- 标准操作与任何额外救援（例如解释需求，或由观察者修改复制的命令）；
- 结果：通过或失败，并记录观察到的退出码；
- 核心耗时与完整耗时；
- 最难的步骤，以及参与者是否愿意再次使用。

不要求填写 token、费用或遥测字段。共享材料中不要包含私人路径和账号名。

## 限制

- 本样例的内部变更按设计为 S 级。最初两次观察（02、03）中，会话 A 将其归为 `M`，路由止于独立
  Code Reviewer 派发。补充 `fixture/AGENTS.md` 的范围说明后，修复轮的两次新目录演练归为 `S` 并由自检关闭；
  自检不能替代独立审查。
- 通过本样例不证明宿主加载、所有宿主的遵从性或 token 节省。
- 外部首次用户试用不属于本样例。失败或经救援的尝试按实际发生情况记录。
