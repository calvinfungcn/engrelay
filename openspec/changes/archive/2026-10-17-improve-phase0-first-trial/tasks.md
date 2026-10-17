# Tasks

本清单是后续获准实施时的唯一实施进度来源。风险 M，原试跑中的 S 级任务保持按实际风险处理。落实选定的八项改进，按 proposal.md 重新连续编号；括号中的原编号只用于追溯试跑记录。第 1–3 组任务（1.1–3.2）均已勾选；2.3 标注宿主实机未测，2.4 标注集合/哈希实包演练未测。

## 1. 规范模板与 Agent 契约

- [x] 1.1 对应改进 1：修改 `payload/docs/ai-collaboration/templates/current-task.template.md` 与 `payload/docs/ai-collaboration/handoff-schema.md` 的 OpenSpec 任务映射说明，明确 `## 1.` 分组、`- [ ] 1.1` 点号编号及与唯一 tasks.md 的精确对应；验证：在经过路径确认的 GUID 一次性目录，用小型虚构任务运行 `pwsh -NoProfile -File <源码根>/payload/docs/ai-collaboration/scripts/validate-runtime-state.ps1 -WorkspaceRoot <一次性目录>`，确认扁平编号映射失败、改成真实点号编号后通过；只审阅示例与实际解析的一致性，不改校验器或其测试脚本，记录命令、诊断及退出码。
- [x] 1.2 对应改进 2：修改 `payload/docs/ai-collaboration/handoff-schema.md`、`payload/docs/ai-collaboration/templates/handoff.template.md`、`payload/docs/ai-collaboration/templates/response-handoff.template.md`、`payload/docs/ai-collaboration/templates/implementation-result.template.md`，明确证据字段只引用文件路径或适用的 none，任务编号在路径引用外说明；命令、观察输出、退出码放入 result 的 Checks Run；验证：用 1.1 的一次性目录，复现把带路径的命令放入 Authoritative Evidence 时非零、改成真实 result 路径后 exit 0；人工核对响应交接与落盘交接语义一致，没有新增机器字段或重复结果正文。

## 2. 双语人类文档（可单独交付）

- [x] 2.1 对应改进 3、4（原 4、5）：新增 `docs/quickstart.md`、`docs/quickstart.zh-CN.md`，写出准备任务输入、开发源码/完整包/一次性试用项目的目录边界；setup 明确 PowerShell 7、检查 pwsh 可用及主版本，并在 A 前给出 `git init`、检查忽略范围、显式暂存输入、首次本地提交与状态/历史核对步骤；验证：在新建虚构目录逐条演练，确认 `git log -1` 有初始提交、`git status --short` 可解释且 `.ai/`、安装备份与宿主缓存不在提交内；模拟缺少 pwsh 时指南能指出前提未满足，两版语义一致；命令只作为后续试用者说明，本轮不执行 Git 写操作。
- [x] 2.2 对应改进 5、6（原 6、7）：补充 `docs/quickstart.md`、`docs/quickstart.zh-CN.md` 的 A/B 交接步骤：A 只准备真实交接，B 前备份 `.ai/handoff.md` 为 `.ai/handoff.A.md`；已有副本不静默覆盖；B 从当前真实 handoff 复制完整 Operator Command，不能粘贴模板占位说明；验证：在一次性目录核对备份内容与 A 原件一致、B 更新实时文件后备份仍保持、接续读取目标仍为实时 handoff；用有效命令和占位说明两个虚构输入审阅，缺少有效命令/角色不符时给出恢复方向，不跳过现有防护。
- [x] 2.3 对应改进 7（原 8）：补充 `docs/quickstart.md`、`docs/quickstart.zh-CN.md` 的 Windows 最小排错段，仅说明文件被占用时关闭相关编辑器或让 pwsh 离开目标目录后重试，以及 Codex 沙箱拦截写入时核对工作目录与可写范围、按宿主支持流程处理所需写权限后重试；仍失败时保留错误并说明尚未解决；验证：仅按这两种故障分别桌面走查双语指引，确认不扩展其他故障或深度诊断，没有批量终止进程、全局策略更改、强删或绕过沙箱的步骤；宿主实测不可得时明确标未测，不编造界面按钮或成功结果。宿主实机未测
- [x] 2.4 对应改进 8（原 9）：补充 `docs/quickstart.md`、`docs/quickstart.zh-CN.md` 的离线取包步骤：可访问 GitHub 的协作者取得对应可信发行完整 ZIP，原样转交并提供来源/版本/可用校验信息，接收者核对解压后 snapshot 集合与哈希；验证：用本地完整包副本按文档检查，桌面走查“接收者不可联网”仍能完成来源/版本核对、集合/哈希检查与失败恢复；区分源码 ZIP 和完整包，不提供虚构镜像、不修改清单；若没有匹配完整包，明确该演练未测，不从本开发目录直接安装。集合/哈希实包演练未测
- [x] 2.5 对应改进 3～8（原 4～9）的入口与一致性：仅在 `README.md`、`README.zh-CN.md` 添加对应 Quickstart 入口，并完善 `docs/quickstart.md`、`docs/quickstart.zh-CN.md` 的语言互链和现有 operator guide/安装说明引用；验证：检查四份文件的目标路径、链接和双语逐项对应，确认没有不存在的 handoff-demo/fixture 链接、未实测时长或宿主已加载承诺；复用已有 optional/none 语义，不扩张安装映射，不改 README 的现有 5.1/7 支持边界。

## 3. 跨文件核对与独立审阅

- [x] 3.1 核对 1、2 两组的整体一致性，记录聚焦证据于实施会话已授权的本地结果文件（如 `.ai/phase0-first-trial-result.md`；不入 Git）；仅按实际结论维护本文件 `openspec/changes/improve-phase0-first-trial/tasks.md`；验证：逐条对照本变更 `specs/collaboration-package/spec.md` 场景，确认八项都有文件和对应检查证据；运行 `openspec validate improve-phase0-first-trial`，检查实际 diff 没有校验器、安装器、生成宿主 Skill、版本、snapshot、外部原件或范围外功能改动；检查一次性证据未进入包输入，不重复已有且输入匹配的检查。
- [x] 3.2 在后续 M 级实施结束时，由未参与实现的审阅者检查最终差异及 3.1 的证据；仅创建其已获授权的 `docs/reviews/improve-phase0-first-trial/<实际日期>-round-<实际轮次>.md`、维护同目录 `index.md`，并根据真实审阅结果维护本文件任务状态；验证：审阅者身份与实现者分离，结论覆盖点号映射、证据路径和双语 Quickstart 八项改进的完整性，缺失证据写未测或未满足，不能把 OpenSpec validate 通过当作业务或宿主验收；不因本任务重置累计 verdict 或启动未经授权的额外循环。证据路径：`docs/reviews/improve-phase0-first-trial/review.md`。
