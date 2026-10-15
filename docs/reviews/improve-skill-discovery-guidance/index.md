# improve-skill-discovery-guidance

## Scope

安装后 Skill 规范读取/宿主发现指引、输出流兼容与双语 README。批次 `engrelay-skill-discovery-20261015-01`，风险 M。

## Overall Status

- Current status: `verified`
- Latest round: `docs/reviews/improve-skill-discovery-guidance/2026-10-15-round-03.md`
- Review round: `3`
- Legacy review sources: none
- Archived execution source: `openspec/changes/archive/2026-10-15-improve-skill-discovery-guidance/tasks.md`

## Topic Index

| Topic | Current status | Latest round | First round | Notes |
| --- | --- | --- | --- | --- |
| SDG-001 目标项目实际路径 | verified | [round 03](2026-10-15-round-03.md#sdg-001002--保留已验证行为) | 01 | 管理器同哈希、双宿主异 cwd 路径重跑 |
| SDG-002 行为证据与完成声明 | verified | [round 03](2026-10-15-round-03.md#sdg-001002--保留已验证行为) | 01 | 保留失败路径、原生退出、指纹及基线证据 |
| SDG-003 基线固定 HEAD | verified | [round 03](2026-10-15-round-03.md#sdg-003--基线与移动-head-解耦) | 02 | 使用明确完整提交，可由 BaselineGitRef 指定 |
| SDG-004 基线目录清理 | verified | [round 03](2026-10-15-round-03.md#sdg-004--本次拥有的基线临时产物清理) | 02 | 成功/异常检查后路径集合相同，无新增或扫删 |
| 成功流与双语目标语义 | verified | [round 03](2026-10-15-round-03.md#evidence) | 01 | 双宿主各基线 3/3、行为 9/9；宿主加载仍未确认 |

## Historical Rounds

| Round | Type | Source |
| --- | --- | --- |
| 2026-10-15-round-01.md | re-review，首轮独立代码审查 | 当前 diff、增量规范、实现结果及新鲜聚焦重跑 |
| 2026-10-15-round-02.md | verification，独立修复复验 | 修复结果、源码、双宿主重跑与运行后清理观察 |
| 2026-10-15-round-03.md | verification，独立复验与关闭 | 最终源码/输入哈希、双宿主成功与异常清理证据 |

## Next Actions

- Next action: `close`，当前映射验收 accepted，无下一角色。tasks 1.1–2.3 已完成；累计 verdict=3。
- 能力 C1–C5 仍待后续独立 Task Intake；没有自动归档、Git 操作、发布或部署。

## Archive Record

- Archived on: `2026-10-15`，依据负责人本次归档、提交及发布授权。
- Proposal archive: [已完成提案](../../../openspec/changes/archive/2026-10-15-improve-skill-discovery-guidance/proposal.md)。主规范已合入 3 条新增要求，6/6 tasks 完成。
- Review 01–03 保留原相对路径、发现、输入/日志哈希及历史结论；当前最终状态为 verified/accepted，累计 Review round=3。归档不产生新 verdict。
- 公开前仅将本机仓库、用户临时目录和工具安装路径替换为语义占位符。未修改历史测试结果或声称这些测试已重跑；原始 Review 与原始日志保留在忽略的本地资料中。
- `<repository-root>` 为审查时源码根，`<temp-root>` 为当时临时根，其余工具占位符表示已有可执行文件位置。日志文件名与 SHA256 用于关联原始证据；原始日志不随 Git 或 Release 公开。
- 历史记录中的 `openspec/changes/improve-skill-discovery-guidance/` 已迁至上述 archive；`.ai/` 引用属于私有历史输入，不是公开文件链接。
- 本索引保留批次关闭时的 Next Actions 作为历史；本次归档和发布另行授权。C1–C5 仍为后续需求。
