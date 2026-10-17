# Collaboration package Specification

## Purpose

记录已发布 EngRelay v1.7.0 的维护基线，供后续变更比较。依据公开产品规范、
官方管理器和发行记录整理；不搬入私人业务资料、历史批次或旧验收结论。
本基线不构成对所有宿主、旧版本及业务场景的新一轮验证。

## Requirements

### Requirement: Explicit activation and one workflow

工具包 SHALL 保留 optional/default/disabled 及当前任务明确选择优先的语义。
明确选择 EngRelay SHALL 等同于选择兼容名称 ai-collaboration；资料或 Skill
被发现本身 SHALL NOT 激活流程，同一任务 SHALL 只有一个主编排流程。

#### Scenario: Optional installation
- **WHEN** 项目以 optional 模式安装，当前任务没有明确选用该流程
- **THEN** 旧 .ai、角色名称或可发现 Skill 不要求创建运行态或启动角色链

#### Scenario: Disabled mode
- **WHEN** 项目为 disabled 模式
- **THEN** 使用前须明确重新启用，不能因读取入口而隐式改变模式

### Requirement: Coherent role routing and review independence

角色 SHALL 以职责及实际需要路由；稳定范围内的问题由有权限的当前负责人继续。
每个真实交接边界 SHALL 选择 continue/dispatch/close 中一个动作；Agent 派发
SHALL 提供完整自包含 Operator Command。M 代码审查及 H 所需验证 SHALL 保持独立。

#### Scenario: Local implementation issue
- **WHEN** 实现工程师遇到不改变已确认范围、验收或风险的局部问题
- **THEN** 继续在角色权限内处理，不增加机械角色往返，也不豁免所需独立审查

#### Scenario: Review allowance exhausted
- **WHEN** 默认三次累计 verdict 已用尽且问题未解决
- **THEN** 当前负责人说明证据、选项、投入和推荐理由，走既有负责人决定出口；
  追加循环须有适用的有限授权，不能通过改名、换角色或 REVISE 重置累计计数

### Requirement: Stable entry Skills and canonical product files

工具包 SHALL 保留三个入口 ai-collab-requirements/start/continue 及四个 CE Skill
的现行机器名称、角色锚点、字段和安装路径。规范产品内容 SHALL 在 payload/
维护，宿主发现副本 SHALL 由官方部署机制管理，单次安装最多选择一个 SkillTarget。
start SHALL 作为推荐通用入口，条件复用与 requirements 相同的既有需求分析契约；需求明确时 SHALL 保持直接分流，重要业务歧义未经负责人确认 SHALL NOT 进入设计或实现。

#### Scenario: Requirements dialogue
- **WHEN** 用户明确使用 ai-collab-requirements 讨论需求
- **THEN** 先按既有条件契约澄清和记录，负责人明确确认后才交给首席设计师；已明确且已确认的输入不重复确认

#### Scenario: Continue work
- **WHEN** 用户明确使用 ai-collab-continue 接续任务
- **THEN** 检查最新有效 handoff 及授权，只按记录的下一步继续，不重置审查计数

#### Scenario: Clear goal through start
- **WHEN** 用户使用 start 给出可安全总结的明确任务或充分明确的现有 OpenSpec 范围
- **THEN** 按既有风险规则分流，不增加固定需求讨论阶段或重复的确认

#### Scenario: Ambiguous goal through start
- **WHEN** 用户使用 start，Task Intake 无法安全总结重要业务歧义
- **THEN** 同一负责会话可按已有 Requirements Analyst 契约澄清，无须用户另行调用 requirements；等待期间由分析师保有责任，使用既有负责人决定出口，明确确认后只交给首席设计师

#### Scenario: Technical uncertainty without business ambiguity
- **WHEN** 业务目标已经明确，剩余问题属于技术设计或实现可行性
- **THEN** start 交给首席设计师处理该问题，不把技术选择变成业务澄清的阻塞条件

#### Scenario: Existing task or inactive workflow
- **WHEN** 同项工作已有活动任务，或当前处于 disabled 模式、选用了其他控制器
- **THEN** 复用同项身份与累计计数并遵守既有接续规则；disabled 或其他控制器的场景不隐式激活、不覆盖运行态、不新建批次

### Requirement: Compatible selective upstream methods

工具包 SHALL 以不可变上游来源核对所采用方法与本地权威、范围、授权和许可的兼容性，只吸收适用的差异。方法同步 SHALL 保留 S/M/H、独立审查、现有发现分类和单一任务权威；SHALL NOT 隐式启用完整上游生命周期、外部模型调用、自动提交或新的运行记录。未捆绑或已覆盖的上游功能 SHALL 如实标明，不用上游版本号代表本地实现程度。

