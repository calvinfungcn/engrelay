# Spec Delta

## MODIFIED Requirements

### Requirement: Explicit activation and one workflow

工具包 SHALL 保留 optional/default/disabled 及当前任务明确选择优先的语义。Full 中明确选择 EngRelay SHALL 等同于兼容名称 ai-collaboration；Lite 中 EngRelay 或 EngRelay-Lite SHALL 选择已安装的 Lite。明确选择未安装配置或其专属入口 SHALL NOT 自动切换、安装或生成另一套运行态。资料或 Skill 被发现本身 SHALL NOT 激活流程，同一任务 SHALL 只有一个主编排流程。现行管理入口 SHALL 明确规则适用于当前选用配置，SHALL NOT 将运行态维护描述为仅适用于退役历史；管理标记及项目块外内容 SHALL 保留归属保护。

#### Scenario: Optional installation
- **WHEN** 项目以 optional 模式安装，当前任务没有明确选用该流程
- **THEN** 旧 .ai、角色名称或可发现 Skill 不要求创建运行态或启动角色链

#### Scenario: Disabled mode
- **WHEN** 项目为 disabled 模式
- **THEN** 使用前须明确重新启用，不能因读取入口而隐式改变模式

#### Scenario: Active workflow is not described as retired-only execution
- **WHEN** 当前任务明确选择 EngRelay，并从管理入口读取运行态维护规则
- **THEN** 文案说明规则适用于当前任务，不以 legacy 或退役描述暗示可以忽略交接；不改变模式、机器路径或角色契约

#### Scenario: Project-owned entry has a conflicting historical statement
- **WHEN** 项目管理块外保留与当前采用方式冲突的历史声明
- **THEN** 采用说明要求在该项目范围核对并协调适用性；安装升级不自动改写块外用户内容，不把包源文案修正称为项目声明已经修复

#### Scenario: Lite task explicitly chooses EngRelay
- **WHEN** 项目有效安装 Lite，当前任务明确使用 EngRelay，模式允许激活
- **THEN** 读取 Lite 的规则和运行态，不把通用名称解释成 Full 角色链

#### Scenario: Entry belongs to another profile
- **WHEN** Lite 项目明确收到 Full 专属 ai-collab-start、requirements、continue 或 ai-collaboration 选择
- **THEN** 说明配置与入口不匹配并给出当前 Lite 可读入口；不覆盖历史、不创建 Full 任务，也不自行转换配置

### Requirement: Stable entry Skills and canonical product files

Full SHALL 保留三个入口 ai-collab-requirements/start/continue 及四个 CE Skill 的现行机器名称、角色锚点、字段和安装路径。规范产品内容 SHALL 在 payload/ 维护，宿主发现副本 SHALL 由官方部署机制管理，单次安装最多选择一个 SkillTarget。Full 的 start SHALL 作为推荐通用入口，条件复用与 requirements 相同的既有需求分析契约；需求明确时 SHALL 保持直接分流，重要业务歧义未经负责人确认 SHALL NOT 进入设计或实现。Lite 的入口及安装集合 SHALL 按 workflow-profiles 契约执行，SHALL NOT 隐式改变上述 Full 入口含义。

#### Scenario: Requirements dialogue
- **WHEN** 用户在 Full 中明确使用 ai-collab-requirements 讨论需求
- **THEN** 先按既有条件契约澄清和记录，负责人明确确认后才交给首席设计师；已明确且已确认的输入不重复确认

#### Scenario: Continue work
- **WHEN** 用户在 Full 中明确使用 ai-collab-continue 接续任务
- **THEN** 检查最新有效 handoff 及授权，只按记录的下一步继续，不重置审查计数

#### Scenario: Clear goal through start
- **WHEN** 用户在 Full 中使用 start 给出可安全总结的明确任务或充分明确的现有 OpenSpec 范围
- **THEN** 按既有风险规则分流，不增加固定需求讨论阶段或重复的确认

#### Scenario: Ambiguous goal through start
- **WHEN** 用户在 Full 中使用 start，Task Intake 无法安全总结重要业务歧义
- **THEN** 同一负责会话可按已有 Requirements Analyst 契约澄清，无须用户另行调用 requirements；等待期间由分析师保有责任，使用既有负责人决定出口，明确确认后只交给首席设计师

#### Scenario: Technical uncertainty without business ambiguity
- **WHEN** Full 的业务目标已经明确，剩余问题属于技术设计或实现可行性
- **THEN** start 交给首席设计师处理该问题，不把技术选择变成业务澄清的阻塞条件

#### Scenario: Existing task or inactive workflow
- **WHEN** 同项工作已有活动任务，或当前处于 disabled 模式、选用了其他控制器
- **THEN** 复用同项身份与累计计数并遵守既有接续规则；disabled 或其他控制器的场景不隐式激活、不覆盖运行态、不新建批次

### Requirement: Protected package lifecycle

官方管理 SHALL 支持现行 Install/Adopt/Status/CheckVersion/Upgrade/SetMode/Uninstall，并按 workflow-profiles 契约处理已安装配置；Adopt SHALL 只接管已登记可信历史布局。升级及卸载 SHALL 保留归属、原始备份、管理块外后续编辑、模式、SkillTarget、项目自有配置和项目证据；升级 SHALL 保留配置身份。未知或漂移内容 SHALL 明确拒绝；不得强制覆盖、手写安装清单、把私人 Lite 当成可信历史或隐式转换配置来绕过检查。

#### Scenario: Valid managed installation
- **WHEN** 目标有有效受管清单且符合受支持的升级条件
- **THEN** 使用官方 Upgrade，保留原归属、备份、配置身份和项目自有内容

#### Scenario: Recognized unmanaged legacy layout
- **WHEN** 无清单且精确匹配已登记旧布局
- **THEN** 可先运行只读 Adopt -Preview，通过后正式 Adopt；不能删除无效清单来冒充该情形

#### Scenario: Local drift
- **WHEN** 升级发现受管内容被修改或新增路径出现不同的项目自有文件
- **THEN** 在写入前报告具体冲突，保留内容并提供最小协调方向

#### Scenario: Repeated install attempts a profile change
- **WHEN** 已有有效安装收到另一配置的 Install 请求
- **THEN** 写入前拒绝，保留现有文件及状态；同配置重复 Install 保持既有幂等语义
