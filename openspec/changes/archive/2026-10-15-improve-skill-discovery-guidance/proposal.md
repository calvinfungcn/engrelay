# Proposal

## Why

默认安装不创建宿主发现副本，操作者照主示例安装后容易把无法直接调用 Skill 误认为安装失败，并转而手工复制文件。当前成功消息只给出目标名，双语 README 又以兼容目标 codex 举例，与包内建议新 Codex 安装使用 agents 的说明不一致。

## What Changes

- 在安装步骤中明确区分规范 Skill 的直接读取与宿主发现；保留默认 `none`，为新 Codex 安装给出显式 `agents` 示例。
- 在首次 Install 成功后增加简短、可见的信息提示，说明已选目标、实际规范/发现路径，以及文件放置不能证明宿主加载。保留现有成功消息、PowerShell 成功流和退出结果。
- 对已有安装优先提供直接读取方法；说明 Install/Upgrade 不用于追加或切换目标，确需调整时使用现有官方流程，不自动操作或接管手工副本。
- 在可丢弃测试包与目标中检查提示、流分离及原有安装保护，同步两版 README；复用已正确的宿主指南，不改部署内容。

本变更不新增安装动作、依赖或破坏性迁移。交接能力 C1–C5 建议已获授权，但属于另一个可独立验收的行为，留待后续独立批次。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：补充安装发现方式的明确告知及成功输出兼容要求；保留现有 Skill 名称、路径、单目标选择、激活和归属保护合同。

## Impact

- 产品：`scripts/manage.ps1` 的首次 Install 成功出口；不修改 Get-Plan、安装清单结构、升级或卸载算法。
- 文档：`README.md`、`README.zh-CN.md`；`payload/docs/ai-collaboration/host-capabilities.md` 作为现有依据保持不变。
- 验证：复用现有夹具安全边界和受管状态检查模式，增加一个聚焦提示验证脚本；在 Windows PowerShell 5.1 与 PowerShell 7 运行。
- 本批风险 M，代码变更后需要独立审查。无需新增依赖、宿主配置、真实部署或当前发行 snapshot 更新。