#### Scenario: Review an I/O gap
- **WHEN** 审查发现 I/O 防护不足
- **THEN** 结合该代码实际运行场景和可证实后果判断是否形成发现；不能只因缺少 try/catch 就要求修复，也不能忽略真实数据损失、误导结果或不可恢复的部分完成

#### Scenario: Review extra surface or a dependency
- **WHEN** 新接口、参数、配置或依赖疑似超出任务需要
- **THEN** 依据明确约束或清楚限定的范围判断；需求简短而未提及本身不是越界证据；建议替换依赖时指出实际可用的标准库、平台或仓库内替代能力

#### Scenario: Prevent recurring root cause
- **WHEN** 最小修复已通过聚焦检查，证据显示同类根因在多个已授权位置重复
- **THEN** 可采用有证据支持的局部复用或约束以防复发，并单独记录；改变公共接口、范围或引入不相称成本时只记录后续建议并走既有范围决定，单点缺陷不强加结构改造

#### Scenario: Unbundled Superpowers and unchanged CE methods
- **WHEN** 上游变化属于未捆绑的宿主插件、控制器或本地已满足的方法
- **THEN** 记录不采用或无需改动的结论；本机工具问题提供受支持的更新建议，不改写生成副本或声称已升级公开包；转载改写内容保留适用通知

### Requirement: Separate human documentation languages

工具包 SHALL 为专门供人类阅读的现行说明提供内容相应、互相可达的英文和简体中文版本，覆盖入门使用、采用、宿主、贡献、开发发布、变更与许可说明及人类示例。每份版本的自然语言正文和说明性示例 SHALL 使用对应语言；语言切换标签、技术标识、命令、机器示例字段、许可证及明确引用的英文 Agent 提示词可保留原文。Agent 契约、机器模板和工具输出 SHALL NOT 因此增加中文版本或改变协议。

#### Scenario: Chinese operator follows the documented flow
- **WHEN** 中文用户从中文 README 进入现行使用、采用和宿主说明
- **THEN** 可阅读对应中文人类说明，识别统一入口、确认与交接方式及安装限制，无须把英文 Agent 契约当作普通操作教程；Agent 仍引用原规范契约

#### Scenario: Maintainer or contributor changes language
- **WHEN** 人类从贡献、开发、变更、许可或源码导航说明切换语言
- **THEN** 对应版本保持相同的实质信息，开发指南的可复制 Agent 提示词继续英文且标明原文引用，不声称未发布或未验证的内容已经发布或验收

#### Scenario: English contract contains Chinese narrative
- **WHEN** 清理英文 Agent 契约中夹杂的中文说明或示例
- **THEN** 将自然语言等义改为英文，保留字段、角色、锚点及行为，不新增中文契约或修改校验器

#### Scenario: Historic records and existing example paths
- **WHEN** 语言清理涉及审查原件、归档提案或既有中文示例文件
- **THEN** 历史审计原件保持原样；既有示例路径保留为兼容例外，示例中的机器结构不因中文正文而翻译或重命名

### Requirement: Protected deployment of added human documents

新增可部署人类文档 SHALL 使用既有受管归属机制；受支持历史布局的转换 SHALL 精确登记新增路径，保留原布局指纹、模式、SkillTarget、原始备份和项目自有内容。根目录维护说明与源码索引 SHALL NOT 被误当作新的安装目标。布局升级或文档语言 SHALL NOT 授权绕过冲突保护、自动迁移宿主目标或重写已发布清单。

#### Scenario: Upgrade a known public installation
- **WHEN** 使用新候选包升级受支持的公开旧版本，新增文档路径没有冲突
- **THEN** 新人类文档按既有机制登记归属，既有模式、单一目标、备份和管理块外内容保留，后续卸载只处理本包可撤销内容

#### Scenario: Added document collides with project content
- **WHEN** 新增目标路径已有相同或不同内容的项目文件
- **THEN** 相同内容继续按既有 preexisting 语义保留；不同内容在任何目标或恢复元数据写入前拒绝，不覆盖或接管项目文件

#### Scenario: Owned content drift or unverified layout
- **WHEN** 旧受管内容漂移，或旧版本布局没有可信登记且不能按现有规则识别
- **THEN** 保持既有拒绝及恢复方向，不伪造指纹、不弱化检查，也不把未取得的旧包测试记为通过

