---
name: ce-simplify-code
description: >
  Apply only to a current task using ai-collaboration; discovery does not activate it.
  Use after focused checks pass and before review to simplify only the current
  meaningful code diff without changing accepted behavior. Remove accidental
  complexity, duplication, speculative abstraction, and unnecessary layers,
  then rerun directly affected checks.
---

# CE Simplify Code

## Activation

Apply this package-adapted Skill only while the current task uses ai-collaboration
under docs/ai-collaboration/README.md#optional-activation-and-coexistence.
Discovery, role names or old .ai files do not select the workflow. When another
controller owns the task, this Skill adds no handoff writes, role dispatch or
mandatory capture; use that project's own quality/CE capabilities instead.
Reading the technique as reference is allowed.

## Boundaries

- Run inside the current Implementation Engineer or Fix Engineer role.
- Scope is the current Execution Batch diff and directly related code only.
- Preserve OpenSpec behavior, public contracts, compatibility, and test intent.
- Do not turn simplification into repository-wide cleanup or a new handoff.
- Do not create or broaden a complexity exception. Route a material exception
  to Chief Designer under the existing contract.

## Procedure

1. Confirm focused behavior checks pass before restructuring.
2. Inspect the diff for speculative abstractions, redundant wrappers,
   duplicated branches, needless indirection, dead code, excessive comments,
   and inconsistent reuse of an existing capability.
3. Make only changes whose behavior-preserving value is clear.
4. Prefer deletion and direct reuse over a new generalized framework.
5. Re-run the directly affected focused checks after the latest edit.
6. Record material simplification and evidence in the existing implementation
   or fix result. If nothing should change, record `no simplification needed`.

Passing this Skill does not replace independent review or completion
verification.

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

