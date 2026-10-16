# Round 01 - 独立代码审查

## Metadata

- Change: `streamline-entry-and-human-docs`
- Recorded on: `2026-10-16`
- Execution Batch ID: `engrelay-entry-upstream-human-docs-20261016-01`
- Review round: `1`（本批首次 verdict；不导入旧批次轮次）
- Round type: `re-review`（首次实现后的代码审查）
- Review role / agent: `Code Reviewer / Codex`
- Repository: `calvinfungcn/engrelay`
- Base: `6960d1975f07063c4250f241cd59dd3beaeaff27`
- Inputs: `.ai/current-task.md`、`.ai/handoff.md`、`.ai/round-01-result.md`、本变更全部 OpenSpec 产物、HEAD 到工作树的差异及新增文件。
- 独立性：当前审查会话未参与本批设计或实现；只写获授权的审查/交接产物。

## Findings

| ID | Priority | Status | 位置 | 发现及处置 |
| --- | --- | --- | --- | --- |
| SEH-001 | must-fix | open | scripts/supported-layouts.json:825、1002 | 公开两版的登记指纹错误，实际旧安装无法升级。修复并用原包复验。 |
| SEH-002 | must-fix | open | scripts/test-human-doc-lifecycle.ps1:140、219 | PackageRoot 未作为待测完整包使用，脚本重新导出并覆盖部分源码；完整包输入直接失败，源码模式漏入/漏出字节且遗留构建根。 |
| SEH-003 | must-fix | open | scripts/test-human-doc-lifecycle.ps1:224、226 | 对旧包刷新 snapshot，把导出 zip 纳入“旧版本”清单，破坏固定旧输入验证。 |
| SEH-004 | must-fix | open | scripts/test-human-doc-lifecycle.ps1:233、252、270；.ai/round-01-result.md 的 Layout and lifecycle | 缺少已约定的生命周期/归属验收，旧通过记录亦不对应当前 registry 字节。补齐聚焦证据后重述完成状态。 |
| SEH-005 | should-fix | open | payload/docs/ai-collaboration/operator-guide.md:11；operator-guide.zh-CN.md:10 | 新指南称只有当前显式选择才运行，遗漏保留的 default 模式。分清项目默认、当前选择优先及 disabled。 |

五项统一分配给本批 Fix Engineer；SEH-005 在已授权指南范围内，预计为配对短文修正，纳入当前修复而非推迟。没有新增范围或偏好类阻塞项。

### SEH-001 — 真实公开安装被错误指纹拒绝

按未修改的 `manage.ps1#Get-DeploymentFingerprint` 算法，从标签 snapshot 选择 agent-rules.md 和 payload 项，Ordinal 排序，以平台换行连接 `path|sha256|bytes` 后计算 SHA256：

| 版本 | 标签 snapshot 重算值 / 实际安装值 | 当前登记值 |
| --- | --- | --- |
| 1.7.0 | 794ee5dcbf019c5e981b1a5ee1472edfad1e392e39bc560630985c35e73279c6 | 9d43212297bc3f9830a4e1295a8e8de45fe91404850b28487e6c542041652f5a |
| 1.7.1 | 04c21e9565c1f455bf4555248f3708aa7737ca6aeb69fe1b83771d3c7354c681 | 5b1b6e4a2cd527e43fdea6306da209b0ecef2330e8699078bc2e71411dcf2375 |

本轮用清单完全匹配的原始 v1.7.1 包在 GUID 临时根 Install：退出 0，manifest 指纹为上表正确值。再用逐文件叠加当前授权差异、独立生成清单的候选 Upgrade：退出 1，错误为 `Installed packageVersion 1.7.1 does not match its verified layout fingerprint; retain backups and reconcile manually`。目标树含恢复元数据前后文件路径/SHA 集合相同。保护机制正确拒绝，但承诺的公开旧版升级失败。

修复限定：从原始标签 snapshot 重算两项登记，不改管理器算法、旧 paths、保护机制或发布清单。不要用刷新旧 snapshot 或增加合成旧包指纹掩盖此错误。

