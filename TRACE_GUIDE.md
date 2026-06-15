# Trace Guide

This guide defines the recommended shape and lifecycle of belay entries in this
template. Entry bodies are Markdown and may be adapted when the project needs
more detail.

## Entry Types And Statuses

| Type | Default | Allowed statuses |
|---|---|---|
| `plan` | `draft` | `draft`, `approved`, `active`, `completed`, `superseded`, `abandoned` |
| `decision` | `proposed` | `proposed`, `accepted`, `rejected`, `superseded` |
| `work` | `in-progress` | `in-progress`, `blocked`, `completed`, `abandoned` |
| `review` | `pending` | `pending`, `completed` |
| `note` | `active` | `active`, `archived` |

Use terminal statuses instead of deleting history.

## Relations

| Relation | Typical use |
|---|---|
| `references` | The source entry depends on or cites the target. |
| `implements` | A work entry implements a plan or decision. |
| `reviews` | A review entry evaluates a work entry. |
| `supersedes` | A newer decision or plan replaces an older one. |
| `follows-up` | An entry records later work caused by another entry. |

Example:

```sh
belay link <work-id> <plan-id> --relation implements
belay link <work-id> <decision-id> --relation implements
belay link <review-id> <work-id> --relation reviews
```

## Plan Body

```markdown
## Objective

Describe the intended outcome.

## Facts

- Verified repository or product facts.

## Assumptions

- Unverified assumptions that affect the plan.

## Scope

- Included work.

## Non-Scope

- Explicitly excluded work.

## Approach

1. Proposed implementation steps.

## Risks And Mitigations

- Risk: ...
  Mitigation: ...

## Acceptance Criteria

- [ ] Verifiable completion condition.

## Open Questions

- None.
```

Lifecycle:

```text
draft -> approved -> active -> completed
```

Use `superseded` or `abandoned` when the plan will not complete as written.

## Decision Body

```markdown
## Context

Describe the situation requiring a decision.

## Decision

State the concrete decision.

## Alternatives Considered

- Alternative and why it was not selected.

## Rationale

Explain the tradeoff.

## Assumptions

- Assumption.

## Consequences

- Positive impact.
- Negative impact.

## Risks And Mitigations

- Risk: ...
  Mitigation: ...

## Rollback

Describe how to reverse the decision.

## Validation

Describe evidence that will confirm the decision works.

## Re-evaluation

State a date or trigger, or `Not required`.
```

Lifecycle:

```text
proposed -> accepted
proposed -> rejected
accepted -> superseded
```

## Work Body

```markdown
## Objective

Describe the approved implementation task.

## Related Context

- Plan: `<plan-id>`
- Decisions: `<decision-id>`
- Issue: `<url-or-number>`
- jj change: `<change-id>`

## Progress

- Completed or current step.

## Changed Files

- `path`: reason.

## Validation

- Command: `<command>`
  Result: pass, fail, or not run with reason.

## Observations

- Verified observation.

## Assumptions

- Assumption still requiring validation.

## Hypotheses

- Hypothesis and how it will be tested.

## Blockers

- None.

## Next Steps

- Next concrete action.
```

Set work to `blocked` when progress cannot continue. Return it to
`in-progress` when the blocker clears.

## Review Body

```markdown
## Scope

- Work: `<work-id>`
- Diff or change reviewed: `<jj-change-or-pr>`

## Findings

### Critical

- None.

### High

- None.

### Medium

- None.

### Low

- None.

## Risks

- Immediate risk.
- Long-term risk.

## Recommendations

- Required or optional action.

## Validation

- Review command or evidence.

## Positive Findings

- Correct or well-contained behavior worth preserving.

## Follow-Up

- Owner, status, and next action.

## Human Review

requires_human_review: false
reason: none
```

Review findings should include file and line references where applicable.

## Note Body

```markdown
## Summary

Durable context that does not fit a plan, decision, work, or review entry.

## Evidence

- Source, command, or link.

## Implications

- Why future work should care.
```

## Direct Markdown Editing

Use `belay show <entry-id>` to find the managed source path. After editing:

```sh
belay sync <entry-id>
```

Never resolve a conflict by preference until both versions have been inspected.
