#!/usr/bin/env bash

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
	echo "gh is required. See SETUP.md for installation." >&2
	exit 1
fi

create_label() {
	local name="$1"
	local color="$2"
	local description="$3"

	if [[ -n "${GH_REPO:-}" ]]; then
		gh label create "$name" \
			--color "$color" \
			--description "$description" \
			--force \
			--repo "$GH_REPO"
	else
		gh label create "$name" \
			--color "$color" \
			--description "$description" \
			--force
	fi
}

create_label "bug" "d73a4a" "Confirmed defects, regressions, or broken expected behavior."
create_label "feature" "1d76db" "New functionality, enhancements, or planned implementation work."
create_label "docs" "0075ca" "Documentation-only work, including process and repository guidance."
create_label "blocked" "b60205" "Blocked by an external dependency or unresolved decision."
create_label "needs-review" "fbca04" "Ready for reviewer attention or re-review."
create_label "priority:high" "b60205" "Time-sensitive or merge-blocking work."
create_label "priority:medium" "fbca04" "Important work that should be scheduled soon."
create_label "priority:low" "c5def5" "Useful follow-up work without immediate impact."

echo "GitHub labels are configured."
