# EngRelay 1.11.3 发行准备

[English](release-preparation.md)

日期：2026-11-23。负责人明确授权完整独立审查、必要修复、归档、GitHub 提交与 Release 发布。

## 完成与归档

[已归档清单](../../../openspec/changes/archive/2026-11-23-improve-review-readiness-and-convergence/tasks.md) 6/6 完成。保留原 round 03 的 accepted 关闭；[完整发行前独立审查](2026-11-23-round-04.md)通过，建议交付质量 5/5，相关累计 verdict 为 4。本次未发现需要追加产品修复的问题。

两个主规范保留旧内容与 Purpose，按归档 delta 新增四项 Full 要求及一项 Lite 要求。主规范 strict 为 2/2，归档校验为 21/21；六个变更文件（含 `.openspec.yaml`）均已归档，当前无活动变更。Review 保留原路径和 verdict 历史。

## 提交与脱敏

提交规范 Full/Lite 引导、成对 README／操作指南／CHANGELOG、同步后的主规范、仅源码的提案与 Review 归档／导航、发行版本引用和经验证的 snapshot。README 下载示例、开发／OpenSpec 基线、snapshot 生成器默认值及公开包冒烟期望均为 1.11.3；两个可执行脚本仅修改版本字面量。独立发行预检子代理核对了这些交付元数据和选定的相对 Markdown 链接，未发现阻断问题。

`.ai/`、生成宿主工具、`.agents/`、`.codex/`、工具缓存、原始日志、临时夹具和安装备份不入 Git。变更公开文件未命中常见凭据赋值或私有业务源码路径；round 01/03 的本机 CLI／源码／临时目录位置已中性化，保留发现、verdict、计数、命令参数和证据哈希，原文件留在忽略的本地证据中。扫描属于启发式检查；MIT 与第三方声明继续适用。

## 候选包与实际检查

干净候选包从源提交 `6bf3e1a1dc4a91f3ae78df66c2246af31e037b81` 经 `git archive` 导出，在暂存副本执行 `update-snapshot.ps1 -Version 1.11.3 -ForRelease`。共 78 项清单（不含 snapshot.json 自身），1,315,587 字节；snapshot SHA256：`BE2700101C954C59675F841F968CB004D58BB0286A11729DEDD8C38A941BAE72`。

| 检查 | 实际结果 |
| --- | --- |
| 精确包清单 | 路径、字节长度和 SHA256 相符；无私有／工具目录、OpenSpec、源码 Review 或仅源码样例。 |
| PowerShell 7.6.10 与 Windows PowerShell 5.1.26100.9818 公开包冒烟 | 均退出 0，各七次生命周期调用覆盖安装／状态／版本／doctor／卸载及漂移零写入拒绝；明确跳过可选冻结 1.6.1 夹具。 |
| 双宿主 1.11.2 升级到 1.11.3 保护检查 | 均退出 0，各 16 次真实调用和 47 项断言，覆盖 Full/Lite、引导与生成 Codex Skill 更新、配置／目标／模式保留、项目配置／证据／入口外文本、只读状态／版本／doctor、重复升级、漂移零写入拒绝和卸载。均使用虚构可丢弃目录并已清理。 |
| 历史新增人类文档夹具 | stock `preexisting-same-bytes-preserved` 在双宿主失败：它把新文档直接覆盖到旧 manifest 已管理的文档，制造漂移，管理器正确拒绝。该夹具假定旧版尚未管理此文档，不适用于本次版本对。已用上行精确迁移检查替代，未修改产品代码或弱化归属保护。 |
| 独立契约及元数据检查 | 完整实施和映射验收审查通过；有界发行核对确认增量归档同步、版本字面量及选定链接。 |

原始日志及实际执行的一次性迁移脚本保存在 Git／安装包外，保留输入指纹。后续仅在本地增加清理碰撞保护，未改变已执行的产品检查步骤；实际执行的原脚本另行保留。仅拷回已验证的生成 snapshot；发布前须重新导出最终提交，确认同一精确清单与 snapshot。附件为带单一 `engrelay-1.11.3` 根目录的 ZIP 和独立 `SHA256SUMS`。

| 本地证据 | SHA256 |
| --- | --- |
| PowerShell 7 公开包冒烟 | C46DB1590F2C40963AE24B9D980BD60877CF405394918C24133E6A095797E919 |
| Windows PowerShell 5.1 公开包冒烟 | A016DCB558DF44C6F6F65A3A556DD97408570DACFF8A5AF8AAC43090E60DD3D8 |
| PowerShell 7 保护升级 | 77AFAA035054C269FCBFEE1E01E9D3D7F0E0BE58E808BDFE3BD0F68325C57DAD |
| Windows PowerShell 5.1 保护升级 | C3E9777F3FA8D9F1F0ED6F722C0350AB24499530F17D0FE2ACE35A09C5F1D3F9 |

## 验证限制

检查覆盖已审文本契约及实际可丢弃包生命周期，不证明真实宿主加载／遵从、运行时 token 节省、所有平台行为、真实项目安装或业务验收。本次未安装或部署到真实项目。
