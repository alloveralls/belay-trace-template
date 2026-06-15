---
name: decision-review-workflow
description: Record decisions and implementation reviews as linked belay traces with explicit risks and outcomes.
---

# Decision Review Workflow

## Guardrails

- Treat `AGENTS.md` as canonical.
- Retrieve history with `belay context` before broad reads.
- Use `belay add`, `belay link`, and `belay status` for trace updates.
- Separate facts, assumptions, hypotheses, and conclusions.
- Human review supplements independent agent review; it does not replace it.

## Retrieve Context

```sh
belay context "<decision or review task>" --format agent --budget 2500
```

Use `belay search` and `belay show` only as needed.

## Decision Rules

Create or update a decision entry when:

- architecture changes
- API contracts change
- operational rules change
- a significant tradeoff justifies a refactor
- a temporary decision is introduced
- a review identifies a systemic issue
- a previous decision is rejected or superseded

Follow the decision body guidance in `TRACE_GUIDE.md`. A meaningful decision
should state:

- context and concrete decision
- alternatives and rationale
- assumptions
- positive and negative consequences
- risks and mitigations
- rollback strategy
- validation and success criteria
- re-evaluation trigger when temporary

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

## Implementation Review

Every implementation requires an independent review entry.

1. Review the change diff, linked work entry, linked plan and decisions, and the
   minimum additional source context needed.
2. Put findings first and order them by severity.
3. Include file and line references where applicable.
4. Record immediate and long-term risks.
5. Record recommendations, positive findings, validation, and follow-up owners.
6. Create the review entry with `belay add review`.
7. Link it to the work:

   ```sh
   belay link <review-id> <work-id> --relation reviews
   ```

8. Keep the review `pending` until required findings are addressed or explicitly
   deferred.
9. Set it to `completed` when the review outcome is recorded.

## Human Review Escalation

Set `requires_human_review: true` in the review body when:

- security implications exist
- production impact is uncertain
- architectural impact is broad
- assumptions cannot be validated
- rollback strategy is unclear
- product scope or customer-facing behavior changes

## Direct Entry Edits

Run `belay sync <id>` after editing managed Markdown. Never overwrite an
unresolved conflict without inspecting both versions.
