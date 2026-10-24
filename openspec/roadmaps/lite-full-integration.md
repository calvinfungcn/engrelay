# EngRelay Lite / Full integration plan

[简体中文](lite-full-integration.zh-CN.md)

Baseline: EngRelay v1.9.6. Reference input: user-supplied Lite 0.2.0. This document plans the selected direction; it does not report delivered functionality. Reference material is input, not a second product contract.

## Phases and implementation authority

There are three sequential phases. Phase 1 produces a reviewable protocol design; Phase 2 produces an implementation usable in disposable installations; Phase 3 produces an exercised and reviewed release candidate. These are milestones, not three required releases.

| Phase | Goal | Main outputs | Exit evidence | Relative effort |
| --- | --- | --- | --- | --- |
| 1 | Set Lite behavior and compatibility boundaries | Concise protocol design, handoff fields, scenario examples, installation and legacy-manifest design | No unresolved material compatibility decisions; positive and negative examples; required independent design review | Medium |
| 2 | Implement both profiles through the shared manager | Lite rules, templates and checks; profile lifecycle; manifest conversion; diagnostics; basic bilingual guidance | Separate disposable installs, upgrades, diagnostics and uninstalls with protection checks | High |
| 3 | Exercise usage and prepare release | S/M/H and resumption evidence, fixes, complete human guides, independent review and candidate evidence | Acceptance, required review and independent verification complete; limits disclosed; candidate inventory matches bytes | Medium |

Formal change: [integrate-lite-full-profiles](../changes/integrate-lite-full-profiles/proposal.md). Its [tasks.md](../changes/integrate-lite-full-profiles/tasks.md) is the sole implementation checklist for all phases. This roadmap describes objectives and acceptance; it does not duplicate task completion, Review counts or runtime state.

Consult the change's tasks.md and its [review index](../../docs/reviews/integrate-lite-full-profiles/index.md) for actual implementation and review evidence. Planning artifacts or acceptance of one design phase do not mean that the product or all three phases are implemented.

## Shared product decisions

1. One repository, one version, one complete distribution and two fixed profiles. The planned parameter is `WorkflowProfile=full|lite`; v1.9.6 does not implement it.
2. Profile selects the rules and installation set; `WorkflowMode=optional|default|disabled` controls activation. Neither determines S/M/H risk or C1–C5 capability advice.
3. New installs without a profile continue to use Full and optional mode. Existing valid installations retain their profile. Upgrade, SetMode and repeated Install cannot silently change it.
4. The official manager owns one profile per project, and each task uses one controller. Other tools may coexist; file presence does not activate them.
5. Full keeps its paths, role anchors, seven Skill names and host targets. Initial Lite reads its short rules directly, installs none of those Full Skills, and supports only SkillTarget=none. Other target values are rejected before writes.
6. Full keeps the EngRelay / ai-collaboration alias. On Lite, EngRelay or EngRelay-Lite selects Lite. An explicit unavailable profile or Full-only entry produces a mismatch explanation, without switching profiles or creating alternate runtime state.
7. Lite supports S/M/H without downgrading high risk. Its three responsibility categories do not mandate separate sessions, but execution, review and required H verification retain actual independence.
8. Short rules retain persisted handoffs, evidence, cumulative review limits and installation protection. Already authorized edits, technical decisions and local CLI/IDE choices do not add approval requests.

## Phase 1: protocol and examples

### Goal

Turn Lite's useful ideas into an inspectable contract and resolve known conflicts before product coding. Outputs are source-only design and fictional examples; this phase does not make Lite officially installable.

### Work

- Record input version, relevant hashes, provenance and copyright notices; prepare a sanitized behavior comparison. Do not commit the private directory, raw snapshot or private absolute paths.
- Define the small reading path: applicable project instructions, Lite rules, project configuration and the current task or queue entry; add the current handoff and named evidence on takeover. Allow relevant source, module instructions and acceptance evidence as needed rather than restricting agents to four files.
- Define owner, executor and reviewer responsibilities. S uses self-checks; M uses independent review and confirmation of mandatory fixes; H retains risk-appropriate design and independent verification. The default allowance is three cumulative verdicts, with existing finite-extension rules.
- Narrow approval gates to missing authorization, material scope, acceptance or risk changes, actual permission gaps, or materially unexpected cost. Do not reconfirm covered actions.
- Define the short handoff: task identity, revision, execution ownership, action, human-action summary, cumulative reviews, outcome and evidence, and a complete next command. Agent dispatch adds one C1–C5 line; continue, close and human decisions omit it.
- Define saving, read-back, expected-state checks and publication of read-only review results. Largest revision or newest timestamp cannot resolve conflicting state. Explain specific conflicts without building a general recovery engine.
- Define queue authorization, dependencies, separate handoffs for blocked tasks, closure and archiving. Sequential continuation applies to an active agent; it does not promise background wake-up.
- Finish profile projection, manifest conversion, safe rejection by old packages and project-configuration ownership design. Prepare scenario inputs and expected outcomes, correcting barriers before implementation.

### Acceptance and limits

The design must identify the writer, read-only result publisher, conflict behavior, eligible next task, cumulative review count, profile identity and old-manager rejection. Examples cover normal continuation, mandatory-fix confirmation, forward environment notices, blocked dependencies, stale handoff conflicts and exhausted authorization.

Required independent design review precedes the relevant implementation. No universal owner reapproval is added at each phase. Textual example checks do not prove script behavior or agent adherence.

## Phase 2: product and shared manager

### Goal

Install and maintain the selected profile without placing the entire Full reading set in Lite or maintaining a second installer with weaker protection.

### Work

