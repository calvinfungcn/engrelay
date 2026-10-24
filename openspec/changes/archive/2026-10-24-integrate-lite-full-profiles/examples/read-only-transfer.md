# 严格只读评审返回的完整虚构样例

这是设计输入，不是实际评审结论，也不是本仓库的 live 恢复指令。样例 A 已预先点名预期结果路径；这里模拟该路径收到一次只读 Reviewer 的完整返回。

## 来源与归属

- Task ID: T01
- Source role: Reviewer
- Source agent: fictional-reviewer-B
- Work producer: fictional-executor-A
- Named result: .ai/engrelay-lite/tasks/T01-review-1.md
- Prior revision: 4
- Prior handoff SHA256: 0E15B4C3F4C7C1BDCFCD4AFD7BCB021C033438AF6221C22C69C6352A1E29808E
- Target revision: 5
- Cumulative verdicts: 1
- Verdict: FAIL
- Handoff persistence: Not written by this fictional read-only reviewer. An active permitted writer must publish the full checked transfer before relying on live routing.

以上指纹由 [T01-before-review.md](states/T01-before-review.md) 实际字节计算。第二期若将该文件原字节复制为夹具 live，指纹适用；改写换行或内容后应重新计算并匹配实际旧状态，不能保留旧哈希掩盖差异。目标为 [T01-after-review.md](states/T01-after-review.md) 的 Routing 与动作正文。

## 完整发现

- F01，must-fix，open：虚构任务 T01 的既定验收要求空输入行为，样例约定该行为遗漏。要求 Executor 在原范围修复并作聚焦检查，由独立 Reviewer 复核；未复核不能写 verified。这里只陈述夹具设定，不宣称发现真实 EngRelay 缺陷。

## 完整响应交接

````markdown
# Fictional Lite handoff T01 after review

## Routing

- Schema version: lite-1
- Task ID: T01
- State revision: 5
- Current role: Reviewer
- Current agent: fictional-reviewer-B
- Current status: in-progress
- Next action: dispatch
- Human Action Required: none
- Review round: 1
- Next role: Executor
- Risk level: M

## Current Status

Recommended capability tier: C3

The fixture stipulates one actual verdict with must-fix F01: the task's defined empty-input case is not handled. F01 is open; T01 is not accepted.

## Evidence

- Task authority: .ai/engrelay-lite/tasks/T01.md
- Review result and F01: .ai/engrelay-lite/tasks/T01-review-1.md

## Operator Command

```text
You are the Executor for task T01.
Read: AGENTS.md, docs/engrelay-lite/RULES.md, docs/engrelay-lite.config.md, .ai/engrelay-lite/tasks/T01.md, .ai/engrelay-lite/handoff.md and .ai/engrelay-lite/tasks/T01-review-1.md.
Objective: fix F01, the recorded missing empty-input behavior required by T01 acceptance, and check the affected behavior.
Constraints: preserve the authorized scope and actual verdict count 1, with 2 default verdicts remaining. Do not treat the review as repeated or declare your own fix independently verified. Do not change models or task identity to reset the count.
Output: authorized T01 implementation files and existing result record; then publish .ai/engrelay-lite/handoff.md with a complete independent-review handoff. Business scope does not expand. Save, read back and validate the decided expectations.
Follow: docs/engrelay-lite/RULES.md.
```
````

实际写入者保留上述来源与发现，不冒充 Reviewer；发布行为不新增 verdict。无法取得有权 writer 时完整返回仍有效作为响应，不能声称文件已更新。冲突、已关闭或真正等待的 live 优先于本候选。
