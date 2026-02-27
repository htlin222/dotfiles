// Package sessionend implements the SessionEnd hook.
// It persists the session ID to ~/.claude/last_session_id for shell resume.
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

	if err := os.WriteFile(config.LastSessionIDFile(), []byte(data.SessionID+"\n"), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "%s%s session-end: %v%s\n", ansi.BrightRed, ansi.IconWarning, err, ansi.Reset)
		return
	}

	fmt.Fprintf(os.Stderr, "%s%s Session ID saved for resume%s\n", ansi.BrightGreen, ansi.IconCheck, ansi.Reset)
}
