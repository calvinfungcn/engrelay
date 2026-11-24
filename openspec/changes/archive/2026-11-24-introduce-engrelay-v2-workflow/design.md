# Design

## Context

动机与背景见 [proposal.md](proposal.md)。在当前仓库实现中，产品规范与脚本载荷位于 `payload/docs/ai-collaboration/`，其中 `full`（1.7.0 演进至今）与 `lite`（1.10.0 引入，位于 `payload/docs/ai-collaboration/lite/`）共用 `scripts/manage.ps1`、`scripts/update-snapshot.ps1` 与版本 2 清单（`.ai-collaboration-install/manifest.json`）。本设计在不破坏已有 `full`/`lite` 安装的前提下，新增 `v2` 配置作为新项目的默认轻量化编排与跨平台接力工作流。

## Goals / Non-Goals

**Goals:**
- 将 `v2` 核心规则与 Skill 总正文控制在 150 行（约 5 KB）以内，单次会话上下文增量极低，同时适配 GPT/Codex（原则驱动）、Gemini 与 Claude。
- 建立从 OpenSpec 出发的三动作闭环（`plan` 拆包与多维评估、`do` 平台原生执行与断点、`review` 有界独立审查与 `H` 级验证），使风险门槛清晰、子任务可独立锁定、遇阻可隔离而不拖死全局。
- 复用现有 `manage.ps1` 的清单 v2 保护、漂移拒绝、项目自有文档保留与受控卸载机制，将 `v2` 设为新安装默认配置。

**Non-Goals:**
- 不在 EngRelay 中构建类似 OmO 的运行时调度器、后台守护进程、自动唤醒或独立多代理执行引擎。
- 不对已有项目中的 `full`（`.ai/handoff.md`）或 `lite`（`.ai/engrelay-lite/`）在途任务进行自动迁移或强制转换。
- 不引入发布脚本自动推送、Git 提交或生产部署能力。

## Decisions

### 1. 源码与安装目录布局（`payload/docs/ai-collaboration/v2/` → `docs/engrelay/`）

- **决策**：遵循仓库 `AGENTS.md` 对产品载荷路径的约定，将 `v2` 源载荷集中存放在 `payload/docs/ai-collaboration/v2/`；安装到目标项目时投影至 `docs/engrelay/`（项目配置实例为根目录 `docs/engrelay.config.md`），运行态固定使用 `.ai/relay/<change-id>/`。
- **目录投影**：
  - `docs/engrelay/RULES.md`（≤ 75 行）
  - `docs/engrelay/skills/engrelay/SKILL.md`（≤ 75 行，与 `RULES.md` 合计 ≤ 150 行）
  - `docs/engrelay/README.md` 与 `docs/engrelay/README.zh-CN.md`（人类快速参考）
  - `docs/engrelay/LICENSE`（MIT 许可声明）
  - `docs/engrelay/templates/board.md`、`wp.md`、`project-config.md`
  - `docs/engrelay/scripts/doctor.ps1`（只读安装与预算诊断）
  - `docs/engrelay.config.md`（仅首次缺省时由模板生成，归属项目，`Upgrade`/`Uninstall` 保留）
- **替代方案及取舍**：曾考虑直接覆写修改 `lite/`；但 `lite` 已绑定 `.ai/engrelay-lite/` 路径、`validate-state.ps1` 门禁与既有回归契约，直接改造会破坏既有约定。独立新增 `v2/` 可令 `full` 与 `lite` 完全冻结，零回归干扰。

### 2. 单一统一 Skill 与宿主发现支持

- **决策**：只提供 1 个统一 Skill `engrelay`（`docs/engrelay/skills/engrelay/SKILL.md`），内部通过 `plan` / `do` / `review` 三个模式分支驱动，并允许 `v2` 在 `manage.ps1` 中同时支持 `SkillTarget=none`（默认，显式读取规则）以及任意有效单一宿主目标（将 `engrelay/SKILL.md` 复制到 `<target>/skills/engrelay/SKILL.md`）。
- **替代方案及取舍**：曾比较拆分为 `engrelay-plan`、`engrelay-do`、`engrelay-review` 三个 Skill；但三个 Skill 需要重复声明激活边界与数据结构，反而拉高静态字节数且增加多平台发现维护成本。统一 `engrelay` Skill 既能守住 150 行硬预算，又便于无 Skill 平台直接提示词调用。

