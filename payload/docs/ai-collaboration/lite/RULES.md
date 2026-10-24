# EngRelay Lite

Apply these rules only when the installed Lite profile is selected for this task
and WorkflowMode allows it. Installation, historical state and discovered Skills
do not activate a workflow. Use one primary controller per task. In optional mode
select EngRelay or EngRelay-Lite explicitly; default selects Lite unless this task
selects another controller. Disabled requires explicit re-enabling first.
Full-only ai-collaboration and ai-collab-* entries do not select Lite: explain the
profile mismatch and point here; never install, switch profiles or create Full state.

## Read and authorize

Read project/module instructions, this file, docs/engrelay-lite.config.md and the
approved current task. On takeover also read that task's latest handoff and named
evidence. These are entry points: read actual source, module guidance and acceptance
evidence as needed. There is no Full handbook or dedicated Skill prerequisite.
Consultation alone creates no runtime task.

An applicable OpenSpec change owns scope, acceptance and its sole tasks.md checklist;
reference it rather than duplicating it. Otherwise Task Owner approves the goal,
scope and acceptance in the queue (S) or tasks/<id>.md (M/H). Configuration records
commands, available tools and real restrictions; it cannot grant permission,
override project instructions or waive independent review. Classify actual impact,
not file type. Rules, configuration and permission changes can be M/H.

Use existing authorization for ordinary edits, local technical choices and CLI/IDE
selection. Ask the Task Owner only for a real authority, scope, acceptance, risk,
irreversible business action or material cost decision. Tool permissions still
apply. Do not add a generic plan approval just because work is H.

## Responsibilities and review

Task Owner is human. Executor owns adjacent non-independent design details,
implementation, self-checks and recording. Reviewer performs eligible independent
design, code or verification actions; changing role labels cannot create independence.

- S: relevant self-checks suffice; no mandatory proposal or independent session.
- M: aggregate actual findings in an independent code review. Must-fix repairs
  require independent confirmation; until then record fixed-not-verified.
- H: obtain design/architecture review when actually triggered, independent code
  review and required independent verification after fixes. Implementation/fix
  authors cannot verify their own batch. A clean review with matching independent
  verification evidence need not manufacture another verdict.

Review round counts completed design/code/verification/adjudication verdicts for
the same mapped acceptance. Default allowance is three, across sessions, stages,
tools and profiles. Never rename unresolved work to reset it. At capacity accept
only on evidence, otherwise wait for Task Owner disposition or an applicable finite
extension. Do not start a fourth autonomous fix/review cycle. An extension retains
owner, date, batch=Task ID, from, through, scope and evidence in the existing form:
`Task Owner decision: review-budget-extension; owner=...; date=YYYY-MM-DD; batch=T01; from=3; through=5; scope=...; evidence=relative/file.md`.
Use it only when from <= current count < through and the real authorization matches.

## State and sequential work

Use only .ai/engrelay-lite/: queue.md, handoff.md, tasks/<id>.md,
tasks/<id>-review-<n>.md, tasks/<id>-handoff.md and archive/. Never route using
historical Full .ai/handoff.md. Installation creates no live task. Task ID identifies
one independent execution/acceptance unit, distinct from a parent change ID.

Choose one approved task whose prerequisites are accepted and whose files do not
conflict with active work. Before moving past a blocked task, save/read back its
tasks/<id>-handoff.md and queue reference. Only independent approved work can
continue. Missing dependencies and cycles block affected tasks, not every task.
Unapproved suggestions never execute. Do not release dependents after implementation
alone or hide unmet acceptance in a follow-up. Out-of-scope independent follow-ups
may remain clearly tracked. Archive accepted task evidence without overwriting
existing records, reconcile queue references, then select the next eligible task.
This is active-agent sequential work; it provides no scheduler or automatic wake-up.

## Handoff at real boundaries

