# workflow-profiles Specification Delta

## MODIFIED Requirements

### Requirement: Fixed workflow profiles and preserved defaults

官方管理器 SHALL 提供 `WorkflowProfile=v2|full|lite`，与 WorkflowMode、SkillTarget、S/M/H 及 C1–C5 分别独立。未指定配置的新安装 SHALL 默认安装 `v2` 并保留既有 `optional` 模式及 `SkillTarget=none` 默认；有效已有安装（含 `v2`、`full`、`lite`）在省略该参数时 SHALL 保留各自既有配置。一个项目 SHALL 只由官方管理器管理一个配置。

#### Scenario: Existing command omits the new parameter
- **WHEN** 操作者在未安装项目运行原有 Install 命令，没有指定 WorkflowProfile
- **THEN** 安装 `v2`，保留原模式及 `SkillTarget=none` 默认，不增加选择问答

#### Scenario: Existing Full or Lite installation preserves its profile
- **WHEN** 已安装 `full` 或 `lite` 的项目运行省略 WorkflowProfile 的 Upgrade 或 SetMode
- **THEN** 保留原有 `full` 或 `lite` 身份与归属，不隐式转换为 `v2`

#### Scenario: Mode changes do not switch profiles
- **WHEN** 操作者对 `v2`、`full` 或 `lite` 安装使用 SetMode
- **THEN** 仅改变模式，保留原配置身份、归属、配置和证据

### Requirement: Profile-specific deployment from one complete package

发行 SHALL 使用统一版本与完整 snapshot；安装校验完整来源后仅部署所选配置集合。`v2` SHALL 部署 `docs/engrelay/`、`docs/engrelay.config.md` 与精简入口，支持 `SkillTarget=none` 及单一宿主发现目标，SHALL NOT 安装 `full` 或 `lite` 专属文件。`full` 部署 SHALL 排除 `docs/ai-collaboration/v2/` 与 `lite/`；`lite` 仅部署 `docs/engrelay-lite/` 且仅支持 `SkillTarget=none`。

#### Scenario: A complete package installs v2
- **WHEN** 完整可信包以 `v2` 配置（显式或默认）安装到空白夹具
- **THEN** 目标包含 `docs/engrelay/` 规定集合（含 `RULES.md`、`skills/engrelay/SKILL.md`、模板、`doctor.ps1`）、`docs/engrelay.config.md` 与精简受管入口，不混入 `full` 手册、七个 Skill 或 `lite` 文件

#### Scenario: v2 deploys unified Skill to selected host target
- **WHEN** 操作者使用 `WorkflowProfile=v2` 与非 `none` 的有效 `SkillTarget` 安装
- **THEN** 除 `docs/engrelay/` 规范文件外，仅将统一的 `engrelay/SKILL.md` 复制到对应宿主发现目录，并在清单记录归属

#### Scenario: Full install excludes v2 and Lite subtrees
- **WHEN** 操作者显式使用 `WorkflowProfile=full` 安装
- **THEN** 目标仅部署 `full` 集合，排除 `docs/ai-collaboration/v2/` 与 `docs/ai-collaboration/lite/`

#### Scenario: A complete package installs Lite
- **WHEN** 完整可信包以 lite 配置安装到空白夹具
- **THEN** 目标包含 docs/engrelay-lite/ 的规定集合及受管入口，不混入 Full 契约、七个 Skill 或 v2 文件

#### Scenario: Package file outside the selected profile is missing
- **WHEN** 来源包缺少 snapshot 列明的 `full` 或 `lite` 文件，而操作者只请求 `v2`（或任一配置）
- **THEN** 仍拒绝来源不完整，不能把配置投影当作跳过完整性检查的授权

#### Scenario: Unsupported Lite discovery target
- **WHEN** Lite 安装请求非 none 的 SkillTarget
- **THEN** 写入前说明当前 Lite 使用显式规范读取，项目文件和安装状态不变

### Requirement: Profile identity and legacy manifest compatibility

新受管安装 SHALL 在版本 2 清单中记录配置身份（`v2`、`full` 或 `lite`）和完整部署归属，使旧管理器在目标写入前拒绝。新管理器 SHALL 仅对可信已识别的旧 version=1 安装按 `full` 处理并通过受保护升级转换，保留原始备份、模式、SkillTarget 及项目内容；未知清单 SHALL NOT 因缺少配置字段而被猜作 `v2` 或 `full`。

#### Scenario: Supported old Full installation upgrades
- **WHEN** 受支持旧清单和文件通过可信布局及归属核对
- **THEN** 新管理器识别为 `full`，升级保留原配置语义及恢复材料，不重算旧发行指纹且不隐式切换为 `v2`

#### Scenario: An old manager encounters a new manifest
- **WHEN** v1.9.6 管理器尝试维护新格式 `v2`、Lite 或 Full 安装
- **THEN** 在目标写入前拒绝，不按 Full 猜测或删除新布局

#### Scenario: Unknown state lacks a profile
- **WHEN** 清单缺少配置身份且不满足可信旧布局识别
- **THEN** 报告具体清单问题并保留内容，不自动创建或接管安装

### Requirement: Explicit configuration transitions and protected project ownership

Upgrade、重复 Install 及 SetMode SHALL NOT 在 `v2`、`full` 与 `lite` 之间隐式转换配置。需要转换时 SHALL 提供保存证据和协调入口的明确人工路径；未完成任务 SHALL NOT 自动改写。`v2` 项目配置 `docs/engrelay.config.md` 与 `lite` 项目配置首次创建后 SHALL 归属项目，升级和卸载保留；运行态与项目证据不成为包可删除内容。受管文件漂移、归属冲突及不完整管理块 SHALL 在目标写入前拒绝。

#### Scenario: Upgrade requests another profile
- **WHEN** 已安装项目收到与当前配置（`v2`/`full`/`lite`）不同的升级或转换请求
- **THEN** 拒绝隐式转换，提供保留状态及受保护卸载／安装的方向，不改写未完成任务或累计审查数

#### Scenario: Project edits its v2 configuration and runs Upgrade or Uninstall
- **WHEN** 已安装 `v2` 项目修改 `docs/engrelay.config.md`、管理块外文字及 `.ai/relay/` 运行态，随后执行 Upgrade 或 Uninstall
- **THEN** 保留这些项目内容与运行态，普通受管包文件仍按各自归属及漂移规则处理；Uninstall 后因安装新建的空 `docs/engrelay/` 目录被移除

#### Scenario: Project edits its Lite configuration
- **WHEN** 已安装项目修改项目配置、管理块外文字及本地证据，随后执行 Upgrade 或 Uninstall
- **THEN** 保留这些内容，包文件仍按各自归属及漂移规则处理

#### Scenario: Private Lite layout is present
- **WHEN** 无官方清单的目标已有私人 Lite 内容或入口
- **THEN** 不自动 Adopt 或覆盖，不将其声明为可信旧安装；说明冲突和保存输入的方向

#### Scenario: Private v2 layout is present
- **WHEN** 无官方清单的目标已有私人 `docs/engrelay/`、`docs/engrelay.config.md` 或 `v2` 入口内容
- **THEN** 不自动 Adopt 或覆盖；Install 与 Adopt 均说明冲突和保留资料的方向
