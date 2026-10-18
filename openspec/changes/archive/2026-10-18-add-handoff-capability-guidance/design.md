# Design

## Context

动机与范围见 [proposal.md](proposal.md)，验收行为见 [增量规范](specs/collaboration-package/spec.md)。本次保留已确认的五档、单行显示和非阻塞边界，不扩大需求。

已核对的复用依据：

| 现状与依据 | 对实现的约束 |
| --- | --- |
| payload 下 handoff-schema 已有 Current Status、Agent/人工 dispatch 区分及回复式降级 | 在现有状态说明中显示建议，不扩充 Routing |
| handoff.template 已有 Current Status；response-handoff.template 目前只有平铺路由项 | 文件模板增加条件提示；回复模板及 schema 内嵌示例补短 Current Status 区域，保留全部原字段及文件未更新提醒 |
| agent-prompts 的 Common Preflight 与 workflows 的 Role Exit Contract 已集中规定出口 | 两处只引用集中规则，不逐角色复制默认表；README 的 Routing Contract 增加短索引 |
| validate-runtime-state 按既有必需章节、路由字段及角色锚点检查，没有能力行要求 | 保持脚本不变；缺少新行仍可结构校验，新行也不改变合法性 |
| 主规格要求双语人类说明、英文单份 Agent 契约、保留累计 verdict | 人类指南提供对应简短说明，规范表只维护一份；本批 round 从既有 0 延续 |
| 开发指南区分源码和完整发行包 | 不向本仓库安装，不刷新根 snapshot，不把文档检查称为宿主加载 |

代码知识图已查询运行态校验器；该 PowerShell 文件索引覆盖为 partial，故直接核对源码的必需章节、任务编号、角色与路由检查。公开文件现状支持新增说明，但尚无修改后的 Agent 遵从证据，不能声称功能完成。

## Goals / Non-Goals

**Goals:**

- 一次真实 Agent 派发可用单行告诉用户下一项工作建议使用的能力档位；通过固定表避免逐次额外分析。
- 文件式和回复式一致，既有交接可接续，建议不影响已有权限或验收。
- 一个 M 批次交付产品修改、双语说明、聚焦证据和独立代码审查。

**Non-Goals:**

- 不提供模型或推理强度的型号映射、排名、测评或自动配置；用户自行结合可用模型作选择。
- 不建设运行时调度、不改变安装算法/路径/manifest、校验器和生成宿主副本。
- 不为历史 handoff 回填档位，不扩展到路线图阶段、发布或真实部署。

## Decisions

### 1. 单份集中规则，最小出口接入

在 `payload/docs/ai-collaboration/handoff-schema.md#capability-tier-guidance` 新增英文规范段落，集中维护五档定义、默认角色表及覆盖规则。复用原有 Current Status，不把建议加入 Routing 或 Operator Command，不新增机器字段。

输出样式为 Current Status 下单独一行 `Recommended capability tier: C3`，随后保留简短状态正文。只有有效 Agent dispatch 使用，且 final 回复简短同步同一值；不粘贴五档表、解释理由或再写一份能力报告。人工决定、continue、close 不显示。

两份规范模板及 schema 的回复式内嵌示例同步条件说明；回复式模板新增的 Current Status 仅承载相同说明，不改平铺路由键或 persistence 提醒。Common Preflight、Role Exit Contract、README Routing Contract 仅链接这一个规范段落。入口 Skill 已通过模板和 schema 接入，无需为本批修改各 Skill 或生成副本。

相比为每个角色/Skill 复制表格或添加结构校验，这个方案改动集中，兼容旧文件，也减少每次输入与维护成本。

### 2. 固定默认表，仅使用现成难度信息

规范五档沿用已确认语义：

| 档位 | 简短含义 |
| --- | --- |
| C1 | 基础执行：按已给步骤完成机械、明确的工作 |
| C2 | 常规实现：处理边界清楚的常规局部任务 |
| C3 | 综合工程：协调实现、检查和常规审查 |
| C4 | 深度分析：处理设计权衡或复杂跨模块推理 |
| C5 | 高难度推理：任务已明确要求的特别困难推理 |

按下一角色查表，完整覆盖现有标准角色和 Task Intake：

| 默认档位 | 下一角色 |
| --- | --- |
| C1 | Documentation Steward |
| C2 | Task Intake、Requirements Analyst、UI Designer、Test Engineer |
| C3 | Implementation Engineer、Fix Engineer、Code Reviewer、Verification Reviewer |
| C4 | Chief Designer、Design Reviewer、Architect |
| C5 | 无默认角色 |

已有任务明确说明工作难度时优先使用其信息：明确高难度推理为 C5，明确需深度分析为 C4；没有这些复杂性要求且明确为机械工作时用 C1、明确为常规局部任务时用 C2。其余直接用角色默认值，不专门调查或编写理由。档位针对本次下一项工作，不是对整个角色或模型的永久评级。

不从 S/M/H、历史轮数或单次失败推导升档；不新增等待“更强模型”的路由。仅有“任务难”或没有明确信息时保留默认值，不为 C5 另启评估。此表是人工建议，不认证某模型能胜任，也不豁免原有角色能力与独立性要求。

### 3. 人类说明与历史兼容

两版 operator-guide 各提供简短五档释义、单行样例及集中规则链接，明确仅供选模参考。它们是同一规则的人类语言说明，不复制维护另一套角色默认表。根目录两版 README 只补能力概览/指南入口；两版 CHANGELOG 只在未发布段落记录实际完成的行为和证据限制，保留 v1.8.0 的历史说明。

