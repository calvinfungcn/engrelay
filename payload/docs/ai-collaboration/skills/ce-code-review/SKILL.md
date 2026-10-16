---
name: ce-code-review
description: >
  Apply only to a current task using ai-collaboration; discovery does not activate it.
  Use inside the assigned Code Reviewer role for an independent, evidence-led
  review of a completed Execution Batch. Review authoritative requirements,
  the actual diff, tests, regressions, security, compatibility, and accidental
  complexity. Do not edit implementation code during the review pass.
---

# CE Code Review

## Activation

Apply this package-adapted Skill only while the current task uses ai-collaboration
under docs/ai-collaboration/README.md#optional-activation-and-coexistence.
Discovery, role names or old .ai files do not select the workflow. When another
controller owns the task, this Skill adds no handoff writes, role dispatch or
mandatory capture; use that project's own quality/CE capabilities instead.
Reading the technique as reference is allowed.

## Boundaries

- This Skill is a review technique, not a role or lifecycle controller.
- Follow `docs/ai-collaboration/agent-prompts.md#code-reviewer` and the current
  handoff exit contract.
- OpenSpec remains authoritative when an active change exists.
- Use the workspace finding statuses and priorities. Do not introduce a second
  P0-P3 taxonomy into formal review artifacts.
- Review implementation code and tests read-only. Write review and handoff
  artifacts only when the assignment explicitly authorizes those outputs.
  A response-only review reports findings in chat and preserves live batch state.

## Procedure

1. Establish the exact batch scope and acceptance criteria.
2. Inspect applicable instructions, authoritative OpenSpec artifacts, the
   actual diff, changed tests, and fresh recorded evidence.
3. Size the review by the consequence of a wrong change and how failure would
   surface, not by total lines changed. A small local change with visible
   failure can receive a focused pass; silent failures or security, money,
   data, public-contract, migration, and release boundaries need the relevant
   deeper checks. Preserve the assigned batch's S/M/H independence rules.
4. Select only material lenses for this diff: correctness, regression,
   security/authorization, data integrity, compatibility, performance,
   operability, test quality, and unnecessary complexity.
   For I/O or guard gaps, judge by the actual runtime context and provable
   consequences in that code path. Missing try/catch alone is not a finding;
   real data loss, misleading results, or unrecoverable partial completion are.
   For extra surface, parameters, configuration, or dependencies, require an
   explicit constraint or a clearly bounded scope. A short requirement that does
   not mention an item is not scope evidence by itself. When suggesting a
   dependency swap, name a real standard-library, platform, or in-repo
   alternative that applies.
5. Trace affected callers, consumers, contracts, configuration, and persisted
   state when the blast radius warrants it.
6. Report every high-confidence finding in one aggregated pass. Each finding
   includes a stable ID, priority, location, problem, impact, evidence, and
   bounded fix direction.
7. Separate findings from questions, residual risks, and optional ideas.
8. Apply the existing clean-close or aggregated-fix routing contract. Never
   stop with findings but no Next Action.

Do not generate a parallel plan, rewrite OpenSpec from the review, or ask
multiple models to repeat the same review without a named independent lens.

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

EngRelay material and modifications: Copyright (c) 2026 calvinfungcn and EngRelay
contributors, MIT. The full notice accompanies the installed kit at the project-root
path `docs/ai-collaboration/README.md#engrelay-license`. Preserve it and any upstream
notice when redistributing a standalone Skill.

