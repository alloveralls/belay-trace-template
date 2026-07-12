#!/usr/bin/env bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: scripts/update-existing-project.sh [OPTIONS] PROJECT [PROJECT ...]

Safely update existing belay-trace-template projects with the workflow skills
from this template checkout.

Options:
  --belay PATH     Use PATH instead of the installed belay command
  --initialize     Allow targets without .belay/config.toml
  --check          Detect drift without changing target projects
  -h, --help       Show this help

This script updates only:
  .shared/skills/<template skill>/
  .agents/skills/codex-{project-planning,implementation-delivery,decision-review}/
  .claude/skills/claude-{project-planning,implementation-delivery,decision-review}/

It does not overwrite project-specific AGENTS.md text outside the managed belay
section, README.md, SETUP.md, Makefile, or GitHub configuration.
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template_root="$(cd "$script_dir/.." && pwd)"
cleanup_paths=()

cleanup() {
	local path

	for path in "${cleanup_paths[@]}"; do
		rm -rf "$path"
	done
}
trap cleanup EXIT

belay_bin=""
allow_initialize=false
check_only=false
projects=()

while [[ "$#" -gt 0 ]]; do
	case "$1" in
	--belay)
		if [[ "$#" -lt 2 ]]; then
			echo "error: --belay requires a path" >&2
			exit 2
		fi
		belay_bin="$2"
		shift 2
		;;
	--initialize)
		allow_initialize=true
		shift
		;;
	--check)
		check_only=true
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	--)
		shift
		while [[ "$#" -gt 0 ]]; do
			projects+=("$1")
			shift
		done
		;;
	-*)
		echo "error: unknown option: $1" >&2
		usage >&2
		exit 2
		;;
	*)
		projects+=("$1")
		shift
		;;
	esac
done

if [[ "${#projects[@]}" -eq 0 ]]; then
	echo "error: provide at least one project path" >&2
	usage >&2
	exit 2
fi

if [[ -z "$belay_bin" ]]; then
	if ! belay_bin="$(command -v belay)"; then
		echo "error: belay is required; pass --belay PATH or install belay" >&2
		exit 2
	fi
fi

