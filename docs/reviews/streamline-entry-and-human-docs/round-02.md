# Round 02 - 独立修复复审

## Metadata

- Change: `streamline-entry-and-human-docs`
- Recorded on: `2026-10-16`
- Execution Batch ID: `engrelay-entry-upstream-human-docs-20261016-01`
- Review round: `2`；累计第 2 次 verdict，不重置首次记录。
- Round type: `re-review`
- Review role / agent: `Code Reviewer / Codex`
- Repository: `calvinfungcn/engrelay`，基线 `6960d1975f07063c4250f241cd59dd3beaeaff27`。
- Inputs: 当前 task/handoff、两份 result、OpenSpec 产物、round-01/index、HEAD 到工作树差异；修复会话未由本审查者执行。本会话只写审查和交接产物。

## Scope

聚合复验 SEH-001–005，并检查修复证据与当前字节一致性。入口、方法及其余译文沿用 round-01 已记录的契约审读范围；本次修复差异仅两份 operator-guide、registry 和生命周期脚本。没有修改产品实现、Git 索引、发布清单或任务复选框。

## Findings

| Topic | Priority | Status | 本轮结论 |
| --- | --- | --- | --- |
| SEH-001 | must-fix | verified | 两版公开指纹重算匹配；原包升级在干净候选矩阵中成功。 |
| SEH-002 | must-fix | open | 完整候选现在直接使用，但所有显式 PreviousPackageRoot 仍在运行用例前被拒绝。 |
| SEH-003 | must-fix | verified | 默认 archive 在包外，不刷新旧 snapshot；原始集合/长度/哈希匹配，临时旧包在 finally 清理。 |
| SEH-004 | must-fix | verified | 当前脚本五场景 × 五组合通过；本轮用符合导出规则的候选独立重跑，并补齐原备份/模式/目标及拒绝树摘要证据。显式旧包缺陷单独保留在 SEH-002，故 3.4/4.2 整体验收仍未完成。 |
| SEH-005 | should-fix | verified | 配对指南已说明 optional/default/disabled，与规范默认选择语义相符。 |

### SEH-002 — 显式旧包被自己的排除条件拒绝

位置：`scripts/test-human-doc-lifecycle.ps1:113`，关联第 83–92 行。

`Get-PreviousPackageRoot` 对非空显式旧包调用 `Assert-OutsidePackageRoots $explicitPrevious`。该函数第二段明确在路径等于 `$explicitPrevious` 时抛错，因此每个合法显式旧包都会失败，后面的 snapshot 验证不可达。相同错误在 PowerShell 7.6.6 与 Windows PowerShell 5.1.26100.9711 均复现：outerExit=1，cases=0，calls=0，错误 `Path must not be inside explicit previous package root`。

两个输入都是无 Git 元数据的完整包；候选 63 项、v1.7.1 旧包 54 项均已独立核对完整集合、长度和 SHA256，路径互不包含。不是旧包缺失或漂移。现有五组成功日志均走 SourceRepoRoot/PreviousGitRef 默认分支，没有覆盖这个参数契约。结果文件称“直接使用 caller-supplied previous”尚不成立。

影响：设计约定的完整 PackageRoot/PreviousPackageRoot 调用无法使用，完整下载包也不能按此接口独立验证。保留同一发现 ID，不因部分修复建立新主题。

最小修复：把输入根的互斥检查与输出/临时资源的包根排除检查分开，允许合法旧包作为只读输入；继续拒绝同根、实际不允许的重叠根及包内日志/临时输出。不得用删除旧 snapshot、自动重建旧包或放宽归属保护绕开。用两份完整包、显式 PreviousPackageRoot、不传 SourceRepoRoot 的调用在双宿主复验；检查输入前后不变。其余已验证范围优先复用相同输入证据，不重复无关历史套件。

## Evidence

### 输入绑定与候选准备

36 个当前差异文件（排除本变更正式审查产物），采用 round-01 相同的 `relative-path|lowercase-raw-SHA256`、Sort-Object 排序、LF 连接且无尾换行，摘要为：
`9c4cf548c3055f6faee71c0949b21bcba405b8ea94d35bfaa241012f2446f30d`。

