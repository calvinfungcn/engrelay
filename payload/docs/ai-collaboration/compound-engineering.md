# Selected Compound Engineering Integration

This document defines how this workspace adopts selected Compound Engineering
capabilities without introducing a second planning or lifecycle controller.

## Activation Boundary

The package-adapted four CE Skills apply only to a task using ai-collaboration,
following README.md#optional-activation-and-coexistence. Discoverable copies or
this contract cannot select the workflow. When inactive, they add no handoff
writes, role dispatch or learning gate to another controller; use that project's
own CE capabilities. Reading these methods as reference is permitted.

For package-managed deployment, the AGENTS CE deployment override supersedes
the inherited all-target installation/check/quarantine guidance below. Use direct
canonical reading or the package manager's single optional SkillTarget.
Do not create unowned copies or disable unrelated Skills.

## Decision

OpenSpec remains authoritative for requirements, specifications, design
decisions, implementation tasks, and archive state. The collaboration standard
remains authoritative for roles, risk, review evidence, and routing. Selected
Compound Engineering Skills provide bounded execution techniques inside those
existing role actions.

The default capability set is:

| Capability | Canonical Skill | Owning role action | Default trigger |
| --- | --- | --- | --- |
| Evidence-led code review | `ce-code-review` | Code Reviewer | Required by the existing S/M/H review rules |
| Diff-scoped simplification | `ce-simplify-code` | Implementation Engineer or Fix Engineer | After focused checks pass when a meaningful code diff exists |
| Hypothesis-led debugging | `ce-debug` | Implementation Engineer or Fix Engineer | Non-obvious, intermittent, cross-layer, or previously failed defects |
| Reusable learning capture | `ce-compound` | Any closing role or a later documentation task | Only when the Learning Worthy Gate passes |

