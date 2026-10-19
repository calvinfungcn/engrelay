# Spec Delta

## ADDED Requirements

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

获准写入的负责角色 SHALL 在真实派发、等待、计划会话中断和关闭边界持久化 handoff，回读核对本次意图对应的批次、路由、累计审查计数及已有修订号，再执行适用校验。最终回复 SHALL 简短说明实际持久化结果或未完成原因。SHALL NOT 仅依据写入调用成功或旧文件结构通过声称本次交接已完成；普通连续微步骤不新增写回和重复检查要求。

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

### Requirement: Durable source-linked fallback handoff

正式转移因权限限制使用替代交接时，负责角色 SHALL 给出完整 Routing、适用命令及状态影响，并说明其未写回。允许写审查产物时 SHALL 复用同轮记录保存完整替代交接，索引只链接；禁止文件写入时 SHALL 在回复保留同等信息。新替代交接 SHALL 说明批次及对应旧交接的修订号（若有）与字节指纹。只读子代理返回后，仍活跃且获准维护 handoff 的主/负责 Agent SHALL 在本次交接结束前核对、落盘、回读及校验，不推给用户或下一轮，不新增 verdict、冒充来源角色或绕过真实禁令。

#### Scenario: Reviewer can write only the review report and index
- **WHEN** 审查已完成但禁止更新 `.ai/handoff.md`
- **THEN** 同轮报告保存完整下一动作、真实累计计数及来源交接匹配依据，索引指向该报告；受限审查者说明其未写回，有活跃可写负责者时由其当轮发布，否则保留可供后续取得的完整交接

#### Scenario: Active writable owner publishes a read-only subagent result
- **WHEN** 宿主实际只读的子代理返回完整有效审查交接，当前主 Agent 仍活跃且获准维护同批次 handoff
- **THEN** 主 Agent 核对来源和执行归属后在本次对外交接结束前保存、回读及校验该决议；子代理保持只读，审查只计一次，回复按最终实际落盘情况说明，不要求用户手写文件

#### Scenario: No permitted publisher remains active
- **WHEN** 没有活跃可写负责者，或用户/上位禁令对负责者同样有效
- **THEN** 保持完整响应交接和真实未持久化说明，不声称文件已更新、不绕过权限，也不要求为此建设新进程或后台恢复服务

#### Scenario: All file writes are prohibited
- **WHEN** 严格只读限制连审查记录也不能创建
- **THEN** 不新建临时状态文件，在回复交付完整替代交接；后续会话无法取得该交接时指出缺失来源，不自行补造 verdict 或路由

#### Scenario: An ordinary accepted close is only a response
- **WHEN** 替代交接包含普通 accepted 关闭结论
- **THEN** 仍遵守最终输入匹配的关闭证据和角色权限规则，旧 handoff 的 exit 0 不能证明新回复已验证；恢复不得补造缺失验收或批准

### Requirement: Source-matched recovery before stale routing execution

已激活任务的接续 SHALL 在执行旧派发前核对明确关联的同批次审查索引及替代交接。确认来源对应当前旧状态、授权有效且无并发写入冲突时，获准写入的 Agent SHALL 先恢复交接，再按实际职责和独立性执行下一步。恢复 SHALL 保留来源角色归属、已完成 verdict 和范围，SHALL NOT 自增审查计数、重放旧审查、依据时间或最大文件号覆盖更晚状态，也不新增恢复审批。

#### Scenario: Completed review supersedes a pre-review dispatch
- **WHEN** live 文件仍派发审查、同批次明确关联的完成记录提供有效的修复派发，且来源匹配及写权限成立
- **THEN** 先恢复该交接中的累计计数和下一角色，再按角色资格执行；持久化本身不产生新 verdict，也不把恢复者伪装成原审查者

#### Scenario: A transfer was already applied or routing advanced
- **WHEN** 当前状态已应用该交接或已在其后前进
- **THEN** 继续按当前有效状态处理，不再次覆盖文件、计数或执行历史 Operator Command

#### Scenario: Source conflicts or refers to another batch
- **WHEN** 来源批次不同、来源匹配依据矛盾、多个候选互相冲突或写入前发现文件已变更
- **THEN** 保留有效状态，指出具体冲突和最小恢复方向；不全盘扫描历史、不选最大编号、不猜测授权或静默覆盖

#### Scenario: Current limits prohibit the proposed next action
- **WHEN** 当前批次已关闭、真正等待负责人或环境，累计额度已耗尽而无适用有限授权，或恢复者不满足角色独立性
- **THEN** 既有关闭、等待、预算及独立性规则优先，替代交接不能重开批次、忽略等待、增加循环或授权自审

#### Scenario: Older records do not contain the new matching narration
- **WHEN** 接续旧记录或已归档交接，缺少新指纹说明
- **THEN** 不要求历史回填；仅在既有明确证据足以无歧义确定同批次来源和出口时按原权限恢复，不足时指出缺失依据而不把旧文件当成已更新

### Requirement: Optional expected handoff state validation

只读运行态校验器 SHALL 接受可选的预期批次及已有路由、审查计数和修订值，逐项比对所给预期；预期须来自已决定的转移或明确替代交接，SHALL NOT 从旧文件反推。已给预期非法、缺少所需批次，或实际字段缺失、重复、不符时 SHALL 返回非零并指出差异。采用新版契约的负责角色 SHALL 在接口可用的真实边界传入本次已决定状态；参数可选只保留旧调用兼容。无预期调用 SHALL 保留原结构语义，不自动推导路由、写文件或证明全局最新与业务验收。

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
- **WHEN** 预期值匹配，但交接违反原预算、角色、等待或关闭结构规则
- **THEN** 仍返回非零，预期检查不能豁免原有约束

#### Scenario: Legacy invocation omits expectations
- **WHEN** 原调用不传任何预期参数，旧交接没有可选修订号或新说明
- **THEN** 保持原结构检查与兼容告警，不强制迁移、自动恢复、发布或添加运行态字段；此兼容不豁免新版负责角色的边界预期比对义务
