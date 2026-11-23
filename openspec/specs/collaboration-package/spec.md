# Collaboration package Specification

## Purpose

记录已发布 EngRelay v1.7.0 的维护基线，供后续变更比较。依据公开产品规范、
官方管理器和发行记录整理；不搬入私人业务资料、历史批次或旧验收结论。
本基线不构成对所有宿主、旧版本及业务场景的新一轮验证。

## Requirements

### Requirement: Actionable closed-batch guidance

Full 接续遇到已关闭批次时 SHALL 依据最新适用权威说明关闭结果、映射范围、已知剩余或未知事项，以及没有下一角色的事实，并给出适用的简短下一步。SHALL 区分普通接受、负责人有限接受、停止和替代；SHALL NOT 把批次关闭等同于父提案全部完成或凭空推断可执行工作。

独立设计交付的普通关闭 SHALL 在 Current Status 开头及回复中清楚显示设计已完成、父提案剩余范围与一个可复制的适用接续请求；该请求 SHALL 与关闭批次的 Operator Command 区分。后续 Task Intake SHALL 遵守当前请求的角色范围与停止边界，已有实施授权 SHALL NOT 被解释为自动执行后继角色。

#### Scenario: Finished batch without a new request
- **WHEN** 最新批次已 accepted，已核对的父范围无待办，用户仅要求继续
- **THEN** 说明已完成及无下一角色，并提供开始新任务的适用入口；不重放旧派发或声称已启动新任务

#### Scenario: Closed batch with unfinished parent work
- **WHEN** 当前批次已关闭，父提案仍有未完成事项，且已有授权覆盖持续实施，范围、依赖与当前目标可无歧义确定
- **THEN** 区分原关闭与父提案进度，按既有 Task Intake 准备适用后续工作；不重复请求同一授权，不自动执行人工接力的下一角色

#### Scenario: Limited acceptance or stopped outcome
- **WHEN** 关闭记录是负责人有限接受、stopped 或 superseded
- **THEN** 如实说明具体结果、未满足范围及适用的负责人决定或下一步，不称为技术验证全部通过

#### Scenario: Evidence is missing or conflicting
- **WHEN** 关闭结论、剩余范围或有效交接所需权威缺失或冲突
- **THEN** 指出具体文件和无法确认的内容，给出最小恢复方向；不猜测结果、下一角色或审查计数

#### Scenario: Remaining work or authority is ambiguous
- **WHEN** 父提案存在多个无法确定先后的候选、授权只覆盖已关闭批次，或适用决定不清楚
- **THEN** 说明已知剩余项、实际限制及一个可复制的最小后续请求；不自行扩大授权或猜测任务

#### Scenario: 独立设计关闭清楚展示下一步请求
- **WHEN** 一个有依据的独立设计交付批次完成，父提案仍有已知待实施事项
- **THEN** 以当前批次的真实接受依据关闭，Current Status 开头与回复显示设计完成、父提案剩余范围及可复制的具体接续请求；关闭批次仍无下一角色及 Operator Command，后续环境缺口不被说成已验证

#### Scenario: 仅执行设计角色的请求在授权边界结束
- **WHEN** 独立设计批次完成，负责人当前只要求设计或设计评审并在交接后停止，即使存在父提案的持续实施授权
- **THEN** 保留当前关闭及明确后续请求，停止本轮，不自动准备或执行超出当前角色范围的后继工作，也不再次询问相同实施授权

#### Scenario: 独立设计关闭后的明确实施请求
- **WHEN** 设计批次已经关闭，当前请求要求实施可明确确定的后续范围，且授权、依赖、权限和执行归属均适用
- **THEN** 保存旧关闭输入并通过既有 Task Intake 准备后续批次，保留相关审查历史和有限限制；人工接力保存新交接后停止，由用户启动下一角色

### Requirement: Authorized work after a closed batch

明确选择 Full 后，当前请求与既有授权共同无歧义地指向关闭后工作时，负责 Agent SHALL 按现有 Task Intake 或适用有限审查路径处理，不要求重复发送等效指令。SHALL 保留原关闭、实际累计计数、明确有限授权和独立性；SHALL NOT 将含糊请求、旧消息或建议当作新授权。

#### Scenario: Explicit next work in an active parent change
- **WHEN** 当前批次已关闭，用户明确要求实施父提案中的特定未完成范围，且现有授权覆盖
- **THEN** 从唯一任务清单核对范围和依赖，经现有 Task Intake 建立适用的后续批次及映射；保留旧关闭，同一未完成验收的 verdict 不清零

#### Scenario: Explicit authorized review after closure
- **WHEN** 用户明确授权对已关闭成果进行一次有限追加审查
- **THEN** 关联原关闭和实际计数，按既有有限审查及独立性规则处理，不把一次审查扩大成新的三轮修复

#### Scenario: A stale or ambiguous message
- **WHEN** 请求只是延迟的旧派发、没有确定目标的“继续”，或缺少适用授权
- **THEN** 报告最新状态及可选择的最小下一步，不重放旧动作、猜测新任务或扩展范围

#### Scenario: Disabled mode or another controller
- **WHEN** 项目处于 disabled，或当前任务由其他明确选择的控制器负责
- **THEN** 保持现有激活与控制器边界，不因关闭提示或后续请求自动启用、覆盖状态或派发角色

#### Scenario: Continue an already authorized parent change
- **WHEN** 用户已明确授权持续实施唯一可识别的父提案，随后要求继续，且候选任务、依赖和权限能从当前权威确定
- **THEN** 选取有明确依据的就绪范围并通过现有入口准备后续工作；原批次的有限接受仍只覆盖原范围，未满足证据不变成通过

### Requirement: Route-conditional reference reading

Full 接续 SHALL 先核对当前适用的项目指令、实时任务和交接，再按实际动作、来源候选和写入边界读取相关规则及证据。适用的模式、授权、恢复、审查额度和角色要求 SHALL 保留；SHALL NOT 要求仅因关闭答复而预加载无关执行分支，也不设强制禁读或绕过项目及已触发 Skill 的必读要求。

#### Scenario: A closed batch needs only a status answer
- **WHEN** 已核对当前交接为 close，且没有需要恢复的来源或明确获授权的后续动作
- **THEN** 读取确认结果和剩余范围所需的具名权威，按需定位关闭规则，无需为执行 continue 或 dispatch 读取无关规则

#### Scenario: A live route needs execution or recovery
- **WHEN** 当前动作可执行、存在具名待恢复来源，或实际边界需要保存交接
- **THEN** 按对应触发条件读取授权、额度、来源匹配、角色指令及预期状态校验，不因精简阅读忽略必要约束

#### Scenario: A new session or changed input
- **WHEN** 新 Agent、缺失上下文、相关输入变化或规则存疑
- **THEN** 重新读取受影响权威及适用规则；同会话仅复用已读且已知未变的参考，不增加缓存台账

### Requirement: Explicit activation and one workflow

工具包 SHALL 保留 optional/default/disabled 及当前任务明确选择优先的语义。Full 中明确选择 EngRelay SHALL 等同于兼容名称 ai-collaboration；Lite 中 EngRelay 或 EngRelay-Lite SHALL 选择已安装的 Lite。明确选择未安装配置或其专属入口 SHALL NOT 自动切换、安装或生成另一套运行态。资料或 Skill 被发现本身 SHALL NOT 激活流程，同一任务 SHALL 只有一个主编排流程。现行管理入口 SHALL 明确规则适用于当前选用配置，SHALL NOT 将运行态维护描述为仅适用于退役历史；管理标记及项目块外内容 SHALL 保留归属保护。

#### Scenario: Optional installation
- **WHEN** 项目以 optional 模式安装，当前任务没有明确选用该流程
- **THEN** 旧 .ai、角色名称或可发现 Skill 不要求创建运行态或启动角色链

#### Scenario: Disabled mode
- **WHEN** 项目为 disabled 模式
- **THEN** 使用前须明确重新启用，不能因读取入口而隐式改变模式

#### Scenario: Active workflow is not described as retired-only execution
- **WHEN** 当前任务明确选择 EngRelay，并从管理入口读取运行态维护规则
- **THEN** 文案说明规则适用于当前任务，不以 legacy 或退役描述暗示可以忽略交接；不改变模式、机器路径或角色契约

#### Scenario: Project-owned entry has a conflicting historical statement
- **WHEN** 项目管理块外保留与当前采用方式冲突的历史声明
- **THEN** 采用说明要求在该项目范围核对并协调适用性；安装升级不自动改写块外用户内容，不把包源文案修正称为项目声明已经修复

#### Scenario: Lite task explicitly chooses EngRelay
- **WHEN** 项目有效安装 Lite，当前任务明确使用 EngRelay，模式允许激活
- **THEN** 读取 Lite 的规则和运行态，不把通用名称解释成 Full 角色链

#### Scenario: Entry belongs to another profile
- **WHEN** Lite 项目明确收到 Full 专属 ai-collab-start、requirements、continue 或 ai-collaboration 选择
- **THEN** 说明配置与入口不匹配并给出当前 Lite 可读入口；不覆盖历史、不创建 Full 任务，也不自行转换配置

### Requirement: Coherent role routing and review independence

角色 SHALL 以职责及实际需要路由；稳定范围内的问题由有权限的当前负责人继续。
每个真实交接边界 SHALL 选择 continue/dispatch/close 中一个动作；Agent 派发
SHALL 提供完整自包含 Operator Command。M 代码审查及 H 所需验证 SHALL 保持独立。

追加审查和关闭后修复 SHALL 按实际授权范围执行并关联原验收及历史；同一未完成验收 SHALL NOT 通过关闭、改名或新批次清零实际计数、规避明确有限授权或隐藏未完成问题。单次追加审查 SHALL NOT 自动授予后续修复循环；已关闭历史不重开，真实新缺陷仅在适用授权下建立关联修复。

Full SHALL 区分角色结束与批次验收：同批实施未完成时交接，独立设计交付完成时合法关闭；来源或映射与已授权目标冲突时交 Chief Designer 核对，遵守 Source-grounded task scope。真实边界 SHALL 保持活动任务、交接、Review 与唯一清单的事实一致。

#### Scenario: Local implementation issue
- **WHEN** 实现工程师遇到不改变已确认范围、验收或风险的局部问题
- **THEN** 继续在角色权限内处理，不增加机械角色往返，也不豁免所需独立审查

#### Scenario: Review allowance exhausted
- **WHEN** 当前动作受已确认的有限审查或修复授权约束，且其明确上限或范围已用尽
- **THEN** 保存实际计数、未解决问题和适用授权，不能通过改名、换角色或 REVISE 扩大该授权；需改变授权时给出具体负责人决定出口

