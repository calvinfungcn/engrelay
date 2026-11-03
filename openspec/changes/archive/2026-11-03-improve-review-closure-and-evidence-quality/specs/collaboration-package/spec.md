# Spec Delta

## MODIFIED Requirements

### Requirement: Coherent role routing and review independence

角色 SHALL 以职责及实际需要路由；稳定范围内的问题由有权限的当前负责人继续。
每个真实交接边界 SHALL 选择 continue/dispatch/close 中一个动作；Agent 派发
SHALL 提供完整自包含 Operator Command。M 代码审查及 H 所需验证 SHALL 保持独立。


追加审查和关闭后修复 SHALL 按实际授权范围执行并关联原验收及历史；同一未完成验收 SHALL NOT 通过关闭、改名或新批次取得新额度。单次追加审查 SHALL NOT 自动授予后续修复循环；已关闭历史不重开，真实新缺陷仅在适用授权下建立关联修复。

#### Scenario: Local implementation issue
- **WHEN** 实现工程师遇到不改变已确认范围、验收或风险的局部问题
- **THEN** 继续在角色权限内处理，不增加机械角色往返，也不豁免所需独立审查

#### Scenario: Review allowance exhausted
- **WHEN** 默认三次累计 verdict 已用尽且问题未解决
- **THEN** 当前负责人说明证据、选项、投入和推荐理由，走既有负责人决定出口；
  追加循环须有适用的有限授权，不能通过改名、换角色或 REVISE 重置累计计数

#### Scenario: Unfinished acceptance is renamed
- **WHEN** 同一未完成验收因阶段、角色、文件或批次名称变化继续处理
- **THEN** 保留实际累计计数和未完成映射，按原额度或适用有限扩展路由；改名不授权新循环

#### Scenario: One extra review is authorized at capacity
- **WHEN** 当前未关闭批次已用尽额度，负责人明确只追加一次独立审查
- **THEN** 以既有有限授权字段记录实际范围及一次 verdict 的绝对上限，完成该次审查；不得解释成无限授权或新三轮修复，不重复请求已给授权

#### Scenario: Owner requests a post-closure audit
- **WHEN** 负责人明确要求对已关闭成果追加一次审查
- **THEN** 保留原关闭和计数，在现有任务及审查索引关联原记录与这次有限范围；发现问题只记录实际影响及下一步，单次审查不自动授权新修复批次；已适用的明确修复授权直接复用

#### Scenario: A genuinely new defect needs repair
- **WHEN** 已关闭成果出现具名新缺陷且存在适用的修复授权
- **THEN** 以关联修复范围经既有 Task Intake 处理，保留历史事实、来源和计数，不伪称原记录从未通过；若只是原未完成验收改名，仍按同一验收累计额度处理

### Requirement: Traceable and proportional verification

检查 SHALL 覆盖实际受影响行为，并仅在输入和范围匹配时复用既有证据。高投入
低收益或明显超预期成本的选项 SHALL 先说明收益、投入与未知、较小方案和建议，
由负责人明确选择。真实缺陷 SHALL 聚合报告，不受固定发现数量上限约束。


负责人明确要求完整审查时，审查 SHALL 覆盖授权范围的全部验收、最终差异、兼容性、证据、说明及交付隐私，并记录适用版本／差异。证据 SHALL 对应所声称的入口、输入、环境和结果；不足保留未验证。后续复核 SHALL 依据实际变化及影响选择检查，发现真实新缺陷、影响扩大或原证据失效时扩大范围；SHALL NOT 将完整审查等同于每次重跑全部测试。

#### Scenario: Documentation-only change
- **WHEN** 修改只影响文案、引用或记账，没有新的行为问题
- **THEN** 不因角色更换或收尾重复全部历史套件，不增加措辞匹配测试

#### Scenario: Owner requests complete review before archive
- **WHEN** 负责人要求归档前完整独立审查
- **THEN** 执行覆盖全部授权验收的聚合审查，不只检查最后一项修复；没有要求追加新审查且已有独立结论覆盖当前全部输入时可复用，不为 S 任务普遍新增审查门槛

#### Scenario: An old upload result is cited as current FileId acceptance
- **WHEN** 报告以旧上传入口结果声称当前 FileId 入口已成功，且没有对应执行依据
- **THEN** 该验收保持未验证并说明入口／版本对应缺口，不以结构通过、离线 fake 或叙述补成真实入口成功

#### Scenario: Privacy or explanation changes preserve behavior inputs
- **WHEN** 修复只涉及报告脱敏或说明，相关行为、配置、测试输入及既有证据仍匹配
- **THEN** 复核修复内容及适用的工作区／待交付副本，引用匹配的既有行为结果；不因角色变化重跑无关构建、供应商调用或全部套件

#### Scenario: Repair changes a shared contract or invalidates evidence
- **WHEN** 修复改变共享契约、调用者或相关输入，或发现可信的新缺陷／原验收证据不成立
- **THEN** 沿实际影响扩大审查和必要检查，明确失效及可保留的证据；扩大到全部验收有依据时执行完整复核，不能以局部复核隐藏问题

### Requirement: Advisory delivery quality feedback

