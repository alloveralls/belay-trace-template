#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

export MOCK_LOG="$temporary_dir/gh.log"
export MOCK_OUTPUT="$temporary_dir/output"
mkdir -p "$MOCK_OUTPUT"

gh() {
	printf '%s\n' "$*" >>"$MOCK_LOG"

	if [[ "$1" == "repo" && "$2" == "view" ]]; then
		printf '%s\n' "example/project"
		return
	fi

	if [[ "$1" == "repo" && "$2" == "edit" ]]; then
		return
	fi

	if [[ "$1" == "label" && "$2" == "create" ]]; then
		return
	fi

	if [[ "$1" != "api" ]]; then
		return
	fi

	local arguments="$*"
	if [[ "$arguments" == *"rulesets?includes_parents=false&per_page=100"* ]]; then
		if [[ "${MOCK_EXISTING:-0}" == "1" ]]; then
			if [[ "$arguments" == *"Protect main"* ]]; then
				printf '%s\n' "10"
			elif [[ "$arguments" == *"Require reviewed PRs"* ]]; then
				printf '%s\n' "20"
			fi
		fi
		return
	fi

	if [[ "$arguments" == *"repos/example/project/rulesets/20"* &&
		"$arguments" == *"bypass_actors"* ]]; then
		printf '%s\n' \
			'[{"actor_id":222,"actor_type":"User","bypass_mode":"pull_request"},{"actor_id":5,"actor_type":"RepositoryRole","bypass_mode":"always"}]'
		return
	fi

	if [[ "$arguments" == *" user "* || "$arguments" == "api user "* ]]; then
		printf '%s\n' "111"
		return
	fi

	local method=""
	local input=""
	local path=""
	while [[ "$#" -gt 0 ]]; do
		case "$1" in
		--method)
			method="$2"
			shift 2
			;;
		--input)
			input="$2"
			shift 2
			;;
		repos/*)
			path="$1"
			shift
			;;
		*)
			shift
			;;
		esac
	done

	if [[ -n "$input" ]]; then
		if grep -q '"Protect main"' "$input"; then
			cp "$input" "$MOCK_OUTPUT/protect-$method.json"
		else
			cp "$input" "$MOCK_OUTPUT/review-$method.json"
		fi
	fi

	printf '%s\n' "$path" >>"$MOCK_LOG"
}
export -f gh

assert_contains() {
	local pattern="$1"
	local file="$2"

	if ! grep -q -- "$pattern" "$file"; then
		echo "Expected $file to contain: $pattern" >&2
		exit 1
	fi
}

assert_not_contains() {
	local pattern="$1"
	local file="$2"

	if grep -q -- "$pattern" "$file"; then
		echo "Expected $file not to contain: $pattern" >&2
		exit 1
	fi
}

reset_mock() {
	: >"$MOCK_LOG"
	rm -f "$MOCK_OUTPUT"/*.json
}

reset_mock
unset GH_REPO GH_RULESET_BYPASS_ACTOR_ID MOCK_EXISTING
/bin/bash "$repository_root/scripts/setup-github.sh"
assert_contains "--enable-squash-merge=true" "$MOCK_LOG"
assert_contains "rulesets?includes_parents=false&per_page=100" "$MOCK_LOG"
assert_contains '"actor_id":[[:space:]]*111' "$MOCK_OUTPUT/review-POST.json"

reset_mock
export GH_REPO="example/project"
export MOCK_EXISTING=1
unset GH_RULESET_BYPASS_ACTOR_ID
/bin/bash "$repository_root/scripts/setup-github.sh"
assert_contains "repos/example/project/rulesets/10" "$MOCK_LOG"
assert_contains "repos/example/project/rulesets/20" "$MOCK_LOG"
assert_contains '"actor_id":[[:space:]]*222' "$MOCK_OUTPUT/review-PUT.json"
assert_contains '"actor_id":[[:space:]]*5' "$MOCK_OUTPUT/review-PUT.json"
assert_contains '"actor_type":[[:space:]]*"RepositoryRole"' "$MOCK_OUTPUT/review-PUT.json"

reset_mock
export GH_RULESET_BYPASS_ACTOR_ID=333
/bin/bash "$repository_root/scripts/setup-github.sh"
assert_contains '"actor_id":[[:space:]]*333' "$MOCK_OUTPUT/review-PUT.json"
assert_not_contains '"actor_id":[[:space:]]*222' "$MOCK_OUTPUT/review-PUT.json"
assert_not_contains '"actor_id":[[:space:]]*5' "$MOCK_OUTPUT/review-PUT.json"

echo "GitHub setup tests passed."
