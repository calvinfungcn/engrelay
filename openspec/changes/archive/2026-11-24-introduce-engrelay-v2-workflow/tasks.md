# Tasks

## 1. v2 协议、Skill 与模板（payload/docs/ai-collaboration/v2/）

- [x] 1.1 编写 100% 原创 MIT 许可的 `payload/docs/ai-collaboration/v2/RULES.md`、`payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md` 与 `payload/docs/ai-collaboration/v2/agent-rules.md`，覆盖条件激活、`plan`（`S|M|H` 风险与显式审查共同决定门禁、与 `C1–C5` 正交、`H` 修复后独立验证、`C1–C5` × `XS|S|M|L` × `可断点|建议连续`、`Global Constraints`、`Interfaces`、WP 仓库与 diff 边界、单次 `docs/solutions/` 检索）、`do`（四态退出、仅适用独立审查/验证要求为空时直关、风险升级刷新门禁、≤60 行摘要、≤15 行断点）与 `review`（独立性强制与异构优先/同家族独立会话回退、独立审查与 `H` 验证职责、最小入口与定向只读权威查阅、测试输入对应核对、`review PASS` 与验收完成区分、`⚠️` 下游具名承接、第 2 轮拒绝原 `BLOCKER` 及修复范围内新 P0/P1 实质回归、`[~] blocked` 区分 `product|harness` 及未完成验收累计历史继承与恢复授权）；验证 `RULES.md` 与 `engrelay/SKILL.md` 合计行数 ≤ 150 行且 `agent-rules.md` ≤ 18 行。
- [x] 1.2 编写 `payload/docs/ai-collaboration/v2/templates/board.md`、`wp.md`、`project-config.md`（含独立的风险列与适用审查要求列、`Repo & Diff Scope`、`Deferred / Handoff` 映射、审查工具/模型与累计历史/恢复记录栏位，及可选个人平台额度手感备忘），以及 `README.md`、`README.zh-CN.md`、`LICENSE`；确认模板与示例完全使用虚构样本、不含私人项目资料或非 MIT 文本。
- [x] 1.3 实现只读诊断脚本 `payload/docs/ai-collaboration/v2/scripts/doctor.ps1`，检查 `docs/engrelay/` 入口文件存在性、`RULES.md + engrelay/SKILL.md` 行数上限、可选 `docs/engrelay.config.md` 及 `.ai/relay/` 看板可读性，不写入目标目录，并在一次性临时目录验证其零写入与退出码 0/1 行为。

## 2. 包管理器与快照清单（scripts/manage.ps1 & scripts/update-snapshot.ps1）

- [x] 2.1 更新 `scripts/manage.ps1` 支持 `WorkflowProfile=v2|full|lite` 并把未指定参数的新安装默认值切换为 `v2`；在 `Get-BasePlan` 中添加 `v2` 固定投影并从 `full` 排除 `docs/ai-collaboration/v2/`；在 `Get-SkillCopyPath` 中支持 `v2` 将统一 `engrelay` Skill 复制到单一 `SkillTarget`；在 `Read-State`、`Adopt`、`Uninstall` 与 `Write-InstallDiscoveryGuidance` 中落实 `v2` 清单校验、私人 `v2` 拒绝、项目 `docs/engrelay.config.md` 与 `.ai/relay/` 保留以及空目录清理；通过临时夹具运行 `Install` / `Status` / `CheckVersion` / `SetMode` / `Upgrade` / `Uninstall` 验证。
- [x] 2.2 更新 `scripts/update-snapshot.ps1` 增加 `v2` 固定源投影完整性检查（缺文件或未知杂项文件时拒绝生成快照），并在临时工作树或干净导出 staging 目录运行验证其摘要输出与完整性拦截均符合预期。

## 3. 生命周期测试、回归适配与核心工作流演练（scripts/test-*.ps1 & 一次性夹具）

