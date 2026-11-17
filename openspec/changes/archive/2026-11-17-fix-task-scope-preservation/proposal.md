# Proposal

## Why

Full 已区分角色结束、同批实施和独立设计关闭，但下游仍可能把上游 Agent 对范围的解释当作用户决定；整体目标因而在设计前被缩窄，或者被反向扩大为未给出的实施授权。需要让任务来源、当前职责和实际授权在已有区块内简短可核对，支持下一平台作出有依据的接力判断。

## What Changes

- 在已有 Source、Goal、Scope 或 Constraints 中保留影响当前范围与出口的最小用户请求／决定依据，区分已确认内容与 Agent 推断；不复制完整对话、不增加机器字段或台账。
- 明确整体目标、本轮职责、已授权工作及授权不确定性的区别；先设计不自动否定既有实施授权，有实施意图或未禁止也不自动授予全部实施权限。
- 设计及评审出口核对来源和映射；有冲突时交 Chief Designer 作最小核对，合法独立设计交付仍可关闭，后续明确授权可直接复用既有设计和 Task Intake。
- 协调相关入口、角色短引用、模板和双语说明，用虚构场景验证；保持人工接力停止边界、兼容性与实际审查历史。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：增加来源可核对的任务范围要求，补充 Coherent role routing and review independence；保留已有关闭后接续及最小授权契约。

## Impact

- Full README 的共享规则、workflows、agent-prompts、handoff-schema、两个入口 canonical Skills、current-task/handoff 模板及必要的 agent-rules 短引用。
- 两份 operator-guide、根 README 和 CHANGELOG 成对更新；公开材料使用虚构信息，修复记录进入 Unreleased。
- 不改变机器字段、角色锚点、安装集合、Lite、manager、validator 或运行时逻辑，不新增依赖或统一审批。
- 一个 M 级批次覆盖规范实施、说明、受影响检查和独立审查。本轮仅建立正式设计并保存交接；归档、版本／snapshot、提交、发布和真实项目安装另按适用请求处理。
