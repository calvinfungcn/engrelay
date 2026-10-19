# Proposal

## Why

v1.9.3 已落实交接写回与审查来源恢复，但候选发现规则没有明确覆盖实现结果，且 applied 判定未比较 `continue` 位于 Current Status 的接续内容。这会留下有完整结果却无法安全接续、或不同命令被误认已应用的风险，需要在现有文件和权限边界内补齐。

## What Changes

- 将当前任务或 live handoff 明确关联的同批实现/修复结果纳入来源匹配恢复；复用现有 Next Action 容器，只有完整交接及匹配依据才可作候选，不扫描历史或从普通总结猜测路由。
- 对已应用判定按动作比较执行内容：Agent dispatch 保留 Operator Command 比较；可执行 continue 比较 Current Status 中的完整接续说明，包括 Continuation Command；同修订号内容不同保持 conflict。
- 明确同角色计划换会话也是写回边界；活跃可写主 Agent 在摘要或继续派发前保存只读子代理完整结论。长检查仅在有实质恢复价值时使用既有 continue 检查点和外置日志。
- 修正源规则和管理块标题中的 legacy 歧义，保留 optional/default/disabled、管理标记和块外内容保护；同步必要模板、canonical Skill 和双语说明。
- 真实项目的块外规则修正另作项目侧小任务，在本提案保留 `LOCAL-ENTRY-01` 待承接记录；本源码批次不修改真实项目，也不把它作为验收前提或已完成事项。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：细化工作流适用性说明、真实边界持久化、现有文件中的完整恢复交接及来源匹配/已应用判定。

## Impact

风险 M。影响 `payload/docs/ai-collaboration/` 的 schema、角色提示、workflows、implementation-result/交接模板、canonical continue Skill、相关双语人类说明，以及 `agent-rules.md` 和管理器生成标题的文案。预期不新增 CLI 参数、状态字段、依赖或运行引擎，不修改现有 validator 比对算法。

先作一次独立设计审查，实施后作独立 M 代码/协议审查，累计 verdict 按现行规则。以虚构可丢弃目录演练受影响恢复路径，保留旧调用与记录兼容；不承诺宿主强制执行、原子写入或异常终止零丢失。不增加 mtime 守门、Git/CI/Profile 钩子、WAL、自动宿主配置、全局设置、真实部署或发布。本轮只建立规划工件，实施进度仅维护本变更 tasks.md。
