# Collaboration package Specification

## Purpose

记录已发布 EngRelay v1.7.0 的维护基线，供后续变更比较。依据公开产品规范、
官方管理器和发行记录整理；不搬入私人业务资料、历史批次或旧验收结论。
本基线不构成对所有宿主、旧版本及业务场景的新一轮验证。

## Requirements

### Requirement: Explicit activation and one workflow

工具包 SHALL 保留 optional/default/disabled 及当前任务明确选择优先的语义。
明确选择 EngRelay SHALL 等同于选择兼容名称 ai-collaboration；资料或 Skill
被发现本身 SHALL NOT 激活流程，同一任务 SHALL 只有一个主编排流程。

#### Scenario: Optional installation
- **WHEN** 项目以 optional 模式安装，当前任务没有明确选用该流程
- **THEN** 旧 .ai、角色名称或可发现 Skill 不要求创建运行态或启动角色链

#### Scenario: Disabled mode
- **WHEN** 项目为 disabled 模式
- **THEN** 使用前须明确重新启用，不能因读取入口而隐式改变模式

### Requirement: Coherent role routing and review independence

角色 SHALL 以职责及实际需要路由；稳定范围内的问题由有权限的当前负责人继续。
每个真实交接边界 SHALL 选择 continue/dispatch/close 中一个动作；Agent 派发
SHALL 提供完整自包含 Operator Command。M 代码审查及 H 所需验证 SHALL 保持独立。

#### Scenario: Local implementation issue
- **WHEN** 实现工程师遇到不改变已确认范围、验收或风险的局部问题
- **THEN** 继续在角色权限内处理，不增加机械角色往返，也不豁免所需独立审查

#### Scenario: Review allowance exhausted
- **WHEN** 默认三次累计 verdict 已用尽且问题未解决
- **THEN** 当前负责人说明证据、选项、投入和推荐理由，走既有负责人决定出口；
  追加循环须有适用的有限授权，不能通过改名、换角色或 REVISE 重置累计计数

### Requirement: Stable entry Skills and canonical product files

工具包 SHALL 保留三个入口 ai-collab-requirements/start/continue 及四个 CE Skill
的现行机器名称、角色锚点、字段和安装路径。规范产品内容 SHALL 在 payload/
维护，宿主发现副本 SHALL 由官方部署机制管理，单次安装最多选择一个 SkillTarget。

#### Scenario: Requirements dialogue
- **WHEN** 用户明确使用 ai-collab-requirements 讨论需求
- **THEN** 先澄清和记录，负责人明确确认后才按既有规则交给首席设计师

#### Scenario: Continue work
- **WHEN** 用户明确使用 ai-collab-continue 接续任务
- **THEN** 检查最新有效 handoff 及授权，只按记录的下一步继续，不重置审查计数

### Requirement: Protected package lifecycle

官方管理 SHALL 支持现行 Install/Adopt/Status/CheckVersion/Upgrade/SetMode/Uninstall。
升级及卸载 SHALL 保留归属、原始备份、管理块外后续编辑、模式、SkillTarget 和
项目证据。未知或漂移内容 SHALL 明确拒绝；不得强制覆盖或手写安装清单绕过检查。

#### Scenario: Valid managed installation
- **WHEN** 目标有有效受管清单且符合受支持的升级条件
- **THEN** 使用官方 Upgrade，保留原归属、备份和项目自有内容

#### Scenario: Recognized unmanaged legacy layout
- **WHEN** 无清单且精确匹配已登记旧布局
- **THEN** 可先运行只读 Adopt -Preview，通过后正式 Adopt；不能删除无效清单来冒充该情形

#### Scenario: Local drift
- **WHEN** 升级发现受管内容被修改或新增路径出现不同的项目自有文件
- **THEN** 在写入前报告具体冲突，保留内容并提供最小协调方向

### Requirement: Bounded diagnostics and knowledge retrieval

doctor 与 find-solutions SHALL 保持现行只读边界。文件存在、结构校验或副本
发现 SHALL NOT 被声称为真实宿主加载、业务正确或验收完成；未知事实 SHALL 如实报告。

#### Scenario: Unverified host loading
- **WHEN** 诊断只能确认规范或发现副本存在
- **THEN** 仅报告该事实，宿主加载与遵守规则仍可为 unknown

### Requirement: Traceable and proportional verification

检查 SHALL 覆盖实际受影响行为，并仅在输入和范围匹配时复用既有证据。高投入
低收益或明显超预期成本的选项 SHALL 先说明收益、投入与未知、较小方案和建议，
由负责人明确选择。真实缺陷 SHALL 聚合报告，不受固定发现数量上限约束。

#### Scenario: Documentation-only change
- **WHEN** 修改只影响文案、引用或记账，没有新的行为问题
- **THEN** 不因角色更换或收尾重复全部历史套件，不增加措辞匹配测试

### Requirement: Complete release inventory and private development state

