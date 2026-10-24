# 第一期 Lite 短协议设计

这是任务 1.2／1.3 的设计交付，尚未安装或实现。行为权威仍为本变更两份 delta；本文确定第二期所需的最小机器结构及解释，不增加任务清单。样例见 [handoff-cases.md](examples/handoff-cases.md) 和 [queue-cases.md](examples/queue-cases.md)。

## 入口与任务权威

- 先遵守当前任务的明确授权、适用项目／模块指令和安全边界。安装清单决定可用配置；模式决定是否启用。Lite 不能自行切换 Full，也不能把历史运行态当作启用指令。
- 日常从项目指令、docs/engrelay-lite/RULES.md、docs/engrelay-lite.config.md 和当前任务条目进入；接手另读本任务最新 handoff 及具名证据。允许查看实际源码、模块说明和验收依据，不必读整个 Full 手册或其他任务历史。
- S 的已批准队列条目可含目标、范围及验收；M/H 用 tasks/<id>.md 的短记录。已有适用 OpenSpec 时只引用其范围、验收和 tasks.md；队列保存调度状态，不另复制实施清单。
- 只读咨询不自动创建任务。实际工作按影响分级；文档、配置、权限规则的改动不因文件类型自动成为 S。稳定范围中的实现细节由有权 Agent 处理。

## 职责、授权与审查

只有三类职责：Task Owner（人）、Executor、Reviewer。Executor 可以在同一会话连续完成非独立的方案细节、实施、自查和记录；Reviewer 可以承担设计、代码或验证行动，但每次必须满足实际独立性。

- S：完成相关自查即可收口，不强制方案或独立会话。
- M：一次聚合独立审查；必须修项修复后由独立评审确认，未确认时只能记 fixed-not-verified。
- H：按实际触发条件进行设计／架构审查，保留独立代码审查及修复后所需独立验证；实施或修复者不得自任同批验证者。不单因 H 再加一次负责人方案批准，也不取消真实业务／风险决定。
- Review round 为同一任务所映射同一批验收的累计 verdict，设计／代码／验证／裁决均计入。默认总额度三次；换阶段、工具、模型、任务文件或配置不能清零。新独立任务可以有自己的计数，未解决同一验收不得换名重开。
- 第三次 verdict 可据证据 accepted，或等待负责人决定；没有适用有限扩展时不得再派发 Agent 或开始第四轮修复。有限扩展保留原授权的身份、日期、批次、from／through、范围与证据，不新造 Lite 额度系统。
- 已有授权覆盖的常规编辑、局部技术选择、CLI／IDE 选择自主执行；真实范围、验收、权限、不可逆业务操作或显著成本变化才使用适用的负责人出口。工具沙箱和真实权限仍照常适用。

一个 Lite Task ID 标识这里的独立执行／验收单元，也作为有限授权的 batch 身份；与父 OpenSpec change-id 区分，不用于改名拆散同一未完成验收。适用有限授权在 Evidence 中复用 Task Owner decision 的 review-budget-extension 语法，batch 必须等于当前 Task ID，from ≤ 当前累计数 < through，并有 owner、date、scope、evidence。缺少、重复、跨任务或已达 through 的授权不增加额度；校验只检查结构及给定引用，真实负责人授权由负责 Agent 核对。

## 状态存放与队列

运行态根固定为 .ai/engrelay-lite/：queue.md、handoff.md、tasks/<id>.md、tasks/<id>-review-<n>.md、tasks/<id>-handoff.md、archive/。安装器不创建 live 任务；这些内容属于项目，永不作为包可删除文件。

queue.md 记录已批准任务 ID、范围／验收的权威引用、前置任务 ID、待做／进行中／待决定／环境暂停／已完成状态和需要时的交接引用。只串行取一个满足前置、已获授权且无冲突的任务。待决定项先保存自己的交接，再允许无依赖任务继续。依赖环或无法确定的依赖只阻塞受影响项，不扩成图引擎。

收口须满足映射验收及相应检查／审查；范围内未完成项不得抄到待决定后称为完成。范围外可独立追踪的后续事项可保留清楚身份及引用，不阻止本批独立接受。当前 handoff 在队列引用核对后归档，暂停项继续使用其自己的快照。读旧 Task ID 的交接不能当作正在执行的另一任务。

## 短交接结构

新 schema 的标识为 lite-1；不让 Full validator 放宽 required 字段，也不把私人 Lite 中文模板默认为受支持旧格式。所有新机器字段使用英文，正文允许采用任务沟通语言。

Routing 恰好包含下列 11 个字段，每项唯一；示例代码围栏中的字段不算真实字段。

| 字段 | 值及含义 |
| --- | --- |
| Schema version | lite-1；缺失／未知时不按当前格式宣称通过 |
| Task ID | 稳定非空任务身份，与当前队列和任务权威对应 |
| State revision | 正整数；同任务每次实际写回加一，新会话接手也加一 |
| Current role | Executor 或 Reviewer；保留实际职责，不能冒充返回结论的来源角色 |
| Current agent | 实际工具／Agent 身份，非空；不要求模型认证 |
| Current status | in-progress、blocked、awaiting-owner-decision、completed 四者之一 |
| Next action | continue、dispatch、close 三者之一 |
| Human Action Required | none、awaiting-decision、awaiting-environment 三者之一 |
| Review round | 非负累计数，含这次已经发生的 verdict |
| Next role | Agent 派发为 Executor／Reviewer；人工派发为 Task Owner；continue／close 为 none |
| Risk level | S／M／H，与该任务权威保持一致 |