### Requirement: Protected package lifecycle

官方管理 SHALL 支持现行 Install/Adopt/Status/CheckVersion/Upgrade/SetMode/Uninstall。
升级及卸载 SHALL 保留归属、原始备份、管理块外后续编辑、模式、SkillTarget 和
项目证据。未知或漂移内容 SHALL 明确拒绝；不得强制覆盖或手写安装清单绕过检查。

#### Scenario: Valid managed installation
- **WHEN** 目标有有效受管清单且符合受支持的升级条件
- **THEN** 使用官方 Upgrade，保留原归属、备份和项目自有内容

#### Scenario: Recognized unmanaged legacy layout
- **WHEN** 无清单且精确匹配已登记旧布局
- **THEN** 可先运行只读 Adopt -Preview，通过后正式 Adopt；不能删除无效清单来冒充该情形

#### Scenario: Local drift
- **WHEN** 升级发现受管内容被修改或新增路径出现不同的项目自有文件
- **THEN** 在写入前报告具体冲突，保留内容并提供最小协调方向

### Requirement: Bounded diagnostics and knowledge retrieval

doctor 与 find-solutions SHALL 保持现行只读边界。文件存在、结构校验或副本
发现 SHALL NOT 被声称为真实宿主加载、业务正确或验收完成；未知事实 SHALL 如实报告。

#### Scenario: Unverified host loading
- **WHEN** 诊断只能确认规范或发现副本存在
- **THEN** 仅报告该事实，宿主加载与遵守规则仍可为 unknown

### Requirement: Traceable and proportional verification

检查 SHALL 覆盖实际受影响行为，并仅在输入和范围匹配时复用既有证据。高投入
低收益或明显超预期成本的选项 SHALL 先说明收益、投入与未知、较小方案和建议，
由负责人明确选择。真实缺陷 SHALL 聚合报告，不受固定发现数量上限约束。

#### Scenario: Documentation-only change
- **WHEN** 修改只影响文案、引用或记账，没有新的行为问题
- **THEN** 不因角色更换或收尾重复全部历史套件，不增加措辞匹配测试

### Requirement: Complete release inventory and private development state

发行包 SHALL 用 snapshot.json 记录实际包版本、文件大小与 SHA256，完整包集合
与字节 SHALL 与清单一致。开发运行态、凭据、私人历史及宿主缓存 SHALL 保留在
忽略或排除范围；开发准备 SHALL NOT 将发布过的包或标签改写为新的内容。

#### Scenario: Clean release export
- **WHEN** 从已审阅源码准备下一发行
- **THEN** 在干净暂存目录导出并重建清单，排除 Git、运行态和本地工具内容；
  结构或哈希检查不被当作发布者签名或业务验收

### Requirement: License notices and bounded orchestration claims

自有内容 SHALL 使用 MIT 并保留适用第三方通知。现有编排角色规则 SHALL NOT
被宣传为已经提供任务依赖图引擎、常驻调度、自动唤醒或后台 Agent 管理。
这些能力的新增 SHALL 作为后续明确需求评估，不从旧路线名或借鉴关系推断完成。

#### Scenario: Future orchestration request
- **WHEN** 用户希望接入宿主原生委派或建设运行时编排
- **THEN** 分析现有宿主能力、许可、成本与最小方案，再确认具体实施及验收范围

### Requirement: 明确区分规范读取与宿主发现

安装使用说明 SHALL 区分安装目标内的规范 Skill 读取路径与可选宿主发现目录，并说明默认 SkillTarget 为 none。双语公开说明 SHALL 保持相同语义，Codex 新安装示例 SHALL 使用显式 agents 目标并说明 codex 目标保留兼容。说明 SHALL 不将手工复制作为常规步骤，也不得将文件放置称为宿主已加载或流程已激活。

#### Scenario: 默认安装后使用规范文件
- **WHEN** 操作者按默认方式首次安装且未传 SkillTarget
- **THEN** 说明和成功提示明确本次未部署本包的宿主发现副本，并提供目标项目内 docs/ai-collaboration/skills 下的规范读取路径；该情况属于成功安装，不要求重装

#### Scenario: 新 Codex 安装选择发现目标
- **WHEN** 操作者需要在 Codex 中发现和显式调用本包 Skill
- **THEN** 双语说明给出首次 Install 显式选择 agents 的示例，说明对应 .agents/skills，并保留 codex 目标及其 .codex/skills 兼容路径；不自动改默认目标或检测宿主

