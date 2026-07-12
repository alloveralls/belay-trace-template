---
name: project-planning-workflow
description: Use for planning Tier 2 and Tier 3 work with belay Goals, Intent Briefs, Delivery Maps, and explicit human gates before implementation.
---

# Project Planning Workflow

## Purpose

Use this skill to turn a human request into traceable intent before
implementation. It owns Frame and Map. It does not own implementation,
reconciliation during execution, or completion assurance.

## Guardrails

- Treat `AGENTS.md` as the canonical repository policy.
- Use `belay-trace` as the source of truth for Goals, Plans, Decisions, Work,
  Reviews, Evidence, and durable Notes.
- Use `jj` for version control, but do not create an implementation change
  during planning.
- Require explicit human approval before issue creation, implementation, pull
  request creation, or merge.
- Preserve facts, assumptions, unknowns, and human decisions separately.

## Retrieve Context

Start planning with focused context:

```sh
belay context compile "<planning task>" --format agent --budget 4000
```

If `compile` is unavailable, fall back to:

```sh
belay context "<planning task>" --format agent --budget 2500
```

Use `belay search` for targeted discovery and `belay show <id>` for a complete
entry. Do not scan `.belay/entries/` broadly.

## Classify The Work

- Tier 1: small, reversible, clear scope. A separate Goal or Plan is optional.
- Tier 2: feature or non-trivial change. Create or update a Goal and Plan.
- Tier 3: architecture, API contract, security, migration, production-impacting,
  or irreversible work. Use Tier 2 trace plus explicit human approval of the
  Intent Brief and Plan.

Escalate to the higher tier when scope, reversibility, or risk is uncertain.

## Frame: Intent Brief

For Tier 2 and Tier 3, create or update a Plan with an Intent Brief before
implementation. Every section must be non-empty; write `None identified` when
there are no items.

Required sections:

- Problem
- Desired Outcome
- Success Signals
- Constraints
- Non-goals
- Assumptions
- Unknowns / Decisions Needed

Ask the human only about decisions that materially change the outcome, affect
security or data loss, create external commitments, or are irreversible. For
small and reversible assumptions, record the assumption and continue.

## Map: Goal And Delivery Map

Create or update a Goal when the request has a durable desired outcome:

```sh
belay add goal --title "<goal title>"
belay goal lint <goal-id>
```

In the Plan, add a Delivery Map with stable Task IDs:

```markdown
## Delivery Map

| ID | Goal item | Outcome / Task | Actor | State | Verification / Evidence |
| --- | --- | --- | --- | --- | --- |
| T-1 | SC-1 | Define the observable outcome | AI | not-started | pending |
| T-2 | SC-1 | Verify the outcome | AI | not-started | pending Evidence |
```

Rules:

- Map every Goal Success Criterion to at least one observable outcome task and
  one verification task.
- Keep Task IDs stable across edits.
- Use only `not-started`, `in-progress`, `blocked`, `implemented`, `verified`,
  and `dropped`.
- Keep dropped tasks visible with reason and approval source.
- Explain any Delivery Map task that does not map to a Goal item.

## Planning Flow

1. Retrieve context.
2. Classify tier.
3. Create or update the Goal when needed.
4. Draft the Intent Brief.
5. Draft the Delivery Map.
6. Create Decision entries for meaningful tradeoffs or contracts.
7. Link related trace entries:

   ```sh
   belay link <plan-id> <goal-id> --relation fulfills
   belay link <decision-id> <goal-id> --relation supports
   ```

8. Run `belay goal lint <goal-id>` when a Goal exists.
9. Present the Intent Brief, Delivery Map, decisions needed, and issue draft if
   requested.
10. Stop at the relevant human gate.

## Planning Output

End with a fixed planning summary:

```text
Intent Brief
- Problem: <one-line summary>
- Desired Outcome: <one-line summary>
- Unknowns requiring human decision: <items or None identified>

Delivery Map
- total tasks: <n>
- blocked: <n>
- verification tasks: <n>

Human gate
- next approval needed: <issue creation | implementation | none>
```

## Not Allowed Without Explicit Approval

- modify source code
- create an implementation `jj` change
- create an actual GitHub issue
- create a pull request
- merge changes

## Direct Entry Edits

When updating managed Markdown:

1. Run `belay show <id>` to identify the source path.
2. Edit only the relevant entry.
3. Run `belay sync <id>`.

Never overwrite an unresolved conflict.
