## EngRelay Alias

EngRelay is the public package alias for ai-collaboration. Selecting EngRelay
explicitly selects the same ai-collaboration workflow; role, field, and
WorkflowMode semantics remain unchanged.

## ai-collaboration Workflow (conditional)

### Select before applying these rules

Read the project WorkflowMode declaration supplied in this managed block.
- optional: activate only when the current task explicitly selects ai-collaboration.
- default: use ai-collaboration unless the current task explicitly selects another workflow.
- disabled: do not activate; first honor an explicit request to re-enable this mode.
An explicit current-task choice takes precedence over a project default.
The presence of .ai, these documents, role names or discoverable Skills does not
select the workflow. Consultation about the package does not activate it.
When inactive, the runtime, role routing, validation and package CE requirements
below do not apply; follow the selected project workflow. Existing project facts,
module guides, security rules and explicit instructions still apply.

Multiple workflow packages may coexist. Use one primary controller per task;
do not chain another controller into this role graph or delete its instructions.
When switching unfinished work, preserve evidence and remaining acceptance in a
short continuation summary; never fabricate accepted closure. Package lifecycle
operations do not launch a business batch.

The following sections apply ONLY when ai-collaboration is selected.
Use the current project root, not a source example's WM path.

### Authority and scope

- Active OpenSpec requirements, design and tasks are the requirement authority.
  Do not invent a parallel plan, change-id or new requirement.
- Current code and fresh tests/runtime evidence determine actual behavior.
- Read module AGENTS.md/CONTRIBUTING.md before touching a module. Preserve
  project-specific build, runtime, permission, encoding and Git constraints.
- Read docs/ai-collaboration/README.md at actual role transfer or when producing
  handoff; read the assigned role in agent-prompts.md and workflows.md.
- One responsible agent may perform adjacent non-independent actions. Roles
  are responsibilities, not mandatory new sessions.
- The mapped Execution Batch in `.ai/current-task.md` is the phase scope; its
  OpenSpec tasks define acceptance. This block adds no requirement, role,
  status or approval gate.
- A new session, changed input or uncertainty requires rereading the current
  task, handoff and assigned role card. A link, memory or this block does not
  replace that scoped reading; same-session reuse is allowed only for material
  known to be unchanged.

### Runtime and exit rules

- Use .ai/current-task.md and .ai/handoff.md only for a task that explicitly selects
  the ai-collaboration workflow;
  templates live in docs/ai-collaboration/templates. Do not copy another
  project's live state. Keep runtime state out of Git.
- At transfer, wait, interruption or completion declare dispatch, continue or
  close under handoff-schema.md. Agent dispatch needs a self-contained Operator
  Command; real human decisions use Owner Decision Brief.
- Foreseeable human-only prerequisites must be explained before dependent
  dispatch. Environment waits use continue/blocked and a resume condition.
  For immediate human intervention, state where to act, what to do and the
  smallest useful reply in plain language;
  provide verified paths/snippets only when relevant, not invented filler.
- Validate real handoff boundaries with
  docs/ai-collaboration/scripts/validate-runtime-state.ps1. This is structure
  validation, not proof of authorization, independence or business acceptance.
- Classify S/M/H by actual impact. Keep M review and H verification independent.
  Close a bounded batch without reopening unrelated parent work.
- Track cumulative completed review verdicts (design, code, verification and
  adjudication). Dispatch states the remaining capacity when it affects the next
  action. Three is the default autonomous allowance; at three verdicts, only
  evidence-supported acceptance, the Task Owner decision route, or a route
  covered by an applicable finite owner authorization under
  docs/ai-collaboration/README.md#review-round-circuit-breaker is allowed.
  No fourth autonomous fix/design/review loop and no reset
  by role change, REVISE or a new file.
- Stay in role for stable-scope local work: continue with the same agent and
  record the step. Escalate to Chief Designer only for a material change in
  scope, acceptance, risk or authority; H escalation keeps independent
  verification.
