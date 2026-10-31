# EngRelay 快速上手（首次试用指引）

[English](quickstart.md) · [README](../README.zh-CN.md) · [操作指南](../payload/docs/ai-collaboration/operator-guide.zh-CN.md)

本指引介绍在干净、独立的一次性项目中首次试用 EngRelay 的操作流程。
内容涵盖目录边界、环境前提、可检查的 Git 基线、会话 A 与会话 B 的交接、
Windows 最小排错以及离线取包方式。

EngRelay 安装包不随附样例产品程序或模拟夹具（fixture）。本指引假定你已经准备好
具有明确目标和说明的试用任务输入。源码仓库另有一份仅限源码的可选样例，见下文第 0 节。

## 配置选择（1.10.0）

1.10.0 已包含 Lite／Full 配置。下文使用默认 Full 及其七个 Skill。Lite 从同一完整包执行 Install 时增加
`-WorkflowProfile lite -SkillTarget none`；明确读取提示、隔离运行态、检查和维护
见[自包含指南](../payload/docs/ai-collaboration/lite/README.zh-CN.md)。后续操作省略
配置参数就保持原配置。切换前保存项目配置／任务证据并协调旧入口，再受保护卸载／
安装；无私人 Lite 自动接管或任务迁移。v1.9.6 管理器不能维护 v2；保留对应管理器
及备份。既有入口文件基准显示 Lite 的 AGENTS.md 静态字节少 86.3%，不代表总上下文、
token 或延迟减少。单工件任务／审查记录是协议设计，不证明运行时遵从。第三期有界
S/M/H 与队列演练已有调用证据，结果和审查状态记录在源码审查历史中。证据限于
虚构样本及已观察宿主。本次 context/feedback 改进另有一个 S 接续和一个正常 M 实施接受独立审查；
固定输入证据仅使用文本。
这些证据不证明全宿主遵从或 token 节省。

## 0. 可选：源码专用样例

源码仓库的 `examples/handoff-demo/` 提供一个固定样例，不包含在安装包中。若你不想自备任务，
可把其 `fixture/` 文件夹复制到空的一次性项目，建立 Git 基线，然后按源码仓库中的样例指南
（`examples/handoff-demo/README.zh-CN.md`）执行。在记录到包含该样例的公开提交之前，它只是本地候选；
完整安装包仍须来自可信发行版。样例指南的第 1 步及第 3 至 6 步分别对应本指引第 4 至 6 节的操作；第 2 步和第 7 步是样例自身的检查。
不要使用 GitHub 自动生成的源码 ZIP 获取该样例，因为其中可能不含它。

## 1. 目录边界

试用过程中请明确区分以下三个目录：

| 目录 | 角色 | 说明 |
| --- | --- | --- |
| **开发源码目录** | 仅供维护 | EngRelay 本身的 Git 工作检出（如 `engrelay-github`）。不要从此目录安装，也不要将其作为试用目标。 |
| **完整发行包** | 安装源 | 包含 `snapshot.json` 的可信官方发行解压目录（如 `engrelay-1.10.0/`）。文件集合与字节须保持未修改。 |
| **一次性试用项目** | 目标项目 | 为本次试用专门创建的独立、干净且可丢弃的目录（如 `E:\Projects\trial-project`）。 |

## 2. 环境前提：PowerShell 7（`pwsh`）检查

本次试用明确需要 PowerShell 7（`pwsh`）。虽然 EngRelay 工具包日常支持
Windows PowerShell 5.1 与 PowerShell 7，但本试用流程依赖 `pwsh`。

在开始会话 A 之前，检查 `pwsh` 是否可用且主版本不低于 7：

```powershell
pwsh -NoProfile -Command 'if ($PSVersionTable.PSVersion.Major -ge 7) { $PSVersionTable.PSVersion } else { throw "PowerShell 7 (pwsh) is required" }'
```

如果找不到 `pwsh`，或者环境中只有 Windows PowerShell 5.1（`powershell.exe`），
说明前提未满足。请停止操作，通过受支持的管理流程安装 PowerShell 7，不要继续。
不要把 `powershell.exe` 当作本次通过。本指引不会自动安装软件或修改系统的全局执行策略。

## 3. 离线取包与完整性核对（无法访问 GitHub 时）

如果你的环境无法直接访问 GitHub：

