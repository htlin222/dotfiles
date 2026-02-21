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

	// Only hint about @LAST after /clear, not on fresh startup
	if data.Source != "clear" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	if snapshot.IsAvailable(data.CWD) {
		fmt.Println(protocol.ContinueWithMessage("💡 前次對話快照可用，輸入 @LAST 載入前次上下文"))
		return
	}

	fmt.Println(protocol.ContinueResponse())
}
