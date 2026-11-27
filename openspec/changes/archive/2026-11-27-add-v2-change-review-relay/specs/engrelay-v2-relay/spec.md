# Delta for engrelay-v2-relay

## ADDED Requirements

### Requirement: Change-level proposal and implementation review relay

EngRelay v2 SHALL 在统一 `engrelay` Skill 内提供 `review proposal [<change-id>]`、`fix proposal [<change-id>]`、`review change [<change-id>]` 与 `fix change [<change-id>]`，固定读写追加式 `.ai/relay/<change-id>/review-proposal.md` 与 `review-change.md`；`review change`/`fix change` 与既有 `board.md`/`wp-XX.md` 对同一未完成映射验收双向继承累计计数与恢复限制；`fix` 须先锁定变更身份并通过前置准入，任何拒绝均严格零写入（含 `CURRENT`）。

#### Scenario: Cross-platform proposal review and reconcile preserves planning boundary

- **WHEN** 独立审查会话执行 `review proposal <change-id>` 发现提案一致性或边界问题（输出 `FIX REQUIRED` 并写入 `.ai/relay/<change-id>/review-proposal.md`），随后另一规划会话执行 `fix proposal <change-id>`
- **THEN** `review proposal` 仅写入 `review-proposal.md`（及获准 `CURRENT` 元数据），只读核对相关代码与规范而不改动提案；`fix proposal` 仅修订 `openspec/changes/<change-id>/*` 并在 `review-proposal.md` 末尾追加修订反馈（严禁改产品源码/测试），复审可沿用同一未污染审查会话直接核对新增修订

#### Scenario: Cross-platform implementation review and reconcile uses fixed append-only report

- **WHEN** 独立审查会话执行 `review change <change-id>` 审查整项变更（涵盖完整 diff、OpenSpec 符合性与实测证据）并将发现写入 `.ai/relay/<change-id>/review-change.md`，随后实施会话执行 `fix change <change-id>`
- **THEN** `fix change` 逐条核对发现、仅修复确认成立的问题、运行针对性验证并在 `review-change.md` 末尾追加核对与验证反馈（保留原审查正文不变，不自动提交、归档或发布）；Round 2 通过后 `review change` 仅在 `review-change.md` 写入 `PASS` 结论并停止

#### Scenario: Change-level reviewer stays read-only after FIX REQUIRED or in-session (a)

- **WHEN** 处于 `review proposal` 或 `review change` 模式的会话判定 `FIX REQUIRED` 或 `[~] blocked`，随后用户在当前审查会话直接要求顺手修改提案或代码（含回复 `(a)` 有限追加授权）
- **THEN** 该审查会话 SHALL NOT 修改任何 OpenSpec 文件、产品源码、配置或测试文件，仅将结论或保留原累计计数的 `(a)` 授权追加写入对应 `review-*.md` 并停止

#### Scenario: Change-level review enforces two-round cap and refuses unauthorized fix bypass

- **WHEN** `review proposal` 或 `review change` 在第 2 轮仍有未解决实质阻塞或连续两次出现相同失败签名进入 `[~] blocked`（`product|harness`），或 `review change` 处理的未完成映射验收在既有 `board.md`/`wp-XX.md` 中已两轮 `[~] blocked` 且未获 `(a)` 授权
- **THEN** `review change` 继承该同一未完成验收的累计计数与恢复限制（不得因新建 `review-change.md` 重新获得自治修复预算，也不将无关验收或提案阶段混并）；在未记录明确 `(a)` 授权（或未核验 `harness` 已恢复）前，对应 `fix` 命令 MUST 严格零写入拒绝绕过，切回 WP `do` 同样不得绕过变更级阻塞

#### Scenario: Fix command stops cleanly when review file is missing or already passed

- **WHEN** 锁定目标变更后发现 `.ai/relay/<change-id>/review-proposal.md`（或 `review-change.md`）不存在，或最新已完结轮次状态为 `PASS` 无待修复项，用户执行 `fix proposal`（或 `fix change`）
- **THEN** Agent MUST 严格零写入停止执行（包括不得新建、改写或回退更新 `.ai/relay/CURRENT` 到另一提案），提示先运行对应的 `review` 命令（或进入下一步规划/归档）

#### Scenario: Rejected fix preserves CURRENT pointer bytes and absent state

