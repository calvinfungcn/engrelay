# Pilot Evidence & Sizing Guidance Evaluation

- Execution Batch ID: `engrelay-link-sizing-pilot-20261021-01`
- Change: `link-sizing-guidance-and-pilot-lean-rules`
- Date: `2026-10-21`
- Author: `Fix Engineer` (owner-authorized S3 route and dynamic-accounting correction)
- Review round: `6` completed; this correction awaits independent round `7` under the finite owner authorization. Historical rounds 01–06 and the original closure remain unchanged.

---

## 1. Pre-Registration & Document Hashes

### 1.1 Pre-Registration Integrity
In accordance with design decision 3, all scenario goals, inputs, prompt constraints, and expected behaviors were pre-registered prior to running any scenario.

- Pre-registration file: `.ai/link-sizing-pilot/pre-registration.md`
- Pre-registration SHA256: `F2649FBA5DE0AD5614C5452F4BBB28D1C4E63A89896B3EC11EEDB9E30DAEE7A0`
- Recorded timestamp: `2026-10-21 04:03:01 UTC` (strictly preceding all scenario runs).

### 1.2 Baseline vs Candidate Document Hashes
Baseline documents were extracted from `v1.9.5` via `git archive v1.9.5 payload/docs/ai-collaboration`. Candidate documents represent the active working tree.

| Document | Baseline v1.9.5 SHA256 | Candidate SHA256 | Change Notes |
| :--- | :--- | :--- | :--- |
| `agent-prompts.md` | `6DE368D6BCA8CB817C457600E66222FF596D4B32C9026B904E428ACE942E08F0` | `E2DAA09FC041305333CE888AEE6FC622F2AEBB00D9C36283F3D4143A5D3C9553` | +2 single-line anchor refs (+221 B) |
| `skills/ai-collab-start/SKILL.md` | `457147E9915B646244BAC9D0FF50DAA89C4F83800C7B554B0B39BD675CE3EB39` | `EEB094CCED1794B57DEDEF63C20361D4E1C890ECE0C5A8A6DD79283767D02B3A` | "the first role" -> "the Initial role" (+2 B) |
| `README.md` | `ED7B9126C90DE9E1DB90F52F02FB5A36AC4FA4E83D3C3462A7CB832FEC57CE96` | `ED7B9126C90DE9E1DB90F52F02FB5A36AC4FA4E83D3C3462A7CB832FEC57CE96` | Unchanged (target section exists) |
| `workflows.md` | `E383010E4815B79D773DF6E3F7E21DF0CCD7F0F274728CC10EF1BBE43619D2BD` | `E383010E4815B79D773DF6E3F7E21DF0CCD7F0F274728CC10EF1BBE43619D2BD` | Unchanged |
| `handoff-schema.md` | `EBA6DC42112F052A4DE30DDA24120A2924F3517EA940C587244B25E912FAD813` | `EBA6DC42112F052A4DE30DDA24120A2924F3517EA940C587244B25E912FAD813` | Unchanged |

---

## 2. Scenario Observations, Conformance & Deviations

All scenarios were executed in isolated GUID workspaces outside the repository.

### S1: Non-Destructive Intake Bypass (T01)
- **Host / Model**: Cursor Agent CLI (`Claude Opus 5.5 300K High`)
- **Role / Entry**: Task Intake (`ai-collab-start`)
- **Context**: Clearly specified bug fix with reproduction test case.
- **Expected**: Dispatches `Implementation Engineer` directly; skips Requirements Analyst and Chief Designer; omits optional sizing line; default capability tier C3.
- **Observed**: Correctly skipped Requirements Analyst and Chief Designer; dispatched `Implementation Engineer` directly; omitted optional sizing line. Selected capability tier `C2` (advisory downgrade based on clear context, diverging from registered default C3).
- **Validation**: Runtime validator on generated `.ai/handoff.md` exited 0.
- **Conformance**: Matched routing and bypass expectations; advisory capability tier override observed.

### S2: Minimal Option & Authoritative Boundary (T02)
- **Host / Model**: Cursor Agent CLI (`Claude Opus 5.5 300K High`) & Codex CLI (gpt-4o / chatgpt auth)
- **Role / Entry**: Chief Designer
- **Context**: Feature request for `.xlsx` export mentioning openpyxl, PDF, and pluggable format engines.
- **Expected**: Minimal option adds single xlsx write method without PDF or plugin framework; no Owner Decision Brief; no Design Review required; dispatches `Implementation Engineer`.
- **Observed**:
  - **Cursor**: Adhered to minimal scope by rejecting unrequested PDF and generic plugin framework. However, identified `openpyxl` as a new third-party dependency complexity exception under minimal authority rules; instead of direct implementation dispatch, it set `Next action: dispatch`, `Human Action Required: awaiting-decision`, `Next role: Task Owner`, and planned Design Review following approval. This is an observed deviation from the registered expectation of direct implementation dispatch.
  - **Codex**: Also identified dependency boundary and rejected framework expansion; emitted response handoff fallback dispatching `Design Reviewer`.
