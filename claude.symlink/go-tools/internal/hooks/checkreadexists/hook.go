// Package checkreadexists checks if files exist before Read tool.
package checkreadexists

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
)

// Run executes the check-read-exists hook.
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

	// Only check Read tool
	if data.ToolName != "Read" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	filePath := data.ToolInput.FilePath
	if filePath == "" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Resolve path
	resolved := resolvePath(filePath)
	info, err := os.Stat(resolved)

	if os.IsNotExist(err) {
		reason := fmt.Sprintf("%s%s 檔案不存在: %s%s%s",
			ansi.BrightRed, ansi.IconCross,
			ansi.BrightYellow, filePath, ansi.Reset,
		)
		fmt.Println(protocol.BlockResponse(reason))
		return
	}

	if info != nil && info.IsDir() {
		reason := fmt.Sprintf("%s%s 這是目錄: %s%s%s (用 ls 查看)",
			ansi.BrightYellow, ansi.IconFolder,
			ansi.BrightCyan, filePath, ansi.Reset,
		)
		fmt.Println(protocol.BlockResponse(reason))
		return
	}

	fmt.Println(protocol.ContinueResponse())
}

// resolvePath expands ~ and makes path absolute.
func resolvePath(path string) string {
	if strings.HasPrefix(path, "~") {
		home, _ := os.UserHomeDir()
		path = home + path[1:]
	}
	return path
}
