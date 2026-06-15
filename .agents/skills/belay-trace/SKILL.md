---
name: belay-trace
description: Use when a task needs project plans, decisions, work history, review context, or trace updates through the local belay CLI.
---

# belay-trace

## Retrieve context

1. Run `belay context "<task>" --format agent --budget 2500` before broad historical reads.
2. Use `belay search "<query>"` for targeted discovery.
3. Use `belay show <id>` only when the full entry is needed.
4. Avoid broad reads of `.belay/entries/` unless a command identifies a specific source path.

## Update trace

1. Use `belay add`, `belay link`, and `belay status` for structured updates.
2. Run `belay sync` after direct managed Markdown edits.
3. Run `belay doctor` when generated or active integration may be stale.

## Conflict safety

Never overwrite an unresolved sync conflict. Inspect both sides and use
`belay sync --prefer markdown <id>` or `belay sync --prefer sqlite <id>` only
after the intended source of truth is known.

Repository-specific policy belongs in the repository `AGENTS.md`, not in this
generic skill.
