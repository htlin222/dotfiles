// Package checkfileexists checks if files exist before cat/bat commands.
package checkfileexists

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
)

var catBatPattern = regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*(?:cat|bat)\s+`)

// Run executes the check-file-exists hook.
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

	// Check if command uses cat or bat
	if !catBatPattern.MatchString(command) {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	filePath := extractFilePath(command)
	if filePath == "" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Resolve path
	resolved := resolvePath(filePath)
	if _, err := os.Stat(resolved); os.IsNotExist(err) {
		reason := fmt.Sprintf("%s%s 檔案不存在: %s%s%s",
			ansi.BrightRed, ansi.IconCross,
			ansi.BrightYellow, filePath, ansi.Reset,
		)
		fmt.Println(protocol.BlockResponse(reason))
		return
	}

	fmt.Println(protocol.ContinueResponse())
}

// extractFilePath extracts file path from cat/bat command.
func extractFilePath(command string) string {
	// Pattern to match cat or bat at start or after && ; |
	pattern := regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*(?:cat|bat)\s+([^\s&|;]+)`)
	match := pattern.FindStringSubmatch(command)
	if len(match) < 2 {
		return ""
	}

	arg := strings.TrimSpace(match[1])
	// Skip flags
	if strings.HasPrefix(arg, "-") {
		return ""
	}
	return arg
}

// resolvePath expands ~ and makes path absolute.
func resolvePath(path string) string {
	if strings.HasPrefix(path, "~") {
		home, _ := os.UserHomeDir()
		path = home + path[1:]
	}
	return path
}
