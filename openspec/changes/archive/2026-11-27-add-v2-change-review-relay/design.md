# Design: add-v2-change-review-relay

## Context

EngRelay v2（`2.0.1`）已通过双车道复用、固定五行 `Next Step` 推荐卡与 `.ai/relay/CURRENT` 解决了 WP 级执行循环的跨平台交接。但在真实工作流中，OpenSpec 变更还存在两个高频跨平台审查场景：
1. **`plan` 前的 OpenSpec 提案审查**：例如 Codex/Antigravity 起草完 `proposal/specs/design/tasks` 后，交由另一平台审查并在修订反馈后复审。
2. **`plan/do/review WP` 收口或整单实施完成后的整单实施审查**：例如所有 WP 完成（或一次性直出实现）后，归档、Git 提交与发版前的整单交叉审查与修复核对。

目前缺少内置子命令与固定落盘约定，用户每次只能自己拼装长提示词，并反复粘贴带日期的文件名（如 `.ai/review-xxx-2026-11-25.md`）与消息正文。

## Goals / Non-Goals

- **Goals**:
  - 在现有统一 `engrelay` Skill 中新增 `review proposal` / `fix proposal` 与 `review change` / `fix change`，使用固定路径且无需复制对话正文即可跨平台无缝接力。
  - 严格复用 v2 既有安全基线：写白名单隔离、独立性强制（可复用未污染审查会话）、追加式累计历史、两轮硬熔断、`(a)` / `harness` 恢复门禁、固定提案身份 5 行 `Next Step` 卡及 `CURRENT` 单次调用锁定。
  - 扩展 `doctor.ps1` 只读识别有效 `plan` 前变更审查指针（不写任何文件，严格 `Safe-Path` 防重解析点/路径穿越）。
- **Non-Goals**:
  - 不新增独立 Skill 文件（保持 v2 `10` 文件固定投影不变，不改动 `manage.ps1` 或 `update-snapshot.ps1`）。
  - 不引入跨平台自动消息总线、后台 daemon、自动 `git commit`/`push`/`openspec archive`/`release`。

## Decisions

### 1. 命令语法与固定追加式报告路径

在统一 `engrelay` Skill 下增加 4 个动词-对象子命令，与现有 `plan <change-id>`、`do [<change-id>] <WP-XX>`、`review [<change-id>] <WP-XX>` 完全正交无歧义：

| 子命令 | 适用阶段 | 固定报告文件 | 核心职责 |
| --- | --- | --- | --- |
| `review proposal [<change-id>]` | `plan` 前 / 提案修订后 | `.ai/relay/<change-id>/review-proposal.md` | 独立审查 `openspec/changes/<id>/*` 并结合相关源码/现有规范核对一致性与风险 |
| `fix proposal [<change-id>]` | `review-proposal.md` 为 `FIX REQUIRED` 或已获 `(a)` | `.ai/relay/<change-id>/review-proposal.md`（追加反馈） | 严守规划边界，逐条核对修订 `openspec/changes/<id>/*` 并追加反馈；**不改产品代码** |
| `review change [<change-id>]` | 实施后 / 归档前 | `.ai/relay/<change-id>/review-change.md` | 独立审查相对基线/未提交的完整变更、OpenSpec 符合性、文档同步及实测证据 |
| `fix change [<change-id>]` | `review-change.md` 为 `FIX REQUIRED` 或已获 `(a)` | `.ai/relay/<change-id>/review-change.md`（追加反馈） | 核对并修复确认缺陷、运行针对性验证、同步 `tasks.md`/文档并追加反馈 |