Full 和 Lite 的既有独立审查／复核在确实评价实施或修复交付时 SHALL 默认附简短的本次交付质量 1–5 分或无法评分、已有发现依据及有必要的原因／建议。Full 由 Code Reviewer 评价实施交付、由独立复核者评价修复交付；Lite 由对应 Reviewer 评价。反馈 SHALL 保存在现有审查结论并在最终回复简短复述，SHALL NOT 引入额外调查、审查、权重、评分文件、handoff 字段或角色自评。


后续发现导致返工时，审查 SHALL 仅依据本轮已有证据简述问题来自实施、修复、证据判断或审查产物，无法归因时说明未知；SHALL NOT 将全部返工自动归给实施者、以最终修复高分替换早期评分，或为归因新增角色评分与调查。

#### Scenario: An implementation review has sufficient evidence
- **WHEN** Code Reviewer 或 Lite Reviewer 已有足够的本次送审范围和发现
- **THEN** 依据实际影响评价：5 为当前范围无已证实必须修且必要证据齐备，4 为总体可靠而局部可修，3 为明确漏项／必要检查不足／修复不全，2 为关键错误／回归／已指明问题反复未解，1 为严重偏离明确要求／主要结果不可用／重大危险；不按缺陷数量、轮数或篇幅机械计算

#### Scenario: An existing verification checks a fix
- **WHEN** 本来就需要的独立复核检查本次修复
- **THEN** 评价该次修复是否解决已指明问题、保留必要证据并避免回归，引用已有发现及受审版本；保留先前评分，不以最终修好后的评价回填首轮

#### Scenario: Evidence or attribution is insufficient
- **WHEN** 可见材料不足以判断质量，或不能确认实施、输入设计、环境工具与审查口径各自的影响
- **THEN** 允许无法评分或原因尚不明确并说明缺口；不把未知自动记作低分，不猜模型能力、虚构推理强度或开展新的评分调查

#### Scenario: A task has no implementation or fix review
- **WHEN** S 任务正常自查收口，或现有审查仅涉及其他角色的设计／需求／文档协调
- **THEN** 不为评分增加独立审查，不要求每个角色都评分；Lite 的简短评价定义保持自包含，不新增 Full 手册必读

#### Scenario: Advice coexists with acceptance and legacy records
- **WHEN** 交付评分较高但仍有未解决验收，或旧报告没有评分，或本次默认评价被遗漏
- **THEN** 正式发现、验收和既有出口继续决定通过与否；旧记录不回填，当前遗漏可在已有保存步骤补充但不转成业务必须修或新增复核。分数不改变 C1–C5、风险、授权、路由或累计 verdict，也不自动换模型

#### Scenario: A verification report creates a new disclosure
- **WHEN** 后续证据证明新增敏感信息来自验证报告，而非被审实现
- **THEN** 在新的发现／结论中指出来源并修复适用的交付产物，保留先前评分及历史结论，不自动降低实施者评分或扩成审查员评分体系

## ADDED Requirements

### Requirement: Privacy-safe review artifacts

审查、验证、修复结果和交接 SHALL 遵守适用的交付隐私边界，以虚构别名、字段名、计数和状态表达证据，并在既有交付步骤核对产物自身及适用的待提交副本。历史事实和 verdict SHALL 保留；必要脱敏 SHALL 仅按适用授权最小处理并记录不含私有值的说明，不要求独立脱敏角色或自动扫描平台。

#### Scenario: Private evidence is summarized
- **WHEN** 现有检查需要引用真实业务证据
- **THEN** 公开／待提交报告及 handoff 不复制发票字段、私有样本标识、凭据或原始日志中的私密值；必要原件按项目隐私边界保存，结论仍能通过已授权渠道追溯

#### Scenario: A historical report requires redaction
- **WHEN** 已有报告含禁止交付的私有值且当前授权允许必要脱敏
- **THEN** 对实际泄露的报告及适用待交付副本做最小处理，以无私有值的方式确认结果；保留事实、结论、评分及历史引用，不以普通勘误代替移除实际泄露，也不输出含私有值的差异

### Requirement: Bounded archive verification

归档核对 SHALL 按当次规范同步及产物影响确定范围和风险，核查 delta／主规范对应、文件完整性、完成状态、索引及交付隐私，复用仍匹配的实施证据。必要独立性 SHALL 保留；SHALL NOT 自动将原实现最高风险或无关全局失败作为本次新门槛，也不为所有任务增加固定独立归档审批。核对通过 SHALL 结束当前核对范围。

#### Scenario: Only synchronized specs and archive records change
- **WHEN** 已通过完整审查后只进行授权的规范同步与归档
- **THEN** 核对本次规范及归档差异，保留实现审查结论和限制，不重做无关业务验证；同步引入契约变化或矛盾时按其实际影响处理

#### Scenario: Unrelated archives fail a global check
- **WHEN** 全局检查因其他历史归档失败，但当前归档的相符依据有效
- **THEN** 分别记录当前结果和全局失败，不伪称全局通过，也不要求本次修复所有历史提案

#### Scenario: Independent archive check passes
- **WHEN** 已授权的独立归档核对无范围内实际缺陷
- **THEN** 结束该核对并记录结果，不为复制状态或复述结论再派发审查；未满足的上级事项和限制仍如实保留
