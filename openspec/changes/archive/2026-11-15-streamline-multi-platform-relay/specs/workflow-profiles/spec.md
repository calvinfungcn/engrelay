# Spec Delta

## MODIFIED Requirements

### Requirement: Aggregated responsibilities with independent review

Lite SHALL 使用负责人、执行者、评审者三类职责并按实际影响判定 S/M/H。相邻非独立动作 SHALL 允许同一 Agent 连续处理；M SHALL 独立审查并复核必须修项，H SHALL 满足实际需要的设计和独立验证，实施或修复者 SHALL NOT 自审或自任同批 H 验证。实际 verdict SHALL 单调记录，默认三次总数 SHALL NOT 单独阻断已授权的正常工作；已有明确有限授权 SHALL 保留实际范围、上限及历史。

Lite SHALL 在自身短规则和现有任务／审查产物中表达完整审查、证据对应及隐私、按变化复核、关闭后有限授权和归档核对，保留三类职责与历史。SHALL NOT 要求 Full 手册、新机器字段、产物台账或固定审批；归档或换任务标识不授予额外修复循环，已给授权不重复请示。

#### Scenario: M review requires a fix
- **WHEN** 独立评审提出有证据的必须修问题
- **THEN** 执行者修复后取得对应复核依据，不能自行把未复核发现标为已验证

#### Scenario: H work uses an available reviewer
- **WHEN** H 任务需要修复后的独立验证
- **THEN** 按实际独立性安排验证者，不能因只有三类职责而省略验证或让修复者自验

#### Scenario: Review allowance is exhausted
- **WHEN** 当前动作受负责人明确的有限审查或修复授权约束，且范围或上限已用尽
- **THEN** 保存结果及历史，不因换模型、阶段、文件或配置而规避限制；确需扩大授权时给出具体负责人决定出口

#### Scenario: Owner requests a complete Lite review
- **WHEN** 负责人要求对 Lite 成果作归档前完整独立审查
- **THEN** Reviewer 检查全部授权验收、最终差异、兼容性、对应入口／版本的证据、说明和交付隐私；依 Lite 自身规则执行，不新增 Full 角色或强制全量测试

#### Scenario: Lite repair changes only report content
- **WHEN** 修复仅对报告作必要脱敏或说明修正，相关行为输入及原证据仍匹配
- **THEN** 独立复核受影响报告及交付副本并复用适用行为结果；发现新缺陷、失效证据或共享行为变化时扩大检查，缺失证据保持未验证

#### Scenario: Closed Lite work receives one additional review request
- **WHEN** 负责人对已关闭成果只授权一次追加审查
- **THEN** 关联原任务的关闭及计数，按这次有限范围执行并在既有产物记录结果；不复写旧历史、不由新 Task ID 自动授予后续修复三轮；真实新缺陷的修复须有适用授权

#### Scenario: Lite archive check has no implementation change
- **WHEN** 已授权核对仅涉及规范同步、归档、完成状态和隐私，实施输入未变
- **THEN** 按当前影响定级并复用相符实施证据，通过后结束该核对，不因父任务为 H 重跑所有套件或新增角色／审批

#### Scenario: Normal review reaches three verdicts
- **WHEN** 设计、代码和必要独立验证形成三次 verdict，仍有已授权工作且没有适用明确上限
- **THEN** 按真实问题和依赖继续，不仅因累计数为三而要求追加授权；保留人工接力偏好和独立性

#### Scenario: Repeated repair makes no verified progress
- **WHEN** 针对同一未解决发现连续两次修复和独立复核，均无已核对且能缩小根因或消除既有阻碍的新证据，也无已验证的实质改善
- **THEN** 暂停该问题的重复循环，依据现有任务及审查记录分析原因和下一步；真正需要改变授权、风险或业务取舍时才请求负责人决定

#### Scenario: Unrelated historical review
- **WHEN** 原批次包含两个可区分验收，后续一次审查明确只涉及其中之一
- **THEN** 保留历史编号和原始记录，另一范围只关联实际相关 verdict；关联不明时保持未知，不猜测清零

### Requirement: Lightweight validation and advisory capability

Lite SHALL 有独立的小型只读结构校验，支持对已决定任务、动作、下一职责、审查数及修订的预期比对；失败 SHALL 非零退出且不写回。可执行 continue 和 Agent dispatch SHALL 遵守适用的明确有限授权，SHALL NOT 因同职责接续绕过明确上限或范围。负责人等待、合法关闭及真实非执行 blocked 记录 SHALL 保留；blocked 恢复为可执行路由前 SHALL 重新核对适用授权。动作指令 SHALL 从其真实小节内唯一、完整且已闭合的 text 命令块读取身份与 Read、Objective、Constraints、Output、Follow；围栏外说明或其他样例 SHALL NOT 补齐缺项。来源元数据 SHALL 只取围栏外文本，按围栏字符、长度及结束条件排除响应样例，并保留显式来源、旧状态 SHA256、修订、计数及归属核对。Agent 派发 SHALL 输出一行既有含义的 C1–C5 建议并在回复同步，Lite 执行者／评审者默认 C3，只有已有明确难度信息才覆盖。能力行缺失 SHALL 仅提示，不能成为新阻塞或模型资格门槛。

#### Scenario: Old valid handoff differs from the intended transfer
- **WHEN** 文件结构可读但其任务或路由与调用者提供的本次预期不符
- **THEN** 校验非零并指出差异，不能用旧结构成功声称本次交接完成

