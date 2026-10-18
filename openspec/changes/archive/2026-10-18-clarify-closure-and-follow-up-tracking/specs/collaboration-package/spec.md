## ADDED Requirements

### Requirement: Evidence-backed ordinary accepted closure

新建或正常更新的普通 accepted 关闭 SHALL 在报告验收完成前，取得与最终交接及相关结构输入相符的校验成功依据，记录实际命令、退出码、诊断及输入对应关系。依据 SHALL 位于既有结果、审查记录或外置日志，交接仅引用。校验未执行、失败或依据已失效时 SHALL NOT 报告普通验收完成。记录依据 SHALL NOT 要求循环修改被校验交接、递归校验日志或增加 Routing 机器字段。

#### Scenario: Final closure passes validation
- **WHEN** 负责角色已满足映射验收及所需独立审查，准备普通 accepted 关闭
- **THEN** 对完成的最终交接及相关输入进行结构校验，将实际 exit 0、诊断和输入对应依据记录在外置证据中；交接文件保持为被校验内容，回复只陈述实际检查结论及限制

#### Scenario: Validation fails or has not run
- **WHEN** 最终交接的结构校验失败或尚未执行
- **THEN** 不以普通 accepted 报告完成；可恢复时当前角色修正并复验，需等待环境时使用 continue + blocked 及明确 Resume condition，不把 blocked 关闭

#### Scenario: Checked inputs change afterward
- **WHEN** 校验成功后，交接或影响该结论的结构输入发生变化
- **THEN** 不继续复用失配的成功依据，先对受影响的最终输入复验；仅在独立证据文件记录本次输出不要求重新校验未变化的交接

#### Scenario: Reuse an existing evidence container
- **WHEN** 当前动作已有实施结果、正式审查记录或边界日志可承载检查证据
- **THEN** 复用该容器，交接只保留短引用，不为纯文案另造实施结果、默认报告或强制新账本

### Requirement: Closure evidence preserves existing authority and compatibility

关闭依据规则 SHALL 保留负责人限定接受、现有路由、角色权限、独立审查及累计 verdict 规则。限定接受 SHALL 如实保留未满足验收和未完成任务，SHALL NOT 将其说成技术验证成功，也不绕过无效结构或 blocked 路由。历史记录 SHALL 保持可读，不要求回填归档；新关闭与文件式、回复式输出 SHALL 遵守同一证据真实性和适用范围约束。结构校验 SHALL NOT 被声称为日志认证、宿主遵从或业务验收。

#### Scenario: Owner accepts incomplete delivery
- **WHEN** 有适用于本批的显式负责人限定接受决定
- **THEN** 仅 Chief Designer 以既有 owner-decision 和 Task Owner decision 记录处置，保持未完成映射不勾选并披露缺失证据；结构检查即使成功也不表示这些技术验收已完成

#### Scenario: Legacy closed handoff lacks the new evidence
- **WHEN** 接续或查阅本规则生效前已关闭的记录
- **THEN** 按现有兼容规则读取，不因缺少新增的说明要求重写归档、重开批次或重置审查计数；当前新关闭只使用适用于当前输入的真实依据

#### Scenario: Read-only response cannot persist a closure
- **WHEN** 只读约束要求回复式交接
- **THEN** 不把旧文件的通过结果说成新回复已验证；允许独立快照时说明实际检查对象和未持久化限制，无法取得相符依据时不报告普通 accepted，按既有 blocked/负责人决定边界记录可恢复下一步

#### Scenario: An unchanged non-closure route
- **WHEN** 当前动作仍是 continue、人工决定或 Agent dispatch
- **THEN** 保留原路由和真实边界检查，不引入关闭证据的新机器必填字段、额外审查轮次或重复历史回归

### Requirement: Concise bilingual follow-up navigation

源码 OpenSpec 导航 SHALL 提供实质对应的英文与简体中文后续事项入口，仅记录事项、来源、当前状态和对应变更或完成证据。状态 SHALL 区分待决定、已确认待实施、待验证、已完成；导航 SHALL NOT 复制 tasks.md 进度、审查计数、运行态或成为第二实施权威。待决定和待验证 SHALL NOT 自动授权实施，完成状态 SHALL 有相符证据，不以提案、归档或发行标题代替验收。

#### Scenario: Read current status after a historical deferral
- **WHEN** 人类从导航查阅曾延期的 C1–C5 或本次关闭规则
- **THEN** 可看到 C1–C5 的真实完成证据及本变更当前概况；历史原件保留原文，当前状态以相符任务与审查证据解释，不伪造新的 verdict

#### Scenario: An idea has not been selected for implementation
- **WHEN** 事项来自样例或后续路线图规划，负责人尚未选择其实施
- **THEN** 标为待决定并说明来源和未立项边界，不生成虚构变更、任务编号、交付日期或实施承诺

#### Scenario: Product or walkthrough validation remains unperformed
- **WHEN** G0 外部试用或 Quickstart 某些操作缺乏实际验证记录
- **THEN** 标为待验证并说明未验证范围和启动边界，不把包结构检查当作用户试用或全链路通过

#### Scenario: A formal change progresses
- **WHEN** 某后续事项被正式选择、完成或取得新的验证证据
- **THEN** 导航只更新相应状态与链接，具体实施继续只维护该变更 tasks.md；不得将私人日志、绝对工作站路径或本机运行态复制进公开导航

#### Scenario: Switch navigation language
- **WHEN** 人类在两版 OpenSpec 导航间切换
- **THEN** 事项、状态和证据保持对应，各自正文使用所属语言；公开包不因该源码导航增加新的安装目标
