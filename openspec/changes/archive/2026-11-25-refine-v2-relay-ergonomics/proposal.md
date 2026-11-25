# Proposal: refine-v2-relay-ergonomics

## Why

在基于 EngRelay v2（`2.0.0` 基线）实际推进跨平台、合并多仓库工作的 OpenSpec 提案时，暴露出三项影响多平台小额度接力体验的摩擦点：
1. `review` 会话发现问题或用户回复有限授权 `(a)` 后，容易在同一审查会话中直接动手改代码，污染审查者独立性，导致复核时被迫不断另开第 3 个新会话，无法稳定复用“实施/修复 ↔ 审查/验证”双会话。
2. 每次 `plan`、`do`、`review` 结束后缺少结构化的下一步建议卡，操作者需要手工翻查 `board.md` 比对依赖就绪状态、风险、难度（`C1–C5`）与体量（`XS–L`），增加切平台判断成本。
3. 专注推进单个提案期间，每次调用 `do`/`review` 都必须重复输入冗长的 `<change-id>`，简写时又缺乏明确指针约束，容易产生多提案歧义或额外目录探测开销。

## What Changes

- **严格禁改业务代码的 `review` 写入白名单与双车道复用规范**：统一明确 `review` 会话的可写范围仅限于：(1) `.ai/relay/<change-id>/`、(2) `.ai/relay/CURRENT`（仅限显式传入 `<change-id>` 或指针缺失/失效且存在唯一看板的合法回退时更新活动目标选择元数据，不得扩展至其他共享状态或由未激活任务/只读 `doctor.ps1` 写入）、(3) 映射验收完全满足时的 `tasks.md`；严禁修改任何产品源码、配置或测试文件。即使收到用户对 `FIX REQUIRED` 或 `(a)` 有限追加轮次的确认，也只记录审查结论或授权（保留原累计计数）并停止，由执行/修复会话接回 `do <change-id> <WP-XX>` 集中修复，从而支持两会话长期交替复用而不破坏独立性。
- **固定提案身份且严格区分恢复授权的 `Next Step` 推荐卡**：在 `plan`、`do`、`review` 末尾输出 4–6 行纯建议型 `Next Step` 卡，包含唯一明确首选动作（其余并行项标为条件性或备选），且所有生成的跨会话可复制命令一律显式携带固定来源提案身份（`do <change-id> <WP-XX>` / `review <change-id> <WP-XX>`），不依赖易被他会话覆盖的全局 `CURRENT`。卡片严格区分四类恢复边界：有余量的 `FIX REQUIRED` 与已确认负责人 `(a)` 有限追加授权可推荐回实施会话执行 `do <change-id> <WP-XX>`（不重复索要批准也不自授新额度）；未获授权的 `product`/上限 `[~] blocked` 与恢复条件未验证的 `harness` `[~] blocked` 不得生成该 WP 的可执行修复指令，只提示等待负责人决定/恢复验证条件（或将已就绪独立 WP 列为备选）。
- **`.ai/relay/CURRENT` 活动提案指针、单次调用锁定与只读诊断**：引入单行 `.ai/relay/CURRENT` 记录默认活动 `<change-id>`（由 `plan <change-id>`、显式 `<change-id>` 命令及唯一看板合法回退更新）；手工简写（`do WP-XX` / `review WP-XX`）在有效 `CURRENT` 存在时直接按该指针解析（即使并存多看板亦优先生效），仅在 `CURRENT` 缺失/失效且存在多个看板时列出候选禁止盲猜。单次调用一旦解析出目标 `<change-id>` 即在本次运行内锁定不变，并在首行回显 `Change: <change-id>`，不被其他会话并发改写 `CURRENT` 中途劫持；该文件存在绝不自动激活 EngRelay，且 `docs/engrelay/scripts/doctor.ps1` 只读校验其格式与路径边界（严格零写入）。

## Capabilities

### New Capabilities

- （无新增能力；全部改进均在既有 `engrelay-v2-relay` 契约能力内演进。）

### Modified Capabilities

- `engrelay-v2-relay`：增强 `review` 模式禁止修改业务代码的双车道复用边界、新增模式结束 `Next Step` 推荐卡规范，以及在隔离运行态规范中引入 `.ai/relay/CURRENT` 活动提案指针解析与只读安全核验。

## Impact

- 预计变更范围：
  - 核心契约与模板：[RULES.md](../../../../payload/docs/ai-collaboration/v2/RULES.md)、[SKILL.md](../../../../payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md)、[wp.md](../../../../payload/docs/ai-collaboration/v2/templates/wp.md)（`RULES.md` + `SKILL.md` 仍须严格控制在 `<= 150` 行预算内，`agent-rules.md` 保持 10/18 行不变）。
  - 只读诊断与自动化测试：[doctor.ps1](../../../../payload/docs/ai-collaboration/v2/scripts/doctor.ps1)、[test-v2-workflow.ps1](../../../../scripts/test-v2-workflow.ps1)。
  - 双语人类说明：[payload v2 README](../../../../payload/docs/ai-collaboration/v2/README.md) / [README.zh-CN.md](../../../../payload/docs/ai-collaboration/v2/README.zh-CN.md)、根目录 [README.md](../../../../README.md) / [README.zh-CN.md](../../../../README.zh-CN.md) 与 [CHANGELOG.md](../../../../CHANGELOG.md) / [CHANGELOG.zh-CN.md](../../../../CHANGELOG.zh-CN.md)。
- 兼容与非目标：
  - `.ai/relay/CURRENT` 位于已受 `.gitignore` 忽略且受 `Upgrade`/`Uninstall` 保护的 `.ai/relay/` 目录内，不改变 `scripts/manage.ps1`、`scripts/update-snapshot.ps1`、`workflow-profiles` 清单归属模型或 `full`/`lite` 冻结配置。
  - 不引入运行时自动派发引擎，不削弱审查独立性、正交风险门禁或两轮硬断路器。