### SEH-002 — 待测输入与实际候选不一致

脚本无条件执行 Build-CandidatePackage，先在 PackageRoot 下 `git archive HEAD`，再将 payload/scripts 全目录覆盖，根目录只另覆盖 agent-rules.md；它不直接验证并使用传入的完整候选。因而：
- 对无 Git 元数据的正确完整包调用，实际退出 1，stderr 为 `fatal: not a git repository`，cases/calls 均为空；合法完整包无法执行验证。
- 从源码运行时，README、CHANGELOG、贡献/开发/许可译文等当前根目录差异未覆盖，且未维护授权差异及内容哈希清单。已有测试候选清单含旧 README，库存 59 项；本轮正确叠加候选为 63 项。
- 构建根及默认旧包根没有 finally 清理；本轮完整包输入失败也产生一个遗留候选目录。审查者仅清理了本轮新增目录，未清理之前运行的遗留目录。

修复限定：验证并直接使用指定完整 PackageRoot/PreviousPackageRoot；源码候选准备保持为独立的、按 design 的精确授权导出步骤。如仍有脚本自建临时资源，只清理其自行创建且经过绝对路径/GUID/边界验证的目录；不得删除传入包或用户已有目录。检查原生命令退出码并保留有效错误原因。

### SEH-003 — 重建旧清单使输入失去可信性

默认旧包将 `a.zip` 放进解压目的根，再调用 previous-update-snapshot。对实现阶段遗留的一个旧输入，本轮直接读取其 a.zip 内原始 snapshot 并逐项计算归档字节：54 项全部匹配；刷新后的 snapshot 列出 55 项，新增的正是 a.zip。这个刷新步骤只是让本不属于旧包的文件被认可，还会把未来的任意字节漂移重新写成该旧版本。

这违反 design Decisions 5 的“先核对原 snapshot，不刷新失败旧输入”。修复限定：archive 在包根外；核对完整原始集合、长度、SHA；任何不一致直接失败/unknown。保持原 snapshot 和旧包字节不变；旧包缺失不能声称旧版升级通过。

### SEH-004 — 缺少约定的归属检查，现有通过记录不能覆盖当前候选

实际只有三个 Record-Case：
- upgrade-adds-four-human-docs 仅断言路径存在；卸载后未核对包创建文件移除和项目原内容恢复。
- preexisting-same-bytes-preserved 只升级并比较一次文件哈希，随后直接删夹具，未执行卸载。它不能证明已明确要求的“同字节项目文件卸载后保留”。
- conflicting-bytes-zero-write 覆盖了不同字节冲突，但没有旧受管漂移零写入场景。

脚本也没有新装四文件受管、原备份/模式/SkillTarget/管理块外内容及哨兵的保留断言；1.7.0 codex 路径未执行。日志不绑定候选/旧包/脚本哈希，汇总丢弃子进程输出与前后树哈希，无法独立核对上述声明。

尤其，最后一个遗留测试候选里的 registry 仍使用 SEH-001 表中的正确指纹，而当前源文件已变成错误值；候选脚本也多两行调试输出。因此 `.ai/round-01-result.md` 的双宿主 outerExit=0 不能证明当前差异通过。本轮只复现了当前真实升级失败，没有重放已知不完整的整套测试。

另一个实际证据契约缺口：原 .ai/round-01-result.md 不符合 canonical implementation-result.template.md，缺少八个必需标题。运行态校验器会对被 Next input / Authoritative Evidence 引用的 result 校验这些标题，因此当前转交保留该原件作为待协调输入时，校验明确报 INVALID。本轮不改写实现者原始结果，也不把结构失败称为通过。

修复限定：补全 design Decisions 5 与 tasks 3.4 明确要求的聚焦场景/断言，以及双宿主 1.7.1 none/agents 和 1.7.0 codex 代表路径；绑定实际输入、宿主版本、子进程退出和零写入证据。按规范模板协调/以合规结果取代旧结果，保留原事实，验证下次交接。优先报告真实覆盖与限制，不增加无关历史矩阵。重新汇总证据并由 Fix Engineer 调整不再成立的任务完成声明。

