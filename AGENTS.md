# Project Guidelines

## Core Principles

- Optimize for resumability, traceability, and safe autonomous execution.
- Preserve rationale, not only implementation details.
- Separate facts, assumptions, hypotheses, and conclusions.
- Use `belay-trace` as the source of truth for plans, decisions, work, reviews,
  and durable notes.
- Keep managed Markdown under `.belay/entries/` tracked in version control.
- Treat `.belay/state/` as local operational state, never as a review artifact.

## Human-Gated Workflow

This project uses explicit human gates. Agents must not autonomously transition
between planning, implementation, issue creation, pull request creation, or
merge phases.

Explicit human approval is required before:

- creating an actual issue
- starting implementation
- creating a pull request
- merging a pull request

Ambiguous responses such as "looks good", "sounds fine", or "進めて" are not
sufficient unless the exact approved action is clear from the immediate
context.

## Start Every Task With Context

Before broad historical reads, run:

```sh
belay context "<task>" --format agent --budget 2500
```

Then use:

```sh
belay search "<targeted query>"
belay show <entry-id>
```

Do not broadly scan `.belay/entries/`. Read a managed Markdown file directly
only when `belay show` or another focused command identifies it as relevant.

## Planning Flow

Use planning flow when the human asks to plan, clarify, design, scope, prepare
an issue, or compare approaches.

During planning:

1. Retrieve related context with `belay context`.
2. Clarify scope, non-scope, risks, dependencies, and acceptance criteria.
3. Create a plan entry with `belay add plan`.
4. Create decision entries with `belay add decision` when meaningful tradeoffs
   or contracts are established.
5. Link decisions to the plan with `belay link`.
6. Draft requested issue content without creating the actual issue.
7. Stop at the relevant human gate.

Planning does not authorize source changes, `jj new`, issue creation, pull
request creation, or merge execution.

When the human explicitly approves a plan, set it to `approved`:

```sh
belay status <plan-id> approved
```

## Implementation Flow

Start implementation only after explicit human instruction.

Before implementation:

1. Retrieve the task context and inspect linked plans, decisions, reviews, and
   issues.
2. Run `belay sync` and resolve any drift without overwriting conflicts.
3. Create a new change with `jj new`.
4. Create a work entry with `belay add work`.
5. Link the work entry to its plan and decisions using `implements` or
   `references`.

During implementation:

- keep the work entry current with progress, changed files, validation,
  blockers, observations, assumptions, and hypotheses
- run `belay sync` after directly editing managed Markdown
- create new decision entries when implementation establishes a meaningful
  architectural, API, operational, or tradeoff decision
- validate with the project's test, lint, typecheck, and build commands

After implementation:

1. Request an independent implementation-time review via Codex `/subagents` or
   Claude Code `/agents`.
2. Create a review entry with `belay add review`.
3. Link the review to the work entry with relation `reviews`.
4. Address findings or record why they are deferred.
5. Set completed review and work entries to `completed`.
6. Run `belay sync` and `belay doctor`.
7. Prepare or create a pull request only when explicitly instructed.

## Trace Entry Guidance

Follow [TRACE_GUIDE.md](./TRACE_GUIDE.md) for recommended entry bodies,
statuses, relations, and lifecycle examples.

Use these entry types:

| Type | Purpose |
|---|---|
| `plan` | Scope, approach, risks, and acceptance criteria. |
| `decision` | A concrete decision and its rationale or tradeoffs. |
| `work` | Implementation progress, evidence, blockers, and validation. |
| `review` | Findings, risks, recommendations, and review outcome. |
| `note` | Durable context that does not fit another entry type. |

Use display IDs in commands and cross-references. Prefer explicit links over
duplicated narrative.

## Decision Rules

Create or update a decision entry when:

- architecture changes
- API contracts change
- important tradeoffs are made
- operational rules change
- significant refactors occur
- temporary decisions are introduced
- an earlier decision is rejected or superseded

When replacing a decision:

1. Create the new decision.
2. Link it to the older decision with relation `supersedes`.
3. Set the older decision status to `superseded`.
4. Record what changed and why.

## Review Rules

Every implementation requires an independent implementation-time review before
pull request preparation.

Review entries should include:

- findings ordered by severity
- file and line references where applicable
- risks and recommendations
- validation performed
- positive findings
- follow-up actions and owners
- whether human review is additionally required

Set `requires_human_review: true` in the review body when:

- security implications exist
- assumptions cannot be validated
- rollback strategy is unclear
- production impact is uncertain
- architectural impact is broad

Human review is additional to, not a replacement for, independent agent review.

## Conflict Safety

Never overwrite an unresolved sync conflict.

Inspect both sides and use one of these only after the intended source of truth
is known:

```sh
belay sync --prefer markdown <entry-id>
belay sync --prefer sqlite <entry-id>
```

Deletion does not propagate in belay v1. Use a terminal status such as
`abandoned`, `rejected`, `superseded`, or `archived` instead of deleting trace
history.

## Version Control

Use `jj` for all version-control operations. Do not use raw `git` commands
unless the human explicitly instructs it.

| Purpose | Command |
|---|---|
| Status | `jj st` |
| Diff | `jj diff` |
| History | `jj log` |
| New change | `jj new` |
| Edit message | `jj describe -m "message"` |
| Squash | `jj squash` |
| Bookmark | `jj bookmark set <name>` |
| Push | `jj git push` |

Use Conventional Commits:

```text
<type>[optional scope]: <description>
```

Allowed types are `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`,
and `ci`.

## Merge Rules

- Never merge without explicit human instruction.
- Never merge with failing CI.
- Use squash merge.
- Never push directly to `main` unless explicitly instructed.

## Final Validation

Before handing off completed implementation:

```sh
belay sync
belay doctor
jj st
jj diff
```

Record the validation outcome in the work and review entries.

<!-- belay-trace:start -->
## belay-trace

- Run `belay context "<task>" --format agent --budget 2500` before broad historical log reads.
- Use `belay search "<query>"` for targeted discovery and `belay show <id>` only when a full entry is needed.
- Use `belay add`, `belay link`, and `belay status` for trace updates.
- Run `belay sync` after direct managed Markdown edits.
- Never overwrite an unresolved sync conflict. Inspect it and use an explicit `belay sync --prefer markdown <id>` or `belay sync --prefer sqlite <id>` only after the intended source of truth is known.
- Do not scan `.belay/entries/` broadly unless a specific source path is required.
<!-- belay-trace:end -->
