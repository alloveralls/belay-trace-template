# Contributing

Follow the repository policy in [AGENTS.md](../AGENTS.md). Plans, decisions,
work, and reviews are recorded through belay.

## Start With Context

```sh
belay context "<task>" --format agent --budget 2500
belay sync
```

Inspect only the entries and source files relevant to the task.

## Implementation Workflow

After explicit implementation approval:

1. Set the approved plan to `active`.
2. Create a change with `jj new`.
3. Create and link a work entry.
4. Implement the smallest coherent change.
5. Record validation in the work entry.
6. Request independent implementation-time review.
7. Create and link a review entry.
8. Resolve findings or record deferrals.
9. Run `belay sync`, `belay doctor`, `jj st`, and `jj diff`.
10. Set a Conventional Commit message with `jj describe`.
11. Push or create a PR only after the relevant human gate.

See [TRACE_GUIDE.md](../TRACE_GUIDE.md) for entry body guidance.

## Pull Requests

- Fill every section of the PR template.
- Include related Plan, Decision, Work, and Review IDs.
- Keep the PR scoped for one review pass.
- Re-request review after material updates.
- Merge policy is `1 approval + green CI`.
- Merge strategy is squash merge.

## Review Ownership

`CODEOWNERS` defines default owners for workflow policy, agent skills, GitHub
configuration, and belay integration assets.
