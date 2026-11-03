# Tasks

唯一实施清单；原批 `engrelay-review-closure-evidence-20261103-01` 为 M，规划时累计 verdict 0/3。设计规划与结构校验不计 verdict，旧批历史不改。首个实现会话可完成第 1 组，随后作有界集成核对及独立审查；不是两个新批次。实现者只能勾选有实际证据的实现／自检项，不能提前完成独立审查和关闭。

## 1. 现有规则、示例及对应人类说明

- [x] 1.1 在 Full 现有 README 集中明确完整审查、证据对应、产物隐私、后续复核／扩大条件、关闭后有限授权和归档结束；在 agent-prompts、workflows、review-round 模板加必要短引用／提示，同步 operator-guide 两种语言；按 design 的 场景1／3 取得实际 Agent 判定及输入／候选规则对应，检查旧场景、角色独立性和现有锚点保留，不新增字段或角色。
- [x] 1.2 在 Lite RULES 及 task 模板实现等价自包含规则，同步 Lite README 两种语言；按 场景2／4／5 保存实际 Agent 判定和脱敏产物，检查适用交付副本不含虚构私有标识、局部修复不重跑无关套件、单次追加不变成新三轮授权且归档核对通过即结束；不依赖 Full 手册或新增模板。
- [x] 1.3 同步根 README 两种语言及 CHANGELOG 两种语言的 Unreleased 说明，引用当前实际能力和已取得检查，不升版本、不声称已发布／节省固定 token；核对双语对应、链接及公开说明与两配置规则一致，复用未变输入下的场景结果。

## 2. 有界集成核对与证据交付

- [x] 2.1 将第 1 组五类场景的真实输入／输出及候选规则对应整理为源码专用 `docs/reviews/improve-review-closure-and-evidence-quality/scenario-evidence.md`，原始虚构输入和运行日志保留在 `.ai/review-closure-evidence/`；核对 Full／Lite 边界一致、场景4 两个变体及 场景2 交付副本，相关规则变更后仅重做失配场景；明确这些自检不代表虚构业务的独立 verdict、实际安装或全宿主遵从。
- [x] 2.2 对实际候选 diff 核对受管文件集合、机器字段／锚点和许可未扩张，运行 `git diff --check`、本变更 `openspec validate --strict` 及受影响引用／语言／脱敏检查；将命令、退出码、实际结果和限制记入 `.ai/review-closure-evidence/implementation-result.md`，不以措辞匹配测试、结构通过或无关全量回归代替行为证据。

## 3. 独立聚合审查及真实关闭

- [x] 3.1 由独立于实施／修复者的 Code Reviewer 完整审查本批全部验收、实际差异、五类场景来源与产物、Full／Lite 和双语一致性、额度及交付隐私；新建当次 round 文件并维护 index，一次聚合实际问题并按既有交付评分给出建议，记录实际累计 verdict，不把场景自检算成额外正式审查（2026-11-03 round-01 PASS，累计 1/3，无 must-fix）。
- [x] 3.2 如有已确认问题，在原范围与剩余额度内集中修复，再取得独立的缺陷／受影响行为复核；修改影响扩大则扩大检查，额度不足走现有有限授权出口。无须修复时直接引用已有 clean verdict 说明本项不需额外循环，不制造复述审查或改写旧评分（原 round-01 无指派发现，引用当时 clean 结论；关闭后追加审查发现 PR-01–03，2026-11-03 独立纠错复核 PASS，累计 verdict 3，PR-01–03 verified）。
- [x] 3.3 按真实验收和独立审查状态收尾唯一清单、场景摘要及 handoff，保留所有未验证限制和历史；保存并回读最终状态，以已决定的 batch/action/role/review/revision 校验并将命令／退出码／输入对应记在外部证据，满足条件才关闭，不提前归档或重建发行快照（原实施批 close、revision 4、round 1 的历史不改；本次纠错复核 PASS，父代理保存并回读 close／round 3／revision 8 的最终状态，以外部日志核对收尾校验）。

## Workflow follow-up

- 原实施时不授权提案／Review 归档、Git 写入、推送、Release、真实安装或全局配置；后续负责人已另行要求审查通过后归档、提交和发布，真实安装及全局配置仍不在范围内。
- 关闭后追加完整审查为历史累计第 2 个 verdict（FAIL），发现 PR-01–03；负责人授权一次集中纠错和一次独立复核。纠错依据见 `docs/reviews/improve-review-closure-and-evidence-quality/scenario-evidence.md` 与 `.ai/review-closure-evidence/correction-result.md`。1.1、1.2、2.1 的五类场景实际返回、场景2交付脱敏及 2.2 的完整候选检查已补证，待本次独立复核确认。场景自检不是正式 verdict；原 round-01 关闭记录和评分保留，不重置历史累计数。