#### Scenario: Unfinished acceptance is renamed
- **WHEN** 同一未完成验收因阶段、角色、文件或批次名称变化继续处理
- **THEN** 保留实际累计计数、未完成映射及适用的明确有限授权；改名不自动授权新循环

#### Scenario: One extra review is authorized at capacity
- **WHEN** 负责人明确只授权对当前工作追加一次独立审查
- **THEN** 以既有有限授权字段记录实际范围及一次 verdict 的绝对上限；不得解释成无限授权或自动授权后续修复，不重复请求已给授权

#### Scenario: Owner requests a post-closure audit
- **WHEN** 负责人明确要求对已关闭成果追加一次审查
- **THEN** 保留原关闭和计数，在现有任务及审查索引关联原记录与这次有限范围；发现问题只记录实际影响及下一步，单次审查不自动授权新修复批次；已适用的明确修复授权直接复用

#### Scenario: A genuinely new defect needs repair
- **WHEN** 已关闭成果出现具名新缺陷且存在适用的修复授权
- **THEN** 以关联修复范围经既有 Task Intake 处理，保留历史事实、来源和计数，不伪称原记录从未通过；若只是原未完成验收改名，仍保留同一验收计数及适用明确限制

#### Scenario: 设计通过但同批映射实施尚未完成
- **WHEN** Full 的设计评审通过或仅有非阻断观察，当前批次映射仍包含未完成实施，且没有适用的授权、审查额度或即时环境阻塞
- **THEN** 派发 Implementation Engineer，或仅在确有需要时交给既有中间角色；保留同批映射和实际计数，提供完整 Operator Command 与建议能力行，人工接力保存、回读及预期校验后停止，不以设计通过声明批次接受

#### Scenario: 独立设计交付满足验收
- **WHEN** 当前批次设计结果是可核对的已确认交付目标或有依据的独立可验收契约边界，相关验收与所需评审已完成
- **THEN** 允许仅关闭该设计批次，并按关闭指引显示后续入口；仅有角色完成或人为缩小的设计任务映射不足以证明独立交付，父提案其余事项保持真实未完成状态

#### Scenario: 仅设计映射与已授权目标不一致
- **WHEN** 当前任务只映射设计事项，但已授权目标还要求实施，且缺少可核对的独立设计交付边界
- **THEN** 不以设计映射勾选为由关闭，也不由审查员擅自扩展任务；派发 Chief Designer 核对原目标和最小连贯映射，保留同一未完成验收的计数及限制；纯范围核对不自动触发重复设计评审或重复负责人批准

#### Scenario: 角色受限会话结束不代表未完成批次接受
- **WHEN** 负责人要求本轮只执行某个设计角色，当前完整批次仍有已授权未完成实施
- **THEN** 当前角色完成设计和适用交接后停止，批次保留真实未完成事项与可执行下一角色，不将会话结束或角色停止写成 accepted close，也不自行启动后继角色

#### Scenario: 活动设计状态与已完成评审一致
- **WHEN** 设计评审已形成结论，负责角色保存本次真实交接
- **THEN** 同时核对当前任务中已有的事实叙述、handoff、所引用 Review 及唯一 tasks.md，仅修正活动叙述中的过时事实，不改变稳定验收、复制运行状态台账或回写历史 Review；读取历史缺少新说明的关闭记录不要求补写或重开

#### Scenario: 第二轮设计评审通过不等于提案终止
- **WHEN** 第二轮设计评审通过，仍有已授权工作且不存在其他真实等待或有效有限上限阻断
- **THEN** 按真实批次范围交接或关闭合法独立交付，不把设计轮数当作父提案终止条件；后续同一未完成验收的累计计数与有限授权保持适用

#### Scenario: 选路先核对独立设计范围的来源
- **WHEN** 设计通过且映射仅有设计，来源摘要却不足以区分独立设计请求与已授权实施的本轮设计步骤
- **THEN** 按来源可核对要求作最小核对，不用任务名称、角色结束或自写的权限结论代替依据；已授权实施被遗漏时交 Chief Designer 纠正映射，合法独立设计交付仍按原规则关闭

#### Scenario: 纯范围纠正保留设计和历史
- **WHEN** 有权角色仅纠正来源摘要或映射，未改变已确认设计、业务验收及风险
- **THEN** 复用已有授权与相符设计结论，保留实际累计计数及有限限制，不因此新增设计审查、重开旧关闭或自动执行后继角色

#### Scenario: 人工 Agent 接力准备后停止
- **WHEN** 当前角色的已决定下一步是 Agent `dispatch`，且采用人工接力
- **THEN** 当前角色准备、保存、回读并说明下一角色交接后停止，不执行下一角色；Operator Command 禁止自动执行后继时仍允许准备该交接，不以 `Do not dispatch any further role` 阻止交接准备

#### Scenario: 负责人决定等待与人类行动提示一致
- **WHEN** 当前工作确实等待负责人作出决定
- **THEN** Routing 状态为 `awaiting-owner-decision`，`Human Action Required` 为 `awaiting-decision`，Owner Decision Brief 描述同一待决定事项；人工平台接力不需要负责人作业务决定或准备环境时仍为 `none`

### Requirement: Source-grounded task scope

Full 任务接入及实质范围更新 SHALL 在既有任务区块内保留影响本批范围与出口的最小请求或决定依据，区分整体目标、本轮职责、已确认授权与 Agent 推断。SHALL NOT 仅因先要求设计而否定已有实施授权，也不得从实施意图、未禁止或建议推导全部实施权限。下一会话 SHALL 能据此核对实际范围，无需完整聊天；旧记录无需回填，缺失依据只在影响当前决定时按既有恢复或负责人决定规则处理，不增加通用批准门槛。

#### Scenario: 整体实施授权与本轮设计职责分别保留
- **WHEN** 用户已授权完成一个明确任务，当前只要求首席设计师完成设计和交接后停止
- **THEN** 输入保留整体交付和已授权实施，将本轮限制记录为职责与停止边界；不改写为独立设计验收，不自动执行下一角色

#### Scenario: 只要求方案或估算的可确认交付
- **WHEN** 用户明确请求方案或估算，现有依据未确认后续实施授权，且该设计结果本身是可独立验收的请求目标
- **THEN** 完成该设计交付及所需评审后可关闭本批，说明整体意图、已完成范围、父级待办和一个可复制后续请求；不将后续授权尚未明确写成用户明确禁止，也不自动实施

#### Scenario: 上游推断不能冒充用户决定
- **WHEN** current-task 称用户只允许设计或禁止实施，但其所引依据仅是当前先做方案，或与已记录的整体实施授权冲突
- **THEN** 由有权角色核对来源并纠正无据推断；不能以该 Agent 叙述或设计项已勾选独自证明独立设计关闭，不能由审查员自行扩大实施权限

#### Scenario: 有总体意图但当前权限仍不明确
- **WHEN** 已知用户期望最终实现某能力，而当前请求只要求分析、设计或估算，已有权威仍无法确定是否授权下一实施动作
- **THEN** 保留总体意图和已确认的当前工作，准确说明下一动作的授权不确定性；来源或映射冲突作最小范围核对，需要实质授权时给现有负责人决定或明确后续入口，不重复确认已有明确内容

#### Scenario: 下一平台只需最小可核对依据
- **WHEN** 新 Agent 只能读取当前任务、交接和具名权威，无法取得早前聊天
- **THEN** 使用已有区块中的最小请求摘要、决定或适用规范引用核对范围；没有相关冲突或缺口时无需取得聊天，不要求来源账本或每个条目的引文，不能从缺失记录虚构授权

#### Scenario: 用户明确限定独立设计
- **WHEN** 用户当前明确只接受独立方案交付并暂不实施，且没有仍适用且与之冲突的范围决定
- **THEN** 按该设计验收和停止边界执行，不派发实施；完成所需评审后可合法关闭设计批次并说明后续入口

#### Scenario: 后续明确实施请求补足原先未知授权
- **WHEN** 设计已通过并关闭，用户随后明确要求实施可确定的未完成范围，先前仅记录后续授权未知
- **THEN** 采用当前明确请求与现有权威准备后续 Task Intake，更新适用的范围依据，保留旧关闭和相关审查历史；不让过时推断阻止接续，不重复询问相同授权或无故重做已通过设计评审

### Requirement: Stable entry Skills and canonical product files

Full SHALL 保留三个入口 ai-collab-requirements/start/continue 及四个 CE Skill 的现行机器名称、角色锚点、字段和安装路径。规范产品内容 SHALL 在 payload/ 维护，宿主发现副本 SHALL 由官方部署机制管理，单次安装最多选择一个 SkillTarget。Full 的 start SHALL 作为推荐通用入口，条件复用与 requirements 相同的既有需求分析契约；需求明确时 SHALL 保持直接分流，重要业务歧义未经负责人确认 SHALL NOT 进入设计或实现。Lite 的入口及安装集合 SHALL 按 workflow-profiles 契约执行，SHALL NOT 隐式改变上述 Full 入口含义。

#### Scenario: Requirements dialogue
- **WHEN** 用户在 Full 中明确使用 ai-collab-requirements 讨论需求
- **THEN** 先按既有条件契约澄清和记录，负责人明确确认后才交给首席设计师；已明确且已确认的输入不重复确认

#### Scenario: Continue work
- **WHEN** 用户在 Full 中明确使用 ai-collab-continue 接续尚未关闭的任务
- **THEN** 检查最新有效 handoff 及授权，按适用的下一步继续，不重置审查计数

#### Scenario: Clear goal through start
- **WHEN** 用户在 Full 中使用 start 给出可安全总结的明确任务或充分明确的现有 OpenSpec 范围
- **THEN** 按既有风险规则分流，不增加固定需求讨论阶段或重复的确认

#### Scenario: Ambiguous goal through start
- **WHEN** 用户在 Full 中使用 start，Task Intake 无法安全总结重要业务歧义
- **THEN** 同一负责会话可按已有 Requirements Analyst 契约澄清，无须用户另行调用 requirements；等待期间由分析师保有责任，使用既有负责人决定出口，明确确认后只交给首席设计师

#### Scenario: Technical uncertainty without business ambiguity
- **WHEN** Full 的业务目标已经明确，剩余问题属于技术设计或实现可行性
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

官方管理 SHALL 支持现行 Install/Adopt/Status/CheckVersion/Upgrade/SetMode/Uninstall，并按 workflow-profiles 契约处理已安装配置；Adopt SHALL 只接管已登记可信历史布局。升级及卸载 SHALL 保留归属、原始备份、管理块外后续编辑、模式、SkillTarget、项目自有配置和项目证据；升级 SHALL 保留配置身份。未知或漂移内容 SHALL 明确拒绝；不得强制覆盖、手写安装清单、把私人 Lite 当成可信历史或隐式转换配置来绕过检查。

