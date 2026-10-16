# Spec Delta

## MODIFIED Requirements

### Requirement: Stable entry Skills and canonical product files

工具包 SHALL 保留三个入口 ai-collab-requirements/start/continue 及四个 CE Skill 的现行机器名称、角色锚点、字段和安装路径。规范产品内容 SHALL 在 payload/ 维护，宿主发现副本 SHALL 由官方部署机制管理，单次安装最多选择一个 SkillTarget。start SHALL 作为推荐通用入口，条件复用与 requirements 相同的既有需求分析契约；需求明确时 SHALL 保持直接分流，重要业务歧义未经负责人确认 SHALL NOT 进入设计或实现。

#### Scenario: Requirements dialogue
- **WHEN** 用户明确使用 ai-collab-requirements 讨论需求
- **THEN** 先按既有条件契约澄清和记录，负责人明确确认后才交给首席设计师；已明确且已确认的输入不重复确认

#### Scenario: Continue work
- **WHEN** 用户明确使用 ai-collab-continue 接续任务
- **THEN** 检查最新有效 handoff 及授权，只按记录的下一步继续，不重置审查计数

#### Scenario: Clear goal through start
- **WHEN** 用户使用 start 给出可安全总结的明确任务或充分明确的现有 OpenSpec 范围
- **THEN** 按既有风险规则分流，不增加固定需求讨论阶段或重复的确认

#### Scenario: Ambiguous goal through start
- **WHEN** 用户使用 start，Task Intake 无法安全总结重要业务歧义
- **THEN** 同一负责会话可按已有 Requirements Analyst 契约澄清，无须用户另行调用 requirements；等待期间由分析师保有责任，使用既有负责人决定出口，明确确认后只交给首席设计师

#### Scenario: Technical uncertainty without business ambiguity
- **WHEN** 业务目标已经明确，剩余问题属于技术设计或实现可行性
- **THEN** start 交给首席设计师处理该问题，不把技术选择变成业务澄清的阻塞条件

#### Scenario: Existing task or inactive workflow
- **WHEN** 同项工作已有活动任务，或当前处于 disabled 模式、选用了其他控制器
- **THEN** 复用同项身份与累计计数并遵守既有接续规则；disabled 或其他控制器的场景不隐式激活、不覆盖运行态、不新建批次

## ADDED Requirements

### Requirement: Compatible selective upstream methods

工具包 SHALL 以不可变上游来源核对所采用方法与本地权威、范围、授权和许可的兼容性，只吸收适用的差异。方法同步 SHALL 保留 S/M/H、独立审查、现有发现分类和单一任务权威；SHALL NOT 隐式启用完整上游生命周期、外部模型调用、自动提交或新的运行记录。未捆绑或已覆盖的上游功能 SHALL 如实标明，不用上游版本号代表本地实现程度。

#### Scenario: Review an I/O gap
- **WHEN** 审查发现 I/O 防护不足
- **THEN** 结合该代码实际运行场景和可证实后果判断是否形成发现；不能只因缺少 try/catch 就要求修复，也不能忽略真实数据损失、误导结果或不可恢复的部分完成

#### Scenario: Review extra surface or a dependency
- **WHEN** 新接口、参数、配置或依赖疑似超出任务需要
- **THEN** 依据明确约束或清楚限定的范围判断；需求简短而未提及本身不是越界证据；建议替换依赖时指出实际可用的标准库、平台或仓库内替代能力

#### Scenario: Prevent recurring root cause
- **WHEN** 最小修复已通过聚焦检查，证据显示同类根因在多个已授权位置重复
- **THEN** 可采用有证据支持的局部复用或约束以防复发，并单独记录；改变公共接口、范围或引入不相称成本时只记录后续建议并走既有范围决定，单点缺陷不强加结构改造

#### Scenario: Unbundled Superpowers and unchanged CE methods
- **WHEN** 上游变化属于未捆绑的宿主插件、控制器或本地已满足的方法
- **THEN** 记录不采用或无需改动的结论；本机工具问题提供受支持的更新建议，不改写生成副本或声称已升级公开包；转载改写内容保留适用通知

### Requirement: Separate human documentation languages

工具包 SHALL 为专门供人类阅读的现行说明提供内容相应、互相可达的英文和简体中文版本，覆盖入门使用、采用、宿主、贡献、开发发布、变更与许可说明及人类示例。每份版本的自然语言正文和说明性示例 SHALL 使用对应语言；语言切换标签、技术标识、命令、机器示例字段、许可证及明确引用的英文 Agent 提示词可保留原文。Agent 契约、机器模板和工具输出 SHALL NOT 因此增加中文版本或改变协议。

#### Scenario: Chinese operator follows the documented flow
- **WHEN** 中文用户从中文 README 进入现行使用、采用和宿主说明
- **THEN** 可阅读对应中文人类说明，识别统一入口、确认与交接方式及安装限制，无须把英文 Agent 契约当作普通操作教程；Agent 仍引用原规范契约

#### Scenario: Maintainer or contributor changes language
- **WHEN** 人类从贡献、开发、变更、许可或源码导航说明切换语言
- **THEN** 对应版本保持相同的实质信息，开发指南的可复制 Agent 提示词继续英文且标明原文引用，不声称未发布或未验证的内容已经发布或验收

#### Scenario: English contract contains Chinese narrative
- **WHEN** 清理英文 Agent 契约中夹杂的中文说明或示例
- **THEN** 将自然语言等义改为英文，保留字段、角色、锚点及行为，不新增中文契约或修改校验器

#### Scenario: Historic records and existing example paths
- **WHEN** 语言清理涉及审查原件、归档提案或既有中文示例文件
- **THEN** 历史审计原件保持原样；既有示例路径保留为兼容例外，示例中的机器结构不因中文正文而翻译或重命名

### Requirement: Protected deployment of added human documents

新增可部署人类文档 SHALL 使用既有受管归属机制；受支持历史布局的转换 SHALL 精确登记新增路径，保留原布局指纹、模式、SkillTarget、原始备份和项目自有内容。根目录维护说明与源码索引 SHALL NOT 被误当作新的安装目标。布局升级或文档语言 SHALL NOT 授权绕过冲突保护、自动迁移宿主目标或重写已发布清单。

#### Scenario: Upgrade a known public installation
- **WHEN** 使用新候选包升级受支持的公开旧版本，新增文档路径没有冲突
- **THEN** 新人类文档按既有机制登记归属，既有模式、单一目标、备份和管理块外内容保留，后续卸载只处理本包可撤销内容

#### Scenario: Added document collides with project content
- **WHEN** 新增目标路径已有相同或不同内容的项目文件
- **THEN** 相同内容继续按既有 preexisting 语义保留；不同内容在任何目标或恢复元数据写入前拒绝，不覆盖或接管项目文件

#### Scenario: Owned content drift or unverified layout
- **WHEN** 旧受管内容漂移，或旧版本布局没有可信登记且不能按现有规则识别
- **THEN** 保持既有拒绝及恢复方向，不伪造指纹、不弱化检查，也不把未取得的旧包测试记为通过
