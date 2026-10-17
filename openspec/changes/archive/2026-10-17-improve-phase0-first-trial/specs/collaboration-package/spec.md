# Spec Delta

## ADDED Requirements

### Requirement: OpenSpec dotted task references

任务准备说明、current-task 模板与 schema SHALL 明确：唯一实施清单使用 `## 1.` 分组及 `- [ ] 1.1` 点号编号；运行态只映射该 tasks.md 中实际存在的任务编号。SHALL NOT 将扁平 `- [ ] 1.` 作为合法映射示例或创建第二份实施清单。

#### Scenario: Prepare a mapped batch
- **WHEN** Agent 为现有 OpenSpec 变更准备 current-task
- **THEN** 可依模板识别点号格式，将批次映射到 tasks.md 中的真实 `1.1` 等项，既有运行时校验器能识别该映射

#### Scenario: Flat task numbering
- **WHEN** 任务输入使用扁平编号，导致既有结构校验无法识别映射
- **THEN** 修正任务输入与映射后复验，不放宽校验器或虚构已存在的任务编号

### Requirement: File evidence and result content separation

handoff 及响应交接的文件证据项 SHALL 填写真实可访问的文件路径，适用时使用现有 `none`，不得填写命令字符串。命令、观察到的输出摘要、退出码及必要的原始日志引用 SHALL 保存在结果文件；实现/修复结果复用既有 result 模板与 Checks Run，不新增机器字段或强制为纯文案另建运行态。

#### Scenario: Record implementation checks
- **WHEN** Agent 已运行行为检查与运行态结构检查
- **THEN** 将实际命令、结果、退出码写入 result，handoff 的 Authoritative Evidence 只引用 result 或日志文件；任务清单引用的编号与路径分开说明，不能把整个命令当作路径

#### Scenario: Command mistaken for an evidence path
- **WHEN** 证据列表中的命令被既有校验器识别为不存在的文件路径
- **THEN** 移动命令与输出到结果文件并改为文件引用后复验，不修改校验器或清空必需证据来隐藏失败

### Requirement: Trial setup has an inspectable Git baseline

Quickstart SHALL 在会话 A 前提供针对新建可丢弃试用项目的 `git init`、检查忽略范围、显式暂存试用输入及首次本地提交步骤与成功检查。SHALL NOT 要求更改全局 Git 身份、配置远端或把运行态、安装备份和宿主缓存纳入提交。

#### Scenario: New trial directory
- **WHEN** 操作者尚未在独立试用目录建立 Git 仓库
- **THEN** setup 指导建立可检查的初始提交，使用 `git status --short`、`git log -1` 确认基线；缺少身份时只给项目局部配置方向

### Requirement: Trial requires PowerShell 7 explicitly

Quickstart SHALL 明确本次试用需要 PowerShell 7（`pwsh`），并提供 `pwsh` 可用性与主版本检查。此要求 SHALL 仅限定本条试用途径，不改写工具包原有 Windows PowerShell 5.1/7 支持声明，不自动安装或更改全局策略。

#### Scenario: Only Windows PowerShell is available
- **WHEN** 用户只有 Windows PowerShell 5.1，或找不到 pwsh
- **THEN** 在会话 A 前报告前提未满足并指向环境准备，不把 powershell.exe 当作此次 pwsh 检查通过

### Requirement: Preserve session A handoff evidence

Quickstart SHALL 在会话 A 产生有效交接后、打开 B 前，指导在试用项目内备份 `.ai/handoff.md` 为 `.ai/handoff.A.md`，核对副本内容；已有副本不得被静默覆盖。该副本 SHALL 仅作本地证据，B 的活动输入仍为最新 `.ai/handoff.md`。

#### Scenario: B later updates the live handoff
- **WHEN** B 实施后更新活动 handoff
- **THEN** A 的交接内容仍可从备份检查，备份不取代实时路由、不重放旧命令，也不提交仓库

### Requirement: Session B uses the actual complete operator command

Quickstart SHALL 指导新会话 B 从当前真实 handoff 的 Operator Command 复制完整命令，确认批次、角色、输入输出与约束；提示中的占位说明 SHALL 清楚标成须替换的说明。没有有效交接、仍含占位文字或角色不符时 SHALL 停在恢复说明，不猜测授权。

#### Scenario: Placeholder pasted into B
- **WHEN** B 收到模板占位说明而非当前真实完整 Operator Command
- **THEN** 指南说明回到真实 handoff 重新复制并核对，保留既有角色匹配防护，不要求 B 忽略路由继续执行

### Requirement: Windows trial troubleshooting stays local

Quickstart SHALL 仅提供两种故障的最小处理方法：文件被占用时关闭相关编辑器或让 pwsh 离开目标目录后重试；Codex 沙箱拦截写入时核对工作目录与可写范围，按宿主受支持流程处理所需写权限后重试。SHALL NOT 扩展到其他故障或深度诊断，也不提供批量杀进程、强删目录、全局降权或绕过沙箱的步骤。

#### Scenario: A trial directory is in use
- **WHEN** 操作因编辑器或 pwsh 占用目标文件/目录失败
- **THEN** 指南提示关闭相关编辑器或让 pwsh 离开目标目录后只重试失败操作

#### Scenario: Codex blocks a write
- **WHEN** 文件系统写入被宿主沙箱拒绝
- **THEN** 按指南核对实际工作目录与授权可写范围，使用宿主支持的权限处理方式后重试；仍失败时保留错误并说明尚未解决

### Requirement: Offline acquisition preserves the complete package

Quickstart SHALL 为不能访问 GitHub 的用户提供离线取得方式：由可访问者从可信发行入口取得对应版本的完整安装 ZIP，连同来源、版本及可用的完整性信息原样转交，接收者核对解压后的 snapshot 文件集合与哈希。SHALL 区分完整包、开发源码和目标项目，不杜撰镜像地址、不让新手修改清单掩盖缺失文件，不宣称 SHA256 是发行者签名。

#### Scenario: GitHub is unreachable
- **WHEN** 接收者只能通过离线介质或内部文件传输收到安装包
- **THEN** 指南给出可执行的来源/版本确认与完整性核对步骤；包不可确认或内容不匹配时重新取得可信完整包，保留错误，不直接安装
