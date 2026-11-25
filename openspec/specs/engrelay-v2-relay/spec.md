# engrelay-v2-relay Specification

## Purpose

定义 EngRelay v2 极简跨平台协作协议：基于 OpenSpec 切分独立可闭环工作包（WP），提供独立风险分级与难度体量评估、平台原生连续执行、无仪式断点接力、两轮硬上限独立审查验证以及按变更隔离的运行态规范。

## Requirements

### Requirement: Lean principle-driven protocol and activation boundary

EngRelay v2 SHALL 提供精简规则 `docs/engrelay/RULES.md` 与单一统一 Skill `engrelay`（`docs/engrelay/skills/engrelay/SKILL.md`），二者核心规则正文合计 MUST NOT 超过 150 行。协议采用原则驱动表达，SHALL 保留 `AGENTS.md` 条件激活边界（默认 `optional`，与其它主控制器互斥，OpenSpec 为唯一权威），SHALL NOT 依赖旧版 `full` 手册。新增 v2 规则、Skill 与模板内容 SHALL 全部原创编写并遵循 MIT 许可。

#### Scenario: Combined core protocol stays within 150-line budget

- **WHEN** 检查规范包中的 `v2` 规则文件与 `engrelay` Skill 文件总行数
- **THEN** 二者合计行数不超过 150 行，且不引用 `full` 手册作为前置必读

#### Scenario: Optional mode prevents unrequested activation

- **WHEN** 项目 `WorkflowMode` 为 `optional`，用户未在当前任务中显式选择 `EngRelay`
- **THEN** 即使存在 `.ai/relay/` 目录或已安装 `engrelay` Skill，Agent 也不得自动启用 v2 流程或写入运行态文件

### Requirement: OpenSpec orchestrator slicing and contract extraction

在 `plan` 模式下，Orchestrator SHALL 读取活动 OpenSpec 变更的提案、规范、设计与 `tasks.md` 并一次性检索 `docs/solutions/`，按“审查者可合理独立批准或打回”的粒度切分为可闭环工作包（`WP-01..N`）。看板 `.ai/relay/<change-id>/board.md` SHALL 显式列出 `Global Constraints`、各 WP 的 `Interfaces`、所属仓库与变更范围边界及必跑验证命令，SHALL NOT 拆出单文件 DTO 或跨多仓巨型批次。

#### Scenario: Slicing respects reviewer independence and boundary contracts

- **WHEN** 用户在活动 OpenSpec 变更上调用 `plan` 模式
- **THEN** Orchestrator 生成 `.ai/relay/<change-id>/board.md`，每个 WP 均包含 OpenSpec 映射、精确接口契约、仓库与范围边界、全局红线及验证命令，且不包含仅修改单个类型或字段的微包

#### Scenario: Knowledge lookup happens once during planning

- **WHEN** 项目存在 `docs/solutions/` 经验文档
- **THEN** `plan` 模式在拆包时检索一次并将命中的路径写入相关 WP 的参考项，后续 `do` 与 `review` 阶段无需重复全库检索

### Requirement: Risk classification and independent review or verification

风险等级（`S|M|H`）与负责人或项目显式审查要求共同决定独立审查与验证门禁，SHALL NOT 由 `C1–C5` 难度单独触发。仅当适用独立审查/验证要求为空（保持 `S` 且无显式审查要求）时可自测关闭；`M` MUST 经独立代码审查及对 `BLOCKER` 修复的独立确认；`H` MUST 经独立代码审查及独立修复后验证（并入独立 `review` 模式）。独立性 MUST 满足（实施/修复者不可自任）；优先选用不同模型家族，异构不可用时允许同家族真正独立会话承接，仅更换模型家族不自动证明独立性。

#### Scenario: Low-difficulty change touching a high-risk boundary

- **WHEN** 某项标为 `C1` 且体量 `XS` 的小改动涉及权限校验、资金或共享契约边界
- **THEN** 其风险等级仍判定为 `H`，不得仅凭自测直接关闭，必须完成独立审查及必要的修复后独立验证

#### Scenario: Risk S with C4 difficulty vs Risk M with C1 difficulty

