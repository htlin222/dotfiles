# herdr plugin sync — declarative plugin management across machines
#
#   plugins.list   source of truth (tracked in git): owner/repo + pinned commit
#   plugins.json   herdr-generated machine state (gitignored, rebuilt on install)
#
# Fresh machine:  git pull → cd config.symlink/herdr → make install
# After adding a plugin on any machine:  make freeze → commit plugins.list

SHELL   := bash
.SHELLFLAGS := -euo pipefail -c

LIST     := plugins.list
MANIFEST := plugins.json

.DEFAULT_GOAL := help

.PHONY: help check list install freeze

help: ## Show this help
	@echo 'herdr plugin sync — targets:'
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) \
	  | sed -E 's/^([a-z]+):.*## /  \1\t/' | expand -t14

check: ## Detect env, verify herdr + jq + source list are present
	@echo "→ platform: $$(uname -s)"
	@command -v herdr >/dev/null || { echo "✗ herdr not on PATH — install herdr first"; exit 1; }
	@command -v jq    >/dev/null || { echo "✗ jq not on PATH — brew/apt install jq"; exit 1; }
	@test -f "$(LIST)"          || { echo "✗ $(LIST) missing (run from config.symlink/herdr)"; exit 1; }
	@echo "✓ herdr=$$(command -v herdr)  jq ok  $(LIST) ok"

list: check ## Show the plugins declared in plugins.list
	@grep -vE '^\s*(#|$$)' "$(LIST)" | while read -r repo ref; do \
	    echo "  $$repo  @ $${ref:0:8}"; \
	  done

install: check ## Install every plugin from plugins.list at its pinned commit
	@grep -vE '^\s*(#|$$)' "$(LIST)" | while read -r repo ref; do \
	    echo "→ $$repo @ $${ref:0:8}"; \
	    herdr plugin install "$$repo" --ref "$$ref" --yes; \
	  done
	@echo "✓ all plugins installed"

freeze: check ## Regenerate plugins.list from the live plugins.json (sorted)
	@test -f "$(MANIFEST)" || { echo "✗ $(MANIFEST) not found — install some plugins first"; exit 1; }
	@{ echo "# herdr plugin manifest — source of truth (tracked in git)"; \
	   echo "# format:  owner/repo[/subdir]  <commit-ref>"; \
	   echo "# regenerate from a live install with:  make freeze"; \
	   jq -r '.[] | select(.enabled) | "\(.source.owner)/\(.source.repo) \(.source.resolved_commit)"' "$(MANIFEST)" \
	     | LC_ALL=C sort; } > "$(LIST)"
	@echo "✓ wrote $(LIST):"; grep -vE '^\s*#' "$(LIST)" | sed 's/^/  /'
