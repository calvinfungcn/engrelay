# Delta for engrelay-v2-relay

## MODIFIED Requirements

### Requirement: Scoped entry points and consequence-sized independent review

在 `review` 模式下，独立于实施与修复者的会话（优先不同模型家族，不可用时允许同家族独立会话并记录工具/模型）SHALL 严禁修改产品源码、配置或测试文件，只允许写入 `.ai/relay/<change-id>/`、活动目标选择元数据 `.ai/relay/CURRENT`（仅限显式 `<change-id>` 或唯一看板合法回退）及验收完全满足时的 `tasks.md`，确保双会话长期复用；审查以 `board.md`、`wp-XX.md` 与完整 WP 变更范围为入口按需查阅 OpenSpec/源码，结论区分 `BLOCKER`、`NOTE` 与 `⚠️`。

#### Scenario: Same-family independent session proceeds when heterogeneous is unavailable

- **WHEN** 某需审查 WP 在不同模型家族额度不可用时，由同模型家族中与实施/修复者真正独立的另一会话执行 `review`
- **THEN** 审查正常继续并记录实际审查工具与模型；实施或修复者自审及自任必需 `H` 验证仍被禁止

#### Scenario: Review accurately covers untracked, staged, committed, and multi-repo changes

- **WHEN** 待审查 WP 包含新增未跟踪文件、已提交区间、跨多仓库修改，或与同工作树内其他 WP 共享文件边界
- **THEN** 审查者依据 WP 声明的仓库与变更范围获取完整 diff（而非仅无参数 `git diff`），准确识别属于本 WP 的全部改动后再下结论

#### Scenario: Reviewer checks authoritative OpenSpec when summary omits criteria

- **WHEN** `wp-XX.md` 摘要遗漏原始 OpenSpec 验收条件或模块约束
- **THEN** 审查者直接只读查阅对应的 OpenSpec 规范、设计与模块 `AGENTS.md` 核对规范符合性，不受“仅读三项”限制

#### Scenario: Reviewer separates blockers from non-blocking notes

- **WHEN** 独立审查者核对实际变更与当前输入匹配的测试证据
- **THEN** 仅将违背规范或安全/并发/契约/构建等实质缺陷列为 `BLOCKER`，样式或额外测试建议记为 `NOTE`，跨包未验证项记为 `⚠️`

#### Scenario: Review session refuses in-session product code fixes

- **WHEN** 处于 `review` 模式的会话判定 `FIX REQUIRED` 或 `[~] blocked`，随后用户在当前审查会话中回复确认或直接要求顺手修改产品代码（含回复 `(a)` 授权有限额外修复与复核轮次）
- **THEN** 该 `review` 会话 SHALL NOT 修改任何产品源码、配置或测试文件，仅将审查结论或有限追加授权记录（保留原累计计数）写入 `.ai/relay/<change-id>/` 并停止，给出固定提案身份的可复用修复指令 `do <change-id> <WP-XX>`（有授权恢复时）或人工处置提示

#### Scenario: Two-lane session reuse preserves reviewer independence

- **WHEN** 会话 A（实施/修复车道）完成 `do <change-id> <WP-XX>` 并根据 `wp-XX.md` 最新 `BLOCKER` 完成修复，全程未触碰产品代码的独立会话 B（审查/验证车道）承接 Round 1 与 Round 2 `review` 及所需 `H` 级修复后独立验证
- **THEN** 会话 B 因从未修改任何产品源码、配置或测试文件而持续保持独立性，无需为第 2 轮或追加轮次重新开设第 3 个全新会话

#### Scenario: Review write allowlist covers CURRENT metadata without expanding write scope

- **WHEN** 独立会话执行显式 `review <change-id> <WP-XX>`、或在 `CURRENT` 缺失/失效且仅存在唯一有效看板时执行简写 `review <WP-XX>`，对比未激活的 `optional` 任务或只读 `doctor.ps1`
- **THEN** 显式 `review` 与合法唯一回退 `review` 允许更新 `.ai/relay/CURRENT` 活动目标选择元数据（不得写入其他共享运行态或产品文件）；未激活任务与 `doctor.ps1` 严格禁止写入 `.ai/relay/CURRENT`

### Requirement: Isolated per-change state and optional diagnostics

EngRelay v2 运行态 SHALL 存放在 `.ai/relay/<change-id>/` 并排除在 Git 之外，SHALL NOT 读写 `full`/`lite` 运行态；项目自有 `docs/engrelay.config.md` 留空不阻塞规划且不跳过验收。v2 SHALL 维护单行活动提案指针 `.ai/relay/CURRENT`，单次调用解析后全程锁定该目标且不被并发改写；仅指针缺失或失效且存在多个看板时列出候选禁止盲猜；指针存在 SHALL NOT 自动激活流程，`doctor.ps1` 只读核验且严格零写入。

#### Scenario: Multiple OpenSpec changes stay isolated

- **WHEN** 同一项目并行推进两个不同的 OpenSpec 变更
- **THEN** 各自运行态分别保存在 `.ai/relay/<change-id-a>/` 与 `.ai/relay/<change-id-b>/`，互不覆盖且不干扰既有 `.ai/handoff.md` 历史

#### Scenario: Blank personal quota calibration does not block planning

- **WHEN** `docs/engrelay.config.md` 中的平台额度手感备忘或命令栏位留空
- **THEN** `plan`、`do`、`review` 正常启动规划与执行，但必需的成果验收不得因配置留空而被跳过

#### Scenario: Plan and explicit change-id commands update CURRENT pointer

