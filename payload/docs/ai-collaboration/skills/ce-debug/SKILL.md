---
name: ce-debug
description: >
  Apply only to a current task using ai-collaboration; discovery does not activate it.
  Use for non-obvious, intermittent, cross-layer, data-dependent, concurrent,
  environment-specific, or previously failed defects. Reproduce, observe,
  form one falsifiable hypothesis at a time, identify root cause, implement the
  smallest fix, and add regression evidence.
---

# CE Debug

## Activation

Apply this package-adapted Skill only while the current task uses ai-collaboration
under docs/ai-collaboration/README.md#optional-activation-and-coexistence.
Discovery, role names or old .ai files do not select the workflow. When another
controller owns the task, this Skill adds no handoff writes, role dispatch or
mandatory capture; use that project's own quality/CE capabilities instead.
Reading the technique as reference is allowed.

## Boundaries

- Run inside the assigned Implementation Engineer or Fix Engineer role.
- Use the existing `quality-systematic-debugging` Skill when it is available;
  this contract provides the same minimum method on other tools.
- Do not change requirements, accepted design, risk, or batch scope. Stop and
  route through the existing contract when evidence requires such a change.
- Do not stack speculative fixes.

## Procedure

1. Record the symptom and establish a reliable reproduction or the best
   bounded observation available.
2. Trace inputs and state through the affected boundaries. Compare a working
   path when one exists.
3. State one hypothesis and the observation that would confirm or reject it.
4. Run the smallest experiment that discriminates that hypothesis.
5. Remove temporary diagnostics or disproven experimental changes.
6. Repeat until evidence identifies the root cause or the stop condition is
   reached.
7. Implement the smallest root-cause fix, add a focused regression test when
   practical, and run directly affected checks.
   When the minimal fix already passes focused checks and evidence shows the same
   root cause repeating across multiple authorized locations, you may add a
   bounded local guard or shared helper that touches only authorized affected
   sites and does not change public interfaces. If the prevention would expand
   scope, change a public contract, or cost disproportionately, record a follow-up
   recommendation instead of structural churn for a single defect.
8. Record symptom, root cause, fix, and fresh evidence in the existing result
   artifact. Use the normal review route for the batch risk.

After three failed fix hypotheses, stop expansion and route to Chief Designer
with the evidence rather than continuing guesswork.

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