- **Validation**: Validator exited 1 on Cursor fixture `.ai/handoff.md` because the fixture's `.ai/current-task.md` omitted standard sections (fixture specification limit, not validator defect).
- **Prompt Limitation**: Runner prompt explicitly cued Minimal Option and authority mapping.

### S3: Preserving Owner-Authorized Abstraction (T03)
- **Host / Model**: Cursor Agent CLI (`Claude Opus 5.5 300K High`)
- **Role / Entry**: Chief Designer
- **Context**: Explicit owner requirement: "We need an extensible interface `IExportFormat` and registry because CSV/JSON/XLSX will be swapped by configuration."
- **Expected**: Preserves `IExportFormat` interface and registry; does not over-prune authorized abstraction; cites owner authorization; does not add unrequested caching or plugin loaders.
- **Observed**: Preserved the requested interface and registry based on explicit owner authorization; did not add unsolicited features. The actual immediate route was `dispatch` to `Task Owner`, status `awaiting-owner-decision` (Human Action Required: `awaiting-decision`), asking for the first concrete export format, input data and observable acceptance behavior. Design Review was planned after that decision; no implementation dispatch occurred. The saved fixture handoff matches the completed edit at line 458 of `S3.jsonl`.
- **Validation**: Validator exited 1 due to fixture `.ai/current-task.md` omission (fixture limitation).
- **Prompt Limitation**: Runner prompt cued authority mapping.

### S4: Sizing Independence from Risk & Verification (T04)
- **Host / Model**: Cursor Agent CLI (`Claude Opus 5.5 300K High`)
- **Role / Entry**: Task Intake (`ai-collab-start`)
- **Context**: 1-line authorization middleware bug fix checking `user.has_permission('admin')`. Prompt suggested "probably tiny (L1)".
- **Expected**: Preserves `Risk: H`; independent review requirement maintained; sizing remains informational and does not downgrade risk or skip verification.
- **Observed**:
  - **Immediate Routing**: Dispatched `Chief Designer` (`Current status: ready-for-design`, advisory tier `C4`). It did not dispatch straight to implementation or review, because risk H tasks require a design basis when technical gaps exist.
  - **Preserved Downstream Requirements**: The Operator Command explicitly preserved future implementation, independent review, and verification requirements, stating that "size does not set risk".
- **Validation**: Runtime validator on generated `.ai/handoff.md` exited 0 (expecting Chief Designer).
- **Conformance**: Complete match with risk independence criteria; immediate route was Chief Designer, while downstream independent review was preserved.

### S5: Evidence-Driven Progress vs. Stalled Boundary (T06 Negative)
- **Host / Model**: Primary host (Cursor) unavailable due to usage limit (`ActionRequiredError`). Executed on substitute host: Codex CLI.
- **Role / Entry**: Implementation Engineer
- **Context**: Active M-risk batch; 4 hours elapsed, two real boundaries passed, but no tests passing, rounding unknown unresolved, zero converging evidence.
- **Expected**: Evaluates progress by evidence rather than elapsed time; acknowledges stall; proposes single minimal corrective action; avoids arbitrary percentage completion.
- **Observed (Codex substitute)**: Evaluated progress strictly by evidence; explicitly identified that elapsed session time and file reading do not constitute progress; refused to invent percentage completion; proposed one bounded tax-bracket boundary check; routed to `continue`.
- **Conformance**: Complete match with behavioral criteria on substitute host. Primary host sample remains unavailable.

### S6: Review Circuit Breaker at Ceiling (T08)
- **Host / Model**: Primary host (Cursor) unavailable due to usage limit. Executed on substitute host: Codex CLI.
- **Role / Entry**: Code Reviewer
- **Context**: Review round 3; unresolved SQL parameter concatenation in `db.py`; no owner budget extension.
- **Expected**: Recognizes round 3 ceiling; strictly forbids autonomous 4th cycle dispatch; routes to `awaiting-owner-decision` with `Owner Decision Brief`.
- **Observed (Codex substitute)**: Recognized round 3/3 ceiling with zero remaining autonomous allowance; prohibited autonomous cycle; routed to `awaiting-owner-decision` with `Owner Decision Brief` recommending a bounded extension (rounds 3 through 4).
- **Limitation**: Final streaming event in raw transcript contained unescaped characters, requiring separate JSON parsing. Response fallback behavior was confirmed, but cross-host streaming serialization limits were observed. Primary host sample remains unavailable.

