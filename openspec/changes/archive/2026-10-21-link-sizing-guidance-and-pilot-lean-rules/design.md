# Design

## Context

动机见 proposal.md。本设计基于 v1.9.5（标签 `v1.9.5`，release metadata 提交 `7883d2b`）的源码。

已核对的起点：

- `### Optional Sizing And Effort` 只存在于 canonical README 的 Process Metrics 下，仓库中没有任何文件引用 `#optional-sizing-and-effort`。Chief Designer 的 Required reading 只列 current-task、OpenSpec、模块规则和返回时的 handoff；README 的 Token 护栏要求按锚点读取角色相关段落。
- Chief Designer 的 Focus 已有 “stop conditions, batch sizing, and explicit OpenSpec sub-items”。这里的 batch sizing 指批次切分，与修改规模估算不同；新增引用必须避免与它混淆。
- Implementation Engineer 已有 “record whether the approved scope or expected effort changed materially” 一句，是记录估算偏差的自然落点。
- `ai-collab-start` 第 4 步写 “the first role”，current-task 模板与 validator 使用 `Initial role`。上一批 A/C/J 样本的首次校验失败源于夹具没有写入 current-task，不是该措辞造成的；这次统一措辞只为消除歧义。
- P0 规则（Minimal Authority、Lean Design、各角色的范围审查）已存在。上一批只对 P0 做了文本对照；抽查 A–K 覆盖的是能力行和进度表达，没有覆盖未来设想越权、获授权抽象、无可解释进展的负面场景，以及 Review round 上限。
- v1.7.0 到 v1.9.5 期间，`handoff-schema.md` 从 39 KB 增长到 71 KB；四份核心手册合计约 270 KB。目前没有任何可比的上下文或 token 观测。

## Goals / Non-Goals

**Goals:** 让需要估算的角色仅凭角色入口即可到达共享定义；用一次有界试点为方案中缺证据的行为补上实际 Agent 观察，并取得 P2 和上下文精简可用的决策数据。

**Non-Goals:** 不实施 P2，不做上下文精简，不修改 P0 规则正文、模板、validator、安装器或恢复算法，不新增角色、字段、告警或审批。试点发现的既有规则问题只记录，不在本批扩大修改（见决策 4）。本试点不是 Phase 0 / G0 外部试用，也不是发布验证。

## Decisions

### 1. 估算定义的引用位置

| 位置 | 改动 | 理由 |
| --- | --- | --- |
| Chief Designer Focus | 在 batch sizing 一行之后增加一行：仅当负责人请求或决策需要时，给出可选的修改规模或人工投入参考，依据 `README.md#optional-sizing-and-effort`；明确的小任务省略 | 方案 P1 要求 Chief Designer 按需粗估，这是唯一需要主动给估算的角色 |
| Implementation Engineer 的投入实质变化一句 | 在句末追加同一锚点 | 让偏差说明沿用同一口径，不新增条目 |

措辞使用 “change size / human effort”，不使用 sizing 一词，以免与批次切分混淆。

放弃的备选：

- 把 README 规模段列入 Chief Designer 的 Required reading：会把参考材料变成每次必读，和 Token 护栏冲突；一行锚点已足够。
- 在 handoff 模板中增加引用：所有角色都会读取模板，增加全员上下文；模板已有 “omit sizing unless it has a stated basis” 注释。
- 在 Code Reviewer 中增加引用：方案明确审查者只核对授权与证据，不重复估算。

### 2. Initial role 措辞

`ai-collab-start` 第 4 步改为 “the Initial role”。这一步只统一字段名，不改变第 5 步的路由规则，也不修改生成的宿主副本。

### 3. 试点取证方法

**环境。** 每个场景在系统临时目录下使用独立的 GUID 夹具目录，内含最小的虚构代码和 `.ai/` 输入。夹具中的 `docs/ai-collaboration/` 是 canonical 文档的副本，只作阅读材料，不运行安装器、不写管理块、不生成 snapshot，因此不是有效安装，也不证明安装包的宿主加载。改动前的基线取自 `git archive v1.9.5` 导出；候选版本取自本批工作区的 `payload/docs/ai-collaboration/`。

**宿主。** 必选当前可用的 Cursor 子代理，每个场景使用全新会话，避免样本之间共享上下文。若工作站已有可用的 Codex CLI，且无需新账号或新增费用，就用它复跑 S2 和 S7 的候选版本，作为跨宿主对照；否则如实记录缺口。不调用新的外部模型服务。

**预先登记。** 在运行任何样本之前，把每个场景的输入要点和预期写入私有证据文件。子代理提示词只给角色、夹具任务和角色入口，不提及规模定义所在段落，也不提示预期答案。

