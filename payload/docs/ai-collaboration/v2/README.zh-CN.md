# EngRelay v2

[English](README.md) · [规则](RULES.md) · [Skill](skills/engrelay/SKILL.md)

EngRelay v2 是面向 OpenSpec 变更与多平台小额度订阅的极简跨平台接力配置。它用三步闭环（`plan`、`do`、`review`）、正交的风险门禁（`S|M|H`）与能力/体量评估（`C1–C5` × `XS|S|M|L`）以及两轮硬断路器，替代繁琐的角色流转与逐次校验脚本。

## 安装

在目标项目之外的完整可信包目录中执行：

```powershell
& ./scripts/manage.ps1 -Action Install -ProjectRoot $project
# 如需同时复制单一宿主 Skill：
& ./scripts/manage.ps1 -Action Install -ProjectRoot $project -WorkflowProfile v2 -SkillTarget cursor
```

未安装项目默认启用 `WorkflowProfile=v2`、`WorkflowMode=optional`、`SkillTarget=none`。已安装 `full` 或 `lite` 的项目在 `Upgrade` 和 `SetMode` 时保留各自原有配置。

## 日常三步流程

1. **拆包编排（`plan <change-id>`）**：读取 OpenSpec 并检索一次 `docs/solutions/`，生成 `.ai/relay/<change-id>/board.md`，切分不超过 `L` 的独立 WP，抽取 `Global Constraints`、`Interfaces` 与仓库/diff 边界，并标注 `风险 (S|M|H)`、`难度 (C1–C5)` 及 `体量/节奏 (XS|S|M|L × 可断点|建议连续)`。
2. **连续实施与断点（`do <WP-XX>`）**：由所选平台原生完成实现、测试与 diff 精简。额度不足时在 `wp-XX.md` 追加 ≤15 行断点即可换平台续跑，不触发审查。仅当风险保持 `S` 且无显式审查要求时，自测通过后直接标为 `[x] done`。
3. **有界独立审查与验证（`review <WP-XX>`）**：`M`、`H`（含修复后独立验证）及显式要求审查的 WP 必须由独立于实施/修复者的会话执行（优先不同模型家族，异构不可用时同家族真正独立会话可承接并记录实际工具/模型）。最多 2 轮，第 2 轮拦截新引入的实质 P0/P1 回归，未通过或重复失败签名立即标为 `[~] blocked` 并隔离依赖项。

## 接力手感

- 审查会话只可写 `.ai/relay/<change-id>/`、显式提案名或唯一看板回退时的 `.ai/relay/CURRENT`，以及映射验收已全部满足时的 `tasks.md`。它不修改产品源码、配置或测试。出现 `FIX REQUIRED` 或已记录的 `(a)` 授权后即停止。修复会话执行 `do <change-id> <WP-XX>`，同一审查会话可以接下一次复核。
- `plan`、`do`、`review` 结束时给出 `Next Step` 卡，正文固定五行：`Primary`、`Command`（或 `Wait`）、`Axes`（风险、难度、体量/节奏）、`Gate` 或恢复条件、`Alternate`（没有则写 `none`）。只有一个首选动作。给其他会话复制的命令始终带上提案名。未获授权的产品或上限阻塞，以及恢复条件尚未核验的环境阻塞，对该 WP 使用 `Command: Wait`。
- `.ai/relay/CURRENT` 保存一行提案名。显式提案名优先，并在本次调用内锁定。回复首行是 `Change: <change-id>`。有效指针存在时，简写 `do WP-XX` / `review WP-XX` 按该指针解析，即使同时有多块看板。指针缺失或失效且看板多于一块时，列候选并停止。该文件本身不会激活 EngRelay。

## 诊断与归属

- 只读诊断：`& ./docs/engrelay/scripts/doctor.ps1 -WorkspaceRoot $PWD.Path`
- 项目自有配置：`docs/engrelay.config.md`（`Upgrade` 与 `Uninstall` 保留；留空不阻塞规划，但不得跳过必需验收）
- 运行态目录：`.ai/relay/<change-id>/`（不入 Git，与旧版 `.ai/handoff.md` 和 `.ai/engrelay-lite/` 隔离）。`.ai/relay/CURRENT` 是同一被忽略目录中的单行活动提案指针。`doctor.ps1` 只读取它，不创建、不修复、也不删除它。