- **追加式不可变历史与跨层级继承（R1）**：
  - 报告结构固定按轮次向下追加（`## Round 1` → `## Revision Feedback (Round 1)` → `## Round 2` → `## Recovery / Owner disposition` → `## Round 3 (Bounded (a))` 等）；禁止删改前轮结论、累计 verdict 计数与失败签名。
  - **WP ↔ 变更级未完成映射验收双向累计规则**：`review change` / `fix change` 与既有 `.ai/relay/<id>/board.md`（`Progress Ledger`）/ `wp-XX.md` 按**同一未完成映射验收**（OpenSpec `tasks.md` 条目/规范条款及实际失败签名）双向关联：
    - 若某未完成映射验收已在既有 WP 中两轮 `[~] blocked` 且无明确 `(a)` 授权：首次 `review change` 可核验证据并记录报告，但必须在 `review-change.md` 显式继承该 WP 的累计 verdict 与阻塞状态（标为 `[~] blocked` / 未获授权，`Next Step` 输出 `Command: Wait`），**不得借新建 `review-change.md` 开启新的两轮自治修复额度**；未获 `(a)` 时 `fix change` 拒绝修复该项。
    - 反向同理：若 `review change` 因某未完成映射验收进入 `[~] blocked`（无 `(a)` / `harness` 未恢复），切回对应 WP 执行 `do` 同样必须继承该限制并拒绝绕过。
    - **区分不误合并边界**：提案审查（`review-proposal.md`）与实现审查（`review-change.md`）分属不同阶段；同一变更下彼此独立的不同 OpenSpec 验收条目，或已关闭验收后续出现的新问题，按实际映射分别计录，不仅因 `<change-id>` 相同就一刀切封死无关条目。
- **零日期文件名消除了人工记忆路径**：固定文件名取代 `.ai/review-<change>-<date>.md`，跨天、跨平台切窗只需记住 `review proposal` / `fix proposal` / `review change` / `fix change`。

### 2. 封闭写权限矩阵（延续双车道不污染）

| 模式 | `.ai/relay/<id>/review-*.md` | `.ai/relay/CURRENT` | `openspec/changes/<id>/*` | 产品源码 / 测试 / 人类文档 | 提交 / 归档 / 发版 |
| --- | --- | --- | --- | --- | --- |
| `review proposal` | 允许（追加） | 仅显式 `<id>` 或唯一合法回退 | **禁止写入** | **禁止写入** | **禁止** |
| `fix proposal` | 允许（仅追加反馈段） | 仅显式 `<id>` 或唯一合法回退 | **允许**（规划修订） | **禁止写入** | **禁止** |
| `review change` | 允许（追加） | 仅显式 `<id>` 或唯一合法回退 | **禁止写入**（含 `tasks.md`） | **禁止写入** | **禁止** |
| `fix change` | 允许（仅追加反馈段） | 仅显式 `<id>` 或唯一合法回退 | 仅允许在修复确认后更新受影响文档/`tasks.md` | **允许**（仅限确认需修范围） | **禁止自动执行** |
| `doctor.ps1` | 只读 | **严格零写入** | 只读存在性 | 只读 | **禁止** |

与 WP `review` 一致：在 `review proposal` / `review change` 会话中即使收到用户的 `(a)` 有限追加轮次指令，审查会话也**仅追加记录授权状态并停止**，不得越权代改提案或代码。

### 3. 两阶段只读解析与“准入后写 `CURRENT`”边界（R2 & R3）

- **阶段 1：只读目标变更身份解析（绝不以 `review-*.md` 是否存在过滤候选）**：
  - **目标身份锚点（Target Identity Anchor）**：
    - WP 命令（`do <WP-XX>` / `review <WP-XX>`）：存在 `.ai/relay/<id>/board.md`。
    - `review proposal` / `fix proposal`：存在活动变更目录 `openspec/changes/<id>/`（排除 `archive/`）。**注意：`fix proposal` 的目标识别不要求先存在 `review-proposal.md`。**
    - `review change` / `fix change`：存在活动 `openspec/changes/<id>/`（排除 `archive/`）或已有 `.ai/relay/<id>/board.md`。**注意：`fix change` 的目标识别同样不以 `review-change.md` 是否存在过滤目标。**
  - **身份解析优先级（全程单次调用锁定 + 首行 `Change: <id>` 回显）**：
    1. 显式 `<change-id>`：只读核验该 `<change-id>` 格式与当前命令目标身份锚点即整次调用锁定；身份不存在直接零写入报错停止。
    2. 省略 `<change-id>` 且 `.ai/relay/CURRENT` 对当前命令目标身份锚点有效：立即锁定该 `<change-id>`（即使该提案尚缺 `review-*.md` 也锁定之，绝不跳去别的提案；即使并存多个其他有报告的提案亦不覆盖）。
    3. **仅当** `.ai/relay/CURRENT` 缺失或指向非活动变更（如已归档/已删除）时，只读扫描满足当前命令目标身份锚点的活动候选：恰好 1 个时暂定为选中候选；0 个或 ≥2 个时列出候选清单（或提示先建提案）后严格零写入停止，禁止盲猜。

