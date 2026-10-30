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
| Lite executable handoff limits, fence parsing and published guidance | Owner-selected project fixes F1/F2/F5 | Completed | [Archived proposal](changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md); [archived tasks](changes/archive/2026-10-30-harden-lite-handoff-validation/tasks.md); [review index](../docs/reviews/harden-lite-handoff-validation/index.md); independent pre-release review PASS at cumulative round 5 |
| SetMode failure recovery (F3) | Owner-selected follow-up | Confirmed, pending implementation | [Scoped follow-up](changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md#follow-up-work); separate change not yet created; preserve current entry/manifest inconsistency evidence |
| Trusted v2 layout evolution (F4) | Owner-selected follow-up | Confirmed, pending implementation | [Scoped follow-up](changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md#follow-up-work); separate change not yet created; resolve before a release adds or retires managed paths |
| Lite / Full profiles in one repository | Owner-selected integration direction | Completed | [Three-phase plan](roadmaps/lite-full-integration.md); [archived proposal](changes/archive/2026-10-24-integrate-lite-full-profiles/proposal.md); [archived tasks](changes/archive/2026-10-24-integrate-lite-full-profiles/tasks.md); [review index](../docs/reviews/integrate-lite-full-profiles/index.md) |
| Estimation definition reachability and lean rules pilot | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-21-link-sizing-guidance-and-pilot-lean-rules/tasks.md); [review index](../docs/reviews/link-sizing-guidance-and-pilot-lean-rules/index.md) |
| Lean progress summaries and handoff capability output | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-20-improve-lean-progress-and-capability-handoff/tasks.md); [review index](../docs/reviews/improve-lean-progress-and-capability-handoff/index.md) |
| Bounded context reading, evidence examples, and review delivery feedback | Owner-selected M batch; post-close audit completed | Completed | [Archived tasks](changes/archive/2026-10-25-improve-context-and-review-feedback/tasks.md); [review index](../docs/reviews/improve-context-and-review-feedback/index.md); [2026-10-25 audit](../docs/reviews/improve-context-and-review-feedback/2026-10-25-release-audit.md) |
| Automatic process statistics (P2) | Owner follow-up discussion | Pending decision | Not an implementation commitment; pilot evidence deferred entry ([pilot evidence](../docs/reviews/link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md#decision-1-p2-entry-criteria-automatic-sizing--statistics)) |
| Broader context consolidation and redundant prompt reduction | Pilot findings (Decision 2) | Pending decision | This change completes only bounded reading guidance and related feedback; remaining consolidation and prompt/schema work is not committed. See [pilot evidence](../docs/reviews/link-sizing-guidance-and-pilot-lean-rules/pilot-evidence.md#decision-2-context-consolidation-prompt--schema-lean-guidance) |
| Handoff capability tiers C1–C5 | Owner-selected M batch | Completed | [Archived change](changes/archive/2026-10-18-add-handoff-capability-guidance/tasks.md); [review index](../docs/reviews/add-handoff-capability-guidance/index.md) |
| Closure evidence rules and this navigation | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-18-clarify-closure-and-follow-up-tracking/tasks.md); [review index](../docs/reviews/clarify-closure-and-follow-up-tracking/index.md) |
| Autonomous continuation and human-action summary | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-18-fix-autonomous-continuation/tasks.md); [review index](../docs/reviews/fix-autonomous-continuation/index.md) |
| Handoff persistence at authorized boundaries | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-19-fix-handoff-persistence/tasks.md); [review index](../docs/reviews/fix-handoff-persistence/index.md) |
| Handoff recovery hardening | Owner-selected M batch | Completed | [Archived tasks](changes/archive/2026-10-19-harden-handoff-recovery/tasks.md); [review index](../docs/reviews/harden-handoff-recovery/index.md) |
| OBS-01: ordinal batch comparison in owner-extension parsing | Round 03 observation | Pending decision | [Review index](../docs/reviews/fix-handoff-persistence/index.md#deferred-follow-up); Task Intake must decide scope before implementation |
| Self-contained demo sample | Route-planning discussion; [Phase 0 non-goals](changes/archive/2026-10-17-improve-phase0-first-trial/proposal.md#non-goals) | Pending decision | Link documents deferral only, not a full roadmap |
| Phase 0 / G0 external trial | Owner phase goals (discussion) | Pending validation | Not started; package checks are not external trial |
| Quickstart troubleshooting and full walkthrough | [Release 1.9.0 review](../docs/reviews/release-1.9.0.md) | Pending validation | Explicit untested scope in that record |
| Phase 1–3 roadmap | Owner external planning (not published in this repo) | Pending decision | Select scope from latest trial facts; no fabricated change IDs |
