---
schema_version: 1
id: WRK-20260615T211443-001-configure-repository-before-public-release
type: work
title: Configure repository before public release
status: completed
created_at: 2026-06-15T21:14:43+09:00
updated_at: 2026-06-15T21:16:49+09:00
revision: 3
tags: []
links: []
metadata: {}
---

## Scope

Configure the published private GitHub repository for eventual public release without changing its visibility.

## Applied Settings

- Enabled template repository mode.
- Enabled squash merge only with PR title and description for the commit.
- Enabled automatic deletion of merged branches and PR branch updates.
- Kept Issues enabled; disabled Projects and Wiki.
- Added repository topics for AI agents, traceability, belay, Codex, Claude
  Code, templates, and `jj`.
- Created or updated all labels required by the issue forms and label policy.
- Enabled vulnerability alerts and Dependabot security updates.
- Kept Actions workflow permissions read-only and prevented workflows from
  approving pull requests.

## Public-Only Follow-Up

GitHub reports that branch protection and repository rulesets are unavailable
while this repository is private on the current plan. Apply main-branch pull
request protection and required checks immediately after the repository becomes
public. Enable secret scanning and push protection at the same time.

## Validation

- Repository remains private.
- Template repository mode is active.
- MIT license is detected by GitHub.
- Squash merge is the only enabled merge method.
- CODEOWNERS validation reports no errors.
- Both repository workflows are active.
- Actions default workflow permission is `read`.
- The latest `docs-ci` run completed successfully; `markdownlint` and `typos`
  both passed.
- Vulnerability alerts and Dependabot security updates are enabled.
- Dependabot currently reports zero alerts.
