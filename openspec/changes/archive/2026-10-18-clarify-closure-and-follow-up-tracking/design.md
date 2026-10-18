# Design

## Context

动机及已确认范围见 [proposal.md](proposal.md)，验收行为见 [增量规范](specs/collaboration-package/spec.md)。本设计只处理已选定的关闭依据与追踪入口，不增加产品范围。

已核对的证据与复用点：

| 现状与来源 | 对方案的约束 |
| --- | --- |
| 主规范的 Coherent role routing、Traceable and proportional verification 及 File evidence and result content separation | 保留原路由、累计 verdict 和文件证据分工，不重复全量回归 |
| canonical README Routing Contract、workflows Role Exit Contract、handoff-schema 关闭条款 | 已有 accepted/stopped/superseded、continue + blocked、Chief Designer 限定接受；集中补缺口，不另建关闭协议 |
| validate-runtime-state.ps1 的关闭分支 | 已拒绝普通 accepted 的未完成映射、M/H 实现/修复者自行关闭及 blocked 错误动作；保留这些保护 |
| 同一脚本的 Authoritative Evidence 与 Validate-ImplementationResult | 检查证据路径存在、结果章节形状；不认证退出码、日志内容或输入新鲜度 |
| handoff/response-handoff/implementation-result 模板 | 原有 Authoritative Evidence、Checks Run、Known Risks 可容纳说明与外置记录，不必加字段 |
| OpenSpec 两版 README 及 .gitattributes | 已有双语源码导航，且 openspec 被安装导出排除；事项表放这里，无新增部署目标 |
| 已归档 Phase 0 proposal 的 Non-goals、C1–C5 Review index、v1.9.0 release evidence | 可分别说明关闭规则曾延期、C1–C5 已完成、用户试用/Quickstart 未测，保留历史原文 |

代码定位先使用 codebase-memory 图及源片段；校验器有 partial 覆盖，关闭分支和证据解析另直接核对源码。未发现适用的 docs/solutions 条目；本轮无实现修复学习，现有分层证据规则可复用，无需额外学习文档。

## Goals / Non-Goals

**Goals:**

- 将“先完成交接、校验、记录真实结果、再报告完成”落实为可执行的共享角色规则，证据可与最终输入对应，记录证据不会循环修改交接。
- 在一个现有双语入口区分已交付、待实施、待决定和待验证；详细进度仍归原变更。
- 同一 M 批次完成契约、说明、聚焦演练和独立审阅，避免为每份文档分批往返。

**Non-Goals:**

- 不让只读结构校验器认证事实或成为运行时关闭引擎，不新增强制机器字段、签名、依赖、脚本参数或执行服务。
- 不为历史记录回填证据，不要求每次交接重跑全部用例，不实施索引列出的其他产品工作。

## Decisions

### 1. 最小方案：共享契约约束，保留校验器边界

在 `payload/docs/ai-collaboration/handoff-schema.md#accepted-closure-validation` 新增集中规则，说明普通 accepted 的最终输入、检查结果、证据位置、失败/未执行和过期处理。canonical README 的 Routing Contract、workflows 的 Role Exit Contract 和 agent-prompts 的 Common Preflight 只保留短引用及必要出口提醒。

两份 handoff 模板的关闭提示引用相同规则，回复式 fallback 内嵌示例同步；implementation-result 模板的 Checks Run 注释说明复用该处或既有日志。入口 Skill 已引用这些契约，不为本批改各 Skill 或生成副本。

**不修改 validate-runtime-state.ps1 或其测试脚本。** 新规则是负责角色的行为义务。缺少相符证据的交接仍可能通过现有结构检查，但负责角色不得因此报告普通验收成功；检查实际改动与契约演练必须分别报告这两层结论。独立 Code Reviewer 不能把脚本 exit 0 当作证明角色遵从或日志真实性。

比较的较大方案是：让校验器读取或认证成功日志，或增加强制证据字段。它们会引入日志伪造/自引用、历史迁移和跨模板解析成本，不能仅靠普通文件证明真实性，超过本次收益。集中契约和现有外置证据即可满足已确认的工作流需求；没有必要另建 enforcement 引擎。

### 2. 先固定最终内容，外置记录，避免自引用循环

普通 accepted 的负责角色按以下顺序完成现有出口：

1. 核实映射验收、独立审查、实际累计计数及任务状态。未满足时保持真实下一步；不为了校验勾选未完成任务。
2. 选择已有结果、正式审查记录或本机日志作为证据容器。预先建立真实证据文件/所需章节，标明尚未执行的内容，不能用空文件冒充成功。
3. 完成最终 current-task、任务映射、handoff 的 close/accepted 和证据引用。此时关闭仍待校验，不能向用户宣告已验收；记录相关结构输入的版本或哈希。
4. 对这些最终输入运行现有校验器。记录完整启动命令、实际退出码、诊断/警告和输入对应依据到交接之外的既有证据容器。无需把日志自身加入其哈希清单。
5. 确认对应输入未变，普通关闭只在校验实际成功且其他验收满足时报告。校验后不把结果/时间/哈希写回 handoff；任何影响结论的输入变化都需对受影响输入复验。