- **阶段 2：只读前置准入检查（`fix` / 恢复门禁先检后写）**：
  - 在目标 `<change-id>` 锁定之后、任何磁盘写入（包括更新 `.ai/relay/CURRENT`）之前，只读检查执行前提：
    - 对 `review proposal` / `review change`：检查目标权威存在、未触发越权写操作。
    - 对 `fix proposal` / `fix change`：读取对应 `review-*.md` 与关联的 `board.md`/`wp-XX.md` 累计历史（按 R1 映射规则）：
      1. 报告缺失 → 零写入停止，提示先运行 `review proposal|change <id>`。
      2. 最新已完结轮次已为 `PASS` 且无待修复项 → 零写入停止，提示进入下一步（`plan` 或归档/收口）。
      3. 处于 `[~] blocked`（本报告第 2 轮阻塞或继承自既有 WP 同验收两轮阻塞）：若为 `product`/上限且无已记录或本次用户显式确认的 `(a)` 有限追加授权，或为 `harness` 且未核验恢复条件 → **零写入拒绝绕过**，输出 `Command: Wait` 的 `Next Step` 卡并停止。

- **阶段 3：准入通过后的受限写入**：
  - **只有当阶段 1 与阶段 2 全部通过时**，才允许按需将锁定的 `<change-id>` 写入 `.ai/relay/CURRENT`（显式 `<id>` 或唯一活动变更回退补写）并执行本命令写白名单内的操作（例如更新提案/源码/追加反馈）。任何被阶段 1 或阶段 2 拒绝的调用均保持 `.ai/relay/CURRENT` 原始字节（或不存在状态）及全部文件 100% 不变。

- **`doctor.ps1` 只读核验扩展**：
  - 先用 `Safe-Path` 核验所有 `.ai/relay/*/review-proposal.md` 与 `review-change.md`（存在时拦截重解析点与路径逃逸）。
  - 校验 `.ai/relay/CURRENT` 文本格式与路径安全边界后按序判断：
    1. `.ai/relay/$id/board.md` 存在 → 输出 `Active relay change=$id (valid)`（`exit 0`）。
    2. 否则用 `Safe-Path` 校验 `openspec/changes/$id` 目录存在且 `.ai/relay/$id/review-proposal.md` 或 `review-change.md` 存在（全部非重解析点） → 输出 `Active relay change=$id (valid: change review, no board yet)`（`exit 0`）。
    3. 否则 → 输出 `Active relay pointer stale: $id (board.md missing)`（`exit 0`，完全兼容已有失效指针用例与语义）。
    4. 任何格式非法、`..`、路径分隔符、冒号、重解析点或越界 → 抛出错误（`exit 1`，严格零写入）。

### 4. 熔断、`(a)` 前置防绕过与 5 行 `Next Step` 路由

- **`fix` 执行前置校验与跨层级传承**：运行 `fix proposal` / `fix change` 时必须在阶段 2 同时校验对应 `review-*.md` 状态与（对 `fix change`）既有 `board.md`/`wp-XX.md` 上同一未完成映射验收的累计状态：
  - 若报告缺失、已 `PASS` 或存在未授权/未核验的 `[~] blocked`（含继承阻塞）→ 阶段 2 零写入停止（不写 `CURRENT`，不改任何文件），输出 `Command: Wait` 的 `Next Step` 卡。
  - 若本次用户指令或报告/WP 记录内明确存在 `(a)` 有限追加授权 → 在保留双方原累计计数的前提下执行修复与验证，并追加 `Revision Feedback`。
