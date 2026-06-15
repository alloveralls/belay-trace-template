---
name: implementation-delivery-workflow
description: Implement approved work with jj, belay work traces, validation, independent review, and delivery gates.
---

# Implementation Delivery Workflow

## Entry Gate

Start implementation only after explicit human instruction. Planning approval
or issue creation alone does not authorize source changes.

Treat `AGENTS.md` as canonical. Use `jj` for version control and belay for trace
history.

## Retrieve And Reconcile

1. Run:

   ```sh
   belay context "<implementation task>" --format agent --budget 2500
   ```

2. Inspect the relevant plan, decisions, reviews, and issue.
3. Run `belay sync`.
4. Resolve drift without overwriting an unresolved conflict.

## Implementation Flow

1. Set the approved plan to `active`.
2. Create a new implementation change:

   ```sh
   jj new
   ```

3. Create a work entry using the body guidance in `TRACE_GUIDE.md`.
4. Record the active `jj` change ID in the work entry.
5. Link work to the approved plan and decisions:

   ```sh
   belay link <work-id> <plan-id> --relation implements
   belay link <work-id> <decision-id> --relation implements
   ```

6. Implement the smallest coherent change.
7. Keep the work entry current with:
   - progress
   - changed files
   - commands and validation results
   - observations
   - assumptions and hypotheses
   - blockers and next steps
8. Create and link new decision entries when implementation establishes a
   meaningful tradeoff or contract.
9. Run project test, lint, typecheck, and build commands where available.
10. Request an independent implementation-time review through Codex
    `/subagents` or Claude Code `/agents`.
11. Create a review entry and link it:

    ```sh
    belay link <review-id> <work-id> --relation reviews
    ```

12. Address findings or document why they are deferred.
13. Set the review and work entries to `completed`.
14. Set the plan to `completed` when its acceptance criteria are met.
15. Run:

    ```sh
    belay sync
    belay doctor
    jj st
    jj diff
    ```

16. Set the change description with a Conventional Commit message.
17. Push or create a pull request only when explicitly authorized.

## Work Status

- `in-progress`: active implementation
- `blocked`: progress cannot continue
- `completed`: implementation and required review are complete
- `abandoned`: the implementation will not continue

Return blocked work to `in-progress` when the blocker clears.

## Pull Request Gate

Creating a pull request requires explicit human instruction. If authorization is
absent, prepare a PR title and body draft, then stop.

Never merge without explicit human instruction and green CI.

## Conflict Safety

After direct managed Markdown edits, run `belay sync <id>`. For conflicts,
inspect both sides before using `--prefer markdown` or `--prefer sqlite`.
