---
name: project-planning-workflow
description: Plan and scope repository work with human gates and belay plan and decision traces.
---

# Project Planning Workflow

## Guardrails

- Treat `AGENTS.md` as the canonical repository policy.
- Use `belay-trace` as the source of truth for planning history.
- Use `jj` for version control.
- Require explicit human approval before issue creation, implementation, pull
  request creation, or merge.
- Separate facts, assumptions, hypotheses, and conclusions.

## Retrieve Context

Before broad historical reads:

```sh
belay context "<planning task>" --format agent --budget 2500
```

Use `belay search` for targeted discovery and `belay show <id>` for a complete
entry. Do not scan `.belay/entries/` broadly.

## Planning Flow

1. Clarify the requested outcome and unknowns.
2. Define scope and non-scope.
3. Identify dependencies, constraints, risks, and acceptance criteria.
4. Create a plan entry with `belay add plan`.
5. Create decision entries with `belay add decision` for meaningful technical,
   product, architecture, API, or operational choices.
6. Link each decision to the plan:

   ```sh
   belay link <decision-id> <plan-id> --relation references
   ```

7. Draft the requested issue title, body, labels, priority, and milestone.
8. Stop at the relevant human gate.

Use the plan and decision body guidance in `TRACE_GUIDE.md`.

## Plan Status

- New plans start as `draft`.
- Set a plan to `approved` only after explicit human implementation approval.
- Use `active` once implementation begins.
- Use `completed` when acceptance criteria are met.
- Use `superseded` or `abandoned` instead of deleting history.

## Allowed During Planning

- inspect repository files needed to understand the task
- retrieve and create belay traces
- ask questions when material ambiguity cannot be resolved locally
- draft plans, issues, acceptance criteria, and decisions

## Not Allowed Without Explicit Approval

- modify source code
- create an implementation `jj` change
- create an actual GitHub issue
- create a pull request
- merge changes

## Direct Entry Edits

When updating a plan or decision by editing its managed Markdown:

1. Run `belay show <id>` to identify the source path.
2. Edit only the relevant entry.
3. Run `belay sync <id>`.

Never overwrite an unresolved conflict.
