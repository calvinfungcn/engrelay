# Proposal: normalize-demo-labels

## Why

The demo label helper must return predictable results for labels with extra
whitespace, blank values and case-insensitive duplicates.

## What Changes

- Make `Normalize-DemoLabels` in `labels.ps1` satisfy
  `specs/label-normalization/spec.md`.
- Keep the checks in `test-labels.ps1` unchanged.

## Out of Scope

- Other functions, files or project settings.
- Unicode case folding or localization rules.
