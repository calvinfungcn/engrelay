# Design

## Context

参见 proposal.md。现行五个环境字段在 needed=no 时仍要求 actionable Human action，示例还要求 Reply；continue 入口限定 same agent，且 blocked 分支在通用 continue 后。校验器已支持 Markdown 围栏识别、分段读取与子进程 fixture，可复用而无需调度器。

## Goals / Non-Goals

**Goals:** 让人类直接辨认介入状态，活跃 Agent 可以在既有授权内跨会话接续，校验结构并保持旧格式兼容。

**Non-Goals:** 不读取真实业务项目；不启动后台进程、不自动恢复退出的 CLI、不自动选模型；不改变安装器、角色独立性、累计 verdict 或关闭依据规则。

## Decisions

1. 保留现有五个环境字段。needed=no 时 Human action 可为 none 或中性后续依赖说明，Confirmation and check 描述 Agent 将来何时检查，不请求人类当前回复。needed=yes 保留即时可操作说明及 ready 证据要求。相较新增两套 schema，此法较小且兼容；不使用自然语言黑名单做校验门禁，避免误判否定句和多语言。
2. Routing 新增摘要 Human Action Required。新生成时必写，读取/校验旧记录时缺失允许且不告警；有字段则检查唯一、枚举及一致性。awaiting-decision 只匹配 awaiting-owner-decision；awaiting-environment 只匹配 continue/blocked 且存在 pending/unknown+yes 环境项；普通操作阻塞仍可 none。新字段不覆盖权威状态。
3. 可执行的新 continue 在 Current Status 内用 ### Continuation Command 和一个 text 围栏，复用 Read/Objective/Constraints/Output/Follow 字段，标明当前角色和批次。Next role 等仍为 none，Operator Command 仍仅用于 Agent dispatch。字段存在且 continue 非等待时须有接续块；旧记录不要求补写。等待/close/dispatch 禁止该块。校验器检测实际 Markdown 结构，围栏示例不得混入。
4. 同一职责的会话接替必须读取磁盘上的最新授权与证据，在不改变职责/风险/范围且无并行写入冲突时接管，并如实记录 Current agent；正式职责交接和独立审查仍用 dispatch。保留批次和 verdict。发现活跃同批次写入者先只读核对，不能创建竞争执行，也不把普通宿主选择交给 Owner。
5. 入口先分辨 close、实际等待、额度及权限，再处理可执行 continue。缺少新命令时从旧 Current Status 和权威任务恢复，不把兼容缺项升级成人类决定。disabled/其他控制器仍不能被发现文件隐式激活。

## Risks / Trade-offs

- 新字段与旧状态冲突 → 结构拒绝，不以摘要覆盖原规则。
- 自主接续变成无限运行或并发写入 → 只要求已活跃 Agent 执行，检查最新状态/写入归属，不承诺唤醒，不绕过权限或角色边界。
- 预告消失导致漏验收 → 保留后续检查触发点并在依赖变为下一步时重新核对，不能用 needed=no 跳过必需检查。
- 结构检查不能判断人类语义或宿主实际执行 → 文档审查使用虚构跨会话场景；报告不夸大为宿主端到端验收。

## Migration Plan

规范产品只改 payload。双语 README/操作者说明同步；CHANGELOG 记 Unreleased，不修改已发行版本。先补失败的子进程用例，再实现并在 Windows PowerShell 5.1/PowerShell 7 的临时目录运行本校验器完整回归；不重跑无关安装生命周期。保留最后发行 snapshot，待明确发布任务再从审查提交干净导出生成。回退可撤回本次开发差异，无历史运行态迁移。
