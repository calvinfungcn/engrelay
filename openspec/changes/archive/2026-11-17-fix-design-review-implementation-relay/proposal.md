# Proposal

## Why

Full 的设计评审出口要求通过后交接实施，但独立批次又允许在映射事项完成后关闭；当前缺少对“角色已完成、设计独立交付、同批实施未完成”三种边界的统一说明。已有实施授权的用户可能因此只收到设计批次关闭通知，难以继续跨平台接力；部分任务叙述还会保留已经过时的评审状态。

## What Changes

- 明确设计与角色会话边界不自动构成批次关闭边界：当前映射实施未完成时交接实施；有依据的独立设计交付完成时仍可合法关闭。
- 发现映射与已授权目标不一致时，交回 Chief Designer 作最小范围核对，保留计数和授权，不把技术核对升级为重复审批或重新设计评审。
- 独立设计批次关闭时，在现有 Current Status 开头说明设计完成、父提案剩余范围及可复制的接续请求；已授权且无歧义的后续工作复用既有 Task Intake，并尊重本轮角色停止指令。
- 在真实交接边界核对任务、交接、Review 与唯一任务清单的事实对应，清除活动叙述中的过时状态；保持历史原样。
- 协调相关入口、模板和双语用户说明，用虚构场景检查路由与可读性，维持人工接力与必要独立审查。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：细化 Coherent role routing and review independence 与 Actionable closed-batch guidance，复用既有关闭后授权、持久化和状态校验要求。

## Impact

- 产品规范：`payload/docs/ai-collaboration/README.md`、`workflows.md`、`agent-prompts.md`、`handoff-schema.md` 的对应段落及路由表，和 `agent-rules.md` 的批次范围短句。
- 入口与模板：同目录 canonical `skills/ai-collab-start/SKILL.md`、`skills/ai-collab-continue/SKILL.md` 及 current-task/handoff 模板，以短引用共享规则。
- 人类说明：两份 operator-guide、根 README 和 CHANGELOG 成对同步，修复记录进入 Unreleased；不作版本发行准备。
- 保留现有角色、机器字段/枚举、路径、旧交接兼容、实际计数、有限授权和独立性；Full 规则修复不改变 Lite、manager 或 validator 代码，也不新增运行引擎。
- 本批为一个 M 级完整修复，范围包括规则、说明、受影响检查及独立审查。归档、提交、发布和真实项目安装不在本次范围内。
