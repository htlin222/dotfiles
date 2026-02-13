// Package largewriteguard warns (not blocks) when Write content is very large.
package largewriteguard

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
)

const warnThreshold = 500 // lines

// Run executes the large-write-guard hook.
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

	content := data.ToolInput.Content
	if content == "" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	lineCount := strings.Count(content, "\n") + 1
	if lineCount > warnThreshold {
		fmt.Fprintf(os.Stderr, "⚠️  大檔案寫入: %d 行 — 考慮拆分成更小的變更\n", lineCount)
	}

	// Always allow — warn only
	fmt.Println(protocol.ContinueResponse())
}
