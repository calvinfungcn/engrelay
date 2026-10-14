# Role Roster

Use this local template as `.ai/role-roster.md`.

Do not commit `.ai/role-roster.md` if it contains personal tool preferences.

## Default Assignments

| Role | Primary agent/tool | Fallback agent/tool | Use when |
| --- | --- | --- | --- |
| Chief Designer | `<agent/tool>` | `<agent/tool>` | Overall design, task slicing, acceptance criteria |
| Requirements Analyst | `<agent/tool>` | `<agent/tool>` | Conditional material business ambiguity clarification |
| Design Reviewer | `<agent/tool>` | `<agent/tool>` | Mandatory on lean-design triggers, otherwise optional; checks necessity and reuse before completeness and feasibility |
| Architect | `<agent/tool>` | `<agent/tool>` | Module boundaries, data flow, contracts, compatibility |
| UI Designer | `<agent/tool>` | `<agent/tool>` | UI flow, states, interaction, standards compliance |
| Implementation Engineer | `<agent/tool>` | `<agent/tool>` | Main coding, focused tests, validation |
| Test Engineer | `<agent/tool>` | `<agent/tool>` | Test strategy, coverage audit, regression analysis |
| Code Reviewer | `<agent/tool>` | `<agent/tool>` | Formal review, high-confidence findings |
| Fix Engineer | `<agent/tool>` | `<agent/tool>` | Review-driven fixes |
| Verification Reviewer | `<agent/tool>` | `<agent/tool>` | Re-review, verification evidence, status closure |
| Documentation Steward | `<agent/tool>` | `<agent/tool>` | Handoff, review index, OpenSpec task alignment |

## Task-Specific Overrides

| Task or change ID | Role | Assigned agent/tool | Reason |
| --- | --- | --- | --- |
| `<change-id>` | `<role>` | `<agent/tool>` | `<reason>` |

## Notes

- Roles describe responsibilities.
- Agents/tools are replaceable executors for a role.
- Selected Compound Engineering Skills are capabilities inside these roles,
  not role names. Verify the recommended tool has the generated Skill copy
  when a batch requires one.
- For risk `H`, assign Verification Reviewer to a different agent/tool from
  Implementation Engineer and Fix Engineer.
- Update `.ai/handoff.md` at actual handoff, wait, interruption, or closure
  boundaries; adjacent non-independent duties do not need separate dispatches.
