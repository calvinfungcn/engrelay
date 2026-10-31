# Improve first handoff trial: desensitized evidence

Change: `improve-first-handoff-trial`
Execution Batch: `engrelay-first-handoff-trial-20261030-01`
Scope: source-only sample, bilingual guides, export boundary, internal A/B exercises.
Status: local delivery independently reviewed and accepted at round 02; the owner authorized item 3.2 and status synchronization on 2026-10-31. Final closure validation is recorded in the [round 02 review](2026-10-31-round-02.md). Public fixed-commit acquisition and external G0 remain pending.

This record contains no private paths, account names, chat transcripts or raw session content. Raw logs and invocation records stay in the author's local evidence area and are referenced here only by hash.

## What was tested

| Item | Result |
| --- | --- |
| Original sample (`fixture/labels.ps1` with its initial defect) | 2 of 4 checks fail on Windows PowerShell 5.1 and PowerShell 7; exit 1 (re-observed in the repair round) |
| Corrected copy in disposable directories | 4 of 4 checks pass on both hosts; exit 0 (run-04 and run-05, repair round) |
| Harness negative control (unrolled return) | Fails on both hosts; the checks detect unrolled or `$null` results |
| Archive boundary (disposable Git tree, real `git archive`) | Sample tree, the sample's nested OpenSpec, `openspec/` and `docs/reviews/` excluded; unrelated `examples/` file, `payload/` and control files kept; negative control without the rule includes the sample. Not re-run in the repair round because no export rule changed |
| Internal A/B exercises | Four fresh directories in total. Runs 02 and 03 are partial (classified `M`). Runs 04 and 05 (repair round) reached the `S` closure locally. See the table below |
| Earlier failed attempt (attempt 01) | Its harness masked the return shape, so Session B stopped and routed back. Kept as a failure record; not counted as a pass |

## Fixture reference (candidate, not published)

The offline copy named in the guides is checked against these SHA256 values. Paths are relative to `examples/handoff-demo/fixture/`.

| File | SHA256 |
| --- | --- |
| `.gitignore` | `2AB0E2C14E9E76CF6C8ADE8CA55FBF744FAAB647DB14AC3A12CD5F4A26D63B39` |
| `AGENTS.md` | `A14ED811CBFB36A5793C0113DBEA82B424FA3B0ECB721552E54A8C22FE1B9759` |
| `labels.ps1` | `1B694222323DF13F64C112EE8058F8003B28570C4C6196C8E1D0A2E3E679E1B8` |
| `test-labels.ps1` | `5AD04DB67799029BC354A828E722418E44918E8F6076C540E2D6E025C366D8F6` |
| `openspec/config.yaml` | `9706BA630C1CFA7FDB28D463A211C53A34849BB052D241EBF9DD61C4DCC2D266` |
| `openspec/changes/normalize-demo-labels/proposal.md` | `92F690A69A91675AE6D0DFF8F63513798B3C35F25EBE5A9185D481230CAAE95A` |
| `openspec/changes/normalize-demo-labels/tasks.md` | `7D4F6C3AAD943FF10D3EE94CC9B5409E8374C4B9BA7B7DE88B8DF044E64FA236` |
| `openspec/changes/normalize-demo-labels/specs/label-normalization/spec.md` | `EB5EE134AFFEC41395796A5DB6C8DD3168576ECAFC8C4643FE1FB447303FC876` |

Repair round 01 changed only `AGENTS.md`, adding a short "Demo scope and impact" section. The defect in `labels.ps1` and the checks in `test-labels.ps1` are unchanged. Runs 02 and 03 used the earlier `AGENTS.md` with SHA256 `BE2BBE84E7CB85E7FEB9C116075C25B8D0DCF734BEA37268D9687A924BB0A659`; the other seven files were identical.

The source repository baseline is `a4aff94d3970e5659c121874eba3817a561ad8ca` (v1.10.1). The sample has no published commit SHA yet.

## Inputs and versions

