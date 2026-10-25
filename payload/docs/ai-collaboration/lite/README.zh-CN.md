# EngRelay Lite

[English](README.md) · [规则](RULES.md)

本指南适用于本地 1.10.0 候选，尚未推送或发布。最近已发布版本 1.9.6 不含 Lite。

Lite 是同一 EngRelay 完整包中的固定配置，使用执行者、评审者和顺序批准队列。
Full 保留七个规范 Skill 和角色链；Lite 无专属 Skill 或宿主发现副本。管理器报告
统一包版本和所选配置，不设独立 Lite 版本线。

在项目之外的可信完整包内执行：

```powershell
& ./scripts/manage.ps1 -Action Install -ProjectRoot $project -WorkflowProfile lite -SkillTarget none
& ./scripts/manage.ps1 -Action Status -ProjectRoot $project
```

安装默认 optional，不创建业务任务。对安装项目的 Agent 明确说：“本任务使用
EngRelay-Lite。读取 AGENTS.md、docs/engrelay-lite/RULES.md、
docs/engrelay-lite.config.md 及当前已批准任务。”不会自动读取 AGENTS 的宿主也
使用该提示。通用 EngRelay 进入已安装 Lite；Full 专属 ai-collaboration 和
ai-collab-* 入口须说明不匹配，不自动切配置。

项目自有配置记录已核实命令和限制。从[队列](templates/queue.md)、
[任务](templates/task.md)、[交接](templates/handoff.md)模板创建
.ai/engrelay-lite/ 下的必要状态，不复制他人运行态。已有 OpenSpec 的范围、验收
和唯一 tasks.md 继续作权威，模板本身不批准任务。按需读取源码和模块指令。

例如，已批准且验收明确的 S 文档修正可在相关自查后收口；M 实施需要独立审查，
必须修项需独立复核；H 保留实际触发的设计审查和独立验证。默认累计三次 verdict，
换阶段、模型或配置不清零；到限未通过须等负责人决定，不开第四次自主循环。

项目配置 `docs/engrelay-lite.config.md` 中可选的工具、模型、推理偏好、已有评审启动方式、
限制与隔离示例仅供参考。留空或不可用的偏好不阻塞工作，不授予权限、不自动启动工具；
升级不覆盖已有项目实例。队列完成行沿用原列，只写简短结果和稳定证据链接。交付质量评价见
[RULES.md](RULES.md)，仅作建议，不构成门槛。

真实边界先决定值，保存并回读，再用该组值核对：

```powershell
& ./docs/engrelay-lite/scripts/validate-state.ps1 -WorkspaceRoot $PWD.Path `
  -ExpectedTaskId T01 -ExpectedNextAction continue -ExpectedNextRole none `
  -ExpectedReviewRound 0 -ExpectedStateRevision 2
& ./docs/engrelay-lite/scripts/doctor.ps1 -WorkspaceRoot $PWD.Path
```

示例值须替换成真实已决定的状态。成功只证明结构和给定预期；诊断只读。缺少派发
能力建议只提醒。当前人工等待须有真实决定或环境前置；远期预告无需当前操作或
回复。同角色会话结束也保存可执行 Continuation Command。进程须由实际宿主重新
启动，包不会自动唤醒 Agent。

完全只读评审须先在旧 Evidence 点名结果路径，返回完整发现和响应交接，并以唯一
英文 `- Field: value` 行保留 Task ID、Source role、Source agent、Work producer、
Named result、Prior revision、Prior handoff SHA256、Target revision、Cumulative
verdicts、Verdict；元数据置于响应代码围栏之外。可选 SourceResultPath 和
PriorHandoffPath 只核对明确给定评审来源及旧字节，不恢复或发布。有权 writer
核对完整动作和归属，当轮保留完整返回并只发布一次。冲突不应用，不扫描目录或
取最大修订。Full 历史运行态保持隔离。

Upgrade 和 SetMode 省略 WorkflowProfile 就保持 Lite。切换前保存任务证据、项目
配置并协调项目历史说明，然后按明确授权受保护卸载／安装。无私人 Lite 自动
Adopt 或任务迁移，不能删 manifest 绕过拒绝。配置实例和运行态归项目，卸载仍保留；
普通包文件继续拒绝漂移。配置缺失时明确恢复项目内容，Upgrade 不静默重建。

保留对应完整包／管理器及原始恢复材料。旧 v1.9.6 管理器不能维护 v2。回退先用
对应新管理器受保护卸载或按明确批准的方式恢复。卸载仍保留 inactive v2 清单，
旧管理器也会拒绝它。安装可信旧包之前，须明确获准将 inactive 恢复目录完整归档
到官方状态路径之外，保留项目配置、运行态及原始备份。不能删除活跃、中断或冲突
清单绕过保护；这不是直接降级。
本说明不执行 Git、部署或负责人验收。

[LICENSE](LICENSE) 保留 EngRelay 和参考 Lite 的完整 MIT 通知。输入指纹只固定
字节，不认证作者或证明完整来源审计。既有入口文件基准显示 Lite 的 AGENTS.md 静态
字节少 86.3%，不代表总上下文、token 或延迟减少。单工件任务／审查记录是协议设计，
不证明运行时遵从。第三期有界 S/M/H 与队列演练已有调用证据，结果和独立审查状态
记录在源码审查历史中。证据限于虚构样本及已观察宿主，更广泛的宿主遵从性未验证；
独立候选审查已完成。完整候选包须按文档中的构建流程，以实际提交导出和匹配清单
为依据；导出证据另行记录。发布须单独请求。