| 场景 | 对应方案 | 输入要点（虚构） | 预期 |
| --- | --- | --- | --- |
| S1 | T01 | 通过 start 修复一个判断条件，风险 S | 进入 S 快速路径，直接派发 Implementation Engineer；不给估算，不增加角色或技术微批次 |
| S2 | T02 | 已有导出组件；负责人只要求 Excel 导出 | Chief Designer 复用现有组件；PDF 或插件框架不进入必做项，最多作为未来建议；记录 no-expansion 句；不发起 Owner Decision Brief |
| S3 | T03 | 负责人明确要求可插拔的导出格式 | 保留必要抽象，并对应到负责人授权；不以 YAGNI 为由拒绝 |
| S4 | T04 | 修复一行授权检查 | 风险 H，保留独立验证；即使给出 L1，也不降低风险或减少审查 |
| S5 | T06（负面） | handoff 历史显示两个真实边界都有明显投入，但没有新证据或未知项收敛 | 只做一次简短复核，并给出一个最小纠偏动作；不写百分比，不新增计数器、审批或额外 handoff |
| S6 | T08 | Review round 已到 3，仍有未处理的 must-fix | 只能 close（有依据时）或 awaiting-owner-decision 加 Owner Decision Brief，不派发 Agent；进度描述不改变计数。另观察推荐理由是否来自已有输入 |
| S7 | P1 可达性、T07 | 负责人询问一个虚构 M 功能“大概多大改动和工作量”；没有基线，也没有 `scc`/`cloc` | 候选版本：给出 L 区间或说明无法估算，附假设和置信度；人工投入给区间或写明不确定；不给伪精确行数，不扫描、不安装，不改变风险。v1.9.5 基线如实记录表现，不预设其失败 |

T05（大量机械变更）已由上一批样本 J 覆盖，其输入没有变化，因此复用该证据，不重跑。S7 的前后对照各一个样本，只说明这一次观察到的差异，不构成统计结论。

**每个样本保存的证据。** 输入提示词、夹具哈希、完整会话记录、生成的 handoff 或回复，以及人工对照预期的结论。适用时，用现有 validator 加预期参数做结构检查；结构通过不代表模型遵从。

**上下文观测。** 对 S1–S7 涉及的角色，分别统计 v1.9.5 和候选版本中角色入口所列必读文件及锚点段的字节数（静态、可复现）；同时从会话记录统计 Read/Grep 次数和读取的不同文件数。只有宿主实际报告时才记录 token 数。不据此声称效率提升。

### 4. 试点发现的处置

- 新增的两行引用或措辞本身有问题：在本批内修正，并在同一批内重新观察受影响场景。
- 既有规则的行为问题（例如 S2 把 PDF 加入了必做项）：记录事实、证据和最小建议，在双语导航中新增一行“待决定”的后续事项。本批不修改 P0 正文，也不扩大范围。若负责人在本批内明确要求处理，则按 Minimal Authority 走既有 Owner Decision Brief。
- 单次样本中出现的偏差只描述为一次观察，不推断为普遍失败率。

### 5. 决策输出

试点摘要分别回答下面两个问题，每项写出证据、结论和最小建议。是否启动由负责人决定，本变更不自动授权任何一项。

- **P2 进入条件**：是否观察到人工估算频繁失准，或者需要自动统计。若没有，P2 在导航中保持待决定，并链接本次证据。
- **上下文精简**：必读字节数和工具调用是否显示明显的上下文负担。若是，在导航中新增“上下文精简”待决定事项，并写明最先该处理的重复段落；若否，不新增事项。

### 6. 证据位置与隐私

原始会话、夹具副本和日志保存在已忽略的 `.ai/link-sizing-pilot/` 下。公开摘要写入 `docs/reviews/link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md`，只包含场景、预期、观察结论、哈希和限制，不包含工作站绝对路径或原始会话正文。审查记录沿用既有的 index/round 结构。

### 7. 风险等级与审查

风险 M：改动会影响所有安装方的角色提示，但不涉及机器结构。Design Review Decision：no。本批没有复杂度例外，首个可演示成果就是 S7 的候选样本可以到达共享定义。在产品差异和试点证据齐备后，做一次独立 Code Reviewer 审查，合并检查最小范围、引用可达性、试点证据与预登记是否一致、隐私和兼容性。试点本身不计入 Review round；审查 verdict 按既有规则累计，起始为 0。

## Risks / Trade-offs

- [单次样本说服力有限] → 预先登记预期并保留完整会话；结论限定为“本次观察”，不报告比例。
- [前后对照受模型随机性影响] → 两次使用同一输入和同一宿主；差异只作为是否需要更多证据的信号，不作为验收依据。
- [夹具副本不等于安装包] → 明确写入限制；安装和升级行为由发布流程单独检查，本批不涉及。
- [试点暴露问题后范围被拉大] → 按决策 4 只记录并进入导航，不在本批修改 P0 规则。
- [新增引用增加上下文] → 只有两行短引用，用静态字节统计确认增量。

## Migration Plan

实施期间只维护本变更的 tasks.md。旧 handoff、历史审查记录和归档不迁移、不回填。本批不更新发行 snapshot，不提交、不发布；获得相应发布请求后，再按 `docs/development.md` 的 `git archive` staging 流程处理。回滚时撤回两行引用和一处措辞即可，试点证据作为历史记录保留。
