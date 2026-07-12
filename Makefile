DOC_FILES := $(shell find . \
	-type f \
	\( \
		-name 'README.md' -o \
		-name 'SETUP.md' -o \
		-name 'TRACE_GUIDE.md' -o \
		-path './.github/*.md' -o \
		-path './.github/**/*.md' -o \
		-path './.shared/skills/*/SKILL.md' -o \
		-path './.agents/skills/belay-trace/SKILL.md' -o \
		-path './.claude/skills/belay-trace/SKILL.md' -o \
		-path './.belay/agent/*.md' -o \
		-path './.belay/agent/**/*.md' -o \
		-name 'AGENTS.md' -o \
		-name 'DESIGN.md' \
	\) | sort)

.PHONY: help bootstrap github-setup check belay-check skill-check github-config-check docs-check lint-md typos-check

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make bootstrap    Initialize or refresh belay agent integration' \
		'  make github-setup Create or update GitHub labels and rulesets' \
		'  make check        Run belay and documentation checks' \
		'  make belay-check  Run belay repository health checks' \
		'  make skill-check  Validate workflow skill wiring' \
		'  make github-config-check Validate GitHub setup files' \
		'  make docs-check   Run all documentation checks' \
		'  make lint-md      Run markdownlint-cli2 on documentation files' \
		'  make typos-check  Run typos on documentation files' \
		'' \
		'Files:' \
		$(foreach file,$(DOC_FILES),'  $(file)')

bootstrap:
	@command -v belay >/dev/null 2>&1 || { \
		echo 'belay is required. See SETUP.md for installation.'; \
		exit 1; \
	}
	belay init --update-agents --install-skill codex --install-skill claude

github-setup:
	./scripts/setup-github.sh

check: belay-check skill-check github-config-check docs-check

belay-check:
	@command -v belay >/dev/null 2>&1 || { \
		echo 'belay is required. See SETUP.md for installation.'; \
		exit 1; \
	}
	belay doctor

skill-check:
	test "$$(readlink .agents/skills/codex-project-planning/SKILL.md)" = "../../../.shared/skills/project-planning/SKILL.md"
	test "$$(readlink .agents/skills/codex-implementation-delivery/SKILL.md)" = "../../../.shared/skills/implementation-delivery/SKILL.md"
	test "$$(readlink .agents/skills/codex-decision-review/SKILL.md)" = "../../../.shared/skills/decision-review/SKILL.md"
	test "$$(readlink .claude/skills/claude-project-planning/SKILL.md)" = "../../../.shared/skills/project-planning/SKILL.md"
	test "$$(readlink .claude/skills/claude-implementation-delivery/SKILL.md)" = "../../../.shared/skills/implementation-delivery/SKILL.md"
	test "$$(readlink .claude/skills/claude-decision-review/SKILL.md)" = "../../../.shared/skills/decision-review/SKILL.md"
	cmp -s .belay/agent/codex/SKILL.md .agents/skills/belay-trace/SKILL.md
	cmp -s .belay/agent/claude/SKILL.md .claude/skills/belay-trace/SKILL.md
	ruby -e 'require "yaml"; {"codex-project-planning"=>"project-planning-workflow","codex-implementation-delivery"=>"implementation-delivery-workflow","codex-decision-review"=>"decision-review-workflow"}.each { |dir, skill| p = ".agents/skills/#{dir}/agents/openai.yaml"; y = YAML.load_file(p); allowed = ["interface"]; extra = y.keys - allowed; abort("#{p}: unexpected top-level keys #{extra.join(", ")}") unless extra.empty?; i = y["interface"] || {}; display = i["display_name"].to_s.strip; short = i["short_description"].to_s.strip; prompt = i["default_prompt"].to_s.strip; abort("#{p}: missing interface.display_name") if display.empty?; abort("#{p}: short_description length #{short.length} outside 25..64") unless (25..64).cover?(short.length); abort("#{p}: missing interface.default_prompt") if prompt.empty?; abort("#{p}: default_prompt must mention $$#{skill}") unless prompt.include?("$$#{skill}") }'

github-config-check:
	/bin/bash -n scripts/setup-github.sh
	/bin/bash -n scripts/test-setup-github.sh
	node -e 'const fs = require("fs"); for (const file of process.argv.slice(1)) JSON.parse(fs.readFileSync(file, "utf8"));' \
		.github/rulesets/protect-main.json \
		.github/rulesets/require-reviewed-prs.json
	./scripts/test-setup-github.sh

docs-check: lint-md typos-check

lint-md:
	@command -v markdownlint-cli2 >/dev/null 2>&1 || { \
		echo 'markdownlint-cli2 is required. Install it with: npm install -g markdownlint-cli2'; \
		exit 1; \
	}
	markdownlint-cli2 --config .github/.markdownlint.json $(DOC_FILES)

typos-check:
	@command -v typos >/dev/null 2>&1 || { \
		echo 'typos is required. Install it from https://github.com/crate-ci/typos'; \
		exit 1; \
	}
	typos --config .github/.typos.toml $(DOC_FILES)