#### Scenario: Agent dispatch omits capability advice
- **WHEN** 新派发草稿缺少能力行但其他结构合法
- **THEN** 提供非阻断提醒，由有权写入者在原回读步骤补齐，不新开评审、分析模型或变更配置

#### Scenario: Validation succeeds
- **WHEN** 结构与显式预期匹配
- **THEN** 只报告实际检查结论，不声称业务验收、实际独立性、来源认证或宿主遵从已经被脚本证明

#### Scenario: Unextended executable continuation reaches the default limit
- **WHEN** 有效任务的可执行 continue 或 Agent dispatch 累计已达三次或更多 verdict，没有适用的明确有限上限且其他结构合法
- **THEN** 校验不因旧默认三次门槛拒绝；不修改 handoff、不清零计数，也不把进程退出当作新增授权

#### Scenario: Executable routes retain unused finite authorization
- **WHEN** 可执行 continue 或 Agent dispatch 受适用有限授权约束，且批次、证据及既有字段有效、from 小于等于当前计数、当前计数小于 through
- **THEN** 有限授权检查不阻断该路由，其他结构、预期与来源检查仍必须成立

#### Scenario: Expired or mismatched extension cannot authorize execution
- **WHEN** 当前动作引用的适用有限授权已到 through、未到 from、任务不符、字段重复／无效或缺少既有要求的证据
- **THEN** 校验非零退出，不将其用于允许接续或派发；不能把用于当前动作的无效有限授权当成不存在

#### Scenario: Non-executable records do not require unused execution capacity
- **WHEN** handoff 是格式有效的负责人等待、合法 close，或带真实恢复条件且没有执行命令的 blocked 记录，即使明确有限授权已用尽
- **THEN** 不仅因缺少可执行额度而拒绝该记录；blocked 恢复后的 continue／dispatch 仍须重新检查适用授权，不能据此开始未经授权的修复循环

#### Scenario: Complete existing command remains valid
- **WHEN** 动作对应的真实小节含唯一完整 text 代码块，使用既有三反引号或合法的较长反引号／波浪线围栏，任务、职责及五项必需内容均在同一命令块内
- **THEN** 指令检查通过，不要求新字段、批量迁移或新的人工批准

#### Scenario: Narrative cannot complete an incomplete command
- **WHEN** 实际命令块缺少身份或任一必需内容，而围栏外叙述、其他小节或其他示例含有所缺文字
- **THEN** 校验非零退出并定位指令缺项；多个实际 text 命令块也不能互相拼成一个可执行命令

#### Scenario: Longer legal task identifiers cannot supply command identity
- **WHEN** 当前任务为 T01，但真实命令中的任务身份仅为 T01.-other、T01._other、T01..other 等较长合法标识
- **THEN** 校验非零退出，不能把其前缀作为当前任务身份；完整正确 ID 和既有句末 T01. 标点仍有效，不收紧 Routing 已允许的 ID 字符

#### Scenario: A higher heading ends the action section
- **WHEN** Operator Command 小节没有命令，其后的真实 H1 下才出现完整 text 命令块
- **THEN** 校验非零退出，不能从新 H1 借用命令；围栏内伪标题不截断真实动作小节，正常同小节命令保持有效

#### Scenario: Existing text fence case variants retain compatibility
- **WHEN** 唯一完整命令块的信息字符串使用既有 TEXT 或 Text 大小写变体
- **THEN** 按序数不区分大小写识别为 text，并继续检查实际范围、闭合、身份和五项内容；text 与其大小写变体形成多个实际命令块时仍报告歧义

#### Scenario: Fenced continuation heading does not select the live command
- **WHEN** Current Status 中先有围栏包裹的 Continuation Command 示例，后有真正的同名小节
- **THEN** 仅校验真实小节中的命令；没有真实小节或真实命令不完整时不能由样例补齐

#### Scenario: Source metadata exists only inside a fence
- **WHEN** 显式来源文件的必需元数据全部或部分仅存在于反引号或波浪线围栏中
- **THEN** 校验非零退出并报告缺少真实来源字段，不输出来源已匹配

#### Scenario: Complete fenced response does not duplicate source metadata
- **WHEN** 来源包含有效的围栏外元数据，并以波浪线或较长反引号围栏包裹带有自身 Routing 及内部较短命令围栏的完整响应 handoff
- **THEN** 只读取外部元数据，不将响应内容认作重复来源字段；已有身份、SHA256、修订、计数、风险和归属检查继续生效

#### Scenario: Genuine duplicate source metadata remains invalid
- **WHEN** 显式来源的围栏外重复定义同一必需元数据字段
- **THEN** 校验非零退出并报告重复字段，不根据位置或修订猜测权威

#### Scenario: Fence closing rules prevent false boundaries
- **WHEN** 输入围栏中出现不同字符、短于开启长度或尾随非空内容的伪结束行，或者真正围栏未闭合
- **THEN** 不因伪结束行读取其中样例作为真实命令或元数据；未闭合围栏非零退出，输入文件保持不变

#### Scenario: Semantic convergence is not a structural proof
- **WHEN** 结构与预期校验成功，但实际授权真实性、独立性、证据或同一发现是否持续无进展未知
- **THEN** 仅报告结构结论，由负责角色按现有任务和审查记录判断；不声称脚本证明真实授权或已完成验收
