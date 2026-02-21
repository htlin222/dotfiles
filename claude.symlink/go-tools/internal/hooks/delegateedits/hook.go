// Package delegateedits blocks Write/Edit/MultiEdit in the main session,
// encouraging delegation to Task subagents to preserve context window.
package delegateedits

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/state"
)

// allowedExtensions are file extensions the main session may edit directly.
var allowedExtensions = map[string]bool{
	".md": true,
}

// allowedBasenames are exact filenames allowed in any directory.
var allowedBasenames = map[string]bool{
	"CLAUDE.md":            true,
	"Makefile":             true,
	".gitignore":           true,
	"settings.json":        true,
	"settings.local.json":  true,
}

// allowedPathContains are path fragments that permit direct edits.
var allowedPathContains = []string{
	"/.claude/",
	"/claude.symlink/go-tools/",
	"/.claude/plans/",
}

// Run executes the delegate-edits PreToolUse hook.
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

	// Only act on write-type tools
	if data.ToolName != "Write" && data.ToolName != "Edit" && data.ToolName != "MultiEdit" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Load state to get main session ID
	st, err := state.Load()
	if err != nil || st.MainSessionID == "" {
		// No stored session ID — can't determine main session, allow
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// If this is NOT the main session (subagent), allow
	if data.SessionID != st.MainSessionID {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// This IS the main session — check file paths against allowlist
	var filePaths []string
	if data.ToolName == "MultiEdit" {
		for _, edit := range data.ToolInput.Edits {
			if edit.FilePath != "" {
				filePaths = append(filePaths, edit.FilePath)
			}
		}
	} else if data.ToolInput.FilePath != "" {
		filePaths = []string{data.ToolInput.FilePath}
	}

	// If no file paths found, allow (shouldn't happen, but safe default)
	if len(filePaths) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Check each file path against allowlist
	for _, fp := range filePaths {
		if !isAllowed(fp) {
			msg := fmt.Sprintf(
				"🔄 DELEGATE: Use a Task agent to modify source code — keeps this session focused on discussion.\n\n"+
					"  Task → \"Edit %s: [describe the change]\"\n\n"+
					"Allowed direct edits: .md, CLAUDE.md, plans/*, settings.json, Makefile, .gitignore, go-tools/**",
				filepath.Base(fp),
			)
			fmt.Println(protocol.BlockResponse(msg))
			return
		}
	}

	fmt.Println(protocol.ContinueResponse())
}

// isAllowed checks if a file path is in the allowlist for direct main-session edits.
func isAllowed(fp string) bool {
	base := filepath.Base(fp)
	ext := filepath.Ext(fp)

	// Check allowed extensions
	if allowedExtensions[ext] {
		return true
	}

	// Check allowed basenames
	if allowedBasenames[base] {
		return true
	}

	// Check allowed path fragments
	for _, fragment := range allowedPathContains {
		if strings.Contains(fp, fragment) {
			return true
		}
	}

	return false
}