1. 由能访问 GitHub 的协作者从可信 GitHub 发行页面下载对应版本的完整安装包（例如 `engrelay-1.10.1.zip`），并记录可用的已公布完整性信息。若没有公布校验和，由可信协作者在转交前用 `Get-FileHash -Algorithm SHA256` 计算 ZIP 的 SHA256，并通过另一条可信渠道传递哈希。
2. 协作者原样转交该 ZIP 文件，同时提供准确的发行版本号、来源链接以及可用校验和及其来源。
3. 接收者在解压前核对转交的 ZIP（SHA256 用于校验传输是否损坏，不是发布者的数字签名）：

```powershell
$zipPath = 'E:\Transfers\engrelay-1.10.1.zip'
$expectedSha256 = '<published-or-separately-transferred-sha256>'
$actualSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash
if ($actualSha256 -ne $expectedSha256) {
    throw "ZIP 的 SHA256 不一致：期望 $expectedSha256，实际为 $actualSha256"
}
```

4. 接收者将包解压到与一次性试用项目分开的独立目录（完整发行包根目录，不是源码归档）。
5. 若尚未创建一次性试用项目，先单独建立空目录（例如 `E:\Projects\trial-project`）。不要使用开发源码检出，也不要把试用项目放在完整包目录树内。
6. 在解压出的完整包根目录下，以试用项目为 `ProjectRoot` 对 `snapshot.json` 做只读核对：

```powershell
# 完整包根目录（不是试用项目目录）：
$engrelayPackageRoot = 'E:\Packages\engrelay-1.10.1'
$trialProject = 'E:\Projects\trial-project'
if (-not (Test-Path -LiteralPath $trialProject -PathType Container)) {
    New-Item -ItemType Directory -Path $trialProject | Out-Null
}
Push-Location $engrelayPackageRoot
& .\scripts\manage.ps1 -Action CheckVersion -ProjectRoot $trialProject
Pop-Location
```

成功时输出包含 `installed=not-installed`（试用项目尚未安装 EngRelay）。请区分两种不同失败结果：

- **试用项目目录不存在**（跳过步骤 5）：命令终止并报 `ProjectRoot must be an existing directory`。
- **包内文件集合或与 snapshot 记录的哈希不一致**：例如 `Package file set differs from snapshot` 或 `Package integrity mismatch: <path>`。

- 务必区分完整发行包与源码归档（即使源码 ZIP 包含 `snapshot.json`，也不能假定它与发行清单匹配）；
- 不要杜撰非官方镜像地址；
- 不要修改 `snapshot.json` 来掩盖缺失文件；
- SHA256 一致用于检查传输完整性，不是发布者的数字签名，也不能独立证明来源可信；须通过可信渠道确认发行来源和转交者；
- 若来源无法确认或清单不匹配，应重新获取可信完整包，不要直接安装。

## 4. 试用准备：建立 Git 基线

在打开会话 A 之前，在一次性试用项目目录中建立干净、可检查的 Git 基线：

1. 进入一次性试用目录，初始化 Git：

```powershell
cd E:\Projects\trial-project
git init
```

2. 配置 `.gitignore`，确保运行态、安装备份与宿主缓存不被跟踪：

```gitignore
.ai/
.ai-collaboration-install/
.agents/
.codex/
```

3. 仅显式暂存已准备好的任务输入文件与 `.gitignore`：

```powershell
$paths = @(
    'E:\Projects\trial-project\TASK.md'
)
git add .gitignore @paths
```

4. 如果未配置 Git 用户身份，仅在当前试用仓库进行局部配置（不更改全局 Git 设置）：

```powershell
git config user.name "Trial User"
git config user.email "trial@example.com"
```

5. 提交基线：

```powershell
git commit -m "chore: initial baseline for trial"
```

6. 核对基线：

```powershell
git log -1
git status --short
```

确认初始提交已生成、`git status --short` 状态干净可解释，且 `.ai/`、`.ai-collaboration-install/` 和宿主缓存目录不在提交或暂存中。

## 5. 安装 EngRelay 到试用项目

从完整发行包根目录运行安装命令：

```powershell
$engrelayProject = 'E:\Projects\trial-project'
Set-Location 'E:\Packages\engrelay-1.10.1'
& .\scripts\manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowMode optional
```

若 Codex 新安装需要宿主发现副本，可根据需要传入 `-SkillTarget agents`。

## 6. 会话 A 与会话 B 交接步骤

试用将职责分为两个会话：会话 A 负责准备交接，会话 B 负责实施。

