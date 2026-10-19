# Round XX Implementation Or Fix Result

## Paths Created Or Updated

| Path | Action | Description |
| --- | --- | --- |
| `<path>` | `<created/modified/deleted>` | `<description>` |

## Work Summary

- <summary item>
<!-- When relevant, add a brief learning observation here: prior entry path +
     decision/check informed; newly captured entry/rule, existing coverage, or
     no durable learning + reason. No new required field or separate report. -->

## Evidence Per Finding Or Requirement

| Requirement or finding | Evidence | Status |
| --- | --- | --- |
| `<requirement>` | `<evidence>` | `<done/open/deferred>` |

## Checks Run

| Command | Result |
| --- | --- |
| `<exact command>` | `<observed output; include exit code>` |

<!-- This table is the authoritative place for commands, transcripts, and exit
     codes, including ordinary accepted closure checks per
     handoff-schema.md#accepted-closure-validation. Link this file from handoff
     Authoritative Evidence; do not put the command string in handoff evidence
     backticks. Appending rows here must not change validated handoff bytes. -->

## Review Impact

- Review round created or updated: `<path or none>`
- Topics affected: `<topics or none>`

## OpenSpec Task Impact

- Task file: `<path or none>`
- Change made: `<yes/no and why>`

## Remaining Risks

- <risk or "None known">

## Next Action

- Decision: `<dispatch|continue|close>`
- Reason: `<why this action applies>`
- Action State: `.ai/handoff.md`

<!-- Add only when this result is the durable carrier of a transfer that the live
     handoff (Next output files or Authoritative Evidence) or current task names by
     path (not for ordinary evidence). The dispatching handoff should name this result
     path in Next output files before the work starts. Put the
     narration outside the fence: source batch, source role, source Agent, work
     producer Agent, Verdict (or none), cumulative Review round, prior State revision,
     prior live SHA256 (64 hexadecimal characters of the live handoff bytes), and
     target State revision. Then one outer fence at least one backtick longer than
     any fence inside it, holding one complete copy of the handoff. Otherwise omit. -->
