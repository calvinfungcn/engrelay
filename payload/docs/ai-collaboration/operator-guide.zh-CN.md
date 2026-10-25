# 操作指南

[English](operator-guide.md)

面向人类的使用说明。角色契约、机器字段与校验规则以 [README.md](README.md) 与
[handoff-schema.md](handoff-schema.md) 为准；本文件不替代它们。

## 激活

包管理项目在
[可选激活](README.md#optional-activation-and-coexistence) 下使用 `WorkflowMode`
**optional**（新安装默认）、**default** 或 **disabled**。当前请求对本工作流的
**明确选择**优先于项目的 **default** 默认选择。在 **optional** 模式下需在当
次请求中显式选择 EngRelay；在 **default** 模式下可按项目已配置的默认选择运
行，无需每次重复声明。仅安装工具包、发现 Skill 或存在 `.ai/` 目录本身不会
启动批次。

若 `WorkflowMode` 为 `disabled`，使用前需显式重新启用。若任务由其他控制器负责，
遵循该控制器，且不写入协作运行态文件。

## 入口

| 入口 | 适用场景 |
| --- | --- |
| `ai-collab-start` | 推荐：有明确目标的新任务 |
| `ai-collab-requirements` | 设计前显式进行业务需求讨论 |
| `ai-collab-continue` | 接续最新已授权交接 |

无宿主发现副本时，请让 Agent 直接阅读已安装项目下的
`docs/ai-collaboration/skills/<name>/SKILL.md` 规范 Skill。

### Start（推荐）

- **目标明确：** Task Intake 准备最小任务输入，按风险分流（如首席设计师、实现工程师或代码审查员），不插入固定需求阶段。
- **重要业务歧义：** 同一负责会话执行
  [条件需求分析师](workflows.md#requirements-analyst-conditional-role-action) 动作；不要求负责人再单独调用 `ai-collab-requirements`。
- **业务已明确、剩余为技术问题：** 交给首席设计师，不把技术选择变成业务访谈阻塞项。
- **已确认的需求：** 直接复用，不重复最终确认。

### Requirements（显式快捷）

与 start 共用同一分析师契约，仅在负责人明确选择“先谈需求”时激活。负责人明确确认后，只交给首席设计师。

### Continue

阅读 `.ai/current-task.md` 与 `.ai/handoff.md`，仅按记录的下一步动作继续；不重置审查计数、不重放已关闭批次。

先看 `Human Action Required`：`none` 表示当前无需人工介入，`awaiting-decision`
表示需回答决定简报，`awaiting-environment` 表示下一步需要交接中说明的人工准备。
远期环境预告必须明确当前无需操作或回复。旧交接没有该摘要时，按实际状态和
前置条件判断。

可执行的 `continue` 在 `Current Status` 下附 `### Continuation Command`。
有能力的活跃 Agent 核对最新授权及执行归属后直接继续。若单次 CLI 已退出，
操作者或已有外部运行器可以把该块复制到接替会话；单次运行结束不代表环境阻塞。
已有授权内的离线工作由 Agent 自行选择本地 CLI 或 IDE 宿主，无需请示负责人；
实际权限、负责人决定、审查上限及独立审查要求仍然有效。EngRelay 本身不会
唤醒已退出的进程。详见[自主接续规则](handoff-schema.md#autonomous-continuation)。

## 交接与审查

- 下一步动作仅一种：`continue`、`dispatch` 或 `close`。
- 向 Agent 派发时附带完整 Operator Command。
- Agent 派发须在 `Current Status` 下给出一行建议，例如
  `Recommended capability tier: C3`。档位 C1–C5 仅提示为**下一项**工作选择模型与
  推理强度：C1 机械执行、C2 常规局部、C3 综合工程、C4 深度分析、C5 高难度推理；
  不批准模型、不阻塞流程、不替代独立审查。固定默认表与规则见
  [handoff-schema.md#capability-tier-guidance](handoff-schema.md#capability-tier-guidance)。
  人工决定派发、`continue` 与 `close` 省略该行。该行是建议而非门槛；旧交接缺少该行仍有效，
  结构校验也不核对该行。
- 负责人决定使用 `awaiting-owner-decision` 与 Owner Decision Brief；沉默不构成批准。
- 每次派发都明确列出可写的交接产物。仅因审查独立或只读代码，不会自动禁止 `.ai/`
  更新；真实的用户、上位指令或工具限制才会禁止，此时回复须附完整交接。
- 真实边界上，写入的 Agent 保存 `.ai/handoff.md`、回读，并用
  `validate-runtime-state.ps1` 按其已决定的批次、动作、下一角色和审查计数核对
  （`-ExpectedBatchId`、`-ExpectedNextAction`、`-ExpectedNextRole`、
  `-ExpectedReviewRound`；存在修订号时加 `-ExpectedStateRevision`）。通过只说明
  所给值与结构一致。
- 只读子代理的结果，由仍活跃且获准写入的委派 Agent 在同一边界发布或落盘，并在其回复中说明发现的问题。没有可写者时，
  回复中的完整交接须说明尚未落盘。
- 若同批次审查记录，或 live 交接（含其 Next output files）与当前任务点名的结果或响应文件比 live 交接更新，`ai-collab-continue` 先按真实 SHA256
  指纹与修订号恢复该转移（见[来源匹配恢复](handoff-schema.md#source-matched-recovery)），
  不重新计数审查结论，也不重放命令。新容器必须带真实 SHA256；只有旧版索引链接审查记录与
  旧版响应交接可以省略。一个批次最多恢复一个待应用转移。
- 计划结束当前会话即使角色不变，也是交接边界；长检查可保留一个外置日志检查点，并说明检查尚未通过。
- 这些检查不会唤醒进程、不认证已保存的日志，也不构成验收。
- 中风险批次需独立代码审查；见 [审查上限](README.md#review-round-circuit-breaker)。

正式审查轮次与结果索引见 `docs/reviews/`（若已记录）。

## 关闭与校验

普通 `accepted` 关闭表示本批映射范围在记录验收下完成，不代表父级 OpenSpec
全部完成或业务已验收。在把批次视为“已验证”之前：

- 责任 Agent 先定稿 `.ai/current-task.md`、映射的 `tasks.md` 与 `close` 交接，
  再对这些**最终**输入运行项目的 `validate-runtime-state.ps1`。
- 命令、退出码、诊断及被检输入对应关系写在链接的结果或审查文件中，不要
  把命令字符串放进交接证据的反引号路径里。
- 校验输出记录在被检交接**之外**，避免循环修改被检内容。
- 校验失败或环境不足时保持 `continue` 或 `dispatch`；用 `blocked` 与恢复条件，
  不要关闭。Chief Designer 仍可按原规则记录**负责人限定接受**
  （`Acceptance basis: owner-decision`）；这不等于技术校验通过。

完整规则见
[handoff-schema.md#accepted-closure-validation](handoff-schema.md#accepted-closure-validation)。
源码仓库的后续事项导航在 GitHub 公开 OpenSpec 说明中维护，安装导出包内
不包含该导航。

## 证据与只读返回示例

以下示例均为示意，其中的数字是假设的，不记录真实运行。

- **外置大量输出。** 把长检查写入交接之外的具名文件，例如 `.ai/<批次>/checks/unit.log`，
  只返回退出码、简短摘要和路径。命令与退出码记录在结果文件的 `Checks Run` 表中，
  不要放进交接证据的反引号。
- **先做一次最小取证。** 当验收需要真实 Agent 调用证据、而取证方法尚未验证时，先完成一次
  最小端到端调用，确认它能对应输入、返回内容、产物和最终交接核对。无法取得的宿主信息
  记为未知；不得事后补填状态。
- **计数勘误。** 汇总写“七次启动”，但指定来源表列出六次 Agent 调用。应在汇总旁增加带日期的
  勘误，引用该来源并写明六次；启动、后续输入、失败与共享协调须分别表述，不能把缺失记录当作零。
  只复核受影响的统计，不改原报告。
- **完全只读返回。** 只读评审返回完整结论、发现和响应交接，包括来源角色、来源 Agent、产出者、
  来源 Execution Batch ID、Task ID、先前 State revision、先前 live SHA256、目标 State revision
  与累计 Review round。仍活跃的可写者随后应用[来源匹配恢复](handoff-schema.md#source-matched-recovery)：
  来源批次须与当前任务一致，先前 revision 与 live SHA256 须与实时交接相符，候选方可待定写入。
  冲突、状态已前进或缺少归属项时在此停止，实时交接保持原状，完整返回仅作未落盘的响应交接。
  只有在该写者获准写交接时，才把完整返回保存到指定容器，重新读取实时字节，把完整 Action State
  发布为 `.ai/handoff.md`，回读后按已决定的批次、动作、下一角色、Review round 与目标 revision
  做预期状态核对。verdict 只计一次。只修正无歧义的格式；不得为适应格式改写技术结论。

## 成本与授权

聚焦检查应匹配受影响行为。在收益不足或成本明显的工作前，责任 Agent 应说明选项并等待负责人选择。负责人验收、Git 操作与部署不在入口 Skill 范围内。

## 采用与宿主

- [项目采用](project-adoption.zh-CN.md) — 安装、升级、接管、卸载。
- [宿主能力](host-capabilities.zh-CN.md) — SkillTarget 发现路径。

安装后请使用本目录相对路径（`docs/ai-collaboration/`）。