- **WHEN** `plan` 与 `do` 分别评估“风险 `S` + 难度 `C4`（无显式审查要求）”与“风险 `M` + 难度 `C1`”两个 WP
- **THEN** 前者在 `plan` 与 `do` 均判定为无需独立审查、自测通过即可关闭；后者均判定为必须经过独立代码审查后方可关闭

#### Scenario: High-risk blocker repair requires independent verification

- **WHEN** 风险为 `H` 的 WP 在实现或修复 `BLOCKER` 后仅完成实现者自测
- **THEN** 该 WP 不得标记为完成，必须由独立于实施与修复者的会话在 `review` 模式下完成独立验证

### Requirement: Two-axis difficulty and workload estimation

`plan` 模式 SHALL 在风险分级之外，为每个 WP 评定难度（`C1`–`C5`）、任务形态（`ui|backend|concurrency|integration|docs|ops`）、体量（`XS|S|M|L`）与执行节奏（`可断点|建议连续`）。超过 `L` 体量的范围 MUST 继续拆分为更小 WP。该评估仅用于匹配模型档位、平台与等待重置窗口，SHALL NOT 覆盖或额外触发独立审查门禁。

#### Scenario: Oversized scope triggers mandatory split

- **WHEN** 某候选 WP 跨越多模块高耦合修改或超出单个会话体量上限 `L`
- **THEN** Orchestrator 将其拆分为多个不超过 `L` 的独立或串联 WP，而不是输出 `XL` 级工作包

#### Scenario: Estimation enables platform and reset-window selection

- **WHEN** 用户在执行前查看 `.ai/relay/<change-id>/board.md`
- **THEN** 每个 WP 均明确展示 `S/M/H` 风险、`C1`–`C5` 难度、`XS`–`L` 体量及 `可断点|建议连续` 标记，使用户可据此匹配订阅平台与等待重置时机，且 `S/C4` 无显式审查要求时不额外要求独立审查

### Requirement: Platform-native continuous execution and lightweight checkpointing

在 `do` 模式下，当前平台 SHALL 在所属 WP 范围内连续完成局部设计、编码、针对性测试与自简 diff，退出时向 `.ai/relay/<change-id>/wp-XX.md` 写入不超过 60 行摘要并报告 `DONE|DONE_WITH_CONCERNS|NEEDS_CONTEXT|BLOCKED`。仅当该 WP 适用的独立审查/验证要求为空（风险保持 `S` 且无显式审查要求）时允许直接关闭。若发现实际风险高于计划，MUST 立即刷新风险与门禁，不得以 `DONE_WITH_CONCERNS` 自关。额度不足时追加 ≤15 行断点；遇 `BLOCKED` 必须换策略。

#### Scenario: Quota exhaustion triggers lightweight checkpoint without review

- **WHEN** 执行者在 WP 尚未完成时收到保存断点指令
- **THEN** 仅向 `wp-XX.md` 追加不超过 15 行断点（已完成、未完成、踩坑、下一步），不启动审查轮次，另一平台可直接从断点继续执行 `do`

#### Scenario: Risk escalation during execution refreshes review gate

- **WHEN** 原标为 `S` 的 WP 在 `do` 阶段被发现触及安全或跨系统契约边界
- **THEN** 执行者将风险上调为 `M` 或 `H`，写入 `wp-XX.md` 并刷新必需的独立审查或验证要求，不得直接将 WP 标为 `[x] done`

#### Scenario: Risk S with explicit review request cannot direct-close

- **WHEN** 风险为 `S` 的 WP 存在用户或项目显式要求的独立审查
- **THEN** 即使自测全部通过，执行者也不得在 `do` 阶段直接将 WP 标为 `[x] done`，必须转入 `review`

#### Scenario: Low-risk S WP with empty review gate closes directly

- **WHEN** 风险保持为 `S` 且无显式审查要求的 WP 完成编码与必跑验证且全部通过
- **THEN** 执行者记录精简摘要并将 `board.md` 中该 WP 状态更新为 `[x] done`，直接关闭而不派发独立审查

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

