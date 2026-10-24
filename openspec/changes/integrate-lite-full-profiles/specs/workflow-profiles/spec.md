# Spec Delta

## Purpose

让同一 EngRelay 发行提供 Lite 与 Full 两种明确配置，以较小必读集合支持 Lite 的顺序任务协作，同时保持安装归属、模式选择、风险与独立审查约束，并使配置隔离和交接一致性具有可复核的验收依据。

## ADDED Requirements

### Requirement: Fixed workflow profiles and preserved defaults

官方管理器 SHALL 提供 `WorkflowProfile=full|lite`，与 WorkflowMode、SkillTarget、S/M/H 及 C1–C5 分别独立。未指定配置的新安装 SHALL 使用 Full 和既有 optional 默认；有效已有安装 SHALL 使用自身配置。一个项目 SHALL 只由官方管理器管理一个配置。

#### Scenario: Existing command omits the new parameter
- **WHEN** 操作者在未安装项目运行原有 Install 命令，没有指定 WorkflowProfile
- **THEN** 安装 Full，保留原模式及 SkillTarget 默认，不增加选择问答

#### Scenario: Mode changes do not switch profiles
- **WHEN** 操作者对 Lite 安装使用 SetMode
- **THEN** 仅改变模式，保留 Lite 身份、归属、配置和证据

### Requirement: Profile-specific deployment from one complete package

发行 SHALL 使用统一版本与完整 snapshot；安装 SHALL 校验完整来源后仅部署所选配置的明确集合。Lite SHALL 提供短规则、项目配置模板、队列／任务／交接模板及所需只读工具，SHALL NOT 安装 Full 角色链、Full 七个 Skill 或其发现副本。初版 Lite SHALL 只支持 SkillTarget=none，其他值 SHALL 在目标写入前拒绝。

#### Scenario: A complete package installs Lite
- **WHEN** 完整可信包以 lite 配置安装到空白夹具
- **THEN** 目标包含 docs/engrelay-lite/ 的规定集合及受管入口，不混入 Full 契约或七个 Skill

#### Scenario: Package file outside the selected profile is missing
- **WHEN** 来源包缺少 snapshot 列明的 Full 文件，而操作者只请求 Lite
- **THEN** 仍拒绝来源不完整，不能把配置投影当作跳过完整性检查的授权

#### Scenario: Unsupported Lite discovery target
- **WHEN** Lite 安装请求非 none 的 SkillTarget
- **THEN** 写入前说明当前 Lite 使用显式规范读取，项目文件和安装状态不变

### Requirement: Profile identity and legacy manifest compatibility

新受管安装 SHALL 在新版本清单中记录配置身份和完整部署归属，使旧管理器在目标写入前拒绝。新管理器 SHALL 仅对可信已识别的旧 version=1 安装按 Full 处理，并通过受保护升级转换，保留原始备份、模式、SkillTarget 及项目内容；未知清单 SHALL NOT 因缺少配置字段而被猜作 Full。

#### Scenario: Supported old Full installation upgrades
- **WHEN** 受支持旧清单和文件通过可信布局及归属核对
- **THEN** 新管理器识别为 Full，升级保留原配置语义及恢复材料，不重算旧发行指纹

#### Scenario: An old manager encounters a new manifest
- **WHEN** v1.9.6 管理器尝试维护新格式 Lite 或 Full 安装
- **THEN** 在目标写入前拒绝，不按 Full 猜测或删除新布局

#### Scenario: Unknown state lacks a profile
- **WHEN** 清单缺少配置身份且不满足可信旧布局识别
- **THEN** 报告具体清单问题并保留内容，不自动创建或接管安装

### Requirement: Explicit configuration transitions and protected project ownership

Upgrade、重复 Install 及 SetMode SHALL NOT 隐式转换配置。需要转换时 SHALL 提供保存证据和协调入口的明确人工路径；未完成任务 SHALL NOT 自动改写。Lite 项目配置首次创建后 SHALL 归属项目，升级和卸载保留；运行态与项目证据 SHALL 不成为包可删除内容。不同内容、归属漂移及不完整管理块 SHALL 在目标写入前拒绝。

#### Scenario: Upgrade requests another profile
- **WHEN** Full 安装收到 lite 的转换请求
- **THEN** 拒绝隐式转换，提供保留状态及受保护卸载／安装的方向，不改写未完成任务或累计审查数

