# 维护规范基线

[English](README.md)

本目录管理 EngRelay 后续维护，起始于公开 v1.7.0。`specs/collaboration-package/spec.md` 汇总当前契约，不复制私有历史，也不将旧审查轮次当作新验收。

新工作请使用活跃变更的 proposal、specs、必要时 design，以及 tasks.md。本引导不创建活跃产品变更，也不产生实时角色交接。不要将早期私有工作区的活跃变更或已接受批次状态复制到本克隆。仅源码的 OpenSpec 记录保留在 Git 中，并由 `.gitattributes` 排除在安装导出之外。

## 后续事项

已讨论跟进事项的简要状态。具体实施进度仍在各变更的 `tasks.md`；本表不是第二
清单，也不授权执行。

| 状态 | 含义 |
| --- | --- |
| 待决定 | 尚未选定实施，不是承诺 |
| 已确认待实施 | 范围已选定；任务以链接的活动变更为准 |
| 待验证 | 缺少指定验证证据；不代表批准招募或外部操作 |
| 已完成 | 映射工作已完成，并有对应任务与审查证据 |

| 事项 | 来源 | 状态 | 变更或证据 |
| --- | --- | --- | --- |
| 交接能力档位 C1–C5 | 负责人选定的 M 级批次 | 已完成 | [已归档变更](changes/archive/2026-10-18-add-handoff-capability-guidance/tasks.md)；[审查索引](../docs/reviews/add-handoff-capability-guidance/index.md) |
| 关闭依据与本导航 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-18-clarify-closure-and-follow-up-tracking/tasks.md)；[审查索引](../docs/reviews/clarify-closure-and-follow-up-tracking/index.md) |
| 自主接续与人类介入摘要 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-18-fix-autonomous-continuation/tasks.md)；[审查索引](../docs/reviews/fix-autonomous-continuation/index.md) |
| 获准边界的 handoff 持久化 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-19-fix-handoff-persistence/tasks.md)；[审查索引](../docs/reviews/fix-handoff-persistence/index.md) |
| OBS-01：负责人扩展解析中的批次序数比较 | 第 03 轮观察项 | 待决定 | [审查索引](../docs/reviews/fix-handoff-persistence/index.md#deferred-follow-up)；实施前须由 Task Intake 决定范围 |
| 自包含演示样例 | 路线讨论；[Phase 0 非目标](changes/archive/2026-10-17-improve-phase0-first-trial/proposal.md#non-goals) | 待决定 | 链接仅说明曾排除，不代表完整路线图 |
| Phase 0 / G0 外部试用 | 负责人阶段目标（讨论） | 待验证 | 尚未开展；包检查不等于外部试用 |
| Quickstart 排错与全链路演练 | [1.9.0 发行审查](../docs/reviews/release-1.9.0.md) | 待验证 | 该记录中的明确未测范围 |
| Phase 1–3 路线图 | 负责人外部规划（未随本仓库发布） | 待决定 | 须按最新试用事实另选范围；不虚构变更编号 |
