# Round 04 - SEH-002 独立复审与闭批

## Metadata

- Change: `streamline-entry-and-human-docs`
- Recorded on: `2026-10-16`
- Execution Batch ID: `engrelay-entry-upstream-human-docs-20261016-01`
- Review round: `4`（负责人有限授权的绝对上限；没有重置累计计数）
- Round type: `re-review`
- Review role / agent: `Code Reviewer / Codex`
- Repository: `calvinfungcn/engrelay`
- Base: `6960d1975f07063c4250f241cd59dd3beaeaff27`
- Inputs: 当前 task/handoff、round-04-result、round-03-result、正式前三轮审查、OpenSpec 产物及当前源字节。本审查会话未执行设计、实现或修复；仅写指定审查、4.2 和交接产物，在一次性目录运行检查。
- Authority: Task Owner 于 2026-10-16 明确同意仅修复 SEH-002 并再独立审查一次，累计上限到 4；完整结构化授权保留于 `.ai/handoff.md`。

## Findings

没有新增高置信度缺陷；本批全部已分配发现均已验证。

| Topic | Priority | Status | 本轮结论 |
| --- | --- | --- | --- |
| SEH-001 | must-fix | verified | registry、manager、部署内容均未变；复用 round-02 的原始两版指纹及受保护升级证据。 |
| SEH-002 | must-fix | verified | 实际 AST 是双括号表达式的 Or；双宿主均拒绝同根及两种包含关系，0 case / 0 manager call；合法显式输入各 5/5；包内日志均拒绝且未写入。 |
| SEH-003 | must-fix | verified | 旧包提取、校验和清理代码未变；复用 round-03 默认分支 5/5。原始完整旧包本轮前后集合、长度和 SHA256 相同，未刷新旧清单。 |
| SEH-004 | must-fix | verified | 复用未变输入的 round-02 代表矩阵、模式/目标/备份及拒绝摘要；本轮完整当前候选又执行双宿主 10 个场景，全部通过。 |
| SEH-005 | should-fix | verified | 两份 operator-guide 与 round-03 同字节，optional/default/disabled 的原核对继续适用。 |

## Evidence

### 输入绑定及差异

勾选 4.2 前，36 个源差异文件（排除本变更正式审查产物）的 `relative-path|lowercase-SHA256`，经 PowerShell Sort-Object 排序、LF 连接且无尾换行，摘要为：
`9b35cfb5d360ea95350f03e6de5abd1a5ffae32f79683e7fcfc4137865f871c0`。

仅将脚本哈希换回 round-03 的 `a333172096631a9a56f1a04fbc3b31cb6691829d84cca619979d5be14e18b08a`，即精确恢复 round-03 摘要 `e8e04ff6a655d458d4782567e3b395e427710948d5ed2092335e2f96a43fb698`。其余 35 个源输入未变；本次实际修复仅第 90 行两次调用的括号。复用前轮证据的范围因此明确。

| 输入 | SHA256 |
| --- | --- |
| 当前生命周期脚本 | 53d6bdf407f9080664ae4e6de1e8b375417ab184c67dbe3154de93259d2fca3c |
| 本轮完整当前候选 snapshot，63 项，夹具版本 1.8.0 | b81079da0ccd0b8b81a9f0cedfc82d8309507ab706bf3656cc98e4996297f7ef |
| 原始 v1.7.1 snapshot，54 项；亦为源码根 snapshot | 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743 |
| Git index（审查开始） | 88fb3162f315f4eaef9573448c02f19ce3fbc588f03f4183ebc5132e8d6eea66 |

修复者复用的 HEAD 候选有完整匹配的 63 项清单，但其中测试脚本仍为 round-03 字节，snapshot 为 `01b4b828449dfee5a35fa0d9f193ac5363898057c7cf3246bb8431529082cc35`。本轮不将其冒充当前全部源码：逐项核对后，在新的 `%TEMP%/engrelay-review04-61dae36954084eb280b34428766a33e0/candidate` 复制该候选，仅覆盖已授权的当前脚本，再对这一新暂存副本运行 `scripts/update-snapshot.ps1 -PackageRoot <candidate> -Version 1.8.0 -ForRelease`，exit 0。新候选全部 63 项均与当前源字节匹配，完整文件集合匹配清单。夹具版本不是发行决定。

旧包继续使用修复者已保留的 `%TEMP%/engrelay-seh03-6c88e3831ee849f086c2f7a15862e243/v1_7_1`。本轮没有修改该包或重建其清单。合法测试前后均独立核对两包完整集合、长度及每项 SHA256，差异 0。

环境：Windows；PowerShell 7.6.6、Windows PowerShell 5.1.26100.9711；Git 2.50.1.windows.1。工具使用绝对路径，无全局 PATH 变更。

### AST 和边界拒绝

先用 codebase-memory `search_graph` / `get_code_snippet` 定位并读取实际函数；trace 返回关系不足，补读实际脚本，确认 `Get-PreviousPackageRoot` 经 `Assert-ExplicitPreviousInputRoot` 在第一个 Record-Case 之前检查根隔离。

使用 `[Management.Automation.Language.Parser]::ParseFile` 解析实际脚本，无解析错误；`Assert-PackageRootsDisjoint` 条件为 `BinaryExpressionAst`，Operator=`Or`，Left/Right 均为 `ParenExpressionAst`：