#### Scenario: Project edits its Lite configuration
- **WHEN** 已安装项目修改项目配置、管理块外文字及本地证据，随后执行 Upgrade 或 Uninstall
- **THEN** 保留这些内容，包文件仍按各自归属及漂移规则处理

#### Scenario: Private Lite layout is present
- **WHEN** 无官方清单的目标已有私人 Lite 内容或入口
- **THEN** 不自动 Adopt 或覆盖，不将其声明为可信旧安装；说明冲突和保存输入的方向

### Requirement: Small explicit reading path and task authority

Lite SHALL 以短规则、项目配置和当前任务输入为日常入口，接手时增加当前 handoff 与明确关联的证据，SHALL NOT 强制读取完整 Full 手册或全量历史。Agent SHALL 按需读取目标源码及适用模块指令。已有适用 OpenSpec 时 SHALL 使用其范围与验收；其他 Lite 任务 SHALL 使用负责人确认的队列条目或任务记录，不建立互相竞争的实施清单。

#### Scenario: Clear S task has no formal proposal
- **WHEN** 已批准的低风险任务有清晰范围和验收，且没有适用的正式变更
- **THEN** 从当前条目执行并自查，不强制创建 OpenSpec、估算或独立会话

#### Scenario: Existing OpenSpec governs the task
- **WHEN** Lite 条目关联已有正式变更
- **THEN** 条目仅引用相应 tasks.md 和验收，不另建冲突范围或冒充完成的副本

### Requirement: Aggregated responsibilities with independent review

Lite SHALL 使用负责人、执行者、评审者三类职责并按实际影响判定 S/M/H。相邻非独立动作 SHALL 允许同一 Agent 连续处理；M SHALL 独立审查并复核必须修项，H SHALL 满足实际需要的设计和独立验证，实施或修复者 SHALL NOT 自审或自任同批 H 验证。累计 verdict 默认上限为三次，有限扩展 SHALL 保留已有授权及历史。

#### Scenario: M review requires a fix
- **WHEN** 独立评审提出有证据的必须修问题
- **THEN** 执行者修复后取得对应复核依据，不能自行把未复核发现标为已验证

#### Scenario: H work uses an available reviewer
- **WHEN** H 任务需要修复后的独立验证
- **THEN** 按实际独立性安排验证者，不能因只有三类职责而省略验证或让修复者自验

#### Scenario: Review allowance is exhausted
- **WHEN** 同批累计三次 verdict 后仍有未解决问题，且没有适用有限追加授权
- **THEN** 保存结果并交负责人决定，不因换模型、阶段、文件或配置而清零或再开循环

### Requirement: Sequential authorized queues with dependency-aware blocking

Lite 队列 SHALL 只执行负责人已批准且满足前置的任务；完成当前任务的验收及必要审查后才取下一项。阻塞任务 SHALL 保留自身交接和原因，只允许不依赖它且不会冲突的已批准任务继续。该能力 SHALL 限于活跃 Agent 的顺序工作，SHALL NOT 宣称进程退出后自动唤醒或提供后台调度。

#### Scenario: Independent task follows a blocked task
- **WHEN** T01 等待决定，T02 已批准且不依赖 T01
- **THEN** 保存 T01 的任务交接及队列引用后可以执行 T02，不能覆盖 T01 状态

#### Scenario: A dependency has not been accepted
- **WHEN** T03 依赖 T01 的未完成结果
- **THEN** T03 保持待处理或阻塞，不将 T01 的等待当作绕过依赖的理由

#### Scenario: Runner exits with executable continue
- **WHEN** 宿主结束本次运行但交接仍可执行
- **THEN** 说明实际接续入口，新的有权 Agent 核对后继续，不把无进程误报成环境阻塞或后台接力保证

### Requirement: Authorization-aware gates and neutral forward notices

Lite SHALL 在超出适用授权、实质范围／验收／风险变化、真实权限缺失或明显超预期成本时使用已有负责人出口；已授权常规编辑、局部技术选择和离线宿主选择 SHALL NOT 重复请示。只有当前未满足的人类前置 SHALL 表示等待人类；远期环境预告 SHALL 明确当前无需操作或回复。

#### Scenario: An authorized local edit replaces file content
- **WHEN** 已批准代码修复需要正常修改文件内容，未涉及范围外破坏性操作
- **THEN** Agent 在原授权内完成，不因覆盖一词泛化成新的人工批准门槛

