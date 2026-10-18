# Verification

## Scope And Inputs

`fix-autonomous-continuation` 的受影响运行态结构规则。使用脚本自行建立且清理的 GUID fixture；未读取报告问题的真实项目，未改动已有 `.ai/current-task.md` 或 `.ai/handoff.md`。

最终受检文件 SHA256：

| File | SHA256 |
| --- | --- |
| payload/docs/ai-collaboration/scripts/validate-runtime-state.ps1 | 42518cd4ff7cf021525effb33dcc2ed79736dffd9b991d690acf11c418c20a50 |
| payload/docs/ai-collaboration/scripts/test-validate-runtime-state.ps1 | 19aceb093bb00972c301a289709cb63c99305cfe7df1566473404dd3cba18a1a |

## Red Evidence

在实现新校验前，运行新增 CaseFilter：

- `autonomous continuation invalid*`：原校验器将非法人类介入值当作有效，expected exit 1，actual exit 0。
- `autonomous continuation neutral*`：原校验器拒绝远期环境预告的 `Human action: none`，expected exit 0，actual exit 1，诊断为 requires actionable Human action。

首轮独立审查后，先补反例再修复：

- `autonomous continuation closing hashes cannot bypass blocked*`：expected exit 1，actual exit 0。
- `autonomous continuation batch suffix*`：expected exit 1，actual exit 0。

## Final Checks

在源码根目录分别执行（本机版本为 PowerShell 7.6.7 与 Windows PowerShell 5.1.26100.9711）：

```powershell
& 'C:/Program Files/PowerShell/7/pwsh.exe' -NoProfile -File payload/docs/ai-collaboration/scripts/test-validate-runtime-state.ps1
& 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' -NoProfile -ExecutionPolicy Bypass -File payload/docs/ai-collaboration/scripts/test-validate-runtime-state.ps1
```

两次最终子进程均 exit 0，各输出 `All runtime-state validator tests passed (229 cases).`；其中 39 个 `autonomous continuation` 新增场景全部通过，原有 190 个用例保持通过。本次仅运行受影响校验器套件，不重放安装/升级/卸载生命周期。

新增场景覆盖中性远期预告、旧格式缺省、当前人类等待摘要、非法/空/重复值、命令的存在/位置/完整性/当前角色和精确批次、等待与派发/关闭禁用、审查上限、代码围栏、合法 Markdown closing hashes 与隐藏重复块。

其他检查：

- `openspec validate fix-autonomous-continuation --strict`：exit 0。
- `git diff --check`：exit 0。
- 对受影响 Markdown 扫描的 85 个本地文件链接目标存在；新 `autonomous-continuation` 锚点存在。未据此声称检查所有旧锚点或外部网站。
- 双语 README、操作指南、CHANGELOG 语义对应；Agent 契约、机器字段保持英文。

原始输出位于忽略的 `.ai/continuation-checks/final-ps7.log` 与 `final-ps51.log`。这些是本地辅助证据，不纳入 Git 或发行包；本文件记录可公开的结果和代码输入对应关系。

## Interrupted Check And Recovery

一次最终定向运行的 39 个断言全部 PASS，但 fixture 清理报 Windows `directory is not empty`，进程 exit 1，故未将该运行作为成功依据。随后核对并清理了该次已知 GUID 临时目录；以上两次完整最终运行均含清理步骤且 exit 0。没有通过忽略异常、更改测试期望或扩大删除范围消除失败。

## Limits

本证据证明结构规则、回归兼容与有限文档场景核对，不认证自然语言授权、环境实际就绪、真实 CLI/IDE 遵从或业务验收。中性预告的语义由规范和独立审查约束，校验器不增加“回复”等词语黑名单。EngRelay 不提供自动唤醒或后台调度；单次运行器退出后，仍须已有外部机制或操作者启动接替会话。

本次为未发布开发变更，`snapshot.json` 保留最后发行清单，未将开发文件吸收到旧发行包。下一次明确发布时按开发指南从受审查提交干净导出后重新生成清单。
