# Tasks

This file is the only implementation checklist for this demo change.

## 1. Normalize demo labels

- [ ] 1.1 Make `Normalize-DemoLabels` in `labels.ps1` satisfy every scenario in
  `specs/label-normalization/spec.md`, without changing `test-labels.ps1`, and
  confirm that `pwsh -NoProfile -File ./test-labels.ps1` exits with code 0.