### 3. 精简 `AGENTS.md` 受管入口块

- **决策**：新增 `payload/docs/ai-collaboration/v2/agent-rules.md`（≤ 18 行），继续沿用既有 `<!-- ai-collaboration:begin -->` / `<!-- ai-collaboration:end -->` 标记与 `WorkflowMode` / `WorkflowProfile` / `Package version` 三行头声明，使 `manage.ps1` 的 `Install`、`SetMode`、`Upgrade`、`Uninstall` 与漂移校验完全统一。
- **行为边界**：明确 `optional`（默认）模式下不因发现 `.ai/relay/` 或 `engrelay` Skill 而自动激活；明确禁止在 `v2` 任务中混用 `full` 的 7 个 Skill、`.ai/handoff.md` 或 `validate-runtime-state.ps1`。

### 4. `board.md`、`wp-XX.md` 契约与多维风险/审查收敛规则

- **`board.md` 结构**（`.ai/relay/<change-id>/board.md`，目标 < 130 行）：
  - **元信息**：OpenSpec 路径、`Progress Ledger`（每完成或阻塞 1 个 WP 追加 1 行结论；同时按未完成 OpenSpec 验收条目关联累计 verdict 与失败签名）。
  - **`Global Constraints`**：从 OpenSpec 抽取的跨包硬红线（精确字段名、命名约定、默认开关、禁止触碰边界）。
  - **WP 总表**：列为 `WP | 模块 | OpenSpec | 风险 | 难度 | 体量/节奏 | 审查要求 | 依赖 | 状态 | 负责/审查`。
    - 风险与审查门禁：`S | M | H` 与显式审查要求共同决定独立审查/验证门禁（`C1–C5` 仅作模型能力建议，不单独触发强制审查）：无显式审查要求的 `S` 自测通过即关闭；存在显式审查要求或 `M` 须经独立代码审查及 `BLOCKER` 修复确认；`H` 须经独立代码审查及独立修复后验证。独立性为硬约束（实施/修复者不可自任），优先采用不同模型家族，异构不可用时允许同家族真正独立会话承接并记录实际工具/模型，仅更换模型家族不自动证明独立性；
    - 难度：`C1–C5`（沿用既有五级认知能力含义，仅调度模型档位）；
    - 形态：`ui | backend | concurrency | integration | docs | ops`（记录于 WP 详情行）；
    - 体量：`XS`（1–2 文件局部改动）/ `S`（3–5 文件常规实现）/ `M`（5–10 文件联动或需构建本地库校验）/ `L`（高密度核心与多轮调试，单平台新窗口上限）；**严格禁止超出 `L`**；
    - 节奏：`可断点` / `建议连续`；
    - 状态：`[ ] todo` / `[ ] in-progress` / `[ ] in-review` / `[x] done` / `[~] blocked`。
  - **WP 详情块**（每个 WP 6–10 行）：`Repo & Diff Scope`（声明所属仓库相对路径、改动文件边界或基线，覆盖暂存/未跟踪新文件/已提交区间并隔离共享工作树兄弟 WP 改动）、`Consumes`、`Produces`、`References`（`plan` 阶段一次性查 `docs/solutions/` 后挂入的 0–2 条路径）、`Deferred / Handoff`（如有 `⚠️` 跨包待验证项，具名指定承接的下游联调 WP 与依赖）、`Done & Verify`（精确命令与可观察验收）。
