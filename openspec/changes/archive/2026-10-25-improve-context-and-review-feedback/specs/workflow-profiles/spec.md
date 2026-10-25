# Spec Delta

## MODIFIED Requirements

### Requirement: Small explicit reading path and task authority

Lite SHALL 以短规则、项目配置和当前任务输入为日常入口，接手时增加当前 handoff 与明确关联的证据，SHALL NOT 强制读取完整 Full 手册或全量历史。Agent SHALL 按需读取目标源码及适用模块指令。同会话已知未变参考 SHALL 可复用；新 Agent、上下文缺失、输入变化或疑问 SHALL 刷新适用权威，不绕过已触发 Skill 和项目必读要求，也不建立缓存台账。已有适用 OpenSpec 时 SHALL 使用其范围与验收；其他 Lite 任务 SHALL 使用负责人确认的队列条目或任务记录，不建立互相竞争的实施清单。

#### Scenario: Clear S task has no formal proposal
- **WHEN** 已批准的低风险任务有清晰范围和验收，且没有适用的正式变更
- **THEN** 从当前条目执行并自查，不强制创建 OpenSpec、估算或独立会话

#### Scenario: Existing OpenSpec governs the task
- **WHEN** Lite 条目关联已有正式变更
- **THEN** 条目仅引用相应 tasks.md 和验收，不另建冲突范围或冒充完成的副本

#### Scenario: Same-session reference remains applicable
- **WHEN** 活跃 Lite Agent 继续稳定范围内工作，参考已读且已知未变
- **THEN** 复用参考并读取必要新输入，不重复加载全量历史；真实边界仍刷新当前状态并保存核对交接

#### Scenario: Replacement context is incomplete
- **WHEN** 新会话接手或不能确定已有参考仍适用
- **THEN** 读取当前任务、最新交接及相关规则／证据，不用一句摘要取代缺失权威，也不按文件数量降低风险

### Requirement: Sequential authorized queues with dependency-aware blocking

Lite 队列 SHALL 只执行负责人已批准且满足前置的任务；完成当前任务的验收及必要审查后才取下一项。阻塞任务 SHALL 保留自身交接和原因，只允许不依赖它且不会冲突的已批准任务继续。完成条目 SHALL 可沿用原格式记录简短结果和证据链接，不强制固定多项总结表。整理指引 SHALL 保留身份、依赖、暂停快照和有效证据引用，不引入自动搬迁或数量门槛。该能力 SHALL 限于活跃 Agent 的顺序工作，SHALL NOT 宣称进程退出后自动唤醒或提供后台调度。

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

## ADDED Requirements

### Requirement: Optional Lite project preferences

Lite 项目配置模板 SHALL 可表达执行／评审的工具、模型及推理偏好、已有评审启动方式、项目限制和隔离示例；这些内容 SHALL 可选且不授予权限、认证能力、豁免独立性或自动选择／启动模型。缺少新增偏好的旧配置 SHALL 继续可用，配置空缺不得成为新增阻塞。项目自有实例 SHALL 沿用现有升级／卸载保留语义，不自动回填或覆盖。

#### Scenario: An existing configuration lacks preference entries
- **WHEN** 已安装 Lite 项目仍使用原配置，尚未填写新增偏好
- **THEN** 正常任务继续按现有授权与可用能力执行；不要求迁移、补齐空值或重复批准，不覆盖配置实例

#### Scenario: A preferred reviewer is unavailable or not independent
- **WHEN** 偏好指定的工具不可用，或实际候选不满足本次独立性
- **THEN** 按已有权限和角色约束选择可行路径或报告真实限制，偏好本身不启动工具、授予费用／权限，也不允许实施者自审或提高未获授权的成本
