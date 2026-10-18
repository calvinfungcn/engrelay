# Proposal

## Why

已归档的 Phase 0 变更明确将“校验失败不得 accepted”留待后续处理；C1–C5 曾被延期、现已完成，也暴露出缺少当前后续事项入口的问题。负责人现已确认：补齐普通验收关闭的有效校验依据，并用简短双语导航区分完成、待实施和待验证，避免将规划或结构通过误称为完成。

## What Changes

- 在共享交接契约集中明确：普通 accepted 需完成对最终交接及相关输入的结构校验，保存命令、实际退出码、诊断和可核对的输入依据；失败先修复复验，环境不可用使用 continue + blocked。
- 采用外置证据、先完成交接再校验的顺序，避免把成功记录写回被校验交接而循环失效；保留负责人有限接受、旧交接兼容、现有机器字段、独立审查及累计 verdict。
- 两份交接模板、共享角色出口和双语人类说明同步最少指引。沿用现有只读校验器，新增规则由负责角色遵循；不把结构校验宣传为证据真实性认证。
- 在现有 OpenSpec 中英文导航增加轻量事项表：事项、来源、状态、对应变更或完成证据；只表达当前概况，实施仍以各变更 tasks.md 为唯一清单。
- 初始记录 C1–C5 已完成、本变更待实施，以及样例、G0、Quickstart 未测部分和后续路线图的真实待定/待验证边界；不复制私人规划全文、不自动授权这些工作的实施。

### Non-goals

不修改运行态校验算法、安装器、Skill 名称、机器字段或历史归档；不新增日志认证系统、后台校验、调度器、实施清单或历史迁移。演示实现、外部招募、Quickstart 全链路补测、后续阶段、版本发布及真实部署不在范围内。

## Capabilities

### New Capabilities

无；复用现有协作包能力。

### Modified Capabilities

- `collaboration-package`：增加普通 accepted 的校验依据与非循环记录约定，以及不改变实施权威的双语后续事项导航要求。

## Impact

风险 M：修改共享 Agent 契约和使用说明，实施后需独立代码审查。规范源位于 `payload/docs/ai-collaboration/`；源码导航位于 `openspec/README.md` 和 `openspec/README.zh-CN.md`，不进入安装导出。两版根 README、operator-guide 和 CHANGELOG Unreleased 同步最少必要说明。无新依赖、运行服务或全局设置。

本轮仅建立 proposal、design、增量 specs 和唯一 tasks.md。检查规划结构不等于实现、独立审查或业务验收；根 snapshot 仅在另行授权发行的干净 staging 刷新。
