# Spec Delta

## ADDED Requirements

### Requirement: Non-blocking forward environment notices

环境准备 SHALL 区分下一步必需的即时前置与后续检查才需要的远期预告。`Needed before next action: no` SHALL 使用中性说明，明确当前无需人类操作或回复，SHALL NOT 包含命令式行动或当前确认请求。接近依赖步骤时 SHALL 重新核对，真实即时前置未就绪 SHALL 保留 blocked 与 Resume condition，不得伪报验收。

#### Scenario: Offline session before later environment check
- **WHEN** 当前继续离线实现，环境只供之后的验证使用
- **THEN** handoff 保留预告和后续检查点，当前无人工要求；Agent 继续已授权离线工作，不等待预告中的准备

#### Scenario: Immediate prerequisite pending
- **WHEN** 任一下一步必需的环境项仍 pending 或 unknown
- **THEN** 保持 continue/blocked 与 Resume condition，不派发 Agent、不提前关闭；需要人类时才给出具体操作和最小回复

### Requirement: Self-contained authorized continuation across sessions

新建或正常更新的可执行 `continue` 交接 SHALL 在 Current Status 中提供自包含的 Continuation Command，包含同一角色/批次、权威输入、下一目标、约束、输出及角色提示。已激活任务中的可执行 Agent SHALL 在核对最新状态后自主接续；本地 CLI/IDE 宿主选择 SHALL NOT 作为负责人决定。会话接替 SHALL 保持同一职责、范围和审查计数，不得用 continue 绕过独立审查或伪装实际角色派发。

#### Scenario: CLI turn ends without an actual blocker
- **WHEN** 单次执行器退出，handoff 为可执行 continue，接入的 Agent 具有所需能力与权限
- **THEN** 读取最新文件后执行下一步，不询问运行在哪个本地宿主；无进程运行不代表环境阻塞，也不承诺协议能够自动唤醒进程

#### Scenario: Wait stale message and exhausted allowance
- **WHEN** handoff 等待决定/环境，已关闭，输入冲突或累计审查额度耗尽
- **THEN** 接续指令不能覆盖真实状态，继续沿既有恢复、等待、关闭和有限授权规则处理

### Requirement: Compatible human intervention summary

新建或正常更新的 handoff SHALL 在 Routing 显示唯一 `Human Action Required: none|awaiting-decision|awaiting-environment`，与当前决定或环境等待一致。该字段 SHALL 仅摘要现有状态，不授权、不建立新动作/状态。旧交接缺少字段或接续命令 SHALL 继续可读有效，无需历史回填；读取旧记录 SHALL 由实际状态和前置确定是否等待，不得仅因缺字段停下。

#### Scenario: Forward notice does not request intervention
- **WHEN** 只有远期未就绪环境预告，当前可以安全执行
- **THEN** 字段为 none，当前离线步骤可接续；有 ready 环境证据也不得误报 awaiting-environment

#### Scenario: Human waiting consistency
- **WHEN** 当前等待负责人决定或确需人类解决的即时环境前置
- **THEN** 分别显示 awaiting-decision 或 awaiting-environment，保留 Owner Decision Brief 或 blocked/Resume condition；等待和关闭交接不附可直接执行的 Continuation Command

#### Scenario: Legacy compatibility and structural boundary
- **WHEN** 校验旧交接，或校验带有新字段/接续块的交接
- **THEN** 旧结构仍通过原有规则；新字段非法、重复或与已声明状态矛盾时失败，代码围栏内的示例不充当真实字段或命令；结构成功不证明宿主遵从、环境真实就绪或业务验收
