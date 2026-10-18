# Spec Delta

## ADDED Requirements

### Requirement: Concise advisory capability on agent dispatch

新建或正常更新的 Agent `dispatch` 交接 SHALL 在 `Current Status` 下用独立一行 `Recommended capability tier: C1` 至 `C5` 表达下一项派发工作的建议能力，并在用户回复中简短同步同一档位。文件式和回复式交接 SHALL 使用同一规则；SHALL NOT 为此复制档位说明、增加逐次理由或模型比较。人工决定、`continue`、`close` SHALL 省略能力行。

#### Scenario: Dispatch an ordinary implementation
- **WHEN** 下一角色为实现工程师，任务没有已明确的轻量或特殊复杂信息
- **THEN** 文件交接在 Current Status 下显示且只显示一行 `Recommended capability tier: C3`，用户回复也简短显示 C3，完整 Operator Command 保留

#### Scenario: Response-only agent handoff
- **WHEN** 实际 Agent 派发因只读限制使用回复式交接
- **THEN** 回复交接的 Current Status 使用同样一行及同一默认映射，仍说明文件交接未更新，并提供完整 Operator Command

#### Scenario: Human decision or no agent dispatch
- **WHEN** 下一动作是人工决定派发、等待负责人决定的 continue、普通 continue、blocked continue 或 close
- **THEN** 不输出能力行，原 Owner Decision Brief、Resume condition、关闭及 next 字段规则继续适用

### Requirement: Reusable capability definitions and defaults

产品 SHALL 集中维护一份英文规范定义及固定角色默认表：C1 基础执行、C2 常规实现、C3 综合工程、C4 深度分析、C5 高难度推理。派发 SHALL 直接查表，仅复用已确认任务中明确的轻量或复杂信息调整；SHALL NOT 增加专门调查、模型评估或交接理由。C5 SHALL 无默认角色，且 SHALL NOT 因一次失败自动升档。双语人类说明 SHALL 提供简短、语义一致的查阅入口。

#### Scenario: Use defaults without new analysis
- **WHEN** 派发目标是现有标准角色或 Task Intake，已有任务没有明确难度例外
- **THEN** 直接使用固定表，所有目标均有默认值；文档整理默认 C1，常规实现默认 C3，首席设计默认 C4，任何角色均不默认 C5

#### Scenario: Already identified lightweight work
- **WHEN** 已授权任务明确是按已给步骤执行的机械工作，或已明确是边界清楚的常规局部任务
- **THEN** 分别用 C1 或 C2 作为此次下一项工作的建议，不因角色默认较高而一律要求高档，不再调查或新增难度判断报告

#### Scenario: Known complexity and exceptional C5
- **WHEN** 已有任务明确需要深度跨模块分析，或已明确要求高难度推理
- **THEN** 分别可采用 C4 或 C5；采用 C5 必须有后者的现成任务依据，无现成信息时继续默认值

#### Scenario: A failed attempt or a risk label
- **WHEN** 发生单次失败，或任务仅标记为 S、M、H 而没有已明确的难度例外
- **THEN** 不据此自动改变能力档位；风险分类和原有修复、审查路径继续适用

### Requirement: Capability guidance preserves authority and legacy compatibility

能力行 SHALL 只作人工选择模型与推理强度的参考，SHALL NOT 成为资格证明、批准步骤、必填机器字段或新阻塞条件；SHALL NOT 替代角色权限、S/M/H、实际验证、独立审查和累计 verdict 规则。旧交接缺少该行 SHALL 继续有效，接续 SHALL NOT 要求先补齐或重写历史。显示建议 SHALL NOT 自动选择模型、修改配置或启动编排。

#### Scenario: Read an older valid handoff
- **WHEN** 接续既有有效交接且缺少能力行
- **THEN** 按原 Next action 和授权继续，不因缺少该行报错、要求迁移或回填归档

#### Scenario: Operator chooses an available agent
- **WHEN** 用户选择可用模型和推理强度，产品没有能力测评或档位认证依据
- **THEN** 建议不新增资格检查或等待高档模型的阻塞；现有工具、环境和授权前提照常适用，实际完成仍需证据

#### Scenario: Preserve existing invalid-route detection
- **WHEN** 交接含有或缺少能力建议，但原 Routing、Operator Command 或累计审查条件本身无效
- **THEN** 原校验或路由规则仍指出原问题，能力行不能覆盖、修复或放行无效状态

#### Scenario: Independent review remains required
- **WHEN** 一个 M 级批次被建议使用 C1、C2 或 C5 Agent
- **THEN** 仍须独立代码审查，档位不改变风险、审查计数或关闭条件，也不证明审查者实际独立或胜任
