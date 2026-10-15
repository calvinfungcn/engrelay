# Design

## Context

动机见 [proposal.md](proposal.md)。实际源码有如下可复用边界：

- `scripts/manage.ps1` 默认 `SkillTarget=none`；Get-Plan 用同一目标表计算规范文件和可选七个 Skill 的发现副本。
- 首次 Install 完成 Save-State 后，仅向成功流输出 `Installed: ... tracked files; Skill target ...; WorkflowMode ...`。重复 Install 是独立的只读返回分支；显式改目标会拒绝，Upgrade 从清单读取已有目标。
- `payload/docs/ai-collaboration/host-capabilities.md` 已说明新 Codex 选择 agents、codex 兼容路径和规范读取回退，本批无需修改它。
- 部署指纹只取包版本、agent-rules 和 payload 内容；因此只改管理器提示、顶层 README 和聚焦测试，不会额外改变部署内容。完整包字节清单仍必须在干净测试暂存目录更新。
- `scripts/test-public-package.ps1` 提供 GUID 夹具、路径约束、子进程退出码和项目哨兵模式，但没有聚焦用例选择，且以合并后的原生进程文本为主。直接复跑其全部历史升级场景既不能充分证明流分离，也不是本批必要证据。

创建此设计文档是因为成功流与可见信息流的兼容边界需要在编码前确定，不是新增架构或数据模型。

## Goals / Non-Goals

**Goals:**

- 最小方案是在首次 Install 的既有成功出口之后附加两至三条信息，复用已解析的目标表与 ProjectRoot，不新增文件操作或清单决策。
- 规范与发现路径指向安装目标，不让用户去发行源的 payload 手工复制。首次可演示结果是 none/agents 安装输出与实际文件、清单相符。
- 本设计未增加已授权范围外的产品行为，所有实施条目只保存在本变更 tasks.md。

**Non-Goals:**

- 不修改 payload、agent-rules、受支持布局登记或默认参数，不添加管理动作、依赖、通用测试框架、模型选型器或宿主检测。
- 不向 Status、Adopt、Upgrade、失败分支或重复 Install 自动添加提示，不重写既有消息。已有安装的补充解释由 README 承担。
- C1–C5 能力建议在后续独立批次设计和实施，不用本批提前改变交接协议。

## Decisions

### 1. 使用独立信息流并保持原成功返回

保留现有成功 Write-Output 的内容及数量。新增提示使用 `Write-Information -InformationAction Continue`，不新增 Warning/Error，不修改全局或调用方偏好变量，不询问输入。信息包含：所选 SkillTarget；目标项目内规范读取路径；非 none 时的实际发现目录，或 none 时“本次未部署发现副本”；宿主加载仍待实际会话确认。所有非 none 目标的路径都从既有目标表取值，不另建映射。

选择理由：将提示继续写到成功流会改变脚本调用者接收的数据；只写 Verbose 或默认被隐藏的信息则无法解决操作者看不到下一步的问题。Microsoft 的 [Write-Information 文档](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-information?view=powershell-5.1)说明信息流从 PowerShell 5.0 起存在，显式 Continue 可显示消息而不修改偏好变量。

兼容承诺限于原成功消息、PowerShell 成功流及退出结果。调用者使用 `6>&1`、`*>&1` 或直接捕获原生进程屏幕文本时会收到附加信息，不能承诺整段 stdout 字节完全一致；双语说明应指出可用 `6>$null` 抑制提示。验证必须分别捕获成功流与信息流，而不能只搜索合并文本。

### 2. 对齐使用入口，保留部署选择

两版 README 的安装段紧邻命令说明“默认 none 可直接读取规范文件”，并给出显式 agents 的 Codex 新安装示例，确保示例和说明一致。其他目标继续列出，codex 明确为保留兼容选项；不要重映射 codex 到 agents。

已有 none 安装优先直接读取目标项目的 `docs/ai-collaboration/skills/ai-collab-start/SKILL.md` 等规范文件。只有用户主动要发现副本，才说明现有官方卸载/重装路线和已有修改的协调要求；重复 Install、Upgrade 不负责追加或切换目标。示例不自动执行、不覆盖或删除手工副本。

替代方案：默认改 agents 会改变所有宿主的安装行为；按目录自动检测会误判多工具项目；全目标复制会扩大冲突和维护范围；新增 SetSkillTarget 会引入归属迁移。它们均非本批最小方案。

### 3. 聚焦夹具验证，不扩大产品和发布范围

