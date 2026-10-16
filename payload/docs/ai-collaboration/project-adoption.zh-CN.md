# 项目采用

[English](project-adoption.md)

本文说明将 ai-collaboration 引入真实项目的有限路径。每条路径都写明项目根目录、真实写入所需授权，以及所支持的验证范围。夹具运行或包结构检查不等于真实部署，也不能证明宿主加载或业务验收。

所有命令请使用绝对路径。将 `E:\Projects\your-project` 替换为实际项目根，并在包目录下运行包管理器。

## 任何路径之前

1. 确认目标项目根目录与确切的包版本。
2. 阅读项目自身的 `AGENTS.md` 及其他活跃的控制器文档。留意 Agent 实际会读取哪些入口。
3. 备份每条路径会改动的每个入口文件；若内容敏感，备份放在项目外。记录 SHA256。
4. 采用过程中不要提交 Git、不要改全局工具设置、不要启动业务运行。

## 路径 A：完整包、受管归属

适用于项目应接收完整包、且由管理器拥有已安装文件与受管块的情况。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action CheckVersion -ProjectRoot 'E:\Projects\your-project'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Install -ProjectRoot 'E:\Projects\your-project' -WorkflowMode optional
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.8.0'
```

`CheckVersion` 为只读：报告已安装版本、工作流模式及是否可升级。`Install` 在预存文件与包副本字节不同时会在任何写入前停止。用有界比较解决冲突，不要强制覆盖。

将受管安装从 packageVersion 1.2.0 升级到 1.4.0 会新增三个诊断文件（`scripts/doctor.ps1`、`host-capabilities.md`、`project-adoption.md`）以及 `scripts/find-solutions.ps1`；从 1.3.0 升级则仅新增 `scripts/find-solutions.ps1`。除非每次新增或退役都已针对已安装版本登记，否则管理器拒绝升级。已存在且字节完全一致的项目文件变为项目自有；字节不同则会在任何写入前拒绝升级。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Upgrade -ProjectRoot 'E:\Projects\your-project'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.8.0' -Host codex
```

若升级中断，清单阶段会变为 `upgrading`。后续管理动作不得报告成功。保留 `.ai-collaboration-install/` 中的恢复文件（`manifest-upgrade-*.json`、`upgrade-files-*.json`），与当前字节对比，并逐个恢复所列文件。Doctor 会将中断阶段报告为必须失败的项。

用 `SetMode` 更改模式，不要编辑受管块。用 `Uninstall` 移除安装：仅删除未改动的包创建文件与受管块；项目自有文件、后续外部编辑与运行证据均保留。

## 路径 B：选择性通用规则

适用于项目只想吸收通用协作规则、且不希望管理器拥有任何文件的情况。

1. 将所需规则文本复制到项目自有的 `AGENTS.md` 区块或独立文档中，附清晰标题与来源说明。
2. 不要添加包的受管标记，不要创建 `.ai-collaboration-install/`。
3. 保持项目现有规则、任务证据及其他工作流文档不变；不要删除整个文件。
4. 运行只读 doctor。归属会报告为未安装，入口事实会显示当前存在的内容：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Packages\engrelay-1.8.0\payload\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.8.0'
```

此路径不提供管理器归属、自动升级或受管卸载。后续变更须手工完成，并按项目内容审查。

## 已知旧版采用

对于版本 1.5.3，目录还识别经审查的已退役通知配置。它要求 `docs/ai-collaboration/README.md` 的精确规范化哈希；原核心文件与旧入口控件可以缺失。已知 `docs/solutions/solution.template.md` 仍为可选且在存在时做哈希校验。所有未知的现有 payload 路径以及残留的旧激活或部分受管标记仍为冲突。

当项目已匹配本包目录中的完整旧版配置时，用下列包命令请求有界接管。`Preview` 为只读：在允许 Adopt 之前校验完整配置、唯一已知旧版入口片段、路径类型及冲突。旧版入口文件在行尾、BOM 或片段外内容上可以不同；未知、重复或部分片段仍会拒绝。成功后，规范文件保持原字节并进入管理；`docs/reviews/README.md` 与 `docs/solutions/README.md` 留在原位，仍可编辑为项目内容。不要手写清单、标记或迁移脚本，也不要搬迁项目索引。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Adopt -Preview -ProjectRoot 'E:\Projects\your-project' -WorkflowMode optional
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage.ps1 -Action Adopt -ProjectRoot 'E:\Projects\your-project' -WorkflowMode optional
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'E:\Projects\your-project\docs\ai-collaboration\scripts\doctor.ps1' -WorkspaceRoot 'E:\Projects\your-project' -PackageRoot 'E:\Packages\engrelay-1.8.0'
```

若 `.ai-collaboration-install/manifest.json` 已存在，请先使用 `Upgrade` 或人工协调；Git 恢复、未知条目、部分配置或任何不匹配文件留下的清单会拒绝采用。拒绝时仅解决报告中的冲突；没有 Force 模式。

## 非受管旧版集成

适用于入口已含较旧协作说明、但没有可信包归属记录的情况。包从不声称拥有那些行。

1. 为每个入口以及新路径可能改动的任何 `.ai` 或审查证据保存私有备份。记录路径、字节数与 SHA256。
2. 将活跃旧版路由与项目安全、测试、模块及 OpenSpec 约束分开。用有界编辑停止旧版路由的指定行；不要删除整个 `AGENTS.md`。
3. 检查工具实际读取的每个入口。仅停止当前任务未选中的重复控制器。
4. 保留历史文件并标注为历史，而不是删除。
5. 仅在旧版入口清理完成后，路径 A 的 `Install` 才可添加受管归属。管理器会拒绝未标记的旧版规则区块。

人工协调应为一个有界变更集并附单一摘要。不要用原始备份覆盖后续编辑来恢复整个项目。

## 验证边界

- 可丢弃临时根上的夹具运行仅展示包行为。
- Doctor 报告展示文件与归属事实。它不运行宿主。
- 真实项目采用、试点、宿主加载、业务运行与发布各自需要独立授权任务与证据。在此之前均视为未执行。
