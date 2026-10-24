# 安装投影、清单与兼容样例

这是任务 1.5 的设计核对，不是已经运行的新管理器或旧包验证。第二期使用可信完整来源及 GUID 临时项目执行本表，不使用真实项目。本批不修改源码安装器、快照或历史登记。

## 现有代码依据

| 依据 | 已确认事实 | 第二期必须补齐 |
| --- | --- | --- |
| scripts/manage.ps1 的 Get-BasePlan、Get-Plan | 全量枚举 payload，随后派生一个发现目标；默认没有配置过滤 | 显式构造两配置集合，不能把 Lite 子树顺便装到 Full |
| Read-State | 首先拒绝 version 非 1、移动及非 installed／inactive 状态，随后核对精确布局、记录、备份和管理块 | 独立严格的 v2 分支，不让 project-document 走“非 file 即需管理块”旧分支 |
| Get-InstalledLayout、supported-layouts.json | 显式登记 1.2.0、1.3.0、1.4.0、1.5.2、1.5.3、1.7.0、1.7.1；其他版本仅有当前同布局兼容 | 从可信 v1.9.6 完整包固定布局／指纹，转换前明确登记，不把任意 v1 当 Full |
| Get-UpgradePlan | 现有普通文件拒绝归属漂移，支持精确新增／退役及已登记 legacy project-document | 为 v2 项目配置增加严格限定的保留分支，保留历史采用标记的原有意义 |
| Get-DeploymentFingerprint、Get-Snapshot | 历史部署指纹基于来源文件；完整来源检查和目标投影不是同一集合 | v1 原算法原登记保留；v2 指纹绑定配置及精确映射，仍校验整个包 |

## Lite 固定投影

以下文件为第二期将编写的目标集合，不表示已存在。来源前缀固定 payload/docs/ai-collaboration/lite/，一般目标前缀为 docs/engrelay-lite/。

| 来源相对路径 | 目标 | 归属 |
| --- | --- | --- |
| RULES.md | RULES.md | 包文件 |
| README.md、README.zh-CN.md | 同名 | 包文件；仅人类指南分语种 |
| templates/project-config.md | 同名模板，并用于首次创建 docs/engrelay-lite.config.md | 模板归包；实例归项目 |
| templates/queue.md、templates/task.md、templates/handoff.md | 同名 | 包文件，均不创建 live 状态 |
| scripts/validate-state.ps1、scripts/doctor.ps1 | 同名 | 包文件，只读 |
| LICENSE | LICENSE | 包文件，含适用通知 |
| agent-rules.md | 不作为普通文件复制；供现有 AGENTS.md 官方管理块生成 Lite 内容 | 受管块，标记保持 ai-collaboration:begin／end |

这是固定映射，不是公开插件配置。Full 排除整个 Lite 子树，保持原 Full 目标及必要的兼容修订；不把 Lite 配置实例加到 Full。初版 Lite 不写 CLAUDE.md 或全宿主 Skill 目录，非自动读取 AGENTS 的宿主使用明确读取提示。旧私人 Lite 入口不自动改写。

Lite 不维护独立 VERSION 发行线；Status／CheckVersion 从统一 packageVersion 和配置身份报告。人类指南可指出所安装版本，不要求 Agent 每个任务跑版本检查。

## v2 记录的最小语义