- **5 行固定 `Next Step` 出口映射**（所有跨会话可复制命令固定携带 `<change-id>`）：

| 当前模式与结论 | `Primary` | `Command`（`Wait` / `none` / 固定命令） | `Gate` | `Alternate` |
| --- | --- | --- | --- | --- |
| `review proposal` → `FIX REQUIRED` / 已确认 `(a)` | 提案修订会话（`fix proposal`） | `fix proposal <change-id>` | 重审需在原未污染审查会话确认 | `none`（或说明切回提示） |
| `review proposal` → 未授权 `[~] blocked` / 未恢复 `harness` | 等待 `(a)/(b)/(c)` 或核验环境 | `Wait` | 未决裁决或未核验环境条件 | `none` |
| `fix proposal` → 完成修订 | 原只读审查会话（`review proposal`） | `review proposal <change-id>` | 复审仅核对阻塞项与修复引入冲突 | `none` |
| `review proposal` → `PASS` | 进入 WP 拆包或人工确认实施 | `plan <change-id>`（`plan` 前已通过） | 进入拆包或按任务授权直接实施 | `none` |
| `review change` → `FIX REQUIRED` / 已确认 `(a)` | 实施修复会话（`fix change`） | `fix change <change-id>` | 修复后需原审查会话独立复核 | `none` |
| `review change` → 未授权 `[~] blocked` / 未恢复 `harness` | 等待 `(a)/(b)/(c)` 或核验环境 | `Wait` | 未决裁决或未核验环境条件 | `none` |
| `fix change` → 完成修复与验证 | 原只读审查会话（`review change`） | `review change <change-id>` | 复核修复证据与回归影响面 | `none` |
| `review change` → `PASS` | 负责人确认归档/提交/发版 | `none` | 全部确认门禁通过（不自动归档/提交） | `none` |

### 5. 150 行核心预算评估

当前 [RULES.md](../../../../payload/docs/ai-collaboration/v2/RULES.md)（48 行）+ [SKILL.md](../../../../payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md)（41 行）合计 **89/150 行**。将上述四个变更级子命令、写白名单、追加式记录及 `CURRENT` 锚点规则以原则驱动语言合并到 `RULES.md` 与 `SKILL.md` 预计增加 `26–38` 行，合计控制在 **115–128 / 150 行**，仍为 150 行硬上限留出 20+ 行余量；`agent-rules.md` 保持 `10/18` 行不变。

## Risks / Trade-offs

- **同时存在 WP 看板 A 与预规划新提案 B（或 A 缺报告而 B 有可修报告）时**：
  - 缓解：① 每张生成的 `Next Step` 卡一律携带显式 `<change-id>`，不会被他会话更新 `CURRENT` 误导；② 严格拆开“目标变更身份”与“`fix` 报告/授权前置”——身份有效但缺报告直接在 A 零写入停机，绝不借回退误改 B；③ 仅当阶段 1 身份与阶段 2 准入全过时才写入 `.ai/relay/CURRENT`，确保拒绝路径不污染后续手工简写默认目标。
- **跨 WP 与变更级 `review change` 同一验收反复切换**：
  - 缓解：双向绑定未完成映射验收的累计 verdict 与失败签名（而不粗暴绑定 `<change-id>` 整体），既堵住借新报告刷预算漏洞，又不误杀同提案下独立的其余验收或前序提案阶段审查。
- **`RULES.md` + `SKILL.md` 接近 120+ 行后需防冗余**：
  - 缓解：共享两条既有原则（独立性/两轮熔断、5 行卡结构），只定义增量写白名单、报告文件名、跨层级验收继承与准入前零写入顺序，不重复抄写整段 WP 规则。