### Requirement: 安装提示保留成功输出兼容

首次 Install 成功后的附加提示 SHALL 简短可见，准确报告所选目标、目标项目内的规范路径及适用的发现路径，并区分文件可读与宿主加载未知。提示 SHALL 与 PowerShell 成功流分离，保留原成功消息的内容、成功流返回及退出结果，不把有效的 none 选择当作告警或失败，也不新增输入或批准步骤。

#### Scenario: 无发现副本的成功提示
- **WHEN** 首次 Install 以 none 目标成功完成
- **THEN** 原成功消息仍在成功流，附加信息提供规范读取路径并说明没有为本次安装部署发现副本，不声称项目中绝对不存在用户自有副本

#### Scenario: 显式目标的成功提示
- **WHEN** 首次 Install 以任一受支持的非 none 目标成功完成
- **THEN** 附加信息同时提供目标名、对应发现目录与规范读取路径，且不声称宿主已发现、加载或遵守 Skill

#### Scenario: 调用方分别捕获输出流
- **WHEN** 调用方仅收集 PowerShell 成功流并单独捕获或抑制信息流
- **THEN** 成功流仍只包含原有成功返回，成功结果不因提示而改变；合并信息流或收集原生进程屏幕输出时可以看到附加提示，不承诺合并文本逐字不变

#### Scenario: 安装失败不输出成功指引
- **WHEN** Install 因已有不同内容、受管漂移或其他既有错误失败
- **THEN** 保留既有拒绝及退出结果，不输出首次安装成功提示，不覆盖冲突路径

### Requirement: 已有安装的发现指引保持归属

已有安装的使用说明 SHALL 优先提供直接读取规范 Skill 的方式，明确重复 Install 和 Upgrade 不用于追加或切换 SkillTarget；确需调整目标时 SHALL 解释现有受保护的官方流程。提示和说明 SHALL 不自动迁移、卸载重装、创建第二目标或接管手工副本，保留项目自有内容、安装归属和升级保留目标的语义。

#### Scenario: 已安装 none 的操作者需要使用入口
- **WHEN** 已有有效 none 安装的操作者希望使用入口 Skill
- **THEN** 说明提供直接读取目标项目规范文件的方法，操作者可继续使用现有安装；只有主动选择宿主发现目标时才参考现有官方目标调整方式

#### Scenario: 重复安装和升级保持已有选择
- **WHEN** 对有效已有安装执行不改变目标的重复 Install 或执行 Upgrade
- **THEN** 原有幂等或升级语义继续有效，既有 SkillTarget 保留，不因新增提示而部署其他目标或改变归属

#### Scenario: 存在手工或同名副本
- **WHEN** 目标中已有用户手工维护的 Skill 或同名不同内容
- **THEN** 说明不要求覆盖或手工删除这些内容，管理器继续按原有归属和冲突规则处理，不将附加提示当作接管授权

### Requirement: OpenSpec dotted task references

任务准备说明、current-task 模板与 schema SHALL 明确：唯一实施清单使用 `## 1.` 分组及 `- [ ] 1.1` 点号编号；运行态只映射该 tasks.md 中实际存在的任务编号。SHALL NOT 将扁平 `- [ ] 1.` 作为合法映射示例或创建第二份实施清单。

#### Scenario: Prepare a mapped batch
- **WHEN** Agent 为现有 OpenSpec 变更准备 current-task
- **THEN** 可依模板识别点号格式，将批次映射到 tasks.md 中的真实 `1.1` 等项，既有运行时校验器能识别该映射

#### Scenario: Flat task numbering
- **WHEN** 任务输入使用扁平编号，导致既有结构校验无法识别映射
- **THEN** 修正任务输入与映射后复验，不放宽校验器或虚构已存在的任务编号

### Requirement: File evidence and result content separation

handoff 及响应交接的文件证据项 SHALL 填写真实可访问的文件路径，适用时使用现有 `none`，不得填写命令字符串。命令、观察到的输出摘要、退出码及必要的原始日志引用 SHALL 保存在结果文件；实现/修复结果复用既有 result 模板与 Checks Run，不新增机器字段或强制为纯文案另建运行态。

#### Scenario: Record implementation checks
- **WHEN** Agent 已运行行为检查与运行态结构检查
- **THEN** 将实际命令、结果、退出码写入 result，handoff 的 Authoritative Evidence 只引用 result 或日志文件；任务清单引用的编号与路径分开说明，不能把整个命令当作路径