- 清单顶层 version=2，workflowProfile 为 full 或 lite，保留 packageVersion、projectRoot、phase、workflowMode、skillTarget、原始恢复材料及受支持采用信息。各状态和路径必须经过严格读取，不把 inactive、损坏或中断当作可继续安装。
- 普通 file、agents、gitignore 维持原有保护；新增 project-document 只允许 Lite 的 docs/engrelay-lite.config.md。不能把普通受管文件改成该类型绕过漂移，也不能伪造旧 legacyProfile。
- project-document 的记录含 path、kind、preexisting 和首次登记字节的 hash；该 hash 仅作来源记录，不要求用户配置之后仍匹配模板。它不要求 managed insertion；没有覆盖过既有配置，不需要伪造原始备份。v2 读取按这种明确类型校验，不能套旧“所有 preexisting 记录都必须有 backup”的分支。
- 初次不存在时创建配置实例；若仅该配置文件预先存在且无未受管 Lite 目录／旧入口，保留其内容并登记项目归属，不宣称接管旧工作流。有私人 Lite 目录或入口仍走冲突拒绝。项目配置不能覆盖包保护或凭空授权。
- 升级／卸载始终保留项目配置实例，即使它仍与模板相同；配置变化不算包漂移。配置缺失时诊断说明，Upgrade 不静默重建，按具体错误给最小恢复方向；Uninstall 不为此创建或删除配置。
- v2 部署指纹含明确版本标识、workflowProfile、SkillTarget、按 ordinal 排序的精确源→目标映射、归属类型及包来源 hash／大小，使用固定 UTF-8 和 LF 序列化。项目配置实例的可变字节不进入包部署指纹，模板字节仍在完整 snapshot 中。
- v1 指纹保留原实际换行和历史算法，不强行转换为 v2 的 LF 规则。新完整包全部字节仍按 snapshot 核对，不能只取当前配置文件而忽略另一个配置缺失。
- 只读 Status／CheckVersion 不写清单。可信旧 Full 的 Upgrade 在预检通过后转 v2；原备份不替换为升级前副本。配置省略时取已有清单，显式冲突先拒绝；SetMode 不改配置或宿主目标。

## 固定验收场景

符号来源 P 为已核对完整候选包，O 为真实可信 v1.9.6 完整包；其哈希与清单由第二期夹具取得，不在本文伪造。输入中的目标文件均为隔离夹具内容。

| ID | 输入 | 预期结果／写入边界 |
| --- | --- | --- |
| I01 | 空项目，P，省略 WorkflowProfile 和模式 | Full、optional、原 none 默认；不生成 Lite 或业务运行态 |
| I02 | 空项目，P，lite／none | 只有明确 Lite 集合、项目配置、官方块及忽略项；无 Full 七个 Skill |
| I03 | P 中缺一个未选配置的 snapshot 文件 | 两种安装都拒绝；不写目标或恢复元数据 |
| I04 | lite 配合 SkillTarget=agents | 写入前拒绝并解释 none；不部署副本 |
| I05 | 已有合法 Lite v2，Upgrade／SetMode 省略 profile | 保留 Lite、原模式／目标；SetMode 只改变所请求模式 |
| I06 | 已有 Full，请求 lite 的重复 Install 或 Upgrade | 写入前拒绝配置切换，保留原文件／证据；无自动运行态转换 |
| I07 | O 安装出的原始 v1 Full，来源和布局已登记 | 新 Upgrade 预检并转 v2 Full，原模式／目标／备份不变，后续卸载保留原项目内容 |
| I08 | 自称 v1.9.6、缺 profile，但记录或原指纹不符 | 拒绝；不能由版本字符串或缺字段推定可信 Full |
| I09 | 用真实 O 管理器操作新的 v2 Lite／Full | Read-State 早期版本检查拒绝；第二期需核对目标前后零写入，不只断言源码分支 |
| I10 | 用户修改配置、AGENTS 块外文字和 runtime 后 Upgrade／Uninstall | 保留全部项目内容；普通包文件仍按漂移规则处理 |
| I11 | 普通包文件漂移、新目标有不同内容、重复／不完整标记或非法路径 | 预检拒绝，保留现场；无 force、手写清单或跨根写入 |
| I12 | 无官方清单，已有私人 Lite 目录／旧入口 | 不自动 Adopt 或覆盖；给出保存输入、协调旧入口及干净安装方向 |
| I13 | 仅预先存在项目配置，其他目标无冲突 | 配置保留为 project-document；不得因内容不同而覆写；目标为目录／非法路径仍拒绝 |
| I14 | 适用 Adopt -Preview | 零写入；不借本变更新增所有动作通用 Preview |
| I15 | 写入中断、manifest phase 非合法已安装状态 | 报具体阶段并保留恢复材料，后续读取不当作新安装；不得删 manifest 强行重试 |
| I16 | 需要回退，手头只有 O，当前为 v2 | 说明 O 不能直接维护 v2；保留对应新管理器和备份，受保护卸载／按批准方式恢复再装旧包，不承诺直接降级 |

独立验收还需比较普通包来源与映射的精确集合，拒绝 v2 任意新增／缺失记录。I09、I15 及 PowerShell 5.1／7 的实际结果属于第二期；本期结论只是路径具有现有代码依据和明确可执行验证方法。