### SEH-005 — 操作指南遗漏 default 激活语义

两份新指南的 Activation 都使用“仅当当前请求明确选择”的绝对条件，但保留的基线规格和产品 README 明确允许项目 default 选择流程，当前任务的明确选择优先。该说明会使 default 模式操作者误以为仍必须逐次显式激活。将两种语言同步说明 optional/default/disabled 与单一控制器规则；入口 Skill 本身显式调用的边界继续保留。

## Evidence

### 输入标识及环境

本轮 36 个待审差异/新增文件，逐文件构造 `relative-path|lowercase-raw-SHA256`、按 PowerShell Sort-Object 唯一排序、以 LF 连接、无尾换行，整体摘要：
`d4a4ef02921bb1f199fca2b1edbeb09060d09b8cf7e570de75cd4d0010b222a5`。
包含已暂存规划和未暂存实现，尚未包含本轮审查产物。

| 输入 | SHA256 |
| --- | --- |
| scripts/test-human-doc-lifecycle.ps1 | 9c23d7eee27b0bd4a8e1cdf1602632424f7ea6fb573304e431890be539d4a276 |
| scripts/supported-layouts.json | c6d8ab743f45dc69ef3068edfc7a70cb3be1b2c5eb5d364a136c169df6934ff7 |
| .ai/round-01-result.md | 26816684fea529f34397779867d828ddbf0bcd1c6a42d8f29cdc06a93c70e40b |
| 根 snapshot.json / 原 v1.7.1 snapshot | 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743 |
| 本轮精确叠加的 1.8.0 临时候选 snapshot（63 项） | dba4270517412855a8bacc5438855697db39a01b62e7b4a047b5ea726ed767b9 |

环境：Windows，PowerShell 7.6.6，Git 2.50.1.windows.1；命令使用已核实的工具绝对路径，仅子进程补充 Git PATH。没有修改全局设置、索引或产品文件。本轮不声称重新执行 Windows PowerShell 5.1 正向矩阵。

### 实际检查与复现方法

- `git diff HEAD` 及新增文件全量审读；graph-first 定位 manage / lifecycle 函数，图提示脚本部分解析覆盖缺口后补读实际源码。
- `git show v1.7.0:snapshot.json` / `git show v1.7.1:snapshot.json` 重算部署指纹：两项均不匹配登记；两项 paths/kind 各 40 项以及四 additions 精确集合正确。
- 对 HEAD 中五个历史条目的 JSON 语义比较：原 paths、fingerprints 保持；各追加四文档集合符合设计。
- 新 GUID 暂存根：`git archive HEAD` 在包根外导出 zip，叠加本批 27 个可导出授权差异/新增文件，再执行候选内 `update-snapshot.ps1 -PackageRoot <candidate> -Version 1.8.0 -ForRelease`，退出 0。源码根 snapshot 不刷新。
- 在独立 previous 根解压原始 v1.7.1 archive；保留原 snapshot，核对完整 54 项集合/长度/SHA；归档本身在包根外。用该原包 `manage.ps1 -Action Install -ProjectRoot <fixture> -WorkflowMode optional -SkillTarget none` 退出 0；当前候选 Upgrade 退出 1，含恢复元数据的树哈希集合不变。仅为 SEH-001 的受限复现。
- `test-human-doc-lifecycle.ps1 -PackageRoot <complete-candidate> -PreviousPackageRoot <original-previous>`：退出 1，零 case，Git 非仓库错误，且遗留自建目录；验证 SEH-002。
- 源码本批 Markdown 链接扫描，忽略代码围栏内示例、外部 URL 与锚点：未发现缺失的相对目标文件。四部署文档内部路径均位于部署子树；语言配对及英文提示词/许可证例外人工审读。
- `openspec validate streamline-entry-and-human-docs --strict`：退出 0。 `git diff --check`：退出 0。它们不证明升级行为或宿主加载。
- 审查后的 runtime 校验与临时资源清理结果见下方 Validation；没有运行全部历史套件。

