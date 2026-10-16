# Tasks

本清单是本变更唯一实施清单。所有实施及验证项初始未完成；规划产物存在不表示实现完成。按 design.md 的范围、来源、文档清单和聚焦验证执行，不另建任务账本。

## 1. 统一入口与需求确认

- [x] 1.1 修改 payload 下 start/requirements 的规范入口，复用 workflows 条件需求分析动作，必要时最小澄清角色卡和入口索引；验证明确任务直接分流、歧义任务在同一会话由分析师等待确认、确认后只交首席设计师，且名称/路径/激活和已有任务保护不变。
- [x] 1.2 同步双语 README 的统一入口说明，按设计用虚构输入检查明确、歧义、已确认复用三个关键场景，记录实际角色、下一动作和确认状态；核对 disabled、其他控制器、技术歧义及未完任务边界，区分受测 Agent 结果与人工契约审读，不用措辞匹配替代行为证据。

## 2. 兼容同步上游方法

- [x] 2.1 在 ce-code-review/ce-debug 中补充实际失败后果、明确范围与依赖替代、受限重复根因预防规则；用设计中的成对案例核对判定，保留风险/发现分类、权限、最小修复与独立审查边界。
- [x] 2.2 在 compound-engineering 及相关 Skill/第三方通知记录固定提交、实际采用和不采用项，在开发指南记录本机 Superpowers 更新建议；核对 MIT 原文完整及来源归属，确认未安装插件、未编辑生成副本、未引入外部传输/提交授权或第二套权威，ce-simplify/ce-compound 无需变更的结论有依据。

## 3. 人类文档、语言分离与安装兼容

- [x] 3.1 按设计表补齐贡献、开发、CHANGELOG、第三方说明、OpenSpec 导航及审查目录索引的中文配对版本与语言互链；核对实质信息对应、开发提示词继续英文原文、未发布变化记入双方 Unreleased，历史审计条目和许可证原文未被改写。
- [x] 3.2 新增 operator-guide 中英文、project-adoption/host-capabilities 中文等四个部署文件，同步已有英文人类说明与双语示例导航；等义清理英文产品 README/handoff-schema 中夹杂的中文说明，验证无中文 Agent 契约/机器模板/输出变更、旧示例路径保留、源目录和安装目录的指南内部链接均可达。
- [x] 3.3 更新 scripts/supported-layouts.json：既有条目只追加四个精确 additions，保留旧 paths/指纹；从公开 1.7.0/1.7.1 标签 snapshot 重算指纹并登记真实旧布局。以实际 payload 集合差异核对全部登记，禁止修改历史 catalogue 或用伪造旧包绕过保护。
- [x] 3.4 增加聚焦 scripts/test-human-doc-lifecycle.ps1，使用 PackageRoot/PreviousPackageRoot/LogPath 与已验证 GUID 夹具；按设计候选准备方式执行代表目标和双 PowerShell 宿主的安装/升级/卸载、同字节预有文件保留、冲突和漂移零写入检查，记录子进程退出码/目标含元数据前后哈希及实际覆盖场景。保留原备份、模式、目标和管理块外内容，缺少可信旧包不得记通过，不跑九目标或全部历史套件。
- [x] 3.5 对设计的人类文档清单做逐份语言/含义/链接核对，明示技术标识、许可证和英文提示词例外；确认源码维护译文不进入安装目标、Agent 不加载双语契约，新增部署文件恰为四个，保留历史审计原件与源 snapshot。

## 4. 汇总证据与独立审查

- [x] 4.1 汇总当前候选的入口、方法、文档和归属证据，运行 openspec validate streamline-entry-and-human-docs --strict 与 git diff --check；核对实际改动没有超出范围、局部证据输入匹配、未验证项如实记录，并更新本批结果与完整 handoff，交给独立 Code Reviewer。
- [x] 4.2 由独立 Code Reviewer 聚合检查全部本批差异与实际证据，在 docs/reviews/streamline-entry-and-human-docs 下记录正式轮次和 index；按既有规则处理发现及必要复验，累计计数保持单调，确认对应验收满足后才完成此项和闭批，实现者不得自行勾选。
