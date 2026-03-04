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

	// Record session start timestamp for shell access
	ts := []byte(fmt.Sprintf("%d\n", time.Now().Unix()))
	os.WriteFile(config.SessionStartTimeFile(), ts, 0644)
	if pane := os.Getenv("TMUX_PANE"); pane != "" {
		os.WriteFile(config.SessionStartTimeFileForPane(pane), ts, 0644)
	}

	// Build startup messages
	var msgs []string

	// Qing dynasty court mode
	if strings.EqualFold(os.Getenv("QING"), "true") {
		msgs = append(msgs, "👑 我在大清當皇帝")
	}

	// Delegation reminder (adapts to FORCE_DELEGATION env)
	if strings.EqualFold(os.Getenv("FORCE_DELEGATION"), "true") {
		msgs = append(msgs, "🔄 Strict delegation: ALL source code edits must use Task subagents. Direct edits allowed only for: *.md, settings.json, Makefile, .gitignore, go-tools/**")
	} else {
		msgs = append(msgs, "🔄 Smart delegation: small edits (Edit, ≤3 MultiEdits, ≤100-line Write) OK directly. Large edits → use Task subagents.")
	}

	// @LAST hint after /clear
	if data.Source == "clear" && snapshot.IsAvailable(data.CWD) {
		msgs = append(msgs, "💡 前次對話快照可用，輸入 @LAST 載入前次上下文")
	}

	fmt.Println(protocol.ContinueWithMessage(strings.Join(msgs, "\n")))
}
