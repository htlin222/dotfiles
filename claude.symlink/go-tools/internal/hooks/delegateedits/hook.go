// Package delegateedits suggests delegation to Task subagents for large edits
// in the main session, while allowing small targeted changes directly.
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

// Thresholds for "large" edits that should be delegated.
const (
	maxMultiEdits = 3   // MultiEdit with more than this many edits → delegate
	maxWriteLines = 100 // Write with more than this many lines → delegate
)

// allowedExtensions are file extensions always allowed directly.
var allowedExtensions = map[string]bool{
	".md": true,
}

// allowedBasenames are exact filenames always allowed directly.
var allowedBasenames = map[string]bool{
	"CLAUDE.md":           true,
	"Makefile":            true,
	".gitignore":          true,
	"settings.json":       true,
	"settings.local.json": true,
}

// allowedPathContains are path fragments that always permit direct edits.
var allowedPathContains = []string{
	"/.claude/",
	"/claude.symlink/go-tools/",
	"/.claude/plans/",
}

// Run executes the delegate-edits PreToolUse hook.
// Set FORCE_DELEGATION=true to block ALL direct source-code edits in main session.
// Default (unset or false): only large edits are blocked.
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
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// If this is NOT the main session (subagent), always allow
	if data.SessionID != st.MainSessionID {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// --- Main session: check allowlist first ---
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

	if len(filePaths) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Allowlisted files are always permitted
	allAllowed := true
	for _, fp := range filePaths {
		if !isAllowed(fp) {
			allAllowed = false
			break
		}
	}
	if allAllowed {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// --- FORCE_DELEGATION mode: block everything except allowlisted ---
	forceMode := strings.EqualFold(os.Getenv("FORCE_DELEGATION"), "true")

	if forceMode {
		msg := fmt.Sprintf(
			"🔄 DELEGATE (FORCE_DELEGATION=true): Use a Task agent to modify source code.\n\n"+
				"  Task → \"Edit %s: [describe the change]\"\n\n"+
				"Unset FORCE_DELEGATION to allow small direct edits.",
			filepath.Base(filePaths[0]),
		)
		fmt.Println(protocol.BlockResponse(msg))
		return
	}

	// --- Default mode: size-based — small edits pass, large edits blocked ---

	// Edit (single replacement in one file) is always small → allow
	if data.ToolName == "Edit" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// MultiEdit: allow if few edits
	if data.ToolName == "MultiEdit" && len(data.ToolInput.Edits) <= maxMultiEdits {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Write: allow if content is small
	if data.ToolName == "Write" {
		lines := strings.Count(data.ToolInput.Content, "\n") + 1
		if lines <= maxWriteLines {
			fmt.Println(protocol.ContinueResponse())
			return
		}
	}

	// Large edit → suggest delegation
	msg := fmt.Sprintf(
		"🔄 Large edit detected — consider using a Task agent to preserve context window.\n\n"+
			"  Task → \"Edit %s: [describe the change]\"\n\n"+
			"Small edits (Edit, ≤%d MultiEdits, ≤%d-line Write) are allowed directly.\n"+
			"Set FORCE_DELEGATION=true to block all direct source edits.",
		filepath.Base(filePaths[0]),
		maxMultiEdits,
		maxWriteLines,
	)
	fmt.Println(protocol.BlockResponse(msg))
}

// isAllowed checks if a file path is in the allowlist for direct main-session edits.
func isAllowed(fp string) bool {
	base := filepath.Base(fp)
	ext := filepath.Ext(fp)

	if allowedExtensions[ext] {
		return true
	}
	if allowedBasenames[base] {
		return true
	}
	for _, fragment := range allowedPathContains {
		if strings.Contains(fp, fragment) {
			return true
		}
	}
	return false
}
