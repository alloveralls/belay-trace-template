# GitHub Configuration

This directory contains repository-level GitHub configuration for the
belay-based agent workflow.

## Files

- `pull_request_template.md`: trace-aware pull request structure
- `ISSUE_TEMPLATE/`: bug and task issue forms
- `CODEOWNERS`: default review ownership
- `CONTRIBUTING.md`: contributor workflow
- `labels.md`: shared label policy
- `workflows/pr-title.yml`: Conventional Commit title validation
- `workflows/docs-ci.yml`: documentation and skill validation
- `../scripts/setup-github-labels.sh`: idempotent label initialization

Repository operating rules live in [AGENTS.md](../AGENTS.md). Trace body and
lifecycle guidance lives in [TRACE_GUIDE.md](../TRACE_GUIDE.md).

## Repository Settings

Recommended settings:

- require at least one pull request approval
- require all configured status checks
- enable squash merge
- disable direct pushes to `main`
- enable branch deletion after merge

Update `CODEOWNERS`, issue forms, and labels for the project before active use.
Run `make github-setup` once after creating a repository from this template so
the labels referenced by issue forms exist.
