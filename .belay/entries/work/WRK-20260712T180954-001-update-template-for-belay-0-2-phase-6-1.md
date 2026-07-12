---
schema_version: 1
id: WRK-20260712T180954-001-update-template-for-belay-0-2-phase-6-1
type: work
title: Update template for belay 0.2 Phase 6.1
status: completed
created_at: 2026-07-12T18:09:54+09:00
updated_at: 2026-07-12T18:20:28+09:00
revision: 6
tags: []
links: []
metadata: {}
---

## Objective

Update belay-trace-template to belay 0.2.0 / Phase 6.1 agent-first delivery assurance.

## Related Context

- Requested by delegated Codex task.
- jj change: zykzxxls

## Delivery Map

| ID | Outcome / Task | State | Verification / Evidence |
| --- | --- | --- | --- |
| T-1 | Run current belay updater and install Codex/Claude belay skills | verified | updater output and belay doctor |
| T-2 | Refresh shared workflow skills and adapters for Phase 6.1 | verified | `make skill-check` and YAML inspection passed |
| T-3 | Update AGENTS, TRACE_GUIDE, README, SETUP, and Makefile | verified | `make check` passed |
| T-4 | Run belay doctor, skill validation, make check, and jj diff | verified | `belay doctor`, `belay coverage`, `make check`, and `jj diff --stat` passed |

## Progress

- Ran `jj new` before implementation.
- Ran current `scripts/update-existing-project.sh` with belay 0.2.0 debug binary.
- Noted accidental shell expansion when using inline body text with backticks; corrected process to use file edits and will squash only the accidental child change into the Phase 6.1 change.
- Updated shared workflow skills, Codex adapters, Makefile, AGENTS, README, SETUP, and TRACE_GUIDE.
- Regenerated the three Codex `openai.yaml` files with skill-creator `generate_openai_yaml.py`.
- Updated `make skill-check` to validate `interface.display_name`, `interface.short_description` length, `interface.default_prompt`, and `$<skill-name>` mention.
- Added a docs-ci `skill-check` job so `openai.yaml` changes are checked in CI, not only by local `make check`.

## Validation

- Command: `scripts/update-existing-project.sh --belay ... --update-agents --install-codex --install-claude ...`
  Result: pass.
- Command: `belay doctor`
  Result: pass.
- Command: `belay coverage`
  Result: pass; no active goals.
- Command: `python3 .../generate_openai_yaml.py ...`
  Result: pass for all three Codex adapters.
- Command: `python3 .../quick_validate.py .shared/skills/project-planning`
  Result: not run successfully because PyYAML is not installed in the active Python environment.
- Command: `make skill-check`
  Result: pass.
- Command: `make check`
  Result: pass with belay 0.2.0 debug binary, mise shims, and temporary mise cache on PATH.
- Command: `jj diff --stat`
  Result: pass; inspected changed-file summary.
- Command: focused diff review
  Result: pass; no blocking findings found in the adapter shape, Phase 6.1 scope, generated belay skill parity, or validation wiring.

## Assumptions

- This is a hypothesis: Phase 6.1 should stay text/skill-driven and avoid introducing any Phase 6.2 deterministic CLI or schema requirement beyond current belay 0.2.0 commands.

## Next Steps

- None.