Selective upstream review baseline: [compound-engineering-v3.29.0](https://github.com/EveryInc/compound-engineering-plugin/releases/tag/compound-engineering-v3.29.0)
(2026-09-24). This workspace maintains its own four canonical Skills; the
manifest's `packageVersion` versions this local bundle, not the upstream plugin.
Import useful behavior selectively and record its source. Upstream installation
or a version-number bump alone does not update these local contracts.
This sync adopts [consequence-sized review](https://github.com/EveryInc/compound-engineering-plugin/pull/1719)
and an optional [learning retirement condition](https://github.com/EveryInc/compound-engineering-plugin/pull/1772).
It does not import the full plugin lifecycle or upstream finding taxonomy.
Upstream's [advisory treatment of unrequested behavior rules](https://github.com/EveryInc/compound-engineering-plugin/pull/1771)
does not override this workspace's `must-fix` rule for implemented unauthorized
scope in `agent-prompts.md#code-reviewer`.

These are capabilities, not roles or lifecycle stages. Invoking one does not
create a handoff, review round, runtime artifact, or new status by itself.

## Authority Boundaries

1. OpenSpec answers what the current change must do.
2. Repository state, tests, builds, and runtime evidence answer what the
   implementation does.
3. `docs/reviews/` answers the durable status of formal workspace findings.
4. `.ai/current-task.md` and `.ai/handoff.md` answer only the current execution
   and routing state.
5. `docs/solutions/` records verified, reusable, non-obvious engineering
   knowledge. It must not restate requirements, designs, task state, or review
   status.

If a Skill output conflicts with a higher authority, stop using that output and
reconcile the authoritative source. Never copy a generated plan into the
workflow as a competing source of truth.

## Default Flow

```text
OpenSpec Explore/Propose when applicable
  -> existing risk-based design gate
  -> OpenSpec Apply or scoped implementation
  -> focused tests
  -> ce-simplify-code when triggered
  -> Code Reviewer using ce-code-review
  -> existing aggregated fix/verification loop when needed
  -> ce-compound only when the Learning Worthy Gate passes
  -> OpenSpec Archive when applicable
```

`ce-debug` replaces guess-first debugging inside implementation or fix work. It
does not replace Task Intake, design, review, or verification.

## Capabilities Not In The Default Flow

Do not use `ce-brainstorm`, `ce-plan`, `ce-work`, or `lfg` as lifecycle
controllers for an active OpenSpec change. They overlap with OpenSpec Explore,
proposal/design/tasks, Apply, and the collaboration routing contract.

`ce-doc-review` is represented by the existing Design Reviewer reviewing the
authoritative OpenSpec artifacts. It must not generate a parallel plan.
`ce-compound-refresh` may be evaluated later after `docs/solutions/` contains
enough used material to justify refresh automation.

An explicitly isolated experiment may evaluate an excluded capability only
when Task Intake names the experiment, authority boundaries, cleanup, and
success evidence. It is not a default workflow change.

## Cross-Tool Deployment

Canonical Skill sources live under `docs/ai-collaboration/skills/`. Generated
tool-local copies are installed by:

```powershell
powershell -ExecutionPolicy Bypass -File `
  docs/ai-collaboration/scripts/install-compound-skills.ps1 -Target all `
  -DisableOverlappingLifecycleSkills
```

The installer reads `compound-skills.manifest.json` and supports these targets:

| Target | Project-local destination | Notes |
| --- | --- | --- |
| shared agents | `.agents/skills/` | Shared Agent Skills discovery surface |
| Codex | `.codex/skills/` | Project-scoped Codex copy |
| Claude Code | `.claude/skills/` | Works alongside the native plugin marketplace without requiring the full plugin |
| Cursor / Cursor CLI | `.cursor/skills/` | Project-scoped Cursor Agent Skills |
| OpenCode | `.opencode/skills/` | Project-scoped OpenCode Skills |
| Antigravity | `.agent/skills/` | Project-scoped Antigravity Skills |
| Gemini | `.gemini/skills/` | Project-scoped Gemini Skills |
| iFlow | `.iflow/skills/` | Project-scoped iFlow Skills |
| Qwen | `.qwen/skills/` | Project-scoped Qwen Skills |

Tool-local directories are ignored workspace state. Do not edit generated
copies manually. Change the canonical files, rerun the installer, and verify:

```powershell
powershell -ExecutionPolicy Bypass -File `
  docs/ai-collaboration/scripts/install-compound-skills.ps1 -Target all -Check
```

`-DisableOverlappingLifecycleSkills` moves only the manifest's known
Superpowers lifecycle controllers from an active `skills/` directory to the
sibling `skills_disabled/` directory. It does not delete them. Keep selected
orthogonal Skills such as TDD, verification, worktree isolation, and systematic
debugging available according to the workspace risk rules.

The project-scoped bundle is deliberately preferred over installing the full
upstream plugin into every host: it gives every reviewer the same four
contracts and avoids exposing overlapping lifecycle commands. A Task Owner may
still install the official plugin globally for unrelated work, but the current
batch prompt and this workspace standard determine which capabilities may run.

## Cross-Tool Assignment

Role assignment remains functional and tool-agnostic. A Routing block may
recommend Claude Code, Cursor, OpenCode, Antigravity, Codex, or another tool
when it offers the required independence or specialist capability. The
Operator Command must still name the functional role, authoritative inputs,
scope, outputs, and role contract.

For cross-review:

- choose a different agent session from implementation for risk `M` review;
- choose an agent independent from implementation and fixes for risk `H`
  verification;
- require the reviewer to inspect OpenSpec, the actual diff, and fresh
  evidence rather than the previous agent's narrative;
- size the inspection by consequence and failure visibility rather than total
  diff lines, while preserving the existing S/M/H independent-review gates;
- keep findings in the existing workspace review artifacts and statuses;
- do not require every available model to review the same change.

For specialist work, assign the existing Architect, UI Designer, Test
Engineer, or bounded supporting analysis task. A Compound Engineering Skill
does not create a new specialist role.

## Retrieve And Reuse

Before non-obvious implementation, diagnosis, or review, search `docs/solutions/`
by symptom, module, or constraint. Read only relevant hits, including their
Context, Verification, and Revalidation sections. Ordinary mechanical work
needs no search; do not reread the entire library at every role boundary.

For a bounded local symptom search, run `docs/ai-collaboration/scripts/find-solutions.ps1 -WorkspaceRoot <absolute project root> -Query '<literal terms>' [-Limit <1-100>]`. It reads only `docs/solutions/**/*.md` entries (skipping README and template files), writes nothing, follows no reparse point, and matches whitespace-separated literal terms. An unsafe or unreadable entry makes the search incomplete with exit 1; a hit is evidence to revalidate, not an applied decision.

Confirm that current versions, behavior, and authoritative requirements still
match before applying guidance. An entry is evidence to evaluate, not permission
to change scope. If stale or conflicting, use current evidence, explain why it
was not applied, and correct the entry only within the assignment's write scope.
Read-only work reports the correction in chat.

Record an actual reuse as a path plus the decision or check it informed in the
existing result or closing summary. Reading a hit or creating a new entry is not
reuse. A no-hit search needs no new artifact.

## Learning Worthy Gate

Create or update a `docs/solutions/` entry only when all conditions hold:

1. the knowledge is non-obvious and supported by verified evidence;
2. recurrence or cross-task reuse is plausible;
3. it adds reusable diagnostic or application guidance beyond existing coverage;
   link the authoritative rule or originating OpenSpec/review rather than copy
   its requirements, design, findings, or task state. Prior coverage in a change
   does not exclude a cross-task lesson; duplicate lessons update or cite the
   existing entry instead;
4. it can be stated without secrets, private runtime data, or transient task
   status.

If guidance holds only while an external bug, platform/tool version, or
dependency behavior persists, an entry may add `retire_when` in frontmatter:
name the change that could retire it and a check that reads external state
without modifying the repository. This is optional; older entries stay valid.
A met condition is contrary evidence requiring investigation, not permission
to delete an entry or remove a workaround. An unavailable check is unknown,
not proof that the condition is unmet. Keep the normal `Revalidation` section
for other changes that call for a fresh assessment.

After verified work involving repeated fixes, expensive diagnosis, platform
traps, or generalizable review findings, the current responsible agent briefly
checks this gate. Record the entry/rule link, existing coverage link, or
`no durable learning` with a short reason in the existing result or closing
summary. Routine changes need no learning ceremony. Response-only or read-only
work reports a candidate in chat unless knowledge-file writes are authorized.

Promote a concise rule into `AGENTS.md` or a module guide only when it is
normative for future work. Otherwise use the solution template. Failure to pass
this gate means `ce-compound` reports `no durable learning` and creates no file.
Learning capture never blocks batch closure unless the current task explicitly
requires it.

## Adoption Metrics

Use optional Process Metrics only for actual available data; no table or ledger
is required. During the first ten eligible batches, record only these additional
observations in the closing summary when known:

- whether simplification removed real accidental complexity;
- review findings accepted versus rejected;
- which prior solution entry was applied and what decision or check it informed;
- which lesson was captured, already covered, or declined with a short reason;
- whether a cross-tool handoff resumed successfully from repository evidence.

Do not add new runtime fields or a dashboard. Reassess the selected capability
set after evidence from five to ten normal changes.
Use existing result/closing prose, not a second ledger or mandatory metric keys.
Measure demonstrated reuse and recurring mistakes; entry counts and skill calls
are activity only. Claim saved time or avoided defects only with supporting
observations, never estimated benefits presented as measured facts.

## Upstream References

- [Compound Engineering guide](https://every.to/guides/compound-engineering)
- [Compound Engineering plugin](https://github.com/EveryInc/compound-engineering-plugin)

The upstream project offers a broader end-to-end loop. This workspace adopts
only the bounded capabilities named above and preserves its existing OpenSpec
and collaboration contracts.

## Third-party source notice

These local instructions selectively adapt Compound Engineering methods and
are modified for EngRelay's activation, role and authority boundaries.
Upstream: EveryInc/compound-engineering-plugin, compound-engineering-v3.29.0,
commit 4043703d32c5df9e35f22757dee22f3a72a99c66. Preserve the following notice
with redistributed copies. This notice covers the upstream material; it does
not grant rights to other material; EngRelay's own MIT notice applies separately.

MIT License

Copyright (c) 2025 Every

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