At dispatch, actual wait, planned session end (even same role), or closure, decide
the next state, save it, read back and run scripts/validate-state.ps1 with all five
decided expectations: ExpectedTaskId, ExpectedNextAction, ExpectedNextRole,
ExpectedReviewRound and ExpectedStateRevision. Keep exact commands, exits,
diagnostics and input hashes outside the checked handoff. Structure is not business
acceptance, real authorization, independence or host-loading proof. Ordinary active
micro-steps need no handoff. A long check may leave one useful checkpoint with an
external log, explicitly not yet passed.

Routing contains exactly eleven unique English fields as in templates/handoff.md:
Schema version=lite-1; Task ID; positive State revision; Current role=Executor|Reviewer;
actual Current agent; Current status=in-progress|blocked|awaiting-owner-decision|completed;
Next action=continue|dispatch|close; Human Action Required=none|awaiting-decision|awaiting-environment;
nonnegative Review round; Next role=none|Executor|Reviewer|Task Owner; Risk level=S|M|H.
Keep Current Status and Evidence, plus only the applicable action blocks.

- continue/in-progress: human none, next role none. Put a complete Continuation
  Command under Current Status: same role/task, Read, Objective, Constraints,
  Output, Follow. A capable active agent immediately executes it after checking
  latest authority and execution ownership. A replacement records its actual
  agent and increments revision, preserving task, scope, role, risk and count.
- Agent dispatch/in-progress: human none, next Executor or Reviewer. Operator
  Command names task/role, inputs, objective, constraints including independence
  and remaining allowance, explicitly writable outputs, and these rules. First
  Current Status line: Recommended capability tier: C3; echo it in the reply.
  Only explicit task difficulty supports C1/C2/C4/C5 overrides; this advice is
  non-blocking and never a model qualification. Do not copy Full tier tables.
- Owner wait: status awaiting-owner-decision, human awaiting-decision; continue
  uses next none, human dispatch uses Task Owner. Include Owner Decision Brief
  with Decision needed, Recommendation (reason), Alternatives (consequences),
  Reply needed, After the reply. No executable Agent command. Reuse a matching
  existing decision; silence never approves. The agent maintains the files.
- Environment wait: continue/blocked, next none. Blockers states actual attempts
  and Resume condition; human awaiting-environment only when current human
  preparation is needed, with concrete Human preparation and smallest reply.
  Pure tool failures use human none. A later environment notice requires no
  current action/reply and does not block executable offline work.
- close/completed: human none, next none, Outcome and corresponding evidence;
  no command or capability line. Ordinary accepted requires mapped acceptance,
  required reviews and final-input checks. Limited acceptance/stopped/superseded
  requires an explicit applicable owner disposition and preserves unfinished scope.

Do not put capability advice on continue, human waits or close. Missing advice on
an otherwise valid historical dispatch only warns; correct it in the existing
write/read-back step. Do not auto-migrate private unversioned Lite handoffs.

## Explicit sources and read-only returns

Review business files read-only, but permit named review/result/handoff outputs
when assigned. Pre-name the expected result in the task or prior handoff Evidence.
If entirely read-only, return full verdict/findings/next handoff, actual source
role/agent, producer, Task ID, prior revision and real prior-byte SHA256, target
revision and cumulative count. State that nothing was persisted. An active permitted
writer saves the complete return and publishes the checked state in the same turn;
retain the reviewer attribution and count each verdict once. Never overwrite an
existing result or ask the owner to hand-maintain these files.

Later recovery reads only the one explicitly named pending source. Match task,
prior revision and SHA256, ownership, allowance and full action body before applying.
Same target revision requires equal Routing and action content to be already applied;
an advanced live state is not overwritten. A close or real wait cannot be bypassed.
Conflicts preserve the live state; never scan directories, select the largest
revision/timestamp or replay/recount. Without a permitted publisher keep the full
response and its unpersisted status. The validator's optional SourceResultPath and
PriorHandoffPath compare a review return to explicit prior input only; they do not
discover sources, authenticate authors, apply transfers or replace this judgment.