- **WHEN** 用户执行 `plan <change-id>`，或在已激活的 `do` / `review` 命令中显式传入有效的 `<change-id>`
- **THEN** 本次调用固定锁定该 `<change-id>`（不受其他会话并发修改 `CURRENT` 影响），并将单行 `<change-id>` 写入 `.ai/relay/CURRENT`，同时在回复首行回显生效的 `Change: <change-id>`

#### Scenario: Shorthand command resolves active change from CURRENT pointer

- **WHEN** 用户手工省略提案名发送 `do WP-XX` 或 `review WP-XX`，且 `.ai/relay/CURRENT` 指向有效的 `.ai/relay/<change-id>/board.md`（即使项目内同时存在多个有效看板）
- **THEN** Agent 按 `.ai/relay/CURRENT` 解析并在本次调用全程锁定该 `<change-id>` 执行对应模式，在回复首行显式回显 `Change: <change-id>`

#### Scenario: Missing or stale CURRENT falls back only when unambiguous

- **WHEN** 用户省略提案名发送 `do WP-XX` 或 `review WP-XX`，且前提为 `.ai/relay/CURRENT` 缺失或指向不存在的 `board.md`
- **THEN** 若 `.ai/relay/` 下仅存在唯一有效 `board.md` 则自动选用并补写 `CURRENT`；若存在两个及以上有效 `board.md` 或零个有效 `board.md` 则 MUST 列出候选目录（或提示先执行 `plan`）并停止，禁止盲猜执行

#### Scenario: CURRENT pointer never auto-activates workflow and doctor inspects it read-only

- **WHEN** 项目存在 `.ai/relay/CURRENT`（包括有效、指向已归档目录的失效指针，或含路径穿越/非法字符的损坏指针）且在 `optional` 模式下执行只读 `doctor.ps1` 或处理未选择 EngRelay 的普通任务
- **THEN** 非 EngRelay 任务保持不自动激活且不写 `CURRENT`；`doctor.ps1` 严格零写入，对有效指针输出活动提案状态（退出 0），对目标缺失的失效指针给出非致命提示（退出 0），对含路径分隔符、`..`、重解析点或非法字符的损坏指针拒绝（退出 1）

## ADDED Requirements

### Requirement: Actionable next-step recommendation card

每次 `plan`、`do`、`review` 结束时，Agent SHALL 在回复末尾输出 4–6 行 `Next Step` 推荐卡（仅作人工接力建议，SHALL NOT 自动启动下一会话、跨越当前模式或自授额外额度），给出唯一明确首选动作（其余标为条件性或备选），所有跨会话可复制命令 MUST 显式携带固定 `<change-id>`（如 `review <change-id> <WP-XX>` / `do <change-id> <WP-XX>`），并严格区分有授权恢复与待决定/未恢复阻塞。

#### Scenario: Next step after do completion with active review gate

- **WHEN** `do` 完成具有独立审查门禁（`M`/`H`/显式要求）的 WP 并写入执行摘要
- **THEN** 回复末尾输出 `Next Step` 推荐卡，给出唯一首选动作（切往独立 `Review` 会话，可复用未改码审查会话），附显式携带提案名的可复制命令 `review <change-id> <WP-XX>` 及该 WP 的风险、难度、体量/节奏与必需验证说明，且不在当前会话执行审查

#### Scenario: Next step after FIX REQUIRED or confirmed bounded extra cycle directs back to fixer session

- **WHEN** `review` 在两轮预算内输出 `FIX REQUIRED`，或已确认负责人明确给出的 `(a)` 有限追加修复/复核授权并写入记录（保留原累计计数）
- **THEN** `Next Step` 推荐卡给出唯一首选动作：切回实施/修复会话执行固定提案身份的 `do <change-id> <WP-XX>`（提示修复后切回当前审查会话复核），不重复索要已经确认的 `(a)` 批准，也不在当前审查会话修改代码

#### Scenario: Next step for unauthorized product block or unverified harness block withholds repair command

- **WHEN** WP 进入未获负责人恢复授权的 `product`/两轮上限 `[~] blocked`，或进入恢复条件尚未满足/未核验的 `harness` `[~] blocked`
- **THEN** `Next Step` 推荐卡 SHALL NOT 为该受阻 WP 生成可执行的 `do` 修复或原样重跑命令（也不得自授新轮次）；首选动作分别标明“等待负责人决定 `(a)/(b)/(c)`”或“恢复并核验前置环境条件”，若另有依赖就绪且独立未受阻的 WP 可标为次要/条件备选

#### Scenario: Next step card stays pinned to source change even after CURRENT switches

- **WHEN** 提案 A 生成包含固定提案身份命令的 `Next Step` 推荐卡后，另一会话显式执行提案 B 将 `.ai/relay/CURRENT` 改写为 B，操作者再复制使用提案 A 的原推荐卡
- **THEN** 接收该命令的会话 MUST 仅作用于提案 A（显式 `<change-id>` 不受 `CURRENT` 覆盖，也不中途切到 B）

#### Scenario: Next step after plan or WP completion recommends ready unblocked WPs

- **WHEN** `plan` 完成初始化，或某 WP 标为 `[x] done` 后需要推进下一项工作
- **THEN** `Next Step` 推荐卡给出依赖已全部 `[x] done` 的唯一首选 WP（携带显式 `do <change-id> <WP-XX>` 命令与四轴决策字段），其余并行就绪 WP 标为可选备选；若全部 WP 已收口或均因未决阻塞等待裁决，则如实汇报收口或待决定状态
