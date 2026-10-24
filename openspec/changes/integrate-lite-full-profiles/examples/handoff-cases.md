# 短交接的固定场景与预期

这些是第一期的设计核对输入，不是实际业务执行、Lite validator 已运行或模型遵从证据。第二期须将逻辑路径映射到可丢弃夹具并执行。完整语义见 [protocol.md](../protocol.md)。

## 基础样例

- A：[T01-before-review.md](states/T01-before-review.md)，revision 4、累计 0，Executor 派发 Reviewer。
- B：[T01-after-review.md](states/T01-after-review.md)，revision 5、累计 1，Reviewer 派发 Executor 修复 F01。
- C：[T01-continue.md](states/T01-continue.md)，revision 3、累计 0，原 Executor 继续离线实现。

样例的结果、任务及审查路径是虚构项目根下的逻辑路径；它们须由后续夹具提供，不表示本仓库存在这些 live 记录。基础状态与变体均不是本仓库的 .ai/handoff.md。

## 路由场景

变体在所列基础样例上只执行本表明确的替换；移除块包含其全部内容，不保留失效命令。未列字段不变。表中结构预期为第二期的验收要求，第一期只人工对照字段及规则。

| ID | 完整输入或精确变体 | 唯一预期与核对责任 |
| --- | --- | --- |
| H01 | C 原文 | 合法可执行 continue；有权活跃 Executor 立即执行，缺进程本身不是 blocked；能力行省略 |
| H02 | A 原文；Reviewer 与 fictional-executor-A 无同批生产关系 | 合法 Agent 派发，首行 C3；实际独立性由负责人核对，不由结构成功证明 |
| H03 | B 原文 | 有且仅有一次 verdict；修复者不能自行 verified，之后仍需独立复核；不能把已完成审查说成已接受整项任务 |
| H04 | A：revision=5，status=awaiting-owner-decision，human=awaiting-decision，next role=Task Owner；删除能力行与 Operator Command，Current Status 改为“等待范围外付费接口决定”，加入下方 Owner Decision Brief | 合法人工 dispatch；不执行 Agent 命令，已有普通编辑授权不被撤销 |
| H05 | C：revision=4，status=blocked，human=awaiting-environment；删除 Continuation Command，加入下方人工环境 Blockers | 合法当前人工前置等待；收到准备证据前不能执行依赖动作 |
| H06 | C：revision=4，status=blocked，human=none；删除 Continuation Command，Blockers 写“Network unavailable after one bounded retry. Resume condition: package host is reachable.” | 合法纯环境等待；不要求人类回复，能做的无关任务按队列规则处理 |
| H07 | C 保留其远期预告；不增加等待状态 | 当前无需人类操作或回复；不得将后来环境检查误当当前前置 |
| H08 | A 删除 Current Status 的能力行，其他不变 | 结构仍可通过并给非阻断提醒；有权 writer 在原回读补齐，不新增审批或模型评分 |
| H09 | A 的 Routing 再加第二个 Next action: continue | 唯一性检查必须非零；代码围栏示例不作为重复真实字段 |
| H10 | A 当前文件不变，调用期望为 Task T01、dispatch、Executor、round 1、revision 5 | 文件结构可读但与已决定转移不符，预期检查必须非零；不能拿旧 exit0 证明 B 已保存 |
| H11 | A 将 Review round 改为 3，无有限扩展仍派发 Reviewer | 超过默认可派发容量；不得开始下一轮。校验报告矛盾，由有权负责者保存负责人决定出口 |
| H12 | B 将 Review round 改回 0，或以新阶段名称继续同一未解决 F01 | 来源／计数核对不得接受清零；不是依据本文件单独数字即可认证的事实 |
| H13 | B 改 close/completed/next none，删除能力与 Operator Command，Outcome=accepted，同时明确 F01 仍 open 且无限定接受 | 业务接受条件不满足；负责者不能普通 accepted。结构检查不能代替发现状态核对 |
| H14 | C 接替会话拟继续；当前无其他 writer，角色仍 Executor | 先保留任务、范围和累计 0，记实际接手 Agent、revision 3→4，再执行；无需询问在哪个本地宿主运行 |

### H04 所需决定块

```markdown
## Owner Decision Brief

- Decision needed: May T01 use the proposed paid external API beyond its current offline scope?
- Recommendation: Keep the offline scope and record the API as follow-up.
- Alternatives: Authorize the named API and its disclosed cost and scope before dependent work.
- Reply needed: Keep offline, or authorize the stated API scope and cost.
- After the reply: The current Executor updates the task and handoff; the owner does not maintain workflow files.
```

### H05 所需环境块

```markdown
## Blockers

- Current prerequisite: A human-controlled test application must be started before the next page check.
- Human preparation: Start the application's already approved local test session and report its reachable address.
- Resume condition: The responsible agent verifies the reported application address is reachable.
```

这是虚构输入中的当前人类动作；不得把这段准备复制进 H07 的远期预告。本样例不授权启动任何真实应用。

## 严格只读返回

恢复的完整来源及字节指纹见 [read-only-transfer.md](read-only-transfer.md)。关键预期：

- 当前 A 的源指纹及 revision=4 匹配，结果由 A 预先点名时，活跃可写负责者当轮保存完整 verdict 并发布 B，计数只从 0 到 1。
- 仍为 A，但结果不由任务或旧 live 点名：不自动恢复；不能由结果自身声称权威。
- 当前已是 B 且动作正文一致：已应用，不重计或重放。
- 同 revision=5 但 Operator Command 不同：冲突，不以路由字段相同当作已应用。
- 当前已到 revision=6：状态已前进，不用 B 覆盖。
- 候选自称 revision=999 但旧状态指纹不符，或来自 T99：不应用、不执行候选。最大编号不能证明权威。
- 当前已 close 或真正等待决定／环境：候选不能重开或越过等待。
- 无有权 writer：保留完整响应及未落盘说明；不假称 live 已更新，也不要求用户手工编写交接。
