// Package sessionhint implements the SessionStart hint hook.
// It checks for available @LAST snapshots and notifies the user.
package sessionhint

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
)

// Run executes the session-hint hook.
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

	// Only hint on startup or clear
	if data.Source != "" && data.Source != "startup" && data.Source != "clear" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	if snapshot.IsAvailable() {
		fmt.Println(protocol.ContinueWithMessage("💡 前次對話快照可用，輸入 @LAST 載入前次上下文"))
		return
	}

	fmt.Println(protocol.ContinueResponse())
}
