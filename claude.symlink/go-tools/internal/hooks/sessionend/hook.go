// Package sessionend implements the SessionEnd hook.
// It persists the session ID to /tmp/claude_last_session_id for shell resume.
package sessionend

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
)

// Run executes the session-end hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	if data.SessionID == "" {
		return
	}

	// Always write to the shared fallback file
	if err := os.WriteFile(config.LastSessionIDFile(), []byte(data.SessionID+"\n"), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "%s%s session-end: %v%s\n", ansi.BrightRed, ansi.IconWarning, err, ansi.Reset)
		return
	}

	// Also write to pane-specific file if inside tmux
	if pane := os.Getenv("TMUX_PANE"); pane != "" {
		if err := os.WriteFile(config.LastSessionIDFileForPane(pane), []byte(data.SessionID+"\n"), 0644); err != nil {
			fmt.Fprintf(os.Stderr, "%s%s session-end: pane file: %v%s\n", ansi.BrightRed, ansi.IconWarning, err, ansi.Reset)
		}
	}

	fmt.Fprintf(os.Stderr, "%s%s Session ID saved for resume%s\n", ansi.BrightGreen, ansi.IconCheck, ansi.Reset)
}
