# Tasks

## 1. 完整修复范围来源与设计后的接力

以下属于一个完整 M 级交付批次；本文件是唯一实施清单，设计产物齐备不表示实施或独立审查完成。

- [x] 1.1 在 Full README 增加唯一共享的 task-scope-evidence 说明，协调原 Minimal Authority、设计接力与关闭后接续，以及 workflows／agent-prompts 的 Task Intake、Chief Designer、Design Reviewer 和相应矩阵；按 design S1–S5 逐项核对完整授权、独立方案、无据缩窄和授权未知的来源、映射及出口对应，防止扩大或缩小权限。
- [x] 1.2 协调 canonical start／continue、current-task／handoff 模板、handoff-schema 和 agent-rules 的必要短引用与原事实修正规则；按 S3/S6/S7/S9/S10/S11 核对来源保留、下一平台无需聊天、后续明确请求、旧记录可读及纯来源纠正不触发重复设计评审，确认未新增字段、台账或通用审批。
- [x] 1.3 成对更新两份 operator-guide、根 README 与 CHANGELOG 的简短操作解释和 Unreleased；用 S1/S2/S4/S5/S7 检查用户能分清整体目标、本轮职责、未知授权、合法设计关闭及具体接续请求，核对双语、链接和公开产物自身隐私，保持既有发行版本与 snapshot。
- [x] 1.4 聚合走查 S1–S11 与全部受影响入口及两个 spec 要求的对应；按 design 用 GUID 可丢弃镜像和原 validator 对 S1/S2/S3/S8 记录本次真实命令、退出、诊断、期望状态和相符输入指纹，区分结构、语义与未观察宿主遵从；完成本变更 OpenSpec strict、引用／锚点、实际差异和隐私检查，保留无关未验证项而不重跑全部历史套件。
- [x] 1.5 由独立于实施者的 Code Reviewer 聚合审查全部验收、最终差异、场景与输入对应、兼容性、双语和交付隐私，在具名正式 Review 与 index 记录实际 verdict 及相关历史；按实际累计和有限限制选路，只有审查通过且最终 accepted 交接具有匹配校验依据时完成本项并关闭，不提前勾选独立审查或因新提案名称重置计数。

## Workflow follow-up

- 归档、主 specs 同步、版本／snapshot、Git 提交推送、Release 和真实项目安装另按后续适用请求处理，不属于本轮首席设计师行动。

## 2. Clarify manual dispatch preparation and human decision waits

本次有限后续工作保留上文已接受的关闭结果和审查历史，仅澄清现有人工接力规约；不重开或重置原批次。负责人授权的发行准备在本清单之外跟踪。

- [x] 2.1 更新共享角色规则、Full spec 和两份人类可读 README，明确 Agent 派发表示准备、保存、回读并说明下一角色交接，然后停止，不执行下一角色；需要准备交接时避免使用互相矛盾的 `Do not dispatch any further role`；核对 Routing、Operator Command、状态、Human Action Required 和 Owner Decision Brief 的一致性，使真实负责人决定等待对应 `awaiting-owner-decision` / `awaiting-decision`，人工接力则保持 `none`。
- [x] 2.2 独立审查聚焦差异及引用的路由规约；检查人工接力和真实负责人决定场景中的动作／状态／人类行动提示是否一致，核对中英文 README 与 CHANGELOG 对应，并保留原累计审查历史、不重置计数。