### 入口与方法的审查范围

三组虚构输入按规范人工推演：明确的“已确认订单 CSV 导出”由 Intake 按风险路由、无需重复确认；业务不明确的“给店员做提醒”进入同会话 Requirements Analyst、以 continue/awaiting-owner-decision 等待，未确认不进入设计；已有明确 confirmed 基线的同范围请求复用身份与确认。disabled、其他控制器、技术歧义和旧任务保护仍由原规范约束。此为审查者的契约判断，不是受测 Agent 行为或宿主加载证据，相关 live 结果仍 unknown。

方法成对审读：可恢复且明确退出的 I/O 失败无需因缺 try/catch 强制修复，可能静默丢数据的失败应形成发现；短需求未提及参数不足以证明越界，明确排除的接口仍 must-fix；多处同类已授权根因可在最小修复通过后局部复用，单点问题不强制结构改造；依赖替换必须指出可用替代，公共接口/显著成本变化仍走范围决定。这些本地规则与所选择的上游方向相符，原 MIT 通知保留，未引入第二套分类或传输/提交权限。上游核对仅为方法来源，未借用其 eval 结果作为本地实现验收：
[PR 1791](https://github.com/EveryInc/compound-engineering-plugin/pull/1791)、
[PR 1792](https://github.com/EveryInc/compound-engineering-plugin/pull/1792)、
[PR 1852](https://github.com/EveryInc/compound-engineering-plugin/pull/1852)。

## Conclusion

- Current status: `open`
- Batch closure decision: `fix-required`
- Next action decision: `dispatch`
- Review round: `1`；默认三次累计 allowance 尚余两次 verdict，不因修复或换角色重置。
- 正式实现方向保持；五个高置信发现交一次聚合修复。没有产品代码修改或隐式设计扩张。
- 未验证：live Agent 行为、宿主加载、真实项目部署、发行；旧 C1-C5 仍独立待办。

## OpenSpec Impact

4.2 保持未完成，批次不关闭。3.3 的真实公开版指纹与 3.4 的验收证据不成立，4.1 汇总必须重做；本轮授权只允许审查者处理 4.2，因此没有改其他复选框。Fix Engineer 按实际完成情况维护唯一 tasks.md；不能沿用旧勾选宣称本轮验收通过。

## Next Actions

Fix Engineer 统一处理 SEH-001–005，记录输入绑定的聚焦结果，再交独立 Code Reviewer；当前审查者保持对修复的审查独立性。完整 Operator Command 写在 `.ai/handoff.md#operator-command`。

## Validation

- 最终 Operator Command 的 Routing、角色锚点、输入存在性等由规范 validate-runtime-state.ps1 在 GUID 结构夹具核对；任务/交接保持与真实输入相同字节，保留 payload 引用并补齐校验器要求的安装态角色卡和模板。退出 1，仅余原 .ai/round-01-result.md 的八个必需标题缺失；此为 SEH-004 待修问题，不声称运行态结构通过。未修改校验器或原始实现结果以绕过检查。
- 最终 OpenSpec strict 校验退出 0；git diff --check 退出 0；两份新增审查文件的 git diff --no-index --check 无空白诊断（存在新文件差异的退出码与空白错误区分处理）。
- 本轮完整候选、原始 previous、目标夹具及运行态结构夹具均位于独立 GUID 根，经绝对父目录/GUID 和递归 reparse 检查后清理；失败脚本本轮产生的额外候选根也单独核实并清理。没有删除实现阶段遗留目录。
- 暂存索引 SHA256 仍为 fb6e270dcd4832efc5abeda89e60321491203c39d975ab0d19e17a45ffe04ea6；源 snapshot SHA256 仍为 16929f2151186fa753166d0d476381764a55528b1c7ab53b24b26d18bef6b743。本轮仅新增正式 round/index 并更新 handoff，tasks 4.2 未改变。
