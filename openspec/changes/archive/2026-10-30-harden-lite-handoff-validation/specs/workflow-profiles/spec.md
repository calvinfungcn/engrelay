# Spec Delta

## MODIFIED Requirements

### Requirement: Lightweight validation and advisory capability

Lite SHALL 有独立的小型只读结构校验，支持对已决定任务、动作、下一职责、审查数及修订的预期比对；失败 SHALL 非零退出且不写回。可执行 continue 和 Agent dispatch SHALL 遵守累计额度及适用有限扩展，SHALL NOT 因同职责接续绕过额度。负责人等待、合法关闭及真实非执行 blocked 记录 SHALL 保留；blocked 恢复为可执行路由前 SHALL 重新核对额度。动作指令 SHALL 从其真实小节内唯一、完整且已闭合的 text 命令块读取身份与 Read、Objective、Constraints、Output、Follow；围栏外说明或其他样例 SHALL NOT 补齐缺项。来源元数据 SHALL 只取围栏外文本，按围栏字符、长度及结束条件排除响应样例，并保留显式来源、旧状态 SHA256、修订、计数及归属核对。Agent 派发 SHALL 输出一行既有含义的 C1–C5 建议并在回复同步，Lite 执行者／评审者默认 C3，只有已有明确难度信息才覆盖。能力行缺失 SHALL 仅提示，不能成为新阻塞或模型资格门槛。

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
- **WHEN** 有效任务的可执行 continue 或 Agent dispatch 累计已达三次或更多 verdict，且没有适用有限扩展
- **THEN** 校验非零退出，说明执行额度耗尽和负责人决定出口；不修改 handoff、不清零计数，也不把进程退出当作新增授权

#### Scenario: Executable routes retain unused finite authorization
- **WHEN** 可执行 continue 或 Agent dispatch 的计数尚低于三，或存在批次、证据及其他既有字段有效且 from 小于等于当前计数、当前计数小于 through 的有限扩展
- **THEN** 额度检查不阻断该路由，其他结构、预期与来源检查仍必须成立

#### Scenario: Expired or mismatched extension cannot authorize execution
- **WHEN** 超额执行所引用扩展已到 through、未到 from、任务不符、字段重复／无效或缺少既有要求的证据
- **THEN** 校验非零退出，不将其用于允许接续或派发

#### Scenario: Non-executable records do not require unused execution capacity
- **WHEN** handoff 是格式有效的负责人等待、合法 close，或带真实恢复条件且没有执行命令的 blocked 记录，即使默认额度已用尽
- **THEN** 不仅因缺少可执行额度而拒绝该记录；blocked 恢复后的 continue／dispatch 仍须重新检查额度，不能据此开始未经授权的修复循环

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
