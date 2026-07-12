---
schema_version: 1
id: WRK-20260712T182331-001-add-updater-for-existing-template-projects
type: work
title: Add updater for existing template projects
status: completed
created_at: 2026-07-12T18:23:31+09:00
updated_at: 2026-07-12T18:36:09+09:00
revision: 4
tags: []
links: []
metadata: {}
---

## Objective

Add a safe updater script that applies current belay-trace-template workflow skill files to existing initialized template projects.

## Related Context

- Request: add scripts/update-existing-project.sh with check mode, initialization guard, belay refresh, skill sync, and integration tests.
- jj change: plttuulq

## Delivery Map

| ID | Outcome / Task | State | Verification / Evidence |
| --- | --- | --- | --- |
| T-1 | Implement safe updater script | implemented | `scripts/update-existing-project.sh` stages template-managed skill trees, checks drift, preserves unrelated skill files, runs belay init/doctor, and rejects self-application |
| T-2 | Add temporary-project integration tests | implemented | `scripts/test-update-existing-project.sh` covers spaces in paths, drift check, update apply, initialization guard, `--initialize`, custom skill preservation, symlink restoration, and self-update refusal |
| T-3 | Document partial update risks and usage | implemented | README.md and SETUP.md document updater scope, default non-overwrite policy, `--check`, `--initialize`, and partial-update recovery risk |
| T-4 | Run belay doctor, make check, and jj diff | verified | `make updater-check`, `make check`, final `belay doctor`, and `jj diff --stat` passed locally |

## Progress

- Created a new jj change before implementation.
- Added a safe updater script for existing template projects.
- Added a temporary git repository integration test and wired it into `make check`.
- Documented updater usage and the risk that failures after `belay init` can leave partial updates for review or rerun.
- Added explicit failure propagation and overlay conflict preflight so directory/file collisions are rejected before applying managed skill copies.

## Validation

- `make updater-check` passed.
- `make check` passed with the current belay binary on PATH.
- Evidence recorded: EVD-20260712T183023-001, EVD-20260712T183121-001, EVD-20260712T183520-001.
- `belay sync`, `belay doctor`, and `jj diff --stat` completed after implementation.

## Next Steps

- No remaining implementation steps.
