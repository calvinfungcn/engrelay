# Design: refine-v2-relay-ergonomics

## Context

EngRelay v2（`2.0.0`）已建立 `plan` / `do` / `review` 三模式、正交风险（`S|M|H`）与能力/体量（`C1–C5 × XS|S|M|L`）评估、≤15 行断点及两轮硬断路器。但在实际跨平台、涉及多个仓库的提案高频执行中，仍出现三项人机交互摩擦：
1. `review` 会话在收到用户授权回复（例如 `(a)` 追加轮次）后在同会话顺手改代码，导致该审查会话失去独立性、不得不持续开启第 3 个会话。
2. 每次模式完成后需要人工翻看 `board.md` 才能判断下一个可执行 WP 的命令、难度、体量与平台档位。
3. 单提案连续执行时每次 `do`/`review` 均需重复键入完整 `<change-id>`。

本设计在严守“核心规则 ≤ 150 行、原则驱动、无运行时调度引擎、不改 `manage.ps1` 所有权模型”的前提下解决上述三点。

## Goals / Non-Goals

- **Goals**:
  - 固化“实施/修复车道（`do`）↔ 只读审查/验证车道（`review`）”双会话复用边界，禁止 `review` 会话改动业务代码或测试文件。
  - 为每次 `plan`、`do`、`review` 退出提供统一、紧凑（4–6 行）且不越权的 `Next Step` 推荐卡。
  - 通过单行 `.ai/relay/CURRENT` 指针支持安全、可回显、无歧义的命令简写（`do WP-XX` / `review WP-XX`），并在 `v2/scripts/doctor.ps1` 增加只读安全核验。
- **Non-Goals**:
  - 不新增第 4 种模式、自动派发 daemon 或跨会话脚本调用。
  - 不改变 `scripts/manage.ps1`、`scripts/update-snapshot.ps1`、`workflow-profiles`、`full` 或 `lite`。
  - 不取消独立性要求、两轮硬断路器或人工接力边界。

## Decisions

### 1. 严格禁改业务代码的 `review` 写入白名单与双车道复用

- **写权限硬边界**：
  - `review` 模式**只读**所有产品源码、配置与测试文件；可写集合统一且严格限定为以下三类：
    1. `.ai/relay/<change-id>/`（当前目标变更的 `board.md` 与 `wp-XX.md`）。
    2. `.ai/relay/CURRENT`（**仅限**活动目标选择元数据：即本次显式传入 `<change-id>` 的 `review`，或指针缺失/失效且仅存在唯一有效看板时简写 `review <WP-XX>` 的合法补写；不得写入其他共享运行态，未激活任务与 `doctor.ps1` 严格禁止写入）。
    3. 映射验收完全满足时勾选 OpenSpec `tasks.md`。
  - 若 `review` 返回 `FIX REQUIRED`，或在 `[~] blocked` 下用户在审查会话回复 `(a)` 有限追加轮次授权：审查会话仅在 `wp-XX.md` / `board.md` 落盘审查结果或授权记录（保持原累计 verdict 与失败签名不变）并立即停止，明确拒绝在当前会话改代码。
- **`do` 模式承接修复与断点并重**：
  - 当实施/修复会话再次收到 `do <change-id> <WP-XX>`（或通过指针解析 `WP-XX`）时，除读取 `Checkpoint`（若有）外，同时读取 `wp-XX.md` 中最新 `Review / Verification` 记录的未解决 `BLOCKER` 列表与已记录授权范围，在原实施/修复会话集中修复并重跑验证，随后交回**同一未污染的 `review` 会话**完成 Round 2 或追加轮次复核。
- **收益**：用户只需长期保持两个会话窗口（例如 Codex 跑 `do` / fix，Antigravity 跑 `review`），只要两会话各自严格守住“实施改码 / 审查只读”职责分离，即可天然满足独立性而无需不断开新窗口。

### 2. 每次模式结束的 `Next Step` 推荐卡（4–6 行）

在 `plan`、`do`、`review` 结束时按退出状态输出唯一明确首选动作的紧凑 `Next Step` 卡（纯建议，不自动执行下一角色、不自授额外轮次，并行备选均显式标为条件性或备选；**所有生成的跨会话可复制命令一律固定携带 `<change-id>`**，避免被其他会话覆盖 `CURRENT` 后误操作）：

| 当前退出状态 | 唯一首选动作（Target / Primary） | 推荐命令、携带信息与禁止事项 |
| --- | --- | --- |
| `plan` 完成 | 切至执行会话（按难度/体量选平台） | 首选依赖就绪 WP 的 `do <change-id> <WP-XX>`、Risk、Difficulty、Size/Rhythm、审查门禁（并行就绪项标为可选备选） |
| `do` 写入 `Checkpoint` | 换额度充足会话续跑 `do`（不触发 `review`） | `do <change-id> <WP-XX>` + 剩余体量/难点提示 |
| `do` 完成且有 `M`/`H`/显式门禁 | 切至独立 `Review` 会话（可复用未改码审查会话） | `review <change-id> <WP-XX>` + Risk、Difficulty、Size/Rhythm、要求范围（审查 / `H` 独立验证） |
| `review` 给出 `FIX REQUIRED`（预算内） | 切回实施/修复会话（勿在审查会话改码） | `do <change-id> <WP-XX>` + 需修 `BLOCKER` 摘要 + 提示修完切回当前 `review` 会话 |
| `[~] blocked` 已获确认 `(a)` 有限追加授权 | 切回实施/修复会话执行已授权范围 | `do <change-id> <WP-XX>`（保留原累计计数，**不重复索要批准**）+ 提示修完切回当前 `review` 会话 |
| `[~] blocked`（`product`/上限，未授权） | **等待负责人处置 `(a)/(b)/(c)`** | **禁止**为受阻 WP 生成可执行 `do` 命令或自授额度；若存在独立就绪 WP 可标为条件备选 `do <change-id> <WP-YY>` |
| `[~] blocked`（`harness`，未核验恢复） | **恢复并核验具体环境前置条件** | **禁止**生成原样重跑/盲试命令；若存在不受环境影响且就绪的 WP 可标为条件备选 `do <change-id> <WP-YY>` |
| `do` 直关（空门禁）或 `review PASS` | 切至下一依赖就绪 WP（按 `board.md` 依赖筛选） | 首选 WP `do <change-id> <WP-XX>` 与四轴字段（并行就绪 WP 标为备选）；若全完成则汇报收口/剩余 `⚠️` |