#### Scenario: Valid managed installation
- **WHEN** 目标有有效受管清单且符合受支持的升级条件
- **THEN** 使用官方 Upgrade，保留原归属、备份、配置身份和项目自有内容

#### Scenario: Recognized unmanaged legacy layout
- **WHEN** 无清单且精确匹配已登记旧布局
- **THEN** 可先运行只读 Adopt -Preview，通过后正式 Adopt；不能删除无效清单来冒充该情形

#### Scenario: Local drift
- **WHEN** 升级发现受管内容被修改或新增路径出现不同的项目自有文件
- **THEN** 在写入前报告具体冲突，保留内容并提供最小协调方向

#### Scenario: Repeated install attempts a profile change
- **WHEN** 已有有效安装收到另一配置的 Install 请求
- **THEN** 写入前拒绝，保留现有文件及状态；同配置重复 Install 保持既有幂等语义

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

负责人明确要求完整审查时，审查 SHALL 覆盖授权范围的全部验收、最终差异、兼容性、证据、说明及交付隐私，并记录适用版本／差异。证据 SHALL 对应所声称的入口、输入、环境和结果；不足保留未验证。后续复核 SHALL 依据实际变化及影响选择检查，发现真实新缺陷、影响扩大或原证据失效时扩大范围；SHALL NOT 将完整审查等同于每次重跑全部测试。

#### Scenario: Documentation-only change
- **WHEN** 修改只影响文案、引用或记账，没有新的行为问题
- **THEN** 不因角色更换或收尾重复全部历史套件，不增加措辞匹配测试

#### Scenario: Owner requests complete review before archive
- **WHEN** 负责人要求归档前完整独立审查
- **THEN** 执行覆盖全部授权验收的聚合审查，不只检查最后一项修复；没有要求追加新审查且已有独立结论覆盖当前全部输入时可复用，不为 S 任务普遍新增审查门槛

#### Scenario: An old upload result is cited as current FileId acceptance
- **WHEN** 报告以旧上传入口结果声称当前 FileId 入口已成功，且没有对应执行依据
- **THEN** 该验收保持未验证并说明入口／版本对应缺口，不以结构通过、离线 fake 或叙述补成真实入口成功

#### Scenario: Privacy or explanation changes preserve behavior inputs
- **WHEN** 修复只涉及报告脱敏或说明，相关行为、配置、测试输入及既有证据仍匹配
- **THEN** 复核修复内容及适用的工作区／待交付副本，引用匹配的既有行为结果；不因角色变化重跑无关构建、供应商调用或全部套件

#### Scenario: Repair changes a shared contract or invalidates evidence
- **WHEN** 修复改变共享契约、调用者或相关输入，或发现可信的新缺陷／原验收证据不成立
- **THEN** 沿实际影响扩大审查和必要检查，明确失效及可保留的证据；扩大到全部验收有依据时执行完整复核，不能以局部复核隐藏问题

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

### Requirement: Optional task sizing without routing gates

任务规模或投入估算 SHALL 仅在有助于决策且有合理依据时提供，并说明范围、假设及不确定性；无依据时 SHALL 允许省略，不强制填写未知值。L1–L5 SHALL 只描述粗略修改规模，SHALL NOT 推导 S/M/H、C1–C5、审查次数、验收或审批。人工投入 SHALL 与 AI 时长、会话数及 LOC 区分，SHALL NOT 由其自动换算。统计 SHALL 按需限定相关范围，不要求安装工具或常驻状态。可能给出或更新估算的角色入口 SHALL 以锚点短引用唯一共享定义，SHALL NOT 复制区间或扩大必读范围。

#### Scenario: Clear small task has no estimate
- **WHEN** 明确的小任务没有可靠规模或人工投入估算，且原授权与执行前提已满足
- **THEN** 省略估算并按已有风险路径执行，不新增角色、工具扫描、未知值表单或负责人确认

#### Scenario: Useful rough source sizing
- **WHEN** 已有信息足以提供有用的产品源码规模粗估
- **THEN** 可按人工维护产品源码的 Added + Deleted 使用 L1 为 0–99、L2 为 100–499、L3 为 500–1999、L4 为 2000–9999、L5 为至少 10000 行的参考区间，附假设及置信度，不提供伪精确行数；测试、文档、生成与机械变更另行说明，不因从规模口径排除而忽略审查

#### Scenario: Documentation or mechanical change
- **WHEN** 任务主要修改文档、配置、二进制资源或机械搬移，产品源码行数不能代表规模
- **THEN** 使用相关文件或行为范围描述，允许不使用 L 级，不把缺少产品源码变化说成无需审查，也不因行数多而自动提高风险

#### Scenario: Human effort is requested
- **WHEN** 用户需要人工投入参考且有可比依据
- **THEN** 可提供含假设和不确定性的人工有效投入区间；依据不足时明确不确定或省略，不将 AI 运行小时、Expected implementation sessions、代码量或工具成本模型换算成人天

#### Scenario: Relevant change baseline is unavailable
- **WHEN** 没有可信批次起点、可区分的相关改动或可用统计工具
- **THEN** 不把全仓体量、单一未暂存 diff 或混入无关工作的数字当作本批实际规模，省略不可靠值并继续原流程，不为获取数字扫描历史、安装程序或写新缓存

#### Scenario: An estimate changes materially
- **WHEN** 实际范围或规模与已有粗估明显不同
- **THEN** 当前角色简短说明证据和原因，先核对获授权范围及最小方案；数字偏差本身不停止工作，实际复杂度例外、范围或重大成本变化仍走已有负责人及设计处理路径

#### Scenario: A role entry reaches the shared definition
- **WHEN** Chief Designer 仅按其角色入口工作且负责人请求规模或投入参考，或实施角色记录投入是否实质变化
- **THEN** 角色入口的短引用可直接到达唯一共享定义中的区间、省略条件与风险独立规则；入口不复制区间表、不把完整手册列为必读，也不因此要求明确的小任务给出估算

### Requirement: Evidence-based progress within existing handoffs

真实交接的进展说明 SHALL 复用既有区块，简短表达可观察成果、证据与剩余工作，并区分实现/自测、独立审查和正式接受。验收项数量 SHALL 仅在已有清晰口径时作为可选覆盖说明，SHALL NOT 冒充工时完成度或主观总进度。进展复核 SHALL 基于实际证据与未知项收敛，SHALL NOT 以固定交接次数或指标自动阻塞、增加检查点、重写稳定任务输入或绕过恢复规则。

#### Scenario: A real boundary reports changed work
- **WHEN** 发生原协议要求保存的派发、等待、计划会话结束或关闭，且已有实质进展
- **THEN** 在既有 Current Status、证据、风险及状态影响区块记录必要变化，链接已有证据，保留具体剩余工作，不为汇报另建交接或复制日志

#### Scenario: Acceptance count has a stable meaning
- **WHEN** 现有验收项可明确映射且部分已经取得证据
- **THEN** 可说明已核验项数和总数及其证据，不通过拆分条目提高比例，不用 OpenSpec 子任务数代替验收项数，也不从数量比例推断总工时进度或 accepted

#### Scenario: Research or review adds useful evidence
- **WHEN** 连续工作尚未新增通过的验收项，但已排除错误方向、收敛关键未知或产生审查证据
- **THEN** 如实说明有效进展及下一步，不因两次交接没有新增通过项而判断停滞，不把尚未独立审查的实现称为已正式接受

#### Scenario: Material work has no explainable progress
- **WHEN** 有明显投入，却持续缺少新增证据、未知项收敛或可解释的必要前置工作
- **THEN** 当前角色作一次简短复核并提出最小纠偏行动，只有实质范围、优先级或成本决定才使用既有负责人出口；不新建计数器、告警表或审批，不重复通报相同情况

#### Scenario: Progress and capability share current status
- **WHEN** 新 Agent 派发同时报告成果或可选估算
- **THEN** 能力建议仍是 Current Status 的第一行，成果说明紧随其后；不把新摘要插在能力行之前，也不改变完整 Operator Command

#### Scenario: Progress updates preserve recovery ownership
- **WHEN** 交接进展发生变化、旧记录缺少指标，或接续存在已关联的恢复来源
- **THEN** 继续按现有真实边界、修订、写入归属、回读及来源匹配规则处理完整 Current Status；不为指标旁路写入、以时间戳覆盖、反复回写 current-task 或要求历史补录

### Requirement: Concise advisory capability on agent dispatch

新建或正常更新的 Agent `dispatch` 交接 SHALL 在 `Current Status` 的首行用独立一行 `Recommended capability tier: C1` 至 `C5` 表达下一项派发工作的建议能力，并在最终用户回复中简短同步同一档位。文件式和回复式交接 SHALL 使用同一规则；SHALL NOT 为此复制档位说明、增加逐次理由或模型比较。现有交接出口 SHALL 提醒负责 Agent 在原有回读时核对该行及回复一致性；公开说明 SHALL 区分必须输出建议与建议不构成资格门槛。人工决定、`continue`、`close` SHALL 省略能力行。

#### Scenario: Dispatch an ordinary implementation
- **WHEN** 下一角色为实现工程师，任务没有已明确的轻量或特殊复杂信息
- **THEN** 文件交接在 Current Status 首行显示且只显示一行 `Recommended capability tier: C3`，用户最终回复也简短显示 C3，完整 Operator Command 保留

#### Scenario: Response-only agent handoff
- **WHEN** 实际 Agent 派发因只读限制使用回复式交接
- **THEN** 回复交接的 Current Status 首行使用同样一行及同一默认映射，仍说明文件交接未更新，并提供完整 Operator Command

#### Scenario: Human decision or no agent dispatch
- **WHEN** 下一动作是人工决定派发、等待负责人决定的 continue、普通 continue、blocked continue 或 close
- **THEN** 不输出能力行，原 Owner Decision Brief、Resume condition、关闭及 next 字段规则继续适用

#### Scenario: An entry completes a new agent transfer
- **WHEN** 通过 start、requirements、continue 或现有角色出口生成新的 Agent 派发
- **THEN** 出口提醒负责 Agent 按既有默认/明确覆盖规则填入能力首行，在同一次交接回读中确认并在最终回复复述；发现本次草稿漏写时由有权写入者补齐，不要求用户选择模型、增加评分或另开审查

#### Scenario: A human reads the capability guidance
- **WHEN** 人类从任一语言的根 README 或操作指南理解能力提示
- **THEN** 说明明确新 Agent 派发须输出这一建议，而档位仅供选择参考、不批准模型或阻塞工作；旧缺行交接仍按原兼容规则继续，不将结构校验通过称为能力行已核对

### Requirement: Reusable capability definitions and defaults

