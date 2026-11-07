# 发行前完整审查 — support-manual-multi-platform-relay

## Metadata

- 日期：`2026-11-07`。
- 审查角色：独立 Code Reviewer；审查者 `Codex /root/manual_relay_full_audit`，未参与原设计或实施。
- 持久化：审查者只读返回完整结论，由父代理保存和更新索引；父代理不代替审查者作 verdict。
- 原实施批次：`engrelay-user-directed-relay-20261106-01`；原首轮 PASS、1/3 计数与 accepted 关闭快照保留。
- 本次范围：负责人明确要求的一次关闭后完整审查；本轮是新增 1 个 verdict，关联历史累计 2，不重开原批、不自动授权新的三轮修复周期。
- 基线 HEAD：`9dea02bdc0c18269eb3d2ff44b4db0bc9ac8ed9b`。受审为相对该基线的 29 个变更文件，包含暂存与新增文件；没有未暂存或未跟踪文件。
- 受审文件清单 SHA256：`DCA5766190860BDB73D4AAD5178246D5B8099740519252587F9A82AD00293FCC`。算法：按 `git diff HEAD --name-only` 输出顺序，每行 `相对路径<TAB>文件大写 SHA256<LF>`，UTF-8 无 BOM。父代理在保存本记录前独立复核相同值。

## Scope and evidence

覆盖 proposal、design、两份 delta、唯一 tasks.md、完整产品差异、Full／Lite 规范、双语说明、既有 round-01、隔离升级摘要及具名场景记录。实际执行 `git diff HEAD --check`、`openspec validate support-manual-multi-platform-relay --strict --no-interactive`，均 exit 0；这是格式与规划结构检查，不证明宿主行为或验收。审查只读，没有修改产品或执行真实项目安装。

- 场景记录：`.ai/manual-multi-platform-relay/scenario-checks.md`，SHA256 `12A5AB52ECFF681FD99F67A1F6F2116C3F7D523375766ACE4743B8154ED3CAFB`。
- 升级摘要：`.ai/manual-multi-platform-relay/upgrade-check.log`，SHA256 `5622F7171EDD8218B409821BDAD42057C9A57485D55E0EFE6627050673466F76`。
- 原关闭 handoff：`.ai/handoff.md`，SHA256 `F682970E03B7FD8BF9E0D259D948B1EB048C270C30F9921803B8569AD8824A3E`；本轮不改写原关闭快照。

## Findings

### PR-01 — must-fix / P2：升级证据不能对应受影响入口及候选包

定位：`openspec/changes/support-manual-multi-platform-relay/tasks.md` 3.1；`.ai/manual-multi-platform-relay/upgrade-check.log`。

清单要求可信完整来源、隔离候选和受影响受管入口的升级、保留及漂移拒绝证据。当前日志只有 Lite 安装／升级摘要和布尔结论，没有旧包与候选包身份、版本、完整清单核对、候选字节指纹、实际命令及完整拒绝诊断；原临时项目已不存在。Full 的 `agent-rules.md` 也发生变化，没有对应 Full 升级证据。配置文件的单个 SHA256 无法确定测试所用包。首轮复用结论因此不足以证明 3.1 对应当前候选。

最小处理：使用可核验的完整旧来源和当前候选，在隔离夹具中仅核对受影响入口、项目内容／模式保留和漂移拒绝，保存命令、退出码及输入指纹；不能取得的部分明确标为未验证，并协调受影响的完成声明。无需重跑无关生命周期。

### PR-02 — must-fix / P2：场景结论超出可检查来源

定位：`.ai/manual-multi-platform-relay/scenario-checks.md` 第 11、14、16 行；`tasks.md` 3.2；`2026-11-07-round-01.md` 的审查依据与结论。

场景表声称 Agent 已停止、没有运行接收者及回合已结束，但明细只有 `Passed: True`，没有对应的具名输入、命令、可检查输出或执行来源；其他场景也使用已发生行为的表述。末尾的静态推演限制不能使这些具体结论自动成立。首轮审查将其称为“9 场景真实判定”，也超出可追溯依据。现有结构校验通过只能说明结构和声明值，不能证明实际 Agent 遵守停顿。

最小处理：用具名虚构输入、预期路由和可检查输出补齐有界场景，清楚区分推演、实际结构检查和未观察到的 Agent 行为，并协调受影响的完成与审查说明。可用现有校验器对真实虚构交接夹具检查退出码、预期值和输入不变；无需只匹配文案的测试，也不必为通过而强制调用真实多宿主 Agent。

### PR-03 — must-fix / P2：Lite 缺少非共享工作区资料入口指导

定位：`payload/docs/ai-collaboration/lite/RULES.md` 人工接力规则；`openspec/changes/support-manual-multi-platform-relay/specs/workflow-profiles/spec.md` 的 `Tool cannot access the live Lite workspace` 场景。

用户在 Lite 中选择无法访问当前项目的工具时，Lite 短规则和双语 README 未说明只提供经用户审核的必要资料。既有只读返回及来源匹配规则处理的是返回发布，不覆盖输入资料的提供。Full 手册和 operator guide 虽有该说明，但 Lite 固定部署集合不包含它们；不能用 Full 文档代替已安装 Lite 的自包含入口。

最小处理：在 Lite 自包含规则及适用双语指南中补齐非共享工具所需的最小、经用户审核资料和未持久化说明，继续复用已有来源匹配；不新增机器字段或强制上传。

## Conclusion

- Verdict：**FAIL**。当前不能确认本提案已满足本次发行前完整审查；归档、提交和发布的条件未满足。
- 共 3 项 must-fix。不存在 OpenSpec 对“必须新增自动化测试”的独立要求；具名输入、可检查输出及证据分类不足合并为 PR-02，不重复计数。未经观察的真实多宿主遵循可保留为未验证，不因此强制追加演练。
- 其他范围未发现高置信的机器字段、路径、枚举、独立性或关闭后授权缺陷。当前建议仅针对发现及受影响范围检查，不要求重复所有历史测试。
- 本次实施交付建议 **3/5**，依据为规范漏项和必要证据不足；实施、证据生成与既有审查判断的具体归因不足以确认。该建议不推断模型能力，不替换原首轮 5/5。
- 本次仅一次关闭后审查；原 accepted 关闭快照和首轮 PASS 不改写。修复、复核及后续发布另按适用授权和已有累计计数处理，不自动取得新一轮额度。
