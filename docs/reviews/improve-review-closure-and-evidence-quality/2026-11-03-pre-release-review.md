# Pre-release review — improve-review-closure-and-evidence-quality

## Metadata

- Recorded on: `2026-11-03`
- Review role: independent Code Reviewer
- Review agent: `Codex reviewer /root/review_closure_evidence`
- Persistence: 审查代理只读返回完整结论，由父代理保存；父代理未代替独立审查者作 verdict。
- Related implementation batch: `engrelay-review-closure-evidence-20261103-01`
- Bounded review scope: `engrelay-review-closure-evidence-pre-release-20261103-01`
- Authority: 负责人本次要求完整审查，通过后归档、提交和发布。
- Prior record: [round-01](2026-11-03-round-01.md)，原批已关闭，历史完成 verdict 为 1。
- Count: 本次单次追加审查产生 1 个 verdict，关联同一验收历史累计为 2；不重开原关闭快照，不重置计数，不自动授权修复或新三轮循环。

## Scope

完整审查本提案全部已授权验收、最终候选差异、兼容性、证据对应、文档和交付隐私。
基线 HEAD 为 `f061085de4b558fb13bd62ff702d67b8457a607a`，送审候选为该基线上 23 个未提交文件的实际工作树及暂存差异。
父代理保存报告前对完整 diff 运行 `git diff HEAD --binary | git hash-object --stdin`，输出 `c8f27bc3e3f5db8f121d054ec1db450db13cc14a`；这是所注明 PowerShell 管道的候选对应值，并非提交 ID。

已逐项检查 proposal、design、两份 delta、tasks、全部产品差异、双语说明、场景原始 JSON、执行日志和首轮审查。
本轮只读，不修改产品、原关闭状态、旧 verdict 或旧评分；不作真实项目安装、全局配置变更或业务外部调用。

## Evidence

- 规划权威：`openspec/changes/improve-review-closure-and-evidence-quality/` 的 proposal、design、两份 delta 和唯一 tasks.md。
- 场景交付：[scenario-evidence.md](scenario-evidence.md)；原始输入与观察位于约定的忽略目录 `.ai/review-closure-evidence/scenarios/`。
- 实施证据：`.ai/review-closure-evidence/implementation-result.md`、`scenario-execution.log`。
- 产品范围：Full README、agent-prompts、workflows、review-round 模板；Lite RULES、task 模板；对应 operator-guide、Lite README、根 README 和 CHANGELOG 两种语言。
- 六个候选规则文件的实际 SHA256 均与场景摘要一致。指纹对应只证明内容匹配，不能单独证明观察来自实际 Agent 执行。
- 严格 OpenSpec 校验实测 exit 0。该结果证明规划结构符合校验要求，不证明行为验收。
- `git diff --check HEAD` 实测 exit 2。旧记录中的 `git diff --check` 未覆盖已经暂存的候选内容。

## Findings

### PR-01 — must-fix / P1：五类场景执行来源不足以支持完成声明

定位：[场景观察](scenario-evidence.md:40)、实施结果第 58 行、[design 第 82 行](../../../openspec/changes/improve-review-closure-and-evidence-quality/design.md:82)。

原始 JSON 同时包含输入、正确规则及已填写的评价。现存日志记录读取这些评价和检查规则文本后的 PASS，不能单独证明实际输入经过 Agent 判断后取得这些返回。
所报 `scratch/test-scenarios.ps1` 当前不存在，也未提供可核对的具名输入与会话返回对应。
场景2声称检查工作区和暂存交付副本，但未保存可供复核的实际脱敏交付副本。

这不足以认定造假，也不足以确认 design 要求的真实场景观察已经完成。受影响的是 tasks 1.1、1.2、2.1 的场景验收，以及据此作出的完成声明；不能仅凭 8/8 勾选确认当前提案验收全部成立。

最小修复：已有真实记录时补充具名来源和输入／返回对应；否则仅重做五类有界场景，保存输入、实际判断及场景2脱敏产物。不要把预填判断的字段断言当作 Agent 演练。无需新增宿主矩阵、评分体系或通用采集平台。

### PR-02 — must-fix / P2：场景2交付摘要重新写入禁止交付的合成标识

定位：[场景2摘要](scenario-evidence.md:56)、[零残留声明](scenario-evidence.md:60)、[design 第 87 行](../../../openspec/changes/improve-review-closure-and-evidence-quality/design.md:87)。

摘要复述了输入中指定为禁止交付的原值，同时声称工作区和暂存副本确认零残留。虽然这些值是虚构的，并非真实凭据泄露，但违反本场景明确的输出验收，无法支撑零残留结论。本报告不复述这些原值。

最小修复：交付摘要仅保留字段名、别名和计数；对实际脱敏产物、摘要及适用暂存副本执行不输出原值的存在性检查。原始虚构输入可继续留在约定的忽略目录。无需重新运行业务测试。

### PR-03 — must-fix / P2：完整待提交候选未通过要求的 diff 检查

定位：[场景摘要第 3 行](scenario-evidence.md:3)、[collaboration-package delta 第 128 行](../../../openspec/changes/improve-review-closure-and-evidence-quality/specs/collaboration-package/spec.md:128)、[workflow-profiles delta 第 39 行](../../../openspec/changes/improve-review-closure-and-evidence-quality/specs/workflow-profiles/spec.md:39)。

实测 `git diff --check HEAD` exit 2，包括摘要尾随空格和三处 EOF 空行。此前只运行 `git diff --check`，在候选已经暂存时不能证明完整候选干净。

最小修复：只处理对应空白，随后检查完整候选或暂存差异并分别记录退出码；无需重跑场景行为。

## Conclusion

- Verdict: **FAIL**；当前不满足归档、提交和发布条件。
- 原首轮 PASS、历史 5/5 评分和关闭快照保持原样；本轮通过新记录披露当前未解决验收，不改写历史。
- 其余审查未发现需要修复的产品契约缺陷：Full／Lite 的审查范围、有限授权、历史保留、证据对应、归档结束及评分归因基本一致；Lite 保持自包含，双语说明实质对应。
- 本提案未修改安装器、校验器、受管路径、现有机器字段、许可或根发行快照。
- 可保留现有规则差异、对应文件指纹、未变输入的 Lite 状态回归证据和本次静态兼容性结论；需补齐场景来源、重验场景2交付隐私并修复完整候选格式，无需全套回归。
- Implementation delivery advisory rating: **3/5**。规则完成度较好，但必要验收证据不足，隐私场景输出和最终检查有明确漏项。归因限于本次证据交付及实施自检；不据此推断模型能力，不替换首轮评分，也不对审查者另行评分。
- 本次单次追加审查已完成；归档／提交／Release 的前提未满足，未执行这些操作。修复与独立复核需适用授权，不自动从本次审查请求推定新三轮额度。

## Persistence and next boundary

父代理将本报告与三个发现加入现有索引。原任务和 handoff 字节级副本保存在忽略目录 `.ai/archive/engrelay-review-closure-evidence-20261103-01/pre-release-baseline/`。
当前关联审查范围按真实 FAIL 等待负责人处置，保留原验收映射与累计 2 个 verdict；没有以新名称取得新额度。
