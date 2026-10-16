# Design

## Context

动机见 [proposal.md](proposal.md)。本次只建立正式设计；产品实现尚未开始。

已核对的起点：
- start 的 Procedure 5 要求有重要业务歧义时改用 requirements；后者自身又要求显式调用。直接从 start 载入后者会撞上其激活边界，因此应复用角色契约而非伪造第二次 Skill 调用。
- 需求澄清、负责人确认、基线权威及只交首席设计师的规则已在 workflows 的条件分析师章节和 agent-prompts 的角色卡中存在，无需新增角色或运行字段。
- CE 本地审查已按后果确定深度，调试已有最小根因修复；新增规则只补实际缺口。公开包仅有四个 CE 改写和三个入口，Superpowers 是未跟踪本机工具，不是公开插件依赖。
- 人类说明与 Agent 契约混用。根 README 已双语；project-adoption、产品 README、handoff-schema、根第三方说明存在自然语言混排。产品目录有 30 份 Markdown，全面翻译会扩大到约 7,300 行。
- scripts/manage.ps1 的 Get-BasePlan 自动纳管 docs/ai-collaboration 下的新增文件；Get-SkillCopyPath 仅映射七个 Skill；Read-State/Get-InstalledLayout/Get-UpgradePlan 要求精确旧布局与新增登记。只添加译文会使旧布局无法匹配。
- 当前公开版实际为 v1.7.1；config 中“current baseline 1.7.0”是陈旧引导文本，不能据此当作当前发布事实。根 snapshot 仍代表已发布版，不在开发阶段刷新。

## Goals / Non-Goals

**Goals:** 以既有角色、Markdown 文件和安装转换登记实现增量行为；人类翻译与 Agent 契约各自保持用途明确。范围及验收以本变更增量规格为准；本设计没有额外必做产品功能。

**Non-Goals:** 不删除 Skill、不建设调度或本地化框架、不翻译机器字段/模板/输出、不安装上游插件、不修订历史审计原件、不执行真实部署或 Git 发布。旧 C1-C5 授权仍独立待办。

## Decisions

### 1. 复用现有需求分析角色，两个入口保持轻量

共享过程以 workflows.md#requirements-analyst-conditional-role-action 为操作依据，agent-prompts.md#requirements-analyst 保持角色职责和禁止事项，README 的相应章节仅作解释与索引；入口不再复制完整访谈和确认步骤。

start 的激活、同项接续、无关未完任务保护和旧批次归档逻辑保留。Task Intake 检出重要业务歧义时，在最小 current-task 中记录 Initial role=Requirements Analyst，并在同一负责会话执行上述现有角色动作。等待时 handoff 的 Current role 是 Requirements Analyst、Next action=continue、Current status=awaiting-owner-decision，下一角色字段为 none，并附 Owner Decision Brief。这不要求用户再调用另一个 Skill，也不让 Task Intake 冒充分析师完成确认。

requirements 保留显式需求讨论快捷入口和原激活限制，同样经 Task Intake 进入共享角色动作。明确任务继续现有快捷分流；已经确认的目标复用确认。技术问题交 Chief Designer，不形成业务访谈题。确认后按原角色契约只 dispatch Chief Designer；不从分析师直接进入实现。start 作为入口本身仍不写产品代码。

改动集中在两个 canonical SKILL.md、workflows 的入口/条件角色章节及必要的 README 入口索引；agent-prompts 只有出现真实冲突才作最小澄清。agent-rules 现有规则已允许条件角色，不改管理块。continue 的行为、机器字段、七个名称与路径保持不变。

替代方案：删除 requirements 需迁移已安装副本、提示词和旧交接，收益小；把其全文复制进 start 会产生两份确认规则；新增路由服务或新的 Skill 均无必要。

### 2. 固定来源，按规则选择性同步

2026-10-16 已对照本地原文、GitHub 官方固定版本差异及通知，结论如下。参考版本不是完整移植声明，后续文档明确区分原改写基线与本次选择性核对版本。

