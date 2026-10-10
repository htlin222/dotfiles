// Package depremind reminds to run install after dependency file edits.
package depremind

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/htlin/claude-tools/internal/protocol"
)

// depFiles maps dependency filenames to their install commands.
var depFiles = map[string]string{
	"package.json":      "pnpm install",
	"go.mod":            "go mod tidy",
	"Cargo.toml":        "cargo build",
	"pyproject.toml":    "uv sync",
	"requirements.txt":  "uv pip install -r requirements.txt",
	"Gemfile":           "bundle install",
	"pubspec.yaml":      "flutter pub get",
	"DESCRIPTION":       "devtools::install_deps()",
}

// Run executes the dep-remind hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil || data.ToolInput.FilePath == "" {
		return
	}

	base := filepath.Base(data.ToolInput.FilePath)
	if installCmd, ok := depFiles[base]; ok {
		fmt.Println(protocol.PostToolUseContext(
			fmt.Sprintf("%s was modified — run `%s` before relying on the new dependencies.", base, installCmd)))
	}
}
