# Setup

This guide prepares a repository created from `belay-trace-template`.

## Prerequisites

- macOS or Linux
- Rust 1.87 or newer
- `jj`
- `gh`
- Codex and/or Claude Code
- `markdownlint-cli2` and `typos` for documentation checks

## Install belay-trace

Install from GitHub:

```sh
cargo install \
  --git https://github.com/alloveralls/belay-trace \
  --locked
```

For a sibling development checkout:

```sh
cargo install --path ../belay-trace --locked
```

Verify:

```sh
belay --version
```

## Install Supporting Tools

One option is `mise` plus Homebrew.

```sh
mise use --global node@24
mise use --global github:jj-vcs/jj@latest
mise use --global npm:@anthropic-ai/claude-code@latest
mise use --global npm:@openai/codex@latest
mise use --global npm:markdownlint-cli2@latest
mise use --global typos@latest
brew install gh
```

Verify:

```sh
jj --version
gh --version
codex --version
claude --version
markdownlint-cli2 --version
typos --version
```

Authenticate the services you use:

```sh
gh auth login
codex
claude
```

The authenticated GitHub account needs repository administration and issue
management permission. For fine-grained tokens or GitHub Apps, grant
`Administration: write` and `Issues: write`.

## Initialize GitHub Configuration

Repositories created from a GitHub template do not inherit custom labels or
rulesets. Create or update the labels and default-branch rulesets:

```sh
make github-setup
```

The command targets the repository associated with the current checkout. Set
`GH_REPO=owner/name` to target another repository explicitly. It creates two
active rulesets:

- `Protect main`: blocks deletion and force pushes, and requires
  `markdownlint`, `typos`, and `validate`
- `Require reviewed PRs`: requires one approval, resolved conversations, and
  squash merging

When the review ruleset is first created, the authenticated GitHub user
receives a pull-request-only bypass so a sole maintainer is not locked out.
Later runs preserve all existing bypass actors. Set
`GH_RULESET_BYPASS_ACTOR_ID=<numeric-user-id>` to explicitly replace them with
one pull-request-only user bypass.

The command also enables squash merging, disables merge commits and rebase
merging, allows pull request branches to be updated, and deletes merged
branches.

Rulesets for private repositories require a GitHub plan that supports them. If
the repository will become public, run this command after changing visibility.

## Initialize Version Control

Repositories created from the GitHub template already have Git metadata. Add a
colocated `jj` workspace:

```sh
jj git init --colocate
```

For a copied directory with no repository metadata:

```sh
git init -b main
jj git init --colocate
```

After initialization, use `jj` for normal version-control operations.

## Initialize Or Refresh belay

This template is already initialized. Running init again is safe and refreshes
required generated assets:

```sh
make bootstrap
```

The command:

- creates or repairs `.belay/config.toml`
- creates managed entry directories
- creates local SQLite state
- updates only the marker-scoped belay section in `AGENTS.md`
- installs the generic Codex skill at `.agents/skills/belay-trace/SKILL.md`
- installs the generic Claude skill at `.claude/skills/belay-trace/SKILL.md`

Verify:

```sh
belay doctor
```

## Read Before Working

Read:

- [README.md](./README.md)
- [AGENTS.md](./AGENTS.md)
- [TRACE_GUIDE.md](./TRACE_GUIDE.md)

Then retrieve relevant history:

```sh
belay context "<task>" --format agent --budget 2500
```

For belay 0.2.0, prefer the compiled context form at task start:

```sh
belay context compile "<task>" --format agent --budget 4000
```

## Normal Task Lifecycle

Planning:

```sh
belay add goal --title "<title>"
belay add plan --title "<title>" --body-file <plan-body.md>
belay goal lint <goal-id>
belay add decision --title "<title>" --body-file <decision-body.md>
belay link <plan-id> <goal-id> --relation fulfills
belay link <decision-id> <goal-id> --relation supports
```

After explicit implementation approval:

```sh
belay status <plan-id> approved
jj new
belay add work --title "<title>" --body-file <work-body.md>
belay link <work-id> <goal-id-or-goal-fragment> --relation fulfills
```

After implementation and independent review:

```sh
belay add review --title "<title>" --body-file <review-body.md>
belay link <review-id> <work-id> --relation reviews
belay verify record \
  --kind test \
  --verdict pass \
  --source "<command>" \
  --summary "<what passed>" \
  --verifies <goal-id-or-work-id>
belay coverage
belay status <review-id> completed
belay status <work-id> completed
belay sync
belay doctor
```

See [TRACE_GUIDE.md](./TRACE_GUIDE.md) for recommended entry bodies and status
values.

## Validate The Repository

Run all template checks:

```sh
make check
```

Run individual checks:

```sh
make belay-check
make skill-check
make updater-check
make github-config-check
make lint-md
make typos-check
```

## Update Existing Template Projects

To apply the current template workflow skills to existing repositories:

```sh
scripts/update-existing-project.sh --check "/path/with spaces/project"
scripts/update-existing-project.sh "/path/with spaces/project"
```

Use `--belay /path/to/belay` to select a specific belay binary. The target must
already contain `.belay/config.toml` unless `--initialize` is provided.

The updater deliberately does not overwrite project-owned `AGENTS.md` text
outside belay's managed section, README, SETUP, Makefile, or GitHub
configuration. It only syncs template-managed workflow skill directories and
runs:

```sh
belay init --update-agents --install-skill codex --install-skill claude
belay doctor
```

Partial update risk: the script validates staged files before applying them,
but the final copy still updates several paths. If the process is interrupted
or the filesystem fails, the target may contain a partial skill update. Run from
a clean target checkout, keep the target under version control, and inspect the
target diff after completion.

## Adapt For A New Project

1. Update `.github/CODEOWNERS`.
2. Run `make github-setup`, then update issue forms, labels, and merge policy.
3. Adjust `AGENTS.md` for project-specific commands and risk rules.
4. Fill in `DESIGN.md` or remove it if the project has no product/UI concerns.
5. Add project test, lint, typecheck, and build targets to the Makefile.
6. Update `.github/rulesets/` when changing workflow job names or merge policy.
7. Run `belay init --update-agents --install-skill codex --install-skill claude`.
8. Run `make check`.

## Troubleshooting

### Repository Not Initialized

Run:

```sh
belay init --update-agents --install-skill codex --install-skill claude
```

### Sync Drift Or Conflict

Inspect the entry:

```sh
belay show <entry-id>
belay sync <entry-id>
```

For a true conflict, inspect both versions before choosing:

```sh
belay sync --prefer markdown <entry-id>
belay sync --prefer sqlite <entry-id>
```

### Missing SQLite State

Rebuild local state from tracked Markdown:

```sh
belay rebuild
belay doctor
```

### Agent Integration Is Stale

Refresh generated assets and integrations:

```sh
belay init --update-agents --install-skill codex --install-skill claude
belay doctor
```