| 来源与路径 | 兼容结论及最小动作 |
| --- | --- |
| CE 3.30.5，50532b00de523980010d97fe950965b35382a3b7；对比基线 4043703d32c5df9e35f22757dee22f3a72a99c66 | 在 compound-engineering 的现有来源区记录本次采用和不采用项，不创建第二份项目计划 |
| PR 1792，reliability-reviewer | ce-code-review 补充 I/O 缺口的实际后果条件；已有按后果定深度规则保留，不导入 P0-P3 或置信分数字段 |
| PR 1852，maintainability-reviewer | 同一 Skill 补充明确范围证据和可指认的依赖替代；简短需求未提及某项并不证明越界，不削弱已有 must-fix 越权规则 |
| PR 1791，ce-debug/references/defense-in-depth.md | ce-debug 补充重复根因的受限防复发措施：最小修复先通过、只触及已授权受影响位置、不变更公共接口；超界或投入不相称时记后续建议 |
| ce-simplify-code / ce-compound | 不引入上游独立执行/分类系统；本地简化、学习准入和 retire_when 已满足既定需要。本次 ce-compound 模板分类枚举变化不适用本地模板 |
| CE 跨模型 transport、peer fallback、提交惯例、插件安装 | 不采用；本地没有对应传输层，提交授权归任务负责人，不能借方法同步扩权 |
| Superpowers v7.0.0，bb92a77741419a4ab5f06e711a283343f1ada0c3 | 新 brainstorming 的按任务规模处理已由本地角色规则覆盖；不导入写设计、强制 TDD、自动委派或分支收尾生命周期 |
| Superpowers systematic-debugging 的环境变量示例修复 | 本机忽略副本确有旧示例，但公开包未捆绑。开发指南提供风险和按原安装来源更新的建议，操作本身留在独立本机维护任务，不编辑生成副本或安装全局插件 |

CE 3.30.5 的 LICENSE blob 仍为 959dd283c510cfac6fd912555f99b14613ee9018，与现有通知相同；保留原完整 MIT 声明，在实际采用的文档/Skill 中补本次来源，不把所有旧内容改称来自新版本。不复制上游原文大段内容或源码树。