| 输入 | SHA256 |
| --- | --- |
| 当前 test-human-doc-lifecycle.ps1 | 7a7176a8364a35b6157cd6e1c8732ab6e7ecd97c7430f755932c3d118fba2ab7 |
| 当前 supported-layouts.json | 09a41311a4fdcfb520c162d07302a8922c85059f3c794dad8d79b2e4f7b97d90 |
| 本轮干净候选 snapshot，63 项 | 5442c80354e569fe4dcbb428eff757e6b28fe7e2f996cc9245e3a6000f84ac98 |
| 原始 v1.7.1 snapshot，54 项 | 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743 |
| 原始 v1.7.0 snapshot，52 项 | f5c4085549cb2b983e98076021c6799419acf31ddf53d7ede472d721d2ff9612 |

环境：Windows；Git 2.50.1.windows.1；PowerShell 7.6.6 / Windows PowerShell 5.1.26100.9711。使用工具绝对路径，仅测试进程补 Git PATH。

修复者所记录候选的 snapshot/脚本/registry 哈希与其日志、当前源码匹配；逐项核验 67 项字节均匹配。不过该候选包含四份应由导出规则排除的源码导航文件：openspec/README 两语及 docs/reviews/README 两语。本轮没有把该候选作为唯一验收输入，而是在新 GUID 根按 design 重新 `git archive HEAD`、仅覆盖 27 个授权可导出差异，排除 openspec/、docs/reviews/ 和本地状态，再运行候选 `update-snapshot.ps1 -Version 1.8.0 -ForRelease`，退出 0。原始标签分别独立导出，zip 在包外；三包完整集合、长度、SHA 全部匹配。1.8.0 仅为夹具版本。

本轮忽略的本机复现根为 `%TEMP%/engrelay-review02-551682a560164529a13ea7a2e93cc355`，候选子目录 HEAD、原包子目录 v1_7_1/v1_7_0。原始日志不进入 Git；下表保留摘要和可复现命令，目录可清理后等价重建。

### 实际执行

生命周期命令（工作目录为仓库根）：

```powershell
# $r 为以上新建且已验证的独立 GUID 复现根。
& <host-exe> -NoProfile -ExecutionPolicy Bypass -File scripts/test-human-doc-lifecycle.ps1 -PackageRoot "$r/HEAD" -SourceRepoRoot <source-repository> -PreviousGitRef <tag> -UpgradeTarget <target> -LogPath "$r/<log-name>"
# 缺陷复现：同一完整候选，显式只读旧包，省略 SourceRepoRoot。
& <host-exe> -NoProfile -ExecutionPolicy Bypass -File scripts/test-human-doc-lifecycle.ps1 -PackageRoot "$r/HEAD" -PreviousPackageRoot "$r/v1_7_1" -LogPath "$r/explicit.json"
```

| 宿主 / 旧版 / target | 日志 | 结果 / SHA256 |
| --- | --- | --- |
| PS7 / 1.7.1 / none | default-none.json | exit 0，5/5；00ec0f0e377eea2fd80b286c98b3d111741307e465297e95f1e221c49d20ef8d |
| PS7 / 1.7.1 / agents | ps7-agents.json | exit 0，5/5；ea3a3bfff3d821c694a0c1c4fa3ba740896ecc08806fcf6a6abe54bdff71b038 |
| PS5.1 / 1.7.1 / none | ps51-none.json | exit 0，5/5；41c9a28ee3372be35a22025e18cca06dadf502cc57395c91a353a614d2ab1d69 |
| PS5.1 / 1.7.1 / agents | ps51-agents.json | exit 0，5/5；ff1f630ffc3553dfb4aa4613199ce9b33c35de6794c33fef59d85acd03d8dad9 |
| PS7 / 1.7.0 / codex | ps7-codex170.json | exit 0，5/5；33f7bd37582331221e27e4f24aa71437692bd37df031f7d71dfd2f935ca3bb83 |
| PS7 / 显式 1.7.1 | explicit.json | exit 1，0 case/0 call；84ac871a9530506da1de704b3de836fa2f2ba67930e33be47f52116e8eb9da74 |
| PS5.1 / 显式 1.7.1 | explicit-ps51.json | exit 1，0 case/0 call；f856e65ad6be797bcd9c32d510dabf979d09156afece0c3443f96bac4417bf94 |