### S7: Sizing Guidance Reachability & Baseline Comparison (P1 / T07)
- **Host / Model**: Primary host (Cursor candidate and baseline) unavailable due to Opus usage limit. Executed on substitute host: Codex CLI (Candidate and Baseline v1.9.5).
- **Role / Entry**: Chief Designer
- **Context**: Fictional M-risk bulk notification feature; owner asks "大概多大改动和人工工作量？(Roughly how large a change and how much effort?)". No prior change baseline exists.
- **Observed Behavior Comparison**:
  - **Candidate Version (with anchor)**: The prompt card contains the anchor reference to `README.md#optional-sizing-and-effort`. The agent located the definition, but also executed search commands across documentation before reading the section. In its response, the agent accurately declined to invent numeric LOC or human effort ranges due to the lack of a baseline (sample SHA256: `CE80765A...`).
  - **Baseline Version (v1.9.5, without anchor)**: Lacking the anchor in `agent-prompts.md`, the baseline agent also performed search commands (`siz|effort|LOC|cloc`) across manuals, located the definition, and applied the same rule, declining numeric LOC and effort ranges (sample SHA256: `AC99C6DE...`).
- **Finding & Causal Limit**: Both candidate and baseline versions reached the shared definition and applied it correctly. The anchor provided a direct citation target; however, single-sample logs demonstrate that both agents performed search queries during documentation intake. The presence of the anchor did not eliminate keyword searching in this sample, and causality cannot be asserted from single runs.

---

## 3. Metrics Summary: Static Context & Dynamic Invocations

### 3.1 Static Required-Reading Context Measurement

All text measurements use LF-terminated UTF-8 byte lengths:
- README anchor sections use `###` headings. `### Optional Sizing And Effort` spans through the line before `## Related Documents`: **24 lines, 1,420 LF UTF-8 bytes** (1,419 bytes if the final trailing LF is excluded). `### Review Round Circuit Breaker` spans through the line before `## Technical Disposition Exit Contracts`: **86 lines, 5,604 bytes**.
- Role cards in `agent-prompts.md` end at the next peer `## <Role>` heading (Implementation Engineer ends at `## Code Reviewer`; Code Reviewer ends at `## Fix Engineer`, not `## Verification Reviewer`).
- Codex `Get-Content` combined outputs in S5-Codex and S6-Codex item_4 retain terminal LFs in rendered command output; totals in the scenario table use **rstrip-LF** byte counts (440 + 645 + 22 for S5; 370 + 548 + 21 for S6 substitute) and are not claimed as exact on-disk file snapshots unless sourced from first `readToolCall` or recorded read-only fixtures.
- Routing schema subtotal uses `handoff-schema.md` from `## Routing Section Schema` through the line before `### Expected state validation` (**3,973 bytes**, 81 lines). A legacy **2,842-byte** figure had no reproducible contiguous slice and is not used in totals.
- Workflow step contracts use each `workflows.md` `### N. <Name>` section through the line before the next numbered step (for example, `### 2. Design` through before `### 3. Architecture Review` is **9,139 bytes**, 179 lines).
- Runtime fixture bytes are taken from the first successful read in saved transcripts or from recorded read-only fixture paths, not from post-run writable outputs on the same tree.
- Task Intake role definition is contained in `skills/ai-collab-start/SKILL.md`, as `agent-prompts.md` does not have a separate `Task Intake` role card.

