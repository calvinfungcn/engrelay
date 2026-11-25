# EngRelay 2.0.1 发行准备

[English](release-preparation.md)

日期：2026-11-25。提案：`refine-v2-relay-ergonomics`。

全部六项任务完成。[审查摘要](2026-11-25-review.md)保留首次 I1 输出契约问题、修订后的独立定向复审 PASS，以及建议评分 4/5。发行核查不重置历史、不新增产品审查 verdict。最新 `Command: none` 说明和非递归 `[IO.Directory]::Delete` Junction 清理均包含在发行输入中。

## 归档与源码检查

- `openspec validate refine-v2-relay-ergonomics --strict`：`Change 'refine-v2-relay-ergonomics' is valid`。
- `openspec archive refine-v2-relay-ergonomics --yes --json`：同步新增 1 项、修改 2 项要求，归档至 `openspec/changes/archive/2026-11-25-refine-v2-relay-ergonomics/`，保留全部文件及 `.openspec.yaml`。
- `openspec list`：`No active changes found.`。
- `openspec validate --all --strict`：`Totals: 3 passed, 0 failed (3 items)`。
- `openspec validate --archived --strict`：23/23 通过。
- v2 主规范与增量一致；变更 Markdown 本地链接及 `git diff --check` 通过。公开包脚本三处版本期望和 snapshot 默认版本均为 2.0.1；双语当前发行日期为 2026-11-25。

## 干净候选实际结果

主提交：`de1c712c17c9d4dcc102a9c12c851e514e114421`。从 `HEAD` 使用 `git archive` 导出到系统临时目录中新建的 GUID 目录，仅在 staging 内运行 `update-snapshot.ps1 -Version 2.0.1 -ForRelease`。两个宿主使用各自字节一致的完整包副本；每份包内顺序运行套件，避免配置测试临时移除源文件时发生竞争。日志位于包外、另一个临时目录。

| 套件 | Windows PowerShell 5.1.26100.9818 | PowerShell 7.6.10 |
| --- | --- | --- |
| `test-v2-workflow.ps1` | PASS：47 次调用 / 44 项检查，exit 0 | PASS：47 次调用 / 44 项检查，exit 0 |
| `test-workflow-profiles.ps1` | PASS：83 次调用 / 32 项检查，exit 0 | PASS：83 次调用 / 32 项检查，exit 0 |
| `test-public-package.ps1` | PASS：7 次调用，2 项通过 / 1 项历史检查跳过，exit 0 | PASS：7 次调用，2 项通过 / 1 项历史检查跳过，exit 0 |

以上是使用本次提交脚本（含 Junction 清理修订）的最终候选实际运行，未将此前修改 staging 测试副本的结果冒充本次结果。两个宿主运行后，包的清单字节均未改变。未提供冻结 v1.6.1 或原始 v1.9.6 转换输入；合成 Adopt 检查不证明真实历史二进制兼容。

snapshot SHA256：`436998b2d1a7bac0e1cb4460103ad3d17898643b140e338ed3e518b1bf4287ec`。清单含 89 个文件、共 1,393,232 字节；完整包加 snapshot 共 90 个文件。已核对精确集合及逐项大小、哈希；源码 OpenSpec/Review 和私有运行态、工具目录均未混入。已测试快照回填用于第二个提交；发布前用暂存树及最终 HEAD 导出分别与已测试候选核对。ZIP 与 `SHA256SUMS` 基于最终 HEAD，上传后重新下载比对哈希。

## 隐私与限制

新归档背景和演练记录已移除工作区绝对路径及真实私人业务项目名。原始 `.ai/` 审查和日志继续忽略，只跟踪摘要及虚构夹具。变更公开文件经过私人用户/业务路径、凭据、Token、私钥模式扫描，已用模式未发现剩余匹配；这不等于穷尽所有秘密格式。v2 原创内容保留 MIT，没有新增第三方文本导入，`LICENSE` 和 `THIRD-PARTY-NOTICES*` 保留。生成宿主 Skill、图缓存、备份及打包产物不进入 Git。

没有安装到本源码仓库或真实项目。外部 Codex/Cursor/Claude 加载、真实额度切换、token 节省和所有模型遵从仍未验证。最终完整性检查后清理本次临时构建、日志及下载附件目录；私有证据副本只保存在本地被忽略的 `.ai/`。
