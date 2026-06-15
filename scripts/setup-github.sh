#!/usr/bin/env bash

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
	echo "gh is required. See SETUP.md for installation." >&2
	exit 1
fi

repo="${GH_REPO:-}"
if [[ -z "$repo" ]]; then
	repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

if [[ -z "$repo" ]]; then
	echo "Could not determine the GitHub repository." >&2
	exit 1
fi

create_label() {
	local name="$1"
	local color="$2"
	local description="$3"

	gh label create "$name" \
		--color "$color" \
		--description "$description" \
		--force \
		--repo "$repo"
}

ruleset_id() {
	local name="$1"

	gh api \
		--paginate \
		"repos/$repo/rulesets?includes_parents=false&per_page=100" \
		--jq ".[] | select(.name == \"$name\") | .id" |
		head -n 1
}

apply_ruleset() {
	local name="$1"
	local definition="$2"
	local existing_id="${3:-}"
	local id

	if [[ -n "$existing_id" ]]; then
		id="$existing_id"
	else
		id="$(ruleset_id "$name")"
	fi

	if [[ -n "$id" ]]; then
		gh api \
			--method PUT \
			"repos/$repo/rulesets/$id" \
			--input "$definition" \
			--silent
	else
		gh api \
			--method POST \
			"repos/$repo/rulesets" \
			--input "$definition" \
			--silent
	fi
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd "$script_dir/.." && pwd)"
ruleset_dir="$repository_root/.github/rulesets"

gh repo edit "$repo" \
	--enable-squash-merge=true \
	--enable-merge-commit=false \
	--enable-rebase-merge=false \
	--delete-branch-on-merge \
	--allow-update-branch

create_label "bug" "d73a4a" "Confirmed defects, regressions, or broken expected behavior."
create_label "feature" "1d76db" "New functionality, enhancements, or planned implementation work."
create_label "docs" "0075ca" "Documentation-only work, including process and repository guidance."
create_label "blocked" "b60205" "Blocked by an external dependency or unresolved decision."
create_label "needs-review" "fbca04" "Ready for reviewer attention or re-review."
create_label "priority:high" "b60205" "Time-sensitive or merge-blocking work."
create_label "priority:medium" "fbca04" "Important work that should be scheduled soon."
create_label "priority:low" "c5def5" "Useful follow-up work without immediate impact."

review_ruleset_id="$(ruleset_id "Require reviewed PRs")"
bypass_actor_override="${GH_RULESET_BYPASS_ACTOR_ID:-}"
if [[ -n "$bypass_actor_override" ]]; then
	case "$bypass_actor_override" in
	''|*[!0-9]*)
		echo "GH_RULESET_BYPASS_ACTOR_ID must be a numeric GitHub user ID." >&2
		exit 1
		;;
	esac
	bypass_actors_json="[{\"actor_id\": $bypass_actor_override, \"actor_type\": \"User\", \"bypass_mode\": \"pull_request\"}]"
elif [[ -n "$review_ruleset_id" ]]; then
	bypass_actors_json="$(
		gh api "repos/$repo/rulesets/$review_ruleset_id" \
			--jq '.bypass_actors'
	)"
else
	bypass_actor_id="$(gh api user --jq .id)"
	bypass_actors_json="[{\"actor_id\": $bypass_actor_id, \"actor_type\": \"User\", \"bypass_mode\": \"pull_request\"}]"
fi

temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

review_ruleset="$temporary_dir/require-reviewed-prs.json"
sed \
	"s|\"bypass_actors\": \\[\\]|\"bypass_actors\": $bypass_actors_json|" \
	"$ruleset_dir/require-reviewed-prs.json" >"$review_ruleset"

apply_ruleset "Protect main" "$ruleset_dir/protect-main.json"
apply_ruleset "Require reviewed PRs" "$review_ruleset" "$review_ruleset_id"

echo "GitHub labels and rulesets are configured for $repo."
