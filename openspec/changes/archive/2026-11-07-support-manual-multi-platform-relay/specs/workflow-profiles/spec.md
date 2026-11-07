## MODIFIED Requirements

### Requirement: Sequential authorized queues with dependency-aware blocking

Lite 队列 SHALL 只执行负责人已批准且满足前置的任务；完成当前任务的验收及必要审查后才取下一项。阻塞任务 SHALL 保留自身交接和原因，只允许不依赖它且不会冲突的已批准任务继续。完成条目 SHALL 可沿用原格式记录简短结果和证据链接，不强制固定多项总结表。整理指引 SHALL 保留身份、依赖、暂停快照和有效证据引用，不引入自动搬迁或数量门槛。该能力 SHALL 限于活跃 Agent 的顺序工作，SHALL NOT 宣称进程退出后自动唤醒或提供后台调度。

没有可执行后续任务时，Lite 的答复 SHALL 依据自身队列和交接简要说明已知结果、待处理或等待事项及适用的下一步；SHALL NOT 凭空生成任务或将等待中的依赖说成全部完成。用户明确选择人工接力时 SHALL 在当前任务完成且下一项就绪的边界说明转交并结束本轮，不改变队列批准状态或要求重复批准。

#### Scenario: Independent task follows a blocked task
- **WHEN** T01 等待决定，T02 已批准且不依赖 T01
- **THEN** 保存 T01 的任务交接及队列引用后可以执行 T02，不能覆盖 T01 状态

#### Scenario: A dependency has not been accepted
- **WHEN** T03 依赖 T01 的未完成结果
- **THEN** T03 保持待处理或阻塞，不将 T01 的等待当作绕过依赖的理由

#### Scenario: Runner exits with executable continue
- **WHEN** 宿主结束本次运行但交接仍可执行
- **THEN** 说明实际接续入口，新的有权 Agent 核对后继续，不把无进程误报成环境阻塞或后台接力保证

#### Scenario: Completed rows grow or an owner requests organization
- **WHEN** 已完成记录影响阅读，或负责人要求按既有归档权限整理
- **THEN** 示例使用简短结果和稳定证据引用；实际整理须保持仍被依赖的任务可解析，暂停任务及被正式记录引用的证据不随意移动；不因超过20条而自动执行或暂停任务

#### Scenario: No authorized queue item is executable
- **WHEN** 当前任务已结束，队列没有获批准且满足依赖的下一项
- **THEN** 区分已完成、待批准与等待依赖的实际状态，给出当前 Lite 入口的简短下一步；不调用 Full 专属 Skill、自动切配置或捏造下一任务

#### Scenario: An authorized queue item is ready
- **WHEN** 当前任务完成且已有明确获批准、依赖满足并且不冲突的下一项，用户未明确选择人工接力
- **THEN** 活跃 Agent 依原有顺序规则继续，不因新增关闭提示而要求负责人重复批准

#### Scenario: A ready item has an explicit manual relay constraint
- **WHEN** 用户明确要求 Lite 队列人工接力，当前任务已完成且下一项已批准并就绪
- **THEN** 正确保存任务与队列结果，说明由用户启动下一项并结束本轮；不自动启动下一项、不把转交伪装为审批或环境阻塞

#### Scenario: An agent dispatch requires manual relay
- **WHEN** 用户明确选择人工接力且 Lite 当前任务派发执行者或独立评审者
- **THEN** 保存、回读并按既有预期校验交接，在最终回复说明转交和能力建议；不另起 Agent、进程或 API 执行下一角色

#### Scenario: Explicit manual relay and a continuing role
- **WHEN** Lite 当前角色已经由用户启动并有可执行同角色 continue
- **THEN** 核对真实任务、归属、额度与权限后继续该角色的普通工作，不将每个微步骤变成转交

## ADDED Requirements

### Requirement: Manual relay without Lite schema migration

用户选择 Lite 人工接力 SHALL 沿用已有任务或项目限制及 handoff 表达，不新增 lite-1 机器字段、状态或枚举。人类可见提示 SHALL 说明用户需转交；现有 `Human Action Required: none` SHALL NOT 被解读为无需转交。

#### Scenario: A legacy Lite project has no relay preference
- **WHEN** 已安装 Lite 项目配置没有相关偏好或运行中的旧任务没有新提示
- **THEN** 保留原就绪队列行为与既有状态，无需回填配置、修改历史或增加新阻塞

#### Scenario: Tool cannot access the live Lite workspace
- **WHEN** 用户选择不能访问或写入当前项目的工具接续 Lite 任务
- **THEN** 指导用户仅提供经审核的必要资料，并沿用现有响应交接及来源匹配，不能声称实时状态已写回或已验证
