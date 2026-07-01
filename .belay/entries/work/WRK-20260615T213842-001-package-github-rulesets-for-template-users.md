---
schema_version: 1
id: WRK-20260615T213842-001-package-github-rulesets-for-template-users
type: work
title: Package GitHub rulesets for template users
status: completed
created_at: 2026-06-15T21:38:42+09:00
updated_at: 2026-06-15T21:52:11+09:00
revision: 3
tags: []
links: []
metadata: {}
---

## Scope

Store repository rulesets as versioned template assets and make `make github-setup` apply labels and rulesets idempotently to repositories created from the template.

## Implemented

- Added checked-in JSON definitions under `.github/rulesets/`.
- Replaced the label-only setup script with a complete GitHub setup script.
- Create or update repository-owned rulesets by exact name with pagination.
- On creation, add the authenticated user as a pull-request-only review
  bypass.
- On update, preserve the complete existing bypass actor array.
- Allow an explicit numeric user override through
  `GH_RULESET_BYPASS_ACTOR_ID`.
- Configure squash-only merging, branch updates, and merged-branch deletion.
- Document inheritance limitations, required permissions, and usage.
- Added mocked setup tests to `make check`.

## Validation

- `make check`: passed.
- Mocked create, update, multi-actor preservation, and explicit override paths:
  passed on macOS Bash 3.2.
- `make github-setup`: passed against the live repository.
- Repeated application retained ruleset IDs `17690822` and `17690999`.
- Live review bypass remained pull-request-only for `alloveralls`.
- Independent review completed with no remaining findings.
