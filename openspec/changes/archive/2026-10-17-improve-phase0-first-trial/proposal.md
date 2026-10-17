# Proposal

## Why

2026-10-17 的 v1.8.0 Phase 0 试跑记录显示：首轮因样例任务使用扁平编号而结构校验 exit 1；次轮把命令放入证据路径列表导致校验失败，且会话 B 曾误贴占位文字。记录另确认 Git 初始提交、pwsh 前提、交接备份、Windows 排错和离线取包说明的缺口，需要以一个 M 级变更修正首次试用说明与 Agent 契约。

依据为用户指定的只读《Phase-0-试跑记录.md》中“第一轮”“第二轮”和改进清单的原第 1、2、4～9 项；本提案重新连续编号为 1～8。《Phase-0-产品体验与首次试用-实施方案.md》仅作背景，不整体转成实施范围。仓库不复制这些外部文件或私人运行态。

## What Changes

- 改进 1（原 1）：在 current-task 模板及 handoff schema 明确 `## 1.` 分组和 `- [ ] 1.1` 点号任务，运行态映射须与唯一 tasks.md 一致。
- 改进 2（原 2）：在 handoff、响应交接和 result 模板及 schema 区分文件证据引用与命令/输出；命令、实际输出和退出码放在 result 的 Checks Run，handoff 仅引用文件。
- 改进 3（原 4）：新增双语最小 Quickstart，在 setup 中加入 Git 初始化和首次提交。
- 改进 4（原 5）：Quickstart 明确 PowerShell 7（pwsh）前提。
- 改进 5（原 6）：Quickstart 指导在 B 前备份 A 的 handoff。
- 改进 6（原 7）：Quickstart 指导 B 粘贴真实完整 Operator Command。
- 改进 7（原 8）：Windows 排错仅保留文件被占用与沙箱拦截写入两种故障的最小处理方法。
- 改进 8（原 9）：Quickstart 提供可信完整 ZIP 的离线转交方式。双语 README 仅增加对应指南入口。

### Non-goals

不新增样例程序或 fixture 产品、不实施完整 Phase 0 路线图，不做首页重构、招募、计时/G0、视频、镜像站、新 CLI 或自动调度。不改变运行时校验器、安装管理器、宿主副本、机器字段枚举、权限、审查独立性或 S 级任务的审查成本。不更新版本、CHANGELOG、snapshot，不 commit/push/release，不在真实项目部署。

原试跑第 3 项“校验失败不得 accepted”及相关关闭规则调整：**待定，暂不纳入本变更**，不设置对应实施任务或增量规格。Windows 排错不扩展到其他故障或深度诊断。

## Capabilities

### New Capabilities

无；在既有协作包能力内收敛这八项。

### Modified Capabilities

- `collaboration-package`：增加点号任务、文件证据与首次试用操作要求。

## Impact

风险 **M**：影响跨模板的任务/证据约定和首次试用指引，需后续独立审阅；并非把试跑中的 S 级演示任务升级为 M。具体文件映射见 design.md 与 tasks.md，双语文档单独成组。

当前源目录没有 `docs/ai-collaboration/` 安装副本，规范位于 `payload/docs/ai-collaboration/`；没有 Quickstart 或 handoff-demo 样例。拟新增的 `docs/quickstart.md`、`docs/quickstart.zh-CN.md` 是包根阅读文档，不扩张目标项目安装映射。保持开发目录与完整包、试用项目分开；包字节的清单刷新只在后续另行授权的发行 staging 完成。

本轮只生成本变更目录中的规划文件；通过 OpenSpec validate 只说明提案结构有效，不代表实现或首次试用已验收。
