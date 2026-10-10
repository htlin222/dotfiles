// Package posttooluse implements the PostToolUse hook.
//
// Write/Edit: format the one file just written (formatter table in
// internal/config), then lint it and feed findings back to the model via
// hookSpecificOutput.additionalContext. Must run synchronously so the
// formatter finishes before the model's next edit of the same file.
//
// Bash: log the command only, print nothing (Codex also sends Bash here).
package posttooluse

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/processors"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/patterns"
)

var (
	// formatTimeout bounds the formatter run for one file.
	formatTimeout = 15 * time.Second
	// lintTimeout bounds the linter/processor run for one file.
	lintTimeout = 20 * time.Second
)

const (
	// maxContextLen caps the additionalContext handed to the model.
	maxContextLen = 2000
	// maxScanSize skips risky-pattern scans of huge files.
	maxScanSize = 1 << 20
)

// formatters maps extensions to formatter commands (file path appended).
var formatters = config.Formatters

// skipDirs lists directories whose files are never formatted or linted.
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
		return
	}

	switch data.ToolName {
	case "Bash":
		if command := data.ToolInput.Command; command != "" {
			metrics.LogBashCommand(command, data.CWD, bashExitCode(&data))
		}
		logMetrics(startTime, &data, "", false, 0)

	case "Write", "Edit":
		filePath := resolvePath(data.ToolInput.FilePath, data.CWD)
		if filePath == "" {
			return
		}
		if _, err := os.Stat(filePath); err != nil {
			return
		}
		metrics.LogEdit(filePath, data.ToolName, data.CWD, data.SessionID)

		formatted := formatFile(filePath)
		findings := lintFile(filePath)
		if findings != "" {
			fmt.Println(protocol.PostToolUseContext(findings))
		}
		logMetrics(startTime, &data, filePath, formatted, len(findings))
	}
}

func bashExitCode(data *protocol.HookInput) int {
	resultSource := data.ToolResult
	if resultSource == nil {
		resultSource = data.ToolResponse
	}
	if result, ok := resultSource.(map[string]any); ok {
		if code, ok := result["exit_code"].(float64); ok {
			return int(code)
		}
	}
	return 0
}

// resolvePath makes a tool file_path absolute against the hook cwd.
func resolvePath(filePath, cwd string) string {
	if filePath == "" {
		return ""
	}
	if !filepath.IsAbs(filePath) && cwd != "" {
		return filepath.Join(cwd, filePath)
	}
	return filePath
}

// inSkippedDir reports whether any path component is in skipDirs.
func inSkippedDir(filePath string) bool {
	for _, part := range strings.Split(filepath.ToSlash(filePath), "/") {
		if skipDirs[part] {
			return true
		}
	}
	return false
}

// formatterFor returns the formatter command for a file, or nil. Exact
// extension match first (".R"), then lower-cased (".PY" → ".py").
func formatterFor(filePath string) []string {
	ext := filepath.Ext(filePath)
	if cmd, ok := formatters[ext]; ok {
		return cmd
	}
	if cmd, ok := formatters[strings.ToLower(ext)]; ok {
		return cmd
	}
	return nil
}

// formatFile runs the configured formatter on filePath in place.
// Returns true if a formatter ran successfully.
func formatFile(filePath string) bool {
	if inSkippedDir(filePath) {
		return false
	}
	cmd := formatterFor(filePath)
	if len(cmd) == 0 {
		return false
	}
	if _, err := exec.LookPath(cmd[0]); err != nil {
		return false
	}

	ctx, cancel := context.WithTimeout(context.Background(), formatTimeout)
	defer cancel()
	args := append(append([]string{}, cmd[1:]...), filePath)
	c := exec.CommandContext(ctx, cmd[0], args...)
	c.Dir = filepath.Dir(filePath) // pick up project formatter config
	return c.Run() == nil
}

// lintFile runs high-severity risky-pattern detection and the file's
// linter processor. Returns plain-text findings for the model, or "".
func lintFile(filePath string) string {
	if inSkippedDir(filePath) {
		return ""
	}

	var findings []string

	if info, err := os.Stat(filePath); err == nil && info.Size() <= maxScanSize {
		if content, err := os.ReadFile(filePath); err == nil {
			for _, f := range patterns.DetectRiskyPatterns(string(content), isTestFilePath(filePath)) {
				if f.Severity == "high" {
					findings = append(findings, "- "+f.Description)
				}
			}
		}
	}

	if out := runProcessor(filePath); out != "" {
		findings = append(findings, out)
	}

	if len(findings) == 0 {
		return ""
	}
	return capText("Lint findings for "+filePath+":\n"+strings.Join(findings, "\n"), maxContextLen)
}

// runProcessor runs the linter processor with a timeout and returns its
// ANSI-stripped output when it reports problems, else "".
func runProcessor(filePath string) string {
	type result struct {
		ok  bool
		out string
	}
	ch := make(chan result, 1)
	go func() {
		ok, out := processors.ProcessFile(filePath)
		ch <- result{ok, out}
	}()
	select {
	case r := <-ch:
		if r.ok {
			return ""
		}
		return strings.TrimSpace(ansi.Strip(r.out))
	case <-time.After(lintTimeout):
		return ""
	}
}

// capText truncates s to at most max bytes on a rune boundary.
func capText(s string, max int) string {
	if len(s) <= max {
		return s
	}
	const suffix = "\n…(truncated)"
	cut := max - len(suffix)
	for cut > 0 && !isRuneStart(s[cut]) {
		cut--
	}
	return s[:cut] + suffix
}

func isRuneStart(b byte) bool { return b&0xC0 != 0x80 }

func isTestFilePath(filePath string) bool {
	lower := strings.ToLower(filePath)
	for _, indicator := range []string{"test", "spec", "__test__", ".test.", "_test."} {
		if strings.Contains(lower, indicator) {
			return true
		}
	}
	return false
}

// logMetrics records one hook_metrics.jsonl entry. (The parallel
// hook_events.jsonl entry was dropped: it duplicated this record plus
// edits.jsonl / bash_commands.jsonl on every tool call.)
func logMetrics(startTime time.Time, data *protocol.HookInput, filePath string, formatted bool, findingsLen int) {
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	extra := map[string]any{
		"session_id": data.SessionID,
		"tool_name":  data.ToolName,
	}
	if filePath != "" {
		extra["file"] = filePath
		extra["formatted"] = formatted
		extra["findings_len"] = findingsLen
	}
	metrics.LogMetrics("post_tool_use", "PostToolUse", executionTimeMS, true, extra)
}