#### Scenario: Command mistaken for an evidence path
- **WHEN** 证据列表中的命令被既有校验器识别为不存在的文件路径
- **THEN** 移动命令与输出到结果文件并改为文件引用后复验，不修改校验器或清空必需证据来隐藏失败

### Requirement: Trial setup has an inspectable Git baseline

Quickstart SHALL 在会话 A 前提供针对新建可丢弃试用项目的 `git init`、检查忽略范围、显式暂存试用输入及首次本地提交步骤与成功检查。SHALL NOT 要求更改全局 Git 身份、配置远端或把运行态、安装备份和宿主缓存纳入提交。

#### Scenario: New trial directory
- **WHEN** 操作者尚未在独立试用目录建立 Git 仓库
- **THEN** setup 指导建立可检查的初始提交，使用 `git status --short`、`git log -1` 确认基线；缺少身份时只给项目局部配置方向

### Requirement: Trial requires PowerShell 7 explicitly

Quickstart SHALL 明确本次试用需要 PowerShell 7（`pwsh`），并提供 `pwsh` 可用性与主版本检查。此要求 SHALL 仅限定本条试用途径，不改写工具包原有 Windows PowerShell 5.1/7 支持声明，不自动安装或更改全局策略。

#### Scenario: Only Windows PowerShell is available
- **WHEN** 用户只有 Windows PowerShell 5.1，或找不到 pwsh
- **THEN** 在会话 A 前报告前提未满足并指向环境准备，不把 powershell.exe 当作此次 pwsh 检查通过

### Requirement: Preserve session A handoff evidence

Quickstart SHALL 在会话 A 产生有效交接后、打开 B 前，指导在试用项目内备份 `.ai/handoff.md` 为 `.ai/handoff.A.md`，核对副本内容；已有副本不得被静默覆盖。该副本 SHALL 仅作本地证据，B 的活动输入仍为最新 `.ai/handoff.md`。

#### Scenario: B later updates the live handoff
- **WHEN** B 实施后更新活动 handoff
- **THEN** A 的交接内容仍可从备份检查，备份不取代实时路由、不重放旧命令，也不提交仓库

### Requirement: Session B uses the actual complete operator command

Quickstart SHALL 指导新会话 B 从当前真实 handoff 的 Operator Command 复制完整命令，确认批次、角色、输入输出与约束；提示中的占位说明 SHALL 清楚标成须替换的说明。没有有效交接、仍含占位文字或角色不符时 SHALL 停在恢复说明，不猜测授权。

#### Scenario: Placeholder pasted into B
- **WHEN** B 收到模板占位说明而非当前真实完整 Operator Command
- **THEN** 指南说明回到真实 handoff 重新复制并核对，保留既有角色匹配防护，不要求 B 忽略路由继续执行

### Requirement: Windows trial troubleshooting stays local

Quickstart SHALL 仅提供两种故障的最小处理方法：文件被占用时关闭相关编辑器或让 pwsh 离开目标目录后重试；Codex 沙箱拦截写入时核对工作目录与可写范围，按宿主受支持流程处理所需写权限后重试。SHALL NOT 扩展到其他故障或深度诊断，也不提供批量杀进程、强删目录、全局降权或绕过沙箱的步骤。

#### Scenario: A trial directory is in use
- **WHEN** 操作因编辑器或 pwsh 占用目标文件/目录失败
- **THEN** 指南提示关闭相关编辑器或让 pwsh 离开目标目录后只重试失败操作

#### Scenario: Codex blocks a write
- **WHEN** 文件系统写入被宿主沙箱拒绝
- **THEN** 按指南核对实际工作目录与授权可写范围，使用宿主支持的权限处理方式后重试；仍失败时保留错误并说明尚未解决

### Requirement: Offline acquisition preserves the complete package

Quickstart SHALL 为不能访问 GitHub 的用户提供离线取得方式：由可访问者从可信发行入口取得对应版本的完整安装 ZIP，连同来源、版本及可用的完整性信息原样转交，接收者核对解压后的 snapshot 文件集合与哈希。SHALL 区分完整包、开发源码和目标项目，不杜撰镜像地址、不让新手修改清单掩盖缺失文件，不宣称 SHA256 是发行者签名。

#### Scenario: GitHub is unreachable
- **WHEN** 接收者只能通过离线介质或内部文件传输收到安装包
- **THEN** 指南给出可执行的来源/版本确认与完整性核对步骤；包不可确认或内容不匹配时重新取得可信完整包，保留错误，不直接安装
