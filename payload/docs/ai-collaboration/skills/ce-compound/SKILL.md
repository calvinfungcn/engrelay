---
name: ce-compound
description: >
  Apply only to a current task using ai-collaboration; discovery does not activate it.
  Use after verified work to capture reusable, non-obvious engineering
  knowledge only when the workspace Learning Worthy Gate passes. Write a
  concise docs/solutions entry or promote a normative rule; otherwise report
  that no durable learning is warranted.
---

# CE Compound

## Activation

Apply this package-adapted Skill only while the current task uses ai-collaboration
under docs/ai-collaboration/README.md#optional-activation-and-coexistence.
Discovery, role names or old .ai files do not select the workflow. When another
controller owns the task, this Skill adds no handoff writes, role dispatch or
mandatory capture; use that project's own quality/CE capabilities instead.
Reading the technique as reference is allowed.

## Boundaries

- This is an optional knowledge action, not a mandatory lifecycle stage.
- Read `docs/ai-collaboration/compound-engineering.md#learning-worthy-gate` and
  `docs/solutions/README.md`.
- Extract cross-task diagnostic guidance from verified work, linking its source.
  Do not copy OpenSpec requirements, design, task state, review findings, or
  obvious framework documentation. Existing source coverage does not by itself
  disqualify a reusable lesson.
- Respect write scope. Read-only work proposes the lesson in chat; it does not
  authorize solution or instruction-file edits.
- Do not include secrets, private runtime data, transient paths, or unverified
  claims.
- Learning capture does not reopen or block an otherwise complete batch unless
  the current task explicitly requires it.

## Procedure

1. Evaluate all four Learning Worthy Gate conditions.
2. Search existing instructions and `docs/solutions/` for prior coverage. Cite
   or update the existing lesson rather than create a duplicate.
3. If the gate fails, report `no durable learning` with a brief reason or a
   link to sufficient existing coverage in the current result/closing summary.
4. If the knowledge is a mandatory rule for future work, make the smallest
   justified update to `AGENTS.md` or the applicable module guide.
5. Otherwise create one focused solution from
   `docs/solutions/solution.template.md`.
6. Include searchable symptoms, applicability and exclusions, verified evidence
   with repository revision or content hash, and revalidation conditions. Mark
   historical evidence as historical; do not claim fresh runtime checks from it.
   Prefer durable repository references over local .ai paths.
   When guidance depends on an external bug, tool version, or dependency
   behavior, optionally set `retire_when` to the change that may retire it and
   a read-only check for that change. A met condition prompts verification; it
   does not itself authorize deleting guidance or changing product code.
7. Keep routing and completion state in `.ai/handoff.md`, not in the solution.
8. Record capture separately from actual reuse. A reuse observation names the
   prior entry and the decision/check it informed; do not invent savings.

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