最小输入依据包含 current-task 与 handoff，以及本次实际参与结构判断的 tasks、校验脚本、角色/模板等文件的版本、哈希或可核对的不变依据；不要求给全仓库生成清单。日志只追加检查输出时，不改变被校验交接及结构事实，无需再为追加日志重跑。已有 result 的结构章节必须预先有效；追加观察结果若改变了被校验的章节、路径等结构事实，就按真实变化复验。

校验 exit 非零时，保存实际失败，不发布普通 accepted 结论；在当前角色权限内修复、更新最终输入并复验。若无法在本次动作完成修复或缺少环境，先将实际交接改回相符的 continue/dispatch；环境等待只用 continue + blocked 及 Resume condition。只有出现实质负责人决定才用既有 awaiting-owner-decision，不把失败自动变成“以 blocked 关闭”或限定接受。

文档动作没有实施 result 时复用边界日志；审查动作复用其正式证据或日志。不默认新增报告、每轮账本或微步骤交接。

### 3. 兼容、负责人有限接受及回复式降级

旧关闭记录缺少新证据仍按原兼容规则读取，不重开旧批次，不回写历史。新建/正常更新的关闭才遵守新约定；既有验证器字段、退出码和安装兼容性不变。

Chief Designer 的显式有限接受仍用原 `Acceptance basis: owner-decision` 和 `Task Owner decision`。未完成任务、未测项目和负责人处置范围保持原样；一个有效结构不能把缺失技术验收变成 verified。有限接受不豁免 invalid Routing、blocked 不能 close、独立性或累计计数；它不是“校验失败也算通过”的替代写法。

回复式关闭遵守相同原则，明确实际检查对象与 .ai 文件未更新。若允许临时快照，可在受许可的独立目录检查与回复路由及相关输入等义的完整快照，说明快照证据不证明活动 .ai 已持久化。严格只读且没有相符现成依据时，不能借旧 handoff 的 exit 0 声称新回复普通 accepted；以已有 response fallback 记录 continue + blocked 及恢复写入/检查条件，真实业务决定仍遵循原负责人出口。不能为取得证据绕过只读限制。

### 4. 轻量事项表与双语说明

只在 `openspec/README.md` 和 `openspec/README.zh-CN.md` 增加对应的短表及状态释义：

| 中文状态 / 英文状态 | 含义 |
| --- | --- |
| 待决定 / Pending decision | 尚未选定实施，不是承诺 |
| 已确认待实施 / Confirmed, pending implementation | 已选定范围，具体任务以对应活动变更为准 |
| 待验证 / Pending validation | 缺少指定验证证据；不表示已批准开展招募或外部操作 |
| 已完成 / Completed | 对应范围有已完成任务和验收/审阅证据 |

最初只记录以下概况，不细化为第二清单：

| 事项 | 初始状态及可公开依据 |
| --- | --- |
| C1–C5 交接能力 | 已完成；链接已归档变更及 `docs/reviews/add-handoff-capability-guidance/index.md` |
| 关闭依据及追踪入口 | 已确认待实施；链接本变更。直到本批映射验收及独立审查满足后才改为已完成 |
| 自包含演示样例 | 待决定；负责人讨论的路线规划建议；链接已归档 Phase 0 proposal 的排除范围，说明此链接证明未纳入该批，不假称它包含完整路线图 |
| Phase 0/G0 外部试用 | 待验证，尚未开展；负责人讨论的阶段目标；包检查不代表外部试用，启动仍需另行选定 |
| Quickstart 排错和全链路操作 | 待验证；链接 `docs/reviews/release-1.9.0.md` 的明确未测范围 |
| Phase 1–3 | 待决定；仅路线规划，需按最新试用事实另选范围，无虚构提案或任务号 |

私人路线图不在公开仓库，来源可用中英文短摘要诚实说明“负责人讨论的外部规划，未随仓库发布”，不能伪造可点击仓库路径，也不复制私有目录或全文。两版表保持同样事项、证据与状态。不为没有独立记录的事项建立虚构 OpenSpec。

根两版 README 只补关闭规则与源码事项入口的短说明；源码入口使用公开仓库相应语言导航的 URL，不使用导出包内不存在的 openspec 相对路径。安装后用户的双语 operator-guide 仅说明关闭检查及有限接受，不依赖源码专属路径。两版 CHANGELOG 在实施实际发生后写 Unreleased，不把本次规划标为功能已完成。不改历史 Review 的 Next Actions 或归档 proposal。

### 5. 可行性、首个结果与精确验证边界

可行性结论：**proceed**。所需章节、模板、证据容器和双语导航均已存在；外置证据的内容不被现有校验器认证，因而无需递归读取成功日志。未知只在 Agent 实际是否遵循，明确作为限制，不建设超范围的宿主评测。无需额外 spike。

