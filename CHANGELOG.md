# Changelog

[Simplified Chinese](CHANGELOG.zh-CN.md)

## 1.10.0 — 2026-10-24 (local release candidate)

Not pushed or published. The latest published GitHub release remains 1.9.6.

- Adds fixed Lite/Full profiles in the shared protected manager, manifest v2,
  trusted v1.9.6 Full Upgrade conversion and retained Lite project configuration.
- Adds Lite short rules, templates and read-only state/diagnostic tools with
  isolated runtime, independent reviews, cumulative limits and explicit sources.
- Keeps Full as the new-install default, preserves existing profiles and rejects
  implicit switches, private Lite adoption and unsupported discovery targets.
- Manifest v2 is refused by the original v1.9.6 manager. Keep matching managers
  and recovery material; Upgrade, repeated Install and SetMode do not switch profiles.
  Lite supports only SkillTarget none and provides no process wake-up or automatic
  migration of unfinished tasks.
- Adds focused PowerShell 5.1/7 subprocess fixtures and completes bounded actual-agent
  S/M/H, handoff and queue exercises. Independent implementation verification and
  final candidate review passed. Sixteen candidate lifecycle processes covered
  Full/Lite Install, CheckVersion, Status and Uninstall across both PowerShell hosts;
  diagnostics made no changes and uninstall preserved project-owned content.
- Reuses earlier upgrade/refusal and protection evidence only for matching inputs.
  Fictional samples on observed hosts do not establish all-host/model adherence,
  business acceptance, zero omissions, token/latency savings or causal improvement.
  The 86.3% comparison concerns static AGENTS.md bytes only. A committed clean export
  and matching snapshot are required separately; this entry does not certify export,
  proposal archival or publication.

## 1.9.6 — 2026-10-21

- Adds single-line anchor references to the shared `README.md#optional-sizing-and-effort`
  definition from Chief Designer Focus and Implementation Engineer's material effort
  change sentence, enabling estimation-aware roles to reach the shared guidance without
  expanding required reading or copying interval tables.
- Aligns `ai-collab-start` step 4 wording to use `Initial role` instead of `the first role`.
- Conducts an empirical pilot across lean-rule and sizing reachability scenarios (S1–S7)
  to record agent observations, required-reading context, and tool invocations for P2 and
  context-consolidation decision inputs.
- The independent review passed at round 7; the cumulative review history remains
  7/7 and was not reset. P2 process statistics and context consolidation remain pending
  decisions. Primary-host S5–S7 samples were unavailable and Codex substitutes were
  used; both baseline and candidate located the existing sizing guidance. The limited
  sample does not establish performance improvement or causal effect.

## 1.9.5 — 2026-10-20

- Makes the advisory capability line a required output for a new agent dispatch: the
  first `Current Status` line states the `Cn` tier and the final reply echoes it. The
  value is a suggestion, not a gate; older handoffs without the line stay valid and are
  not backfilled. Entry skills, Common Preflight, operator guides and both README
  editions now say so.
- Adds optional rough sizing (L1–L5 for product source) and human-effort guidance to
  Process Metrics, and states that progress is judged by new evidence rather than by a
  handoff count. Sizing never gates routing.
- Removes the optional-line ambiguity from the README and operator-guide capability
  wording.
- Confirms the `improve-lean-progress-and-capability-handoff` change in OpenSpec
  navigation. Automatic process statistics remain deferred.
- Independent review passed; CR-01 was verified. The runtime validator and manager
  bytes are unchanged, and historical suites were not rerun for this change.

## 1.9.4 — 2026-10-19

- Narrows source-matched recovery. Candidates are only review records named by the
  review index and result or response files that the live handoff (including Next
  output files) or current task names by path; directories are never scanned. A new
  container without a real prior SHA256 is reported as missing evidence, never restored
  as pending. Only legacy index-linked review records and legacy response handoffs keep
  the no-fingerprint branch. A batch restores at most one pending transfer and restores
  none when any same-batch candidate is in conflict or lacks evidence.
