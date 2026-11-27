# EngRelay 2.1.0 发行准备记录

[English](release-preparation.md)

日期：2026-11-27。提案：`add-v2-change-review-relay`。

五项实施任务均已完成。[审查摘要](index.zh-CN.md)记录了最终实施审查 PASS、R1–R4 关闭及首行 `Change:` 遵循性的非阻塞提示。此前发现和修复反馈继续作为历史证据保留；发行准备不增加实施 verdict，不重置计数。复用独立结果仍要求输入匹配、映射验收相同且适用门禁全部满足，包括 H 级修复后的独立验证。

## 归档与源码检查

- `openspec validate add-v2-change-review-relay --strict`：`Change 'add-v2-change-review-relay' is valid`。
- `openspec archive add-v2-change-review-relay --yes --json`：归档至 `openspec/changes/archive/2026-11-27-add-v2-change-review-relay/`，`specsUpdated: true`；新增 1 项、修改 3 项要求，无删除或重命名。
- `openspec list`：`No active changes found.`。
- `openspec validate --all --strict`：归档后 `Totals: 3 passed, 0 failed (3 items)`。
- v2 主规范逐字包含全部四个增量要求块。五项任务仍已勾选，新增归档及审查文档的本地 Markdown 链接均有效。
- 当前双语版本元数据、公开包测试期望及快照默认值均为 2.1.0，历史版本记录未改写。刷新归档暂存内容并移除两处 Markdown 行尾空格后，暂存隐私扫描及 `git diff --cached --check` 通过。

## 干净候选包结果

源码提交：`53415abc6704a55022025f8881d551a9efd41b9e`。在 `%TEMP%` 新建 GUID 目录，使用 `git archive HEAD` 导出。仅在暂存副本运行 `scripts/update-snapshot.ps1 -PackageRoot <staging-package> -Version 2.1.0 -ForRelease`。两个宿主使用字节一致的独立副本；同一副本内依次运行套件，日志放在包外。

| 套件 | Windows PowerShell 5.1.26100.9818 | PowerShell 7.6.10 |
| --- | --- | --- |
| `test-v2-workflow.ps1` | PASS：56 次调用 / 46 项检查，退出 0 | PASS：57 次调用 / 46 项检查，退出 0 |
| `test-workflow-profiles.ps1` | PASS：83 次调用 / 32 项检查，退出 0 | PASS：83 次调用 / 32 项检查，退出 0 |
| `test-public-package.ps1` | PASS：7 次调用，2 项通过 / 1 项历史检查跳过，退出 0 | PASS：7 次调用，2 项通过 / 1 项历史检查跳过，退出 0 |

Windows PowerShell 5.1 因操作要求管理员权限而明确跳过文件符号链接用例；PowerShell 7 已执行该用例，两个宿主均已执行目录 junction 检查。未提供可选冻结 v1.6.1 包及原始 v1.9.6 输入。合成接管及兼容夹具不证明兼容所有历史包。

快照 SHA256：`92c62089b386f542481ab04d2a37a6616250836bc052096ca643237898eb47e5`。清单包含 89 个文件，共 1,416,583 字节；计入 `snapshot.json` 后完整包为 90 个文件。两个宿主副本运行全部套件后，精确文件集合、大小、哈希及快照字节均未变化。已测快照拷回源码作为发行元数据提交；发布前还须确认最终 HEAD 导出与该已测清单一致。

正式发行使用最终 HEAD 的新 ZIP 及 `SHA256SUMS`。发布流程先下载草稿附件、与本地哈希核对，再转为公开发行。`.gitattributes` 排除 OpenSpec 及源码审查记录；被忽略的运行态、宿主副本、缓存和备份不是导出输入。

## 隐私与验证边界

本机文件 URL 已替换为有效相对链接。私有原始审查证据继续保持忽略；跟踪摘要及虚构演练保留结论与限制，不导入原文件。对变更跟踪文件的有限扫描覆盖私有用户／项目路径、已知私有项目名、凭证类 token 格式及私钥头，未发现未解决命中；已有安装示例路径为虚构占位符。这不是穷尽秘密检测的声明。v2 原创内容继续使用 MIT，未引入新第三方文本，许可证与第三方声明文件保留。

未向源码仓或真实项目安装。虚构代理演练及结构／生命周期检查不证明外部 Codex／Cursor／Claude 加载、真实跨平台额度、token 节省、所有 Agent 遵从或业务验收；既有演练也明确限定了独立性证据范围。临时构建、日志和下载目录在发布核对完成后清理；私有证据副本仅保留在本地忽略目录 `.ai/`。