#### Bounded Shared-Document Subtotals
| Component | Baseline v1.9.5 Bytes (Lines) | Candidate Bytes (Lines) | Delta | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **`agent-prompts.md` (Entire file)** | 60,991 B (1,112 lines) | 61,212 B (1,115 lines) | +221 B | Shared role library |
| • **Common Preflight** (`agent-prompts.md#common-preflight`) | 11,716 B (177 lines) | 11,716 B (177 lines) | 0 B | Shared preflight baseline for all prompt roles |
| • **Chief Designer Card** (`agent-prompts.md#chief-designer`) | 8,985 B (150 lines) | 9,167 B (153 lines) | +182 B | Focus anchor reference added |
| • **Implementation Engineer Card** (`agent-prompts.md#implementation-engineer`; ends at `## Code Reviewer`) | 7,338 B (130 lines) | 7,377 B (130 lines) | +39 B | Effort anchor reference added; excludes Code Reviewer card |
| • **Code Reviewer Card** (`agent-prompts.md#code-reviewer`; ends at `## Fix Engineer`) | 7,666 B (129 lines) | 7,666 B (129 lines) | 0 B | Unmodified in candidate; prior 11,349 B slice incorrectly included Fix Engineer |
| **Task Intake Skill (`ai-collab-start/SKILL.md`)** | 4,947 B (94 lines) | 4,949 B (94 lines) | +2 B | Aligned to `Initial role`; serves as Task Intake role contract |
| **Target Sizing Anchor (`README.md#optional-sizing-and-effort`)** | 1,420 B (24 lines) | 1,420 B (24 lines) | 0 B | Unmodified section content |
| **Circuit Breaker (`README.md#review-round-circuit-breaker`)** | 5,604 B (86 lines) | 5,604 B (86 lines) | 0 B | `### Review Round Circuit Breaker` through before `## Technical Disposition Exit Contracts` |
| **CE Review Skill (`skills/ce-code-review/SKILL.md`)** | 5,373 B (102 lines) | 5,373 B (102 lines) | 0 B | Required present reading for Code Reviewer (S6 static total) |
| **Step Contract: 1. Task Intake (`workflows.md`)** | 10,095 B (186 lines) | 10,095 B (186 lines) | 0 B | Workflow step contract |
| **Step Contract: 2. Design (`workflows.md#2-design`)** | 9,139 B (179 lines) | 9,139 B (179 lines) | 0 B | Full step section through before `### 3. Architecture Review` |
| **Step Contract: 6. Implementation (`workflows.md`)** | 6,273 B (123 lines) | 6,273 B (123 lines) | 0 B | Workflow step contract |
| **Step Contract: 7. Formal Review (`workflows.md`)** | 4,398 B (93 lines) | 4,398 B (93 lines) | 0 B | Workflow step contract |
| **Handoff Schema (`handoff-schema.md`)** | 71,059 B (1,311 lines) | 71,059 B (1,311 lines) | 0 B | Shared schema reference |
| • Routing Section Schema slice (`handoff-schema.md`) | 3,973 B (81 lines) | 3,973 B (81 lines) | 0 B | Through line before `### Expected state validation` |
| **Templates (`templates/`)** | | | | |
| • `current-task.template.md` | 4,508 B (103 lines) | 4,508 B (103 lines) | 0 B | Task intake template |
| • `handoff.template.md` | 10,666 B (195 lines) | 10,666 B (195 lines) | 0 B | Handoff template |
| • `response-handoff.template.md` | 7,073 B (120 lines) | 7,073 B (120 lines) | 0 B | Response fallback template |

#### Per-Scenario / Per-Role Required Reading Accounting

Each total is formed by summing:
1. **Canonical Core**: Applicable Role Definition (role card or entry skill) + Common Preflight (11,716 B) + Step Contract in `workflows.md`.
2. **Canonical Anchors & Skills**: Referenced README anchors (S7: Optional Sizing 1,420 B; S6: Circuit Breaker 5,604 B) and, for Code Reviewer, the required present `ce-code-review` Skill (5,373 B) exactly once in static totals.
3. **Referenced Templates & Schema**: Mandatory handoff/task templates (Task Intake scenarios) and the Routing Section Schema slice (3,973 B).
4. **Runtime Inputs**: Exact fixture source code and initial handoff/task files.
5. **Conditional / Absent / Non-File Inputs**: Distinguishes inputs conditionally required by ambiguity or absent from specific test fixtures.

