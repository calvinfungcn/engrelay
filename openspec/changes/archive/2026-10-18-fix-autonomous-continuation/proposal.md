# Proposal

## Why

现行交接把远期环境准备写成当前回复要求，且没有为单次 CLI 退出后的 `continue` 提供自包含接续规范，容易造成假性阻塞和不必要的负责人请示。需要让当前是否需要人类介入可直接辨认，同时保留授权、独立审查和真实环境阻断。

## What Changes

- 区分即时环境前置与中性远期预告；远期预告不得要求当前操作或回复。
- 新建或正常更新的交接在 Routing 显示 `Human Action Required: none|awaiting-decision|awaiting-environment`，旧记录缺字段保持有效。
- 在 Current Status 内提供条件性的 `### Continuation Command`，支持跨会话接回同一职责的已授权工作；保留 dispatch 的 Operator Command。
- 明确本地宿主选择属于自主工程细节；有执行能力的活跃 Agent 立即继续，不把 CLI 退出当作阻塞，也不承诺自动唤醒。
- 同步规范、入口 Skill、模板、双语人类说明与结构校验/回归用例。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：补充非阻塞环境预告、自包含自主接续和兼容的人类介入指示规则。

## Impact

影响 payload 下的 handoff schema、模板、角色提示、workflows、README、ai-collab-continue 和运行态校验器及其测试，以及 agent-rules 受管激活块、双语项目 README、操作者说明和 CHANGELOG。维护风险为 M，需要独立代码审查。只使用虚构可丢弃 fixture，不读取或修改报告问题的真实业务项目。保持既有三种动作、状态、角色边界与累计审查规则；不建设运行时编排器，不发布、不部署、不修改全局设置。发行清单留到受审查的下一次发布按干净暂存流程生成。
