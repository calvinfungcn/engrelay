# Round 03 - 独立修复复审

## Metadata

- Change: `streamline-entry-and-human-docs`
- Recorded on: `2026-10-16`
- Execution Batch ID: `engrelay-entry-upstream-human-docs-20261016-01`
- Review round: `3`（累计第 3 次 verdict，默认自主额度用尽）
- Round type: `re-review`
- Review role / agent: `Code Reviewer / Codex`
- Repository: `calvinfungcn/engrelay`
- Base: `6960d1975f07063c4250f241cd59dd3beaeaff27`
- Inputs: 当前 task/handoff、round-03-result、既有正式审查、当前完整差异与 SEH-002 局部修复。本审查者未参与修复，只写获授权审查与交接产物。

## Scope

复验显式完整 PreviousPackageRoot、输入不变性和根/日志隔离。其余四项与 round-02 的输入逐文件核对后复用证据；没有重放全部历史矩阵或更改产品代码。

## Findings

| Topic | Priority | Status | 本轮结论 |
| --- | --- | --- | --- |
| SEH-001 | must-fix | verified | registry、manager 和部署输入未变，复用 round-02 指纹与原包升级证据。 |
| SEH-002 | must-fix | open | 合法显式输入已成功；新增根重叠检查遗漏 candidate 位于 previous 内的方向，实际非法组合仍返回成功。 |
| SEH-003 | must-fix | verified | 旧包不刷新规则保持；当前默认标签分支补跑 5/5 通过。 |
| SEH-004 | must-fix | verified | 复用 round-02 干净矩阵及模式/备份/拒绝摘要；本轮显式双宿主再运行 10 case。根隔离剩余问题继续归 SEH-002。 |
| SEH-005 | should-fix | verified | 两份指南与 round-02 字节相同，原激活语义核对继续适用。 |

### SEH-002 — 根重叠条件只执行一个方向

位置：`scripts/test-human-doc-lifecycle.ps1:90`，`Assert-PackageRootsDisjoint`。

```powershell
if (Test-PathUnderRoot $Left $Right -or Test-PathUnderRoot $Right $Left) { throw $Message }
```

PowerShell 将整段解析为一次命令调用，`-or Test-PathUnderRoot ...` 成为第一个函数的额外参数；没有构成两个布尔表达式。因此只执行 Left 位于 Right 内这一方向。调用方传入 Left=previous、Right=candidate：同根、previous 在 candidate 内会拒绝；candidate 在 previous 内则放行。

本轮不仅检查文本：从实际脚本 AST 提取原函数后，四组合结果分别为“不拒绝无重叠、拒绝相等、拒绝 previous 在 candidate 内、不拒绝 candidate 在 previous 内”。随后在一次性副本上调用完整原脚本：previous 为复现根的 nested-old，candidate 为 nested-old/.ai/candidate；脚本执行全部 5 个 case、12 个 manager 调用，outerExit=0。预期应在用例/manager 调用之前拒绝重叠。

嵌套副本专用于拒绝边界复现，不作为可信旧包升级验收输入。选择 `.ai/candidate` 是为了避免 manager 的既有额外文件拒绝掩盖前置隔离漏检：manager 本就忽略 `.ai` 子树；两个包的声明字节仍来自已核验输入，未刷新 snapshot。没有改写原包，也没有观察到数据损坏。实际缺陷是已分配输入隔离边界被绕过、无效组合可报告测试成功，不是要求增强任意 mock 或证明假想 mutation。

影响与最小修复：SEH-002 已解决“所有合法显式旧包都拒绝”，但此次承诺的双向根隔离尚不成立。给两次函数调用分别加括号，使 `-or` 在表达式模式中求值；复验相等、两个包含方向、真正分离及包内日志拒绝，再用完整显式输入双宿主聚焦验证。保持管理器、snapshot、归属算法及其他已验证范围不动。

## Evidence

### 输入和环境

36 个当前源差异文件（排除本变更正式审查产物），沿用 round-02 的 path|lowercase-SHA256、Sort-Object 排序、LF 连接且无尾换行：
`e8e04ff6a655d458d4782567e3b395e427710948d5ed2092335e2f96a43fb698`。
将唯一脚本的哈希替换回 round-02 值，摘要精确恢复为 `9c4cf548c3055f6faee71c0949b21bcba405b8ea94d35bfaa241012f2446f30d`，证明其余 35 个源输入未变。

| 输入 | SHA256 |
| --- | --- |
| 当前生命周期脚本 | a333172096631a9a56f1a04fbc3b31cb6691829d84cca619979d5be14e18b08a |
| 修复者提供的完整候选 snapshot，63 项，夹具版本 1.8.0 | 01b4b828449dfee5a35fa0d9f193ac5363898057c7cf3246bb8431529082cc35 |
| 原始 v1.7.1 snapshot，54 项 | 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743 |

本轮独立核对候选和原包完整集合、长度、每项 SHA256；候选每项同时与当前源码对应字节核对，差异 0。包中无 Git 元数据，未修改或重建其 snapshot。输入来自修复者已记录的 `%TEMP%/engrelay-seh03-6c88e3831ee849f086c2f7a15862e243/HEAD` 和 `v1_7_1`；原有输入目录由其生产者管理，本轮不删除。

环境：Windows，PowerShell 7.6.6、Windows PowerShell 5.1.26100.9711，Git 2.50.1.windows.1。使用工具绝对路径，只在默认 archive 测试进程补 Git PATH。

### 实际执行与结果

