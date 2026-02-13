// Package depremind reminds to run install after dependency file edits.
package depremind

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

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
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Collect file paths from tool input
	var paths []string
	if data.ToolInput.FilePath != "" {
		paths = append(paths, data.ToolInput.FilePath)
	}
	for _, edit := range data.ToolInput.Edits {
		if edit.FilePath != "" {
			paths = append(paths, edit.FilePath)
		}
	}

	// Check if any edited file is a dependency file
	for _, p := range paths {
		base := filepath.Base(p)
		if installCmd, ok := depFiles[base]; ok {
			fmt.Println(protocol.ContinueWithMessage(
				fmt.Sprintf("📦 %s 已修改 — 記得執行: `%s`", base, installCmd)))
			return
		}
	}

	fmt.Println(protocol.ContinueResponse())
}