### Requirement: Review pass vs acceptance completion and deferred item handoff

v2 SHALL 明确区分“代码审查通过（`review PASS`）”与“OpenSpec 成果验收完成”。`⚠️ Cannot verify from diff` 仅在完全不影响本 WP 自身必需验收、且于 `board.md` 中具名映射到下游承接 WP（含依赖与负责人）时，才允许本 WP 审查判定 `PASS` 并标为 `[x] done`。若缺少下游联调承接、下游 WP 或环境无法完成验证，相关 OpenSpec `tasks.md` 条目与父变更 MUST 保持未完成，而独立 WP 可继续推进。可选配置留空不得用于跳过必需验收。

#### Scenario: Deferred item has an explicit downstream integration owner

- **WHEN** 审查仅余非阻塞 `NOTE` 与一项明确映射到已建下游联调 WP 的 `⚠️` 跨端验证项，且本 WP 自身必需单测已通过
- **THEN** 当前 WP 可判定 `review PASS` 并标为 `[x] done`，但关联的跨端 OpenSpec 验收条目保持未勾选，直至下游联调 WP 验证通过

#### Scenario: Missing downstream owner or unavailable verification environment

- **WHEN** 存在未验证 `⚠️` 项却无下游承接 WP，或最终联调 WP 因环境不可用无法执行必需验证
- **THEN** 相关 OpenSpec 验收条目与父变更不得宣称全部完成；不依赖该项的独立 WP 仍可正常继续

### Requirement: Hard two-round circuit breaker and cumulative acceptance history

每个 WP 的正式审查最多允许 2 轮。第 2 轮复核 SHALL 核验原 `BLOCKER` 修复情况及修复影响范围内新引入的任意实质 `BLOCKER`（含新 P0/P1、安全、资金、并发、契约或必需构建失败），仅禁止将非致命 `NOTE` 升级阻塞。第 2 轮仍存在真缺陷或连续两次出现同一失败签名时，MUST 立即停机标为 `[~] blocked`（区分 `product` 与 `harness`）。累计 verdict 与失败签名 SHALL 绑定未完成映射验收，不得因重新 `plan`、拆分、改名或换平台而清零。

#### Scenario: Round 2 rejects fix-introduced P1 regression

- **WHEN** 第 1 轮 `BLOCKER` 已修复，但修复代码在受影响范围内引入新的 P1 权限或契约缺陷
- **THEN** 第 2 轮复核不得判定 `PASS`，记录该新 `BLOCKER` 后立即将 WP 标为 `[~] blocked` 并交由人工裁决，不自动开启第 3 轮

#### Scenario: Re-planning or splitting does not reset cumulative ceiling

- **WHEN** 某 WP 经两轮失败进入 `[~] blocked` 后，用户或代理重新执行 `plan`、改名 WP ID 或拆出子包处理同一未完成验收
- **THEN** 新条目继承原累计 verdict 与失败签名历史，不自动获得新的 2 轮自治修复预算

### Requirement: Explicit recovery from blocked state

从 `[~] blocked` 恢复执行 SHALL 遵循可核查授权：`harness` 类环境或工具故障在确认恢复条件已真实满足后，可恢复执行受阻检查；`product` 缺陷或达到两轮上限的阻塞 MUST 经负责人明确处置（有限追加一次修复/复核额度、明确延后并保留 OpenSpec 未勾选，或有限接受已知限制）。有限接受已知限制 MUST 独立记录限制条件，SHALL NOT 伪记为必需技术验证已通过。

#### Scenario: Owner grants bounded extra cycle for blocked WP

- **WHEN** 负责人针对 `[~] blocked` 的 WP 明确授权一次有限修复与复核范围
- **THEN** 该 WP 在保留原累计 verdict 与失败记录的前提下恢复执行该有限范围，完成后仍须受该有限范围约束

#### Scenario: Owner accepts known limitation distinctly

- **WHEN** 负责人明确决定接受某项已知非致命限制而非继续修复
- **THEN** 看板与 WP 记录标明“负责人有限接受（含具体未验证/限制范围）”，不得将其记为必需技术验证通过

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
