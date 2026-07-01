---
schema_version: 1
id: WRK-20260615T212943-001-align-template-rulesets-with-belay-trace
type: work
title: Align template rulesets with belay-trace
status: completed
created_at: 2026-06-15T21:29:43+09:00
updated_at: 2026-06-15T21:30:48+09:00
revision: 3
tags: []
links: []
metadata: {}
---

## Scope

Align the template repository ruleset structure with `alloveralls/belay-trace` while preserving template-specific CI check names and squash-only merging.

## Applied Changes

- Restrict `Protect main` to deletion, force-push, and required checks with no bypass.
- Exempt branch creation from required checks.
- Create `Require reviewed PRs` with one approval and resolved conversations.
- Allow only the repository owner to bypass the review rule via a pull request.
- Keep template-specific required checks: `markdownlint`, `typos`, and `validate`.

## Validation

- `Protect main` is active as ruleset `17690822`.
- `Require reviewed PRs` is active as ruleset `17690999`.
- GitHub reports both rulesets as applied to `main`.
- The protection ruleset has no bypass actors.
- The review ruleset grants only user `alloveralls` a pull-request-only bypass.
- CODEOWNERS review is not required.
- Required checks are not enforced on branch creation.
- Remaining differences from `belay-trace` are intentional:
  template-specific CI check names and squash-only merging.