- **WHEN** `.ai/relay/CURRENT` 指向提案 A，提案 B 的报告已为 `PASS` 或未授权 `[~] blocked`，用户显式执行 `fix change B`；或 `.ai/relay/CURRENT` 不存在且仅有唯一活动变更 B 但其报告不可修复时用户执行简写 `fix change`
- **THEN** 上述失败准入均 MUST 严格保持 `.ai/relay/CURRENT` 的原始字节或不存在状态及所有项目文件完全不变；只有通过目标身份解析与全部准入校验的 `fix` 才允许按约定更新 `.ai/relay/CURRENT`

## MODIFIED Requirements

### Requirement: Hard two-round circuit breaker and cumulative acceptance history

每个 WP 及变更级审查最多允许 2 轮自治复核。第 2 轮核验原 `BLOCKER` 与修复影响面新引入的实质 `BLOCKER`（禁升 `NOTE`）；未解决或两次同一签名 MUST 立即标为 `[~] blocked`（`product|harness`）。累计计数与失败签名绑定未完成映射验收，SHALL NOT 因重 `plan`、拆分、改名、换平台或在 WP 与 `review change`/`fix change` 间切换而清零，也不将不相关验收或阶段强行合并。

#### Scenario: Round 2 rejects fix-introduced P1 regression

- **WHEN** 第 1 轮 `BLOCKER` 已修复，但修复代码在受影响范围内引入新的 P1 权限或契约缺陷
- **THEN** 第 2 轮复核不得判定 `PASS`，记录该新 `BLOCKER` 后立即将 WP 标为 `[~] blocked` 并交由人工裁决，不自动开启第 3 轮

#### Scenario: Re-planning or splitting does not reset cumulative ceiling

- **WHEN** 某 WP 经两轮失败进入 `[~] blocked` 后，用户或代理重新执行 `plan`、改名 WP ID 或拆出子包处理同一未完成验收
- **THEN** 新条目继承原累计 verdict 与失败签名历史，不自动获得新的 2 轮自治修复预算

#### Scenario: Change-level review inherits exhausted WP limits for the same unfinished acceptance

- **WHEN** 某 WP 已因特定未完成映射验收两轮失败进入 `[~] blocked` 且负责人尚未授权 `(a)`，随后独立会话运行 `review change <change-id>`
- **THEN** 首次 `review change` 可按当前证据报告问题但须继承该未完成验收的累计历史与阻塞限制；未获 `(a)` 授权的 `fix change` 不得借新报告 `Round 1` 实施修复，仅在负责人明确给出 `(a)` 后才可保留累计计数执行受限修复；与该阻塞项不同的独立验收及先前的提案阶段审查不因 `<change-id>` 相同而误累计

#### Scenario: WP execution cannot bypass a change-level blocked acceptance

- **WHEN** `review change <change-id>` 将某未完成映射验收标为 `[~] blocked` 且未获 `(a)` 授权（或 `harness` 前置未恢复）
- **THEN** 返回或新开对应 WP 执行 `do <change-id> <WP-XX>` 时 MUST 继承该未完成验收的阻塞与累计历史，未获明确 `(a)` 授权或未核验恢复前不得绕过执行

### Requirement: Isolated per-change state and optional diagnostics

EngRelay v2 运行态（含 `board.md`、`wp-XX.md`、`review-proposal.md` 与 `review-change.md`）SHALL 排除在 Git 外并隔离于 `full`/`lite`；`docs/engrelay.config.md` 留空不阻塞也不跳过验收。v2 SHALL 先按活动变更身份解析并锁定单行 `.ai/relay/CURRENT`（不以报告存在与否过滤目标），仅在命令准入通过后才写 `CURRENT`，缺失/失效且多候选列候选停机，不自动激活流程，`doctor.ps1` 严格零写入。

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

#### Scenario: Change-level commands resolve active change without requiring board.md

- **WHEN** 变更尚处于 `plan` 前仅存在 `openspec/changes/<change-id>/`（或含 `board.md`），用户执行显式 `review|fix proposal|change <change-id>` 或省略提案名简写
- **THEN** 目标身份解析只核验活动变更身份（`openspec/changes/<id>/` 排除 `archive/`，或 `change` 命令可用的 `board.md`），绝不以 `review-*.md` 是否存在作为筛选门槛；显式 `<change-id>` 仅在变更身份合法且命令准入（对 `fix` 含前置检查）通过后才锁定并写 `CURRENT`；简写优先按有效 `CURRENT` 锁定该变更身份，仅当 `CURRENT` 本身缺失或指向非活动变更时按唯一活动变更回退，多候选或零候选 MUST 列候选停止；并发切走 `CURRENT` 不影响已有单次调用锁

