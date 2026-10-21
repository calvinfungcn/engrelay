# EngRelay 开发与维护

[English](development.md)

GitHub 仓库是受维护的公开源码。初始公开基线为 v1.7.0，提交 `9c26c22266625aa04822637baf8f283763362677`，MIT 许可证。当前发行基线为 v1.9.6。本地维护设置不会创建活跃业务批次，也不授权发布。

## 从这里开始

请阅读 AGENTS.md、所用语言的 README、本指南、openspec/config.yaml、基线 spec，以及任何相关活跃变更。仅当当前任务明确使用角色工作流且文件确实存在时，才阅读 `.ai/current-task.md` 与 `.ai/handoff.md`。不要将已关闭的旧运行态复制到本克隆。

源码职责如下：

| 路径 | 职责 |
| --- | --- |
| payload/ | 规范产品规则、模板、Skill 与运行态工具 |
| agent-rules.md | 受管激活与角色入口规则 |
| scripts/ | 官方包管理、快照与聚焦夹具检查 |
| openspec/ | 仅源码的维护需求、设计、任务与归档 |
| docs/development.md | 维护者工作流；不是第二份任务清单 |
| .ai/ | 被忽略的本地笔记、夹具、日志与构建产物 |
| .agents/、.codex/ | 被忽略的本地宿主工具；非可部署产品 Skill |

生成的 OpenSpec Skill 是本地工具入口。保持其生成状态；产品 Skill 仅改 payload/。若工作站有被忽略的 `.codex/bin/apply_patch.ps1`，可用于补丁编辑。它是本地辅助，不是可移植的包依赖。不要复制工作站配置或凭据。

## 本地 Superpowers 副本

公开包不捆绑 Superpowers。若被忽略的宿主副本在 systematic-debugging 中仍显示过时的环境变量示例，请按原安装来源刷新，作为独立的本机维护任务；不要在本仓库编辑生成的副本。

## 需求与工作

基线 spec 汇总已发布契约；产品源码与新证据决定实际行为。它不是新的验收报告，也不是旧审查历史的第二份拷贝。新行为需要适当的 OpenSpec 变更。仅以该变更的 tasks.md 作为唯一实施清单。不要自动创建另一生命周期或重开已关闭的历史批次。

小范围稳定任务由当前负责 Agent 继续。保留角色能力限制、独立 M 代码审查、必需的独立 H 验证，以及累计裁决/有限负责人接续规则。仅显式选择的角色工作流才创建运行态 task/handoff 记录。

当前范围不包括 OmO 式运行调度器、依赖图引擎、自动唤醒或后台 Agent 管理器。此类新增应作为新需求评估成本与替代方案。现有角色/交接方法在实际可用时可使用宿主委派能力。

## 源码检出与完整包

开发检出包含仅源码的 OpenSpec 文件与被忽略的宿主工具。不要从中安装，也不要仅为吸收开发文件而再生其末次发布快照。tracked 的 snapshot.json 标识上一发布清单，直至下次经审查的发布从暂存刷新。

下载的完整发布是不可变安装输入。切勿将 EngRelay 安装进本源码仓库。生命周期测试使用带 GUID 名的可丢弃根，而非真实项目。真实部署需要各自的任务。

## 构建与发布流程

1. 完成连贯变更及相应审查；公开行为变更时同步两种语言 README。选定目标包版本，并在导出发布候选前用日期、变更与验证限制更新 CHANGELOG.md。
2. 用 git archive 将明确审查过的提交导出到新的可丢弃暂存目录。已提交的 .gitattributes 从安装导出中排除 openspec/ 与 docs/reviews/。被忽略的运行态/宿主目录不是 Git 输入。
3. 在暂存副本运行 scripts/update-snapshot.ps1，参数 `-Version <version>` 与 `-ForRelease`。记录实际导出字节并拒绝私有/工具目录及常见敏感文件名。它不是穷尽的秘密扫描。
4. 核对精确文件集与哈希，仅运行与变更行为相称的检查。在暂存包上运行生命周期夹具，日志放在包外。发布版本变化时须更新测试版本期望；当前 smoke 脚本含 v1.9.6 期望；其可选冻结 v1.6.1 夹具仍是独立历史检查。
5. 发布候选稳定后，将其 snapshot.json 拷回源码作为发布元数据，并确保新导出一致。保留不可变标签/归档与旧包。发布或推送须单独请求；开发设置不执行发布。

意图变更与属性提交后的导出示例：

```powershell
$engrelayBuild = Join-Path ([IO.Path]::GetTempPath()) ('engrelay-build-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $engrelayBuild | Out-Null
git archive --format=zip --output "$engrelayBuild/source.zip" HEAD
Expand-Archive -LiteralPath "$engrelayBuild/source.zip" -DestinationPath "$engrelayBuild/package"
& "$engrelayBuild/package/scripts/update-snapshot.ps1" -PackageRoot "$engrelayBuild/package" -Version '<next-version>' -ForRelease
```

将 `<next-version>` 替换为选定的 major.minor.patch。继续前检查命令失败。示例是导出工作流，不是自动安装、发布、回滚、清理或授权。

## 相称验证

文档/配置准备需要结构/引用检查与实际 diff 审查。OpenSpec 验证通过证明制品结构，不证明业务行为、宿主加载、授权或独立性。仅在匹配输入与范围内复用先前证据。对收益低或意外昂贵的选项应说明并推荐更小方案，再请负责人选择。不要因 Agent、角色、交接、文件名或簿记记录变化而重跑完整历史套件。

`scripts/test-skill-discovery-guidance.ps1` 默认从 git ref `9c26c22266625aa04822637baf8f283763362677` 构建无引导基线（`-BaselineGitRef` 可覆盖）。候选验证使用提供的完整包根。

## 本地设置与下次对话

在当前源码检出中继续维护。工作站设置笔记放在被忽略的 .ai/ 下；这些笔记不会成为活跃任务。

可复制起始提示词（提示词按引用保持英文原文）：

```text
Working directory: <your EngRelay source directory>.
First read AGENTS.md, README.md, docs/development.md, and openspec/config.yaml,
then check the active changes against the actual code.
Current requirement: <describe the requirement>.
Handle small tasks according to their actual impact; use the existing OpenSpec
capabilities when a formal change is needed.
During implementation, maintain only the relevant change's tasks.md. Do not copy
runtime state from earlier batches or reset the cumulative review count.
Check only the affected behavior. Before proposing an option with high cost and
limited benefit, explain its cost, a smaller alternative, and your recommendation.
This task does not automatically authorize publication, real deployment, global
configuration changes, or building a runtime orchestration engine.
```
