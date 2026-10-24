# Proposal

## Why

用户提供的 Lite 0.2.0 展示了短规则、聚合职责和顺序任务队列的价值，但其独立安装器、共享运行态路径及最大修订号胜出规则不能直接纳入官方产品。需要在同一仓库提供 Lite／Full 两种固定配置，降低日常使用负担，同时保留安装保护、独立审查和可靠交接。

## What Changes

- 用三个顺序里程碑完成整合：协议与样例定稿；产品及共用管理器集成；使用演练与发行准备。整体路线见 `../../roadmaps/lite-full-integration.zh-CN.md`，本变更的 tasks.md 是三期唯一实施清单。
- Lite 提供负责人、执行者、评审者三类职责，短规则、项目配置、顺序队列、短交接与聚焦只读校验；保留 S/M/H、必要独立验证、有限累计审查及 Agent 派发的一行 C1–C5 建议。
- 扩展现有管理器以选择 `WorkflowProfile=full|lite`，与现有 WorkflowMode 分开。省略配置继续使用 Full；有效旧安装保持原配置。一个项目只管理一种配置，不隐式转换未完成任务。
- Lite 规范源仍在 payload/docs/ai-collaboration/ 下，安装内容投影到 docs/engrelay-lite/；运行态使用 .ai/engrelay-lite/，Full 现有路径、标记和 Skill 名称保留。
- 统一版本及完整发行清单，复用归属保护、恢复材料和生命周期机制；新增配置不能绕过完整包检查。保留旧清单可信识别，并使旧管理器安全拒绝新格式。
- 同步双语人类说明与来源通知；在可丢弃目录验证相关行为，不引入后台调度、自动唤醒、自动迁移或两套发布流水线。

## Capabilities

### New Capabilities

- `workflow-profiles`：Lite／Full 配置身份、安装投影、Lite 顺序任务与短交接、兼容诊断及有界演练。

### Modified Capabilities

- `collaboration-package`：明确按已安装配置解析激活及入口，限定原有角色链和七个 Skill 的 Full 归属；扩展受保护生命周期以保存配置身份并拒绝隐式配置切换。

## Impact

涉及 scripts/manage.ps1、supported-layouts.json、update-snapshot.ps1、agent-rules.md、payload 下的 Lite 规范和工具、现有 doctor 的兼容入口、受影响夹具，以及双语 README、使用／维护说明、CHANGELOG 和来源通知。不直接合并私人 Lite 目录或其安装器，不改写已发行清单及归档 Review。

安装归属、清单升级与配置隔离按 H 影响组织设计及独立验证；纯协议／文档批次按实际影响分配，阶段名称不能重置同批累计计数。实际实施状态以本变更 tasks.md 为准；规划或单期设计验收不代表产品实施完成。三期结束目标为可审阅发行候选；提交、推送、GitHub Release、真实项目安装及全局设置修改仍须适用请求。本提案不设发布日期或预先占用版本号。
