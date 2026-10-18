# Maintenance specification baseline

[Simplified Chinese](README.zh-CN.md)

This directory manages future EngRelay maintenance, starting from public v1.7.0.
`specs/collaboration-package/spec.md` consolidates the current contracts without
copying private history or treating old review rounds as new acceptance.

Use an active change's proposal, specs, design when needed, and tasks.md for new
work. This bootstrap creates no active product change and no live role handoff.
Do not copy the earlier private workspace's active changes or accepted batch
state into this clone. Source-only OpenSpec records are kept in Git and excluded
from installation exports by .gitattributes.

## Follow-up items

Concise status for discussed follow-ups. Detailed implementation progress stays
in each change's `tasks.md`; this table is not a second checklist or execution
authority.

| Status | Meaning |
| --- | --- |
| Pending decision | Not selected for implementation; not a commitment |
| Confirmed, pending implementation | Scope chosen; tasks live in the linked active change |
| Pending validation | Required validation evidence is missing; not approval to recruit or deploy |
| Completed | Mapped work finished with linked task and review evidence |

| Item | Source | Status | Change or evidence |
| --- | --- | --- | --- |
| Handoff capability tiers C1–C5 | Owner-selected M batch | Completed | [Archived change](changes/archive/2026-10-18-add-handoff-capability-guidance/tasks.md); [review index](../docs/reviews/add-handoff-capability-guidance/index.md) |
| Closure evidence rules and this navigation | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-18-clarify-closure-and-follow-up-tracking/tasks.md); [review index](../docs/reviews/clarify-closure-and-follow-up-tracking/index.md) |
| Autonomous continuation and human-action summary | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-18-fix-autonomous-continuation/tasks.md); [review index](../docs/reviews/fix-autonomous-continuation/index.md) |
| Self-contained demo sample | Route-planning discussion; [Phase 0 non-goals](changes/archive/2026-10-17-improve-phase0-first-trial/proposal.md#non-goals) | Pending decision | Link documents deferral only, not a full roadmap |
| Phase 0 / G0 external trial | Owner phase goals (discussion) | Pending validation | Not started; package checks are not external trial |
| Quickstart troubleshooting and full walkthrough | [Release 1.9.0 review](../docs/reviews/release-1.9.0.md) | Pending validation | Explicit untested scope in that record |
| Phase 1–3 roadmap | Owner external planning (not published in this repo) | Pending decision | Select scope from latest trial facts; no fabricated change IDs |
