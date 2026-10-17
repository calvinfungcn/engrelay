# Design

## Context

动机见 proposal.md 的 Why。当前为 v1.8.0，活动变更创建前为空；规范产品文件位于 `payload/docs/ai-collaboration/`，安装后才映射为目标项目的 `docs/ai-collaboration/`。`handoff-schema.md`、current-task/handoff/result/响应交接模板已存在；根 `docs/` 只有开发说明与审查导航，没有 Quickstart；没有 handoff-demo 样例及自定义 OpenSpec schema。

已读取现有 OpenSpec `spec-driven` schema 的产物指令和 `collaboration-package` 全部要求，复用现有能力路径，不修改 OpenSpec 的生成模板或本机 Skill。知识图已索引，但覆盖信号提示源元数据变化、PowerShell 局部解析不完整，因此对相关模板、契约和校验逻辑直接只读核实。

既有校验器读取任务映射和真实证据路径；已确认 `validate-runtime-state.ps1` 中任务匹配与 Authoritative Evidence 路径检查。此处“Schema”是产品 `handoff-schema.md`，不是要求修改 OpenSpec 安装目录里的 schema。校验器视为正确基线。

## Goals / Non-Goals

**Goals:** 将选定的八项改进逐一放入现有权威文件或最小人类操作指南；保留一份实施清单；让实现者与双语文案工具有明确文件边界和检查依据。

**Non-Goals:** 不引入新的机器字段、关闭 outcome、强制审查环节、产品演示代码或远程下载设施。其余边界见 proposal.md 的 Non-goals。

## Decisions

### 文件责任与任务映射

下表路径均相对仓库根。canonical 目录以下简写为 `payload/docs/ai-collaboration/`；tasks.md 使用完整路径，避免实施歧义。

| 改进编号（原试跑项） | 拟修改或新增的文件 | 落点与验证 | 任务 |
| --- | --- | --- | --- |
| 1（原 1）点号编号 | canonical `handoff-schema.md`、`templates/current-task.template.md` | 在任务映射规则旁放合法分组/复选项示例；与真实 tasks 中编号比对，用既有校验器验证正反输入 | 1.1 |
| 2（原 2）文件证据 | canonical `handoff-schema.md`、`templates/handoff.template.md`、`templates/response-handoff.template.md`、`templates/implementation-result.template.md` | 文件字段只填路径或适用的 none；任务编号在路径代码片段外说明；命令/输出/退出码归 Checks Run；复现误填命令导致失败和修正后通过 | 1.2 |
| 3（原 4）Git 基线 | `docs/quickstart.md`、`docs/quickstart.zh-CN.md` | 新目录 setup：git init、忽略范围、显式暂存、首次提交及状态/历史检查 | 2.1 |
| 4（原 5）pwsh | 同上 | 前提中明确 PowerShell 7，用可用性与主版本检查区分 powershell.exe | 2.1 |
| 5（原 6）A 备份 | 同上 | A 完成真实交接后、B 前复制为 handoff.A.md，存在时停止覆盖，核对内容 | 2.2 |
| 6（原 7）B 真命令 | 同上 | 从最新活动 handoff 复制完整 Operator Command；占位文本不是可执行输入 | 2.2 |
| 7（原 8）Windows 最小排错 | 同上 | 只说明文件占用时关闭相关编辑器或让 pwsh 离开目标目录后重试；沙箱拒写时核对工作目录/可写范围并按宿主支持流程处理所需权限，不做深度诊断 | 2.3 |
| 8（原 9）离线包 | 同上 | 可信完整发行 ZIP 原样转交，核对来源/版本/集合/哈希；不虚构镜像服务 | 2.4 |

### 最小 Quickstart 与现有安装映射分开

新建根 `docs/quickstart.md` / `docs/quickstart.zh-CN.md`，两种语言互链。根 README 两版只增加对应指南入口（2.5），不重写首页。Quickstart 是这六项操作修正的最小载体，复用现有安装命令和 operator guide 的角色说明，明确实际任务输入须已准备、A 只准备交接、B 才实施；没有公开样例时不得提供不存在的 fixture 链接或声称完整 demo 已交付。指南能用于一个已准备任务的全新可丢弃项目，不承担制作该任务代码与需求的职责。

替代方案是在已安装 operator guide 中大幅添加演示流程，但会扩大 payload 人类文档的职责；本次不扩张安装映射、不改 `supported-layouts.json` 或管理器。根 docs 的指南随现有导出规则保留在包根供阅读，安装目标不因它新增文件。不得引用未来未发布包中才会有的指南或样例作为当前已可取得的内容。

### 复用既有证据机制

只改提示、注释及必要例子，不改机器字段名称。`Implementation or fix result` 指向真实 result 文件；`OpenSpec checklist` 引用 tasks 文件，编号写在文件路径代码片段外。result 的 `Checks Run` 提示记录实际命令、观察输出、退出码和日志路径，不规定新的强制字段。复用既有日志与结果路径，不要求纯文案为满足示例而生成一套业务运行态。

替代方案是允许证据列表混填命令，但这与当前解析行为冲突，也违背本次不改校验器的约束。并非禁止 result 或正式审查文件自身包含命令。

### 聚焦验证，记录真实限制

实现后在校验过路径的 GUID 一次性目录构造小型虚构任务/证据输入，用当前产品校验器复现扁平编号、命令误填和修正后的结果；只读检查器无需逻辑改动。文案检查使用内容审阅与可复制步骤演练，不新增措辞匹配测试。双语对照核查改进 3～8（原 4～9），不要求三人招募或完整增长实验。

后续 M 级实施须由未参与实现的审阅者检查最终差异和实际证据；本轮提案不启动该角色生命周期，也不运行产品安装或试用。

## Risks / Trade-offs

- [没有随附样例] → Quickstart 明确“已有已准备任务输入”的前提；新增完整示例留后续，不能用不存在的演示承诺弥补。
- [PowerShell 7 被误读为包整体放弃 5.1] → 指南仅限定本次试用步骤，保留 README 既有支持边界。
- [新增指南与上次发行清单不匹配] → 开发 checkout 不作安装源；本变更不更新版本与 snapshot，发行时再经另行授权的干净 staging 纳入字节。
- [备份被当作活动状态] → 指明 handoff.A.md 只留本地，B 始终核对最新 handoff.md；不加入接续 Skill 的默认读取链。
- [离线分发缺少可信来源] → 无法确认来源或清单不匹配就报告未就绪，不提供未存在的镜像或完整性绕过。

## Migration Plan

本轮只写规划，所有任务保持未勾选。获准实施后先改 canonical 契约和模板，再完成独立成组的双语指南，最后做聚焦检查和独立差异审阅。没有字段迁移或真实部署。本次不触碰历史审查、运行态、已发布包或 snapshot；如后续放弃，回退本变更新增指南与契约文案即可，保留真实检查记录。
