# Claude Code Go Tools Makefile

.PHONY: all build install test clean fmt lint

# Binary names
HOOKS_BIN = claude-hooks
STATUSLINE_BIN = claude-statusline

# Install directory
INSTALL_DIR = $(HOME)/.local/bin

# Build flags
LDFLAGS = -s -w
GCFLAGS =

all: build

# Build both binaries
build:
	@echo "Building $(HOOKS_BIN)..."
	@go build -ldflags "$(LDFLAGS)" -o $(HOOKS_BIN) ./cmd/claude-hooks
	@echo "Building $(STATUSLINE_BIN)..."
	@go build -ldflags "$(LDFLAGS)" -o $(STATUSLINE_BIN) ./cmd/claude-statusline
	@echo "Build complete!"

# Build with debug info
build-debug:
	@go build -gcflags "all=-N -l" -o $(HOOKS_BIN) ./cmd/claude-hooks
	@go build -gcflags "all=-N -l" -o $(STATUSLINE_BIN) ./cmd/claude-statusline

# Install to ~/.local/bin
install: build
	@echo "Installing to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(HOOKS_BIN) $(INSTALL_DIR)/
	@cp $(STATUSLINE_BIN) $(INSTALL_DIR)/
	@echo "Installed!"
	@echo ""
	@echo "Make sure $(INSTALL_DIR) is in your PATH"
	@echo "Update ~/.claude/settings.json:"
	@echo '  "hooks": {'
	@echo '    "UserPromptSubmit": [{"matcher": ".*", "hooks": ["command:$(HOOKS_BIN) user-prompt"]}],'
	@echo '    "PreToolUse": ['
	@echo '      {"matcher": "^Bash$$", "hooks": ["command:$(HOOKS_BIN) check-rm"]},'
	@echo '      {"matcher": "^(Read|Write|Edit|MultiEdit)$$", "hooks": ["command:$(HOOKS_BIN) file-guard"]}'
	@echo '    ],'
	@echo '    "PostToolUse": [{"matcher": "^(Write|Edit|MultiEdit|Bash)$$", "hooks": ["command:$(HOOKS_BIN) post-tool-use"]}],'
	@echo '    "Stop": [{"matcher": ".*", "hooks": ["command:$(HOOKS_BIN) stop"]}]'
	@echo '  },'
	@echo '  "statusline": {"enabled": true, "command": "$(STATUSLINE_BIN)"}'

# Run tests
test:
	@go test -v ./...

# Format code
fmt:
	@go fmt ./...

# Lint code
lint:
	@golangci-lint run ./... 2>/dev/null || go vet ./...

# Clean build artifacts
clean:
	@rm -f $(HOOKS_BIN) $(STATUSLINE_BIN)
	@echo "Cleaned!"

# Uninstall
uninstall:
	@rm -f $(INSTALL_DIR)/$(HOOKS_BIN)
	@rm -f $(INSTALL_DIR)/$(STATUSLINE_BIN)
	@echo "Uninstalled!"

# Show help
help:
	@echo "Available targets:"
	@echo "  build       - Build both binaries"
	@echo "  build-debug - Build with debug info"
	@echo "  install     - Build and install to ~/.local/bin"
	@echo "  test        - Run tests"
	@echo "  fmt         - Format code"
	@echo "  lint        - Lint code"
	@echo "  clean       - Remove built binaries"
	@echo "  uninstall   - Remove installed binaries"
	@echo "  help        - Show this help"

# Test individual hooks
test-user-prompt:
	@echo '{"prompt":"test prompt","cwd":"/tmp","session_id":"test"}' | ./$(HOOKS_BIN) user-prompt

test-check-rm:
	@echo '{"tool_input":{"command":"rm -rf /"}}' | ./$(HOOKS_BIN) check-rm

test-file-guard:
	@echo '{"tool_name":"Read","tool_input":{"file_path":".env"}}' | ./$(HOOKS_BIN) file-guard

test-stop:
	@echo '{"cwd":"/tmp","session_id":"test"}' | ./$(HOOKS_BIN) stop
