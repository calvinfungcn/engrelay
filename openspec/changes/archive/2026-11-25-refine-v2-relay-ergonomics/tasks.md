# Tasks

## 1. 核心契约、统一 Skill 与模板改进（payload/docs/ai-collaboration/v2/）

- [x] 1.1 更新 `payload/docs/ai-collaboration/v2/RULES.md` 与 `payload/docs/ai-collaboration/v2/skills/engrelay/SKILL.md`，补充：(a) 统一 `review` 写入白名单（仅 `.ai/relay/<change-id>/`、显式 `<change-id>` 或唯一看板回退时的 `.ai/relay/CURRENT` 活动目标选择元数据、及验收满足时的 `tasks.md`），严禁修改产品源码/配置/测试（含收到 `(a)` 有限追加授权时仅写记录并停止，由执行/修复会话按最新 `BLOCKER` 修复实现双会话复用）；(b) 每次 `plan`、`do`、`review` 末尾输出唯一明确首选动作的 4–6 行 `Next Step` 推荐卡，跨会话命令一律固定携带 `<change-id>`，并严格区分预算内 `FIX REQUIRED` / 已确认 `(a)` 授权 与 未获授权 `product` 阻塞 / 未核验 `harness` 阻塞（后两者禁止生成可执行 `do`/重跑命令）；(c) `.ai/relay/CURRENT` 单行指针更新、手工简写解析与单次调用目标锁定、首行 `Change: <change-id>` 回显、仅指针缺失/失效且多看板时列出候选禁盲猜及不自动激活边界。验证：`RULES.md` + `engrelay/SKILL.md` 合计逻辑行数 ≤ 150，`agent-rules.md` 保持 ≤ 18 行。
- [x] 1.2 更新 `payload/docs/ai-collaboration/v2/templates/wp.md`，在 `Review / Verification` 栏位明确“修复请切回实施/修复会话执行 `do`”的双车道交接提示，并在末尾增加简洁的 `Next Step` 交接/授权占位提示；验证所有内容为 100% 原创 MIT 文本且不含私人项目资料。

## 2. 只读诊断与自动化回归测试（doctor.ps1 & test-v2-workflow.ps1）

- [x] 2.1 更新只读脚本 `payload/docs/ai-collaboration/v2/scripts/doctor.ps1`，增加 `.ai/relay/CURRENT` 安全与只读检测：校验路径及重解析点边界不逃逸 `.ai/relay/`、验证单行变更名合法正则（`^[A-Za-z0-9][A-Za-z0-9._-]*$`）、对有效指针输出 `Active relay change=<id> (valid)` 并退出 0、对缺失 `board.md` 的失效指针输出非致命提示并退出 0（零写入）、对格式非法或路径越界指针拒绝并退出 1（零写入）。
- [x] 2.2 更新 `scripts/test-v2-workflow.ps1`，新增 `CURRENT` 有效指针（exit 0）、失效指针（exit 0 + 提示）、非法格式/路径穿越（exit 1 + 零写入）及 `RULES.md + SKILL.md` ≤ 150 行断言，在一次性完整工作树测试包上分别使用 Windows PowerShell 5.1 与 PowerShell 7 运行 `test-v2-workflow.ps1` 与 `test-workflow-profiles.ps1` 并确认全部通过。

## 3. 行为演练与双语文档同步

- [x] 3.1 在 `%TEMP%` 一次性虚构夹具仓库与真实独立子代理会话中完成并记录行为演练（见 `docs/reviews/refine-v2-relay-ergonomics/`，不安装到本仓库且演练后清理 `%TEMP%`），覆盖核心路径与审查反例：(a) **R3/双车道复用**：显式 `review <change-id> <WP-XX>` 更新 `CURRENT`，唯一看板时简写 `review <WP-XX>` 合法补写 `CURRENT`，未激活任务与 `doctor.ps1` 不写 `CURRENT`；会话 B 在 Round 1 `FIX REQUIRED` 及收到 `(a)` 授权后均拒绝改产品代码并保持独立性，会话 A 修复后仍由会话 B 执行 Round 2 验证；(b) **R1/跨会话锁与双看板边界**：保存提案 A 携带固定提案名的 `Next Step` 推荐卡后由另一会话将 `CURRENT` 切至 B，再复制原卡仍精确指向 A；同时存在 A/B 两看板时，有效 `CURRENT` 下简写正确解析至 `CURRENT`，仅当 `CURRENT` 缺失/失效且存在 A/B 两看板时列候选并停止；(c) **R2/阻塞恢复边界**：第 2 轮失败且负责人尚未授权时不输出该 WP 的可执行 `do` 修复命令，确认记录 `(a)` 后才输出固定提案身份的 `do <change-id> <WP-XX>` 且保留原计数不重复索要批准；未满足恢复条件的 `harness` 阻塞不建议原样重跑；每张卡片均有唯一明确首选动作且次要项清晰标注。
- [x] 3.2 同步更新双语人类说明 `payload/docs/ai-collaboration/v2/README.md`、`payload/docs/ai-collaboration/v2/README.zh-CN.md`、根目录 `README.md`、`README.zh-CN.md` 与 `CHANGELOG.md`、`CHANGELOG.zh-CN.md`，反映双会话复用、`Next Step` 推荐卡、`CURRENT` 简写用法及实测范围限制；确认不修改根目录 `snapshot.json` 且不执行未授权 Git 提交或发布。

## Workflow follow-up

- 实施与审查通过后，如需正式发版，按 `docs/development.md` 的干净导出流程更新发行快照并另行由用户授权提交与发布。