每组成功日志的 12 个 manager 调用退出依次为 `0,0,0,0,0,0,0,0,0,1,0,1`；两个 1 分别对应实际冲突/受管漂移拒绝，其余 Install/Upgrade/Uninstall 均 0。25 个 case 无失败，全部绑定本轮 63 项候选和当前脚本哈希。默认导出的旧包根在返回后已不存在，原始输入 snapshot 未改写。

补充归属验证直接使用同一候选/原包的 manager，在复现根独立子目录执行：

- v1.7.1 Install 以 `WorkflowMode default / SkillTarget agents`，候选 Upgrade 即使参数为 optional 也保持 manifest 的 default/agents；逐条比较原 47 个记录的 backup/beforeHash，差异 0。Uninstall 退出 0，AGENTS.md 管理块外原始字节恢复。
- 另两目标以 disabled/none 原包安装，分别制造新人类文档冲突及旧受管文档漂移。候选 Upgrade 均退出 1。递归包含隐藏恢复元数据的 `relative-path|SHA256` 排序摘要前后相等：冲突为 `6c37a0f14bf7530e8f770516c7cc37311b93ba79accb7ef1fbdff43e50acbc54`；漂移为 `4b9c7e40a26afa9cb5650a95a861f2da54e96092071c2e3117905a5a2b9ecd03`。
- 两版指纹按未更改 manage.ps1 算法从原 snapshot 独立重算，分别为 `794ee5dcbf019c5e981b1a5ee1472edfad1e392e39bc560630985c35e73279c6` 和 `04c21e9565c1f455bf4555248f3708aa7737ca6aeb69fe1b83771d3c7354c681`，登记完全匹配。七条布局的 additions 与实际 payload 减旧 paths 集合差均 0；HEAD 中五条旧 paths/指纹保持。
- 两份 operator-guide 激活段与规范 README 前 19 行逐项人工核对；对应 optional、default、disabled 和其他控制器限制。该证据为文档审读，不代表真实宿主加载。

## Conclusion

- Current status: `open`
- Batch closure decision: `fix-required`
- Next action decision: `dispatch`
- 累计 Review round 为 2，默认 allowance 只剩 1 次 verdict；本轮复验四项，SEH-002 仍须修复。下一独立审查将是 round 3；若仍未满足验收，须走既有负责人决定出口，不能自动派发第四轮。
- round-01 的入口/方法/其余译文审读范围继续适用；live Agent 行为、宿主加载、真实部署、发行仍未验证。旧 C1–C5 独立待办不变。

## OpenSpec Impact

4.2 保持未勾选。3.3 的两版指纹与默认归属矩阵已有新证据；3.4 中显式完整旧包接口仍不成立，Fix Engineer 应按实际证据维护其完成声明及 4.1 汇总。本轮没有改动其他实施复选框，不把通过的默认分支代替显式分支验收。

## Next Actions

一次聚合 dispatch Fix Engineer，仅修复 SEH-002 并记录相关输入验证；其余四项已 verified。完整自包含 Operator Command 在 `.ai/handoff.md#operator-command`。不要求重复已绑定且未受修复影响的整个历史矩阵。

## Validation

OpenSpec strict 与 HEAD 到工作树的空白检查均退出 0；新增 round-02 的 no-index 空白检查无诊断。真实 .ai 运行态校验因源码布局缺少 docs/ai-collaboration/agent-prompts.md 退出 1；这是已记录的安装路径假设，不把它称为结构通过。

最终交接已在复现根的 runtime-e0d8b6637c614384b49c1ebe3669897e 结构夹具运行原 validate-runtime-state.ps1：退出 0，输出 Runtime collaboration structure is valid。真实 task/handoff/两份 result 保持同字节，实际输入文件和 payload 路径保留，仅在夹具补齐校验器要求的安装态规范角色卡/模板；没有修改校验器。结构通过不证明 Agent 行为或修复通过。

结束前重新核对三份完整输入包：集合、长度、SHA 均未变化，默认脚本自建旧包根全部已清理。本轮独立 GUID 复现根经绝对临时父目录、GUID 名称及全树无 reparse 检查后已删除；没有删除其他会话临时资源。根 snapshot SHA256 仍为 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743；Git 索引 SHA256 仍为本轮开始时的 2258ef2217febaee791708d0319353f1eb99c5227ccb36ee8dc9a4c6bf7a9cd2。本轮没有暂存、提交或修改产品代码。