正文仅保留适用区块：Current Status、Evidence、以及下表要求的动作区块；阻塞和关闭时需要相应依据。Evidence 链接真实文件，命令／结果／退出码留在现有任务结果、审查记录或外置日志。角色身份和修订不能证明作者真实性或强制排他执行；接手前核对当前 writer，不并行抢写。

| 动作与状态 | Human Action Required | Next role | 必需动作内容 |
| --- | --- | --- | --- |
| continue + in-progress | none | none | Current Status 内的 Continuation Command，含同角色／任务、Read、Objective、Constraints、Output、Follow |
| dispatch 给 Agent | none | Executor 或 Reviewer | Operator Command，含角色／任务、输入、目标、可写输出、范围、独立性、额度及规则位置 |
| continue 或人工 dispatch + awaiting-owner-decision | awaiting-decision | continue 为 none；dispatch 为 Task Owner | Owner Decision Brief；不得混入可执行 Agent 命令 |
| continue + blocked，当前需人工准备 | awaiting-environment | none | Blockers 的 Resume condition 及当前具体人类准备；没有可执行命令 |
| continue + blocked，纯工具／环境故障 | none | none | Blockers 的 Resume condition、已尝试事项；不虚构人工要求 |
| close + completed | none | none | Outcome、对应证据和所需负责人处置；没有 Agent 命令 |

其他组合为结构错误。dispatch 的 Current status 为 in-progress 或 awaiting-owner-decision（仅人工）；完成的 Reviewer 输出可以派发修复，但不能把整项任务状态写成 completed 后继续派发。环境的远期预告可用短正文：依赖什么、到哪一步再查、当前无需操作或回复；预告本身不改变路由。

## 一行能力建议

只有 Agent dispatch 在 Current Status 的首行写 Recommended capability tier: Cn，并在最终回复同步。Lite Executor／Reviewer 的默认值都是 C3；仅使用任务中已有明确机械、常规、深度分析或特殊推理信息作 C1／C2／C4／C5 覆盖。定义沿用 Full，短协议和交接不复制档位表或做模型比较。

continue、人工决定、close 省略能力行。缺失能力行由校验器非阻断提醒，有权写入者在原回读步骤补齐；档位不批准模型、不代替独立性，也不修改风险、授权和计数。

这里“旧输入仍合法”指可按本 schema 读取但缺少建议行的历史交接，不是把私人 Lite 0.2.0 的无版本中文结构自动纳入兼容。

## 保存、只读返回与恢复

1. 真实派发、等待、计划会话结束和关闭：决定下一状态，保存，重新读取核对 Task ID／动作／下一职责／累计数／修订，再执行只读校验并传入这些已决定预期。不能从旧文件反推预期来证明新状态已发布。
2. 长检查只留一个有实质价值的恢复点和外置日志引用；未决检查不能写成通过。普通连续微步骤不要求重复落盘。
3. 业务代码只读的审查可以显式获准写审查及交接产物；完全只读时返回完整 verdict、发现和下一交接，并标明未落盘。派发时预先在任务记录或当前 handoff 的 Evidence／命令中点名预期审查结果路径，不能让结果文件自我提名。
4. 有活跃可写负责者时，当轮核对原任务、该次明确关联的旧 handoff 修订及原始字节 SHA256，保存完整结果并发布下一状态；记录来源 Reviewer 和实际 writer，verdict 只计一次。没有有权 writer 则保留完整响应和未落盘事实，不把责任推成用户手工维护。
5. 后续恢复只读本任务明确关联的一个待发布来源。旧状态修订与 SHA256 都匹配，且现有授权／额度／归属允许时才能发布；同目标修订须比较 Routing 和动作内容，已应用不重放。更高当前修订已前进则不覆盖，冲突保留现场，不取最大编号、不扫描目录、不根据时间戳判断权威。
6. 新格式输入不满足时只报告缺失和最小协调方向，不为私人 Lite 自动补字段或迁移旧任务；Full 旧交接按 Full 既有兼容规则读取。

## 校验接口与关闭

拟定 Lite 只读入口为 scripts/validate-state.ps1，参数包括 WorkspaceRoot、HandoffPath、ExpectedTaskId、ExpectedNextAction、ExpectedNextRole、ExpectedReviewRound、ExpectedStateRevision；提供任一预期即要求 ExpectedTaskId。真实边界提供本次全部已决定预期。缺失、重复、非法值、预期不符或路由矛盾返回非零；成功仅证明结构和所给值。

所有路径受工作根及明确引用约束；校验器不自动写回、选择 Agent、计算队列依赖、证明事实独立性或评估模型。来源匹配只核对显式来源与给定旧输入的指纹，不发现／恢复／发布文件；发布仍是有权 Agent 的动作。

普通 accepted 关闭必须有实际验收、所需审查及最终输入匹配的结构检查。校验依据在外置记录，交接只引用，记录依据不循环改动被检查的 handoff。未满足验收不得关闭为普通 accepted；负责人限定接受、stopped／superseded 须保存适用的明确决定，保留未完成项及限制，不称技术通过。此规则不授权 Git 操作或部署。
