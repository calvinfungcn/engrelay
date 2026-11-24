# Proposal

## Why

在真实跨仓库项目（如跨 `mis_app` / `MISMobileWeb` / `MISWebCore` 的多端并发变更）与多平台小额度订阅（ChatGPT Plus、Google AI Pro、Cursor Pro）组合使用场景下，现有 EngRelay v1（`full` 与 `lite`）暴露出结构性消耗与流程僵化问题：

1. **规则与上下文过度膨胀**：`full` 核心规范（`README.md`、`workflows.md`、`handoff-schema.md`、`agent-prompts.md`）累计约 5,837 行 / 338 KB，单次交接常连带十余个输入文件、SHA-256 指纹审计与大段结果报告，新会话尚未开始写代码就已消耗大量额度；`lite` 的 `RULES.md` 也已膨胀至 265 行 / 22.3 KB，且仍沿用微步骤交接与缺失 OpenSpec 拆包/分级编排能力。
2. **粒度失衡与无限修验循环**：大型 OpenSpec 变更容易被整批塞入单一 H 级批次，交接路径又强制经过 `Fix Engineer -> Reviewer -> Chief Designer -> Fix Engineer` 官僚中转；同时默认 3 轮硬上限被移除后，P0/P1 真缺陷与 P2/P3 边缘洁癖混作阻塞项，极易演变为十几到二十余轮的修验死循环。
3. **缺少面向小额度订阅的拆包与用量预判**：当前虽然具备 `C1–C5` 难度标签，但缺少从 OpenSpec 出发、按合理粒度切分工作包（Work Package, WP）并同时评估“风险（`S|M|H`）× 难度（`C1–C5`）× 体量（`XS/S/M/L`）× 节奏（`可断点/建议连续`）”的编排机制，导致用户无法据此分配不同平台与等待额度重置时机，也难以顺应现代平台原生的端到端执行能力。

## What Changes

引入 **EngRelay v2**（`WorkflowProfile: v2`）作为面向多平台小额度协作与 OpenSpec 交付的新一代工作流配置，同时保持现有 `full` 与 `lite` 配置冻结向后兼容、不自动迁移历史运行态：

1. **极简原则驱动协议（≤ 150 行硬预算）**：
   - 新增精简核心规则 `docs/engrelay/RULES.md` 与单一统一 Skill `engrelay`（`docs/engrelay/skills/engrelay/SKILL.md`），二者合计正文严格控制在 150 行（约 5 KB）以内，采用兼顾 GPT/Codex、Gemini 与 Claude 的原则驱动写法，彻底移除 `full` 手册与每步 `validate-runtime-state.ps1` 强制校验；全部新增规则与模板保持 100% MIT 原创。
   - 保留 `AGENTS.md` 条件激活边界（默认 `optional`，与其它控制器互斥，OpenSpec 为唯一需求与任务权威）。

2. **OpenSpec Orchestrator 拆包编排（`plan` 模式）**：
   - 读取 OpenSpec 提案、设计、规范与 `tasks.md` 并一次性检索 `docs/solutions/` 后，按“可被独立批准或打回的最小可测交付单元”切分为 `WP-01..N`，禁止按单个 DTO/字段拆包，也禁止把跨多仓大需求死绑成无法关闭的巨型批次。
   - 在唯一看板 `.ai/relay/<change-id>/board.md` 中显式抽取跨端 `Global Constraints`、`Interfaces`（`Consumes / Produces`）以及每个 WP 的仓库路径与变更范围边界；存在跨包待联调边界时明确建立联调承接 WP 与依赖映射。
   - 为每个 WP 独立评定：**风险（`S|M|H`）**、**难度（`C1–C5`）**、**任务形态（`ui|backend|concurrency|integration|docs|ops`）**、**体量/节奏（`XS|S|M|L` × `可断点|建议连续`，禁止产出超过 `L` 的巨包）** 与 **适用审查门禁**（由风险与显式审查要求决定，不由 `C1–C5` 触发）。

3. **平台原生闭环执行与无仪式断点（`do` 模式）**：
   - 执行平台在授权 WP 内连续完成实现、局部设计细节、自测与 diff 精简；退出时向 `.ai/relay/<change-id>/wp-XX.md` 写入不超过 60 行摘要，并给出 `DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED` 四态之一；仅当适用独立审查/验证要求为空（风险保持 `S` 且无显式审查要求）时允许直接关闭。
   - 平台额度或上下文即将耗尽时，仅追加不超过 15 行断点（`checkpoint`），切换平台直接继续 `do`，不触发交接校验脚本或额外审查；若实施中发现风险升级，必须刷新风险等级与独立审查/验证要求，不得以 `DONE_WITH_CONCERNS` 自关；遇 `BLOCKED` 必须改变策略，禁止原样重试。