参考：
- [CE 固定比较](https://github.com/EveryInc/compound-engineering-plugin/compare/4043703d32c5df9e35f22757dee22f3a72a99c66...50532b00de523980010d97fe950965b35382a3b7)
- [PR 1791](https://github.com/EveryInc/compound-engineering-plugin/pull/1791)、[PR 1792](https://github.com/EveryInc/compound-engineering-plugin/pull/1792)、[PR 1852](https://github.com/EveryInc/compound-engineering-plugin/pull/1852)
- [Superpowers 固定版本记录](https://github.com/obra/superpowers/blob/bb92a77741419a4ab5f06e711a283343f1ada0c3/RELEASE-NOTES.md)

### 3. 按主要读者确定文档清单

新增文件统一用 .zh-CN.md 后缀；两种语言互链，说明内容相应。以下表中的 payload 文档安装后去掉 payload/ 前缀。

| 现有路径或新指南 | 具体处理 |
| --- | --- |
| README.md / README.zh-CN.md | 同步入口用法及语言范围，提供对应语言的人类指南/贡献/维护/许可导航；入口安装示例语义不改 |
| CONTRIBUTING.md | 新增 CONTRIBUTING.zh-CN.md，说明贡献约束与配对更新规则 |
| docs/development.md | 新增 docs/development.zh-CN.md；人类维护说明可翻译，可复制 Agent 提示词原文继续英文，并明确标作引用 |
| CHANGELOG.md | 新增 CHANGELOG.zh-CN.md，覆盖现有 1.7.0/1.7.1；两者增加 Unreleased 记录本次变化和真实验证边界，不伪造发布日期或覆盖历史条目 |
| THIRD-PARTY-NOTICES.md | 新增 THIRD-PARTY-NOTICES.zh-CN.md，移出原末尾中文摘要，提供完整对应人类来源说明；适用 MIT 原文完整保留为许可原文引用 |
| openspec/README.md | 新增 openspec/README.zh-CN.md，仅翻译维护导航，不翻译 formal specs/config 或归档提案 |
| docs/reviews/README.md | 当前中文索引正文整理为英文并新增 README.zh-CN.md；保留轮次、状态事实和原审查链接，不编辑子目录审计原件 |
| payload/docs/ai-collaboration/operator-guide.md | 新增此英文指南及 operator-guide.zh-CN.md，为人类解释安装入口、角色选择、需求确认、接续、交接/审查结果阅读、成本和授权边界；链接现有规范，不重述角色契约全文 |
| payload/docs/ai-collaboration/project-adoption.md | 英文正文中的两段中文等义改为英文；新增 project-adoption.zh-CN.md，覆盖现有各采用路径和限制 |
| payload/docs/ai-collaboration/host-capabilities.md | 新增 host-capabilities.zh-CN.md，目标名和诊断状态保持标识符；同步实际版本引用但不扩大宿主验证声明 |
| payload/docs/ai-collaboration/examples/mobile-points-expiry-reminder.md / mobile-points-expiry-reminder-zh.md | 保留原文件名作为兼容例外，补语言互链；中文自然语言解释保持中文，代码围栏内机器标题、状态及角色名保留原值 |
| payload/docs/ai-collaboration/README.md / handoff-schema.md | 仍为英文规范；仅把现有中文说明/示例等义改为英文，加入人类指南链接，不新增对应中文契约 |

排除项按目录归并：AGENTS.md、agent-rules.md、所有 SKILL.md、agent-prompts、workflows、compound-engineering、solution-exploration、templates、payload/docs/reviews/README、payload/docs/solutions 的操作规则/模板以及两个 review-*-optimization 提示词示例，主要用于约束 Agent，不创建中文副本。脚本/JSON/YAML 和历史审计原件也排除；翻译范围表本身不把已有审计结论升级为新验收。

语言分离针对自然语言句子，不按“出现英文字母”拦截中文文档。允许语言切换标签、产品名、路径、命令、状态/字段及许可证或 Agent 提示词原文；例外在指南中明示。正文中的无必要整段另一语言需移到对应版本。避免将同一段业务说明在文件中双语并排。

部署目录内指南仅用同目录或目录内部相对链接，避免指向包根维护文件的 ../../../ 链接在安装后越出项目。根 README 链接 payload 下指南；源码/完整包与安装后 docs 布局分别核对链接。

替代方案：翻译全部 7,300 行和生成 Skill 会增加提示 token、规则漂移及机器解析风险；仅翻译根 README 又无法覆盖采用和维护。本表限于专门人类说明，预计两次实现会话，可复用已有英文内容，无需语言选择参数或本地化资源框架。

### 4. 仅增加四个部署文档，精确登记布局

新增部署路径固定为：
- docs/ai-collaboration/operator-guide.md
- docs/ai-collaboration/operator-guide.zh-CN.md
- docs/ai-collaboration/project-adoption.zh-CN.md
- docs/ai-collaboration/host-capabilities.zh-CN.md

其余新增译文位于包根/源码说明目录，不进入安装目标；openspec 和 docs/reviews 继续由既有 export-ignore 排除。七个 Skill 发现副本不包含这些人类指南。Get-BasePlan 已支持这些路径，不改 manage 的算法、输出流、错误码或参数。

scripts/supported-layouts.json 中：
- 对既有 1.2.0/1.3.0/1.4.0/1.5.2/1.5.3 条目，保留 paths、指纹和 retirements，按序追加上述四个 additions；不重新定义旧版字节。
- 为公开 v1.7.0 和 v1.7.1 分别登记真实旧 base plan（含 AGENTS/.gitignore 共 40 项）、本次四个 additions 和空 retirements。输入取自可信不可变标签的 snapshot，部署指纹按现行算法计算。规划时读到的值为：1.7.0 = 794ee5dcbf019c5e981b1a5ee1472edfad1e392e39bc560630985c35e73279c6；1.7.1 = 04c21e9565c1f455bf4555248f3708aa7737ca6aeb69fe1b83771d3c7354c681。实现必须从原 snapshot 再现，不能把本表当作绕过校验的手写清单。
- 1.6.1 冻结夹具是独立历史选项，当前无可信完整旧包输入；不编造指纹或声称已测。未登记/unknown 布局保留拒绝路径及用原包协调的方向，公开支持范围与实际证据一致。

同字节预有文件由既有 preexisting 规则保护；不同字节、路径类型冲突或受管漂移在写入前拒绝。历史 legacy-adoption catalogue 不改成新内容，不通过清理 manifest 迁移。

### 5. 聚焦验证与候选准备

规划阶段只执行 OpenSpec 结构、引用、实际差异与运行态结构检查，不运行产品生命周期套件；实现阶段执行以下受影响检查。

| 检查 | 具体范围与证据 |
| --- | --- |
| 入口契约 | 明确任务、重要业务歧义、已确认需求复用三个关键场景，使用可用受测 Agent 与一次性虚构输入，记录实际角色/下一动作/确认状态；其余同项接续、无关未完任务、disabled/其他控制器与技术歧义按契约核对。不以字符串匹配证明 Agent 行为 |
| 方法规则 | 用短的成对案例检查可恢复脚本失败/实际数据损害、简短未提及/明确排除、重复局部根因/单点缺陷、越界结构建议等选择；记录判定依据及未验证的宿主行为，不跑上游整套 eval |
| 人类文档 | 对范围表逐份核对实质等义、语言互链、原文引用例外和相对链接；Agent 契约中文清理核对字段/锚点不变；不写逐词镜像测试 |
| 布局静态差异 | 比较实际新增 payload 路径与每个受支持旧布局 additions 的精确集合；原指纹/paths 不变。公开两版从标签 snapshot 重算 |
| 一次性生命周期 | 使用新的聚焦 scripts/test-human-doc-lifecycle.ps1；参数 PackageRoot、PreviousPackageRoot、LogPath，支持指定完整旧包。Windows PowerShell 5.1 与 PowerShell 7 各执行当前公开 1.7.1 的 none/agents 升级及卸载；1.7.0 用 codex 作一个兼容路径检查，无需九目标全矩阵 |
| 归属与拒绝 | 同一聚焦脚本覆盖新安装文档受管、同字节预有文件卸载后保留、不同字节冲突零写入、旧受管漂移零写入；核对原备份、模式、目标、管理块外哨兵和四个新人类文档。零写入以目标树含恢复元数据前后哈希及子进程退出结果证明 |
| 独立审查 | 一次聚合 M 代码审查检查全部本批差异、实际证据、译文范围和权威；实现者不自行完成该项。没有发现时可依现有规则闭批 |

Agent 行为检查使用宿主现有能力；不为三组场景开发通用 eval、编排或模型传输系统。按实施时适用 Skill 的验证规则执行；缺少可用受测环境时报告 unknown 与实际限制，不能把人工审读冒充已运行的行为检查。明显超预算的真实宿主试运行先说明成本与较小替代，不静默升级验证范围。

未提交改动的临时候选：用 git archive 导出已审阅基线 HEAD 到已验证 GUID 临时目录，逐文件覆盖本设计授权且实际发生的公开改动/新增文件；生成覆盖文件清单与 SHA256，排除 .ai/.codex/.agents/openspec/docs/reviews。不改 Git 索引或制造提交。归属验证日志置于候选之外；用候选内 update-snapshot -PackageRoot 指定候选 -Version 1.8.0 -ForRelease 建清单。1.8.0 仅为夹具测试版本以避免相同版本异指纹拒绝，不是本次发布决定；根源文件默认版本、历史 snapshot 及发布标签保持原值。后续若用户请求发行，再按开发指南从正式审阅提交导出。

旧包用 git archive v1.7.0/v1.7.1 的不可变输入在独立临时根导出，先核对与其 snapshot 的集合/字节完全一致；不为失败的旧输入刷新清单掩盖漂移。未取得匹配完整旧包时停止相应生命周期结论并记录限制，不进行真实项目安装。

常用命令在环境 PATH 正常时使用 openspec；本机会话解析不到命令时，仅在本机进程使用已核实的 Node 和 CLI 绝对路径，工具解析信息保留在忽略的运行态，不修改全局 PATH。验证命令为 openspec validate streamline-entry-and-human-docs --strict、git diff --check 及限定范围的引用/语言核对。

## Risks / Trade-offs

- [需求被误判为明确而跳过确认] → 共享原角色动作，关键歧义/确认用成对输入检查；不把入口统一解释为 start 有实现权限。
- [方法更新导致过度防御或越界重构] → 实际后果、明确范围和局部根因约束；上游已有或不适用变化只记结论。
- [翻译漂移与重复上下文] → 固定人类文档清单和双向导航，改动时同步配对；Agent 不读取两套契约。
- [新增译文使旧布局升级拒绝] → 四路径集合登记、公开旧版指纹溯源及聚焦生命周期；不放宽未知布局。
- [高收益不足的历史/全宿主验证] → 公开两版和代表目标覆盖实际变更，旧已登记版本做精确集合检查；其余不承诺新验证。
- [本机 Superpowers 风险被误称已修复] → 保留原副本，维护说明明确风险与独立更新方向；本任务不声称全机工具升级。
- [结构校验被当作独立审查或宿主验收] → 输出分别声明；累计 review 只在真实 verdict 时递增。

## Migration Plan

单一 M 批次的现行身份由 .ai/current-task.md 记录，预计两次实现会话完成统一入口与配套人类说明，并一次聚合独立代码审查；不按文件或三个需求标题重置批次。first demonstrable outcome 是用户依据对应语言的人类说明选择 start，明确任务可直接分流、歧义任务可在原会话确认，再按既有规则交接，同时旧安装能保护性获得这些说明。

端到端可行性结论：proceed。入口与方法只改现有 Markdown 契约；四个新部署文件已有通用归属机制，旧版真实 snapshot 可得；无需新协议、依赖、公共接口或复杂度例外，也无需人类预先启动业务应用。未验证的 Agent 宿主加载是明确限制，不能据此宣传保证。

Design Reviewer decision: no。方案沿用现有角色动作、目录和布局登记，未引入复杂度例外，首批结果可演示；最终 M 独立代码审查保留。此判断是设计路由，不是独立审查 verdict，不改变运行态累计计数。

实现先完成入口/方法，再完成对应人类说明与布局登记；唯一实施清单为 tasks.md，所有实施项初始未勾选。当前角色只输出规划并 dispatch Implementation Engineer；OpenSpec propose 的本轮规划边界不允许立即 apply。实现失败保留本批证据并按正常 continue/fix/disposition 路由，不恢复整个用户工作树、不伪造关闭或重置审查计数。

本次无真实迁移。未来获得部署授权时才使用可信完整新包 Upgrade；出现拒绝保留具体路径和备份，用原包协调，不删除清单强装。未来回退需评估原包和当前字节，不能靠把旧 snapshot 覆盖到新文件上完成。