产品 SHALL 集中维护一份英文规范定义及固定角色默认表：C1 基础执行、C2 常规实现、C3 综合工程、C4 深度分析、C5 高难度推理。派发 SHALL 直接查表，仅复用已确认任务中明确的轻量或复杂信息调整；SHALL NOT 增加专门调查、模型评估或交接理由。C5 SHALL 无默认角色，且 SHALL NOT 因一次失败自动升档。双语人类说明 SHALL 提供简短、语义一致的查阅入口。

#### Scenario: Use defaults without new analysis
- **WHEN** 派发目标是现有标准角色或 Task Intake，已有任务没有明确难度例外
- **THEN** 直接使用固定表，所有目标均有默认值；文档整理默认 C1，常规实现默认 C3，首席设计默认 C4，任何角色均不默认 C5

#### Scenario: Already identified lightweight work
- **WHEN** 已授权任务明确是按已给步骤执行的机械工作，或已明确是边界清楚的常规局部任务
- **THEN** 分别用 C1 或 C2 作为此次下一项工作的建议，不因角色默认较高而一律要求高档，不再调查或新增难度判断报告

#### Scenario: Known complexity and exceptional C5
- **WHEN** 已有任务明确需要深度跨模块分析，或已明确要求高难度推理
- **THEN** 分别可采用 C4 或 C5；采用 C5 必须有后者的现成任务依据，无现成信息时继续默认值

#### Scenario: A failed attempt or a risk label
- **WHEN** 发生单次失败，或任务仅标记为 S、M、H 而没有已明确的难度例外
- **THEN** 不据此自动改变能力档位；风险分类和原有修复、审查路径继续适用

### Requirement: Capability guidance preserves authority and legacy compatibility

能力行 SHALL 只作人工选择模型与推理强度的参考，SHALL NOT 成为资格证明、批准步骤、必填机器字段或新阻塞条件；SHALL NOT 替代角色权限、S/M/H、实际验证、独立审查和累计 verdict 规则。旧交接缺少该行 SHALL 继续有效，接续 SHALL NOT 要求先补齐或重写历史。显示建议 SHALL NOT 自动选择模型、修改配置或启动编排。

#### Scenario: Read an older valid handoff
- **WHEN** 接续既有有效交接且缺少能力行
- **THEN** 按原 Next action 和授权继续，不因缺少该行报错、要求迁移或回填归档

#### Scenario: Operator chooses an available agent
- **WHEN** 用户选择可用模型和推理强度，产品没有能力测评或档位认证依据
- **THEN** 建议不新增资格检查或等待高档模型的阻塞；现有工具、环境和授权前提照常适用，实际完成仍需证据

#### Scenario: Preserve existing invalid-route detection
- **WHEN** 交接含有或缺少能力建议，但原 Routing、Operator Command 或累计审查条件本身无效
- **THEN** 原校验或路由规则仍指出原问题，能力行不能覆盖、修复或放行无效状态

#### Scenario: Independent review remains required
- **WHEN** 一个 M 级批次被建议使用 C1、C2 或 C5 Agent
- **THEN** 仍须独立代码审查，档位不改变风险、审查计数或关闭条件，也不证明审查者实际独立或胜任

### Requirement: Evidence-backed ordinary accepted closure

新建或正常更新的普通 accepted 关闭 SHALL 在报告验收完成前，取得与最终交接及相关结构输入相符的校验成功依据，记录实际命令、退出码、诊断及输入对应关系。依据 SHALL 位于既有结果、审查记录或外置日志，交接仅引用。校验未执行、失败或依据已失效时 SHALL NOT 报告普通验收完成。记录依据 SHALL NOT 要求循环修改被校验交接、递归校验日志或增加 Routing 机器字段。

#### Scenario: Final closure passes validation
- **WHEN** 负责角色已满足映射验收及所需独立审查，准备普通 accepted 关闭
- **THEN** 对完成的最终交接及相关输入进行结构校验，将实际 exit 0、诊断和输入对应依据记录在外置证据中；交接文件保持为被校验内容，回复只陈述实际检查结论及限制

#### Scenario: Validation fails or has not run
- **WHEN** 最终交接的结构校验失败或尚未执行
- **THEN** 不以普通 accepted 报告完成；可恢复时当前角色修正并复验，需等待环境时使用 continue + blocked 及明确 Resume condition，不把 blocked 关闭

#### Scenario: Checked inputs change afterward
- **WHEN** 校验成功后，交接或影响该结论的结构输入发生变化
- **THEN** 不继续复用失配的成功依据，先对受影响的最终输入复验；仅在独立证据文件记录本次输出不要求重新校验未变化的交接

#### Scenario: Reuse an existing evidence container
- **WHEN** 当前动作已有实施结果、正式审查记录或边界日志可承载检查证据
- **THEN** 复用该容器，交接只保留短引用，不为纯文案另造实施结果、默认报告或强制新账本

### Requirement: Closure evidence preserves existing authority and compatibility

关闭依据规则 SHALL 保留负责人限定接受、现有路由、角色权限、独立审查及累计 verdict 规则。限定接受 SHALL 如实保留未满足验收和未完成任务，SHALL NOT 将其说成技术验证成功，也不绕过无效结构或 blocked 路由。历史记录 SHALL 保持可读，不要求回填归档；新关闭与文件式、回复式输出 SHALL 遵守同一证据真实性和适用范围约束。结构校验 SHALL NOT 被声称为日志认证、宿主遵从或业务验收。

#### Scenario: Owner accepts incomplete delivery
- **WHEN** 有适用于本批的显式负责人限定接受决定
- **THEN** 仅 Chief Designer 以既有 owner-decision 和 Task Owner decision 记录处置，保持未完成映射不勾选并披露缺失证据；结构检查即使成功也不表示这些技术验收已完成

#### Scenario: Legacy closed handoff lacks the new evidence
- **WHEN** 接续或查阅本规则生效前已关闭的记录
- **THEN** 按现有兼容规则读取，不因缺少新增的说明要求重写归档、重开批次或重置审查计数；当前新关闭只使用适用于当前输入的真实依据

#### Scenario: Read-only response cannot persist a closure
- **WHEN** 只读约束要求回复式交接
- **THEN** 不把旧文件的通过结果说成新回复已验证；允许独立快照时说明实际检查对象和未持久化限制，无法取得相符依据时不报告普通 accepted，按既有 blocked/负责人决定边界记录可恢复下一步

#### Scenario: An unchanged non-closure route
- **WHEN** 当前动作仍是 continue、人工决定或 Agent dispatch
- **THEN** 保留原路由和真实边界检查，不引入关闭证据的新机器必填字段、额外审查轮次或重复历史回归

### Requirement: Concise bilingual follow-up navigation

源码 OpenSpec 导航 SHALL 提供实质对应的英文与简体中文后续事项入口，仅记录事项、来源、当前状态和对应变更或完成证据。状态 SHALL 区分待决定、已确认待实施、待验证、已完成；导航 SHALL NOT 复制 tasks.md 进度、审查计数、运行态或成为第二实施权威。待决定和待验证 SHALL NOT 自动授权实施，完成状态 SHALL 有相符证据，不以提案、归档或发行标题代替验收。

#### Scenario: Read current status after a historical deferral
- **WHEN** 人类从导航查阅曾延期的 C1–C5 或本次关闭规则
- **THEN** 可看到 C1–C5 的真实完成证据及本变更当前概况；历史原件保留原文，当前状态以相符任务与审查证据解释，不伪造新的 verdict

#### Scenario: An idea has not been selected for implementation
- **WHEN** 事项来自样例或后续路线图规划，负责人尚未选择其实施
- **THEN** 标为待决定并说明来源和未立项边界，不生成虚构变更、任务编号、交付日期或实施承诺

#### Scenario: Product or walkthrough validation remains unperformed
- **WHEN** G0 外部试用或 Quickstart 某些操作缺乏实际验证记录
- **THEN** 标为待验证并说明未验证范围和启动边界，不把包结构检查当作用户试用或全链路通过

#### Scenario: A formal change progresses
- **WHEN** 某后续事项被正式选择、完成或取得新的验证证据
- **THEN** 导航只更新相应状态与链接，具体实施继续只维护该变更 tasks.md；不得将私人日志、绝对工作站路径或本机运行态复制进公开导航

#### Scenario: Switch navigation language
- **WHEN** 人类在两版 OpenSpec 导航间切换
- **THEN** 事项、状态和证据保持对应，各自正文使用所属语言；公开包不因该源码导航增加新的安装目标

### Requirement: Non-blocking forward environment notices

环境准备 SHALL 区分下一步必需的即时前置与后续检查才需要的远期预告。`Needed before next action: no` SHALL 使用中性说明，明确当前无需人类操作或回复，SHALL NOT 包含命令式行动或当前确认请求。接近依赖步骤时 SHALL 重新核对，真实即时前置未就绪 SHALL 保留 blocked 与 Resume condition，不得伪报验收。

#### Scenario: Offline session before later environment check
- **WHEN** 当前继续离线实现，环境只供之后的验证使用
- **THEN** handoff 保留预告和后续检查点，当前无人工要求；Agent 继续已授权离线工作，不等待预告中的准备

#### Scenario: Immediate prerequisite pending
- **WHEN** 任一下一步必需的环境项仍 pending 或 unknown
- **THEN** 保持 continue/blocked 与 Resume condition，不派发 Agent、不提前关闭；需要人类时才给出具体操作和最小回复

### Requirement: Self-contained authorized continuation across sessions

新建或正常更新的可执行 `continue` 交接 SHALL 在 Current Status 中提供自包含的 Continuation Command，包含同一角色/批次、权威输入、下一目标、约束、输出及角色提示。已激活任务中的可执行 Agent SHALL 在核对最新状态后自主接续；本地 CLI/IDE 宿主选择 SHALL NOT 作为负责人决定。会话接替 SHALL 保持同一职责、范围和审查计数，不得用 continue 绕过独立审查或伪装实际角色派发。

#### Scenario: CLI turn ends without an actual blocker
- **WHEN** 单次执行器退出，handoff 为可执行 continue，接入的 Agent 具有所需能力与权限
- **THEN** 读取最新文件后执行下一步，不询问运行在哪个本地宿主；无进程运行不代表环境阻塞，也不承诺协议能够自动唤醒进程

#### Scenario: Wait stale message and exhausted allowance
- **WHEN** handoff 等待真实决定/环境，已关闭，输入冲突或适用的明确有限授权已耗尽
- **THEN** 接续指令不能覆盖真实状态，继续沿适用恢复、等待、关闭和明确有限授权规则处理

### Requirement: Compatible human intervention summary

