// Package fileguard implements the FileGuard hook to block access to sensitive files.
package fileguard

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// Run executes the file guard hook.
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

	// Only check file-based tools
	if data.ToolName != "Read" && data.ToolName != "Write" && data.ToolName != "Edit" && data.ToolName != "MultiEdit" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Get file paths
	var filePaths []string
	if data.ToolName == "MultiEdit" {
		for _, edit := range data.ToolInput.Edits {
			if edit.FilePath != "" {
				filePaths = append(filePaths, edit.FilePath)
			}
		}
	} else if data.ToolInput.FilePath != "" {
		filePaths = []string{data.ToolInput.FilePath}
	}

	// Check each file path
	for _, filePath := range filePaths {
		// Check pattern match
		isSensitive, reason := patterns.MatchesSensitivePattern(filePath)
		if isSensitive {
			blockMsg := fmt.Sprintf("BLOCKED: Access to sensitive file denied — %s (%s). Add to .agentignore exceptions if needed.", filePath, reason)
			fmt.Println(protocol.BlockResponse(blockMsg))
			return
		}

		// Check content patterns for existing JSON files
		if strings.HasSuffix(filePath, ".json") {
			if _, err := os.Stat(filePath); err == nil {
				content, err := os.ReadFile(filePath)
				if err == nil && len(content) <= 10000 {
					if hasSensitive, contentReason := patterns.HasSensitiveContent(string(content)); hasSensitive {
						blockMsg := fmt.Sprintf("BLOCKED: Sensitive content detected in %s (%s). Add to .agentignore exceptions if needed.", filePath, contentReason)
						fmt.Println(protocol.BlockResponse(blockMsg))
						return
					}
				}
			}
		}
	}

	// All checks passed
	fmt.Println(protocol.ContinueResponse())
}
