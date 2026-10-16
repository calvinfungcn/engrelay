# 示例 - 基于风险的 Action State

[English](mobile-points-expiry-reminder.md)

以下虚构功能用于演示协作协议：

> 在移动端显示员工积分将在 30 天内过期的提醒。

下面的规范示例始终属于同一个风险 `M` Execution Batch。替换虚构路径和
Agent 名称后，其中的运行时工件可以直接使用。后面的 `S` 和 `H` 流程属于
其他任务变体，只是不可复制的流程摘要。

## 规范的 M Current Task

`.ai/current-task.md` 在整个批次中保持稳定：

```markdown
# Current Task - 移动端积分过期提醒

## Task Identity

- Task ID: `mobile-points-expiry-reminder`
- Change ID: `add-mobile-points-expiry-reminder`
- Module(s): `mis_app/`
- Source: `openspec/changes/add-mobile-points-expiry-reminder/`
- Created on: `2026-08-04`

## Batch Classification

- Execution Batch ID: `points-reminder-ui`
- Risk level: `M`
- Risk reason: `该变更增加共享的移动端展示行为和本地化状态转换。`
- OpenSpec checklist items:
  - `2.1`
  - `2.2`
- Existing capability to reuse: `现有积分 API 和 controller-backed 页面`
- First demonstrable outcome: `符合条件时显示本地化提醒，条件变化后提醒消失；在两种资格状态下检查积分页面`
- Justified complexity exceptions: `none`
- Stop condition: `现有 API 无法识别 30 天内到期的积分`
- Expected implementation sessions: `1`
- Broad regression command: `flutter test`

## Initial Assignment

- Initial role: `Implementation Engineer`
- Recommended agent: `mobile-capable agent`
- Initial prompt template:
  - `docs/ai-collaboration/agent-prompts.md#implementation-engineer`

## Required Reading

- `AGENTS.md`
- `mis_app/AGENTS.md`
- `docs/ai-collaboration/workflows.md#6-implementation`
- `docs/ai-collaboration/agent-prompts.md#implementation-engineer`
- `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`
- `openspec/changes/add-mobile-points-expiry-reminder/specs/points-reminder/spec.md`
- `mis_app/lib/pages/points_page.dart`
- `mis_app/test/points_expiry_reminder_test.dart`

## Goal

复用现有积分 API 显示一条本地化提醒，并使提醒与当前资格状态保持一致。

## Scope

- 提醒展示、本地化、状态转换和聚焦 Widget 测试。

## Out of Scope

- 积分计算和通知调度。

## Must Not Touch

- 后端积分核算和无关的移动端页面。

## Acceptance Criteria

- 符合条件的积分显示本地化提醒。
- 不符合条件的积分不显示提醒。
- 状态从符合条件变为不符合条件后，提醒消失。

## Constraints

- 复用现有积分 API 和页面 controller。
- 不新增通知服务或后端契约。

## Required Checks

- `flutter test test/points_expiry_reminder_test.dart`
- `flutter analyze`
- `flutter test`

## Output Requirements

- 更新限定范围内的移动端代码和测试。
- 在 `.ai/round-01-result.md` 记录实现证据。
- 在 `.ai/handoff.md` 中以唯一的 Next Action 结束。
```

实时状态和路由不得写回该文件。

## 规范的 M 审查派发

实现完成后，`.ai/handoff.md` 包含完整派发状态：

````markdown
# Handoff - points-reminder-ui implementation

## Routing

- Next action: `dispatch`
- Current role: `Implementation Engineer`
- Current agent: `mobile-capable agent`
- Current status: `ready-for-review`
- Next role: `Code Reviewer`
- Recommended next agent: `independent review-capable agent`
- Next input files:
  - `.ai/current-task.md`
  - `.ai/round-01-result.md`
  - `docs/reviews/README.md`
  - `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`
  - `openspec/changes/add-mobile-points-expiry-reminder/specs/points-reminder/spec.md`
  - `mis_app/lib/pages/points_page.dart`
  - `mis_app/test/points_expiry_reminder_test.dart`
- Next output files:
  - `docs/reviews/add-mobile-points-expiry-reminder/2026-08-04-round-01.md`
  - `docs/reviews/add-mobile-points-expiry-reminder/index.md`
  - `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`
  - `.ai/handoff.md`
- Next prompt template:
  - `docs/ai-collaboration/agent-prompts.md#code-reviewer`

