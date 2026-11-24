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

在 `review` 模式下，独立于实施与修复者的会话（优先不同模型家族；异构不可用时允许同家族真正独立会话承接并记录实际工具/模型，仅更换模型家族不自动证明独立性）SHALL 以 `board.md` WP 条目、`wp-XX.md` 与完整 WP 变更范围（覆盖跨仓、暂存、未跟踪新文件及已提交区间，并隔离共享工作树其他改动）为最小入口，按需定向只读 OpenSpec、模块 `AGENTS.md`、调用方及源码。复用测试前核对其匹配当前输入；结论区分 `BLOCKER`、`NOTE` 与 `⚠️`，不经中转转述。

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

EngRelay v2 运行态 SHALL 存放于 `.ai/relay/<change-id>/`（`board.md` 与 `wp-XX.md`），按 OpenSpec 变更隔离并排除在 Git 提交之外，SHALL NOT 写入或校验 `full` 的 `.ai/handoff.md` 或 `lite` 的 `.ai/engrelay-lite/`。项目可维护自有的 `docs/engrelay.config.md` 记录已核实命令及个人平台额度手感备忘（留空不阻塞规划）。v2 SHALL NOT 强制要求每次交接运行结构校验脚本，仅提供可选只读诊断脚本 `docs/engrelay/scripts/doctor.ps1`。

#### Scenario: Multiple OpenSpec changes stay isolated

- **WHEN** 同一项目并行推进两个不同的 OpenSpec 变更
- **THEN** 各自运行态分别保存在 `.ai/relay/<change-id-a>/` 与 `.ai/relay/<change-id-b>/`，互不覆盖且不干扰既有 `.ai/handoff.md` 历史

#### Scenario: Blank personal quota calibration does not block planning

- **WHEN** `docs/engrelay.config.md` 中的平台额度手感备忘或命令栏位留空
- **THEN** `plan`、`do`、`review` 正常启动规划与执行，但必需的成果验收不得因配置留空而被跳过