1. Author canonical Lite rules, configuration, queue, task and handoff templates and a small read-only validator under `payload/docs/ai-collaboration/lite/`. Keep agent contracts and machine fields in English. Do not repeat capability tables in handoffs.
2. Extend the existing installation plan: Full keeps its set and excludes the Lite subtree; Lite maps only explicitly listed content to `docs/engrelay-lite/`, plus its managed entry and ignore rules. Do not import the private install.ps1.
3. Record profile identity and exact projection in a new manifest version. Recognize only trusted supported version=1 installations as legacy Full and convert through protected Upgrade. Continue rejecting unknown, moved, damaged and drifted records; preserve old fingerprints.
4. Old managers must reject new manifests before target writes. Retain the corresponding manager, trusted package and original recovery material; do not promise direct downgrade. Profile projection must not bypass complete-package file-set and SHA256 checks.
5. Create project configuration once from a template, then preserve it as project-owned on upgrade and uninstall. Express this explicitly in the new manifest instead of borrowing trusted legacy Adopt flags. Lite runtime uses `.ai/engrelay-lite/`, separate from Full's current-task and handoff.
6. Make Install, Status, CheckVersion, Upgrade, SetMode and Uninstall profile-aware. Preserve registered legacy Adopt support without adding automatic adoption of the private Lite layout. Repeated Install stays idempotent; conflicting profile or SkillTarget requests fail before writes.
7. Keep a single managed entry, mode precedence and edits outside the block. Diagnostics report profile, mode, ownership, readable entry and mismatches. Preserve the old Full doctor path; read-only diagnosis does not prove host loading.
8. On PowerShell 5.1 and 7, use GUID disposable roots for lifecycle, drift refusal, project-file/configuration/runtime preservation, legacy Full upgrade, failure recovery and zero-write previews. Check paths that actually support Preview rather than adding a universal lifecycle Preview API.
9. Provide basic bilingual installation, activation, continuation and diagnostic guidance, plus provenance and complete applicable notices. README and CHANGELOG describe unreleased behavior without claiming publication.

### Acceptance and limits

The candidate can be used in disposable projects. Omitted profile still gives Full; Lite installs no Full role graph or seven Skills; both profiles preserve project content during upgrade and uninstall.

Installation and manifest-conversion batches carry H impact with required design review, independent code review and independent verification. Other batches follow actual impact. Avoid an indiscriminate cross-product of every profile, host and mode.

## Phase 3: usage exercises and release preparation

### Goal

Establish that Lite requires less reading and operator work while retaining explainable continuity, independent review and installation protection.

### Work

- Exercise S closure, M review/fix/confirmation, H independent verification, cross-session continue, read-only result publication and queue dependencies/blockers in fictional disposable projects.
- Compare Lite and Full on the same tasks with an explicit input boundary: required context, human copy/decision steps, unnecessary role transitions and handoff correctness. Record actual hosts and models when agents run. Disclose unavailable runs; prewritten state is not behavioral evidence.
- Aggregate real defects and follow existing finite review/fix rules. Changing phase, model or record cannot reset unresolved work's count.
- Finish paired README, quickstart, selection, migration/recovery, maintenance, CHANGELOG and source notices. Separate human-document languages; keep one English agent contract and machine template set.
- Complete independent review and required H verification. Rerun relevant checks when causal inputs or dependencies change, not every historical suite for phase bookkeeping.
- Once an actual candidate commit exists, export it through git archive into clean staging, rebuild the complete snapshot and check inventory and bytes. Preserve old packages and disclose unverified scope; do not represent a dirty working tree as a clean candidate.
- Produce a release-readiness conclusion and copyable usage instructions. Real-project installation, external trial invitations, Git commit/push and GitHub Release remain separate operations requiring an applicable request.

### Acceptance and limits

Lite's prescribed reading set for representative tasks must be smaller than Full's without hidden mandatory Full contracts. Report actual files/bytes and context scope; report tokens only with a suitable available tokenizer. Rule line counts do not establish performance gains or zero omissions across models.

Overall completion requires protected lifecycle evidence for both profiles, representative behavior evidence, required review/verification, corresponding documentation and complete candidate-package evidence. Missing required exercises remain pending validation; structural checks alone cannot close them.

## Later candidates, outside these phases

| Candidate | This change | Reconsider when |
| --- | --- | --- |
| Automatic transfer of unfinished Full/Lite work | Preserve state; provide explicit manual checking and handoff instructions | Repeated demand and verifiable identity, evidence and count conversion |
| In-place adoption of private Lite | No automatic takeover; retain inputs and use a clean official installation path | A stable, recognizable layout with trusted fingerprints exists |
| Separate Lite ZIP or version line | One complete package and version | Distribution-cost evidence justifies it |
| Arbitrary modules or Lite Skills for every host | Two fixed profiles; explicit Lite rule reading | Specific host demand and loading-verification conditions |
| Background scheduling, wake-up, locks/heartbeat services | Excluded | A separately evaluated product requirement |
| Broad Full prompt rewrite or new statistics system | Retain existing tracking without expanding this change | Its own scoped decision and pilot evidence |

## Execution and cost

There is no calendar commitment or assumed savings percentage. Phase 2 is the largest cost because it changes manifest conversion, installation projection and protection checks. A lightweight Full reading entry would cost less but would not deliver a separate Lite installation set; the selected two-profile plan remains the implementation direction.

One responsible agent continues adjacent non-independent work. Create runtime state only when the role workflow is selected. Do not import or reopen closed batches or Reviews. Phase boundaries add no review allowance or permissions. Explain value, cost, a smaller option and the recommendation before high-cost, low-benefit extensions.
