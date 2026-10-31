# Demo project agent instructions

This is a small PowerShell sample used to try EngRelay's first handoff.

- Work only inside this project directory.
- The requirement is `openspec/changes/normalize-demo-labels/`. Its `tasks.md`
  is the only implementation checklist.
- Keep the function name `Normalize-DemoLabels` and its parameter in `labels.ps1`.
- Do not change the expectations in `test-labels.ps1` to make a check pass.
- Verify with `pwsh -NoProfile -File ./test-labels.ps1`; it must exit with code 0.
- Do not change Git configuration or create commits.

## Demo scope and impact

- `Normalize-DemoLabels` is used only by `test-labels.ps1` in this disposable project.
  It is not a shared library, and no other code in this project calls it.
- The change has no permission, data, money, network or deployment effect.
- This trial task is designed as an S-level demo. The array return shape is fixed by
  the spec and the checks, not by a shared contract.
