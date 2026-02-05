// Package posttooluse implements the PostToolUse hook.
package posttooluse

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/processors"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/patterns"
	"github.com/htlin/claude-tools/pkg/tts"
)

// Skip directories for linting
var skipDirs = map[string]bool{
	"node_modules": true, "dist": true, "build": true, ".next": true,
	".nuxt": true, "__pycache__": true, ".venv": true, "venv": true,
	".git": true, "coverage": true, ".cache": true, "out": true, ".output": true,
}

// Run executes the post-tool-use hook.
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

	// Handle Bash commands
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
			tts.NotifyBashComplete(command, exitCode, cwd)

			// Skip further processing for git commands
			if strings.HasPrefix(strings.TrimSpace(command), "git ") || strings.Contains(command, "git ") {
				fmt.Println(protocol.ContinueResponse())
				return
			}
		}
	}

	// Find file paths
	filePathPattern := regexp.MustCompile(`"(?:filePath|file_path)"\s*:\s*"([^"]+)"`)
	matches := filePathPattern.FindAllStringSubmatch(string(input), -1)

	var filePaths []string
	for _, match := range matches {
		if len(match) > 1 {
			filePaths = append(filePaths, match[1])
		}
	}

	var warnings []string
	tsFilesEdited := false

	// Process found paths
	for _, filePath := range filePaths {
		if _, err := os.Stat(filePath); os.IsNotExist(err) {
			continue
		}

		ext := filepath.Ext(filePath)

		// Log the edit
		metrics.LogEdit(filePath, toolName, cwd)

		// TTS notification for file edits
		if toolName == "Write" || toolName == "Edit" || toolName == "MultiEdit" {
			tts.NotifyFileSaved(filePath, toolName)
		}

		// Skip gitignored files
		if isGitignored(filePath, cwd) {
			continue
		}

		// Track TypeScript files
		if ext == ".ts" || ext == ".tsx" {
			tsFilesEdited = true
		}

		// Detect risky patterns
		isTestFile := isTestFilePath(filePath)
		content, err := os.ReadFile(filePath)
		if err == nil {
			findings := patterns.DetectRiskyPatterns(string(content), isTestFile)
			for _, finding := range findings {
				filename := filepath.Base(filePath)
				if finding.Severity == "high" {
					warnings = append(warnings, fmt.Sprintf("%s%s%s %s%s%s: %s",
						ansi.BrightRed, ansi.IconWarning, ansi.Reset,
						ansi.BrightYellow, filename, ansi.Reset,
						finding.Description))
				} else if finding.Severity == "medium" {
					warnings = append(warnings, fmt.Sprintf("%s%s%s %s%s%s: %s",
						ansi.BrightYellow, ansi.IconWarning, ansi.Reset,
						ansi.BrightCyan, filename, ansi.Reset,
						finding.Description))
				}
			}
		}

		// Run processors (check-only mode)
		success, output := processors.ProcessFile(filePath)
		if !success && output != "" {
			fmt.Fprintln(os.Stderr, output)
		}
	}

	// TypeScript build check
	if tsFilesEdited && cwd != "" {
		success, errorCount := checkTypeScriptBuild(cwd)
		if !success && errorCount > 5 {
			warnings = append(warnings, fmt.Sprintf("%s%s%s TypeScript: %s%d%s type errors - 建議執行 %s/build-and-fix%s",
				ansi.BrightRed, ansi.IconCross, ansi.Reset,
				ansi.BrightWhite, errorCount, ansi.Reset,
				ansi.BrightCyan, ansi.Reset))
		}
	}

	// Output response
	if len(warnings) > 0 {
		// Limit to 5 warnings
		if len(warnings) > 5 {
			warnings = warnings[:5]
		}
		fmt.Println(protocol.ContinueWithMessage(strings.Join(warnings, "\n")))
	} else {
		fmt.Println(protocol.ContinueResponse())
	}

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("post_tool_use", "PostToolUse", executionTimeMS, true, map[string]any{
		"session_id":      sessionID,
		"tool_name":       toolName,
		"files_processed": len(filePaths),
		"warnings_count":  len(warnings),
	})

	metrics.LogEvent("PostToolUse", "post_tool_use", sessionID, cwd, map[string]any{
		"tool_name":  toolName,
		"file_paths": truncateSlice(filePaths, 5),
		"warnings":   truncateSlice(warnings, 3),
	})
}

func isGitignored(filePath, cwd string) bool {
	// Check skip directories first (fast path)
	parts := strings.Split(strings.ReplaceAll(filePath, "\\", "/"), "/")
	for _, part := range parts {
		if skipDirs[part] {
			return true
		}
	}

	// Use git check-ignore for accurate detection
	dir := cwd
	if dir == "" {
		dir = filepath.Dir(filePath)
	}
	if dir == "" {
		dir = "."
	}

	cmd := exec.Command("git", "check-ignore", "-q", filePath)
	cmd.Dir = dir
	err := cmd.Run()
	return err == nil
}

func isTestFilePath(filePath string) bool {
	lower := strings.ToLower(filePath)
	testIndicators := []string{"test", "spec", "__test__", ".test.", "_test."}
	for _, indicator := range testIndicators {
		if strings.Contains(lower, indicator) {
			return true
		}
	}
	return false
}

func checkTypeScriptBuild(cwd string) (bool, int) {
	// Check if package.json exists
	if _, err := os.Stat(filepath.Join(cwd, "package.json")); os.IsNotExist(err) {
		return true, 0
	}

	// Try running typecheck
	commands := [][]string{
		{"pnpm", "typecheck"},
		{"pnpm", "tsc", "--noEmit"},
		{"npx", "tsc", "--noEmit"},
	}

	for _, cmdArgs := range commands {
		cmd := exec.Command(cmdArgs[0], cmdArgs[1:]...)
		cmd.Dir = cwd
		output, err := cmd.CombinedOutput()
		if err == nil {
			return true, 0
		}

		// Count errors
		errorPattern := regexp.MustCompile(`error TS\d+:`)
		matches := errorPattern.FindAllString(string(output), -1)
		return false, len(matches)
	}

	return true, 0
}

func truncateSlice(slice []string, maxLen int) []string {
	if len(slice) <= maxLen {
		return slice
	}
	return slice[:maxLen]
}