- Adds a planned session end and long-check checkpoint rule to the canonical role
  rules: a same-role session end is a handoff boundary, and a long check may keep one
  checkpoint with its external log, stated as not yet passed.
- The project adoption guides explain project-owned historical statements outside the
  managed block: the project coordinates them, and package changes do not rewrite them.
- The applied check compares the Routing section and the action section of the
  transfer's Next action (Operator Command, Current Status including any
  Continuation Command, Owner Decision Brief, or Review Or Task State Impact), after
  line-ending normalization and with fence-aware section reading. Same-revision
  differences are conflicts, and two or more pending candidates are a conflict.
- Taking over an executable continue records the actual Current agent and increments
  `State revision`, so a superseded transfer compares as advanced and is not replayed.
- A read-only subagent result is published directly by the active permitted writer,
  or saved first as a recovery container in a batch-scoped result path. Existing
  result files are never overwritten, and the writer's reply states the findings.
- Recovery containers use an outer fence longer than any backtick run inside them.
- `agent-rules.md` and the generated managed heading now describe the selected
  ai-collaboration workflow instead of legacy execution. The managed-block
  replacement algorithm is unchanged; existing managed blocks keep their current
  heading until an official upgrade regenerates them.
- On each of Windows PowerShell 5.1 and PowerShell 7, recovery fixture rehearsals
  passed 47 cases and the final independent follow-up passed 17 focused cases.
  The runtime validator is unchanged from v1.9.3; its historical full suite was
  not repeated for these protocol changes. Fixture checks do not establish
  real-agent or host adherence.

## 1.9.3 — 2026-10-19

- Makes handoff persistence explicit: formal dispatches name writable handoff
  outputs and add no unsourced `.ai/` write ban; real boundaries are saved, read
  back and validated; a read-only subagent result is persisted by the active
  permitted writer, or kept as a complete response handoff when none remains.
- Adds source-matched recovery for a same-batch review or response handoff that
  the live file predates, by fingerprint and revision, without recounting or
  replaying a verdict.
- Adds optional `validate-runtime-state.ps1` expectation parameters
  (`ExpectedBatchId`, `ExpectedNextAction`, `ExpectedNextRole`,
  `ExpectedReviewRound`, `ExpectedStateRevision`). Existing calls without them keep
  their behavior; updated boundaries must pass the decided values.
- These changes add structure and stated-value checks and documented procedures.
  They do not wake processes, authenticate logs, prove host compliance, or certify
  business acceptance.
- On each of Windows PowerShell 5.1 and PowerShell 7, the full validator suite
  passed 262 cases, expected-state checks passed 33 cases, and recovery protocol
  rehearsals passed 43 cases. The legacy no-fingerprint recovery branch received
  static review only; these checks do not establish real-agent or host adherence.

## 1.9.2 — 2026-10-18

- Fixes autonomous continuation handoffs: later environment notices are neutral
  previews without a current human-action requirement; `Human Action Required`
  summarizes immediate action; executable `continue` includes a self-contained
  Continuation Command; and an active capable agent chooses its local CLI/IDE host
  within existing authorization. Real waits, independent review, and review limits
  remain enforced.
- Updates canonical entry guidance, templates, validators, and structural
  regression coverage. The affected validator suite passed 229 cases on both
  Windows PowerShell 5.1 and PowerShell 7 (39 new scenarios and 190 existing
  cases); OpenSpec strict validation, whitespace checks, and the scoped local-link
  check also passed. Independent follow-up review verified the identified
  must-fix findings and the response-handoff template consistency correction.
- These checks cover protocol structure and compatibility. They do not certify
  natural-language authorization, real CLI/IDE adherence, automatic process
  wake-up, real-project deployment, or business acceptance.

## 1.9.1 — 2026-10-18