| Scenario | Role & Key Canonical Inputs | Canonical Subtotal Base / Cand (Delta) | Templates & Schema | Runtime Inputs | Full Required Context Base / Cand (Delta) | Conditional, Absent & Non-File Inputs |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **S1** (Intake Bypass) | **Task Intake**: `SKILL.md` (4,947 B -> 4,949 B) + Common Preflight (11,716 B) + Step 1 (10,095 B) | 26,758 B / 26,760 B (+2 B) | CT Template (4,508 B) + Handoff Template (10,666 B) + Routing Schema (3,973 B) = 19,147 B | `src/discount.py` (207 B; S1.jsonl first read) | **46,112 B / 46,114 B (+2 B)** | Conditional: Requirements Analyst card (9,654 B, skipped for clear scope). Absent: `.ai` files absent before intake. |
| **S2** (Scope Boundary) | **Chief Designer**: Role Card (8,985 B -> 9,167 B) + Common Preflight (11,716 B) + Step 2 (9,139 B) | 29,840 B / 30,022 B (+182 B) | Routing Schema (3,973 B) | `.ai/current-task.md` (728 B) + `src/exporter.py` (258 B) = 986 B (S2.jsonl first reads) | **34,799 B / 34,981 B (+182 B)** | Conditional: `openspec/changes/` artifacts (absent in fixture); prior handoff (absent at initial design). |
| **S3** (Authorized Abstraction) | **Chief Designer**: Role Card (8,985 B -> 9,167 B) + Common Preflight (11,716 B) + Step 2 (9,139 B) | 29,840 B / 30,022 B (+182 B) | Routing Schema (3,973 B) | `.ai/current-task.md` (429 B) + `src/exporter.py` (29 B) = 458 B (S3.jsonl first reads) | **34,271 B / 34,453 B (+182 B)** | Conditional: `openspec/changes/` artifacts (absent in fixture); prior handoff (absent at initial design). |
| **S4** (Sizing vs Risk) | **Task Intake**: `SKILL.md` (4,947 B -> 4,949 B) + Common Preflight (11,716 B) + Step 1 (10,095 B) | 26,758 B / 26,760 B (+2 B) | CT Template (4,508 B) + Handoff Template (10,666 B) + Routing Schema (3,973 B) = 19,147 B | `src/auth.py` (69 B; S4.jsonl first read) | **45,974 B / 45,976 B (+2 B)** | Conditional: Requirements Analyst card (9,654 B, skipped for clear scope). Absent: `.ai` files absent before intake. |
| **S5** (Stalled Progress) | **Implementation Engineer**: Role Card (7,338 B -> 7,377 B) + Common Preflight (11,716 B) + Step 6 (6,273 B) | 25,327 B / 25,366 B (+39 B) | Routing Schema (3,973 B) | `.ai/current-task.md` (440 B) + `.ai/handoff.md` (645 B) + `src/calculator.py` (22 B) = 1,107 B (S5-Codex.jsonl rstrip-LF; rendered 441 + 646 + 22) | **30,407 B / 30,446 B (+39 B)** | Absent: Prior boundary logs and test suite (stubbed/absent in fixture). |
| **S6** (Review Breaker) | **Code Reviewer**: Role Card (7,666 B) + Common Preflight (11,716 B) + Step 7 (4,398 B) + Circuit Breaker (5,604 B) + `ce-code-review` Skill (5,373 B) | 34,757 B (0 B delta) | Routing Schema (3,973 B) | **Codex substitute** (S6-Codex.jsonl item_4 rstrip-LF): `.ai/current-task.md` (370 B) + `.ai/handoff.md` (548 B) + `src/db.py` (21 B) = 939 B (rendered 371 + 549 + 21). **Primary-host fixture** (run-results `S6`, no `src/db.py`): `.ai` inputs 575 B. | **39,669 B** (substitute full context) / **39,305 B** (primary recorded path) | Attempted absent in substitute sample: `AGENTS.md`, `docs/reviews/README.md` only. Skill body also read successfully in transcript item_6 (dynamic access). |
| **S7** (Candidate Anchor) | **Chief Designer**: Role Card (8,985 B -> 9,167 B) + Common Preflight (11,716 B) + Step 2 (9,139 B) + Sizing Anchor (1,420 B) | 31,260 B / 31,442 B (+182 B) | Routing Schema (3,973 B) | `.ai/current-task.md` (501 B) + `src/notifications.py` (78 B) = 579 B (run-results `S7-Codex` read-only fixture) | **35,812 B / 35,994 B (+182 B)** | Conditional: `openspec/changes/` artifacts (absent in fixture); prior handoff (absent). |

##### Scenario Detail & Accounting Notes
1. **Task Intake (S1, S4)**:
   - Canonical Role Definition: `skills/ai-collab-start/SKILL.md` (Baseline 4,947 B -> Candidate 4,949 B, +2 B). Serves as the role contract since `agent-prompts.md` delegates intake execution to the Skill entry.
   - Common Preflight: 11,716 B (177 lines).
   - Step Contract: `workflows.md#1-task-intake` (10,095 B, 186 lines).
   - Templates & Schema: `current-task.template.md` (4,508 B) + `handoff.template.md` (10,666 B) + Routing Section Schema slice (3,973 B) = 19,147 B.
   - Runtime Inputs: `src/discount.py` (207 B, S1.jsonl first read) / `src/auth.py` (69 B, S4).
   - Conditional / Absent: Requirements Analyst role card (`agent-prompts.md#requirements-analyst`, 9,654 B) is conditional on business ambiguity and correctly skipped for clear tasks; `.ai/` state files do not exist prior to initial intake.
2. **Chief Designer (S2, S3, S7)**:
   - Canonical Role Card: `agent-prompts.md#chief-designer` (Baseline 8,985 B -> Candidate 9,167 B, +182 B).
   - Common Preflight: 11,716 B (177 lines).
   - Step Contract: `workflows.md#2-design` (9,139 B, 179 lines).
   - Optional Sizing Anchor (S7): `README.md#optional-sizing-and-effort` (1,420 B, 24 lines) is referenced when sizing guidance is needed.
   - Schema: Routing Section Schema slice (`handoff-schema.md`: 3,973 B, 81 lines).
   - Runtime Inputs (first transcript reads / recorded read-only paths): S2: 728 B + 258 B = 986 B; S3: 429 B + 29 B = 458 B; S7-Codex: 501 B + 78 B = 579 B.
   - Conditional / Absent: OpenSpec change artifacts and previous return handoffs were absent in the isolated mock fixtures.
3. **Implementation Engineer (S5)**:
   - Canonical Role Card: `agent-prompts.md#implementation-engineer` through `## Code Reviewer` (Baseline 7,338 B -> Candidate 7,377 B, +39 B).
   - Common Preflight: 11,716 B (177 lines).
   - Step Contract: `workflows.md#6-implementation` (6,273 B, 123 lines).
   - Schema: Routing Section Schema slice (`handoff-schema.md`: 3,973 B, 81 lines).
   - Runtime Inputs (S5-Codex.jsonl rstrip-LF): `.ai/current-task.md` (440 B), `.ai/handoff.md` (645 B), `src/calculator.py` (22 B) = 1,107 B (rendered Get-Content bodies 441 + 646 + 22).
   - Conditional / Absent: Prior verification logs and test suite were stubbed or absent.
