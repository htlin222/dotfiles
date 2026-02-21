// Package sessionhint implements the SessionStart hint hook.
// It resets per-session state and checks for available @LAST snapshots.
package sessionhint

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

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
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Reset state on new session or clear (prevents zombie accumulation)
	// Preserve the main session ID so delegate-edits can detect the main session
	if data.Source == "startup" || data.Source == "clear" {
		state.Save(&state.State{
			MainSessionID: data.SessionID,
		})
	}

	// Build startup messages
	var msgs []string

	// Qing dynasty court mode
	if strings.EqualFold(os.Getenv("QING"), "true") {
		msgs = append(msgs, "👑 我在大清當皇帝")
	}

	// Delegation reminder
	msgs = append(msgs, "🔄 Delegation active: delegate all source code edits (Write/Edit) to Task subagents. Direct edits allowed only for: *.md, settings.json, Makefile, .gitignore, go-tools/**")

	// @LAST hint after /clear
	if data.Source == "clear" && snapshot.IsAvailable(data.CWD) {
		msgs = append(msgs, "💡 前次對話快照可用，輸入 @LAST 載入前次上下文")
	}

	fmt.Println(protocol.ContinueWithMessage(strings.Join(msgs, "\n")))
}
