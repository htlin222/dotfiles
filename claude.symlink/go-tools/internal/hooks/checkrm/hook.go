// Package checkrm implements the check-rm hook to block rm commands.
package checkrm

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// Run executes the check-rm hook.
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

	command := data.ToolInput.Command
	if command == "" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Check if command uses rm
	if patterns.IsRmCommand(command) {
		reason := fmt.Sprintf("%s%s 請使用 %srip%s 代替 %srm%s",
			ansi.BrightRed, ansi.IconLock,
			ansi.BrightCyan, ansi.BrightRed,
			ansi.BrightYellow, ansi.Reset,
		)
		fmt.Println(protocol.BlockResponse(reason))
		return
	}

	fmt.Println(protocol.ContinueResponse())
}