4. **Code Reviewer (S6)**:
   - Canonical Role Card: `agent-prompts.md#code-reviewer` through `## Fix Engineer` (7,666 B, 129 lines; identical in baseline and candidate).
   - Common Preflight: 11,716 B (177 lines).
   - Step Contract: `workflows.md#7-formal-review` (4,398 B, 93 lines).
   - Circuit Breaker Anchor: `README.md#review-round-circuit-breaker` (`###` heading slice, 5,604 B, 86 lines).
   - Required present Skill: `skills/ce-code-review/SKILL.md` (5,373 B) included once in static canonical subtotal.
   - Schema: Routing Section Schema slice (`handoff-schema.md`: 3,973 B, 81 lines).
   - Runtime Inputs: distinguish **primary-host** `run-results` `S6` fixture (249 B + 326 B task/handoff; no `src/db.py` on saved path) from **Codex substitute** `S6-Codex.jsonl` item_4 rstrip-LF reads (370 B + 548 B + 21 B `src/db.py`; rendered 371 + 549 + 21).
   - Fixture Absent Attempts (substitute transcript): `AGENTS.md` and `docs/reviews/README.md` only. The canonical `ce-code-review` Skill was emitted successfully in transcript item_6 and must not be classified as absent.

### 3.2 Dynamic Scenario Invocations & Distinct Content-Read Files

Counting rules:
- **Cursor**: Counts initiated tool calls (`tool_call` started events); matches each read to its completed result by call ID. Categories are read, grep, glob, shell, and edit/write. Successful unique files count normalized paths with a successful `readToolCall` result. Shell contents are not added as more tool calls.
- **Codex command / invocation / operand**: Counts only completed command executions (`item.completed`, `item.type == 'command_execution'`), never their paired starts. A command can contain several `Get-Content` invocations; one invocation can name an array of file operands. Repeated operands count again as operations, but successful unique files count once after slash/case normalization. The external graph Skill counts as one successful file where actually read. Saved `Cannot find path` results identify failed operands, which are excluded from successful unique files; a nonzero command exit alone does not make every read fail.
- **Search / probe sites**: Separately counts syntactic sites in completed commands. Searches include content `rg`, in-memory `[Array]::IndexOf`, and file `Select-String`. Probes include `rg --files`, `Get-ChildItem`, and `Test-Path`. Reports both containing commands and sites; categories overlap within a command, so they are not summed into command totals. Sites inside conditional bodies are counted syntactically, without claiming they executed. In S7 baseline, two `rg --files` sites are guarded by `Test-Path`. Hash, Git and Python commands are outside these categories. Search inputs are not `Get-Content` read operands: for example S5's one `Select-String` names three files.
- **Reproducibility**: Fresh private `correction-metrics.py` / `correction-metrics.json` derive all rows from the saved completed results, recording source SHA256, line/item or call IDs, invocation/operand members, failed paths and normalized successful-path sets. The bounded lexer handles these samples' literal arrays and shell display quoting, rejects unsupported operand syntax, and never executes recorded commands. `--check` reproduces and compares the saved result. Original calculators and results are retained unchanged. This correction does not change the static byte measurements in section 3.1.

