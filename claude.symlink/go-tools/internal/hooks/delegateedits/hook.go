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
)

// maxWriteLines: a Write with more lines than this is "large" → delegate.
const maxWriteLines = 500

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

// Run executes the delegate-edits PreToolUse hook. Allow = exit 0, no output.
// Set FORCE_DELEGATION=true to block ALL direct source-code edits in main session.
// Default (unset or false): only large Writes are blocked.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	if reason := decide(&data, strings.EqualFold(os.Getenv("FORCE_DELEGATION"), "true")); reason != "" {
		fmt.Println(protocol.PreToolUseDeny(reason))
	}
}

// decide returns a deny reason, or "" to allow.
func decide(data *protocol.HookInput, forceMode bool) string {
	// Only act on write-type tools
	if data.ToolName != "Write" && data.ToolName != "Edit" {
		return ""
	}

	// Subagent tool calls carry agent_id; the main session's do not.
	if data.AgentID != "" {
		return ""
	}

	filePath := data.ToolInput.FilePath
	if filePath == "" || isAllowed(filePath) {
		return ""
	}

	if forceMode {
		return fmt.Sprintf(
			"DELEGATE (FORCE_DELEGATION=true): use a subagent (Agent/Task tool) to modify source code.\n\n"+
				"  Agent → \"Edit %s: [describe the change]\"\n\n"+
				"Unset FORCE_DELEGATION to allow small direct edits.",
			filepath.Base(filePath),
		)
	}

	// Default mode: Edit (single replacement) is always small → allow.
	if data.ToolName == "Edit" {
		return ""
	}

	// Write: allow if content is small
	if lines := strings.Count(data.ToolInput.Content, "\n") + 1; lines <= maxWriteLines {
		return ""
	}

	return fmt.Sprintf(
		"Large Write detected — use a subagent (Agent/Task tool) to preserve the main context window.\n\n"+
			"  Agent → \"Write %s: [describe the change]\"\n\n"+
			"Small edits (any Edit, ≤%d-line Write) are allowed directly.",
		filepath.Base(filePath),
		maxWriteLines,
	)
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
