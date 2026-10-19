# harden-handoff-recovery

## Scope

交接恢复来源、按动作比较、计划换会话、只读子代理写回及入口说明。批次 `engrelay-handoff-recovery-20261019-01`，风险 M；唯一实施清单为 [tasks.md](../../../openspec/changes/archive/2026-10-19-harden-handoff-recovery/tasks.md)。

## Overall Status

- Current status: `closed` / `accepted`，CR-05(a/b) 及关联证据独立复核通过；最终输入校验及对应见 round 04 外置边界证据。
- Latest round: [round 04](2026-10-19-round-04.md)，有限授权内最后一次独立复核 `PASS`。
- Review round: 4/4；负责人于 2026-10-19 将本批上限有限扩展至 4，仅限 CR-05(a/b) 修复和一次独立复核。授权细节保存在本机非公开接案记录中，本索引不公开本地文件。累计已到限，无第五轮。
- Fix record: round 02 与 round 03 的修复记录不产生 verdict；CR-05(a/b) 修复及复核依据见 round 03、round 04。
- Legacy review sources: none。
- Execution source: tasks 映射 10/10 完成；5.1 为 round 04 独立 PASS，5.2 对应最终边界检查，4.1 的证据缺项已闭合。

## Topic Index

| Finding | Priority | Status | Latest evidence | Owner |
| --- | --- | --- | --- | --- |
| DR-01 新容器缺指纹不得落入旧分支 | should-consider | verified | [round 03](2026-10-19-round-03.md) | Code Reviewer |
| DR-02 human dispatch/close 同 revision 比较 | should-consider | verified | [round 02](2026-10-19-round-02.md) | Code Reviewer |
| DR-03 接管/编辑须递增修订 | should-consider | verified | [round 03](2026-10-19-round-03.md)，F10 | Code Reviewer |
| DR-04 可写主 Agent 的发布路径 | should-consider | verified | [round 03](2026-10-19-round-03.md)，F18 | Code Reviewer |
| DR-05 有界读取与未发布转移 | observation | verified | [round 04](2026-10-19-round-04.md)，同批归属阻断与链式冲突 | Code Reviewer |
| DR-06 已安装布局镜像校验 | observation | verified | [round 02](2026-10-19-round-02.md)；round 03 外置边界证据 | Code Reviewer |
| DR-07 旧结果撞名保护 | observation | verified | [round 02](2026-10-19-round-02.md) | Code Reviewer |
| CR-01 Next output files 候选遗漏 | must-fix | verified | [round 03](2026-10-19-round-03.md)，F1/F2 | Code Reviewer |
| CR-02 新指纹与旧兼容冲突 | must-fix | verified | [round 04](2026-10-19-round-04.md)，旧响应正反例及新指纹保护 | Code Reviewer |
| CR-03 长检查与计划会话边界 | must-fix | verified | [round 03](2026-10-19-round-03.md)，canonical 规则、F10/F11 | Code Reviewer |
| CR-04 项目自有声明与双语采用说明 | should-fix，已分配 | verified | [round 03](2026-10-19-round-03.md) | Code Reviewer |
| CR-05 oracle 与关键链路证据不匹配 | must-fix | verified | [round 04](2026-10-19-round-04.md)，双宿主各 17/17、恢复幂等和阻断原字节核对 | Code Reviewer |

DR 分类沿用原设计审查。CR-05(a/b) 为原发现未闭合部分，聚合处理，不新增第二实施清单。

## Historical Rounds

| Round | Type | Outcome |
| --- | --- | --- |
| [round 01](2026-10-19-round-01.md) | 独立设计审查 | PASS；累计 1；dispatch Implementation Engineer |
| [round 02](2026-10-19-round-02.md) | 独立 M 代码/协议审查 | FAIL；4 must-fix、1 assigned should-fix；累计 2；dispatch Fix Engineer |
| [round 03](2026-10-19-round-03.md) | 原独立审查会话复核 | FAIL；CR-01/03/04 verified，CR-02 待证据，CR-05 open；累计 3；continue/awaiting-owner-decision |
| [round 04](2026-10-19-round-04.md) | 有限授权内原独立会话最终复核 | PASS；CR-02/05、DR-05 verified；累计 4/4；close/accepted |

## Deferred Follow-up

LOCAL-ENTRY-01：项目自有块外历史声明冲突，deferred，已确认但待独立项目执行；归属目标项目维护负责人 / Task Intake。具体目标与项目证据保存在目标项目本机接案记录中，本公开索引仅保留通用问题、状态和归属。产品文案完成不等于真实项目已修复，不阻塞本批。OBS-01 继续单独 deferred，不属于本批。

## Closure

本批按 round 04 的技术复核与最终输入校验关闭，累计 Review round 4/4，close / accepted，无下一角色。原 Fix Engineer 修复不计 verdict；本轮为有限授权内累计第 4 次，计数不重置。全部已分配发现 verified；LOCAL-ENTRY-01、OBS-01 保持既有 deferred 归属。验收范围为映射协议/文档及合成文件链路，不证明宿主遵从或业务验收；不包含项目侧修复、安装或发布。
## Archive Record

- 已归档工件：[提案](../../../openspec/changes/archive/2026-10-19-harden-handoff-recovery/proposal.md)、[规格差量](../../../openspec/changes/archive/2026-10-19-harden-handoff-recovery/specs/collaboration-package/spec.md)、[设计](../../../openspec/changes/archive/2026-10-19-harden-handoff-recovery/design.md)、[任务](../../../openspec/changes/archive/2026-10-19-harden-handoff-recovery/tasks.md)。
- 主规格已同步 collaboration-package 的 4 条修改要求；严格规格校验通过。
- 完成 10/10 项；累计 4 次审查 verdict，无未解决 must-fix。round 01–04 原文件保持不变，归档不新增 verdict、不重置计数。
- round 文件中指向本机 .ai/ 证据的引用仅表示本地非公开记录；该等本机文件不属于本次公开归档或提交内容。
- 审查轮次 SHA256：
  - round 01: B193BA4F7F2DA5ABAB000D9DBD25016B85F6A2658172EA8BBC05FC74E07981CA
  - round 02: CCF9E1875357D1A480CB36A94C5712705BF006AC768A02B75FB6F0413FD755EE
  - round 03: A714840D14064DCDACD7047738C0AE533F85D0E363BD67E307BE75CCA89BB096
  - round 04: 062A1EF29CCF0D604E97D26A3BF0041C77361D7C0F3D256B5DD74129903DF22B
- 归档时尚未发布；发行状态以对应 Release 记录为准。宿主遵从、自动进程恢复及业务验收仍未验证。
