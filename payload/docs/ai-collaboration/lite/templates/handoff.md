# Lite handoff <Task ID>

## Routing

- Schema version: lite-1
- Task ID: <stable approved ID>
- State revision: <positive integer>
- Current role: Executor
- Current agent: <actual agent>
- Current status: in-progress
- Next action: continue
- Human Action Required: none
- Review round: <actual cumulative completed verdicts>
- Next role: none
- Risk level: <S/M/H>

## Current Status

<Actual progress and unfinished acceptance. This is a template, not live state.>

### Continuation Command

```text
You are continuing as Executor for task <Task ID>.
Read: AGENTS.md, docs/engrelay-lite/RULES.md, docs/engrelay-lite.config.md, the approved task and its latest handoff and named evidence.
Objective: <next authorized executable step>.
Constraints: check latest authority and other writers; preserve scope, role, risk and actual cumulative count. Choose the local host within existing authorization. Do not self-review or self-verify H work.
Output: <named authorized files and evidence>; .ai/engrelay-lite/handoff.md at the next real boundary. Record actual takeover agent and increment revision on replacement.
Follow: docs/engrelay-lite/RULES.md.
```

## Evidence

- Task authority: <relative path>
- Result/checks and next named review output: <relative paths>
