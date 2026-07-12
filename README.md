# belay-trace-template

`belay-trace-template` is a repository template for developing software with AI
agents while preserving the context behind each change.

It combines the human-gated workflow documented in
[AGENTS.md](./AGENTS.md) with
[`belay-trace`](https://github.com/alloveralls/belay-trace), a local-first trace
store backed by SQLite and deterministic Markdown.

This is a workflow starter kit, not an application framework.

## What This Template Provides

- Repository-local agent policy in [AGENTS.md](./AGENTS.md).
- Goals, plans, decisions, work, reviews, evidence, and notes managed by
  `belay`.
- Tracked review and recovery files under `.belay/entries/`.
- Local searchable state under `.belay/state/`.
- Shared planning, implementation, and review skills for Codex and Claude Code.
- GitHub issue forms, pull request template, CODEOWNERS, labels, and Actions.
- Documentation validation through [Makefile](./Makefile).
- Reusable trace body guidance in [TRACE_GUIDE.md](./TRACE_GUIDE.md).
- A generic product and UI design reference in [DESIGN.md](./DESIGN.md).

## Repository Map

| Path | Purpose |
|---|---|
| [AGENTS.md](./AGENTS.md) | Canonical workflow and safety rules. |
| [TRACE_GUIDE.md](./TRACE_GUIDE.md) | Entry body, status, relation, and lifecycle guidance. |
| [.belay/config.toml](./.belay/config.toml) | belay repository configuration. |
| `.belay/entries/` | Tracked Markdown trace surface, including Goals and Plans. |
| `.belay/evidence/` | Tracked append-only verification evidence. |
| `.belay/state/` | Ignored local SQLite operational state. |
| `.belay/agent/` | Generated integration assets. |
| `.shared/skills/` | Shared workflow skills. |
| `.agents/skills/` | Codex skill adapters and generated belay skill. |
| `.claude/skills/` | Claude Code skill adapters. |
| [.github/](./.github/) | GitHub workflow and contribution configuration. |
| [SETUP.md](./SETUP.md) | Installation and adaptation guide. |
| [Makefile](./Makefile) | Documentation and belay health checks. |

## Quick Start

Install `belay` and the other prerequisites described in
[SETUP.md](./SETUP.md), then verify the template:

```sh
make bootstrap
belay doctor
make check
```

GitHub repository settings are not inherited from a template. After creating a
repository, initialize its labels and default-branch rulesets:

```sh
make github-setup
```

Start a task by retrieving bounded, source-attributed context:

```sh
belay context compile "describe the task" --format agent --budget 4000
```

Create a Goal and planning trace:

```sh
belay add goal --title "Deliver the change"

printf '%s\n' \
  '## Intent Brief' \
  '' \
  '### Problem' \
  '- Describe the problem.' \
  '' \
  '### Desired Outcome' \
  '- Describe the intended outcome.' \
  '' \
  '### Success Signals' \
  '- Observable success signal.' \
  '' \
  '### Constraints' \
  '- None identified' \
  '' \
  '### Non-goals' \
  '- None identified' \
  '' \
  '### Assumptions' \
  '- None identified' \
  '' \
  '### Unknowns / Decisions Needed' \
  '- None identified' \
  '' \
  '## Delivery Map' \
  '' \
  '| ID | Goal item | Outcome / Task | Actor | State | Verification / Evidence |' \
  '| --- | --- | --- | --- | --- | --- |' \
  '| T-1 | SC-1 | Implement observable outcome | AI | not-started | pending |' \
  '| T-2 | SC-1 | Verify observable outcome | AI | not-started | pending Evidence |' |
  belay add plan --title "Plan the change" --stdin
```

The command prints a display ID such as:

```text
GOAL-20260712T090000-001-deliver-the-change
PLN-20260712T090100-001-plan-the-change
```

Use display IDs to connect the trace:

```sh
belay add decision \
  --title "Choose the implementation approach" \
  --body "## Decision\nUse the smallest compatible approach."

belay link <plan-id> <goal-id> --relation fulfills
belay link <decision-id> <goal-id> --relation supports
belay status <plan-id> approved
```

## Workflow

The workflow is human-gated:

1. Planning: create and link Goal, Plan, and Decision entries.
2. Approval: the human explicitly approves implementation.
3. Implementation: create a `jj` change and a Work entry.
4. Reconciliation: update Delivery Map states at checkpoints.
5. Validation: record tests, lint, typecheck, build, and Evidence.
6. Review: an independent agent creates a linked Review entry.
7. Delivery: prepare or create a PR only after explicit approval.
8. Merge: execute only after explicit human instruction and green CI.

Meaningful work should be traceable:

```text
Goal
  -> Plan
  -> Decision
  -> Work
  -> Evidence
  -> Review
  -> Validation
```

Use `belay link` to make these relationships explicit.

## Retrieval Before Reading

Do not begin by scanning all historical Markdown. Let belay rank and bound the
relevant context:

```sh
belay context "implement repository sync" --format agent --budget 2500
belay context compile "implement repository sync" --profile task-start --budget 4000
belay search "repository sync"
belay show <entry-id>
```

This keeps agent context focused while retaining source paths and trace IDs.

## Synchronization

Managed Markdown can be edited directly:

```sh
belay show <entry-id>
# Edit the source path shown by belay.
belay sync <entry-id>
```

When both SQLite and Markdown changed, belay preserves both sides and reports a
conflict. Resolve it only after inspecting the intended source of truth:

```sh
belay sync --prefer markdown <entry-id>
belay sync --prefer sqlite <entry-id>
```

Run health checks before handoff:

```sh
belay sync
belay doctor
```

## Version Control

This template uses `jj`:

```sh
jj st
jj diff
jj new
jj describe -m "feat: describe the change"
jj bookmark set <name>
jj git push
```

Use Conventional Commit titles for changes and pull requests.

## Adapting The Template

1. Update repository ownership and labels under `.github/`.
2. Adjust the human gates and review policy in [AGENTS.md](./AGENTS.md).
3. Replace placeholders in [DESIGN.md](./DESIGN.md).
4. Add project-specific build, test, lint, and typecheck targets.
5. Keep belay's marker-scoped AGENTS section and generated skill current with:

   ```sh
   belay init --update-agents --install-skill codex --install-skill claude
   ```

6. Run `make check`.

## License

This template is available under the [MIT License](./LICENSE).