- Apply handoff-schema.md#autonomous-continuation: after checking latest authority,
  allowance and execution ownership, a capable active agent executes authorized
  continue immediately. A replacement session retains role/batch/review count and
  records its actual agent. Local CLI/IDE host choice for offline work is not an
  owner decision; a runner turn exit is not an environment blocker. Actual waits,
  permissions, independent reviews and formal dispatch still govern.
- New/updated handoffs show Human Action Required; executable continue adds its
  Continuation Command under Current Status. Later-only environment notices are
  neutral, with no current action or reply request. Only immediate unmet human
  setup uses awaiting-environment. This does not add process wake-up or scheduling.
- Code review reports every high-confidence actual defect in one aggregated
  round, without a fixed count cap. Preferences, style and mock strictness are
  advisory; passing tests do not erase a concrete behavior or evidence defect.
  Design review blocks only executable barriers (unsupported necessity, invalid
  reference or starting point, contradiction, or a check that cannot run).
- Stop and resume: record valid progress, remaining work, evidence and the
  Resume condition in the existing handoff sections. Wait with `continue` plus
  `blocked`. For a delayed message, compare it with the current revision and
  evidence first; do not repeat dispatch or reopen closure because of an old
  notice.
- Human steps name the exact verified file or CLI path with a copy-ready snippet,
  or the application screen and action for UI-only work. Material decisions use
  the Owner Decision Brief; routine preparation does not.
- Closure outcome is accepted/stopped/superseded. Ordinary accepted needs
  evidence. Chief Designer may record scoped owner acceptance of incomplete
  work with Acceptance basis: owner-decision and Task Owner decision, keeping
  incomplete tasks unchecked and verification limits explicit. Stopped or
  superseded also require explicit applicable owner authorization; otherwise
  await owner decision. Closure does not authorize Git merge or deployment.
- Chief Designer and Requirements Analyst disclose foreseeable adverse effects
  and a smaller/safer option rather than blindly implementing a known flaw.

### Package-managed CE deployment override

For this package-managed installation, this override takes precedence over the
deployment instructions in docs/ai-collaboration/README.md and
compound-engineering.md: their all-target install/check/quarantine guidance is
historical and inapplicable. Do not run the inherited
docs/ai-collaboration/scripts/install-compound-skills.ps1 for package deployment.
Read docs/ai-collaboration/skills/<name>/SKILL.md directly by default. Only the
original package's scripts/manage.ps1 may deploy one optional SkillTarget during
installation, tracked by its ownership manifest. Changing that target requires
package uninstall/reinstall. Do not create additional unowned copies or remove
or quarantine unrelated Skills. This exception changes deployment ownership,
not the capability methods or the active workflow's requirement/review contracts below.

### Review, capabilities and evidence

- Formal root OpenSpec reviews use docs/reviews/README.md, fresh round files and
  index.md. Preserve old artifacts; findings are open, fixed-not-verified,
  verified or deferred. Verified requires fresh evidence.
- Read-only means no writes unless specific artifacts were authorized. A formal
  dispatch names its writable handoff outputs and does not add an unsourced
  `.ai/` write ban. Response-only consultation stays in chat and does not create
  runtime state.
- Selected local CE capabilities follow docs/ai-collaboration/compound-engineering.md:
  ce-code-review, ce-debug, ce-simplify-code and ce-compound. Read canonical
  SKILL.md directly if no host discovery copy is installed.
- Do not stack CE lfg/plan/work/brainstorm or full Superpowers lifecycle with
  active OpenSpec. Existing independent quality safeguards remain usable.
- Search relevant docs/solutions for non-obvious work; check applicability.
  Learning capture uses the existing Learning Worthy Gate, never a new closure gate.
- Verify reviewer findings before editing; report checks, failures and unverified
  limits honestly. Never claim completion from a passing structure check alone.
- Use focused checks and input-matched reuse. A role, prose, handoff,
  inventory or bookkeeping change alone does not justify repeating every
  suite. Before a substantial low-benefit or unexpected-cost check, use the
  existing Owner Decision Brief with benefit, effort/unknowns, evidence,
  smaller option and recommendation; silence is not approval.
- Do not commit, branch, create worktrees, merge, push or deploy unless explicitly
  authorized. Package lifecycle operations do not require legacy handoff routing.
