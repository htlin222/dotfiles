// Package sessionhint implements the SessionStart hint hook.
// It resets per-session state and checks for available @LAST snapshots.
package sessionhint

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/hooks/busy"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
	"github.com/htlin/claude-tools/internal/state"
)

// Run executes the session-hint hook.
func Run() {
	if pane := busy.GetTmuxPane(); pane != "" {
		busy.SetIdle(pane)
	}
	busy.CleanupStale()

	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	// Reset per-session state on new session or clear (prevents zombie accumulation)
	if data.Source == "startup" || data.Source == "clear" {
		state.Save(&state.State{})
	}

	// Record session start timestamp for shell access
	ts := []byte(fmt.Sprintf("%d\n", time.Now().Unix()))
	os.WriteFile(config.SessionStartTimeFile(), ts, 0644)
	if pane := os.Getenv("TMUX_PANE"); pane != "" {
		os.WriteFile(config.SessionStartTimeFileForPane(pane), ts, 0644)
	}

	if msg := buildMessage(data.Source, os.Getenv("QING"), snapshot.IsAvailable(data.CWD)); msg != "" {
		fmt.Println(protocol.SystemMessage(msg))
	}
}

// buildMessage returns the user-facing (systemMessage) startup notice,
// or "" when there is nothing to say.
func buildMessage(source, qing string, snapshotAvailable bool) string {
	var msgs []string

	// Qing dynasty court mode
	if strings.EqualFold(qing, "true") {
		msgs = append(msgs, "👑 我在大清當皇帝")
	}

	// @LAST hint after /clear
	if source == "clear" && snapshotAvailable {
		msgs = append(msgs, "💡 前次對話快照可用，輸入 @LAST 載入前次上下文")
	}

	return strings.Join(msgs, "\n")
}