### 3. `.ai/relay/CURRENT` 活动提案指针、单次锁定与只读校验

- **存储格式与合法字符**：
  - 路径：`.ai/relay/CURRENT`（与 `.ai/relay/<change-id>/` 同级，已受 `.gitignore` 与受保护 `Upgrade`/`Uninstall` 覆盖）。
  - 内容：UTF-8 单行文本（裁剪首尾空白后须满足 `^[A-Za-z0-9][A-Za-z0-9._-]*$`，且不得为 `.`、`..` 或包含 `/`、`\`、`:`、`..` 路径片段）。
- **解析、更新优先级与单次锁定**：
  1. **显式提案名优先**（`plan <change-id>`、`do <change-id> <WP-XX>`、`review <change-id> <WP-XX>`）：直接锁定该 `<change-id>`，不被当前或并发修改的 `CURRENT` 覆盖；确认任务已激活 EngRelay 且 `.ai/relay/<change-id>/board.md` 存在/创建后，同步更新 `.ai/relay/CURRENT`。
  2. **手工省略提案名**（`do <WP-XX>`、`review <WP-XX>`）：读取 `.ai/relay/CURRENT`；若格式合法且 `.ai/relay/<change-id>/board.md` 存在，即锁定该 `<change-id>`（即使项目内同时存在多个有效看板，有效 `CURRENT` 依然优先生效）。
  3. **指针缺失或失效回退**：**仅当** `.ai/relay/CURRENT` 缺失或指向不存在的 `board.md` 时扫描 `.ai/relay/*/board.md`；恰好存在 **1 个**有效 `board.md` 时自动选用并补写 `CURRENT`；若存在 ≥2 个有效 `board.md` 或 0 个，则列出候选列表并要求显式指定（或先 `plan`），立即停止，**严禁盲猜**。
  4. **单次调用目标锁定与首行回显**：一旦在模式调用开始时解析出 `<change-id>`，整次调用全程锁定该目标，中途绝不因其他会话修改 `CURRENT` 而漂移；并在回复首行输出 `Change: <change-id>`。
  5. **跨会话卡固定身份**：所有生成的 `Next Step` 跨会话可复制命令必须始终显式携带来源 `<change-id>`（而不输出省略提案名的简写），因此即便另一会话随后改写全局 `CURRENT`，复制旧卡仍精确作用于原提案。
- **只读诊断（`payload/docs/ai-collaboration/v2/scripts/doctor.ps1`）**：
  - `doctor.ps1` 严格零写入（包括存在损坏/失效 `CURRENT` 时也不删除或修改该文件）。
  - 当 `.ai/relay/CURRENT` 不存在：不报错（正常无活动指针状态）。
  - 当 `.ai/relay/CURRENT` 存在：先用 `Safe-Path` 核验其自身不是重解析点且位于 `.ai/relay/` 内，再校验裁剪后的单行名称符合安全正则且不含 `..` / 分隔符，以及解析后的目标看板路径也遵守 `Safe-Path` 边界；格式非法或越界立即抛出错误（`exit 1`，零写入）。
  - 若格式合法且 `.ai/relay/<id>/board.md` 存在：输出 `Active relay change=<id> (valid)`（`exit 0`）；若对应目录/看板已归档或缺失：输出非致命提示 `Active relay pointer stale: <id> (board.md missing)`（`exit 0`）。

### 4. 核心规则行数预算保护

当前 [RULES.md](../../../../payload/docs/ai-collaboration/v2/RULES.md)（41 行）+ [SKILL.md](../../../../payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md)（33 行）合计 **74/150 行**。本次三项改进只对 `RULES.md`、`SKILL.md` 做原则性增补（预计共增加 14–20 行），总计控制在 ~88–95 行，为未来留出充分余量且继续远低于 150 行硬上限；`agent-rules.md` 保持 10/18 行不变。

## Risks / Trade-offs

- **并发修改多个提案时 `CURRENT` 被另一会话改写** → 通过三层防呆解决：① 生成的 `Next Step` 跨会话可复制命令一律显式固定 `<change-id>`，即使 `CURRENT` 被他会话切换为提案 B，复制提案 A 的旧卡仍精确作用于 A；② 单次模式调用在入口解析出 `<change-id>` 后全程锁定该目标，且首行回显 `Change: <change-id>`；③ 手工命令可随时传显式 `<change-id>` 覆盖指针，不会发生静默串包。
- **旧提案归档或手动清理 `.ai/relay/<change-id>/` 后留下失效 `CURRENT`** → 设计为平滑退化：下次无参简写时按单看板回退或列出候选提示，且 `doctor.ps1` 对指向缺失 `board.md` 的合法指针只报非致命提示（`exit 0`），不阻断日常诊断。
- **用户偶发在 `review` 会话里口头要求“小 bug 你直接帮我顺手改一下吧”** → 协议与 `Next Step` 模板将“审查会话绝不改产品代码”定为硬约束，避免一次性破坏双会话独立性。
