# EngRelay · A workflow kit for AI coding agents

**Keep small tasks simple. Clear handoffs. Evidence-backed delivery.**

[简体中文](README.zh-CN.md) · [Quickstart](docs/quickstart.md) · [Role contracts](payload/docs/ai-collaboration/README.md) · [Sources and licensing](THIRD-PARTY-NOTICES.md)

EngRelay (Engineering + Relay) is a practical workflow kit for AI coding agents
working in existing repositories. It provides role prompts, task and handoff
templates, independent reviews based on risk, and tools for checking the evidence
used to call work complete.

**Version 2.0.0** · [Download the complete package](https://github.com/calvinfungcn/engrelay/releases/tag/v2.0.0) · [MIT License](LICENSE)

## Workflow profiles (v2 default, 2.0)

`scripts/manage.ps1` supports `-WorkflowProfile v2|full|lite`.
Fresh installs now default to **v2** (`WorkflowMode=optional`, `SkillTarget=none`);
existing `full` and `lite` installations retain their recorded profile when
`-WorkflowProfile` is omitted on `Upgrade`, `SetMode`, `Status`, or `CheckVersion`.

- **v2 (default for new installs)**: lean cross-platform OpenSpec relay (`docs/engrelay/RULES.md` + unified `engrelay` Skill, hard budget ≤ 150 lines combined), three modes (`plan` / `do` / `review`), orthogonal **Risk (`S|M|H`)** gates + **Difficulty (`C1–C5`) × Workload (`XS|S|M|L` × `可断点|建议连续`, meaning breakable or preferably continuous)** sizing, ≤15-line cross-platform checkpoints, hard 2-round review circuit breaker, per-change `.ai/relay/<change-id>/` state, project-owned `docs/engrelay.config.md`, and optional single-target Skill discovery copy. See [EngRelay v2](payload/docs/ai-collaboration/v2/README.md).
- **Full & Lite (frozen legacy profiles)**: pass `-WorkflowProfile full` or `-WorkflowProfile lite` explicitly for new installs that want the v1 role chain (`docs/ai-collaboration/`) or v1 Lite sequential queue (`docs/engrelay-lite/`).

```powershell
# Default fresh install (v2, optional mode, SkillTarget none)
& ./scripts/manage.ps1 -Action Install -ProjectRoot $engrelayProject
# v2 with a single host discovery copy of the unified engrelay Skill
& ./scripts/manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowProfile v2 -SkillTarget cursor
# Explicit legacy Full or Lite install
& ./scripts/manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowProfile lite -SkillTarget none
```

Tests use isolated complete working-tree packages; the source checkout is not an
installation source. Verification on this workstation ran across Windows PowerShell 5.1
and PowerShell 7.6.10 (`test-v2-workflow.ps1`, `test-workflow-profiles.ps1`,
`test-human-doc-lifecycle.ps1`, `test-public-package.ps1`, plus `test-lite-state.ps1` on PS 5.1)
alongside disposable fictional `v2` drills (independent second-session `do` continuation and
independent two-round `review`); external Codex/Cursor/Claude host loading remains unverified locally.
New installations use manifest v2; trusted v1 Full converts only through Upgrade.
The original v1.9.6 manager refuses v2. Keep the matching complete package, manager
and original recovery material. Upgrade, repeated Install and SetMode never switch
profiles: preserve evidence, coordinate project entries, then use protected
Uninstall/Install for an explicitly requested switch. Project-owned Lite config
and runtime survive upgrade/uninstall; ordinary package drift still refuses.
Private Lite is not automatically adopted, and unfinished tasks are not migrated.
The existing entry-file baseline shows 86.3% fewer static AGENTS.md bytes in Lite;
this is not a reduction in total context, tokens or latency. Single-artifact task/review
records are a protocol design, not proof of runtime adherence. The bounded Phase 3
S/M/H and queue pilot has invocation evidence; results and review status are recorded
in the source review history. Separately, this context/feedback improvement received
independent review on one S continuation and one normal M implementation. Fixed-input
evidence used text only. Evidence does not establish all-host adherence or token
savings. Read the matching package's complete inventory before installation.

## What you get

| Capability | What it helps you do |
| --- | --- |
| Requirements clarification and task routing | Start with a clear goal; clarify material business ambiguity before design |
| Collaboration based on risk | Assign design, implementation, independent review and verification as the task requires |
| Resumable handoffs | Continue in another agent session using recorded scope, next action and evidence |
| Four CE method Skills | Review code (`ce-code-review`), diagnose root causes (`ce-debug`), simplify scoped changes (`ce-simplify-code`) and capture reusable lessons (`ce-compound`) |
| Read-only checks and knowledge lookup | Diagnose installation state, validate handoff structure and search recorded solutions |
| Protected package management | Install, upgrade and uninstall with ownership checks that protect project content and report conflicts |

For example, a feature request can follow this path:

```text
Request -> clarify requirements when needed -> design when needed
        -> implement and check -> independent review when required
        -> hand off remaining work or close with evidence
```

Small tasks stay with one responsible agent when their risk permits it. The
roles define responsibilities; this example does not require a separate session
for every step. See the [operator guide](payload/docs/ai-collaboration/operator-guide.md)
for entry selection and handoffs.

## How it works

- Keep ordinary small tasks with one responsible agent. Roles describe
  responsibilities; they do not require a new chat for every step.
- Use one primary workflow per task. Installation defaults to `optional`:
  storing the kit does not activate the role workflow.
- Introduce independent code review for medium-risk work and independent
  verification where high-risk work requires it.
- Record one next action: `continue`, `dispatch`, or `close`. A dispatch includes
  a complete command the next agent can use without the preceding chat. New Full
  tasks default to manual relay on formal agent dispatch: the agent saves, reads back,
  and validates the handoff, places a top human transfer notice, explains the next role,
  capability tier (C1–C5) and Operator Command in chat, and ends the turn for the operator
  to relay it; it does not launch the successor via subagents, external CLIs, or APIs.
  The current role must prepare and save that dispatch before stopping. A true owner-decision wait
  uses status `awaiting-owner-decision`, `Human Action Required: awaiting-decision`, and a brief describing the same decision.
  Explicit automated progression applies only when authorized in Constraints and supported
  by the host. In-role micro-steps and user-launched executable `continue` proceed directly.
  Lite retains its default sequential queue for active agents, supporting opt-in manual relay.
- Responsible roles work continuously towards agreed observable outcomes within
  authorized scope, running directly relevant development checks and grouping fixes
  before formal review nodes. Distinguish development checks, controlled trials, and
  final acceptance: controlled trials describe supported capabilities and unverified
  items without auto-passing or adding owner approval gates. Hazardous paths touching real
  devices, money, production data, or external deployments must first be fixed, disabled,
  or isolated under authorized conditions; risk H required independent review and post-repair
  independent verification cannot be bypassed.
- When two consecutive repair-and-independent-review loops for the same unfinished mapped
  acceptance occur and another formal repair or review cycle is planned, synthesize confirmed
  improvements, remaining blockers, and minimal aggregated repair/evidence plan in existing
  records before entering that cycle. Regrouping is not a verdict, does not increment Review
  round, does not alter cumulative review history, and does not add a default review cap or
  auto-stop; once recorded, does not re-trigger until two new actual loops occur; merges with
  stall analysis if applicable; finite ceilings and manual relay are preserved.
- Finding triage separates blocking defects, unverified gaps, and deferrable suggestions:
  real risks (security, identity, concurrency, data, money, contracts) cannot be
  downgraded to style or auto-passed. Project-required mechanical formatting fixes that lack
  explicit advance-review requirements combine with related fixes and subsequent checks
  without a dedicated formal round. Changes that affect inputs or covered behavior
  invalidate prior evidence, while matching unchanged evidence continues to be reusable.
- Goal-driven requests ("implement feature X") authorize achieving outcomes within scope
  without waiving explicit review requests, rule-mandated independent reviews, or manual
  relay. When the user explicitly specifies executing only the current role, the role
  completes authorized work and stops without executing the next role; when routing to another
  role via dispatch, it prepares and saves the successor handoff and adds the human transfer
  notice, preserving clean close and owner waits.
- Complete review before archive covers all authorized acceptance, final diff,
  compatibility, evidence correspondence, documentation, and delivery privacy in
  one aggregated round. Renaming unfinished work preserves cumulative verdicts
  without reset; authorized single reviews at capacity or post-closure do not grant
  new fix cycles. Evidence must correspond to claimed entrypoints and results
  (unverified if lacking). Focused rechecks reuse matching evidence for unchanged
  inputs, while shared contract changes or invalid evidence expand checks along the
  blast radius. Review artifacts remain privacy-safe, and bounded archive checks
  verify spec sync and completeness, ending on pass.
- Handoff `Human Action Required` shows whether a person needs to act now.
  Under manual relay dispatch the field remains `none` (no business decision or environment
  blocker); disclose the known limitation that legacy machine consumers might read it literally.
  Non-shared tools use minimal vetted excerpts and response handoff fingerprint matching; tool
  separation does not establish review independence.
  Later environment notices require no current action or reply. Executable
  `continue` includes a self-contained Continuation Command; an active capable
  agent proceeds within existing authorization and chooses its local CLI/IDE host.
  A runner ending its turn does not mean work is environment-blocked. This kit
  provides resumption instructions, not automatic process wake-up; see
  [autonomous continuation](payload/docs/ai-collaboration/handoff-schema.md#autonomous-continuation).
- Recovering a superseded handoff reads only the review record linked by the index or
  a result or response path that the live handoff (including Next output files) or the
  current task names. A new container requires a real SHA256 fingerprint; only legacy
  index-linked review records and legacy response handoffs may omit it. A batch restores
  at most one pending transfer, and any conflict blocks it. The action section is
  compared before a transfer counts as applied. A session that takes over a continue
  increments `State revision`. A planned same-role session end is a handoff boundary;
  a long check may keep one checkpoint with its external log, stated as not yet passed.
- Project-owned historical statements outside the managed block are coordinated inside
  the project; installing or upgrading the package does not rewrite them.
- Agent dispatch must include one advisory capability line (`Recommended capability
  tier: C1`–`C5`) under handoff `Current Status` to hint at model strength for
  the next work item; see
  [capability tier guidance](payload/docs/ai-collaboration/handoff-schema.md#capability-tier-guidance).
  It is not a blocker or model certification. Older handoffs without it stay valid.
- An unavailable environment or unverified entrypoint is recorded as a gap with its Resume
  condition, never as a lower rating for the implementer. A recorded unmet check is not
  redispatched while the environment, inputs and related code or configuration are unchanged; a relevant change first triggers a readiness check, and simulated results never
  stand in for the real entrypoint. Tool, model and reasoning choices stay with you.
- Reference reuse is limited to material already read in the same session and known
  unchanged; a new agent, missing context, a changed input or a rule question triggers a reread.
- An independent review of an implementation or fix adds one advisory 1–5 delivery rating
  by default, or `not scored`, to the existing review record, and the final response briefly
  repeats it. It does not change acceptance, routing or the review count.
- Progress is shown as an observable outcome, its evidence, and remaining work in the
  existing handoff sections. Rough sizing and human effort are optional, never gate
  routing, and are not a completion percentage.
- A real handoff boundary is saved, read back and checked against the expected
  batch, action, next role and Review round decided for it. A read-only review
  result is saved by the active writing agent, or kept as a complete response
  handoff when no permitted writer remains. Recovery matches fingerprints and
  never recounts a verdict. These checks do not wake processes or prove
  authenticity; see [expected state validation](payload/docs/ai-collaboration/handoff-schema.md#expected-state-validation).
- Match verification to the affected behavior. A successful structure check
  does not prove correct business behavior or a working host integration.
- Ordinary `accepted` closure requires a successful structure check on the
  **final** handoff inputs with command, exit code, and input correspondence
  and diagnostics recorded outside the validated handoff; see
  [accepted closure validation](payload/docs/ai-collaboration/handoff-schema.md#accepted-closure-validation).
  Source-repo follow-up status (deferred demo work, trials, and roadmap items)
  is tracked in the
  [OpenSpec navigation](https://github.com/calvinfungcn/engrelay/blob/main/openspec/README.md)
  on GitHub, not in installation exports.

The role workflow uses OpenSpec as its requirement and task authority. Installing
the kit does not install or initialize OpenSpec, or chain another orchestrator.
See the [maintained role contracts](payload/docs/ai-collaboration/README.md).

## Install or upgrade

Use a trusted complete package in its own directory. Back up the target project's
rules and read its existing agent instructions. For a new project:

Download `engrelay-2.0.0.zip` from the release and extract it. Run commands from
the extracted `engrelay-2.0.0` directory. Keep that complete package unchanged;
extra tool files or edited bytes make it differ from its inventory. The repository
source can also be used when its file set and bytes exactly match `snapshot.json`.

```powershell
$engrelayProject = 'E:\Projects\your-project'
& .\scripts\manage.ps1 -Action CheckVersion -ProjectRoot $engrelayProject
# Default SkillTarget is none: canonical Skills only (read under the target project).
& .\scripts\manage.ps1 -Action Install -ProjectRoot $engrelayProject -WorkflowMode optional
# For Codex host discovery on a new install, choose one target explicitly:
# & .\scripts\manage.ps1 -Action Install -ProjectRoot $engrelayProject -SkillTarget agents -WorkflowMode optional
& .\scripts\manage.ps1 -Action Status -ProjectRoot $engrelayProject
& .\payload\docs\ai-collaboration\scripts\doctor.ps1 -WorkspaceRoot $engrelayProject -PackageRoot $PWD.Path
```

On first successful Install, the manager keeps the original success line on the
PowerShell success stream and adds short guidance on the information stream
(selected target, canonical read path, and discovery path when applicable). Host
loading remains unverified. To hide only that guidance, redirect stream 6:
`6>$null` before or after the Install call. Merging streams or capturing native
process screen text may include the extra lines.

Use official `Upgrade` when the project already has a valid managed manifest.
Use `Adopt -Preview`, then `Adopt`, only for a recognized unmanaged legacy layout.
Conflicts report a concrete path; keep local edits and resolve them before retrying.
The manager has no force-overwrite mode. The commands below cover the usual operations.

Windows PowerShell 5.1 and PowerShell 7 on Windows are the intended script hosts.
Other operating systems are not claimed as verified installation targets.
An execution-policy restriction may require your organization's approved launch
method; the kit does not change global execution policy.

### Upgrade, adopt, or uninstall

Run from the trusted package root, with the target variable above:

```powershell
# Existing valid managed installation
& .\scripts\manage.ps1 -Action Upgrade -ProjectRoot $engrelayProject

# Recognized legacy layout WITHOUT a manifest; preview is read-only
& .\scripts\manage.ps1 -Action Adopt -Preview -ProjectRoot $engrelayProject -WorkflowMode optional
& .\scripts\manage.ps1 -Action Adopt -ProjectRoot $engrelayProject -WorkflowMode optional

# Remove only unchanged package-owned content
& .\scripts\manage.ps1 -Action Uninstall -ProjectRoot $engrelayProject
```

These are alternative routes; do not run all of them in sequence. Upgrade keeps
mode, SkillTarget, original backups, project rules, OpenSpec, reviews, solutions,
and `.ai` evidence. Uninstall preserves project content and later edits outside
managed blocks. Keep recovery material in `.ai-collaboration-install/` private.
Never remove an invalid manifest to force Install or Adopt. Reconcile the reported
conflict; use the trusted old package when planning rollback.

`CheckVersion` compares with the specified local package, not the newest version
on the internet. `doctor` is read-only and does not start an application, host or
installer. Warnings and unknown host-loading results remain relevant at exit0.

### Mode and Skill copies

| Mode | Meaning |
| --- | --- |
| `optional` | New-install default; explicit current-task selection activates the workflow |
| `default` | Project default; an explicit task choice may select another workflow |
| `disabled` | Keep files; explicitly re-enable before use |

```powershell
& .\scripts\manage.ps1 -Action SetMode -ProjectRoot $engrelayProject -WorkflowMode optional
```

Canonical Skills are installed without package-managed discovery copies by default
(`none`). For the default **v2** install, read the unified Skill directly at
`docs/engrelay/skills/engrelay/SKILL.md` (alongside `docs/engrelay/RULES.md`). For an
explicit `-WorkflowProfile full` install, read the matching canonical Skill directly,
for example `docs/ai-collaboration/skills/ai-collab-start/SKILL.md`. Either is a valid
install; you do not need to reinstall just to use the workflow.

To add host discovery copies during the **first** Install, pass exactly one
`-SkillTarget`. For new Codex setups, prefer `-SkillTarget agents` (`.agents/skills`).
`-SkillTarget codex` remains supported for `.codex/skills` compatibility. Other
targets are `claude`, `cursor`, `opencode`, `antigravity`, `gemini`, `iflow`, and
`qwen`. For `v2`, this copies only the unified `engrelay` Skill; for `full`, it copies
the seven `full` Skills; for `lite`, `SkillTarget` must be `none`. Repeat Install and
Upgrade do not add or switch targets. Changing target
requires official uninstall/reinstall; the manager does not migrate or remove
hand-maintained copies for you. Do not overwrite unrelated same-name Skills or run
the inherited all-target installer. Placement does not prove host loading.

## First handoff trial (Full profile)

The source repository includes a fixed, source-only sample under `examples/handoff-demo/`.
It is excluded from the package and from GitHub's automatic source ZIP, so use a Git
checkout of a commit that contains it. Follow the [quickstart](docs/quickstart.md) with
`-WorkflowProfile full` for the three directories and the Session A to Session B steps. Sample source commit
`304aa95702f106da262bcc741576293dfbeddc8d` was retrieved from GitHub and its eight
fixture files verified. This does not prove host loading or the external ten-minute target.

## Talk to an agent

### Default v2 workflow (`plan` / `do` / `review`)

Human guide: [EngRelay v2](payload/docs/ai-collaboration/v2/README.md)
([简体中文](payload/docs/ai-collaboration/v2/README.zh-CN.md)). Start with an active
OpenSpec change, and read `docs/engrelay/RULES.md` +
`docs/engrelay/skills/engrelay/SKILL.md` (or let a copied `engrelay` Skill guide you):

```text
Use EngRelay v2: read docs/engrelay/RULES.md and docs/engrelay/skills/engrelay/SKILL.md,
then run plan for openspec/changes/<change-id>/.
```

```text
Use EngRelay v2: read .ai/relay/<change-id>/board.md and wp-01.md, then run do WP-01.
```

```text
Use EngRelay v2: in an independent session, run review WP-01 against
.ai/relay/<change-id>/board.md and wp-01.md.
```

### Full profile entries (`-WorkflowProfile full`)

Human guides for Full: [quickstart](docs/quickstart.md)
( [简体中文](docs/quickstart.zh-CN.md) ),
[operator guide](payload/docs/ai-collaboration/operator-guide.md)
( [简体中文](payload/docs/ai-collaboration/operator-guide.zh-CN.md) ),
[project adoption](payload/docs/ai-collaboration/project-adoption.md),
[host capabilities](payload/docs/ai-collaboration/host-capabilities.md).
Contributing, development, changelog, licensing, and OpenSpec navigation also
have paired language editions at the repository root and under `docs/` /
`openspec/`. Agent contracts stay English-only.

**Recommended (Full) — start a task** (`ai-collab-start`):

```text
Use ai-collab-start: implement the confirmed order-export requirement.
Use EngRelay for this task. Communicate in English.
```

Clear goals route by risk without a fixed requirements stage. Material business
ambiguity runs the same conditional Requirements Analyst contract in the same
session; you do not need a separate `ai-collab-requirements` call. Technical
questions with a clear business goal go to Chief Designer.

**Optional — requirements-first dialogue** (`ai-collab-requirements`):

```text
Use ai-collab-requirements: I want an order-export feature.
Discuss the requirements with me first. Communicate in English.
```

**Resume recorded work** (`ai-collab-continue`):

For a closed batch, the reply gives the evidenced result, remaining or unknown scope,
no next role, and one applicable next step. A clear, authorized follow-up uses the
existing Task Intake in the same session, preserving old closure and cumulative
review limits; a bare “continue” selects parent work only under a recorded standing
authorization with exactly one unambiguous ready item, otherwise it names the
candidates and chooses none. Read rules for the
actual route and reuse only already-read, known-unchanged session references.
Lite keeps its own approved queue: ready items continue; otherwise it reports
pending approval/dependencies and a Lite next step, without invoking Full Skills.

When a design role finishes, Full either dispatches the implementer for work the same
batch still maps, or closes a genuinely independent design deliverable with the parent
remaining work and one copyable request. See the
[design-to-implementation relay](payload/docs/ai-collaboration/README.md#design-to-implementation-relay).

Scope sources stay minimal. Say the overall result you want and whether this round is
design, planning, estimate or implementation; an agent keeps the overall goal, the
current role and your actual authorization distinct. A design-only round does not cancel
an earlier implementation authorization, and a missing command is not a prohibition
([task scope evidence](payload/docs/ai-collaboration/README.md#task-scope-evidence)).

```text
Use ai-collab-continue: continue the latest authorized handoff.
```

Without a host discovery copy in an explicit `-WorkflowProfile full` install, ask the agent to read the matching canonical
`docs/ai-collaboration/skills/<name>/SKILL.md` in the installed project directly.
Reading a Skill or discovering `.ai/` alone never activates the workflow.

For **Full** (`-WorkflowProfile full`), the seven canonical names are retained: the three entries above plus
`ce-code-review`, `ce-debug`, `ce-simplify-code`, and `ce-compound`. The CE Skills
provide techniques within the assigned role; they add no second lifecycle. (Default **v2** installs deploy only the unified `engrelay` Skill under `docs/engrelay/skills/engrelay/SKILL.md`.)

## Review limits and cost

Completed design, code, verification and adjudication verdicts accumulate within
the batch and are kept for traceability; the count alone does not block normal
work. If problems remain at a reached finite-extension ceiling, or after a confirmed
same-finding stall whose one technical analysis still needs an owner decision, the responsible agent explains the cause, viable options, costs and a
recommendation to the task owner. It does not unilaterally end the project.
Further cycles require applicable explicit finite owner authorization under the
[review rule](payload/docs/ai-collaboration/README.md#review-round-circuit-breaker).
Changing roles, names or wording never resets the count.

Use focused checks and reuse evidence only when inputs match. Before substantial
low-benefit or unexpectedly costly work, explain the benefit, cost/unknowns,
smaller option and recommendation, and obtain the owner's choice. Passing tests
cannot erase a concrete behavior or evidence defect.

## Existing ai-collaboration users

EngRelay is the public brand of the kit previously called `ai-collaboration`.
The package keeps `docs/ai-collaboration/`, `.ai-collaboration-install/`, managed
block markers, role anchors, machine fields, and the seven Skill names for upgrade
compatibility. Explicitly selecting EngRelay selects that same workflow.
Use official Upgrade; do not delete a manifest or rename installed paths manually.

## Contents and limits

| Path | Purpose |
| --- | --- |
| `payload/` | Deployable role rules, templates, Skills, examples, and read-only tools |
| `agent-rules.md` | Activation and workflow rules inserted into a managed project entry |
| `scripts/manage.ps1` | Official install, adoption, status, version, upgrade, mode, and uninstall operations |
| `scripts/supported-layouts.json` | Exact known historical layout fingerprints and allowed transitions |
| `snapshot.json` | Package version, exact file sizes, and SHA256 inventory |
| `README.md`, `README.zh-CN.md` | English and Simplified Chinese overview and usage |

The kit does not run a background scheduler, switch models on a timer, deploy
business code, automatically commit, or guarantee that a host follows instructions.
SHA256 detects unexpected byte changes; it is not a publisher signature.

## Contributing and licensing

Read [CONTRIBUTING.md](CONTRIBUTING.md). Include observable behavior, a small
proposed change, and relevant evidence. Keep personal project data and runtime
handoffs out of contributions.

Development starts from a clone of this repository. Follow the
[development guide](docs/development.md); maintain requirements in OpenSpec and
export a clean package for installation checks. Keep the downloaded release
package unchanged instead of installing from a tool-populated development checkout.

EngRelay's original material is available under the [MIT License](LICENSE).
Third-party notices remain applicable; see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
The four CE method Skills selectively adapt
[Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin)
and retain Every's copyright and MIT notice. References to
[Superpowers](https://github.com/obra/superpowers) concern methods and coexistence
with separately installed local tools; the public package does not bundle it
or require it to be installed. EngRelay is an independent project and claims
no affiliation with or endorsement by either upstream project.
The recorded OmO influence is mechanism-level inspiration expressed in local
rules. OmO's own restricted text and code are not granted new rights by this license.
