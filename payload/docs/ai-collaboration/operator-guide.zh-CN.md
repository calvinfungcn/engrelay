# 操作指南

[English](operator-guide.md)

面向人类的使用说明。角色契约、机器字段与校验规则以 [README.md](README.md) 与
[handoff-schema.md](handoff-schema.md) 为准；本文件不替代它们。

## 激活

包管理项目在
[可选激活](README.md#optional-activation-and-coexistence) 下使用 `WorkflowMode`
**optional**（新安装默认）、**default** 或 **disabled**。当前请求对本工作流的
**明确选择**优先于项目的 **default** 默认选择。在 **optional** 模式下需在当
次请求中显式选择 EngRelay；在 **default** 模式下可按项目已配置的默认选择运
行，无需每次重复声明。仅安装工具包、发现 Skill 或存在 `.ai/` 目录本身不会
启动批次。

若 `WorkflowMode` 为 `disabled`，使用前需显式重新启用。若任务由其他控制器负责，
遵循该控制器，且不写入协作运行态文件。

## 入口

| 入口 | 适用场景 |
| --- | --- |
| `ai-collab-start` | 推荐：有明确目标的新任务 |
| `ai-collab-requirements` | 设计前显式进行业务需求讨论 |
| `ai-collab-continue` | 接续最新已授权交接 |

无宿主发现副本时，请让 Agent 直接阅读已安装项目下的
`docs/ai-collaboration/skills/<name>/SKILL.md` 规范 Skill。

### Start（推荐）

- **目标明确：** Task Intake 准备最小任务输入，按风险分流（如首席设计师、实现工程师或代码审查员），不插入固定需求阶段。
- **重要业务歧义：** 同一负责会话执行
  [条件需求分析师](workflows.md#requirements-analyst-conditional-role-action) 动作；不要求负责人再单独调用 `ai-collab-requirements`。
- **业务已明确、剩余为技术问题：** 交给首席设计师，不把技术选择变成业务访谈阻塞项。
- **已确认的需求：** 直接复用，不重复最终确认。

### Requirements（显式快捷）

与 start 共用同一分析师契约，仅在负责人明确选择“先谈需求”时激活。负责人明确确认后，只交给首席设计师。

### Continue

阅读 `.ai/current-task.md` 与 `.ai/handoff.md`，仅按记录的下一步动作继续；不重置审查计数、不重放已关闭批次。

## 交接与审查

- 下一步动作仅一种：`continue`、`dispatch` 或 `close`。
- 向 Agent 派发时附带完整 Operator Command。
- Agent 派发可在 `Current Status` 下增加一行建议，例如
  `Recommended capability tier: C3`。档位 C1–C5 仅提示为**下一项**工作选择模型与
  推理强度：C1 机械执行、C2 常规局部、C3 综合工程、C4 深度分析、C5 高难度推理；
  不批准模型、不阻塞流程、不替代独立审查。固定默认表与规则见
  [handoff-schema.md#capability-tier-guidance](handoff-schema.md#capability-tier-guidance)。
  人工决定派发、`continue` 与 `close` 省略该行。
- 负责人决定使用 `awaiting-owner-decision` 与 Owner Decision Brief；沉默不构成批准。
- 中风险批次需独立代码审查；见 [审查上限](README.md#review-round-circuit-breaker)。

正式审查轮次与结果索引见 `docs/reviews/`（若已记录）。

## 成本与授权

聚焦检查应匹配受影响行为。在收益不足或成本明显的工作前，责任 Agent 应说明选项并等待负责人选择。负责人验收、Git 操作与部署不在入口 Skill 范围内。

## 采用与宿主

- [项目采用](project-adoption.zh-CN.md) — 安装、升级、接管、卸载。
- [宿主能力](host-capabilities.zh-CN.md) — SkillTarget 发现路径。

安装后请使用本目录相对路径（`docs/ai-collaboration/`）。
