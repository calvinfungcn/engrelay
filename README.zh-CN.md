# EngRelay · AI 编程协作工具包

**小任务从简，交接可续，交付可查。**

[English](README.md) · [快速上手](docs/quickstart.zh-CN.md) · [角色规则](payload/docs/ai-collaboration/README.md) · [来源与许可](THIRD-PARTY-NOTICES.zh-CN.md)

EngRelay 取自 Engineering + Relay，意为工程接力。它为已有代码库中的 AI 编程
Agent 提供角色提示词、任务和交接模板、按风险引入的独立审查，以及检查交付
证据的工具。

**版本 1.10.1** · [下载完整发行包](https://github.com/calvinfungcn/engrelay/releases/tag/v1.10.1) · [MIT 许可证](LICENSE)

## 工作流配置（1.10.0）

1.10.0 为共用管理器增加 `-WorkflowProfile full|lite`。新安装默认 Full；已有安装
省略参数时保持清单中的配置。WorkflowMode 独立控制启用。Full 拥有七个 Skill
和现有角色链；Lite 只安装[短规则、模板和只读工具](payload/docs/ai-collaboration/lite/README.zh-CN.md)，
使用 `.ai/engrelay-lite/`，初版仅支持 SkillTarget none。Lite 使用明确规范读取，
不自动读取 AGENTS.md 的宿主也须收到明确读取提示。
Lite 项目可记录可选的工具、模型、推理与评审启动偏好；留空不阻塞工作。既有
实施／修复独立审查默认附建议性 1–5 分（或 `not scored`），不新增审查或影响验收。
1.10.1 更新 Lite 校验：检查可执行动作额度、实际动作小节内的完整围栏命令，以及围栏外的来源元数据。

```powershell
& ./scripts/manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowProfile lite -SkillTarget none
```

检查使用隔离的完整工作树测试包；开发检出不是安装源。新安装采用 v2 清单，可信 v1 Full 只在 Upgrade 转换。原 v1.9.6 管理器
拒绝 v2；保留对应完整包、管理器和原恢复材料。Upgrade、重复 Install、SetMode
不切换配置：明确要求切换时先保存证据、协调项目入口，再受保护卸载／安装。
Lite 项目配置和运行态在升级／卸载后仍保留；普通包文件继续拒绝漂移。私人 Lite
不自动 Adopt，未完成任务不自动迁移。既有入口文件基准显示 Lite 的 AGENTS.md
静态字节少 86.3%，不代表总上下文、token 或延迟减少。单工件任务／审查记录是协议设计，
不证明运行时遵从。第三期有界 S/M/H 与队列演练已有调用证据，结果和审查状态记录在
源码审查历史中。本次 context/feedback 改进另有一个 S 接续和一个正常 M 实施接受独立审查；
固定输入证据仅使用文本。这些证据不证明全宿主遵从或 token 节省。安装前核对对应完整包清单。

## 提供哪些功能

| 功能 | 帮助你完成什么 |
| --- | --- |
| 需求澄清与任务分流 | 从明确目标开始；有重要业务歧义时先澄清，再进入设计 |
| 按风险协作 | 按任务需要安排设计、实现、独立审查和验证 |
| 可接续的交接 | 通过已记录的范围、下一动作和证据，在另一 Agent 会话继续工作 |
| 四个 CE 方法 Skill | 代码审查（`ce-code-review`）、根因调试（`ce-debug`）、范围内简化（`ce-simplify-code`）及可复用经验沉淀（`ce-compound`） |
| 只读检查与经验检索 | 诊断安装状态、校验交接结构、搜索已记录的解决经验 |
| 受保护的包管理 | 安装、升级和卸载时检查文件归属，保护项目内容并报告冲突 |

例如，一项功能需求可以按下面的路径推进：

```text
提出需求 → 必要时澄清需求 → 必要时设计
        → 实现并检查 → 按要求独立审查
        → 交接剩余工作或附证据关闭
```

风险允许时，小任务由一个负责 Agent 连续处理。角色表示职责，示例中的每一步
无需单独开启会话。入口选择和交接方式详见[操作指南](payload/docs/ai-collaboration/operator-guide.zh-CN.md)。

## 如何协作

- 普通小任务由一个负责 Agent 连续处理。角色表示职责，不要求每个步骤新开对话。
- 每项任务使用一个主流程。安装默认 `optional`，存放工具包不会启动角色流程。
- 中风险工作需要独立代码审查；高风险工作按规则增加所需独立验证。
- 下一步只选 `continue`、`dispatch` 或 `close`。派发提供完整指令，下一位 Agent
  无需读取之前的聊天即可接续。
- 交接中的 `Human Action Required` 直观显示当前是否需要人类操作；远期环境预告
  无需当前行动或回复。可执行的 `continue` 附自包含接续指令；有能力的活跃 Agent
  应在已有授权内直接继续，自行选择本地 CLI 或 IDE 宿主。执行器结束单次运行
  不代表环境阻塞。工具包提供接续规范，不会自动唤醒进程；详见
  [自主接续规则](payload/docs/ai-collaboration/handoff-schema.md#autonomous-continuation)。
- 恢复过期交接时只读取索引链接的审查记录，或 live 交接（含 Next output files）与当前任务点名的结果或响应路径；新容器须有真实 SHA256 指纹，只有旧版索引链接审查记录与旧版响应交接可省略。一个批次最多恢复一个待应用转移，任何冲突都会阻止恢复。比较动作段落后才判定为已应用。接管可执行 continue 时会递增 `State revision`。计划结束同一角色的会话也是交接边界；长检查可保留一个外置日志检查点，并说明检查尚未通过。
- 块外的项目自有历史声明在项目内协调；安装或升级包不会改写这些内容。
- Agent 派发须在交接 `Current Status` 下给出一行能力建议（`Recommended capability
  tier: C1`–`C5`），仅供为下一项工作选择模型与推理强度时参考；详见
  [能力档位说明](payload/docs/ai-collaboration/handoff-schema.md#capability-tier-guidance)。
  它不是阻塞条件，也不代表模型资格认证；旧交接缺少该行仍有效。
- 参考复用仅限同一会话中已读且已知未变的资料；新 Agent、上下文缺失、输入变化或规则疑问时须重新读取。
- 实施或修复交付的独立审查默认在既有审查记录中附一行建议性 1–5 分（或 `not scored`），最终回复简短复述；它不改变验收、路由或审查计数。
- 进展以既有交接区块中的可观察成果、证据与剩余工作表示。粗略规模与人工投入均为可选，
  不作为路由门槛，也不是完成百分比。
- 检查覆盖实际受影响的行为。结构检查成功不代表业务正确或宿主接入有效。
- 真实交接边界会落盘、回读，并按已决定的批次、动作、下一角色和审查计数做预期核对。
  只读子代理结果由仍活跃的可写 Agent 直接发布或先落盘，并在回复中说明发现；若没有获准写入者，则保留完整响应交接。
  恢复时按指纹匹配，不重新计数审查结论。这些检查不唤醒进程，也不证明真实性；
  详见[预期状态校验](payload/docs/ai-collaboration/handoff-schema.md#expected-state-validation)。
- 普通 `accepted` 关闭须对**最终**交接输入完成结构校验，并将命令、退出码、
  诊断与输入对应关系记录在被检交接之外；详见
  [关闭校验依据](payload/docs/ai-collaboration/handoff-schema.md#accepted-closure-validation)。
  源码仓库的后续事项（例如延后的演示样例、试用与路线图）在 GitHub 的
  [OpenSpec 导航](https://github.com/calvinfungcn/engrelay/blob/main/openspec/README.zh-CN.md)
  维护，安装导出包内不含该导航。

角色流程以 OpenSpec 为需求和任务权威。安装包不会安装或初始化 OpenSpec，
也不会串联另一套编排器。详见[完整角色规则](payload/docs/ai-collaboration/README.md)。

## 安装或升级

使用可信完整包，放在业务项目以外的独立目录。先备份目标项目规则，读取其
现有 Agent 指令。新项目示例：

从发行页面下载 `engrelay-1.10.1.zip`，解压后进入 `engrelay-1.10.1` 目录执行命令。
保留完整包原样；额外工具文件或字节修改会使它与清单不匹配。仓库源码仅在
实际文件集合和字节与 `snapshot.json` 完全一致时，也可作为安装源。

```powershell
$engrelayProject = 'E:\Projects\your-project'
& .\scripts\manage.ps1 -Action CheckVersion -ProjectRoot $engrelayProject
# 默认 SkillTarget 为 none：只安装规范 Skill（在目标项目内直接读取）。
& .\scripts\manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowMode optional
# Codex 新安装需要宿主发现副本时，首次 Install 显式选择一个目标，例如：
# & .\scripts\manage.ps1 -Action Install -ProjectRoot $engrelayProject -SkillTarget agents -WorkflowMode optional
& .\scripts\manage.ps1 -Action Status -ProjectRoot $engrelayProject
& .\payload\docs\ai-collaboration\scripts\doctor.ps1 -WorkspaceRoot $engrelayProject -PackageRoot $PWD.Path
```

首次 Install 成功后，管理器仍在 PowerShell 成功流输出原有成功行，并在信息流
追加简短指引（所选目标、规范读取路径，以及适用时的发现目录）。宿主是否加载
仍须在实际会话中确认。若只需隐藏指引，可在 Install 调用中使用 `6>$null` 重定向
第 6 路输出；合并流或捕获原生进程屏幕文本时可能包含附加行。

已有有效受管清单时使用官方 `Upgrade`。只有无清单且匹配已知旧布局时，才先
`Adopt -Preview`、再 `Adopt`。冲突会报告具体路径；保留本地修改，解决后再重试。
管理器没有强制覆盖模式。下面的命令覆盖常用操作。

脚本面向 Windows 上的 Windows PowerShell 5.1 和 PowerShell 7。
未声称验证其他系统的安装。执行策略受限时使用组织允许的运行方式；工具包
不会更改全局执行策略。

### 升级、接管或卸载

在可信包根目录执行，使用上面的目标变量：

```powershell
# 已有有效受管安装
& .\scripts\manage.ps1 -Action Upgrade -ProjectRoot $engrelayProject

# 无清单，且匹配已知旧布局；Preview 只读
& .\scripts\manage.ps1 -Action Adopt -Preview -ProjectRoot $engrelayProject -WorkflowMode optional
& .\scripts\manage.ps1 -Action Adopt -ProjectRoot $engrelayProject -WorkflowMode optional

# 仅撤销本包新增且未改动的内容
& .\scripts\manage.ps1 -Action Uninstall -ProjectRoot $engrelayProject
```

这些是不同的处理方式，不要全部依次运行。升级保留模式、SkillTarget、原始
备份、项目规则、OpenSpec、审查、经验与 `.ai` 证据。卸载保留项目内容和管理
块外后续编辑。`.ai-collaboration-install/` 中的恢复资料须保留并排除公开 Git。
不删除无效清单来强行安装或接管；先协调具体冲突。计划回退时保留可信旧包。

`CheckVersion` 仅与指定本地包比较，不搜索网上最新版本。`doctor` 只读，不启动
应用、宿主或安装器；exit0 时仍须阅读警告和未知的宿主加载结果。

### 模式与 Skill 副本

| 模式 | 行为 |
| --- | --- |
| `optional` | 新安装默认；当前任务明确选择时启动流程 |
| `default` | 项目默认使用；当前任务可明确选择其他流程 |
| `disabled` | 保留资料，使用前须明确重新启用 |

```powershell
& .\scripts\manage.ps1 -Action SetMode -ProjectRoot $engrelayProject -WorkflowMode optional
```

默认安装规范 Skill，不部署本包管理的宿主发现副本（`none`）。直接在目标项目读取，
例如 `docs/ai-collaboration/skills/ai-collab-start/SKILL.md`。这是成功安装，
不必为使用流程而重装。

仅在**首次** Install 需要发现副本时，显式传入一个 `-SkillTarget`。Codex 新安装
优先使用 `-SkillTarget agents`（`.agents/skills`）；`-SkillTarget codex` 保留
`.codex/skills` 兼容路径。其他值：`claude`、`cursor`、`opencode`、`antigravity`、
`gemini`、`iflow`、`qwen`。重复 Install 与 Upgrade 不会追加或切换目标；确需调整
须走官方卸载/重装，管理器不会自动迁移或删除你手工维护的副本。不覆盖无关同名
Skill，不运行继承的全目标安装器。文件放入发现目录不等于宿主已加载。

## 首次交接试用

源码仓库在 `examples/handoff-demo/` 提供一个固定的、仅限源码的样例。它不在安装包中，也不在
GitHub 自动生成的源码 ZIP 中，因此请使用包含它的提交的 Git 检出。按[快速上手](docs/quickstart.zh-CN.md)
完成三目录划分与会话 A 到会话 B 的步骤。样例源码提交
`304aa95702f106da262bcc741576293dfbeddc8d` 已从 GitHub 取得，八个 fixture 文件已核对；
这不证明宿主加载或外部十分钟目标。

## 对 Agent 说什么

人类指南：[快速上手](docs/quickstart.zh-CN.md)
（[English](docs/quickstart.md)）、
[操作指南](payload/docs/ai-collaboration/operator-guide.zh-CN.md)
（[English](payload/docs/ai-collaboration/operator-guide.md)）、
[项目采用](payload/docs/ai-collaboration/project-adoption.zh-CN.md)、
[宿主能力](payload/docs/ai-collaboration/host-capabilities.zh-CN.md)。
贡献、开发、变更、许可与 OpenSpec 导航在仓库根目录及 `docs/`、`openspec/` 下有配对中文版。Agent 契约仍为英文-only。

**推荐 — 开始任务**（`ai-collab-start`）：

```text
使用 ai-collab-start：实施已确认的订单导出需求。
本任务采用 EngRelay，使用中文交流。
```

目标明确时按风险分流，不插入固定需求阶段。重要业务歧义在同一会话执行与 requirements 相同的条件分析师契约，无需再单独调用 `ai-collab-requirements`。业务已明确的技术问题交给首席设计师。

**可选 — 先谈需求**（`ai-collab-requirements`）：

```text
使用 ai-collab-requirements：我想增加订单导出功能。
先和我确定需求，使用中文交流。
```

**接续已有任务**（`ai-collab-continue`）：

```text
使用 ai-collab-continue：接续最新、已获授权的 handoff。
```

宿主未发现 Skill 时，可以要求 Agent 直接读取目标项目内的
`docs/ai-collaboration/skills/<name>/SKILL.md`。发现 Skill、读取资料或存在 `.ai/`
本身不会启动协作流程。

七个规范名称保留：上述三个入口，以及 `ce-code-review`、`ce-debug`、
`ce-simplify-code`、`ce-compound`。CE Skill 是角色内的具体方法，不增加另一套
生命周期。

## 审查额度与成本

当前批次的设计、代码、验证和裁定 verdict 累计计算，默认自主额度三次。
额度用完但问题未解决时，负责 Agent 应说明原因、可行选项、成本和推荐理由，
交由任务负责人决定；不能单方面中止项目。继续循环须取得适用的有限追加授权，
详见[审查额度规则](payload/docs/ai-collaboration/README.md#review-round-circuit-breaker)。
换角色、改名或改写文案不重置计数。

检查覆盖实际受影响行为，输入匹配才复用旧证据。大投入低收益或成本明显超预期
时，先说明收益、投入与未知、较小方案和建议，由负责人选择。
测试全绿不能掩盖实际行为或证据缺陷。

## 旧 ai-collaboration 用户

EngRelay 是原 `ai-collaboration` 的公开品牌。为兼容升级，包保留
`docs/ai-collaboration/`、`.ai-collaboration-install/`、管理块标记、角色锚点、
机器字段和七个 Skill 的名称。明确选择 EngRelay 即选择同一协作流程。
使用官方 Upgrade，不手工删除清单或改名已安装的路径。

## 包内内容与边界

| 路径 | 用途 |
| --- | --- |
| `payload/` | 可部署角色规则、模板、Skill、示例和只读工具 |
| `agent-rules.md` | 插入目标项目受管入口的激活与流程规则 |
| `scripts/manage.ps1` | 官方安装、接管、状态、版本、升级、模式和卸载命令 |
| `scripts/supported-layouts.json` | 已知旧布局的精确指纹及允许的变更 |
| `snapshot.json` | 包版本、文件大小和 SHA256 清单 |
| `README.md`、`README.zh-CN.md` | 英文、简体中文概览与使用说明 |

工具包不提供后台调度、定时模型切换、业务部署或自动提交，也不能保证宿主
遵守指令。SHA256 可检查字节漂移，不是发布者的数字签名。

## 贡献与许可

阅读[贡献指南](CONTRIBUTING.zh-CN.md)，说明可观察行为、最小修改和相关证据。
贡献中保留公共示例，排除私人项目数据和运行中的 handoff。

日常开发使用本仓库的独立克隆，先读[开发维护指南](docs/development.zh-CN.md)。需求和
任务在 OpenSpec 中维护，安装检查使用干净导出的完整包。下载的发行包保留原样，
不使用混有开发工具与运行态的工作目录作为安装源。

EngRelay 自有内容采用 [MIT 许可证](LICENSE)。第三方通知仍然适用，详见
[第三方声明](THIRD-PARTY-NOTICES.zh-CN.md)。四个 CE 方法 Skill 选择性改编自
[Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin)，保留 Every 的版权与 MIT 声明。
对 [Superpowers](https://github.com/obra/superpowers) 的引用涉及方法及与单独安装的本机工具共存；
公开包未捆绑它，也不要求预先安装。EngRelay 是独立项目，不声称与这两个上游项目存在隶属或背书关系。
OmO 的借鉴记录是机制层面的
独立表述；本许可证不改变 OmO 自身受限文本或代码的授权。