#### Scenario: Later verification needs a separate environment
- **WHEN** 当前离线实施可执行，环境仅供后续验证
- **THEN** 继续工作并保留中性预告，Human Action Required 为 none；到依赖步骤再核对

### Requirement: Isolated concise handoffs and observable persistence

Lite 运行态 SHALL 使用 .ai/engrelay-lite/ 并与 Full 状态隔离。真实派发、等待、计划会话结束及关闭 SHALL 保存任务身份、修订、执行归属、下一动作、Human Action Required、累计审查数、成果、证据和适用自包含指令，回读核对本次已决定状态并运行相应检查。普通连续微步骤 SHALL NOT 因此新增交接。

#### Scenario: Same-role session ends
- **WHEN** 当前 Agent 计划让出未完成工作，即使下一会话角色不变
- **THEN** 保存并回读当前交接，保留任务、实际计数与下一指令，不只在聊天中说已交接

#### Scenario: Another profile has historical state
- **WHEN** Lite 项目内仍保留 Full 的历史 .ai/handoff.md
- **THEN** Lite 不读取它作为自身路由或改写它，也不由其存在自动启用 Full

### Requirement: Source-checked read-only result publication

评审可对业务文件只读并明确获准写必要协议产物；完全只读时 SHALL 返回完整结论及交接。仍活跃且有权写入的负责 Agent SHALL 当轮保存完整返回并核对任务、来源旧状态及执行归属。替代交接 SHALL 使用明确关联来源及旧状态修订／SHA256 核对；冲突 SHALL 保留现状并说明，SHALL NOT 按最大修订、时间或目录扫描猜测权威，也不得重复计数。

#### Scenario: Read-only reviewer returns a mandatory fix
- **WHEN** 子代理无法写文件而主 Agent 仍有权发布同任务交接
- **THEN** 主 Agent 保存完整审查及修复派发并回读核对，verdict 只计一次，不把落盘推给用户

#### Scenario: Higher revision has a conflicting source
- **WHEN** 候选修订更高，但任务或其引用的旧状态 SHA256 不匹配
- **THEN** 不覆盖当前文件，不执行候选指令，指出具体冲突；缺少可写发布者时保留完整响应及未落盘说明

### Requirement: Lightweight validation and advisory capability

Lite SHALL 有独立的小型只读结构校验，支持对已决定任务、动作、下一职责、审查数及修订的预期比对；失败 SHALL 非零退出且不写回。Agent 派发 SHALL 输出一行既有含义的 C1–C5 建议并在回复同步，Lite 执行者／评审者默认 C3，只有已有明确难度信息才覆盖。能力行缺失 SHALL 仅提示，不能成为新阻塞或模型资格门槛。

#### Scenario: Old valid handoff differs from the intended transfer
- **WHEN** 文件结构可读但其任务或路由与调用者提供的本次预期不符
- **THEN** 校验非零并指出差异，不能用旧结构成功声称本次交接完成

#### Scenario: Agent dispatch omits capability advice
- **WHEN** 新派发草稿缺少能力行但其他结构合法
- **THEN** 提供非阻断提醒，由有权写入者在原回读步骤补齐，不新开评审、分析模型或变更配置

#### Scenario: Validation succeeds
- **WHEN** 结构与显式预期匹配
- **THEN** 只报告实际检查结论，不声称业务验收、实际独立性、来源认证或宿主遵从已经被脚本证明

### Requirement: Bounded diagnostics and evidence-backed readiness

诊断 SHALL 只读报告配置、模式、归属和可读入口；未安装另一配置本身 SHALL NOT 作为本配置故障。发行准备 SHALL 取得两配置受影响生命周期及代表性任务证据、必要独立审查／验证、双语人类说明及完整候选包依据；缺少实际行为或宿主证据 SHALL 报告未验证，不以文本样例或结构成功冒充。

#### Scenario: Lite diagnostics find Full files absent
- **WHEN** 有效 Lite 安装没有 Full 角色链或发现副本
- **THEN** 视为预期投影，不要求补装 Full；宿主加载仍可为 unknown

#### Scenario: Usage comparison has missing host runs
- **WHEN** 演练只取得部分实际宿主的证据
- **THEN** 按真实覆盖报告输入集合和人工步骤，不宣称所有模型节省固定 token 或零遗漏，未满足的必需验收保持未完成