#### Scenario: Valid CURRENT without review report stops instead of falling back to another change

- **WHEN** 存在两个活动变更 A 与 B，`.ai/relay/CURRENT` 指向有效的活动变更 A 且 A 尚无 `review-proposal.md`（或 `review-change.md`），而 B 存在 `FIX REQUIRED` 报告，用户发送简写 `fix proposal`（或 `fix change`）
- **THEN** Agent MUST 先锁定当前活动变更 A，随后在只读前置检查中因 A 缺失对应报告而严格零写入停止（提示先执行 `review proposal A` / `review change A`），严禁回退或改选 B，也不得修改 A、B 或 `.ai/relay/CURRENT`

#### Scenario: Doctor recognizes active pre-plan change review pointer read-only

- **WHEN** `.ai/relay/CURRENT` 格式安全合法且尚无 `.ai/relay/<id>/board.md`，对比“存在 `openspec/changes/<id>/` 与 `.ai/relay/<id>/review-proposal.md`（或 `review-change.md`）”与“缺少活动变更目录或报告均不存在”以及“路径含重解析点/穿越”执行 `doctor.ps1`
- **THEN** 前者输出有效的 `plan` 前变更审查指针状态（退出 0，严格零写入）；缺少对应活动锚点仍输出非致命失效提示 `board.md missing`（退出 0，零写入）；若 `.ai/relay/CURRENT`、`openspec/changes/<id>` 或报告路径触发 `Safe-Path` 重解析点/越界检查则立即拒绝（退出 1，零写入）

#### Scenario: Change-level review files never auto-activate workflow

- **WHEN** 项目 `WorkflowMode` 为 `optional`，工作区已存在 `.ai/relay/<change-id>/review-proposal.md`、`review-change.md` 或 `.ai/relay/CURRENT`，用户运行未显式选择 EngRelay 的任务
- **THEN** Agent 不得自动激活 EngRelay，也不得改写上述文件或 `.ai/relay/CURRENT`

### Requirement: Actionable next-step recommendation card

每次 `plan`、`do`、`review`、`review proposal|change` 与 `fix proposal|change` 结束时，Agent SHALL 输出固定五行正文（`Primary`、`Command`、`Axes`、`Gate`、`Alternate`）的 `Next Step` 推荐卡（仅作建议，SHALL NOT 自动启动下一会话、越权执行或自授额度），给出唯一首选动作（备选或 `none`），跨会话命令 MUST 携带固定 `<change-id>` 且严格区分已授权恢复与待决定阻塞。

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

#### Scenario: Next step for proposal review routes between fix proposal, re-review, and plan

- **WHEN** `review proposal <change-id>` 输出预算内 `FIX REQUIRED`、已确认 `(a)` 授权、未授权/未核验 `[~] blocked` 或 `PASS`，或 `fix proposal <change-id>` 完成修订后退出
- **THEN** `Next Step` 始终保持五行正文且命令固定携带 `<change-id>`：可修复分支推荐 `fix proposal <change-id>`，`fix proposal` 完成推荐切回同一审查会话执行 `review proposal <change-id>`，未授权/未核验 `[~] blocked` 使用 `Command: Wait`（禁止输出可执行 `fix`），`review proposal PASS` 首选推荐 `plan <change-id>`

#### Scenario: Next step for change implementation review routes between fix change, re-review, and owner close-out

- **WHEN** `review change <change-id>` 输出预算内 `FIX REQUIRED`、已确认 `(a)` 授权、未授权/未核验 `[~] blocked` 或 `PASS`，或 `fix change <change-id>` 完成核对修复后退出
- **THEN** `Next Step` 始终保持五行正文且命令固定携带 `<change-id>`：可修复分支推荐 `fix change <change-id>`，`fix change` 完成推荐切回同一审查会话执行 `review change <change-id>`，未授权/未核验 `[~] blocked` 使用 `Command: Wait`（禁止输出可执行 `fix` 或原样重跑），`review change PASS` 输出 `Command: none` 并交由负责人决定是否执行 OpenSpec 归档/提交/发版
