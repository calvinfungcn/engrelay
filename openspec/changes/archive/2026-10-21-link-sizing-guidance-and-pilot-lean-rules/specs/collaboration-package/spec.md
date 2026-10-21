# Spec Delta

## MODIFIED Requirements

### Requirement: Optional task sizing without routing gates

任务规模或投入估算 SHALL 仅在有助于决策且有合理依据时提供，并说明范围、假设及不确定性；无依据时 SHALL 允许省略，不强制填写未知值。L1–L5 SHALL 只描述粗略修改规模，SHALL NOT 推导 S/M/H、C1–C5、审查次数、验收或审批。人工投入 SHALL 与 AI 时长、会话数及 LOC 区分，SHALL NOT 由其自动换算。统计 SHALL 按需限定相关范围，不要求安装工具或常驻状态。可能给出或更新估算的角色入口 SHALL 以锚点短引用唯一共享定义，SHALL NOT 复制区间或扩大必读范围。

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

#### Scenario: A role entry reaches the shared definition
- **WHEN** Chief Designer 仅按其角色入口工作且负责人请求规模或投入参考，或实施角色记录投入是否实质变化
- **THEN** 角色入口的短引用可直接到达唯一共享定义中的区间、省略条件与风险独立规则；入口不复制区间表、不把完整手册列为必读，也不因此要求明确的小任务给出估算