安装后，将控制台切回一次性试用项目。下面所有 `.ai/` 路径均相对于该项目，
而不是完整包目录：

```powershell
Set-Location 'E:\Projects\trial-project'
```

两个 Agent 会话均以该试用项目作为工作目录打开。

### 会话 A：准备交接

`optional` 模式的安装不会激活工作流，须显式为当前任务选择 EngRelay。
默认 `SkillTarget none` 时，要求会话 A 直接读取已安装的规范 Skill，
不需要宿主发现副本。以上文准备的 `TASK.md` 为例，发送：

```text
本任务使用 EngRelay。读取本试用项目中的
docs/ai-collaboration/skills/ai-collab-start/SKILL.md，
使用 ai-collab-start 为 TASK.md 中已准备好的任务建立输入与交接。
会话 A 只准备 .ai/current-task.md 和给会话 B 的完整 .ai/handoff.md，
不要在会话 A 实施任务。
```

如果实际输入路径不同，将 `TASK.md` 替换为真实路径。该入口按既有
[操作指南](../payload/docs/ai-collaboration/operator-guide.zh-CN.md)准备批次并路由下一角色，
不实施任务。只有实时交接已授权实施时才进入 B；若首先需要设计或所有者决策，
先完成相应准备再继续。

当会话 A 产出有效交接后、打开会话 B 之前，备份会话 A 的交接文件：

1. 备份交接文件：

```powershell
if (Test-Path .ai/handoff.A.md) {
    throw '.ai/handoff.A.md 已存在，不要覆盖已有备份。'
} else {
    Copy-Item -Path .ai/handoff.md -Destination .ai/handoff.A.md
}
$backupHash = (Get-FileHash -Algorithm SHA256 -LiteralPath .ai/handoff.A.md).Hash
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath .ai/handoff.md).Hash
if ($backupHash -ne $sourceHash) {
    throw '备份哈希与 .ai/handoff.md 不一致。打开会话 B 前请停止操作。'
}
```

2. 确认 `.ai/handoff.A.md` 与原件一致（含上方哈希比对）。`Test-Path` 判断可防止已有备份被静默覆盖。
3. 此备份仅作本地凭据核对，不要提交到 Git。会话 B 的输入始终是最新实时的 `.ai/handoff.md`，而不是备份文件。

### 会话 B：执行实施

1. 在一次性试用项目中打开新的 Agent 会话（会话 B）。
2. 从当前实时的 `.ai/handoff.md` 中找到 `## Operator Command` 代码块。
3. 完整复制命令文本，原样粘贴给会话 B。
4. 严禁直接粘贴带有占位说明的模板文本（例如 `<next role>`、`<batch id>` 或 `<authoritative paths>`）。占位符是说明标签，不是可执行输入。
5. 若 `.ai/handoff.md` 不存在、仍包含占位符或指定的角色与当前任务不符，请停止操作，返回会话 A 重新生成有效完整的交接；不要绕过角色校验或猜测授权。

## 7. Windows 最小排错

本节仅针对试用中观察到的两种具体故障提供最小处理方法，不扩展到其他故障或深度诊断。

### 故障 1：文件或目录被占用

- **现象**：脚本或文件操作失败，提示文件正由另一进程使用。
- **处理**：
  1. 关闭打开了目标文件的编辑器、IDE 标签或查看器。
  2. 如果有 PowerShell 窗口的当前工作目录正位于目标目录内，使用 `cd ..` 离开该目录。
  3. 仅重试失败的操作。
- **严禁**：运行 `taskkill`、批量强制终止进程或使用递归脚本强行删除目录。

### 故障 2：Codex 沙箱拦截写入

- **现象**：宿主或 Agent 提示写入操作被沙箱拦截或拒绝。
- **处理**：
  1. 核对命令的实际工作目录（`Cwd`）是否在宿主授权的可写工作区范围内。
  2. 按照宿主支持的权限流程确认并授予目标路径所需的写权限。
  3. 授权后重试失败的操作；若仍然被拒绝，保留错误信息并说明尚未解决。
- **严禁**：尝试绕过沙箱限制、关闭宿主安全特性或更改系统全局权限。

## 8. 相关阅读

- [README](../README.zh-CN.md) · [English](quickstart.md)
- [操作指南](../payload/docs/ai-collaboration/operator-guide.zh-CN.md)
- [完整角色规则](../payload/docs/ai-collaboration/README.md)
