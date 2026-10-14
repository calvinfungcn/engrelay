# Review Request - <task id>

<!-- This template explicitly authorizes the formal artifacts named below.
     For response-only review, replace these outputs with chat findings; do not
     create a formal round or overwrite another batch's live .ai state. -->

## Review Target

- Task ID: `<task-id>`
- Change ID: `<change-id>`
- Review type: `<initial-review|re-review|verification|reconciliation>`
- Target diff or commit range: `<diff, branch, commit, or working tree>`

## Required Reading

- `.ai/current-task.md`
- `.ai/handoff.md`
- `docs/reviews/README.md`
- `AGENTS.md`
- `<module instructions>`
- `<source artifacts>`

## Scope

In scope:

- <review scope>

Out of scope:

- <explicit exclusions>

## Evidence To Check

- <tests, builds, procedures, source paths, or screenshots>

## Output Requirements

- Create a new `docs/reviews/<change-id>/YYYY-MM-DD-round-##.md` file.
- Update `docs/reviews/<change-id>/index.md`.
- Use only formal statuses: `open`, `fixed-not-verified`, `verified`, `deferred`.
- Include fresh evidence for any `verified` claim.
- Do not modify legacy review artifacts.
- Update `.ai/handoff.md` as the sole Action State. Include Operator Command
  only for agent `dispatch`, never human decision dispatch.
- Read-only prohibits writes unless these named outputs are explicitly
  authorized. If artifact writes are forbidden, report in the response.
- Always state the selected Next Action in the final response. For agent `dispatch`,
  provide one copy-ready next-role Operator Command; for `close`, state that no
  next role or Operator Command exists.
- For human decision dispatch, provide Owner Decision Brief and no Operator Command.
- If strict read-only also prohibits review artifacts, report the complete
  findings in the final response and embed assigned finding IDs, evidence
  locations, and required outcomes in the Operator Command.
