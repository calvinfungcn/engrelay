# EngRelay product growth and validation roadmap

[简体中文](product-growth.zh-CN.md)

Calibrated on 2026-10-30 against v1.10.1 and source commit `a4aff94d3970e5659c121874eba3817a561ad8ca`. This updates the owner's 2026-10-17 roadmap and Phase 0 plan using current facts. The external originals remain historical planning sources.

This document records direction and stage decisions. Each formal change's tasks.md alone tracks implementation. The roadmap carries no copied checklists, runtime state or review counts and grants no automatic permission for later stages, external operations or publication.

## Product direction

Help AI coding work in existing repositories continue in a fresh session, with clear scope and evidence for review. Validate first use and repeat-use value, then choose local improvements from observed obstacles. GitHub projects inform methods; adoption must fit EngRelay's authorization, task authority, review independence and licensing requirements.

## Current facts

| Item | Status and basis |
| --- | --- |
| Eight selected Phase 0 improvements | Completed; the [archived scope](../changes/archive/2026-10-17-improve-phase0-first-trial/proposal.md) explicitly excluded the complete Phase 0 |
| Lite / Full profiles | Completed; see [integration tasks](../changes/archive/2026-10-24-integrate-lite-full-profiles/tasks.md). The first new demonstration uses Full; Lite retains its separate existing guidance |
| Handoff capability, recovery and context feedback | Completed; the [follow-up navigation](../README.md) links the relevant acceptance. This does not establish all-host or all-model adherence |
| Public sample and current-version internal exercises | Local delivery accepted after [independent review and closure](../../docs/reviews/improve-first-handoff-trial/index.md); [trial evidence](../../docs/reviews/improve-first-handoff-trial/trial-evidence.md) records two fresh `S`-level internal exercises after two earlier partial `M` runs. Sample acquisition is verified at commit [`304aa95702f106da262bcc741576293dfbeddc8d`](https://github.com/calvinfungcn/engrelay/commit/304aa95702f106da262bcc741576293dfbeddc8d); [submission preparation](../../docs/reviews/improve-first-handoff-trial/submission-preparation.md) records the fresh-clone and archive checks. See [improve-first-handoff-trial](../changes/archive/2026-10-31-improve-first-handoff-trial/proposal.md) and its [sole implementation checklist](../changes/archive/2026-10-31-improve-first-handoff-trial/tasks.md) |
| External G0 | Pending validation; local exercises, fresh-clone acquisition and package structure checks do not substitute for external first attempts by target users |
| F3 / F4 | Confirmed, pending separate implementation; see the [scope entry](../changes/archive/2026-10-30-harden-lite-handoff-validation/proposal.md#follow-up-work) |

## Stages

| Stage | Smallest useful outcome | Progression condition |
| --- | --- | --- |
| Current: complete first use | One fixed fictional task, paired guides, real A/B continuation in two new directories, and independent maintenance review | Use the active change's local acceptance; unimplemented or unevidenced work stays incomplete |
| External G0 | First attempts by three target users uninvolved in design, at least two completing without extra assistance, with two internal reproductions and key protections satisfied | Missing participants or conditions leave external validation pending; successful internal reproduction permits limited internal Phase 1 |
| Limited Phase 1 | One fresh-session continuation during coding, a risk-appropriate independent review, then an attempt with one cross-tool combination that has actual users | Record versions, inputs, results and limits; same-host results do not establish cross-tool compatibility |
| Phase 2 | Address one reproducible primary obstacle at a time, at most two local improvements in total, or decide with evidence to add none | Compare existing alternatives, minimum change, checks, maintenance cost and rollback; retest the original obstacle |
| Phase 3 | A usable feedback channel, a few real contribution tasks and a sustainable maintenance rhythm | Follow observed feedback and capacity, without quotas for Issues, PRs or features |

Prioritize a separate minimal F3 SetMode failure-recovery fix. Resolve F4 trusted v2 layout evolution before a release adds or retires managed paths; the current source-only sample adds none. Define later implementation separately and keep it outside demonstration acceptance.

## First-use distribution and status

Keep sample source, complete installation package and demonstration target separate. Obtain sample source by checking out a fixed Git commit containing it; obtain the trusted complete v1.10.1 package separately. The sample is export-ignored, so neither GitHub's automatic Source code ZIP nor the complete installation package is promised to contain it. An uncommitted candidate may use file fingerprints for local exercises; verify the real public SHA and acquisition path during authorized commit preparation.

Local accepted closure covers only mapped delivery. Keep public acquisition pending until checked and external G0 pending until performed. Ten minutes is a target for the core experience after preparation; report completion and timing separately and make no general guarantee.

## Minimal trial record

Use an anonymous ID and record version/environment, first attempt or retry, standard operations and extra rescue, result, core and total elapsed time, hardest step, and willingness to use it again. Copying the live Operator Command is standard operation; explaining requirements, operating for the user or changing inputs is extra assistance. Preserve first failures, exits and retries after revision. Mark missing data untested. Internal Agent exercises are not external users.

Collect no telemetry by default. Keep raw chats, live runtime, installation backups and private paths local; publish only necessary sanitized summaries. External contact, real projects and public material still require applicable authorization.

## Upstream methods and effort

See the [formal design](../changes/archive/2026-10-31-improve-first-handoff-trial/design.md) for pinned sources and compatibility choices. Use Superpowers' behavioral evidence, CE's concise references and existing knowledge reuse, and GSD Core's layered documentation as ideas. This round imports no upstream feature or lifecycle and adds no runtime, state store or machine field. Implementation need not repeat whole-project upstream research.

Timebox upstream comparison to 2–3 hours. Allow roughly 6–10 effective hours for the first sample, guides and internal exercises, with model waiting and external recruitment separate. Estimates inform spending only. For a material overrun or costly low-value expansion, present evidence already gained, a smaller option and a recommendation before deciding to expand.
