# Relay Board: <change-id>

- OpenSpec: `openspec/changes/<change-id>/` (`proposal.md`, `design.md`, `specs/`, `tasks.md`)
- Progress Ledger (append 1 line per completed/blocked WP; retain cumulative verdicts & failure signatures per unfinished OpenSpec item):
  - `(none yet)`

## Global Constraints

1. `<Exact cross-WP contract field, column, flag, or forbidden action from OpenSpec/repo>`

## Work Packages

| WP | 模块 | OpenSpec | 风险 | 难度 | 体量/节奏 | 审查要求 | 依赖 | 状态 | 负责/审查 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WP-01 | `<module>` | `<1.1>` | `S` | `C2` | `S / 可断点` | 无（自测关闭） | - | `[ ] todo` | `-` |
| WP-02 | `<module>` | `<1.2>` | `H` | `C4` | `M / 建议连续` | 独立审查 + 修复后独立验证 | WP-01 | `[ ] todo` | `-` |

### WP-01: <Title>
- **Shape**: `<ui|backend|concurrency|integration|docs|ops>`
- **Repo & Diff Scope**: `<repo path(s); base ref/range or WP file boundary>`
- **Interfaces**: Consumes `<none or upstream contract>`; Produces `<exact API/file/schema>`
- **References**: `<docs/solutions/... or none>`
- **Deferred / Handoff**: `<none or explicit downstream WP + dependency for cross-boundary checks>`
- **Done & Verify**: `<observable acceptance + exact command(s)>`