- **`wp-XX.md` 结构**（`.ai/relay/<change-id>/wp-XX.md`）：
  - **实现摘要**（≤ 60 行）：退出状态（`DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED`）、实际仓库与改动范围（基线/提交区间或未跟踪+暂存+未暂存文件清单，便于多仓或先提交后审查）、已跑命令与输入对应说明、自简清理说明、风险变更记录（如发现触发 `M`/`H` 升级则同步刷新门禁，禁止以 `DONE_WITH_CONCERNS` 自关；仅当适用独立审查/验证要求为空时允许直接标 `[x] done`）、已知限制。
  - **中断断点**（可选，≤ 15 行）：仅在额度/上下文耗尽交接时追加（已完成 / 未完成 / 踩坑 / 下一步），供另一平台直接续跑 `do`，不触发 `review`。
  - **独立审查与验证记录**（≤ 50 行 / 轮，最多 2 轮）：
    - **独立性与入口**：记录实际审查工具与模型；独立性强制要求（实施/修复者不可自任），优先不同模型家族，异构不可用时同家族真正独立会话可承接。以 `board.md` WP 条目、`wp-XX.md` 与完整 WP 变更范围为最小入口，按需定向只读查阅权威 OpenSpec、模块 `AGENTS.md`、调用方及完整源码，不强制全量历史读入或逐文件 SHA-256 审计。复用测试输出前先核对其匹配当前受影响代码与输入。
    - **三态概念分离**：明确区分 `review PASS`（针对本 WP 自身代码质量的审查通过）、`WP done`（看板工作包完成）与 `OpenSpec 验收完成`（映射需求全部通过必需验证）。仅当 `⚠️ Cannot verify from diff` 不阻塞本 WP 必需验收且已在 `board.md` 具名映射到下游承接 WP 时，才允许本 WP `review PASS`；缺少承接或联调环境不可用时，关联 OpenSpec `tasks.md` 与父变更保持未完成，独立 WP 可继续。
    - **第 2 轮与断路器**：第 2 轮核验原 `BLOCKER` 修复与修复影响范围内新引入的任意实质 `BLOCKER`（含新 P0/P1、安全、资金、并发、契约或必需构建失败），仅禁止将非致命 `NOTE` 升级阻塞。第 2 轮未通过或连续 2 次相同失败签名时，立刻停机标 `[~] blocked`，标明 `failure_class: product | harness` 与 3 项人工裁决出口。
    - **历史继承与恢复授权**：累计 verdict 与失败签名绑定未完成映射验收，拆分、重跑 `plan`、改 WP ID 或换平台均不重置计数。从 `[~] blocked` 恢复时，`harness` 阻塞需核实恢复条件成立；`product`/上限阻塞须由负责人明确选定：① 有限追加一次修复与复核范围（保留历史轨迹）、② 明确延后并保留 OpenSpec 未勾选，或 ③ 负责人有限接受已知限制（独立注明限制，严禁伪记为必需技术验证通过）。
- **可选项目配置 `docs/engrelay.config.md`**：记录已核实构建/测试命令、仓库限制，以及可选的**个人平台额度手感备忘**。所有条目留空均不阻塞规划，但不得因命令留空而跳过必需成果验收。

### 5. `scripts/manage.ps1` 与 `scripts/update-snapshot.ps1` 改造

- **`scripts/manage.ps1`**：
  - 参数 `[ValidateSet('v2', 'full', 'lite')][string]$WorkflowProfile`，初始默认 `$script:resolvedProfile = 'v2'`。
  - `Get-BasePlan` 新增 `$script:resolvedProfile -eq 'v2'` 分支，从 `payload/docs/ai-collaboration/v2/` 映射固定 9 个包文件至 `docs/engrelay/`，加上 `docs/engrelay.config.md`（`kind = 'project-document'`）、`AGENTS.md`（使用 `v2/agent-rules.md`）与 `.gitignore`（追加 `.ai/` 与 `.ai-collaboration-install/`）。
  - `full` 分支在扫描 `payload` 时除排除 `docs/ai-collaboration/lite/` 外，同步排除 `docs/ai-collaboration/v2/`。
  - `Get-SkillCopyPath` 新增 `v2` 分支：当 `SkillTarget != 'none'` 时，仅将 `docs/engrelay/skills/engrelay/SKILL.md` 复制到 `$targets[$SelectedTarget]/skills/engrelay/SKILL.md`。
  - `Read-State` 允许 `workflowProfile` 为 `v2 | full | lite`。
  - `Adopt` 拒绝私人 `v2` 布局（与 `lite` 规则一致）；`Uninstall` 对 `v2` 仅清理因本次安装新建且现为空的 `docs/engrelay/` 目录树，保留 `docs/engrelay.config.md` 与 `.ai/relay/`。
  - `Write-InstallDiscoveryGuidance` 为 `v2` 输出精简路径提示（`docs/engrelay/RULES.md`、`docs/engrelay.config.md`、`engrelay` Skill 复制状态与未知宿主加载说明）。
