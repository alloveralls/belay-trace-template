# Trace Guide

This guide defines the recommended shape and lifecycle of belay entries in this
template. Entry bodies are Markdown and may be adapted when the project needs
more detail.

## Entry Types And Statuses

| Type | Default | Allowed statuses |
|---|---|---|
| `goal` | `draft` | `draft`, `active`, `completed`, `superseded`, `abandoned` |
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
| `fulfills` | Work or Plan satisfies a Goal or Goal item. |
| `supports` | Decision or Evidence supports a Goal, Plan, or Work item. |
| `verifies` | Evidence verifies a Goal, Goal item, Plan, or Work item. |
| `refutes` | Evidence contradicts an expected outcome. |

Example:

```sh
belay link <plan-id> <goal-id> --relation fulfills
belay link <work-id> <goal-id-or-goal-fragment> --relation fulfills
belay link <decision-id> <goal-id> --relation supports
belay link <review-id> <work-id> --relation reviews
```

## Goal Body

`belay add goal --title "<title>"` can create the required Goal sections as a
template. Fill them before relying on the Goal for planning.

Recommended sections:

```markdown
## Problem

What is wrong or missing today.

## Desired Outcome

The durable state that should become true.

## Success Criteria

- SC-1: Observable success criterion.

## Constraints

- Constraint that the solution must respect.

## Non-goals

- Explicitly excluded outcome.

## Assumptions

- Assumption that should be revisited if evidence changes.

## Unknowns

- Unknown or human decision still needed.
```

Run:

```sh
belay goal lint <goal-id>
```

## Plan Body

```markdown
## Intent Brief

### Problem

- Describe the problem.

### Desired Outcome

- Describe the intended outcome.

### Success Signals

- Observable signal.

### Constraints

- Constraint.

### Non-goals

- Excluded outcome.

### Assumptions

- Assumption.

### Unknowns / Decisions Needed

- Unknown or `None identified`.

## Delivery Map

| ID | Goal item | Outcome / Task | Actor | State | Verification / Evidence |
| --- | --- | --- | --- | --- | --- |
| T-1 | SC-1 | Implement observable outcome | AI | not-started | pending |
| T-2 | SC-1 | Verify observable outcome | AI | not-started | pending Evidence |

## Risks And Mitigations

- Risk: ...
  Mitigation: ...

## Acceptance Criteria

- [ ] Verifiable completion condition.
```

Delivery Map states are limited to `not-started`, `in-progress`, `blocked`,
`implemented`, `verified`, and `dropped`. Treat `implemented` and `verified` as
different states.

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
- Goal: `<goal-id>`
- Delivery Map task: `T-n`
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
- Evidence: `<evidence-id-or-source>`

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

## Evidence

Record durable verification with:

```sh
belay verify record \
  --kind test \
  --verdict pass \
  --source "<command>" \
  --summary "<what passed>" \
  --verifies <goal-id-or-work-id>
```

Use `belay coverage` to inspect Goal coverage. Coverage is supporting evidence,
not a replacement for semantic review.

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
