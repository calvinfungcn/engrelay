# Changelog

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
