// Package stop implements the Stop hook.
package stop

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/notify"
	"github.com/htlin/claude-tools/pkg/tts"
)

// File extension to formatter mapping
var formatters = map[string][]string{
	// Biome
	".js":  {"biome", "format", "--write"},
	".jsx": {"biome", "format", "--write"},
	".ts":  {"biome", "format", "--write"},
	".tsx": {"biome", "format", "--write"},
	".json": {"biome", "format", "--write"},
	".css": {"biome", "format", "--write"},
	// Prettier
	".html": {"prettier", "--write"},
	".md":   {"prettier", "--write"},
	".qmd":  {"prettier", "--write"},
	".mdx":  {"prettier", "--write"},
	".yaml": {"prettier", "--write"},
	".yml":  {"prettier", "--write"},
	".scss": {"prettier", "--write"},
	".less": {"prettier", "--write"},
	".vue":  {"prettier", "--write"},
	// Python
	".py":  {"ruff", "format"},
	".pyi": {"ruff", "format"},
}

// Run executes the stop hook.
func Run() {
	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		notify.SendSimple("Claude Code 對話結束")
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		notify.SendSimple("Claude Code 對話結束")
		return
	}

	cwd := data.CWD
	sessionID := data.SessionID
	folderName := filepath.Base(cwd)

	// Feature 1: Format edited files
	editedFiles := getRecentEditedFiles()
	formattedCount := 0
	if len(editedFiles) > 0 {
		formattedCount = formatEditedFiles(editedFiles)
	}

	// Feature 2: Git status & notification
	gitStatusAndNotify(cwd, folderName)

	// Feature 2.5: Save context snapshot for @LAST
	if data.TranscriptPath != "" {
		snapshot.Generate(data.TranscriptPath, cwd, sessionID)
	}

	// Feature 3: TTS notification
	tts.NotifySessionComplete(folderName, formattedCount, 0, false)

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("stop", "Stop", executionTimeMS, true, map[string]any{
		"session_id":      sessionID,
		"files_formatted": formattedCount,
	})

	metrics.LogEvent("Stop", "stop", sessionID, cwd, map[string]any{
		"project": folderName,
	})

	// Print summary to stderr (visible in verbose mode)
	if formattedCount > 0 {
		fmt.Fprintf(os.Stderr, "%s%s%s %s%d%s files formatted\n",
			ansi.BrightGreen, ansi.IconCheck, ansi.Reset,
			ansi.BrightWhite, formattedCount, ansi.Reset)
	}

	// Stop hook: exit 0 with no stdout = allow Claude to stop normally
	// Do NOT output JSON here - "continue":true can be misinterpreted as "keep working"
}

func getRecentEditedFiles() map[string]bool {
	editedFiles := make(map[string]bool)
	editsFile := config.EditsLogFile()

	if _, err := os.Stat(editsFile); os.IsNotExist(err) {
		return editedFiles
	}

	cutoff := time.Now().Add(-time.Duration(config.SessionTimeoutMinutes) * time.Minute)

	f, err := os.Open(editsFile)
	if err != nil {
		return editedFiles
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		var entry map[string]any
		if err := json.Unmarshal(scanner.Bytes(), &entry); err != nil {
			continue
		}

		timestampStr, ok := entry["timestamp"].(string)
		if !ok {
			continue
		}

		timestamp, err := time.Parse(time.RFC3339, timestampStr)
		if err != nil {
			continue
		}

		if timestamp.After(cutoff) {
			if filePath, ok := entry["file"].(string); ok {
				if _, err := os.Stat(filePath); err == nil {
					editedFiles[filePath] = true
				}
			}
		}
	}

	return editedFiles
}

func formatEditedFiles(files map[string]bool) int {
	formattedCount := 0

	for filePath := range files {
		ext := strings.ToLower(filepath.Ext(filePath))
		formatterCmd, ok := formatters[ext]
		if !ok {
			continue
		}

		// Check if formatter exists
		if _, err := exec.LookPath(formatterCmd[0]); err != nil {
			continue
		}

		cmd := exec.Command(formatterCmd[0], append(formatterCmd[1:], filePath)...)
		if err := cmd.Run(); err == nil {
			formattedCount++
		}
	}

	return formattedCount
}

func gitStatusAndNotify(cwd, folderName string) {
	title := "Claude Code"
	if folderName != "" {
		title = fmt.Sprintf("Claude Code 📁 %s", folderName)
	}

	// Get git status
	cmd := exec.Command("git", "status", "-s")
	cmd.Dir = cwd
	output, err := cmd.Output()
	if err != nil {
		notify.Send(title, "對話已完成")
		return
	}

	gitStatus := strings.TrimSpace(string(output))
	if gitStatus == "" {
		notify.Send(title, "無 Git 變動")
		return
	}

	// Format status lines with emoji
	lines := strings.Split(gitStatus, "\n")
	var formatted []string
	for _, line := range lines {
		if len(line) < 3 {
			continue
		}
		code := line[:2]
		path := strings.TrimSuffix(line[3:], "/")
		filename := filepath.Base(path)
		parent := filepath.Base(filepath.Dir(path))
		displayName := filename
		if parent != "." && parent != "" {
			displayName = parent + "/" + filename
		}
		emoji := ansi.GetGitStatusEmoji(code)
		formatted = append(formatted, fmt.Sprintf("%s %s", emoji, displayName))
	}

	notify.Send(title, strings.Join(formatted, "\n"))
}