新建或正常更新的 handoff SHALL 在 Routing 显示唯一 `Human Action Required: none|awaiting-decision|awaiting-environment`，与当前决定或环境等待一致。该字段 SHALL 仅摘要现有决定或环境等待，不授权、不建立新动作/状态，也不能单独判断是否需要用户手动转交。旧交接缺少字段或接续命令 SHALL 继续可读有效，无需历史回填；读取旧记录 SHALL 由实际状态和前置确定是否等待，不得仅因缺字段停下。

#### Scenario: Forward notice does not request intervention
- **WHEN** 只有远期未就绪环境预告，当前可以安全执行
- **THEN** 字段为 none，当前离线步骤可接续；有 ready 环境证据也不得误报 awaiting-environment

#### Scenario: Human waiting consistency
- **WHEN** 当前等待负责人决定或确需人类解决的即时环境前置
- **THEN** 分别显示 awaiting-decision 或 awaiting-environment，保留 Owner Decision Brief 或 blocked/Resume condition；等待和关闭交接不附可直接执行的 Continuation Command

#### Scenario: Legacy compatibility and structural boundary
- **WHEN** 校验旧交接，或校验带有新字段/接续块的交接
- **THEN** 旧结构仍通过原有规则；新字段非法、重复或与已声明状态矛盾时失败，代码围栏内的示例不充当真实字段或命令；结构成功不证明宿主遵从、环境真实就绪或业务验收

#### Scenario: Operator transfer is needed without a decision or environment wait
- **WHEN** 人工接力 Agent dispatch 使用现有 `none` 且需要用户转交指令
- **THEN** 在人类可见交接和最终回复直接说明需要转交；不显示为无需任何人工操作，不伪造 awaiting-decision 或 awaiting-environment，并说明旧消费方仍可能误读该字段

### Requirement: Manual relay at Full agent dispatch

新 Full 任务 SHALL 默认使用人工接力。人工接力下的正式 Agent `dispatch` SHALL 保存、回读并按已决定状态校验交接，提供下一角色的完整 Operator Command 与 C1–C5 建议，然后结束当前回合，由用户选择工具启动接收者。该边界 SHALL NOT 改变业务授权或创建负责人决定。

#### Scenario: New task reaches a role handoff
- **WHEN** 新 Full 任务未明确选择自动接续，首席设计师完成设计并派发实施角色
- **THEN** handoff 和最终回复明确用户需人工转交，写有完整指令和实施角色的适用能力建议；设计角色结束本轮，不运行实施步骤或启动接收 Agent

#### Scenario: Manual relay applies to a same-role agent transfer
- **WHEN** 人工接力任务需要将同一正式职责派给另一 Agent
- **THEN** 当前 Agent 形成既有 Agent dispatch 并结束本轮，不通过子代理、CLI、API 或改名自行启动接收者

#### Scenario: Explicit automated relay within authority
- **WHEN** 用户明确允许本任务自动启动已授权后续 Agent，宿主具备该能力且当前没有更窄的停止指令
- **THEN** 可按现有路由继续，在每个真实边界保持交接、权限及审查独立性；功能被禁用或权限不足时不得借其他启动方式绕过限制

#### Scenario: An active same-role continuation
- **WHEN** 人工接力任务中的合格 Agent 已被用户启动且当前为同角色可执行 continue
- **THEN** 核对授权、归属与额度后继续该角色的普通工作；不因每个工具调用或局部步骤要求人工转交

#### Scenario: An existing task is resumed
- **WHEN** 新规则生效前已有未关闭任务，或旧交接没有接力偏好
- **THEN** 沿用实际已有授权、活动角色和下一动作，不回填、重放或改写历史；本次用户明确收窄停止边界时按当前指令执行，不凭缺字段猜测自动授权

#### Scenario: Closed-batch follow-up starts in the current session
- **WHEN** 关闭后当前请求明确授权新工作，现有规则允许本会话进行 Task Intake
- **THEN** 可在同会话完成适用的 Task Intake；随后产生正式 Agent dispatch 时遵守该任务的人工或明确自动接力选择，不要求重复授权业务范围

#### Scenario: A real wait or unavailable host remains authoritative
- **WHEN** 真实负责人决定、环境前置、执行归属冲突、独立性或审查额度限制下一动作
- **THEN** 保持对应真实等待或限制，不把人工接力当作授权、伪造环境阻塞或绕过限制

### Requirement: Portable and bounded manual relay guidance

人工接力的用户可见交接 SHALL 简短说明需由用户转交、下一职责和复制入口；接收者 SHALL 依据可获得的实时权威确认范围、归属及审查计数。说明 SHALL 区分共享工作区与无法直接访问工作区的工具，不声称已上传、已持久化或自动完成脱敏。

#### Scenario: Shared workspace
- **WHEN** 下一工具可以访问同一项目与当前交接
- **THEN** 用户可转交完整 Operator Command，由接收者核对实时状态后执行自己的已授权职责，不要求再次批准已授权业务工作

#### Scenario: Non-shared or read-only workspace
- **WHEN** 下一工具不能读取或写入当前项目
- **THEN** 说明仅提供必要且经过用户审核的资料；无法更新实时状态时使用现有响应交接及来源匹配规则，不能声称已写回或验证最新状态

#### Scenario: Distinct platforms do not establish review independence
- **WHEN** 用户选择不同平台、模型或推理强度执行后续审查
- **THEN** 仍按既有角色、产出归属与证据规则判断独立性，不仅凭平台不同或更换角色标签宣称独立

### Requirement: Explicit write permission for formal handoff outputs

正式角色派发 SHALL 在指令和输出列表中明确交接产物的写入权限。默认业务代码只读的审查 SHALL 显式允许维护所需审查记录、索引及 `.ai/handoff.md`，不授予业务代码写权限。派发者 SHALL NOT 仅因审查独立、泛称只读或个人偏好自行增加无适用来源的 `.ai/` 禁令。用户或适用上位指令的明确禁令、实际工具权限不足时 SHALL 保留限制并要求完整响应交接，SHALL NOT 静默省略出口或覆盖真实禁令。

#### Scenario: Business code is read-only and workflow outputs are writable
- **WHEN** 生成正式独立审查的派发指令，未要求完全只读
- **THEN** 明确列出允许写入的审查记录、索引和 handoff；下一角色可更新这些产物而不改动业务代码、测试或无关文件

#### Scenario: Assignment explicitly prohibits runtime writes
- **WHEN** 派发明确禁止 `.ai/` 写入但允许审查产物
- **THEN** 指令要求完整替代交接及未落盘原因，审查角色保持 `.ai/` 不变，在获准审查记录和回复中交付出口，不将禁令理解为允许偷偷写回

#### Scenario: Dispatcher cannot invent a runtime write ban
- **WHEN** 生成普通正式独立审查的指令，没有用户/上位禁令且交接输出可写
- **THEN** 派发者不得自行把 `.ai/` 加入禁写范围或把该审查降为仅回复交付；生成的指令仍逐项允许必要交接产物

#### Scenario: Response-only consultation does not transfer a task
- **WHEN** 请求仅为只读咨询或局部意见，没有正式接管或角色转移
- **THEN** 按原请求返回意见，不因默认产物授权规则创建或改写 live 业务运行态

### Requirement: Observable handoff persistence at real boundaries

获准写入的负责角色 SHALL 在真实派发、等待、计划会话中断和关闭边界持久化 handoff，回读核对本次意图对应的批次、路由、累计审查计数及已有修订号，再执行适用校验。最终回复 SHALL 简短说明实际持久化结果或未完成原因。SHALL NOT 仅依据写入调用成功或旧文件结构通过声称本次交接已完成。计划让出执行或切换会话 SHALL 视为真实边界，即使角色不变；普通连续微步骤不新增写回和重复检查要求。可预见长检查的恢复检查点 SHALL 只记录已知进度、未决结果与日志引用，不提前声称检查通过。

#### Scenario: Writable reviewer completes a verdict
- **WHEN** 获准写交接的正式审查角色完成一个 verdict，并派发修复或选择其他有效出口
- **THEN** handoff 显示该真实出口和本批实际累计计数，回读及校验匹配本次意图；回复说明文件已更新，不保留审查前路由冒充最新状态

#### Scenario: Planned session interruption with executable continue
- **WHEN** Agent 计划在未完成的同职责工作处结束会话或交接上下文
- **THEN** 保存有效进度、剩余工作和证据，并按现有规则提供可执行 continue 接续块；不把会话边界虚构为环境阻塞，不对每个微步骤另建交接

#### Scenario: Save or read-back validation fails
- **WHEN** 写入被拒绝、保存内容与本次意图不符或边界校验失败
- **THEN** 不报告已成功持久化或普通 accepted；可恢复时在权限内修正，否则提供完整替代交接、实际限制和最小恢复方向，不绕过权限

#### Scenario: Process ends before it can persist state
- **WHEN** 无预告进程崩溃或断线使 Agent 来不及写回
- **THEN** 不承诺此次内存进度已经保存，接续只能依据实际存留的明确证据恢复，不由聊天猜测状态或宣称后台保证完成

#### Scenario: Same role moves to another session
- **WHEN** 未完成工作的角色不变，但准备结束当前负责会话并由另一会话接续
- **THEN** 不能援引微步骤例外省略写回；保存当前事实和下一步，保持批次、职责、实际计数及适用修订号

#### Scenario: Adjacent work remains in the active session
- **WHEN** 同一活跃负责 Agent 在稳定范围内执行相邻局部动作，没有计划让出执行或其他真实边界
- **THEN** 继续工作，不强制每次编辑、工具调用或检查都复制交接、创建结果或再跑校验

#### Scenario: Long check has material interruption risk
- **WHEN** 已知下一检查可能跨越会话预算，且此前已有值得保存的实质进度
- **THEN** 在权限内利用既有 continue 保存简短恢复点并引用日志；待检查仍标为未决，不添加后台保证或每步预写日志

### Requirement: Durable source-linked fallback handoff

正式转移因权限限制使用替代交接时，负责角色 SHALL 给出完整 Routing、适用命令及状态影响，并说明其未写回。允许写审查产物时 SHALL 复用同轮记录保存完整替代交接，索引只链接；允许写既有实现/修复结果时 SHALL 在其 Next Action 内承载所需恢复交接，SHALL NOT 将其伪装成审查。禁止文件写入时 SHALL 在回复保留同等信息。新替代交接 SHALL 说明批次及对应旧交接的修订号（若有）与字节指纹。只读子代理返回后，仍活跃且获准维护 handoff 的主/负责 Agent SHALL 在摘要、继续派发或结束该边界前核对并保存完整结论与交接，回读及校验，不推给用户或下一轮，不新增 verdict、冒充来源角色或绕过真实禁令。

#### Scenario: Reviewer can write only the review report and index
- **WHEN** 审查已完成但禁止更新 `.ai/handoff.md`
- **THEN** 同轮报告保存完整下一动作、真实累计计数及来源交接匹配依据，索引指向该报告；受限审查者说明其未写回，有活跃可写负责者时由其当轮发布，否则保留可供后续取得的完整交接

