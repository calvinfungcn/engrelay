# Engineering Solutions

This directory contains verified, reusable, non-obvious engineering knowledge
captured through the selected Compound Engineering learning process.

It is not authoritative for product requirements, active change design,
implementation tasks, review status, or runtime routing. Those remain in
OpenSpec, repository evidence, `docs/reviews/`, and `.ai/` respectively.

## Admission Rule

Add an entry only when the Learning Worthy Gate in
`docs/ai-collaboration/compound-engineering.md` passes. Prefer one focused
problem and one reusable conclusion per file. Do not record task diaries,
obvious documentation, secrets, production data, or unverified advice.
An existing OpenSpec or review may supply evidence for a cross-task diagnostic
lesson. Add applicability and reusable reasoning, link the source, and keep
product behavior and current task state authoritative there. If the lesson is
already sufficiently explained here or in instructions, cite it or update it.

## Finding And Applying A Lesson

Search titles, tags, and symptoms, for example:

```powershell
rg -n -i 'skill drift|out-of-sync|parent checklist|accepted closure' docs/solutions
```

The read-only helper searches the same library with literal terms, match reasons and a bounded list:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File docs/ai-collaboration/scripts/find-solutions.ps1 -WorkspaceRoot 'E:/Projects/your-project' -Query 'skill drift' -Limit 10
```

Read only relevant entries. Check Context, Verification, and Revalidation
against the current environment before applying them. Record actual reuse as
the entry path and the decision/check informed in an existing result or closing
summary. Correct outdated guidance when authorized; read-only review reports it.
Capture and reuse are separate observations. Do not infer saved time from either.

For a lesson that depends on an external bug, tool/platform version, or
dependency behavior, optionally add a quoted `retire_when` frontmatter value
that names the change and a read-only way to check it. A met condition triggers
reassessment of the lesson and any workaround; it is not enough on its own to
remove either. Existing entries need no backfill. `Revalidation` remains the
general trigger for changes in repository behavior or evidence.

## Naming

Use a stable, searchable kebab-case name:

```text
docs/solutions/<area>/<problem-and-solution>.md
```

Use [solution.template.md](solution.template.md) as the starting point. Link
the originating OpenSpec change or verified evidence, but do not copy its
content. Update or retire an entry when later evidence invalidates it.