本轮独立日志/逆向边界副本置于新的 `%TEMP%/engrelay-review03-a253ace60d0a4868a78bcbc74b9dac0a`。下列摘要为公开持久记录，原始运行态/日志不进入 Git。

```powershell
# 工作目录：本仓库；$candidate/$previous 为上述经核验完整输入。
& <PS7-or-PS5.1-exe> -NoProfile -ExecutionPolicy Bypass -File scripts/test-human-doc-lifecycle.ps1 -PackageRoot $candidate -PreviousPackageRoot $previous -LogPath <outside-package-log>
# 默认分支的代表性回归检查。
& <PS7-exe> -NoProfile -File scripts/test-human-doc-lifecycle.ps1 -PackageRoot $candidate -SourceRepoRoot <source-repository> -LogPath <outside-package-log>
# 反向包含拒绝复现：对一次性复制的包调用实际脚本，未刷新任一 snapshot。
& <PS7-exe> -NoProfile -File scripts/test-human-doc-lifecycle.ps1 -PackageRoot <review-root>/nested-old/.ai/candidate -PreviousPackageRoot <review-root>/nested-old -LogPath <review-root>/ancestor-previous.json
```

| 日志 / 场景 | 观测 | 日志 SHA256 |
| --- | --- | --- |
| explicit-ps7.json | exit 0，5/5；无 SourceRepoRoot 参数 | 99ebf764244c930dc64448328b1db07f4d9262e39d66874b8a76e2382c863e5f |
| explicit-ps51.json | exit 0，5/5；无 SourceRepoRoot 参数 | 0dbd69b03a3d900feb983e613ff4efa32fd20c020d3006c5b2d131f1f3d29b48 |
| default-ps7.json | exit 0，5/5，默认 v1.7.1/none | 185a69a41f6cfb652653b62fd8a336ea65c59650431216d0d6ca5713ebaf808a |
| ancestor-previous.json | **错误放行**：exit 0，5/5、12 calls | 352c84aa0d4932ea662ea623ec255038bfd994f0bc78a9e3de77262ea2af5a1b |
| equal.json | 正确拒绝：exit 1，0 case/0 call | 765c90b523af79b9f8049fc80149599ab5ecee2fb13cf8295fdc95a74c2cfa04 |
| descendant-previous.json | 正确拒绝：exit 1，0 case/0 call | 05ea98f02aacb05384a167e31c6c7b67f567ae47a302301c6977b082b56d3b4e |

三组合法输入的 12 次 manager 退出均为 `0,0,0,0,0,0,0,0,0,1,0,1`；两个 1 对应已预期冲突/漂移拒绝。不能把合法输入的 15/15 通过当作完整根隔离验收通过。候选内 LogPath、旧包内 LogPath 均在参数检查退出 1，对应日志文件未创建。

## Conclusion

- Current status: `open`
- Batch closure decision: `task-owner-decision`
- Next action decision: `continue`
- 累计 Review round 为 3，默认额度耗尽。SEH-002 仍 open，其他四项保持 verified；本轮不派发 Fix Engineer，不开始第四次自主修复/审查。
- 未收敛原因：上一修复分离了输入与可写路径，但新复合条件使用了 PowerShell 命令参数语法；仅相等根的负向证据未覆盖反向包含。最小剩余修复为一处布尔条件和针对性检查，无需重新设计或重放全部历史矩阵。
- live Agent 行为、宿主加载、实际部署及发行继续未验证；C1–C5 保持独立待办。根源 snapshot、Git 索引、产品实现和历史正式审查未修改。

## OpenSpec Impact

4.2 保持未完成，批次不关闭。3.4 的根隔离边界及 4.1 中“重叠根拒绝有效”的汇总还需协调；本轮不改其他实施复选框，不以预算上限或正向通过掩盖剩余问题。

## Next Actions

当前 Code Reviewer 保持责任，用 `continue / awaiting-owner-decision` 等待负责人对有限追加额度的明确回复。完整 Owner Decision Brief 在 `.ai/handoff.md`，没有新的 Operator Command。

建议只为 SEH-002 再授权一次最小修复及一次独立复审，累计审查上限到 4；预计小范围条件修改与数分钟聚焦检查。替代为暂不追加，保留当前成果和已知缺陷，批次继续未验收。未经授权不进入这次额外循环。

## Validation

本轮 OpenSpec strict 与 HEAD 到工作树空白检查退出 0；新增 round-03 的 no-index 空白检查无诊断。真实 .ai 的 validate-runtime-state.ps1 因源码布局缺少 docs/ai-collaboration/agent-prompts.md 退出 1，未把它称为通过。

最终交接在本轮 GUID 根的 runtime-a36c596de3e642b79113262fcb20a94b 结构夹具运行同一规范校验器，退出 0，输出 Runtime collaboration structure is valid。task/handoff/各 result 均核对与真实输入同字节；实际源码路径保留，仅在夹具提供安装态规范角色卡和模板，没有修改校验器。结构检查不等于行为验收、宿主加载或授权真实性。

结束前对借用的完整候选/旧包重新核对全部集合、长度和 SHA256，均未变化；默认分支自建旧包根已清理。仅本轮新建复现根在核实绝对临时父目录、GUID 名称和全树无 reparse 后删除，修复者原有输入/日志保留。Git 索引 SHA256 仍为本轮开始时的 88fb3162f315f4eaef9573448c02f19ce3fbc588f03f4183ebc5132e8d6eea66，源 snapshot SHA256 仍为 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743。本轮只新增 round-03、更新 index 与 handoff；tasks 4.2 保持未勾选。
