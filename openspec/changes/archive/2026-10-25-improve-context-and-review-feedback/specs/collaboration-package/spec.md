# Spec Delta

## ADDED Requirements

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
