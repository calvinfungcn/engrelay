# Fictional Lite handoff T01 before review

This is a design fixture. Its stated events and paths are fictional inputs, not evidence of executed work.

## Routing

- Schema version: lite-1
- Task ID: T01
- State revision: 4
- Current role: Executor
- Current agent: fictional-executor-A
- Current status: in-progress
- Next action: dispatch
- Human Action Required: none
- Review round: 0
- Next role: Reviewer
- Risk level: M

## Current Status

Recommended capability tier: C3

The fixture stipulates a bounded implementation ready for independent review. The task is not accepted.

## Evidence

- Task authority: .ai/engrelay-lite/tasks/T01.md
- Implementation result: .ai/engrelay-lite/tasks/T01-result.md
- Named expected review output: .ai/engrelay-lite/tasks/T01-review-1.md

## Operator Command

```text
You are the Reviewer for task T01.
Read: AGENTS.md, docs/engrelay-lite/RULES.md, docs/engrelay-lite.config.md, .ai/engrelay-lite/queue.md, .ai/engrelay-lite/tasks/T01.md, .ai/engrelay-lite/handoff.md and .ai/engrelay-lite/tasks/T01-result.md.
Objective: independently review the authorized T01 change against its recorded scope and acceptance, reporting all high-confidence actual defects together.
Constraints: business code is read-only. Do not implement or review your own work. There are 0 completed verdicts and 3 default verdicts available. Existing authorization, scope and required verification govern.
Output: .ai/engrelay-lite/tasks/T01-review-1.md and .ai/engrelay-lite/handoff.md are expressly writable protocol outputs; save the verdict and complete next state, read back and validate the decided expectations. If actually prohibited from writing, return the complete findings and response handoff with the source revision and SHA256.
Follow: docs/engrelay-lite/RULES.md.
```
