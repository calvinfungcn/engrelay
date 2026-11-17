# Spec Delta

## MODIFIED Requirements

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

### Requirement: Coherent role routing and review independence

角色 SHALL 以职责及实际需要路由；稳定范围内的问题由有权限的当前负责人继续。
每个真实交接边界 SHALL 选择 continue/dispatch/close 中一个动作；Agent 派发
SHALL 提供完整自包含 Operator Command。M 代码审查及 H 所需验证 SHALL 保持独立。

追加审查和关闭后修复 SHALL 按实际授权范围执行并关联原验收及历史；同一未完成验收 SHALL NOT 通过关闭、改名或新批次清零实际计数、规避明确有限授权或隐藏未完成问题。单次追加审查 SHALL NOT 自动授予后续修复循环；已关闭历史不重开，真实新缺陷仅在适用授权下建立关联修复。

Full SHALL 区分角色结束与批次验收：同批实施未完成时交接，独立设计交付完成时合法关闭；映射与已授权目标冲突时交 Chief Designer 核对。真实边界 SHALL 保持活动任务、交接、Review 与唯一清单的事实一致。

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