- [x] 3.1 新增 `scripts/test-v2-workflow.ps1`，在隔离临时目录覆盖：`v2` 作为默认新安装、`SkillTarget=none` 与非 `none` 宿主复制、`RULES.md + SKILL.md` ≤ 150 行（含 149/150/151 边界与换行）断言、`doctor.ps1` 只读诊断、`docs/engrelay.config.md` 与 `.ai/relay/` 在 `Upgrade`/`Uninstall`（含卸载后重装）中保留、拒绝私人 `v2`（含仅独立 `docs/engrelay.config.md`）接管，以及既有 `full`/`lite` 安装在省略参数执行 `Upgrade`/`SetMode` 时保持原配置不隐式切换；在 Windows PowerShell 5.1 与 PowerShell 7.6.10 下均通过（37 次调用 / 34 项断言）。
- [x] 3.2 核对并更新 `scripts/test-workflow-profiles.ps1`、`scripts/test-public-package.ps1`、`scripts/test-skill-discovery-guidance.ps1`、`scripts/test-human-doc-lifecycle.ps1` 中依赖“新安装默认 `full`”的历史断言（显式传入 `-WorkflowProfile full` 或补充新默认行为断言），在隔离包目录下运行受影响的测试脚本并确认通过（`test-workflow-profiles.ps1` 在 PS 5.1/7.6.10 通过 83 调用 / 32 检查，`test-human-doc-lifecycle.ps1` PS 5.1/7.6.10 通过 5 项，`test-public-package.ps1` PS 5.1/7.6.10 通过 2 项 / `frozen-161` 跳过；`test-skill-discovery-guidance.ps1` 因脚本硬编码要求 `1.8.0` 基线由合成 `1.8.0` 副本覆盖）。
- [x] 3.3 在虚构的一次性临时夹具仓库与实际可用独立子代理会话中，执行并记录代表性 `v2` 核心工作流行为演练（见 [2026-11-24-drill.md](../../../../docs/reviews/introduce-engrelay-v2-workflow/2026-11-24-drill.md)，不替代也不混同为脚本结构校验）：(a) 低风险 `S` WP（无显式审查要求）的 `plan → do → 自测关闭`；(b) `M`/`H` WP 的 `plan → do → ≤15 行断点真实第二会话 do 续跑（691343da）→ 独立审查（995acdeb）→ BLOCKER 修复 → 第 2 轮独立验证 → OpenSpec tasks.md 同步`；(c) 关键门禁与失败分支验证，覆盖第 2 轮拒绝修复引入的 P1 回归并进 `[~] blocked`、无承接或环境缺口时 `⚠️` 保持父验收未完成、`S/C4` vs `S/C1` vs `M/C1` 及 `S` 带显式审查要求的一致路由、`C1` 触及高风险边界及 `do` 中风险升级禁止自关、异构不可用时同家族真正独立会话承接并禁止自审/自任 `H` 验证、未跟踪/暂存/已提交/多仓库 diff 范围与直接查阅 OpenSpec，以及拆分/重规划继承累计计数和 `[~] blocked` 有限恢复或负责人有限接受；逐项记录输入、实际动作、结果及未验证外部宿主限制。

## 4. 双语文档同步与发布说明准备

- [x] 4.1 同步更新根目录 `README.md`、`README.zh-CN.md` 与 `docs/development.md`、`docs/development.zh-CN.md`，说明 EngRelay v2 定位、默认配置切换、独立 `S|M|H` 风险门禁、`C1–C5` × `XS/S/M/L` 使用示例及 `full`/`lite` 冻结兼容路径；检查交叉链接与命令示例与实测一致。
- [x] 4.2 更新 `CHANGELOG.md` 的待发布变更记录草稿并注明实际运行检查与未验证宿主范围；保持工作区干净，不擅自更改根 `snapshot.json`（除非执行授权的发布前干净导出流程）或执行 Git 提交/推送/发布。

## Workflow follow-up

- 如后续需正式发布新版本，按 `docs/development.md` 的干净导出流程生成发布包、在 staging 运行 `update-snapshot.ps1 -ForRelease` 刷新快照并另行由用户授权提交与发布。
