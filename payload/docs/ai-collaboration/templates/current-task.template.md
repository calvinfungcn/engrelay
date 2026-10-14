# Current Task - <short title>

## Task Identity

- Task ID: `<task-id>`
- Change ID: `<openspec-change-id or none>`
- Module(s): `<module paths>`
- Source: `<OpenSpec, issue, request, review round, or other source>`
- Created on: `YYYY-MM-DD`

## Batch Classification

- Execution Batch ID: `<batch-id>`
- Risk level: `<S|M|H>`
- Risk reason: `<why this level applies>`
- OpenSpec checklist items:
  - `<task or sub-item>`
- Existing capability to reuse: `<current component, API, pattern, or none>`
- First demonstrable outcome: `<observable vertical result or bounded spike conclusion>`
- Justified complexity exceptions: `<none, or element -> acceptance criterion/evidenced risk>`
- Stop condition: `<evidence or material scope/effort change requiring pause and a revise/stop/split recommendation>`
- Expected implementation sessions: `<1 or 2>`
- Broad regression command: `<command or not applicable>`

<!-- For a design-bound batch, technical fields may state "to be confirmed by Chief Designer". -->
<!-- Batch outcome must be an observable, independently testable behavior (see docs/ai-collaboration/README.md#execution-batch). -->
<!-- Classify this batch's actual impact, not its parent proposal's highest risk.
     Map only this requested outcome; unrelated parent tasks do not block closure. -->

## Initial Assignment

- Initial role: `<role>`
- Recommended agent: `<agent/tool>`
- Initial prompt template:
  - `docs/ai-collaboration/agent-prompts.md#<section>`

## Required Reading

- `AGENTS.md`
- `<module AGENTS.md or CONTRIBUTING.md>`
- `docs/ai-collaboration/workflows.md#<assigned-role-section>`
- `docs/ai-collaboration/agent-prompts.md#<assigned-role-section>`
- `<triggered docs/ai-collaboration/skills/<skill>/SKILL.md, if any>`
- `<batch-specific OpenSpec, review, source, and test inputs>`

## Goal

<Describe the task outcome in 1-3 sentences. For uncertainty-driven work, state the critical unknown here or in Acceptance Criteria.>

## Scope

<!-- Mandatory scope and acceptance must be explicitly accepted, evidenced as
     an existing constraint, or causally necessary for accepted behavior or
     safety/correctness. Keep suggestions and assumptions non-authoritative. -->

- <in-scope item>

## Out Of Scope

- <out-of-scope item or deferred non-required work>

## Must Not Touch

- <paths, modules, generated files, local config, or unrelated changes>

## Acceptance Criteria

- <observable completion criterion or evaluation condition>

## Constraints

- <technical, business, compatibility, security, or workflow constraint>
<!-- Include foreseeable environment prerequisites here or under Required Checks.
     Put live readiness and human-only preparation notices in handoff's conditional
     Environment Preparation section. A stop condition permits pausing affected work,
     not unilateral stopped/superseded closure; record explicit Task Owner authorization. -->

## Required Checks

- `<exact command or inspection step>`

## Output Requirements

The assigned agent must produce:

- one Next Action: `dispatch`, `continue`, or `close`
- updated `.ai/handoff.md` at actual handoff, wait, interruption, or closure boundaries
- a copy-ready Operator Command in `.ai/handoff.md` for agent `dispatch`;
  for human decision `dispatch`, omit Operator Command and include `## Owner Decision Brief`
- a final response stating the selected Next Action (for `close`, state that no next role or command exists)
- when read-only prohibits `.ai/` writes, response Routing and an Operator Command
  only for agent dispatch; human dispatch uses Owner Decision Brief instead
  (see docs/ai-collaboration/handoff-schema.md#response-handoff-fallback)
- `.ai/round-XX-result.md`, only if implementation or fix work changes code, tests, or runtime configuration
- `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` and updated `index.md`, only if this is workspace-level review
- updated `openspec/changes/<change-id>/tasks.md`, only if task state changes