| Scenario | Host | Completed Calls / Commands | Operation Breakdown | Successful Unique Read Paths | Attempted Absent Reads | Immediate Route & Validator Exit Code |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **S1** (Intake Bypass) | Cursor | 19 tool calls | read: 10, grep: 4, glob: 1, shell: 2, edit: 2 | 10 files | 0 | Dispatched Implementation Engineer (C2); validator exit 0 |
| **S2** (Scope Boundary) | Cursor | 21 tool calls | read: 8, grep: 3, glob: 1, shell: 5, edit: 4 | 6 files | 0 | Dispatched Task Owner (awaiting-decision); validator exit 1 (fixture limit) |
| **S2-Codex** (Scope Boundary)| Codex | 11 commands | 8 read commands; 14 invocations / 14 file operands (12 successful / 2 failed); search: 4 commands / 8 sites; probe: 4 commands / 9 sites | 9 files | 2 (`AGENTS.md`, `.ai/handoff.md`) | Response fallback; dispatched Design Reviewer |
| **S3** (Authorized Abstraction)| Cursor | 13 tool calls | read: 8, grep: 2, glob: 1, shell: 1, edit: 1 | 6 files | 0 | Dispatched Task Owner; status awaiting-owner-decision; validator exit 1 (fixture limit) |
| **S4** (Sizing vs Risk) | Cursor | 20 tool calls | read: 12, grep: 1, glob: 2, shell: 3, edit: 2 | 10 files | 0 | Dispatched Chief Designer (C4); preserved review; validator exit 0 |
| **S5-Codex** (Stalled Progress)| Codex | 3 commands | 3 read commands; 6 invocations / 8 file operands (7 successful / 1 failed); search: 2 commands / 4 sites; probe: 0 / 0 | 6 files | 1 (`AGENTS.md`) | Routed `continue` (evidence stall); primary host unavailable |
| **S6-Codex** (Review Breaker) | Codex | 8 commands | 5 read commands; 13 invocations / 13 file operands (11 successful / 2 failed); search: 2 commands / 2 sites; probe: 1 command / 1 site | 9 files | 2 (`AGENTS.md`, `docs/reviews/README.md`) | Response fallback; `awaiting-owner-decision`; primary host unavailable |
| **S7-Baseline-Codex** | Codex | 8 commands | 8 read commands; 9 invocations / 13 file operands (11 successful / 2 failed); search: 3 commands / 5 sites; probe: 3 commands / 9 sites (2 conditional sites) | 7 files | 2 (`.ai/handoff.md`, `AGENTS.md`) | Located sizing rules via grep search; primary host unavailable |
| **S7-Codex** (Candidate Anchor)| Codex | 8 commands | 7 read commands; 12 invocations / 12 file operands (10 successful / 2 failed); search: 2 commands / 4 sites; probe: 3 commands / 6 sites | 9 files | 2 (`.ai/handoff.md`, `AGENTS.md`) | Located sizing rules via anchor + search; primary host unavailable |

Search sites by kind: S2 = 2 content `rg` + 6 `IndexOf`; S5 = 3 `IndexOf` + 1 `Select-String` (3 file operands); S6 = 2 content `rg`; S7 baseline = 1 content `rg` + 4 `IndexOf`; S7 candidate = 2 content `rg` + 2 `IndexOf`. Probe sites: S2 = 2 `rg --files` + 3 `Get-ChildItem` + 4 `Test-Path`; S6 = 1 `rg --files`; S7 baseline = 4 `rg --files` (2 conditional) + 3 `Get-ChildItem` + 2 `Test-Path`; S7 candidate = 1 `rg --files` + 5 `Get-ChildItem`. S5 has none. These are source-site counts, not a measure of successful searches or token use.

