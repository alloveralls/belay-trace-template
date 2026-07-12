---
name: implementation-delivery-workflow
description: Use for implementing approved work with jj, belay Work entries, stable Delivery Map Task IDs, checkpoint reconciliation, and validation Evidence.
---

# Implementation Delivery Workflow

## Purpose

Use this skill after explicit implementation approval. It owns Execute and
checkpoint Reconcile. It does not own initial planning or final independent
completion assurance.

## Entry Gate

Start implementation only after explicit human instruction. Planning approval
or issue creation approval alone does not authorize source changes.

Before touching source code:

```sh
jj new
```

If a human explicitly instructs you to skip `jj new`, record the exception and
reason in the Work entry before continuing.

## Retrieve And Reconcile Before Work

1. Run:

   ```sh
   belay context compile "<implementation task>" --format agent --budget 4000
   ```

   If unavailable, use `belay context "<implementation task>" --format agent --budget 2500`.

2. Inspect the approved Goal, Plan, Delivery Map, Decisions, Reviews, Evidence,
   and issue.
3. Run `belay sync`.
4. Resolve drift without overwriting unresolved conflicts.
5. Confirm every active work item has a stable Delivery Map Task ID.

## Execute

1. Set the approved Plan to `active` when applicable.
2. Create a Work entry using the body guidance in `TRACE_GUIDE.md`.
3. Record the active `jj` change ID in the Work entry.
4. Link Work to the Goal item or Goal:

   ```sh
   belay link <work-id> <goal-id-or-goal-fragment> --relation fulfills
   ```

5. Use the Delivery Map Task ID as the active work unit.
6. Move a task to `implemented` only when the intended change exists.
7. Move a task to `verified` only after passing Evidence checks the mapped
   outcome.
8. Record validation with `belay verify record` when the result should support
   release or Goal coverage decisions.
9. Add newly discovered tasks, assumptions, unknowns, constraints, and scope
   changes to the Plan instead of silently absorbing them.
10. Create Decision entries for meaningful implementation tradeoffs.

## Checkpoint Reconciliation

Reconcile the Intent Brief, Goal, Delivery Map, actual diff, and Evidence at
these checkpoints:

- after a meaningful task
- after discovering a requirement, constraint, risk, or changed assumption
- after changing design or scope
- before interruption, compaction, or handoff
- when asked for status
- before claiming implementation is done

Use this fixed status report and make it match the Delivery Map:

```text
Current state
- verified: <n>/<total>
- implemented, unverified: <n>/<total>
- in progress: <n>/<total>
- blocked: <n>/<total>

Goal coverage
- <criterion>: <verified|partial|not started>

Changed assumptions
- <change or None identified>

Human decisions needed
- <decision or None identified>

Next action
- <single next action>
```

Do not report a task as complete when it is only `implemented`.

## Validation

Run the project's test, lint, typecheck, and build commands where available.
Record each command and result in the Work entry.

For durable Evidence:

```sh
belay verify record \
  --kind test \
  --verdict pass \
  --source "<command>" \
  --summary "<what passed>" \
  --verifies <goal-id-or-work-id>
```

Use `belay coverage` before release decisions when Goals are active.

## Delivery Gate

After implementation:

1. Run `belay sync`.
2. Run `belay doctor`.
3. Run `jj st` and `jj diff`.
4. Ensure the Delivery Map has no blocked or implemented-only item represented
   as complete.
5. Request independent completion assurance or review according to risk.
6. Create or update a Review entry only after the review has actual findings or
   an explicit no-finding outcome.
7. Push or create a pull request only when explicitly authorized.

## Review Budgeting

The default review path is a focused high-reasoning diff review. Use Codex
`/subagents`, Claude Code `/agents`, or cross-model review only when risk,
scope, security, production impact, architecture, or uncertainty justifies the
cost.

## Conflict Safety

After direct managed Markdown edits, run `belay sync <id>`. For conflicts,
inspect both sides before using `--prefer markdown` or `--prefer sqlite`.