- **`scripts/update-snapshot.ps1`**：
  - 在既有 `lite` 固定源投影完整性检查旁，新增等价的 `v2` 固定源投影校验（校验 `payload/docs/ai-collaboration/v2/` 下全部必需文件齐全且无未知杂项文件）。

### 6. 许可与来源边界（依据 `CONTRIBUTING.md`）

- 本次所有 `v2` 规则、Skill 文本、模板与 `doctor.ps1` **100% 原创编写并使用 MIT 许可**。
- 仅在理念层面借鉴如下工程思想，**严禁直接复制任何非 MIT 外部提示词文本（特别是 OmO 的 SUL-1.0 提示词）**：
  - 借鉴 Superpowers 的“审查可独立批准/打回”粒度标准、`Global Constraints` + `Interfaces` 契约前置、`⚠️ Cannot verify from diff` 分级与最小入口机制；
  - 借鉴 OmO 的“原则驱动短规则适配 GPT 系模型”、强内聚不拆碎、稀缺模型投低频高杠杆节点、`[~]` 隔离阻塞与 `product | harness` 故障区分；
  - 借鉴 Compound Engineering 的“后果分级审查”、一次前置检索 `docs/solutions/` 与提交前自简 diff。

## Risks / Trade-offs

- **[Risk] 默认 `Install` 从 `full` 切换为 `v2` 会使未传 `-WorkflowProfile` 的旧夹具测试失败**
  → **Mitigation**：审查 `scripts/test-workflow-profiles.ps1`、`scripts/test-public-package.ps1`、`scripts/test-skill-discovery-guidance.ps1`、`scripts/test-human-doc-lifecycle.ps1` 中的历史 `full` 夹具调用，将明确测试 `full` 行为的用例显式加上 `-WorkflowProfile full`；同时新增默认安装为 `v2` 的专项测试。
- **[Risk] 150 行超精简规范在后续迭代中再次发生“防御性规则膨胀”**
  → **Mitigation**：在 `docs/engrelay/scripts/doctor.ps1` 与自动化测试脚本 `scripts/test-v2-workflow.ps1` 中内建硬性行数校验（`RULES.md + engrelay/SKILL.md <= 150` 行），任何超限改动直接在本地验证失败。
- **[Risk] 仅有安装生命周期与行数检查不足以证明 v2 实际协作行为（如两轮断路器、跨平台断点、H 级独立验证）可用**
  → **Mitigation**：在 `tasks.md` 中安排虚构一次性夹具的端到端核心路径与 R1–R5 失败分支代表性演练，诚实记录输入、实际步骤、输出和未验证宿主限制，不以 `doctor.ps1` 或字面匹配替代行为证据。
- **[Risk] 取消每步 `validate-runtime-state.ps1` 后，跨平台手工修改 `board.md` / `wp-XX.md` 可能出现格式轻微偏差**
  → **Mitigation**：将模板字段设计为人眼与 AI 极易对齐的极简 Markdown 表格与短列表，并在 `doctor.ps1` 中提供按需运行的只读状态诊断（不作为交接阻断门禁）。

## Migration Plan

1. **包内增量落地**：先在 `payload/docs/ai-collaboration/v2/` 落地完整规范与模板并验证行数预算，再扩展 `scripts/manage.ps1` 与 `scripts/update-snapshot.ps1`。
2. **存量项目零打扰**：已安装 `full` 或 `lite` 的项目执行 `Upgrade` / `SetMode` 时自动保持原有配置；仅当用户主动希望从 `full`/`lite` 切到 `v2` 时，按既有受保护转换流程（保存证据、受保护 `Uninstall`、再 `Install -WorkflowProfile v2`）切换。
3. **测试、演练与文档对齐**：通过隔离临时目录套件完成 `v2` 安装生命周期、`full`/`lite` 回归及代表性工作流行为演练后，按用户单独授权走 `docs/development.md` 的干净导出与发布快照流程。
