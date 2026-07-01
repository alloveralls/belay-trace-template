---
schema_version: 1
id: WRK-20260615T212008-001-apply-public-repository-protections
type: work
title: Apply public repository protections
status: completed
created_at: 2026-06-15T21:20:08+09:00
updated_at: 2026-06-15T21:22:16+09:00
revision: 3
tags: []
links: []
metadata: {}
---

## Scope

Apply the GitHub protections that became available after public release.

## Applied Settings

- Created active ruleset `Protect main` for the default branch.
- Required pull requests, one approval, CODEOWNERS review, resolved
  conversations, current branch checks, and squash merge.
- Required `markdownlint`, `typos`, and `validate`.
- Blocked branch deletion, force pushes, and non-linear history.
- Preserved an administrator emergency bypass.
- Enabled secret scanning and push protection.
- Enabled private vulnerability reporting.

## Validation

- Repository visibility is public.
- Ruleset ID `17690822` is active.
- GitHub reports every configured rule as applied to `main`.
- Secret scanning is enabled.
- Secret scanning push protection is enabled.
- Private vulnerability reporting is enabled.
- Secret scanning currently reports zero alerts.
- Dependabot currently reports zero alerts.
