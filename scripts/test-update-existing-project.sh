#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

belay_bin="${BELAY_BIN:-${BELAY:-belay}}"

assert_contains() {
	local pattern="$1"
	local file="$2"

	if ! grep -q -- "$pattern" "$file"; then
		echo "Expected $file to contain: $pattern" >&2
		exit 1
	fi
}

assert_file_exists() {
	local path="$1"

	if [[ ! -e "$path" ]]; then
		echo "Expected file to exist: $path" >&2
		exit 1
	fi
}

assert_symlink() {
	local path="$1"
	local target="$2"

	if [[ ! -L "$path" ]]; then
		echo "Expected symlink: $path" >&2
		exit 1
	fi
	if [[ "$(readlink "$path")" != "$target" ]]; then
		echo "Expected $path to point to $target, got $(readlink "$path")" >&2
		exit 1
	fi
}

make_project() {
	local path="$1"

	mkdir -p "$path"
	(
		cd "$path"
		git init -q
		"$belay_bin" init --update-agents --install-skill codex --install-skill claude >/dev/null
	)
	/bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" "$path" >/dev/null
}

project="$temporary_dir/project with spaces"
make_project "$project"

printf '%s\n' "project readme" >"$project/README.md"
printf '%s\n' "stale shared skill" >"$project/.shared/skills/project-planning/SKILL.md"
rm -f "$project/.agents/skills/codex-project-planning/SKILL.md"
printf '%s\n' "not a symlink" >"$project/.agents/skills/codex-project-planning/SKILL.md"
mkdir -p "$project/.agents/skills/custom" "$project/.shared/skills/custom"
printf '%s\n' "custom agent skill" >"$project/.agents/skills/custom/SKILL.md"
printf '%s\n' "custom shared skill" >"$project/.shared/skills/custom/SKILL.md"

if /bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" --check "$project" >/dev/null 2>&1; then
	echo "Expected --check to detect drift" >&2
	exit 1
fi
assert_contains "stale shared skill" "$project/.shared/skills/project-planning/SKILL.md"

/bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" "$project" >"$temporary_dir/update.log"
assert_contains "Planned updates" "$temporary_dir/update.log"
assert_contains "name: project-planning-workflow" "$project/.shared/skills/project-planning/SKILL.md"
assert_symlink "$project/.agents/skills/codex-project-planning/SKILL.md" "../../../.shared/skills/project-planning/SKILL.md"
assert_symlink "$project/.claude/skills/claude-project-planning/SKILL.md" "../../../.shared/skills/project-planning/SKILL.md"
assert_file_exists "$project/.agents/skills/custom/SKILL.md"
assert_file_exists "$project/.shared/skills/custom/SKILL.md"
assert_contains "project readme" "$project/README.md"

/bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" --check "$project" >"$temporary_dir/check-clean.log"
assert_contains "no drift" "$temporary_dir/check-clean.log"

blocked="$temporary_dir/blocked project"
make_project "$blocked"
rm -f "$blocked/.shared/skills/project-planning/SKILL.md"
mkdir -p "$blocked/.shared/skills/project-planning/SKILL.md"
if /bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" "$blocked" >/dev/null 2>&1; then
	echo "Expected file/directory overlay conflict to be rejected" >&2
	exit 1
fi
if [[ ! -d "$blocked/.shared/skills/project-planning/SKILL.md" ]]; then
	echo "Expected blocked directory to be preserved" >&2
	exit 1
fi

uninitialized="$temporary_dir/uninitialized project"
mkdir -p "$uninitialized"
(
	cd "$uninitialized"
	git init -q
)
if /bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" "$uninitialized" >/dev/null 2>&1; then
	echo "Expected uninitialized project to be rejected" >&2
	exit 1
fi

/bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" --initialize "$uninitialized" >"$temporary_dir/initialize.log"
assert_file_exists "$uninitialized/.belay/config.toml"
assert_symlink "$uninitialized/.agents/skills/codex-project-planning/SKILL.md" "../../../.shared/skills/project-planning/SKILL.md"

if /bin/bash "$repository_root/scripts/update-existing-project.sh" --belay "$belay_bin" "$repository_root" >/dev/null 2>&1; then
	echo "Expected template source self-update to be rejected" >&2
	exit 1
fi

echo "Existing project updater tests passed."