首个可展示结果：一份清楚标记为演练的最终关闭交接，用户能从其短引用追到与输入对应的真实校验记录；同一次查看能在导航分清 C1–C5 已完成、样例未立项和外部试用待验证。它不冒充真实业务验收。

实施阶段用一个独立、经绝对路径核对的 GUID 结构夹具，复制当前规范及自造的任务/交接。源码没有 docs/ai-collaboration，夹具内将 canonical agent-prompts/templates 同字节置于对应 docs 路径以满足原角色检查；不安装到源码，不用真实项目数据或旧私人批次作夹具。记录源/夹具输入对应、命令、退出码及诊断。

仅执行这些受影响检查：

- 最终合法关闭运行真实校验，向外置证据追加输出后确认交接哈希不变；改变一个真正影响结构结论的输入，说明旧记录不可复用并复验。
- 一份实际无效交接收到 exit 1，按规则修复复验或保留可恢复下一步；“未运行”“证据过期”以明确标记的契约演练核对，不能声称原校验器会自动拒绝缺证据。
- continue + blocked 保留恢复条件且不能 close；负责人有限接受保留真实未完成映射，普通 accepted 仍拒绝未完成映射，M/H 实现者不能自行 accepted。
- 旧缺新增说明的有效交接仍可读；回复式分别覆盖允许快照和严格只读，保证未持久化提示与实际对象一致，不伪称脚本验证了聊天正文。
- 检查双语事项/状态/链接、无私人路径和无第二实施清单，README/指南/CHANGELOG 内容对应；运行 OpenSpec 严格检查及差异/空白检查。

这些是模板、流程和结构兼容验证，不能把手写期望的演练当作宿主遵从证明。不为文案新增关键词断言测试；脚本不改，不重放其全套历史测试、安装全套或模型评测。

可用命令：`openspec validate clarify-closure-and-follow-up-tracking --strict`、`git diff --check`，以及独立 PowerShell 子进程运行 canonical `validate-runtime-state.ps1 -WorkspaceRoot`，具体夹具路径记录在实际日志。本机 CLI 不在 PATH 时使用已核实的绝对启动器，不更改全局 PATH。

### 6. 文件映射、批次与审查决定

| 对应路径 | 实施用途 |
| --- | --- |
| payload/docs/ai-collaboration/handoff-schema.md | 集中关闭依据规则及回复式说明 |
| 同目录 README.md、workflows.md、agent-prompts.md | 共享出口短引用，保持角色职责 |
| 同目录 templates/handoff.template.md、response-handoff.template.md、implementation-result.template.md | 条件提示和证据复用，不增机器字段 |
| 同目录 operator-guide.md、operator-guide.zh-CN.md | 人类关闭检查说明，不依赖源码专属路径 |
| openspec/README.md、README.zh-CN.md | 源码追踪表，不改安装导出 |
| 根 README.md、README.zh-CN.md、CHANGELOG.md、CHANGELOG.zh-CN.md | 最少双语公开说明及实际 Unreleased 记录 |

上述是路径职责，不是第二实施清单；唯一 checklist 为本变更 tasks.md。

保持批次 `engrelay-closure-tracking-20261018-01`、风险 M、累计 Review round=0。所有紧邻项组成一个可验收的证据可查/待办可辨结果，预计一个实施会话。无复杂性例外或无法展示的基础批次，Design Review 决定 **no**；这不是设计审查 verdict，不消耗计数。下一角色 Implementation Engineer，随后必须由未参与实现的独立 Code Reviewer 聚合审查；需要修复/复核时延续原计数，默认自主额度总计三次。

## Risks / Trade-offs

- [规则仍依赖 Agent 遵从] → 明确工具只查结构，独立审阅实际契约和证据；不宣传为强制运行保障。
- [记录成功又改交接，引起证据循环失效] → 最终交接预先引用真实容器；只在外置证据保存实际结果，相关结构变化才复验。
- [缺环境或严格只读导致无法普通关闭] → 允许现有合法快照/证据复用；确无依据时保留可恢复 blocked，而不虚构成功或绕过权限。
- [负责人接受被误当技术通过] → 原限定接受字段、未完成任务及 Known Risks 保留，结构与业务验收分别陈述。
- [追踪表漂移或范围扩大] → 表内只存状态/来源/链接；任务仍归原 tasks，待定/待验证不授权行动，关闭时由现负责角色同步概况。
- [维护/token 增量] → 一份集中规范、两份短表和出口引用，交接只增加证据短引用，不默认新增报告、循环或人工批准。

## Migration Plan

无历史运行态或安装算法迁移；开发时只改 canonical 契约及对应文档。源码导航仍按现有 export-ignore 排除；未来获准发行后才在干净 staging 重建完整 snapshot，并按官方 Upgrade 分发。

回退仅撤回本批候选契约/文档改动，不覆盖已发布包、标签、原 Review 或历史归档。已有交接按旧兼容契约继续可读。归档、Git 提交/推送、发布与真实部署须有各自适用请求。
