# Spec Delta

## ADDED Requirements

### Requirement: Optional task sizing without routing gates

任务规模或投入估算 SHALL 仅在有助于决策且有合理依据时提供，并说明范围、假设及不确定性；无依据时 SHALL 允许省略，不强制填写未知值。L1–L5 SHALL 只描述粗略修改规模，SHALL NOT 推导 S/M/H、C1–C5、审查次数、验收或审批。人工投入 SHALL 与 AI 时长、会话数及 LOC 区分，SHALL NOT 由其自动换算。统计 SHALL 按需限定相关范围，不要求安装工具或常驻状态。

#### Scenario: Clear small task has no estimate
- **WHEN** 明确的小任务没有可靠规模或人工投入估算，且原授权与执行前提已满足
- **THEN** 省略估算并按已有风险路径执行，不新增角色、工具扫描、未知值表单或负责人确认

#### Scenario: Useful rough source sizing
- **WHEN** 已有信息足以提供有用的产品源码规模粗估
- **THEN** 可按人工维护产品源码的 Added + Deleted 使用 L1 为 0–99、L2 为 100–499、L3 为 500–1999、L4 为 2000–9999、L5 为至少 10000 行的参考区间，附假设及置信度，不提供伪精确行数；测试、文档、生成与机械变更另行说明，不因从规模口径排除而忽略审查

#### Scenario: Documentation or mechanical change
- **WHEN** 任务主要修改文档、配置、二进制资源或机械搬移，产品源码行数不能代表规模
- **THEN** 使用相关文件或行为范围描述，允许不使用 L 级，不把缺少产品源码变化说成无需审查，也不因行数多而自动提高风险

#### Scenario: Human effort is requested
- **WHEN** 用户需要人工投入参考且有可比依据
- **THEN** 可提供含假设和不确定性的人工有效投入区间；依据不足时明确不确定或省略，不将 AI 运行小时、Expected implementation sessions、代码量或工具成本模型换算成人天

#### Scenario: Relevant change baseline is unavailable
- **WHEN** 没有可信批次起点、可区分的相关改动或可用统计工具
- **THEN** 不把全仓体量、单一未暂存 diff 或混入无关工作的数字当作本批实际规模，省略不可靠值并继续原流程，不为获取数字扫描历史、安装程序或写新缓存

#### Scenario: An estimate changes materially
- **WHEN** 实际范围或规模与已有粗估明显不同
- **THEN** 当前角色简短说明证据和原因，先核对获授权范围及最小方案；数字偏差本身不停止工作，实际复杂度例外、范围或重大成本变化仍走已有负责人及设计处理路径

### Requirement: Evidence-based progress within existing handoffs

真实交接的进展说明 SHALL 复用既有区块，简短表达可观察成果、证据与剩余工作，并区分实现/自测、独立审查和正式接受。验收项数量 SHALL 仅在已有清晰口径时作为可选覆盖说明，SHALL NOT 冒充工时完成度或主观总进度。进展复核 SHALL 基于实际证据与未知项收敛，SHALL NOT 以固定交接次数或指标自动阻塞、增加检查点、重写稳定任务输入或绕过恢复规则。

#### Scenario: A real boundary reports changed work
- **WHEN** 发生原协议要求保存的派发、等待、计划会话结束或关闭，且已有实质进展
- **THEN** 在既有 Current Status、证据、风险及状态影响区块记录必要变化，链接已有证据，保留具体剩余工作，不为汇报另建交接或复制日志

#### Scenario: Acceptance count has a stable meaning
- **WHEN** 现有验收项可明确映射且部分已经取得证据
- **THEN** 可说明已核验项数和总数及其证据，不通过拆分条目提高比例，不用 OpenSpec 子任务数代替验收项数，也不从数量比例推断总工时进度或 accepted

#### Scenario: Research or review adds useful evidence
- **WHEN** 连续工作尚未新增通过的验收项，但已排除错误方向、收敛关键未知或产生审查证据
- **THEN** 如实说明有效进展及下一步，不因两次交接没有新增通过项而判断停滞，不把尚未独立审查的实现称为已正式接受

#### Scenario: Material work has no explainable progress
- **WHEN** 有明显投入，却持续缺少新增证据、未知项收敛或可解释的必要前置工作
- **THEN** 当前角色作一次简短复核并提出最小纠偏行动，只有实质范围、优先级或成本决定才使用既有负责人出口；不新建计数器、告警表或审批，不重复通报相同情况

#### Scenario: Progress and capability share current status
- **WHEN** 新 Agent 派发同时报告成果或可选估算
- **THEN** 能力建议仍是 Current Status 的第一行，成果说明紧随其后；不把新摘要插在能力行之前，也不改变完整 Operator Command

#### Scenario: Progress updates preserve recovery ownership
- **WHEN** 交接进展发生变化、旧记录缺少指标，或接续存在已关联的恢复来源
- **THEN** 继续按现有真实边界、修订、写入归属、回读及来源匹配规则处理完整 Current Status；不为指标旁路写入、以时间戳覆盖、反复回写 current-task 或要求历史补录

## MODIFIED Requirements

### Requirement: Concise advisory capability on agent dispatch

新建或正常更新的 Agent `dispatch` 交接 SHALL 在 `Current Status` 的首行用独立一行 `Recommended capability tier: C1` 至 `C5` 表达下一项派发工作的建议能力，并在最终用户回复中简短同步同一档位。文件式和回复式交接 SHALL 使用同一规则；SHALL NOT 为此复制档位说明、增加逐次理由或模型比较。现有交接出口 SHALL 提醒负责 Agent 在原有回读时核对该行及回复一致性；公开说明 SHALL 区分必须输出建议与建议不构成资格门槛。人工决定、`continue`、`close` SHALL 省略能力行。

#### Scenario: Dispatch an ordinary implementation
- **WHEN** 下一角色为实现工程师，任务没有已明确的轻量或特殊复杂信息
- **THEN** 文件交接在 Current Status 首行显示且只显示一行 `Recommended capability tier: C3`，用户最终回复也简短显示 C3，完整 Operator Command 保留

#### Scenario: Response-only agent handoff
- **WHEN** 实际 Agent 派发因只读限制使用回复式交接
- **THEN** 回复交接的 Current Status 首行使用同样一行及同一默认映射，仍说明文件交接未更新，并提供完整 Operator Command

#### Scenario: Human decision or no agent dispatch
- **WHEN** 下一动作是人工决定派发、等待负责人决定的 continue、普通 continue、blocked continue 或 close
- **THEN** 不输出能力行，原 Owner Decision Brief、Resume condition、关闭及 next 字段规则继续适用

#### Scenario: An entry completes a new agent transfer
- **WHEN** 通过 start、requirements、continue 或现有角色出口生成新的 Agent 派发
- **THEN** 出口提醒负责 Agent 按既有默认/明确覆盖规则填入能力首行，在同一次交接回读中确认并在最终回复复述；发现本次草稿漏写时由有权写入者补齐，不要求用户选择模型、增加评分或另开审查

#### Scenario: A human reads the capability guidance
- **WHEN** 人类从任一语言的根 README 或操作指南理解能力提示
- **THEN** 说明明确新 Agent 派发须输出这一建议，而档位仅供选择参考、不批准模型或阻塞工作；旧缺行交接仍按原兼容规则继续，不将结构校验通过称为能力行已核对