旧 handoff 无能力行直接按原路由接续，不强制迁移或补档；新建/正常更新时按新契约输出。既有校验器继续只检查原协议。旧交接缺行不构成接续前提；新输出是否遵循建议规则由契约检查与审查核对，不能仅凭结构校验判断。生成宿主副本仍由官方部署管理，不在源码中手改。

### 4. 端到端可行性与首个展示结果

| 必需结果 | 可行路径与检查 |
| --- | --- |
| 一行可读建议 | 集中规则 → 共用出口/模板 → 一份常规实现派发样例显示 C3；最终真实实现交接也按同表给下一角色建议 |
| 无逐次评估 | 固定表 → 使用已给任务信息覆盖 → 普通、机械、常规局部、已知复杂与明确 C5 输入进行短契约演练 |
| 回复式一致 | 相同输入分别形成文件式和受只读限制的回复式输出，比对档位、位置、命令及 persistence 提醒 |
| 兼容旧交接/其他动作 | 旧 Agent dispatch 缺行、人工决定、continue、blocked continue、close 样例沿用旧协议；既有校验器检查有效/无效路由 |
| 建议不变权限 | 独立审查核对规范和输出，确认无新资格/批准/阻塞或自动选模；保留 M 独立审查及累计计数 |

可行性结论：可以按该最小方案实施，无需先做 spike；模板和共享出口均已存在，未发现必须引入新代码或宿主依赖的障碍。真实宿主是否遵守提示词仍是未验证限制，不把它作为本批必须建设测评系统的理由。

首个可展示结果为一份清楚标注的样例 Agent 派发，用户看到 Current Status 下 C3 并可查五档短释义；样例不是伪造的真实审查或验收。

### 5. 聚焦验证与证据边界

实施只维护本变更 tasks.md，证据在原 result 模板的 Checks Run 记录；handoff 只链接真实文件。具体命令使用当前环境可用的 OpenSpec/PowerShell 启动方式：

- `openspec validate add-handoff-capability-guidance --strict`。
- `pwsh -NoProfile -File payload/docs/ai-collaboration/scripts/validate-runtime-state.ps1 -WorkspaceRoot <经核对的独立结构夹具根>`；占位路径须替换为实际创建的 GUID 目录。当前源码缺安装 docs 路径，不能直接把源码根的缺路径错误当成产品回归。
- `git diff --check`，另检查新建未跟踪文件；核对实际差异、章节锚点及双语对应，不只做关键词存在检查。

结构夹具放在被忽略的独立 GUID 目录：复制当前 task/handoff、真实 tasks、所引用输入及模板，另将 canonical agent-prompts 同字节复制到夹具的 docs/ai-collaboration，满足校验器现有角色路径；不安装包，不复制旧批次运行态，不作为完整安装源。记录夹具路径、输入哈希、命令、输出及退出码。

契约演练覆盖：角色默认表各组和角色覆盖完整性、C1/C2 轻量覆盖、C4 已知复杂、C5 明确要求、单次失败不升档、仅有风险标签不升档、文件/回复一致、人工决定/普通及 blocked continue/close 无能力行、旧 dispatch 缺行。对合法 dispatch 增删能力行后各跑一次原校验；对同一份无效 Routing 在有/无能力行时确认仍被拒绝。

这些是输出契约、模板和结构兼容检查，不是模型基准测试或真实宿主加载证明。样例明确标注来源与预期；实现者不得把自己手写期望输出称为独立 Agent 遵从证据。独立 Code Reviewer 检查实际规则是否足以产生这些结果及是否有遗漏，不为每个文案新建措辞匹配测试，不重放安装全套或历史业务回归。

### 6. 风险、批次与下一路由

保持 M：影响共享交接表达，需要一次独立代码审查。无新增架构、依赖、机器协议、权限/归属边界或复杂性例外；首批即可展示完整建议行为。因此 Design Review 决定为 **no**，直接交 Implementation Engineer，后续独立 Code Reviewer 核对设计与实际修改。这个决定不是设计审查 verdict，不消耗 review round。

同一 Execution Batch 映射全部实现和验收项，不把模板、文档或测试拆成单独批次。产品修改预计一个实现会话；本轮只建立规划和交接，所有实现任务保持未勾选。若出现新机器字段、校验逻辑、安装布局变化或必须新增高成本测评，停止受影响部分并回 Chief Designer；安全的既定范围可继续，不默认取消本功能。

## Risks / Trade-offs

- [用户把档位当资格认证或最低模型门槛] → 明示人工建议，不生成资格检查、配置动作或等待更强模型的阻塞。
- [固定角色表可能偏高或偏低] → 对本次工作复用已明确的轻量/复杂信息覆盖；无信息用默认值，实际交付仍靠检查和独立审查。
- [五档/映射被多处复制导致漂移、增大 token] → 一份英文规范表，共用出口和模板只链接；每次交接只加一行。
- [回复模板和 schema 示例不同步] → 同一任务修改并演练同一输入，保留所有既有路由项与完整命令。
- [旧交接误被要求补行] → 不修改校验器，不回写归档，覆盖缺行兼容及无效路由仍拒绝的检查。
- [提示词规则不被宿主遵守] → 报告证据范围；不承诺零副作用或全宿主可用，不引入不相称的运行时引擎/模型评测。

## Migration Plan

开发实现只更新 canonical 产品规则与对应文档；无需运行态迁移。未来获准发行时按开发指南导出已审阅提交，在干净暂存重建完整 snapshot，再按既有官方 Upgrade 分发；本批不执行发布或实际部署。

如候选有问题，撤回候选中的建议说明和模板变更即可恢复旧输出约定；不得重写历史包、标签、审查或运行态。旧交接始终按原 Routing 可读。
