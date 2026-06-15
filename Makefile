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
		-path './.belay/agent/*.md' -o \
		-path './.belay/agent/**/*.md' -o \
		-name 'AGENTS.md' -o \
		-name 'DESIGN.md' \
	\) | sort)

.PHONY: help bootstrap github-setup check belay-check docs-check lint-md typos-check

help:
	@printf '%s\n' \
		'Available targets:' \
		'  make bootstrap    Initialize or refresh belay agent integration' \
		'  make github-setup Create or update the repository labels' \
		'  make check        Run belay and documentation checks' \
		'  make belay-check  Run belay repository health checks' \
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
	belay init --update-agents --install-skill codex

github-setup:
	./scripts/setup-github-labels.sh

check: belay-check docs-check

belay-check:
	@command -v belay >/dev/null 2>&1 || { \
		echo 'belay is required. See SETUP.md for installation.'; \
		exit 1; \
	}
	belay doctor

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
