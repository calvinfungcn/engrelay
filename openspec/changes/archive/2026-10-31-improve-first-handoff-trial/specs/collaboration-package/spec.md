# Spec Delta

## ADDED Requirements

### Requirement: Source-only reproducible first-handoff sample

源码 SHALL 提供固定输入、明确预期和可检查初始缺陷的独立首次交接样例，使用户无需自编业务需求即可开始。样例 SHALL 预置唯一 OpenSpec 需求与未完成实施清单，不携带已生成运行态、安装状态或审查结论；人类指南 SHALL 中英文对应，既有机器契约不翻译或复制。

#### Scenario: Prepare a fresh sample
- **WHEN** 用户从明确源码版本取得样例并复制至新的可丢弃项目
- **THEN** 可识别同一需求、初始缺陷与行为检查，未预置当前任务、handoff 或通过记录；实际 A/B 状态由本次 Agent 生成

#### Scenario: Initial defect and corrected behavior
- **WHEN** 对原始样例和其可丢弃修复副本分别执行约定行为检查
- **THEN** 原始样例至少一项检查失败并返回非零，正确修复后全部约定案例通过且返回 0；不能以文本匹配或预写 PASS 代替行为证据

### Requirement: Trial source acquisition preserves package boundaries

首次演示 SHALL 区分源码检出、可信完整安装包和独立目标，沿用官方受保护安装。样例 SHALL 仅留在源码并从安装导出排除，不新增受管路径。取得说明 SHALL 使用能包含样例的固定提交检出或经过明确核对的离线源码副本，SHALL NOT 把自动源码归档或完整安装 ZIP 当作必然含样例的来源。

#### Scenario: Sample is export-ignored
- **WHEN** 样例被 export-ignore 排除且用户需要获取样例
- **THEN** 指南提供固定提交 Git 检出路径，安装包另从可信发行取得；不指导用户用可能排除样例的自动源码 ZIP，也不拼改安装包清单

#### Scenario: Candidate has no published sample commit
- **WHEN** 样例仅存在于尚未提交的本地候选
- **THEN** 本地证据记录候选文件指纹与实际包版本；公开固定提交与下载验证保持待后续提交准备，不编造 SHA 或声称尚不存在的公开链接已可用

#### Scenario: Existing installations keep their layout
- **WHEN** 维护者新增源码样例及包根入门说明
- **THEN** 样例不部署至目标项目，既有受管集合、Lite／Full、SkillTarget 和模式保持原语义，不能通过向 payload 新增演示文件绕过布局演进要求

### Requirement: First-handoff exercises use real fresh sessions

首次演示 SHALL 使用真实会话 A 准备交接、没有 A 聊天上下文的真实会话 B 按当前有效 handoff 实施；在两个全新目录记录实际过程。SHALL 沿用既有直接规范读取、Git 基线、A 交接备份及角色权限要求，不将脚本代填状态、同会话更名或事后叙述作为真实 Agent 演练。

#### Scenario: Session B continues the authorized task
- **WHEN** A 按 start 产生有效实施派发，B 收到接续入口与实时完整 Operator Command
- **THEN** B 核对当前批次、权限和路由后执行已授权任务，维护同一 OpenSpec 清单与真实交接，并通过约定行为和最终状态检查；复制命令计为标准人工动作

#### Scenario: Exercise evidence is unavailable
- **WHEN** 缺少实际 Agent 调用、无法证明 B 没有 A 聊天上下文或无法取得必要执行结果
- **THEN** 对应演练保持未验证并记录缺口；可继续无依赖的本地工作，但不能勾选实际演练验收或建设新的运行时引擎替代该证据

#### Scenario: S sample and M maintenance are separate
- **WHEN** 维护样例的变更风险为 M、样例内真实任务风险为 S
- **THEN** 维护交付接受独立聚合审查，样例任务仍按实际风险自检与关闭；不为增加样例审查次数而改变风险或重置任一批次累计数

### Requirement: Staged trial claims follow observed evidence

路线图和试用报告 SHALL 分开记录本地复现、公开获取与外部 G0。G0 SHALL 要求两个新目录内部复现及三位目标用户首次尝试中至少两位无额外辅助完成；十分钟目标单列。人数或条件不足 SHALL 保持外部待验证，允许有限内部 Phase 1，不替代真实结果或增加自动遥测。

#### Scenario: Internal exercise passes without external users
- **WHEN** 内部演练已完成但外部首次试用尚未开展或人数不足
- **THEN** 可按本变更的本地映射验收关闭，并明确外部 G0 未通过；内部 Agent、重试和辅助成功不能冒充新的外部首次独立完成

#### Scenario: First attempt needs rescue
- **WHEN** 观察者补讲需求、代操作或修改用户输入后试用完成
- **THEN** 首次结果与额外辅助保留，修订后的成功另记；不能以成功重试覆盖失败、退出或未知耗时

#### Scenario: Calibrate the roadmap
- **WHEN** 根据当前版本与实际证据更新双语源码路线图
- **THEN** 保留已经完成的能力，按现有状态词标明尚缺证据，链接正式任务与独立后续入口；路线图不复制勾选清单、运行态或审查计数，也不自动授权外部操作与后续阶段