- Package: the complete v1.10.1 Full package, SHA256 `8DF013148E5D80663EA75112A40F334EC070FDC60477B5C49FC2D2C6BEEF1A3F`. The repair runs extracted the same verified archive into separate package directories. The public release tag was not re-observed, so this is a locally verified package, not a fresh public download check.
- Install command shape: Full profile (default), SkillTarget `none`, WorkflowMode `optional`. Repair-round installs and the follow-up `Status` and `CheckVersion` calls each exited 0 when called directly. In earlier installs the manager printed success but `$LASTEXITCODE` was 1 after the call; that was not isolated, so guides must not rely on the exit code alone.
- Environment: Windows, PowerShell 7.6.9 and Windows PowerShell 5.1.26100.9711, Git 2.50.1.
- Agent host: Cursor Task subagents (`generalPurpose`). Each invocation is a new subagent that receives only its own prompt. The model parameter was not set, so the model is inherited from the parent session. The exact model was not recorded. This is a non-inheriting agent invocation, not a separate user-opened desktop chat.

## Invocation records (repair round 01)

Each subagent invocation was recorded with its input text, a Cursor invocation identifier, and a transcript hash. The first record of each transcript is the single prompt that was sent. The saved input for each run matches that prompt.

| Invocation | Input SHA256 (saved text) | Result |
| --- | --- | --- |
| Run 04, Session A (start only) | `3A7D0F73EB92C1115E4931CF7570F0D3F4F0A9474D74C47FFD627D8F39CAE931` | `dispatch` to Implementation Engineer, `S`, state revision 1 |
| Run 04, Session B (continue) | `AFE8CAC520B1EDD9B643399B37483B16AF57A27437B1CAE38D8C753BC9A7E196` | Closure `accepted`, `close`, state revision 2 |
| Run 05, Session A (start only) | `C380A4BB8327BCEBBBA5473928C3D0E871F4675E4DAAEF8ED994BC501111B7E2` | `dispatch` to Implementation Engineer, `S`, state revision 1 |
| Run 05, Session B (continue) | `511F2BEDB18D843D67959C630DCF6C5B6DB34B6BCE900A99FF96F2EB84CB8775` | Closure `accepted`, `close`, state revision 2 |

Runs 02 and 03 (earlier, fixture without the scope note) have their original transcripts preserved locally, and each Session B input matches the saved Operator Command copy. A minimal nonce probe from the first run also has its transcript and artifact recorded locally.

## What each session did

- Session A (start only): read the installed `ai-collab-start` skill in the trial project, prepared the current task and a complete handoff, did not change the sample, and backed up its handoff. The backup hashes matched the live handoff.
- Session B (new invocation): received only the project path, the continue entry, and the live Operator Command. It changed only `Normalize-DemoLabels` in `labels.ps1`, left `test-labels.ps1`, the spec and the proposal unchanged, ticked its own task item in the disposable copy, wrote a round result, and closed the batch as `S`.
- Standard operations: copying the live Operator Command into Session B and backing up Session A's handoff. No script wrote session state.
- Session B loaded its continue entry from the source checkout's skill copy rather than from a copy installed in the trial project, because the install used SkillTarget `none`. Host discovery was not tested.

## Observed results

- Runs 02 and 03 (earlier): Session A classified the sample as `M`, so the route stopped at an independent Code Reviewer dispatch. Their OpenSpec item stayed unchecked. These are partial results and are not counted as completed S-level closures.
- Runs 04 and 05 (repair round): Session A classified the sample as `S` after the scope note. Session B returned `Normalize-DemoLabels` to 4 of 4 passing checks on both hosts, with exit 0. The OpenSpec item was ticked in each disposable copy. The structure check, run with the expected batch, action, next role, review round and state revision, exited 0.
- The `S` closure is a self-check by the implementer. It is not an independent review.

## Earlier attempts and their kept records

- Attempt 01 (first harness): failed because the harness masked the return shape. Kept as a failure record.
- Runs 02 and 03: partial `M` routing, as above. Kept as recorded.
- The repair round did not overwrite or relabel these records.

## Limits

- Internal runs do not establish external users, host loading, all-host adherence, token savings or cost.
- Time was not measured for the ten-minute target; the guide does not claim it.
- The external G0 trial has not started. No outside participant was contacted.
- The sample is not yet a published commit, and the public acquisition path has not been checked.
- The four checks cover a single-item output array through the blank-label case, but do not include a separate single-element input or a `$null` element in `-Labels`. Session B also ran an ad hoc single-element input check without adding a new check.
- The source checkout's `.gitattributes` now differs from the root `snapshot.json` inventory; the next release staging must regenerate the snapshot.
- Independent Code Reviewer round 02 verified CR-01, CR-02 and CR-03. Local accepted closure covers the mapped delivery only; it does not establish public acquisition, external G0 or release readiness. See the [review index](index.md) and [final boundary evidence](2026-10-31-round-02.md#负责人授权后的-32-收尾).
