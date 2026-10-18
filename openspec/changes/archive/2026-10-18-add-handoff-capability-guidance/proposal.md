# Proposal

## Why

现有交接说明下一角色，却没有简短的能力参考，用户难以据此选择 AI 模型和推理强度。此前已确认的 C1–C5 需求曾从安装发现变更中拆出，本变更将它交付为独立可验收功能。

## What Changes

- 在 Agent `dispatch` 的 `Current Status` 下显示一行 `Recommended capability tier: C3` 形式的建议，并在用户回复中简短同步同一档位。
- 集中定义 C1 基础执行、C2 常规实现、C3 综合工程、C4 深度分析、C5 高难度推理；用固定角色默认表复用已有任务信息，明确轻量与已知复杂任务的简短例外，不新增逐次能力评估。
- 同步文件式与回复式交接模板、共享角色出口及双语人类说明。旧交接缺少该行仍可接续；人工决定、`continue`、`close` 省略该行。
- 保持建议性质、原 Routing 机器字段、S/M/H、权限、独立审查和累计审查计数；通过聚焦契约演练与既有结构校验核对兼容。

不纳入型号榜单、模型测评、自动选模或配置、运行时编排、强制选模或新增批准步骤；本次设计不扩大已确认范围。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：为既有交接增加单行能力参考、固定默认映射与向后兼容要求，不替代原有路由和验收契约。

## Impact

- 产品规范与模板：`payload/docs/ai-collaboration/handoff-schema.md`、`README.md`、`agent-prompts.md`、`workflows.md`、`templates/handoff.template.md`、`templates/response-handoff.template.md`。
- 人类说明：根目录两版 README、两版 CHANGELOG 的未发布段落，以及 payload 下两版 operator-guide；英文 Agent 契约保持单份。
- 不需要新依赖、安装路径、清单字段、宿主副本或校验器逻辑；保持当前发行 `snapshot.json`，后续发行按开发指南从干净暂存重建。
- 一个 M 级批次完成实现、聚焦检查与独立代码审查；提交、推送、发行与真实部署不在本次授权内。
