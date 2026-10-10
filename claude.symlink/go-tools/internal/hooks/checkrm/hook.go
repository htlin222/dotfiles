// Package checkrm implements the check-rm hook to block rm commands.
package checkrm

import (
	"encoding/json"
	"fmt"
	"io"
	"os"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// denyReason is shown to the model when an rm invocation is blocked.
const denyReason = "請使用 rip 代替 rm（rm is blocked; use `rip <path>` to move files to the graveyard）"

// Run executes the check-rm hook. Allow = exit 0 with no output.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	if data.ToolInput.Command != "" && patterns.IsRmCommand(data.ToolInput.Command) {
		fmt.Println(protocol.PreToolUseDeny(denyReason))
	}
}
