# Proposal: add-v2-change-review-relay

## Why

EngRelay v2（`2.0.1` 基线）已为 WP 级执行建立 `plan`、`do`、`review`、双车道复用、5 行推荐卡与 `.ai/relay/CURRENT`，但针对 **OpenSpec 提案审查**（`plan` 前）与 **整单变更实施审查**（归档/发版前）仍缺少原生命令与固定报告路径。跨平台评审时，操作者仍需临时手写长提示词并在多个窗口间复制带日期的文件名（如 `.ai/review-xxx-2026-11-25.md`）与反馈正文。

## What Changes

- **扩展统一 `engrelay` Skill 的四项提案/整单级接力子命令（不新增 Skill 文件或改变 v2 10 文件固定投影）**：
  - `review proposal [<change-id>]` / `fix proposal [<change-id>]`：固定读写追加式 `.ai/relay/<change-id>/review-proposal.md`。
  - `review change [<change-id>]` / `fix change [<change-id>]`：固定读写追加式 `.ai/relay/<change-id>/review-change.md`。
- **严格隔离写权限与双会话复用**：
  - `review proposal` 与 `review change` 只读产品源码、配置、测试与 OpenSpec 原文（`review proposal` 还须只读核对相关代码与规范）；仅允许写对应的 `.ai/relay/<change-id>/review-*.md` 与获准 `.ai/relay/CURRENT` 元数据，即使收到 `FIX REQUIRED` 或会话内 `(a)` 授权也只落盘并停止，确保同一审查会话保持独立可复用。
  - `fix proposal` 严守规划边界，只修订 `openspec/changes/<change-id>/*` 并追加反馈到 `review-proposal.md`（禁止改产品代码）；`fix change` 核对并修复已确认问题、补跑针对性检查、更新相关文档/`tasks.md` 并追加反馈到 `review-change.md`（不自动提交、归档或发布）。
- **继承两轮硬断路器、跨层级累计验收历史与 5 行 `Next Step` 推荐卡**：
  - 报告采用追加式结构（保留历次 `Round 1`/`Revision Feedback`/`Round 2` 与失败签名，不覆写历史）。
  - `review change` / `fix change` 与既有 WP（`board.md` `Progress Ledger` / `wp-XX.md`）对**同一未完成映射验收**双向共享并继承累计计数、失败签名与恢复限制：既不能在 WP 两轮阻塞后借新建 `review-change.md` 重新获得自治修复额度，也不能在变更级审查阻塞后切回 WP `do` 绕过限制；对确属不同的未完成验收或提案阶段与实施阶段，则按真实映射区分而不仅因 `<change-id>` 相同就强行合并。
  - 第 2 轮仍存在真缺陷或连续两次同一失败签名触发 `[~] blocked`（`product|harness`）；`fix` 对缺失报告、已 `PASS` 报告或未获 `(a)` 授权/未核验 `harness` 的 `[~] blocked` 拒绝盲改。
  - 每次 `review|fix` 退出输出固定提案身份（携带 `<change-id>`）的 5 行 `Next Step` 卡（`Primary`、`Command`、`Axes`、`Gate`、`Alternate`），由未授权/未核验阻塞切换为 `Command: Wait`。
- **严格拆分“目标变更身份解析”与“前置准入”，执行“准入后写入 `CURRENT`”**：
  - 所有变更级命令按两阶段推进：**阶段 1（只读目标身份解析）**仅核验活动变更身份（`openspec/changes/<id>/` 排除 `archive/`，或 `change` 命令可用的 `board.md`），绝不以 `review-*.md` 是否存在过滤目标；若 `CURRENT` 指向的活动提案 `A` 尚无报告，简写 `fix` 锁定 `A` 并因缺前置报告停止，绝不回退改选另一提案 `B`。**阶段 2（只读准入校验）**核验报告存在、最新结论可修及无未授权/未核验阻塞（含跨层级继承）。**仅当阶段 1 与阶段 2 全部通过后**才执行 `.ai/relay/CURRENT` 更新及目标修改；任何被拒绝的 `fix` 调用均严格零写入，保持 `CURRENT` 原字节（或不存在状态）与全部文件不变。
  - `docs/engrelay/scripts/doctor.ps1` 保持严格零写入与 `Safe-Path` 防重解析点边界，识别有效的 `plan` 前变更审查指针并照常报错/拒绝越界或损坏指针。

## Capabilities

### New Capabilities

- （无新增能力；全部变更属于 `engrelay-v2-relay` 既有跨平台接力能力的扩展。）

### Modified Capabilities

- `engrelay-v2-relay`：新增 `review proposal|change` 与 `fix proposal|change` 固定文件接力规范，扩展隔离运行态/`.ai/relay/CURRENT`/`doctor.ps1` 的 `plan` 前变更审查支持，以及扩展 5 行 `Next Step` 推荐卡到变更级审查/修复出口。

## Impact

- 预计变更范围：
  - 核心契约与诊断：`payload/docs/ai-collaboration/v2/RULES.md`、`payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md`、`payload/docs/ai-collaboration/v2/scripts/doctor.ps1`（`RULES.md` + `SKILL.md` 继续保持 `<= 150` 逻辑行预算，`agent-rules.md` 保持 `10/18`）。
  - 自动化测试与演练：`scripts/test-v2-workflow.ps1` 与一次性 `%TEMP%` 跨会话行为演练记录（`docs/reviews/add-v2-change-review-relay/`）。
  - 双语说明：`payload/docs/ai-collaboration/v2/README.md` / `README.zh-CN.md`、根目录 `README.md` / `README.zh-CN.md`、`CHANGELOG.md` / `CHANGELOG.zh-CN.md`。
- 兼容与非目标：
  - v2 固定 10 文件源投影不变，不修改 `scripts/manage.ps1`、`scripts/update-snapshot.ps1`、`workflow-profiles`、`full` 或 `lite`。
  - 不引入跨进程后台调度器，不自动执行 Git 提交、OpenSpec 归档或发版。
