# Proposal

## Why

v1.10.1 已具备 Lite／Full、交接恢复与上下文改进，但首次试用仍要求用户自备任务。2026-10-17 的 Phase 0 变更只交付选定的八项改进，明确排除了公开样例和完整 G0；需要补齐可重复的新会话接续体验，并按当前事实校准路线图。

## What Changes

- 在源码中提供一个有明确初始缺陷的 PowerShell 标签去重样例、预置 OpenSpec 文档与未完成任务，不携带旧运行态。会话 A 使用 Full start 准备交接，会话 B 在没有 A 聊天上下文的情况下继续实施并检查。
- 双语样例指南与现有 README／Quickstart 相连，明确完整发行包、固定提交的源码检出、一次性项目三个目录。源码样例使用 Git 检出取得；不依赖会受 export-ignore 影响的自动源码 ZIP。
- 仅增加 `/examples/handoff-demo export-ignore`，保留原有排除规则；不增加 payload 或受管安装路径。演示使用可信完整 v1.10.1 包，不从开发检出安装。
- 在两个全新目录各完成真实 A/B 演练，保留输入版本、实际调用和行为结果；本地候选、公开固定提交下载、外部 G0 分别判断，未发生的阶段不标通过。
- 维护双语源码路线图，记录既有完成项、三人首次试用协议、有限 Phase 1 及 F3／F4 的独立入口。上游定向比较只取兼容的方法，不新增控制器、字段、评分或常驻工具。

### Non-goals

本变更不招募或联系用户，不执行外部 G0／跨工具试验、F3／F4 修复、全路线图或 Lite 比较矩阵；不修改规范 Skill、校验器、安装器、受管布局、全局设置或真实项目。当前请求只建立规划，不实施代码、不提交／推送／发布、不更新版本、CHANGELOG 或根 snapshot。

## Capabilities

### New Capabilities

无；复用现有协作包与入口。

### Modified Capabilities

- `collaboration-package`：补充源码专用首次交接样例、取得与导出边界、实际双会话证据及分阶段状态要求；保留既有试用前提、独立审查与路由契约。

## Impact

- 后续实施路径：`examples/handoff-demo/`、根 README 两种语言、`docs/quickstart.md`／`docs/quickstart.zh-CN.md`、`.gitattributes`。
- 本轮规划路径：本变更的 proposal／design／delta spec／tasks、`openspec/roadmaps/product-growth.md`／`product-growth.zh-CN.md`、OpenSpec 双语导航及获准的本地交接。
- 风险 M：样例的真实接续与分发边界需要一次独立聚合审查；样例内部的 S 级任务不因此增加审查。保持源码仓库 Git 只读，后续仅可丢弃演示／导出夹具使用无远端的临时 Git 基线。
- 实施清单只在本变更 tasks.md。发布后固定提交与真实下载可用性属于后续提交准备，不是本次本地交付的虚构成功条件；G0 仍须真实外部证据。
