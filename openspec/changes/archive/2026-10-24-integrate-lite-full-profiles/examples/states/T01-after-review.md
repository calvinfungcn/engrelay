# Fictional Lite handoff T01 after review

This is a design fixture. Its stipulated finding is not a real product finding.

## Routing

- Schema version: lite-1
- Task ID: T01
- State revision: 5
- Current role: Reviewer
- Current agent: fictional-reviewer-B
- Current status: in-progress
- Next action: dispatch
- Human Action Required: none
- Review round: 1
- Next role: Executor
- Risk level: M

## Current Status

Recommended capability tier: C3

The fixture stipulates one actual verdict with must-fix F01: the task's defined empty-input case is not handled. F01 is open; T01 is not accepted.

## Evidence

- Task authority: .ai/engrelay-lite/tasks/T01.md
- Review result and F01: .ai/engrelay-lite/tasks/T01-review-1.md

## Operator Command

```text
You are the Executor for task T01.
Read: AGENTS.md, docs/engrelay-lite/RULES.md, docs/engrelay-lite.config.md, .ai/engrelay-lite/tasks/T01.md, .ai/engrelay-lite/handoff.md and .ai/engrelay-lite/tasks/T01-review-1.md.
Objective: fix F01, the recorded missing empty-input behavior required by T01 acceptance, and check the affected behavior.
Constraints: preserve the authorized scope and actual verdict count 1, with 2 default verdicts remaining. Do not treat the review as repeated or declare your own fix independently verified. Do not change models or task identity to reset the count.
Output: authorized T01 implementation files and existing result record; then publish .ai/engrelay-lite/handoff.md with a complete independent-review handoff. Business scope does not expand. Save, read back and validate the decided expectations.
Follow: docs/engrelay-lite/RULES.md.
```