#### Scenario: Active writable owner publishes a read-only subagent result
- **WHEN** 宿主实际只读的子代理返回完整有效审查交接，当前主 Agent 仍活跃且获准维护同批次 handoff
- **THEN** 主 Agent 在用摘要代替原始返回、继续派发或结束本边界前，核对来源和执行归属，保存完整发现及决议、回读和校验；子代理保持只读，审查只计一次，不要求用户手写文件

#### Scenario: No permitted publisher remains active
- **WHEN** 没有活跃可写负责者，或用户/上位禁令对负责者同样有效
- **THEN** 保持完整响应交接和真实未持久化说明，不声称文件已更新、不绕过权限，也不要求为此建设新进程或后台恢复服务

#### Scenario: All file writes are prohibited
- **WHEN** 严格只读限制连审查记录也不能创建
- **THEN** 不新建临时状态文件，在回复交付完整替代交接；后续会话无法取得该交接时指出缺失来源，不自行补造 verdict 或路由

#### Scenario: An ordinary accepted close is only a response
- **WHEN** 替代交接包含普通 accepted 关闭结论
- **THEN** 仍遵守最终输入匹配的关闭证据和角色权限规则，旧 handoff 的 exit 0 不能证明新回复已验证；恢复不得补造缺失验收或批准

#### Scenario: Implementation result carries a complete recovery transfer
- **WHEN** 实现或修复角色需要在获准的既有结果中保留完整恢复交接
- **THEN** 在现有 Next Action 保存一份可提取的完整交接和来源依据，不新增 pending 文件、状态数据库或 review verdict；有活跃可写负责者时仍在同一边界发布 live handoff

#### Scenario: A normal result is not a recovery transfer
- **WHEN** 结果只记录工作摘要、检查、Decision 或 handoff 路径，没有完整交接及匹配依据
- **THEN** 不据此推断新路由、计数或验收，也不要求迁移旧普通结果；新交接继续遵守适用的正常写回或 fallback 规则

### Requirement: Source-matched recovery before stale routing execution

已激活任务的接续 SHALL 在执行旧派发前核对明确关联的同批次审查、实现/修复结果及替代交接。实现结果 SHALL 由当前任务或恢复前 live handoff 中的具体文件引用确定，SHALL NOT 因候选自我引用或目录扫描取得权威。确认来源对应当前旧状态、授权有效且无写入冲突时，获准 Agent SHALL 先恢复，再按实际职责执行。判为已应用 SHALL 比较同修订号的 Routing 及动作对应的执行内容，包括可执行 continue 的完整 Current Status。恢复 SHALL 保留来源、实际 verdict 和范围，SHALL NOT 重计、重放、依据时间或最大编号覆盖状态，亦不新增恢复审批。

#### Scenario: Completed review supersedes a pre-review dispatch
- **WHEN** live 文件仍派发审查、同批次明确关联的完成记录提供有效的修复派发，且来源匹配及写权限成立
- **THEN** 先恢复该交接中的累计计数和下一角色，再按角色资格执行；持久化本身不产生新 verdict，也不把恢复者伪装成原审查者

#### Scenario: A transfer was already applied or routing advanced
- **WHEN** 当前状态已应用该交接或已在其后前进
- **THEN** 继续按当前有效状态处理，不再次覆盖文件、计数或执行历史 Operator Command 或 Continuation Command

#### Scenario: Source conflicts or refers to another batch
- **WHEN** 来源批次不同、来源匹配依据矛盾、多个候选互相冲突或写入前发现文件已变更
- **THEN** 保留有效状态，指出具体冲突和最小恢复方向；不全盘扫描历史、不选最大编号、不猜测授权或静默覆盖

#### Scenario: Current limits prohibit the proposed next action
- **WHEN** 当前批次已关闭、真正等待负责人或环境，适用的明确有限授权已耗尽，或恢复者不满足角色独立性
- **THEN** 既有关闭、等待、预算及独立性规则优先，替代交接不能重开批次、忽略等待、增加循环或授权自审

#### Scenario: Older records do not contain the new matching narration
- **WHEN** 接续旧记录或已归档交接，缺少新指纹说明
- **THEN** 不要求历史回填；仅在既有明确证据足以无歧义确定同批次来源和出口时按原权限恢复，不足时指出缺失依据而不把旧文件当成已更新

#### Scenario: Named implementation result recovers without a review index
- **WHEN** 当前任务或 live handoff 事先点名的同批实现结果携带完整有效交接，原 handoff 尚未发布该转移
- **THEN** 在来源匹配和既有保护成立后先恢复，不要求创建审查索引；没有新 verdict 时保持原累计计数，实施者不得借恢复执行自审

#### Scenario: Unnamed file cannot nominate itself
- **WHEN** 仅在目录中发现结果文件，或其自身声称应作为下一状态，没有恢复前的明确权威引用
- **THEN** 不自动恢复，不按较新时间或最大编号选择它；若请求依赖该文件，指出关联缺失而不补造来源

#### Scenario: Same revision contains a different continuation
- **WHEN** live 与候选 Routing 和目标 revision 相同，但 Current Status 中的接续说明或 Continuation Command 不同
- **THEN** 判为 conflict，指出差异，保留 live，不因双方都没有 Operator Command 而判为 applied

#### Scenario: Legacy continue has prose rather than a command block
- **WHEN** 有明确来源的旧 continue 没有 Continuation Command，但 Current Status 提供足够的接续说明
- **THEN** 比较该完整状态说明，不仅比较缺失的命令块；缺少新块本身不要求回填，无法确定执行内容时不得猜测

#### Scenario: A result is updated after handoff validation
- **WHEN** 已发布 handoff 校验后向结果的 Checks Run 追加实际证据，使结果修改时间较新
- **THEN** 不据时间判定 handoff 过期，不由此重放、改写或额外要求人类行动

### Requirement: Optional expected handoff state validation

只读运行态校验器 SHALL 接受可选的预期批次及已有路由、审查计数和修订值，逐项比对所给预期；预期须来自已决定的转移或明确替代交接，SHALL NOT 从旧文件反推。已给预期非法、缺少所需批次，或实际字段缺失、重复、不符时 SHALL 返回非零并指出差异。采用新版契约的负责角色 SHALL 在接口可用的真实边界传入本次已决定状态；参数可选只保留旧调用兼容。无预期调用 SHALL 兼容原参数和其他结构规则，并应用当前版本的明确有限授权检查；不得自动推导路由、写文件或证明全局最新与业务验收。

#### Scenario: Structurally valid old handoff differs from intended transfer
- **WHEN** 旧文件结构正确，但所给预期表示同批次已完成审查后的计数、动作或目标角色
- **THEN** 返回非零，标明不符字段，不以原 exit 0 代替本次交接成功

#### Scenario: Expected state matches saved routing
- **WHEN** 合法的预期批次及所给字段与唯一实际 Routing 一致，且原结构规则全部满足
- **THEN** 返回 0，说明检查了结构与所给预期值，不声称来源真实性、全局新鲜度或业务验收

#### Scenario: Updated boundary supplies the decided expectations
- **WHEN** 负责角色按新版契约新建或正常更新真实交接，使用已支持预期接口的校验器
- **THEN** 边界检查必须传入本次已决定的批次、动作、下一角色和累计审查计数，存在修订号时附该值；旧式无参数 exit 0 不构成本次已完成预期比对的证据

#### Scenario: Invalid or ambiguous expectation input
- **WHEN** 提供预期值却缺少有效预期批次，或所给预期为空、格式非法、实际字段缺失或重复
- **THEN** 返回非零；显式预期 Review round 为 0 仍是已提供的有效值，围栏示例或其他段落不能充当实际 Routing 字段

#### Scenario: Matching expectations cannot bypass an existing violation
- **WHEN** 预期值匹配，但交接违反适用的明确有限授权、角色、等待或关闭结构规则
- **THEN** 仍返回非零，预期检查不能豁免原有约束

#### Scenario: Legacy invocation omits expectations
- **WHEN** 原调用不传任何预期参数，旧交接没有可选修订号或新说明
- **THEN** 保持其他结构检查与兼容告警，并应用当前版本审查规则；不强制迁移、自动恢复、发布或添加运行态字段；此兼容不豁免新版负责角色的边界预期比对义务

#### Scenario: Three verdicts alone do not block an executable route
- **WHEN** 最新已授权交接累计三次或更多 verdict，未命中适用的明确有限上限，其他结构与预期均有效
- **THEN** 校验不因默认三次门槛拒绝该路由；仍不证明授权真实性、独立性或业务验收

#### Scenario: A structured finite authorization is exhausted
- **WHEN** 当前动作受本批有效结构化有限授权约束，计数达到其 through，或被用于本动作的结构化授权无效
- **THEN** 可执行 continue 或 Agent dispatch 校验非零，合法等待及关闭仍可表达；不得把无效授权当作不存在来绕过其限制

### Requirement: Bounded reference reading and log handling

Full 入口、公共角色指引和相关模板 SHALL 一致地区分当前任务／交接／受影响输入与参考手册，优先定位适用章节。同会话已知未变的参考 SHALL 可复用；新 Agent、上下文缺失、输入变化或疑问 SHALL 触发相应刷新。该规则 SHALL NOT 绕过当前适用项目／模块指令或已触发 Skill 的必读要求，也不引入缓存台账、强制禁读、风险降级或额外生命周期。

#### Scenario: Same agent continues bounded work
- **WHEN** 同一 Agent 在稳定范围中继续相邻步骤，参考内容已读且已知未变
- **THEN** 复用适用参考并读取本步所需输入，不因每次工具调用重读整本手册或计算阅读清单指纹；真实交接边界仍刷新当前权威并落盘核对

#### Scenario: Context or relevant inputs change
- **WHEN** 新 Agent 接手、已有上下文不足、相关规则／输入变化或出现规则疑问
- **THEN** 重新读取适用权威及相关规则章节，不因曾读过摘要而跳过新约束，不从聊天历史猜测最新路由

#### Scenario: Clear intake does not need a requirements dialogue
- **WHEN** 用户目标已明确，Task Intake 能安全总结范围与验收
- **THEN** 保留既有直接分流，需求分析详细材料按实际触发需要加载；不能因单文件、小实验或预算偏好忽略按真实影响判定的 M/H 要求

#### Scenario: A check produces large output
- **WHEN** 本次检查有大量日志且具备外置输出条件
- **THEN** 生成时保存到具名结果或日志，返回必要摘要／实际结果／路径，在交接中引用而非复制全文；不宣称保存文件能移除已经进入会话的上下文或证明费用下降

### Requirement: Minimal evidence examples and bounded convergence

