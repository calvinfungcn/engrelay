# Proposal

## Why

v1.9.5 已把可选 L1–L5 与人工投入定义集中在 canonical README 的 `#optional-sizing-and-effort`，但没有任何角色入口、模板或入口 Skill 引用该锚点；Chief Designer 的必读清单也不含它。按既有锚点阅读护栏，需要估算的角色很可能读不到这一定义。上一批的子代理抽查明确指示读取该段，因此未覆盖可达性。

同时，团队实施方案的 P0 行为（未来设想不进入当前必做、获授权抽象被保留）、无可解释进展的负面场景、Review round 上限下的叠加行为，以及提示词上下文开销，至今只有文本对照或没有证据。P2 自动统计按方案须以试点证据为进入条件，目前尚无此证据。

## What Changes

- 在 Chief Designer 角色卡及 Implementation Engineer 已有的“投入实质变化”说明中，以一行锚点短引用唯一共享定义；不复制区间、不扩大必读范围、不要求小任务估算。
- 将 `ai-collab-start` 第 4 步的 “the first role” 统一为模板字段名 `Initial role`，不改变路由语义。
- 用实际可用 Agent，在可丢弃的虚构夹具中开展一次有界试点取证：覆盖方案 T01–T08 中尚缺行为证据的场景，并对估算可达性作改动前后对照；同时记录各角色的必读上下文量与工具调用，作为 P2 和上下文精简的决策依据。
- 依试点结果更新双语 OpenSpec 导航与 CHANGELOG 的 Unreleased 记录；P2 及可能的上下文精简仍为待决定，不由本变更实施。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `collaboration-package`：`Optional task sizing without routing gates` 增加角色入口可达共享定义的要求，不改变估算可选、省略及与风险独立的既有语义。

## Impact

产品字节仅涉及 `payload/docs/ai-collaboration/agent-prompts.md` 的两处短引用与 `skills/ai-collab-start/SKILL.md` 的一处措辞；不改模板、validator、安装管理、恢复算法或机器字段。源码侧涉及本变更工件、双语 OpenSpec 导航、双语 CHANGELOG 及 `docs/reviews/` 下的试点与审查记录。根 README 的公开行为描述不变，因此不修改。

变更风险为 M，保留一次独立代码/协议审查。试点只在 GUID 命名的临时目录中使用虚构输入，不是安装，也不等同于 Phase 0 / G0 外部试用；它不证明宿主加载或模型零遗漏。本变更不授权提交、发布、快照重建、真实项目安装或全局设置修改。