Successful-file member reconciliation (relative paths below use `docs/ai-collaboration/` as **manual/**; **graph Skill** denotes the external Skill without publishing its workstation path):

| Sample | Successful unique members |
| --- | --- |
| S2-Codex (9) | graph Skill; manual/agent-prompts.md; .ai/current-task.md; src/exporter.py; manual/templates/handoff.template.md; manual/templates/response-handoff.template.md; manual/workflows.md; manual/handoff-schema.md; manual/scripts/validate-runtime-state.ps1 |
| S5-Codex (6) | manual/agent-prompts.md; .ai/current-task.md; .ai/handoff.md; src/calculator.py; manual/handoff-schema.md; manual/workflows.md |
| S6-Codex (9) | graph Skill; manual/agent-prompts.md; .ai/current-task.md; .ai/handoff.md; src/db.py; manual/README.md; manual/handoff-schema.md; manual/workflows.md; manual/skills/ce-code-review/SKILL.md |
| S7-Baseline-Codex (7) | graph Skill; manual/agent-prompts.md; .ai/current-task.md; src/notifications.py; manual/README.md; manual/handoff-schema.md; manual/workflows.md |
| S7-Codex (9) | graph Skill; manual/agent-prompts.md; .ai/current-task.md; src/notifications.py; manual/templates/handoff.template.md; manual/templates/response-handoff.template.md; manual/handoff-schema.md; manual/README.md; manual/workflows.md |

#### S6 / S6-Codex File Access Reconciliation
- **Fixture version map**: `run-results.json` records primary-host `S6` at the saved temp fixture path (initial `.ai` files only; **no** `src/db.py` on that path today). The completed behavioral sample is **S6-Codex** (`S6-Codex.jsonl`) on a substitute read-only tree that included `src/db.py`; that substitute directory was not retained separately in `run-results`.
- **Transcript verification** (completed command `item_6` in `S6-Codex.jsonl`): chained `Get-Content` on `src/db.py`, `AGENTS.md`, `docs/reviews/README.md`, and `docs/ai-collaboration/skills/ce-code-review/SKILL.md` emitted `def query(sql): pass`, then two `Cannot find path` errors for `AGENTS.md` and `docs/reviews/README.md`, then the full canonical `ce-code-review` Skill body (`name: ce-code-review`, 5,373 LF bytes in `payload/`).
- **Consistent accounting rule** (current source-wide executable check: `.ai/link-sizing-pilot/correction-metrics.py --check` / `correction-metrics.json`; original `fix-05-metrics.py/json` retained):
  - **8** completed commands; **13** `Get-Content` operands (**11** successful content reads / **2** failed absent paths) across **5** read-containing commands (searches, enumeration, hashes, and writes are separate).
  - **9** successful distinct normalized read paths: external graph Skill, `agent-prompts.md`, `.ai/current-task.md`, `.ai/handoff.md`, `src/db.py`, `README.md`, `handoff-schema.md`, `workflows.md`, canonical `ce-code-review` Skill.
  - **2** attempted absent paths: `AGENTS.md`, `docs/reviews/README.md`.
  - One malformed final JSONL line remains a disclosed serialization limit; it does not change completed command results above.

---

## 4. Authentic Environment & Host Constraints

During execution, real-world constraints were observed and recorded:
1. **Primary Host Opus Usage Limit**: After scenario S4, Cursor Agent CLI exited with code 1 reporting an Opus usage limit (`ActionRequiredError`). As a result, primary-host samples for S5, S6, S7-Candidate, and S7-Baseline were unavailable. The exact error log and diagnostic details are preserved privately under `.ai/link-sizing-pilot/logs/S5.log`.
2. **Cross-Host Codex Execution**: In accordance with design decision 3, remaining scenarios were executed using the Codex CLI with zero added cost or accounts. These represent cross-host substitute samples, not completed Cursor executions.
3. **Sandbox Read-Only Fallback & Streaming Limitations**: Codex executions ran in read-only directories, triggering the canonical `handoff-schema.md#response-handoff-fallback`. In S6, streaming output contained unescaped characters in the final message event, showing that cross-host serialization requires careful handling.

---

## 5. Decision Outputs

### Decision 1: P2 Entry Criteria (Automatic Sizing & Statistics)
- **Evaluation**: The pilot shows that agents on both candidate and baseline configurations are capable of recognizing when a change lacks a baseline and declining to invent arbitrary line counts or human effort hours.
- **Risk Assessment**: Sizing remains an optional, informational description. Automated line-counting tools (e.g. `scc`, `cloc`) or mandatory numeric handoff fields introduce risks of false precision and inappropriate estimation gating.
- **Decision**: **P2 (Automatic Process Statistics) remains DEFERRED / PENDING DECISION**. It is not authorized for implementation. Sizing remains an optional planning property that does not dictate risk, capability tier, or verification requirements.

### Decision 2: Context Consolidation (Prompt & Schema Lean Guidance)
- **Evaluation**: Canonical per-scenario/per-role required reading ranges from **24.7 KiB to 33.9 KiB** (25,327–34,757 LF UTF-8 bytes: role/skill card or entry skill, Common Preflight, full numbered workflow step section, scenario anchors, and for S6 the required present CE review Skill). Adding Task Intake templates plus the Routing Section Schema slice (19,147 B for intake scenarios; 3,973 B routing slice for other roles) and initial runtime inputs yields full required reading contexts from **29.7 KiB to 45.0 KiB** (30,407–46,114 bytes: primary S6 recorded path **38.4 KiB** / 39,305 B; S6-Codex substitute **38.7 KiB** / 39,669 B; Task Intake **45.0 KiB**; Implementation **29.7 KiB** / 30,446 B; Design/S7 **35.0–35.2 KiB**). Loading the full shared `agent-prompts.md` adds **59.8 KiB** (61,212 B); loading the complete `handoff-schema.md` adds **69.4 KiB** (71,059 B) without recursive expansion. KiB figures use decimal division by 1,024 with one fractional digit.
- **Finding**: Review of role cards reveals repeated boilerplate instructions across all roles, including identical fallback response instructions, duplicate validation commands, and redundant review criteria.
- **Decision**: **Context consolidation is recommended as a future maintenance topic (Pending Decision)**. Proposed future targets:
  1. Consolidate repetitive handoff persistence and fallback response instructions into a single shared reference section;
  2. Streamline validator command examples;
  3. Keep role cards focused strictly on role-specific focus, boundaries, and outputs.
  *Note*: Consistent with CR-02 requirements, this recommendation is derived directly from bounded context byte measurements and retains uncertainty without claiming speculative token or runtime efficiency savings.

---

## 6. Limits & Caveats

- **Single Sample Scope**: Each scenario was evaluated on a single sample. Observations demonstrate capability and compliance under specific constraints, not statistical distribution or universal reliability across models.
- **Substitute Host Coverage**: Scenarios S5, S6, and S7 rely on Codex CLI observations due to primary-host Opus usage limits.
- **Prompt Cueing**: S2 and S3 prompts included guidance that assisted Minimal Option mapping.
- **Non-Installation Fixtures**: Fixtures were isolated directory trees containing relevant documentation and mock source files; they do not represent fully installed host plugins.
- **Privacy & Sanitization**: This document contains no verbatim session responses, private workstation paths, or raw credentials. All statements refer to sample identifiers and hashes recorded in `.ai/link-sizing-pilot/`.
