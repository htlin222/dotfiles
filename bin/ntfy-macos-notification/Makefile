.PHONY: install uninstall start stop restart status logs help

LABEL       := sh.ntfy.client
PLIST_SRC   := sh.ntfy.client.plist
CONFIG_SRC  := client.yml
PLIST_DEST  := $(HOME)/Library/LaunchAgents/$(LABEL).plist
CONFIG_DIR  := $(HOME)/Library/Application Support/ntfy
CONFIG_DEST := $(CONFIG_DIR)/client.yml
NTFY_BIN    := $(shell command -v ntfy 2>/dev/null)
LOG_FILE    := /tmp/ntfy.log
ERR_FILE    := /tmp/ntfy.err

# --- Main targets ---

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: _check-brew _install-ntfy _install-config _install-plist _load ## Install ntfy client service
	@echo "✓ ntfy macOS notification service installed and running"
	@echo "  topic: lizard"
	@echo "  config: $(CONFIG_DEST)"
	@echo "  plist:  $(PLIST_DEST)"
	@echo "  logs:   $(LOG_FILE)"

uninstall: _unload ## Remove ntfy client service
	@rm -f "$(PLIST_DEST)"
	@echo "✓ plist removed"
	@echo "  note: config kept at $(CONFIG_DEST)"
	@echo "  note: ntfy binary kept (brew uninstall ntfy to remove)"

start: ## Start the service
	launchctl start $(LABEL)
	@echo "✓ $(LABEL) started"

stop: ## Stop the service
	launchctl stop $(LABEL)
	@echo "✓ $(LABEL) stopped"

restart: stop start ## Restart the service

status: ## Show service status
	@launchctl list $(LABEL) 2>/dev/null && echo "✓ running" || echo "✗ not running"

logs: ## Tail the log file
	@tail -f $(LOG_FILE)

# --- Internal targets ---

_check-brew:
	@command -v brew >/dev/null 2>&1 || { echo "✗ Homebrew required: https://brew.sh"; exit 1; }

_install-ntfy:
	@if ! command -v ntfy >/dev/null 2>&1; then \
		echo "→ Installing ntfy via Homebrew..."; \
		brew install ntfy; \
	else \
		echo "✓ ntfy already installed: $$(command -v ntfy)"; \
	fi

_install-config:
	@mkdir -p "$(CONFIG_DIR)"
	@if [ -f "$(CONFIG_DEST)" ]; then \
		echo "✓ config exists: $(CONFIG_DEST) (skipped)"; \
	else \
		cp $(CONFIG_SRC) "$(CONFIG_DEST)"; \
		echo "✓ config installed: $(CONFIG_DEST)"; \
	fi

_install-plist:
	@NTFY=$$(command -v ntfy); \
	sed "s|__NTFY_BIN__|$$NTFY|g" $(PLIST_SRC) > "$(PLIST_DEST)"; \
	echo "✓ plist installed: $(PLIST_DEST) (ntfy=$$NTFY)"

_load:
	@launchctl unload "$(PLIST_DEST)" 2>/dev/null || true
	@launchctl load "$(PLIST_DEST)"
	@echo "✓ service loaded"

_unload:
	@launchctl unload "$(PLIST_DEST)" 2>/dev/null || true
	@echo "✓ service unloaded"
