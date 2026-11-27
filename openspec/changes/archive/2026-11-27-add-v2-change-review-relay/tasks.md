# Tasks

## 1. 核心契约与统一 Skill 扩展（payload/docs/ai-collaboration/v2/）

- [x] 1.1 更新 `payload/docs/ai-collaboration/v2/RULES.md` 与 `payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md`，新增 `review proposal [<change-id>]`、`fix proposal [<change-id>]`、`review change [<change-id>]` 与 `fix change [<change-id>]` 四个子命令及完整契约：固定追加式报告路径 `.ai/relay/<change-id>/review-proposal.md` 与 `review-change.md`（保留历次轮次、累计计数与失败签名）、封闭写权限白名单（`review` 严禁改 OpenSpec/产品文件含收到 `(a)` 后仅写记录停止；`fix proposal` 严守规划边界不改产品代码；`fix change` 不自动提交/归档/发版）、WP 与 `review change`/`fix change` 对同一未完成映射验收的双向累计计数及阻塞继承（不误并无关验收或阶段）、两阶段“只读目标身份解析（不以报告存在过滤候选）→ 只读前置准入（缺文件/已 `PASS`/未授权或继承 `[~] blocked` 零写入停止且保留 `CURRENT` 原字节或不存在状态）→ 准入后更新 `CURRENT` 与修复”、首行 `Change: <change-id>` 回显，以及固定提案身份 5 行 `Next Step` 卡映射；验证：`RULES.md` + `engrelay/SKILL.md` 合计逻辑行数 ≤ 150，`agent-rules.md` 保持 ≤ 18 行，全部内容 100% 原创 MIT 文本且保留 `v2/` 10 文件固定投影不变。

## 2. 只读诊断扩展与双宿主自动化测试（doctor.ps1 & test-v2-workflow.ps1）

- [x] 2.1 更新只读诊断脚本 `payload/docs/ai-collaboration/v2/scripts/doctor.ps1`：使用 `Safe-Path` 检查现有 `.ai/relay/*/review-proposal.md` 与 `review-change.md`（拒绝重解析点与路径逃逸）；在校验 `.ai/relay/CURRENT` 格式与路径安全边界后，当无 `board.md` 但 `openspec/changes/<id>/` 与 `.ai/relay/<id>/review-proposal.md`（或 `review-change.md`）均合法且无重解析点时输出 `Active relay change=<id> (valid: change review, no board yet)`（退出 0）；若两者均不满足，保持输出 `Active relay pointer stale: <id> (board.md missing)`（退出 0）；所有分支严格零写入且对重解析点/路径越界/非法字符返回退出 1。
- [x] 2.2 更新 `scripts/test-v2-workflow.ps1`，补齐：(a) 有效 `plan` 前 `CURRENT`（`openspec/changes/<id>/` + `review-proposal.md` 或 `review-change.md` 无 `board.md`）退出 0 且零写入；(b) 缺少 `openspec/changes/<id>/` 时输出失效提示退出 0 且零写入；(c) `openspec/changes/<id>` 或 `review-proposal.md` 为重解析点/junction 时退出 1 且零写入；(d) 维持现有 `RULES.md + SKILL.md <= 150` 行预算及 `CURRENT` 原有用例。在 `%TEMP%` 构建独立工作树测试包，分别使用 Windows PowerShell 5.1 与 PowerShell 7 运行 `scripts/test-v2-workflow.ps1` 与 `scripts/test-workflow-profiles.ps1` 并确认全部通过。

## 3. 跨会话行为演练与双语文档同步

- [x] 3.1 在 `%TEMP%` 一次性虚构夹具仓库与独立子代理会话中执行并记录跨平台变更审查接力演练（记录到 `docs/reviews/add-v2-change-review-relay/`，不安装到源仓库且演练后清理 `%TEMP%`），覆盖主路径与 R1–R3 反例：(a) `review proposal <id>` → `fix proposal <id>`（严守仅改 `openspec/changes/<id>/*` 规划边界、追加反馈、不改源码）→ 同一未污染审查会话执行 Round 2 `review proposal <id>` 通过（`Next Step` 推荐 `plan <id>`）；(b) `review change <id>` → `fix change <id>`（运行针对性验证、追加反馈、不自动提交/归档）→ Round 2 `review change <id>` `PASS`（`Command: none`）；(c) **R1 跨层级熔断与双向继承**：WP 已两轮 `[~] blocked` 且无 `(a)` 时，首次 `review change` 继承该同一未完成验收历史、未授权 `fix change` 零写入拒绝绕过（`Command: Wait`），仅在明确记录 `(a)` 后才可保留计数修复；反向变更级 `[~] blocked` 时 WP `do` 同样拒绝绕过；确认同变更下其他独立未阻塞验收不被误并；(d) **R2 身份与报告分离**：`CURRENT=A`（活动且无报告）、`B`（活动且有 `FIX REQUIRED` 报告）时，简写 `fix proposal` 与 `fix change` 锁定 `A`、提示缺报告并零写入停止，严禁跳去修复 `B`；(e) **R3 准入前零写入与 `CURRENT` 锁定**：`CURRENT=A` 时显式执行 `fix change B`（`B` 已 `PASS` 或未授权 blocked）保持 `CURRENT=A` 原字节与全部文件不变；`CURRENT` 缺失且仅 `B` 存在但不可修时保持 `CURRENT` 仍不存在；合法准入的 `fix` 正常更新 `CURRENT`；同时覆盖多候选列候选停止、旧卡固定提案身份与 `optional` 非自动激活检查。
- [x] 3.2 同步更新双语人类说明 `payload/docs/ai-collaboration/v2/README.md`、`payload/docs/ai-collaboration/v2/README.zh-CN.md`、根目录 `README.md`、`README.zh-CN.md` 与 `CHANGELOG.md`、`CHANGELOG.zh-CN.md`，补全四个变更级接力子命令、固定报告路径、写权限隔离、5 行卡流向及实际验证范围限制；确认不修改根目录 `snapshot.json`、`scripts/manage.ps1`、`scripts/update-snapshot.ps1` 与 `full`/`lite` 载荷，也不执行未授权 Git 提交、推送或发布。

## Workflow follow-up

- 实施与审查通过后，如需正式归档与发版，按 `docs/development.md` 的干净导出流程更新快照并另行由用户授权执行归档、提交与发布。
