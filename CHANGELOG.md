# Changelog

[Simplified Chinese](CHANGELOG.zh-CN.md)

## Unreleased

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
