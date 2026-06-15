---
schema_version: 1
id: WRK-20260615T203042-001-address-template-publication-review-findings
type: work
title: Address template publication review findings
status: completed
created_at: 2026-06-15T20:30:42+09:00
updated_at: 2026-06-15T20:44:07+09:00
revision: 4
tags: []
links: []
metadata: {}
---

## Scope

Resolve all five review findings:

- add an MIT license
- ensure docs CI always reports on pull requests
- refresh generated belay integrations
- replace inaccessible provenance text
- make issue-label setup reliable for repositories created from the template

## Progress

- Added the MIT license and linked it from the README.
- Removed the inaccessible provenance URL in favor of repository-local policy.
- Made `docs-ci` run for every pull request.
- Refreshed generated belay assets and synchronized the installed Codex skill.
- Added an idempotent `make github-setup` label initialization flow.
- Removed `lychee` at the human's request.

## Validation

- `make check`: passed.
- `belay doctor`: passed.
- macOS `/bin/bash` syntax and mocked execution passed with `GH_REPO` unset
  and set.
- GitHub Actions workflow parsed successfully as YAML.
- Label setup was exercised with a fake `gh` command and produced all expected
  `gh label create --force` invocations.
- `typos --config .github/.typos.toml scripts LICENSE`: passed.
- Independent review found one Bash 3.2 compatibility defect; it was fixed,
  and re-review reported no remaining findings.

## Constraints

The required `jj new`, `jj st`, and `jj diff` commands were attempted, but the
environment denied temporary writes to `.git/objects`, including after
escalation. Existing workspace changes were preserved.
