// Package posttooluse implements the PostToolUse hook.
package posttooluse

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"regexp"
	"time"

	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/metrics"
)

// Run executes the post-tool-use hook (metrics-only, no file reads or linting).
func Run() {
	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	toolName := data.ToolName
	cwd := data.CWD
	sessionID := data.SessionID

	// Handle Bash commands — log metrics only
	if toolName == "Bash" {
		command := data.ToolInput.Command
		if command != "" {
			exitCode := 0
			if result, ok := data.ToolResult.(map[string]any); ok {
				if code, ok := result["exit_code"].(float64); ok {
					exitCode = int(code)
				}
			}
			metrics.LogBashCommand(command, cwd, exitCode)
		}
		fmt.Println(protocol.ContinueResponse())
		logMetrics(startTime, sessionID, toolName, cwd, nil)
		return
	}

	// Find file paths for edit metrics
	filePathPattern := regexp.MustCompile(`"(?:filePath|file_path)"\s*:\s*"([^"]+)"`)
	matches := filePathPattern.FindAllStringSubmatch(string(input), -1)

	var filePaths []string
	for _, match := range matches {
		if len(match) > 1 {
			filePaths = append(filePaths, match[1])
		}
	}

	// Log edit metrics only (no file reads, no linting)
	for _, filePath := range filePaths {
		if _, err := os.Stat(filePath); os.IsNotExist(err) {
			continue
		}
		metrics.LogEdit(filePath, toolName, cwd, sessionID)
	}

	fmt.Println(protocol.ContinueResponse())
	logMetrics(startTime, sessionID, toolName, cwd, filePaths)
}

func logMetrics(startTime time.Time, sessionID, toolName, cwd string, filePaths []string) {
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("post_tool_use", "PostToolUse", executionTimeMS, true, map[string]any{
		"session_id":      sessionID,
		"tool_name":       toolName,
		"files_processed": len(filePaths),
		"warnings_count":  0,
	})

	metrics.LogEvent("PostToolUse", "post_tool_use", sessionID, cwd, map[string]any{
		"tool_name":  toolName,
		"file_paths": truncateSlice(filePaths, 5),
	})
}

func truncateSlice(slice []string, maxLen int) []string {
	if len(slice) <= maxLen {
		return slice
	}
	return slice[:maxLen]
}