发行包 SHALL 用 snapshot.json 记录实际包版本、文件大小与 SHA256，完整包集合
与字节 SHALL 与清单一致。开发运行态、凭据、私人历史及宿主缓存 SHALL 保留在
忽略或排除范围；开发准备 SHALL NOT 将发布过的包或标签改写为新的内容。

#### Scenario: Clean release export
- **WHEN** 从已审阅源码准备下一发行
- **THEN** 在干净暂存目录导出并重建清单，排除 Git、运行态和本地工具内容；
  结构或哈希检查不被当作发布者签名或业务验收

### Requirement: License notices and bounded orchestration claims

自有内容 SHALL 使用 MIT 并保留适用第三方通知。现有编排角色规则 SHALL NOT
被宣传为已经提供任务依赖图引擎、常驻调度、自动唤醒或后台 Agent 管理。
这些能力的新增 SHALL 作为后续明确需求评估，不从旧路线名或借鉴关系推断完成。

#### Scenario: Future orchestration request
- **WHEN** 用户希望接入宿主原生委派或建设运行时编排
- **THEN** 分析现有宿主能力、许可、成本与最小方案，再确认具体实施及验收范围

### Requirement: 明确区分规范读取与宿主发现

安装使用说明 SHALL 区分安装目标内的规范 Skill 读取路径与可选宿主发现目录，并说明默认 SkillTarget 为 none。双语公开说明 SHALL 保持相同语义，Codex 新安装示例 SHALL 使用显式 agents 目标并说明 codex 目标保留兼容。说明 SHALL 不将手工复制作为常规步骤，也不得将文件放置称为宿主已加载或流程已激活。

#### Scenario: 默认安装后使用规范文件
- **WHEN** 操作者按默认方式首次安装且未传 SkillTarget
- **THEN** 说明和成功提示明确本次未部署本包的宿主发现副本，并提供目标项目内 docs/ai-collaboration/skills 下的规范读取路径；该情况属于成功安装，不要求重装

#### Scenario: 新 Codex 安装选择发现目标
- **WHEN** 操作者需要在 Codex 中发现和显式调用本包 Skill
- **THEN** 双语说明给出首次 Install 显式选择 agents 的示例，说明对应 .agents/skills，并保留 codex 目标及其 .codex/skills 兼容路径；不自动改默认目标或检测宿主

### Requirement: 安装提示保留成功输出兼容

首次 Install 成功后的附加提示 SHALL 简短可见，准确报告所选目标、目标项目内的规范路径及适用的发现路径，并区分文件可读与宿主加载未知。提示 SHALL 与 PowerShell 成功流分离，保留原成功消息的内容、成功流返回及退出结果，不把有效的 none 选择当作告警或失败，也不新增输入或批准步骤。

#### Scenario: 无发现副本的成功提示
- **WHEN** 首次 Install 以 none 目标成功完成
- **THEN** 原成功消息仍在成功流，附加信息提供规范读取路径并说明没有为本次安装部署发现副本，不声称项目中绝对不存在用户自有副本

#### Scenario: 显式目标的成功提示
- **WHEN** 首次 Install 以任一受支持的非 none 目标成功完成
- **THEN** 附加信息同时提供目标名、对应发现目录与规范读取路径，且不声称宿主已发现、加载或遵守 Skill

#### Scenario: 调用方分别捕获输出流
- **WHEN** 调用方仅收集 PowerShell 成功流并单独捕获或抑制信息流
- **THEN** 成功流仍只包含原有成功返回，成功结果不因提示而改变；合并信息流或收集原生进程屏幕输出时可以看到附加提示，不承诺合并文本逐字不变

#### Scenario: 安装失败不输出成功指引
- **WHEN** Install 因已有不同内容、受管漂移或其他既有错误失败
- **THEN** 保留既有拒绝及退出结果，不输出首次安装成功提示，不覆盖冲突路径

### Requirement: 已有安装的发现指引保持归属

已有安装的使用说明 SHALL 优先提供直接读取规范 Skill 的方式，明确重复 Install 和 Upgrade 不用于追加或切换 SkillTarget；确需调整目标时 SHALL 解释现有受保护的官方流程。提示和说明 SHALL 不自动迁移、卸载重装、创建第二目标或接管手工副本，保留项目自有内容、安装归属和升级保留目标的语义。

#### Scenario: 已安装 none 的操作者需要使用入口
- **WHEN** 已有有效 none 安装的操作者希望使用入口 Skill
- **THEN** 说明提供直接读取目标项目规范文件的方法，操作者可继续使用现有安装；只有主动选择宿主发现目标时才参考现有官方目标调整方式

#### Scenario: 重复安装和升级保持已有选择
- **WHEN** 对有效已有安装执行不改变目标的重复 Install 或执行 Upgrade
- **THEN** 原有幂等或升级语义继续有效，既有 SkillTarget 保留，不因新增提示而部署其他目标或改变归属

#### Scenario: 存在手工或同名副本
- **WHEN** 目标中已有用户手工维护的 Skill 或同名不同内容
- **THEN** 说明不要求覆盖或手工删除这些内容，管理器继续按原有归属和冲突规则处理，不将附加提示当作接管授权
