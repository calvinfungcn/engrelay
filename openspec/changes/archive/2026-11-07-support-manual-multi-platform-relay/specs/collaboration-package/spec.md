## ADDED Requirements

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

## MODIFIED Requirements

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
