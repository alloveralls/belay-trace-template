---
name: decision-review-workflow
description: Use for recording material Decisions and reviewing completion with fresh context, Evidence, risk escalation, and human acceptance checks.
---

# Decision Review Workflow

## Purpose

Use this skill to record material Decisions and to review whether completed work
actually satisfies the Intent Brief, Goal, Delivery Map, diff, and Evidence. It
owns Decision quality and Assure completion. It does not own initial planning or
implementation execution.

## Guardrails

- Treat `AGENTS.md` as canonical.
- Retrieve history with belay before broad reads.
- Use `belay add`, `belay link`, `belay status`, and `belay verify record` for
  trace updates.
- Separate facts, assumptions, unknowns, opinions, and human decisions.
- Human review supplements independent agent review; it does not replace it.

## Retrieve Context

For decision work:

```sh
belay context compile "<decision task>" --profile goal-drafting --budget 4000
```

For review or completion assurance:

```sh
belay context compile "<review task>" --profile review --budget 4000
```

If `compile` is unavailable, use `belay context "<task>" --format agent --budget 2500`.

## Decision Rules

Create or update a Decision entry when:

- architecture changes
- API contracts change
- operational rules change
- security, migration, or production behavior changes
- a significant tradeoff justifies a refactor
- a temporary decision is introduced
- a review identifies a systemic issue
- a previous decision is rejected or superseded

A meaningful Decision should state:

- context and concrete decision
- alternatives and rationale
- assumptions and unknowns
- positive and negative consequences
- risks and mitigations
- rollback strategy
- validation and success criteria
- re-evaluation trigger when temporary

Link Decisions to the relevant Goal or Plan:

```sh
belay link <decision-id> <goal-id-or-plan-id> --relation supports
```

Use `accepted` only when the decision is adopted. Use `rejected` when it is not
adopted.

## Supersession

When replacing a decision:

```sh
belay link <new-decision-id> <old-decision-id> --relation supersedes
belay status <old-decision-id> superseded
belay status <new-decision-id> accepted
```

Record what changed and why the old rationale no longer applies.

## Fresh-Context Completion Assurance

Completion assurance must use context separation. A reviewer should inspect the
Intent Brief, Goal, Delivery Map, actual diff, Work entry, Decisions, and
Evidence without relying on the implementer's working memory.

Do not declare the Goal complete until:

- every Success Criterion has mapped delivery tasks
- every required task is `verified` or explicitly `dropped`
- dropped tasks preserve reason and approval source
- no `implemented`, `blocked`, or important unknown item is counted as complete
- Evidence actually checks the mapped outcome
- the diff respects Constraints and Non-goals
- changed scope or assumptions are recorded
- final human acceptance is recorded when required by the tier or risk

Use `belay coverage` and `belay verify status <id>` where useful, but do not
treat coverage numbers as a substitute for semantic review.

## Review Entry

Every non-trivial implementation needs a Review entry before pull request
preparation. Findings should lead, ordered by severity.

Include:

- review method, such as `focused-high-review`, `subagent-review`,
  `cross-model-review`, or `human-review`
- related Goal, Plan, Work, Decision, Evidence, and diff references
- findings with file and line references where applicable
- risks and recommendations
- validation reviewed
- positive findings
- follow-up actions and owners
- whether human review is additionally required

Link review to Work:

```sh
belay link <review-id> <work-id> --relation reviews
```

Keep the Review `pending` until required findings are addressed or explicitly
deferred. Set it to `completed` when the outcome is recorded.

## Human Review Escalation

Set `requires_human_review: true` in the Review body when:

- security implications exist
- production impact is uncertain
- architectural impact is broad
- assumptions cannot be validated
- rollback strategy is unclear
- product scope or customer-facing behavior changes
- final acceptance is required by Tier 3 or by project policy

## Direct Entry Edits

Run `belay sync <id>` after editing managed Markdown. Never overwrite an
unresolved conflict without inspecting both versions.
