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
| Lite 可执行交接额度、围栏解析及已发布说明 | 负责人选定的项目修复 F1／F2／F5 | 已完成 | [已归档提案](changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md)；[已归档任务](changes/archive/2026-10-30-harden-lite-handoff-validation/tasks.md)；[审查索引](../docs/reviews/harden-lite-handoff-validation/index.md)；发行前独立审查通过，累计第 5 轮 |
| SetMode 失败恢复（F3） | 负责人选定的后续工作 | 已确认待实施 | [范围入口](changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md#follow-up-work)；尚未建立独立变更，保留入口／清单不一致的现有证据 |
| 可信 v2 布局演进（F4） | 负责人选定的后续工作 | 已确认待实施 | [范围入口](changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md#follow-up-work)；尚未建立独立变更，须在后续新增或退役受管路径的发行前解决 |
| 同仓库 Lite／Full 配置 | 负责人选定的整合方向 | 已完成 | [三期路线图](roadmaps/lite-full-integration.zh-CN.md)；[已归档提案](changes/archive/2026-10-24-integrate-lite-full-profiles/proposal.md)；[已归档任务](changes/archive/2026-10-24-integrate-lite-full-profiles/tasks.md)；[审查索引](../docs/reviews/integrate-lite-full-profiles/index.md) |
| 估算定义可达性与精益规则试点 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-21-link-sizing-guidance-and-pilot-lean-rules/tasks.md)；[审查索引](../docs/reviews/link-sizing-guidance-and-pilot-lean-rules/index.md) |
| 精简进度说明与交接能力输出 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-20-improve-lean-progress-and-capability-handoff/tasks.md)；[审查索引](../docs/reviews/improve-lean-progress-and-capability-handoff/index.md) |
| 有界上下文读取、取证示例与交付反馈 | 负责人选定的 M 级批次；关闭后审计已完成 | 已完成 | [已归档任务](changes/archive/2026-10-25-improve-context-and-review-feedback/tasks.md)；[审查索引](../docs/reviews/improve-context-and-review-feedback/index.md)；[2026-10-25 审计](../docs/reviews/improve-context-and-review-feedback/2026-10-25-release-audit.md) |
| 自动过程统计（P2） | 负责人讨论的后续事项 | 待决定 | 不作为实施承诺；试点证据支持推迟准入（见[试点证据](../docs/reviews/link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md#decision-1-p2-entry-criteria-automatic-sizing--statistics)） |
| 更广泛的上下文精简与冗余提示词缩减 | 试点发现（决策 2） | 待决定 | 本变更仅完成有界读取指引和相关反馈；其余上下文精简及提示词／schema 工作尚未承诺。见[试点证据](../docs/reviews/link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md#decision-2-context-consolidation-prompt--schema-lean-guidance) |
| 交接能力档位 C1–C5 | 负责人选定的 M 级批次 | 已完成 | [已归档变更](changes/archive/2026-10-18-add-handoff-capability-guidance/tasks.md)；[审查索引](../docs/reviews/add-handoff-capability-guidance/index.md) |
| 关闭依据与本导航 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-18-clarify-closure-and-follow-up-tracking/tasks.md)；[审查索引](../docs/reviews/clarify-closure-and-follow-up-tracking/index.md) |
| 自主接续与人类介入摘要 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-18-fix-autonomous-continuation/tasks.md)；[审查索引](../docs/reviews/fix-autonomous-continuation/index.md) |
| 获准边界的 handoff 持久化 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-19-fix-handoff-persistence/tasks.md)；[审查索引](../docs/reviews/fix-handoff-persistence/index.md) |
| 交接恢复加固 | 负责人选定的 M 级批次 | 已完成 | [已归档任务](changes/archive/2026-10-19-harden-handoff-recovery/tasks.md)；[审查索引](../docs/reviews/harden-handoff-recovery/index.md) |
| OBS-01：负责人扩展解析中的批次序数比较 | 第 03 轮观察项 | 待决定 | [审查索引](../docs/reviews/fix-handoff-persistence/index.md#deferred-follow-up)；实施前须由 Task Intake 决定范围 |
| 自包含演示样例 | 路线讨论；[Phase 0 非目标](changes/archive/2026-10-17-improve-phase0-first-trial/proposal.md#non-goals) | 待决定 | 链接仅说明曾排除，不代表完整路线图 |
| Phase 0 / G0 外部试用 | 负责人阶段目标（讨论） | 待验证 | 尚未开展；包检查不等于外部试用 |
| Quickstart 排错与全链路演练 | [1.9.0 发行审查](../docs/reviews/release-1.9.0.md) | 待验证 | 该记录中的明确未测范围 |
| Phase 1–3 路线图 | 负责人外部规划（未随本仓库发布） | 待决定 | 须按最新试用事实另选范围；不虚构变更编号 |