- Documents evidence-backed ordinary `accepted` closure: finalize handoff inputs,
  run the existing structure validator on those inputs, and record command,
  exit code, diagnostics, and input correspondence in external evidence without
  writing validation output back into the validated handoff. Adds paired
  English/Chinese follow-up navigation under source OpenSpec READMEs. These
  rules are agent duties only; they do not change validator algorithms or add
  machine fields. The independent round-three review verified the technical
  fixes, and the batch converged to ordinary `accepted` closure with matching
  external evidence and a successful final structure check. These checks do not
  certify log authenticity, agent or host adherence, or business acceptance.

## 1.9.0 — 2026-10-18

- Adds advisory C1–C5 capability tier guidance on agent dispatch: one line under
  handoff `Current Status`, fixed next-role defaults, and concise bilingual
  operator/README entry points. Tiers are manual model-selection hints only; they
  do not add machine fields, qualification gates, or host loading proof.
- Clarifies dotted OpenSpec task references and file-only handoff evidence in
  canonical templates and the handoff schema; check commands, outputs and exit
  codes belong in result files.
- Adds paired first-trial Quickstarts and README links covering a Git baseline,
  PowerShell 7, explicit activation, A/B handoffs, two Windows troubleshooting
  cases, and trusted offline package checks. Host troubleshooting and the
  complete-package inventory/hash walkthrough remain untested; these documents
  do not establish host loading or business acceptance.
- Adds a capability overview and a short task-flow example to both README editions.
- Clarifies the distinction between selectively adapted Compound Engineering
  Skills and unbundled Superpowers references, with a pinned Superpowers license
  reference and redistribution notice guidance.

## 1.8.0 — 2026-10-16

- Makes `ai-collab-start` the recommended entry while keeping
  `ai-collab-requirements`; start reuses the conditional Requirements Analyst
  contract in the same session when business ambiguity requires it.
- Selectively adopts applicable Compound Engineering review and debug rules
  (PR 1791/1792/1852) without importing upstream lifecycle, taxonomy, or
  transport features.
- Adds paired human documentation for operators, adoption, hosts, contributing,
  development, changelog, licensing, OpenSpec navigation, and review index;
  deploys four new managed human guides under `docs/ai-collaboration/`.
- Registers exact layout transitions for public v1.7.0/v1.7.1 packages and adds
  a focused protected lifecycle fixture for the new human guides.

The reviewed 63-file candidate passed the focused lifecycle scenarios on Windows
PowerShell 5.1 and PowerShell 7, including upgrade, preservation, refusal, and
uninstall cases. OpenSpec strict validation and whitespace checks passed. These
checks do not establish live Agent behavior, host loading, real-project
deployment, or business acceptance. C1–C5 handoff capability guidance remains
outside this release.

## 1.7.1 — 2026-10-15

- Adds first-install guidance showing the selected SkillTarget, the target project's
  canonical Skill path, and the discovery directory when applicable.
- Clarifies that the default `none` installation supports direct canonical Skill
  reading; new Codex installations can explicitly choose `agents`, with `codex`
  retained for compatibility.
- Keeps the original PowerShell success stream and exit behavior; additional
  guidance uses the information stream and can be suppressed with `6>$null`.
- Updates both README editions, adds an English maintainer starting prompt, and
  archives the completed OpenSpec change and three Review rounds in the source.
- Verifies focused guidance, lifecycle protection, and v1.7.0 upgrades on Windows
  PowerShell 5.1 and PowerShell 7 using disposable fixtures.

Host loading, real-project deployment, and business acceptance remain separate
checks. C1–C5 handoff capability guidance is not included in this version.

## 1.7.0 — 2026-10-14

- Introduces the public EngRelay name and English/Simplified Chinese README editions.
- Preserves ai-collaboration installation identifiers and existing managed upgrades.
- Removes private project snapshots, runtime evidence, workstation setup, and old
  Git history from the proposed public distribution.
- Applies the MIT License to original material and retains third-party notices.
- Provides a complete package inventory and focused Windows PowerShell 5.1/7 evidence.

This is the first EngRelay public release, derived from the local 1.6.1 package.
Earlier local packages are not represented as historical GitHub releases.
Package fixtures do not establish real-project deployment, host loading, or
business acceptance.