case "$belay_bin" in
/*) ;;
*) belay_bin="$(cd "$(dirname "$belay_bin")" && pwd)/$(basename "$belay_bin")" ;;
esac

if [[ ! -x "$belay_bin" ]]; then
	echo "error: belay binary is not executable: $belay_bin" >&2
	exit 2
fi

managed_roots=(
	".shared/skills/project-planning"
	".shared/skills/implementation-delivery"
	".shared/skills/decision-review"
	".agents/skills/codex-project-planning"
	".agents/skills/codex-implementation-delivery"
	".agents/skills/codex-decision-review"
	".claude/skills/claude-project-planning"
	".claude/skills/claude-implementation-delivery"
	".claude/skills/claude-decision-review"
)

validate_source() {
	local root="$1"

	for rel in "${managed_roots[@]}"; do
		if [[ ! -d "$root/$rel" ]]; then
			echo "error: template source missing $rel" >&2
			return 1
		fi
	done

	if [[ "$(readlink "$root/.agents/skills/codex-project-planning/SKILL.md")" != "../../../.shared/skills/project-planning/SKILL.md" ]]; then
		echo "error: codex project-planning SKILL.md symlink is invalid" >&2
		return 1
	fi
	if [[ "$(readlink "$root/.agents/skills/codex-implementation-delivery/SKILL.md")" != "../../../.shared/skills/implementation-delivery/SKILL.md" ]]; then
		echo "error: codex implementation-delivery SKILL.md symlink is invalid" >&2
		return 1
	fi
	if [[ "$(readlink "$root/.agents/skills/codex-decision-review/SKILL.md")" != "../../../.shared/skills/decision-review/SKILL.md" ]]; then
		echo "error: codex decision-review SKILL.md symlink is invalid" >&2
		return 1
	fi
	if [[ "$(readlink "$root/.claude/skills/claude-project-planning/SKILL.md")" != "../../../.shared/skills/project-planning/SKILL.md" ]]; then
		echo "error: claude project-planning SKILL.md symlink is invalid" >&2
		return 1
	fi
	if [[ "$(readlink "$root/.claude/skills/claude-implementation-delivery/SKILL.md")" != "../../../.shared/skills/implementation-delivery/SKILL.md" ]]; then
		echo "error: claude implementation-delivery SKILL.md symlink is invalid" >&2
		return 1
	fi
	if [[ "$(readlink "$root/.claude/skills/claude-decision-review/SKILL.md")" != "../../../.shared/skills/decision-review/SKILL.md" ]]; then
		echo "error: claude decision-review SKILL.md symlink is invalid" >&2
		return 1
	fi

	if command -v ruby >/dev/null 2>&1; then
		(
			cd "$root"
			ruby -e 'require "yaml"; {"codex-project-planning"=>"project-planning-workflow","codex-implementation-delivery"=>"implementation-delivery-workflow","codex-decision-review"=>"decision-review-workflow"}.each { |dir, skill| p = ".agents/skills/#{dir}/agents/openai.yaml"; y = YAML.load_file(p); abort("#{p}: unexpected keys") unless y.keys == ["interface"]; i = y["interface"] || {}; short = i["short_description"].to_s; prompt = i["default_prompt"].to_s; abort("#{p}: missing display_name") if i["display_name"].to_s.empty?; abort("#{p}: short_description length") unless (25..64).cover?(short.length); abort("#{p}: default_prompt missing $#{skill}") unless prompt.include?("$#{skill}") }'
		)
	fi
}

stage_source() {
	local stage="$1"

	for rel in "${managed_roots[@]}"; do
		mkdir -p "$stage/$(dirname "$rel")" || return $?
		cp -R -P "$template_root/$rel" "$stage/$rel" || return $?
	done

	validate_source "$stage" || return $?
}

copy_tree_overlay() {
	local source="$1"
	local destination="$2"
	local source_path
	local rel_path
	local target_path

	while IFS= read -r -d '' source_path; do
			if [[ "$source_path" == "$source" ]]; then
				continue
			fi
			rel_path="${source_path#$source/}"
			mkdir -p "$destination/$rel_path" || return $?
		done < <(find "$source" -type d -print0)

		while IFS= read -r -d '' source_path; do
			rel_path="${source_path#$source/}"
			target_path="$destination/$rel_path"
			mkdir -p "$(dirname "$target_path")" || return $?
			if [[ -d "$target_path" && ! -L "$target_path" ]]; then
				echo "error: target directory blocks managed skill file: $target_path" >&2
				return 1
			fi
			rm -f "$target_path" || return $?
			cp -P "$source_path" "$target_path" || return $?
		done < <(find "$source" \( -type f -o -type l \) -print0)
	}

path_has_drift() {
	local source="$1"
	local destination="$2"
	local source_path
	local rel_path
	local target_path

	while IFS= read -r -d '' source_path; do
		if [[ "$source_path" == "$source" ]]; then
			continue
		fi
		rel_path="${source_path#$source/}"
		target_path="$destination/$rel_path"

		if [[ -L "$source_path" ]]; then
			if [[ ! -L "$target_path" || "$(readlink "$source_path")" != "$(readlink "$target_path")" ]]; then
				return 0
			fi
		elif [[ -f "$source_path" ]]; then
			if [[ ! -f "$target_path" ]] || ! cmp -s "$source_path" "$target_path"; then
				return 0
			fi
		fi
	done < <(find "$source" \( -type f -o -type l \) -print0)

	while IFS= read -r -d '' source_path; do
		if [[ "$source_path" == "$source" ]]; then
			continue
		fi
		rel_path="${source_path#$source/}"
		target_path="$destination/$rel_path"
		if [[ ! -d "$target_path" ]]; then
			return 0
		fi
	done < <(find "$source" -type d -print0)

	return 1
}

validate_overlay_target() {
	local source="$1"
	local destination="$2"
	local source_path
	local rel_path
	local target_path

	if [[ -L "$destination" || ( -e "$destination" && ! -d "$destination" ) ]]; then
		echo "error: target path blocks managed skill directory: $destination" >&2
		return 1
	fi

	while IFS= read -r -d '' source_path; do
		if [[ "$source_path" == "$source" ]]; then
			continue
		fi
		rel_path="${source_path#$source/}"
		target_path="$destination/$rel_path"
		if [[ -L "$target_path" || ( -e "$target_path" && ! -d "$target_path" ) ]]; then
			echo "error: target path blocks managed skill directory: $target_path" >&2
			return 1
		fi
	done < <(find "$source" -type d -print0)

	while IFS= read -r -d '' source_path; do
		rel_path="${source_path#$source/}"
		target_path="$destination/$rel_path"
		if [[ -d "$target_path" && ! -L "$target_path" ]]; then
			echo "error: target directory blocks managed skill file: $target_path" >&2
			return 1
		fi
	done < <(find "$source" \( -type f -o -type l \) -print0)
}

update_project() {
	local requested_project="$1"
	local project
	local stage
	local drift=false
	local doctor_status=0
	local rel

	if [[ ! -d "$requested_project" ]]; then
		echo "error: project directory does not exist: $requested_project" >&2
		return 2
	fi

	project="$(cd "$requested_project" && pwd)"
	if [[ "$project" == "$template_root" ]]; then
		echo "error: refusing to update template source itself: $project" >&2
		return 2
	fi

	if [[ ! -f "$project/.belay/config.toml" && "$allow_initialize" != true ]]; then
		echo "error: not an initialized belay project: $project" >&2
		echo "hint: pass --initialize to initialize it explicitly" >&2
		return 2
	fi

	stage="$(mktemp -d)"
	cleanup_paths+=("$stage")
	stage_source "$stage" || return $?

	echo "Checking $project"
	if (cd "$project" && "$belay_bin" doctor); then
		doctor_status=0
	else
		doctor_status=$?
		drift=true
	fi

	for rel in "${managed_roots[@]}"; do
		if path_has_drift "$stage/$rel" "$project/$rel"; then
			echo "drift: $rel"
			drift=true
		fi
	done

	if [[ "$check_only" == true ]]; then
		if [[ "$drift" == true ]]; then
			echo "drift detected in $project"
			return 1
		fi
		echo "no drift in $project"
		return 0
	fi

	for rel in "${managed_roots[@]}"; do
		validate_overlay_target "$stage/$rel" "$project/$rel" || return 2
	done

	echo "Planned updates for $project:"
	echo "  belay init --update-agents --install-skill codex --install-skill claude"
	for rel in "${managed_roots[@]}"; do
		echo "  sync $rel"
	done
	echo "  belay doctor"

	(cd "$project" && "$belay_bin" init --update-agents --install-skill codex --install-skill claude) || return $?

	for rel in "${managed_roots[@]}"; do
		copy_tree_overlay "$stage/$rel" "$project/$rel" || return $?
	done

	(cd "$project" && "$belay_bin" doctor) || return $?
	if [[ "$doctor_status" -ne 0 ]]; then
		echo "note: initial doctor failed before update; final doctor passed" >&2
	fi
}

validate_source "$template_root"

overall_status=0
for project in "${projects[@]}"; do
	if update_project "$project"; then
		status=0
	else
		status=$?
		if [[ "$status" -gt "$overall_status" ]]; then
			overall_status="$status"
		fi
	fi
done

exit "$overall_status"
