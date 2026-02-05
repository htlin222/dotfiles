// Package fileguard implements the FileGuard hook to block access to sensitive files.
package fileguard

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

// Run executes the file guard hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		os.Exit(0)
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		os.Exit(0)
	}

	// Only check file-based tools
	if data.ToolName != "Read" && data.ToolName != "Write" && data.ToolName != "Edit" && data.ToolName != "MultiEdit" {
		os.Exit(0)
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
			printBlockMessage(filePath, reason)
			os.Exit(2) // Block the operation
		}

		// Check content patterns for existing JSON files
		if strings.HasSuffix(filePath, ".json") {
			if _, err := os.Stat(filePath); err == nil {
				content, err := os.ReadFile(filePath)
				if err == nil && len(content) <= 10000 {
					if hasSensitive, contentReason := patterns.HasSensitiveContent(string(content)); hasSensitive {
						printBlockMessage(filePath, contentReason)
						os.Exit(2)
					}
				}
			}
		}
	}

	// All checks passed
	os.Exit(0)
}

func printBlockMessage(filePath, reason string) {
	fmt.Fprintf(os.Stderr,
		"%s%s BLOCKED:%s %s%sAccess to sensitive file denied%s\n"+
			"   %s%s%s %s%s%s\n"+
			"   %s%s%s %s\n"+
			"   %s%s%s Add to .agentignore exceptions if needed%s\n",
		ansi.BrightRed, ansi.IconShield, ansi.Reset,
		ansi.BrightWhite, "", ansi.Reset,
		ansi.Dim, ansi.IconFile, ansi.Reset,
		ansi.BrightYellow, filePath, ansi.Reset,
		ansi.Dim, ansi.IconInfo, ansi.Reset, reason,
		ansi.Dim, ansi.IconArrowRight, ansi.Reset, ansi.Reset,
	)
}
