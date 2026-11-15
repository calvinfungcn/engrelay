# Spec Delta

## MODIFIED Requirements

### Requirement: Actionable closed-batch guidance

Full 接续遇到已关闭批次时 SHALL 依据最新适用权威说明关闭结果、映射范围、已知剩余或未知事项，以及没有下一角色的事实，并给出适用的简短下一步。SHALL 区分普通接受、负责人有限接受、停止和替代；SHALL NOT 把批次关闭等同于父提案全部完成或凭空推断可执行工作。

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

### Requirement: Coherent role routing and review independence

角色 SHALL 以职责及实际需要路由；稳定范围内的问题由有权限的当前负责人继续。
每个真实交接边界 SHALL 选择 continue/dispatch/close 中一个动作；Agent 派发
SHALL 提供完整自包含 Operator Command。M 代码审查及 H 所需验证 SHALL 保持独立。

追加审查和关闭后修复 SHALL 按实际授权范围执行并关联原验收及历史；同一未完成验收 SHALL NOT 通过关闭、改名或新批次清零实际计数、规避明确有限授权或隐藏未完成问题。单次追加审查 SHALL NOT 自动授予后续修复循环；已关闭历史不重开，真实新缺陷仅在适用授权下建立关联修复。

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

### Requirement: Self-contained authorized continuation across sessions

新建或正常更新的可执行 `continue` 交接 SHALL 在 Current Status 中提供自包含的 Continuation Command，包含同一角色/批次、权威输入、下一目标、约束、输出及角色提示。已激活任务中的可执行 Agent SHALL 在核对最新状态后自主接续；本地 CLI/IDE 宿主选择 SHALL NOT 作为负责人决定。会话接替 SHALL 保持同一职责、范围和审查计数，不得用 continue 绕过独立审查或伪装实际角色派发。

#### Scenario: CLI turn ends without an actual blocker
- **WHEN** 单次执行器退出，handoff 为可执行 continue，接入的 Agent 具有所需能力与权限
- **THEN** 读取最新文件后执行下一步，不询问运行在哪个本地宿主；无进程运行不代表环境阻塞，也不承诺协议能够自动唤醒进程

#### Scenario: Wait stale message and exhausted allowance
- **WHEN** handoff 等待真实决定/环境，已关闭，输入冲突或适用的明确有限授权已耗尽
- **THEN** 接续指令不能覆盖真实状态，继续沿适用恢复、等待、关闭和明确有限授权规则处理

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

## ADDED Requirements

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
