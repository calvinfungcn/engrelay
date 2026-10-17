# 变更日志

[English](CHANGELOG.md)

## 未发布

- 为中英文 README 增加功能概览和简短任务流程示例。
- 区分选择性改编的 Compound Engineering Skill 与未捆绑的 Superpowers 引用，
  补充固定提交的 Superpowers 许可来源及再分发声明保留要求。

## 1.8.0 — 2026-10-16

- 将 `ai-collab-start` 作为推荐通用入口，在重要业务歧义时复用既有需求分析职责；保留 `ai-collab-requirements` 的名称、路径与显式需求讨论能力。
- 对照 Compound Engineering 插件提交 `50532b00de523980010d97fe950965b35382a3b7`（相对 v3.29.0 基线的 v3.30.5 比较）选择性同步方法，仅采用 PR 1791、1792、1852 相关规则；不导入整套上游生命周期或传输层。
- 为人类使用与维护说明提供独立中英文版本与互链；英文 Agent 契约不增加中文副本。
- 新增四个部署指南：`operator-guide.md`、`operator-guide.zh-CN.md`、`project-adoption.zh-CN.md`、`host-capabilities.zh-CN.md`；并登记精确的历史布局转换。
- 为公开 v1.7.0/v1.7.1 包登记精确布局转换，并为新增人类指南增加聚焦的受保护生命周期夹具。

经审查的 63 文件候选在 Windows PowerShell 5.1 与 PowerShell 7 上通过聚焦生命周期场景，涵盖升级、内容保留、冲突拒绝与卸载。OpenSpec 严格校验和空白检查通过。这些检查不证明 live Agent 行为、宿主加载、真实项目部署或业务验收。C1–C5 交接能力引导不在本版本范围内。

## 1.7.1 — 2026-10-15

- 首次安装引导展示所选 SkillTarget、目标项目的规范 Skill 路径，以及适用时的发现目录。
- 澄清默认 `none` 安装支持直接规范 Skill 阅读；新 Codex 安装可显式选择 `agents`，`codex` 为兼容保留。
- 保留原有 PowerShell 成功流与退出行为；额外引导使用信息流，可用 `6>$null` 抑制。
- 更新两种语言 README，新增英文维护者起始提示词，并在源码中归档已完成的 OpenSpec 变更与三轮 Review。
- 在 Windows PowerShell 5.1 与 PowerShell 7 上，用可丢弃夹具验证聚焦引导、生命周期保护与 v1.7.0 升级。

宿主加载、真实项目部署与业务验收仍是独立检查。本版本不包含 C1–C5 交接能力引导。

## 1.7.0 — 2026-10-14

- 引入公开 EngRelay 名称与中英 README 版本。
- 保留 ai-collaboration 安装标识与既有受管升级。
- 从拟议公开分发中移除私有项目快照、运行证据、工作站设置与旧 Git 历史。
- 对原创材料适用 MIT 许可证并保留第三方声明。
- 提供完整包清单与聚焦的 Windows PowerShell 5.1/7 证据。

这是 EngRelay 首次公开发布，源自本地 1.6.1 包。更早本地包不作为 GitHub 历史发布表示。包夹具不确立真实项目部署、宿主加载或业务验收。