工具包 SHALL 在现有说明中提供可追溯的最小取证、计数勘误和只读返回发布示例。仅当验收要求真实 Agent 行为证据且采集方法尚未验证时，SHALL 先确认一个最小调用能对应输入、可得会话信息、返回及产物。示例 SHALL 使用明确来源、保留失败和未知，复用匹配输入下的已有证据；SHALL NOT 为普通任务增加统一取证前置、账本、自动汇总工具或额外审查。

#### Scenario: An agent exercise has an unproven capture method
- **WHEN** 演练明确要求实际调用来源，当前采集方法未被验证
- **THEN** 先确认一条最小端到端路径再扩大样本；不可取得的宿主信息记为未知，不用预填状态或事后叙述补成同期执行

#### Scenario: A summary miscounts launches
- **WHEN** 具名来源足以确认六次启动，而汇总误写七次或混入结果整理动作
- **THEN** 新增勘误并指向正确来源，分别表达启动、后续输入、失败及共享协调，不把缺记录当零；仅核对受影响统计和结论，不改原报告或无故重跑已成立样本

#### Scenario: Explanation grows without resolving the evidence gap
- **WHEN** 同一缺口仍缺实际来源，修复只增加状态或说明
- **THEN** 在既有交接中简述失效方法、缺少的能力／来源和下一步最小方法；未能恢复的历史保持未验证，不新增失败计数门槛或延长审查额度

#### Scenario: A fully read-only reviewer returns a transfer
- **WHEN** 已有规则允许的只读评审返回完整结论及交接，活跃写者具备发布权限
- **THEN** 按原来源匹配规则保存完整返回，并仅对无歧义格式作规范化后发布、回读及预期核对；技术结论有歧义时不得代改，发布本身不另计 verdict

### Requirement: Advisory delivery quality feedback

Full 和 Lite 的既有独立审查／复核在确实评价实施或修复交付时 SHALL 默认附简短的本次交付质量 1–5 分或无法评分、已有发现依据及有必要的原因／建议。Full 由 Code Reviewer 评价实施交付、由独立复核者评价修复交付；Lite 由对应 Reviewer 评价。反馈 SHALL 保存在现有审查结论并在最终回复简短复述，SHALL NOT 引入额外调查、审查、权重、评分文件、handoff 字段或角色自评。

后续发现导致返工时，审查 SHALL 仅依据本轮已有证据简述问题来自实施、修复、证据判断或审查产物，无法归因时说明未知；SHALL NOT 将全部返工自动归给实施者、以最终修复高分替换早期评分，或为归因新增角色评分与调查。

#### Scenario: An implementation review has sufficient evidence
- **WHEN** Code Reviewer 或 Lite Reviewer 已有足够的本次送审范围和发现
- **THEN** 依据实际影响评价：5 为当前范围无已证实必须修且必要证据齐备，4 为总体可靠而局部可修，3 为明确漏项／必要检查不足／修复不全，2 为关键错误／回归／已指明问题反复未解，1 为严重偏离明确要求／主要结果不可用／重大危险；不按缺陷数量、轮数或篇幅机械计算

#### Scenario: An existing verification checks a fix
- **WHEN** 本来就需要的独立复核检查本次修复
- **THEN** 评价该次修复是否解决已指明问题、保留必要证据并避免回归，引用已有发现及受审版本；保留先前评分，不以最终修好后的评价回填首轮

#### Scenario: Evidence or attribution is insufficient
- **WHEN** 可见材料不足以判断质量，或不能确认实施、输入设计、环境工具与审查口径各自的影响
- **THEN** 允许无法评分或原因尚不明确并说明缺口；不把未知自动记作低分，不猜模型能力、虚构推理强度或开展新的评分调查

#### Scenario: A task has no implementation or fix review
- **WHEN** S 任务正常自查收口，或现有审查仅涉及其他角色的设计／需求／文档协调
- **THEN** 不为评分增加独立审查，不要求每个角色都评分；Lite 的简短评价定义保持自包含，不新增 Full 手册必读

#### Scenario: Advice coexists with acceptance and legacy records
- **WHEN** 交付评分较高但仍有未解决验收，或旧报告没有评分，或本次默认评价被遗漏
- **THEN** 正式发现、验收和既有出口继续决定通过与否；旧记录不回填，当前遗漏可在已有保存步骤补充但不转成业务必须修或新增复核。分数不改变 C1–C5、风险、授权、路由或累计 verdict，也不自动换模型

#### Scenario: A verification report creates a new disclosure
- **WHEN** 后续证据证明新增敏感信息来自验证报告，而非被审实现
- **THEN** 在新的发现／结论中指出来源并修复适用的交付产物，保留先前评分及历史结论，不自动降低实施者评分或扩成审查员评分体系

### Requirement: Privacy-safe review artifacts

审查、验证、修复结果和交接 SHALL 遵守适用的交付隐私边界，以虚构别名、字段名、计数和状态表达证据，并在既有交付步骤核对产物自身及适用的待提交副本。历史事实和 verdict SHALL 保留；必要脱敏 SHALL 仅按适用授权最小处理并记录不含私有值的说明，不要求独立脱敏角色或自动扫描平台。

#### Scenario: Private evidence is summarized
- **WHEN** 现有检查需要引用真实业务证据
- **THEN** 公开／待提交报告及 handoff 不复制发票字段、私有样本标识、凭据或原始日志中的私密值；必要原件按项目隐私边界保存，结论仍能通过已授权渠道追溯

#### Scenario: A historical report requires redaction
- **WHEN** 已有报告含禁止交付的私有值且当前授权允许必要脱敏
- **THEN** 对实际泄露的报告及适用待交付副本做最小处理，以无私有值的方式确认结果；保留事实、结论、评分及历史引用，不以普通勘误代替移除实际泄露，也不输出含私有值的差异

### Requirement: Bounded archive verification

归档核对 SHALL 按当次规范同步及产物影响确定范围和风险，核查 delta／主规范对应、文件完整性、完成状态、索引及交付隐私，复用仍匹配的实施证据。必要独立性 SHALL 保留；SHALL NOT 自动将原实现最高风险或无关全局失败作为本次新门槛，也不为所有任务增加固定独立归档审批。核对通过 SHALL 结束当前核对范围。

#### Scenario: Only synchronized specs and archive records change
- **WHEN** 已通过完整审查后只进行授权的规范同步与归档
- **THEN** 核对本次规范及归档差异，保留实现审查结论和限制，不重做无关业务验证；同步引入契约变化或矛盾时按其实际影响处理

#### Scenario: Unrelated archives fail a global check
- **WHEN** 全局检查因其他历史归档失败，但当前归档的相符依据有效
- **THEN** 分别记录当前结果和全局失败，不伪称全局通过，也不要求本次修复所有历史提案

#### Scenario: Independent archive check passes
- **WHEN** 已授权的独立归档核对无范围内实际缺陷
- **THEN** 结束该核对并记录结果，不为复制状态或复述结论再派发审查；未满足的上级事项和限制仍如实保留

### Requirement: Source-only reproducible first-handoff sample

源码 SHALL 提供固定输入、明确预期和可检查初始缺陷的独立首次交接样例，使用户无需自编业务需求即可开始。样例 SHALL 预置唯一 OpenSpec 需求与未完成实施清单，不携带已生成运行态、安装状态或审查结论；人类指南 SHALL 中英文对应，既有机器契约不翻译或复制。

#### Scenario: Prepare a fresh sample
- **WHEN** 用户从明确源码版本取得样例并复制至新的可丢弃项目
- **THEN** 可识别同一需求、初始缺陷与行为检查，未预置当前任务、handoff 或通过记录；实际 A/B 状态由本次 Agent 生成

#### Scenario: Initial defect and corrected behavior
- **WHEN** 对原始样例和其可丢弃修复副本分别执行约定行为检查
- **THEN** 原始样例至少一项检查失败并返回非零，正确修复后全部约定案例通过且返回 0；不能以文本匹配或预写 PASS 代替行为证据

### Requirement: Trial source acquisition preserves package boundaries

首次演示 SHALL 区分源码检出、可信完整安装包和独立目标，沿用官方受保护安装。样例 SHALL 仅留在源码并从安装导出排除，不新增受管路径。取得说明 SHALL 使用能包含样例的固定提交检出或经过明确核对的离线源码副本，SHALL NOT 把自动源码归档或完整安装 ZIP 当作必然含样例的来源。

#### Scenario: Sample is export-ignored
- **WHEN** 样例被 export-ignore 排除且用户需要获取样例
- **THEN** 指南提供固定提交 Git 检出路径，安装包另从可信发行取得；不指导用户用可能排除样例的自动源码 ZIP，也不拼改安装包清单

#### Scenario: Candidate has no published sample commit
- **WHEN** 样例仅存在于尚未提交的本地候选
- **THEN** 本地证据记录候选文件指纹与实际包版本；公开固定提交与下载验证保持待后续提交准备，不编造 SHA 或声称尚不存在的公开链接已可用

#### Scenario: Existing installations keep their layout
- **WHEN** 维护者新增源码样例及包根入门说明
- **THEN** 样例不部署至目标项目，既有受管集合、Lite／Full、SkillTarget 和模式保持原语义，不能通过向 payload 新增演示文件绕过布局演进要求

### Requirement: First-handoff exercises use real fresh sessions

首次演示 SHALL 使用真实会话 A 准备交接、没有 A 聊天上下文的真实会话 B 按当前有效 handoff 实施；在两个全新目录记录实际过程。SHALL 沿用既有直接规范读取、Git 基线、A 交接备份及角色权限要求，不将脚本代填状态、同会话更名或事后叙述作为真实 Agent 演练。

#### Scenario: Session B continues the authorized task
- **WHEN** A 按 start 产生有效实施派发，B 收到接续入口与实时完整 Operator Command
- **THEN** B 核对当前批次、权限和路由后执行已授权任务，维护同一 OpenSpec 清单与真实交接，并通过约定行为和最终状态检查；复制命令计为标准人工动作

#### Scenario: Exercise evidence is unavailable
- **WHEN** 缺少实际 Agent 调用、无法证明 B 没有 A 聊天上下文或无法取得必要执行结果
- **THEN** 对应演练保持未验证并记录缺口；可继续无依赖的本地工作，但不能勾选实际演练验收或建设新的运行时引擎替代该证据

#### Scenario: S sample and M maintenance are separate
- **WHEN** 维护样例的变更风险为 M、样例内真实任务风险为 S
- **THEN** 维护交付接受独立聚合审查，样例任务仍按实际风险自检与关闭；不为增加样例审查次数而改变风险或重置任一批次累计数

### Requirement: Staged trial claims follow observed evidence

