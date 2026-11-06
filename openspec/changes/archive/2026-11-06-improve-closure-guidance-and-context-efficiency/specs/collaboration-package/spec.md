## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Actionable closed-batch guidance

Full 接续遇到已关闭批次时 SHALL 依据最新适用权威说明关闭结果、映射范围、已知剩余或未知事项，以及没有下一角色的事实，并给出适用的简短下一步。SHALL 区分普通接受、负责人有限接受、停止和替代；SHALL NOT 把批次关闭等同于父提案全部完成或凭空推断可执行工作。

#### Scenario: Finished batch without a new request
- **WHEN** 最新批次已 accepted，已核对的父范围无待办，用户仅要求继续
- **THEN** 说明已完成及无下一角色，并提供开始新任务的适用入口；不重放旧派发或声称已启动新任务

#### Scenario: Closed batch with unfinished parent work
- **WHEN** 当前批次已关闭、父提案仍有明确可核对的未完成事项，用户未指定要做哪项
- **THEN** 区分本批次结果与父提案剩余范围，提供最小可执行的后续请求示例；不把建议或待决定事项当作已获执行授权

#### Scenario: Limited acceptance or stopped outcome
- **WHEN** 关闭记录是负责人有限接受、stopped 或 superseded
- **THEN** 如实说明具体结果、未满足范围及适用的负责人决定或下一步，不称为技术验证全部通过

#### Scenario: Evidence is missing or conflicting
- **WHEN** 关闭结论、剩余范围或有效交接所需权威缺失或冲突
- **THEN** 指出具体文件和无法确认的内容，给出最小恢复方向；不猜测结果、下一角色或审查计数

### Requirement: Authorized work after a closed batch

明确选择 Full 的当前请求若在关闭批次后提出可区分且已获授权的后续工作，负责 Agent SHALL 按现有 Task Intake 或适用的有限审查路径在同一会话处理，不要求重复发送等效指令。SHALL 保留原关闭、适用累计计数、授权边界和独立性；SHALL NOT 将含糊请求、旧消息或建议当作新授权。

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