新增 `scripts/test-skill-discovery-guidance.ps1`，参数为 `-PackageRoot`（可信完整测试包）及可选 `-LogPath`（包外日志）。它只承担本批可观察行为，不引入测试依赖、通用选择器或共享产品模块；借鉴现有安全夹具与哨兵模式。

实施时先写可失败的行为用例，再增加提示。用例在 GUID 命名、已验证包含关系且无重解析点的一次性项目根执行：

| 场景 | 主要证据 |
| --- | --- |
| 默认 none | 安装成功且规范七个 Skill 可读，清单 target=none，没有本次受管发现副本；成功流仍只有原消息，信息流给出实际规范路径 |
| agents 与兼容 codex | 发现副本和信息中的目录符合既有映射，规范文件仍存在；清单目标不被替换 |
| 重复 Install 与同包 Upgrade | 保留原有成功/幂等消息及目标；重复 Install 的项目指纹不变，Upgrade 不额外生成发现目录 |
| 同名不同内容与受管漂移 | 既有拒绝及非零退出继续有效，失败没有成功指引，前后项目指纹不变 |
| 流与偏好兼容 | 分别收集成功流和信息流；抑制 6 号流仍可获得原成功返回；有效 none 不触发 WarningAction Stop，偏好变量未被脚本改写 |

none 安装同时放置一个用户自有发现副本作哨兵，证明信息只描述本包本次行为，而不错误声明目录中不存在任何用户内容。用例检查路径、清单、实际流和文件结果，不把文案逐字匹配当作行为证据。

不从开发目录安装。准备测试输入时先用 git archive 导出 HEAD 公开基线到 GUID 测试暂存目录，逐文件叠加本批已核对的候选管理器、双语 README 与测试脚本，记录覆盖文件和哈希；不复制整工作区、运行态或工具目录。在该干净目录运行其 update-snapshot.ps1 更新临时测试清单，核对完整集合和哈希。保留原版本标识仅用于本地候选验证，不把它作为重发 v1.7.0、可发布包或新验收结论；源码 snapshot 不动，实际发行仍遵守已审阅提交的 git archive 流程。

两个已存在的脚本宿主分别运行聚焦脚本，`$engrelayCandidatePackage` 为上述受控候选包绝对路径，日志位于包外的 `$engrelayCheckLogs`：

```powershell
& 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' -NoProfile -File scripts/test-skill-discovery-guidance.ps1 -PackageRoot $engrelayCandidatePackage -LogPath "$engrelayCheckLogs/windows-powershell.json"
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File scripts/test-skill-discovery-guidance.ps1 -PackageRoot $engrelayCandidatePackage -LogPath "$engrelayCheckLogs/pwsh.json"
```

逐条检查子退出码和诊断，记录实际用例、宿主、耗时与输入版本。测试脚本/临时状态清理失败不得静默视为通过；递归清理前验证最终绝对路径仍在指定 GUID 临时根。当前规划没有执行这些安装检查，不主张它们已通过。

### 4. 设计可行性与审查路由

当前所需路径、映射、成功出口和可用宿主均已确认；实现不依赖账号、真实项目或人工环境设置，可以进入实施。风险保持 M。

设计审查决定：不另派 Design Reviewer。没有复杂性例外、新依赖、数据模型或迁移，首批可直接展示实际输出及规范/发现文件结果；信息流技术选择已有官方文档依据。此决定不是审查 verdict，不消耗或重置计数。实施后仍须独立 Code Reviewer 检查聚焦证据和实际差异；不得由实施者自行给出独立审查结论。

## Risks / Trade-offs

- 信息流被调用者主动合并后改变屏幕文本 → 明确成功流与合并文本的边界，保留原成功行，并验证抑制提示的方式。
- none 被误报成失败或被描述为项目完全没有发现文件 → 只陈述本包本次是否部署发现副本，保留直接读取及用户自有文件。
- 文档引导重装造成额外操作或冲突 → 已有安装优先规范读取，目标调整是操作者主动选择，不提供自动迁移步骤。
- 测试暂存包被误当新发行 → 日志标注仅测试候选，源码清单及已发布内容不变，不发布、不自动提交。
- 聚焦测试遗漏其他宿主真实发现行为 → 复用原目标映射，不改变宿主适配；只证明文件、提示及安装保护，宿主加载仍为未知。

## Migration Plan

本批不需要已安装内容迁移。后续正式发行按开发指南从已审阅提交干净导出并建立新发行清单；升级继续保留原目标。若候选行为不符合验收，在本分支修正候选或撤销本批改动，不改发行标签、旧清单、原始备份或用户已有内容。C1–C5 后续批次单独 Task Intake，不作为本批关闭条件。
