# Tasks

## 1. 环境预告与自主接续契约

- [x] 1.1 更新 handoff schema 和模板：人类介入摘要、远期中性预告、可执行 continue 接续块；检查等待、派发、关闭及响应 fallback 的规则相容。
- [x] 1.2 同步 agent-prompts、workflows、产品 README、agent-rules 和规范 ai-collab-continue 入口：先判断真实阻塞再自主接续，禁止普通宿主选择请示；检查旧记录、角色独立性、并发归属和审查上限边界。
- [x] 1.3 同步双语项目 README、操作者说明和 Unreleased CHANGELOG；核对语言对应、示例可理解及无自动唤醒承诺。

## 2. 校验器与兼容回归

- [x] 2.1 先增加子进程失败用例：新摘要枚举/重复/矛盾、接续块结构/位置/等待禁用、needed=no 的 none 行动、即时阻断；记录原校验器对新增用例的失败。
- [x] 2.2 实现增量结构检查及环境字段条件校验，保留旧记录缺字段兼容；运行新增定向用例直至通过。
- [x] 2.3 在可丢弃目录运行 Windows PowerShell 5.1 和 PowerShell 7 的本校验器完整回归，并执行 OpenSpec strict、受影响 Markdown 链接及 diff 检查；记录命令、退出码、范围和未验证限度。

## 3. 独立审查与收尾

- [x] 3.1 完成一次独立 M 代码/协议审查并修复实际发现；将证据写入 docs/reviews/fix-autonomous-continuation，不重置审查计数，不重复无关检查。
- [x] 3.2 按最终差异核对验收及变更任务；交付提案、实现、验证依据，清楚说明未发布及保留的宿主验证限度。