```powershell
(Test-PathUnderRoot $Left $Right) -or (Test-PathUnderRoot $Right $Left)
```

实际调用脚本验证如下。两种嵌套组合均使用本轮一次性副本，内包位于外包 `.ai/` 下；不刷新任何嵌套副本的 snapshot，避免 manager 额外文件检查掩盖前置拒绝。所有重叠探针均 outerExit=1、cases=0、calls=0，错误为 `Candidate and explicit previous package roots must not overlap`。

| 宿主 | 场景 | 日志 SHA256 |
| --- | --- | --- |
| PS7 | 同根 | 4ee3a52e3e30dadce1b3a19aac05947d2db60f12e209d6446534b2ea849a924d |
| PS7 | candidate 在 previous 内 | ffd8cd97c9edd66e86910df8ceeda5c0792285d50b8028ca3f2236d9f95c0a7f |
| PS7 | previous 在 candidate 内 | 9cc6560952ff6cadfceee13af597cc2678a81d6d97ac1bf3aeacf829f7138079 |
| PS5.1 | 同根 | a07ba4410ab7a7e25e675b3c066444154cea4daaa1f494985b252b705ae09587 |
| PS5.1 | candidate 在 previous 内 | 7fe1293217a735b91499c29cdbc1ad4194e11124988ff5f76db1748ab43a7982 |
| PS5.1 | previous 在 candidate 内 | e727ff8a90d5d0679da248030c4ecc852d936f24c1fce94a632223fecbbc41a1 |

双宿主另各执行 LogPath 在 candidate/previous 内的两种拒绝：共 4 次 exit 1，错误 `LogPath must be outside package roots`，目标日志不存在。测试后两包无新增文件或字节变化。

### 合法显式输入

工作目录为仓库根；`$candidate` 为本轮新完整候选，`$previous` 为上述原始旧包；没有传 SourceRepoRoot。实际两包无 Git 元数据。

```powershell
& <PS7-or-PS5.1-exe> -NoProfile -ExecutionPolicy Bypass -File scripts/test-human-doc-lifecycle.ps1 -PackageRoot $candidate -PreviousPackageRoot $previous -LogPath <outside-package-log>
# 重叠组合使用同一命令，将两根换成同根或上表一次性嵌套副本。
# 日志拒绝组合将 LogPath 换成 candidate 或 previous 内的新文件路径。
```

| 日志 | 结果 | SHA256 |
| --- | --- | --- |
| explicit-ps7.json | exit 0，5/5 PASS，33,576 ms | bc96025fa34fd6547996c04cc515112e6522589554f3f8a69572c72dd3730a62 |
| explicit-ps51.json | exit 0，5/5 PASS，16,715 ms | 589821d628976930ea29323ace4d6b1466cb50b07e81c840278ed02d41bc002d |

场景为旧安装升级并卸载、新装文档受管并卸载、同字节预有文件卸载保留、不同字节冲突零写入、旧受管漂移零写入。每宿主 12 个 manager 子进程退出序列均为 `0,0,0,0,0,0,0,0,0,1,0,1`；两个 1 对应期望的冲突和漂移拒绝。所有日志绑定当前脚本、新候选 snapshot 和未变原始旧包 snapshot。

### 结构与完成检查

`openspec validate streamline-entry-and-human-docs --strict`、`git diff --check` 均通过。真实源工作区运行 `validate-runtime-state.ps1 -WorkspaceRoot <repository>` 仍因硬编码安装路径缺少 `docs/ai-collaboration/agent-prompts.md` 退出 1；这是已记录的源码布局限制，不记为通过。

最终关闭交接另在本轮 GUID 根的 runtime 夹具运行原 validator：同字节复制当前 task、最终 handoff、实际证据和源输入，保留 payload 路径，并在夹具 docs 下提供同字节规范角色卡/模板。`validate-runtime-state.ps1 -WorkspaceRoot <review-root>/runtime` exit 0，输出 `Runtime collaboration structure is valid`。收尾 `openspec validate streamline-entry-and-human-docs --strict`、`git diff HEAD --check` 均 exit 0；新增 round-04 的 no-index 空白检查无诊断。源码根 snapshot 与 Git index 保持上表哈希。不修改原校验器，不安装到源码仓库，结构检查不证明宿主加载或业务行为。

## Conclusion

- Current status: `verified`
- Batch closure decision: `accepted`
- Next action decision: `close`
- 累计 verdict 为 4；所有已分配 must-fix 和 should-fix 已 verified，无未完成的本批映射项，无下一角色或 Operator Command。未启动第 5 轮。
- 入口/方法/其余文档沿用前三轮对相同输入的审读和已记录场景证据。本轮没有把人工契约审读或结构检查称为 live Agent、真实宿主加载、部署或发行验收；这些仍未验证。C1–C5 仍是本批以外的独立待办。

## OpenSpec Impact

独立审查者据本轮证据勾选 4.2；1.1–4.1 原映射和已记录验证限制保留。关闭当前批次，不执行 OpenSpec 归档、Git 暂存/提交/推送、发布或真实安装。

## Next Actions

`close`。最终动作和完整有限授权保留于 `.ai/handoff.md`；无下一角色或 Operator Command。