## Current Status

实现和必要检查已经完成；该风险 `M` 批次需要一次独立审查。

## Delta Since Last Handoff

- 增加本地化提醒和资格状态转换行为。
- 增加聚焦 Widget 覆盖并记录广泛回归结果。

## Authoritative Evidence

- `.ai/round-01-result.md`
- `openspec/changes/add-mobile-points-expiry-reminder/specs/points-reminder/spec.md`

## Known Risks

- 审查必须确认资格变化后提醒会消失。

## Blockers

- None.

## Review Or Task State Impact

- 尚未改变正式审查状态或 OpenSpec 勾选状态。

## Operator Command
```text
You are the Code Reviewer for Execution Batch points-reminder-ui (risk M).
Read: AGENTS.md, mis_app/AGENTS.md, docs/reviews/README.md, .ai/current-task.md, .ai/handoff.md, .ai/round-01-result.md, the mapped OpenSpec spec and tasks, and the changed points page and tests.
Objective: Review the complete mapped acceptance, final diff, and recorded evidence; report all high-confidence findings together and give a clear verdict.
Constraints: Read-only for implementation code and tests; preserve unrelated changes. Required review and .ai handoff artifacts remain writable.
Output: Create docs/reviews/add-mobile-points-expiry-reminder/2026-08-04-round-01.md and update docs/reviews/add-mobile-points-expiry-reminder/index.md and .ai/handoff.md. If clean, mark OpenSpec items 2.1 and 2.2 complete in openspec/changes/add-mobile-points-expiry-reminder/tasks.md before close; otherwise preserve their task state and dispatch one Fix Engineer with all assigned findings in one copy-ready Operator Command.
Follow: docs/ai-collaboration/agent-prompts.md#code-reviewer.
```
````

## 规范的 M 无问题关闭

审查无问题时，Reviewer 用以下完整关闭状态替换实时 handoff：

```markdown
# Handoff - points-reminder-ui review

## Routing

- Next action: `close`
- Current role: `Code Reviewer`
- Current agent: `independent review-capable agent`
- Current status: `closed`
- Next role: `none`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

独立审查未发现可执行问题，映射的验收条件已经完成。Task Owner 进度摘要：
符合条件的积分显示本地化提醒，条件变化后提醒消失；在两种资格状态下检查
积分页面，并查看聚焦 Widget 测试输出。验收条件 `2.1` 和 `2.2` 已满足，
OpenSpec 条目 `2.1` 和 `2.2` 已完成。除正常发布验证外没有偏差，当前批次没有
剩余映射工作；后续工作必须通过单独的 Task Intake 开始。

## Delta Since Last Handoff

- 审查最终差异、聚焦测试、静态分析和广泛回归证据。
- 创建正式审查 Round 01，并更新持久审查索引。
- 记录审查证据后，将 OpenSpec 条目 `2.1` 和 `2.2` 标记为完成。

## Authoritative Evidence

- `.ai/round-01-result.md`
- `docs/reviews/add-mobile-points-expiry-reminder/2026-08-04-round-01.md`
- `docs/reviews/add-mobile-points-expiry-reminder/index.md`
- `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`

## Known Risks

- 除正常发布验证外无其他风险。

## Blockers

- None.

## Review Or Task State Impact

- 正式审查 Round 01 已写入索引，且没有未解决的已分配问题。
- OpenSpec 条目 `2.1` 和 `2.2` 已在
  `openspec/changes/add-mobile-points-expiry-reminder/tasks.md` 中标记为完成。
- 当前已完成批次没有剩余工作；无关或后续工作不会因关闭而自动开始。

## Process Metrics

- Role actions: `2`
- Review/fix/verification loops: `0`
- Broad regression runs: `1`
- Elapsed time: `1h 20m`
- Token usage: `unknown`
```

关闭状态没有 Operator Command，因为没有剩余角色。如果审查发现可执行问题，
应使用 `dispatch`，并把所有已分配问题一次性派发给一个 Fix Engineer。如果
严格只读指令禁止写入 `.ai`，使用
`docs/ai-collaboration/handoff-schema.md#response-handoff-fallback` 中的完整
响应回退格式。

