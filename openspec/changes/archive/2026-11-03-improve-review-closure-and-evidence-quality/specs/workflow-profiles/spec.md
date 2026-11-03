# Spec Delta

## MODIFIED Requirements

### Requirement: Aggregated responsibilities with independent review

Lite SHALL 使用负责人、执行者、评审者三类职责并按实际影响判定 S/M/H。相邻非独立动作 SHALL 允许同一 Agent 连续处理；M SHALL 独立审查并复核必须修项，H SHALL 满足实际需要的设计和独立验证，实施或修复者 SHALL NOT 自审或自任同批 H 验证。累计 verdict 默认上限为三次，有限扩展 SHALL 保留已有授权及历史。


Lite SHALL 在自身短规则和现有任务／审查产物中表达完整审查、证据对应及隐私、按变化复核、关闭后有限授权和归档核对，保留三类职责与历史。SHALL NOT 要求 Full 手册、新机器字段、产物台账或固定审批；归档或换任务标识不授予额外修复循环，已给授权不重复请示。

#### Scenario: M review requires a fix
- **WHEN** 独立评审提出有证据的必须修问题
- **THEN** 执行者修复后取得对应复核依据，不能自行把未复核发现标为已验证

#### Scenario: H work uses an available reviewer
- **WHEN** H 任务需要修复后的独立验证
- **THEN** 按实际独立性安排验证者，不能因只有三类职责而省略验证或让修复者自验

#### Scenario: Review allowance is exhausted
- **WHEN** 同批累计三次 verdict 后仍有未解决问题，且没有适用有限追加授权
- **THEN** 保存结果并交负责人决定，不因换模型、阶段、文件或配置而清零或再开循环

#### Scenario: Owner requests a complete Lite review
- **WHEN** 负责人要求对 Lite 成果作归档前完整独立审查
- **THEN** Reviewer 检查全部授权验收、最终差异、兼容性、对应入口／版本的证据、说明和交付隐私；依 Lite 自身规则执行，不新增 Full 角色或强制全量测试

#### Scenario: Lite repair changes only report content
- **WHEN** 修复仅对报告作必要脱敏或说明修正，相关行为输入及原证据仍匹配
- **THEN** 独立复核受影响报告及交付副本并复用适用行为结果；发现新缺陷、失效证据或共享行为变化时扩大检查，缺失证据保持未验证

#### Scenario: Closed Lite work receives one additional review request
- **WHEN** 负责人对已关闭成果只授权一次追加审查
- **THEN** 关联原任务的关闭及计数，按这次有限范围执行并在既有产物记录结果；不复写旧历史、不由新 Task ID 自动授予后续修复三轮；真实新缺陷的修复须有适用授权

#### Scenario: Lite archive check has no implementation change
- **WHEN** 已授权核对仅涉及规范同步、归档、完成状态和隐私，实施输入未变
- **THEN** 按当前影响定级并复用相符实施证据，通过后结束该核对，不因父任务为 H 重跑所有套件或新增角色／审批