4. **有界、按后果分级的独立审查与验证（`review` 模式）**：
   - 审查与验证独立性强制保留（实施与修复者不可自任）：`M` 须经独立代码审查及对 `BLOCKER` 修复的独立确认；`H` 须经独立代码审查及独立修复后验证（并入独立 `review` 模式）；无显式审查要求的 `S` 默认自测通过即关闭。优先选用不同模型家族执行审查，异构不可用时允许同家族真正独立会话承接，且仅更换模型家族不自动证明独立性。
   - 以 `board.md` WP 条目、`wp-XX.md` 与完整 WP 变更范围（覆盖跨仓库、未跟踪新文件、暂存与已提交区间，隔离共享工作树其他改动）为最小入口，按需定向只读查阅 OpenSpec、模块 `AGENTS.md`、调用方与源码（不强迫全量历史读入与 SHA-256 审计，取消 `Chief Designer` 中转）。
   - 复用实施者测试证据前确认其匹配当前受影响输入；严格区分 `review PASS`、`WP done` 与 `OpenSpec 验收完成`，仅对不影响本 WP 必需验收且已具名映射到下游承接 WP 的 `⚠️` 项允许审查 `PASS`；缺少承接或环境不可用时保留 OpenSpec 验收未完成。
   - **硬上限 2 轮断路器与历史继承**：第 2 轮核验原 `BLOCKER` 及修复影响范围内任何新引入的实质 `BLOCKER`（含新 P0/P1、安全、资金、并发、契约或必需构建失败），仅禁将非致命 `NOTE` 升级阻塞；第 2 轮未通过或连续两次相同失败签名立即标为 `[~] blocked`（区分 `product` 与 `harness`），仅阻塞下游依赖并呈现 3 项人工裁决出口。未完成验收的累计计数与失败历史跨拆分、重新 `plan` 与改名保留，从 `[~] blocked` 恢复须满足核实条件或负责人有限授权，负责人有限接受不得伪记为必需技术验证通过。

5. **按变更隔离的运行态与可选额度校准配置**：
   - 运行态存放于 `.ai/relay/<change-id>/`（`board.md` + `wp-XX.md`），不纳入 Git；支持可选项目自有 `docs/engrelay.config.md`（记录已核实构建/测试命令及用户个人平台额度手感备忘，留空不阻塞规划但不得跳过必需验收）；提供只读诊断脚本 `docs/engrelay/scripts/doctor.ps1`。

6. **BREAKING：新项目默认安装配置切换为 `v2`**：
   - 未安装项目省略 `-WorkflowProfile` 执行 `Install` 时默认安装 `v2`（仍保持 `WorkflowMode=optional` 与 `SkillTarget=none` 默认）。
   - 已安装 `full` 或 `lite` 的项目在 `Upgrade`、`SetMode`、`Status`、`CheckVersion` 时继续严格保留其原有配置身份，不隐式转换；`v2` 支持 `SkillTarget=none` 及单一宿主目标（复制统一的 `engrelay` Skill）。

## Capabilities

### New Capabilities

- `engrelay-v2-relay`: 定义 EngRelay v2 极简协议、OpenSpec Orchestrator 拆包与独立风险/难度/体量评估、平台原生执行与断点接力、有界独立审查与 `H` 级验证、两轮硬断路器与未完成验收累计历史继承，以及 `.ai/relay/<change-id>/` 运行态与只读诊断规范。

### Modified Capabilities

- `workflow-profiles`: 将官方包管理器支持的 `WorkflowProfile` 从 `full|lite` 扩展为 `v2|full|lite`，将新安装默认配置调整为 `v2`（同时保留已安装 `full`/`lite` 身份与现有隔离、所有权保护及受保护转换规则），并定义 `v2` 的固定部署集合与单统一 Skill 的 `SkillTarget` 支持。

## Impact

- **新增规范载荷**：`payload/docs/ai-collaboration/v2/`（`RULES.md`、`agent-rules.md`、`README.md`、`README.zh-CN.md`、`LICENSE`、`skills/engrelay/SKILL.md`、`templates/board.md`、`templates/wp.md`、`templates/project-config.md`、`scripts/doctor.ps1`）。
- **包管理器与快照脚本**：`scripts/manage.ps1`（支持 `v2` 默认安装、部署投影、`SkillTarget` 映射、清单校验与卸载清理；确保 `full` 排除 `v2/`）、`scripts/update-snapshot.ps1`（校验完整的 `v2` 固定源投影）。
- **测试与验证脚本**：新增 `scripts/test-v2-workflow.ps1` 验证 `v2` 安装生命周期、150 行预算上限与旧配置不隐式切换；在 `tasks.md` 中包含虚构一次性夹具上的代表性工作流行为演练（`S`/`M`/`H` 路径与断路器/风险升级分支）；更新既有 `scripts/test-*.ps1` 中依赖“省略 `-WorkflowProfile` 即安装 `full`”的夹具调用。
- **文档同步**：更新 `README.md`、`README.zh-CN.md`、`docs/development.md`、`docs/development.zh-CN.md` 中的配置说明与实际检查范围。
- **明确非目标**：不构建后台进程调度器或自动唤醒引擎；不自动迁移已有 `.ai/` 或 `.ai/engrelay-lite/` 运行态；不执行 Git 操作、真实部署或发布。
