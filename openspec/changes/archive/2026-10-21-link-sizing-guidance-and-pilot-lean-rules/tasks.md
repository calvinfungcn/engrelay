# Tasks

本文件是本变更唯一的实施与验证清单。全部条目从未实施状态开始；规划工件齐备不代表产品已完成。本批是一个连贯的交付批次，下列条目是其内部步骤，不按文件或样本另开生命周期。累计 Review round 从 0 开始，不复制旧批次的额度。

## 1. 估算定义可达性与措辞统一

- [x] 1.1 按 design 决策 1、2，在 `payload/docs/ai-collaboration/agent-prompts.md` 的 Chief Designer Focus 增加一行可选修改规模/人工投入引用，在 Implementation Engineer 已有的投入实质变化一句末尾追加同一锚点；把 `payload/docs/ai-collaboration/skills/ai-collab-start/SKILL.md` 第 4 步的 “the first role” 改为 “the Initial role”。不修改生成的宿主副本、模板、validator 或其他角色。验证：确认 `README.md#optional-sizing-and-effort` 对应的标题存在；仓库内恰好出现两处该锚点引用，且都没有复制 L 区间；新措辞不使用 sizing 一词；`git diff --check` 返回 exit 0；差异只涉及这两个产品文件；记录两个文件改动前后的字节数。
- [x] 1.2 在双语 CHANGELOG 中写入本批实际发生的 Unreleased 变化，不改版本号；在双语 OpenSpec 导航中新增本变更一行，状态为“已确认待实施”，并链接 tasks.md。验证：中英文实质对应，链接可达；导航不复制清单进度或计数；根 README 不改动，并在证据中说明公开行为描述没有变化。

## 2. 试点取证

- [x] 2.1 按 design 决策 3 准备试点：在任何样本运行之前，把 S1–S7 的输入要点和预期写入 `.ai/link-sizing-pilot/` 下的预登记文件，并记录其 SHA256；通过 `git archive v1.9.5` 导出基线文档，从工作区复制候选文档；在系统临时目录中为每个场景建立 GUID 夹具。验证：预登记文件的哈希和时间早于第一个样本；夹具不在仓库内，也没有运行安装器；记录基线和候选文档的哈希。
- [x] 2.2 用全新的 Cursor 子代理会话逐一运行 S1–S7 的候选版本，以及 S7 的 v1.9.5 基线；若 Codex CLI 可用且无需新账号或费用，再用它复跑 S2 和 S7 的候选版本。提示词不提及规模定义所在段落，也不提示预期。验证：每个样本都保存了输入、完整会话、生成的 handoff 或回复，以及对照预登记预期的人工结论；适用的样本用现有 validator 加预期参数做结构检查，并记录退出码；未运行或无法运行的样本如实标为缺口，不用模板填充代替。若发现新增引用本身的问题，按 design 决策 4 修正后重跑受影响场景，并保留首次结果。
- [x] 2.3 统计 S1–S7 涉及角色在 v1.9.5 与候选版本中的必读字节数，并从会话记录统计 Read/Grep 次数和读取的不同文件数；编写公开的 `docs/reviews/link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md`，包含场景、预期、观察、哈希、限制，以及 design 决策 5 的两项决策输出；按 design 决策 4 把既有规则的问题写入双语导航的“待决定”事项，并更新 P2 一行的证据链接。验证：公开摘要不含工作站绝对路径或原始会话正文；每个结论都能追溯到具体样本；单次观察不写成比例或普遍结论；双语导航对应一致；P2 和上下文精简都没有被写成已获授权。

## 3. 独立审查与最终对账

- [x] 3.1 对最终产品差异和试点证据做一次独立 M 代码/协议审查，合并检查最小范围、锚点可达性、试点结果与预登记是否一致、隐私和旧兼容性。验证：独立审查者在 `docs/reviews/link-sizing-guidance-and-pilot-lean-rules/` 下按既有 index/round 结构记录真实 verdict、发现和处置；实现作者不自审；所有 verdict 在同批累计，修复遵守剩余额度。仅根据实际审查结果更新本项。
- [x] 3.2 在审查通过后对账本清单、CHANGELOG 和双语导航（本变更改为“已完成”），运行 `openspec validate link-sizing-guidance-and-pilot-lean-rules --strict`，并检查实际差异与链接。验证：strict 校验返回 exit 0；导航状态和审查证据相符；没有触及旧归档、发行 snapshot、提交、部署或发布；仍未覆盖的试点场景保留在限制中，不写成已验证。

本次有限纠错状态（2026-10-21）：2.3 的 S3 路由及全部 Codex 动态统计已集中修正，并由独立第 7 轮 PASS 复核；3.1/3.2 据此完成最终对账，关闭以外置 review-07-boundary.log 的最终输入校验为准。累计审查 7/7，原第 6 轮 PASS、关闭记录及 Review 01–06 保留原件，未重置或重计。主宿主未完成样本及其他试点局限继续披露；无进一步自主修复或审查循环。

## Workflow follow-up

- 满足审查要求后，按既有流程同步主 spec 并归档本变更。
- 发布、快照重建、Git 提交和推送需要另行的明确请求，并按 `docs/development.md` 的 `git archive` staging 流程执行。
- P2 与可能的上下文精简是否立项，由负责人依据 `pilot-evidence.md` 另行决定。