## 独立的风险变体

以下只是流程摘要，不是运行时工件，也不能复制到上面的风险 `M` 示例中。

- 单独分类为风险 `S` 的文档或机械性任务，可在自验证后使用
  `Implementation Engineer -> close`。
- 单独分类为风险 `H` 的安全或数据完整性任务，在问题需要修复时可使用
  `Implementation Engineer -> Code Reviewer -> Fix Engineer -> independent
  Verification Reviewer -> close`。
- 证据完整且审查无问题的 `H` 批次可以直接关闭。
- 唯一允许的修复和验证闭环失败时，派发 Chief Designer 作出 `REVISE`、
  `STOP` 或 `SPLIT`，不得自动开始新闭环。

## Owner 决策示例

### 同会话 Continue

当同一角色和 Agent 可以在当前交互中接收决策时，使用 `continue`：

```markdown
# Handoff - points-reminder-ui clarify copy

## Routing

- Next action: `continue`
- Current role: `Implementation Engineer`
- Current agent: `mobile-capable agent`
- Current status: `awaiting-owner-decision`
- Next role: `none`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

在完成 Widget 实现前等待 Task Owner 对提醒横幅文案做出决策。

## Delta Since Last Handoff

- 识别出 30 天提醒的两种可行文案选项。

## Authoritative Evidence

- Implementation or fix result: `none`
- Formal review or verification round: `none`
- OpenSpec checklist: `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`

## Known Risks

- None.

## Blockers

- 等待文案决策。

## Owner Decision Brief

- Decision needed: 员工积分在 30 天内过期时应显示哪种横幅文案？
- Recommendation: 使用简明警告文案 (Reason: 适配移动端卡片头部，跨屏幕尺寸均不会发生截断)
- Alternatives:
  - 使用包含精确积分明细的详细文案 (Consequence: 折行为三行并将操作按钮挤至首屏下方)
- Reply needed: `简明`
- After the reply: Implementation Engineer 将应用所选文案字符串并运行 widget 测试。

## Review Or Task State Impact

- Formal review status impact: `none`
- OpenSpec task impact: `none`
```

### 人工决策派发 (Human Decision Dispatch)

对于明确的异步或跨人员业务、数据权限或批准决策，使用人工决策 `dispatch`：

```markdown
# Handoff - points-reminder-ui owner approval

## Routing

- Next action: `dispatch`
- Current role: `Implementation Engineer`
- Current agent: `mobile-capable agent`
- Current status: `awaiting-owner-decision`
- Next role: `Task Owner`
- Recommended next agent: `none`
- Next input files: `none`
- Next output files: `none`
- Next prompt template: `none`

## Current Status

等待 Task Owner 确认恰好在第 30 天到期的积分是否包含在提醒范围内。

## Delta Since Last Handoff

- 实现了边界检查逻辑；请求 owner 对第 30 天是否包含进行决策。

## Authoritative Evidence

- Implementation or fix result: `none`
- Formal review or verification round: `none`
- OpenSpec checklist: `openspec/changes/add-mobile-points-expiry-reminder/tasks.md`

## Known Risks

- None.

## Blockers

- 等待 owner 边界决策。

## Owner Decision Brief

- Decision needed: 恰好在第 30 天到期的积分是否应包含在提醒范围内？
- Recommendation: 包含第 30 天 (Reason: 给员工在过期前完整的 30 天通知期)
- Alternatives:
  - 排除第 30 天并从第 29 天开始 (Consequence: 通知窗口减少 24 小时)
- Reply needed: `包含`
- After the reply: Implementation Engineer 将最终确定比较器逻辑并运行 flutter test。

## Review Or Task State Impact

- Formal review status impact: `none`
- OpenSpec task impact: `none`
```

## 操作者检查清单

1. 读取 `.ai/handoff.md`。
2. 对于 Agent `dispatch`：把 Operator Command 发送给推荐 Agent。
3. 对于人工决策 `dispatch`：将 Owner Decision Brief 呈现给指定人类角色，收集其简短选择，并重新调用同一角色/Agent。
4. 对于 `continue`：让同一个 Agent 继续。
5. 对于 `close`：不要再为该批次发送提示词。
6. 接受角色退出前运行
   `docs/ai-collaboration/scripts/validate-runtime-state.ps1`。
