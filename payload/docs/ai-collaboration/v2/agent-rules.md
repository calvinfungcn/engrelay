## EngRelay v2 workflow (conditional)

The installed WorkflowProfile is v2. Read the WorkflowMode declaration above:
- optional: activate ONLY when the current task explicitly selects EngRelay.
- default: use EngRelay v2 unless the current task selects another controller.
- disabled: do not activate until explicitly re-enabled.
Discovery, `.ai/relay/`, or historical `.ai/` files never activate a workflow. Use one primary controller per task.

When selected, read `docs/engrelay/RULES.md`, `docs/engrelay/skills/engrelay/SKILL.md`, optional `docs/engrelay.config.md`, and `.ai/relay/<change-id>/board.md` (use `plan`, `do`, or `review`). OpenSpec is the sole requirement/task authority. Preserve Risk (`S|M|H`) independence, hard 2-round circuit breaker, and cumulative unfinished-acceptance history; never load legacy `full` handbooks or `validate-runtime-state.ps1`.
Legacy Full `ai-collab-*` or Lite `EngRelay-Lite` requests do not match v2: explain the mismatch and point to `docs/engrelay/RULES.md` without switching profiles or rewriting historical state.
