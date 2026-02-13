// Package autostage implements a PostToolUse hook that auto-stages files
// after Write/Edit/MultiEdit. This keeps the git index in sync with Claude's
// edits so the stop-hook formatter (which uses `git diff --name-only`)
// correctly picks up all changed files.
package autostage

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
)

// writeTools are the tool names that produce file changes worth staging.
var writeTools = map[string]bool{
	"Write":     true,
	"Edit":      true,
	"MultiEdit": true,
}

// Run executes the auto-stage hook.
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

	if !writeTools[data.ToolName] {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	cwd := data.CWD

	// Collect file paths from the tool input
	var paths []string
	if data.ToolInput.FilePath != "" {
		paths = append(paths, data.ToolInput.FilePath)
	}
	for _, edit := range data.ToolInput.Edits {
		if edit.FilePath != "" {
			paths = append(paths, edit.FilePath)
		}
	}

	// Stage each file (only if inside a git repo)
	for _, p := range paths {
		if _, err := os.Stat(p); err != nil {
			continue
		}
		dir := cwd
		if dir == "" {
			dir = filepath.Dir(p)
		}
		cmd := exec.Command("git", "add", "--", p)
		cmd.Dir = dir
		_ = cmd.Run() // silently ignore errors (e.g. not a git repo)
	}

	fmt.Println(protocol.ContinueResponse())
}
