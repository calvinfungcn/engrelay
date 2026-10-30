# Proposal

## Why

1.10.0 的 Lite 校验会放行没有扩展授权的超额可执行 continue，并因命令／来源使用不同的代码围栏识别而误收样例、误拒有效只读交接。Lite 双语指南还把已发布版本描述为本地候选，需要以小范围修复恢复可信的交接检查和一致说明。

## What Changes

- F1：将既有额度判断应用到可执行 continue 和 Agent dispatch，保留有效有限授权、负责人等待、合法关闭及真实非执行阻塞记录。
- F2：复用同文件的围栏识别能力；命令的身份及必需内容只取自实际命令块，来源元数据只取自围栏外，正确处理围栏字符、长度、结束和嵌套样例。
- F5：同步纠正 Lite 中英文指南的发布时态，更新必要的规则、双语公开说明及未发行修复记录。
- 保持 lite-1 字段、显式来源／SHA256 比对、只读零写入、能力建议非阻断和默认三次累计审查额度；不自动迁移或修改历史状态。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `workflow-profiles`：明确 Lite 只读校验的可执行动作额度及命令／来源围栏边界，保留有效记录和非阻断建议。

## Impact

- 产品：payload/docs/ai-collaboration/lite/scripts/validate-state.ps1、Lite RULES.md、必要模板及两份 Lite README。
- 检查：scripts/test-lite-state.ps1；复用真实子进程退出码、诊断及文件哈希检查，不引入新测试框架或 Markdown 依赖。
- 公开说明：按受影响行为同步根 README 和 CHANGELOG 的两种语言；不选新发行版本、不改根 snapshot、不执行提交／发布／真实安装。
- 新校验可能拒绝旧代码误放行的超额动作或不完整命令；只报告问题，由有权 Agent 更新交接，不改写旧记录。正常三反引号 text 命令继续可用。

### Follow-up work

负责人已选定的 F3（SetMode 失败后的入口／清单恢复）和 F4（可信 v2 布局的新增／退役升级）在本批之外，状态为已确认待独立设计实施，由下一次 Task Intake／Chief Designer 接续。本批完成不得将两项标为完成；尤其 F4 应在后续新增或删除受管路径的发行前解决。它们以本节及 OpenSpec 双语导航保留入口，不在此创建另一份实施清单或虚构变更编号。
