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
)

var catBatPattern = regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*(?:cat|bat)\s+`)

// Run executes the check-file-exists hook. Allow = exit 0 with no output.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	command := data.ToolInput.Command
	if command == "" || !catBatPattern.MatchString(command) {
		return
	}

	filePath := extractFilePath(command)
	if filePath == "" {
		return
	}

	if _, err := os.Stat(resolvePath(filePath)); os.IsNotExist(err) {
		fmt.Println(protocol.PreToolUseDeny("檔案不存在 (file not found): " + filePath))
	}
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