路线图和试用报告 SHALL 分开记录本地复现、公开获取与外部 G0。G0 SHALL 要求两个新目录内部复现及三位目标用户首次尝试中至少两位无额外辅助完成；十分钟目标单列。人数或条件不足 SHALL 保持外部待验证，允许有限内部 Phase 1，不替代真实结果或增加自动遥测。

#### Scenario: Internal exercise passes without external users
- **WHEN** 内部演练已完成但外部首次试用尚未开展或人数不足
- **THEN** 可按本变更的本地映射验收关闭，并明确外部 G0 未通过；内部 Agent、重试和辅助成功不能冒充新的外部首次独立完成

#### Scenario: First attempt needs rescue
- **WHEN** 观察者补讲需求、代操作或修改用户输入后试用完成
- **THEN** 首次结果与额外辅助保留，修订后的成功另记；不能以成功重试覆盖失败、退出或未知耗时

#### Scenario: Calibrate the roadmap
- **WHEN** 根据当前版本与实际证据更新双语源码路线图
- **THEN** 保留已经完成的能力，按现有状态词标明尚缺证据，链接正式任务与独立后续入口；路线图不复制勾选清单、运行态或审查计数，也不自动授权外部操作与后续阶段

### Requirement: Evidence-based review convergence

实际 verdict SHALL 保持单调记录；通用默认三次总数 SHALL NOT 独自阻断已授权的正常设计、代码审查和验证。两个针对同一未解决问题的连续修复及独立复核循环没有可验证进展时，负责角色 SHALL 暂停重复循环，依据既有记录分析原因和可执行下一步；真实负责人决定仍按适用授权处理。

#### Scenario: Normal design code and verification verdicts
- **WHEN** 设计、代码及修复后验证共形成三次 verdict，范围仍获授权且未触及明确限制
- **THEN** 按实际缺陷和验证条件处理后续动作，不仅因次数为三而要求追加授权；独立性及手动交接不变

#### Scenario: Same finding does not converge
- **WHEN** 针对同一未解决发现连续两次修复和独立复核，均没有已核对且能缩小根因或消除既有阻碍的新证据，也没有已验证的实质改善
- **THEN** 暂停该问题的重复修复循环，保留历史并交有权负责角色分析；只有需改变业务、权限、风险、成本或无法在现有授权内继续时才请求负责人决定

#### Scenario: Evidence is insufficient to assess progress
- **WHEN** 无法确定两个循环是否针对同一问题，或无法核对声称的进展
- **THEN** 保持相关验收未完成，先指出和核对缺失的具名记录，不凭改名、文件时间或未验证叙述推断进展或重置历史

#### Scenario: Explicitly limited review
- **WHEN** 负责人只授权一次追加审查，或设置明确的 from 和 through
- **THEN** 范围和绝对上限继续生效；到期、范围外或权限不明时不自动增加修复或审查

### Requirement: Relevant-scope review history

跨批次处理 SHALL 保留每个真实 verdict 的原始记录与可追溯来源。同一未完成验收的相关历史 SHALL 关联并保持实际计数；仅涉及不同可区分范围的审查 SHALL NOT 因父提案编号相同而自动计入当前验收。无法证明关联时 SHALL 说明未知，不自动清零或猜测。

#### Scenario: Offline review is outside face acceptance
- **WHEN** 一个历史批次同时覆盖两个范围，后续独立审查明确只检查其中一个，另一个范围随后继续
- **THEN** 保留全部历史及全局记录编号，按审查实际覆盖关联另一范围的相关记录；不把后续无关审查自动计入该范围，也不删除原批次相关 verdict

### Requirement: Environment-aware review preparation

当当前验收确实依赖特定环境或样本时，负责角色 SHALL 在派发依赖它的验证前按已有证据作有界准备核对。未就绪的验证 SHALL 保留缺口及恢复条件；已授权且不依赖该条件的工作 SHALL 可按现有角色与依赖规则推进。未变化的环境 SHALL NOT 导致重复执行已知无法完成的同一验证。

#### Scenario: Later authenticated path is unavailable
- **WHEN** 隔离账户或测试数据尚不可用，但授权的离线实现及定向检查可以执行
- **THEN** 继续安全工作并记录真实入口尚未验证；只有该入口依赖的动作等待，模拟结果不能替代真实认证证据

#### Scenario: No new environment information
- **WHEN** 同一验证因缺失环境被记录为未完成，后续没有相关环境或输入变化
- **THEN** 复用该限制和仍匹配的证据，不再派发只会重复相同阻塞的验证；具备新条件时按实际范围独立验证

### Requirement: 成果就绪与分层检查

Full 协作 SHALL 在现有授权和角色边界内支持围绕约定的可观察成果连续实施、执行直接相关检查并聚合修复，再于适用节点进行独立审查。明确要求的提前检查、前置依赖和安全限制 SHALL 继续适用。

#### Scenario: 开发期间连续完成主路径

- **WHEN** 实现角色在授权范围内开发尚未达到约定复核节点的功能，且没有明确的提前审查要求或其他阻断
- **THEN** 该角色可连续完成相关实现、必要的直接检查和局部修复，无须为每个局部修改派发正式审查；到适用节点后按风险要求准备聚合审查

#### Scenario: 明确的提前检查或前置依赖

- **WHEN** 用户或项目明确要求某一步之前独立审查或验证，或该步骤有实际安全前置
- **THEN** 该要求优先于一般的聚合时机，不能以尽早交付或试用为由跳过

#### Scenario: 试用候选不等于最终验收

- **WHEN** 某项授权工作已有适合受控试用的实现，但最终独立审查、验证或其他验收尚未完成
- **THEN** 交付说明区分已支持范围、未验证事项及剩余检查；试用不自动产生最终通过结论，也不新增负责人审批门槛

#### Scenario: 危险路径尚未受控

- **WHEN** 提议试用的路径可能触及真实设备、资金、生产数据、外部部署或其他实际副作用，而必要授权或安全条件尚不存在
- **THEN** 该路径不得按可用试用交付，须先修复、禁用或在获得授权的隔离条件下限制，并且不妨碍其他安全且已授权的工作

#### Scenario: 高风险修复的独立性

- **WHEN** H 级验收涉及修复且适用既有修复后独立验证规则
- **THEN** 试用或实现者的自检不能替代所需的独立代码审查和修复后独立验证，未验证不得记为已验证

### Requirement: 重复往返的聚合整理

对同一未完成的映射验收，连续两次实际修复及独立复核后若仍需再次进入正式修复或复核，现有有权角色 SHALL 先在现有记录内作一次简短聚合整理，再按既有授权和人工接力继续。整理 SHALL 不构成 verdict 或默认审查上限。

#### Scenario: 局部进展但验收仍未完成

- **WHEN** 同一验收已有两次修复及其对应的独立复核结果，即使每次都有已验证的局部进展，仍计划进行下一次正式往返
- **THEN** 整理引用已有结果，说明已确认改善、剩余阻断或新回归，以及最小的聚合修复和证据计划；不因达到两次自动请求额外授权或关闭验收

#### Scenario: 原停滞规则同时适用

- **WHEN** 两次往返同时满足既有的同一问题无进展或重复出现新问题的停滞条件
- **THEN** 一份符合既有停滞规则的技术分析可以同时满足聚合整理，不额外增加一次角色交接或忽略原规则

#### Scenario: 整理后尚需其他角色

- **WHEN** 已有权限的当前角色完成整理，但下一项修复或独立复核应由另一角色执行
- **THEN** 使用现有人工接力保存完整交接并停止，由用户选择平台和模型；不得自行启动或代行下一角色

#### Scenario: 有限授权已经用尽

- **WHEN** 适用于同一未完成验收的负责人有限授权上限已达到，且尚无足以验收的证据
- **THEN** 不得借整理绕过上限继续新循环，应按现有负责人决策路径处理；不改写已记录的授权和审查历史

#### Scenario: 整理不反复触发

- **WHEN** 已完成一次整理，尚未针对同一验收产生两次新的修复及独立复核往返
- **THEN** 不因单次本地测试、重复命令、角色切换或查看历史再次要求该整理；已有未完成工作仍按当前授权及既有规则处理

#### Scenario: 记录不足或总数较高

- **WHEN** 现有证据无法确认相关往返，或旧验收的累计 Review round 很高但未达到有效有限上限
- **THEN** 保留不确定性，不编造历史、按总轮次推定该整理或自动阻断；继续可执行的安全工作，并在声称验收前补足必要证据

#### Scenario: 不借验证逃避审查计数

- **WHEN** 在同一批次和验收中形成独立审查、独立验证或发现裁定的正式 verdict
- **THEN** 按既有规则累计 Review round；两次往返的识别与总审查计数分别维护，不因名称或角色变化删除 verdict 或将本地命令充作 verdict

### Requirement: 发现处理与可复用证据

协作 SHALL 根据当前验收、实际影响和证据区分阻断、未验证与可延后建议，仅在证据输入、环境及覆盖范围仍适用时复用证据，并保留明确要求的修复和检查。

#### Scenario: 真实风险不可降级

- **WHEN** 已有证据表明缺陷影响安全、身份、并发、数据、资金或实际业务契约
- **THEN** 按其对当前验收和试用的实际影响处理，不能为了减少审查次数将其改称风格建议或宣告通过

#### Scenario: 合并机械修正

- **WHEN** 同批有项目要求的机械格式修正，且不存在要求该修正立即独立复审的适用门槛
- **THEN** 可与相关修复和其后适用检查合并，不能仅因单行修改就必然新建一次完整正式往返

#### Scenario: 变化使证据失效

- **WHEN** 后续改动影响先前证据的输入、环境或所覆盖行为
- **THEN** 不得声称旧证据仍证明受影响部分已通过，应补充适用检查或明确保留未知；未受影响且匹配的证据可以复用

### Requirement: 入口与目标指令保留审查和人工接力

Full 入口 SHALL 区分新任务初始化与同一未完成批次的合法接续；目标型指令 SHALL 不替代适用的独立审查、显式步骤及人工跨角色接力。

#### Scenario: 新任务与已有批次

- **WHEN** 新任务使用 start，或已有未完成批次通过 continue 或 start 的既有同批委托语义接续
- **THEN** 新任务入口按现有职责准备输入；接续遵循当前交接和授权，不凭入口名称重置历史或关闭未完成验收

#### Scenario: 实现目标不省略指定审查

- **WHEN** 用户要求完成目标并明确要求独立审查，或现有规则要求该审查
- **THEN** 按要求准备并执行适用的独立审查，不因目标已实现或某项结构检查通过而跳过

#### Scenario: 用户指定本轮只执行一个角色

- **WHEN** 用户要求当前角色完成后停止且下一工作由另一角色承担
- **THEN** 当前角色准备并保存下一角色的完整人工交接后停止，不自动启动或执行下一角色，也不把该停止误记为环境阻断
