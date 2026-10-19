# Spec Delta

## MODIFIED Requirements

### Requirement: Explicit activation and one workflow

工具包 SHALL 保留 optional/default/disabled 及当前任务明确选择优先的语义。
明确选择 EngRelay SHALL 等同于选择兼容名称 ai-collaboration；资料或 Skill
被发现本身 SHALL NOT 激活流程，同一任务 SHALL 只有一个主编排流程。现行管理入口 SHALL 明确这些规则适用于当前选用的工作流，SHALL NOT 将运行态维护表述为仅适用于已退役的历史执行；更正文案 SHALL 保留管理标记和项目块外内容的归属保护。

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
- **WHEN** 当前批次已关闭、真正等待负责人或环境，累计额度已耗尽而无适用有限授权，或恢复者不满足角色独立性
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
