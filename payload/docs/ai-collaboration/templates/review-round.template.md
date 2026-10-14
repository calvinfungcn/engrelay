# Round ## - <Imported Legacy Review|Re-Review|Current-State Reconciliation|Verification>

## Metadata

- `Change`: `<change-id>`
- `Recorded on`: `YYYY-MM-DD`
- `Source artifacts`:
  - `<path/to/source-1>`
  - `<path/to/source-2>`
- `Round type`: `<imported|re-review|reconciliation|verification>`
- `Review role`: `<Code Reviewer|Verification Reviewer|Architect|Test Engineer>`
- `Review agent`: `<agent/tool>`

## Scope

<What this round is checking and what is explicitly out of scope.>

## Evidence

<Commands and results, or a clear procedure with observed outcomes. Include dates.>

## Findings

| Topic | Priority | Status | Finding | Evidence |
| --- | --- | --- | --- | --- |
| `<topic>` | `<must-fix|should-fix|nice-to-have>` | `<open|fixed-not-verified|verified|deferred>` | `<finding>` | `<evidence>` |

## Conclusion

<What is true after this round, and what remains open.>

- Batch closure decision: `<closed|fix-required|task-owner-decision>`
- Next action decision: `<dispatch|continue|close>`
- Broad evidence reused: `<path/command/result or none>`
- Additional checks run in this round: `<focused checks or none>`

## OpenSpec Impact

- <If tasks.md should change, specify which items and why.>

## Next Actions

- If clean: reconcile OpenSpec state and close without a separate verification
  or documentation-only round.
- If fixes are required: aggregate all assigned findings into one Fix Engineer
  round and provide a copy-ready Operator Command in `.ai/handoff.md`.
- Always state the selected Next Action in the final response. A clean `close`
  has no next role or Operator Command.
- If the single fix/verification loop already failed: dispatch Chief Designer
  with evidence for technical `REVISE`, or proposed `STOP`/`SPLIT` subject to an
  explicit, applicable Task Owner decision before stopped/superseded closure.
