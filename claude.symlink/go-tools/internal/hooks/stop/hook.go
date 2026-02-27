// Package stop implements the Stop hook.
package stop

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/hooks/busy"
	"github.com/htlin/claude-tools/internal/hooks/killtimer"
	"github.com/htlin/claude-tools/internal/hooks/sessiontimer"
	"github.com/htlin/claude-tools/internal/processors"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/notify"
	"github.com/htlin/claude-tools/pkg/patterns"
)

const (
	// formatTimeout is the maximum time for the entire formatting step.
	formatTimeout = 30 * time.Second
	// formatWorkers is the number of parallel formatter goroutines.
	formatWorkers = 8
)

// formatters returns the extension-to-command mapping from config.
var formatters = config.Formatters

// Run executes the stop hook.
func Run() {
	if pane := busy.GetTmuxPane(); pane != "" {
		busy.SetIdle(pane)
	}

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

	// TTS: say the repo name (fire-and-forget)
	notify.Say(folderName)

	// Feature 1: Format unstaged git files (parallel, with timeout)
	dirtyFiles := getGitDirtyFiles(cwd)
	formattedCount := 0
	if len(dirtyFiles) > 0 {
		formattedCount = formatEditedFiles(dirtyFiles)
	}

	// Feature 1.5: Lint dirty files (one-time, not per-tool-call)
	lintCount := 0
	if len(dirtyFiles) > 0 {
		lintCount = lintDirtyFiles(dirtyFiles, cwd)
	}

	// Feature 2: Notification with last assistant message
	title := "Claude Code"
	if folderName != "" {
		title = fmt.Sprintf("Claude Code 📁 %s", folderName)
	}
	body := data.LastAssistantMessage
	if body == "" {
		body = "對話已完成"
	}
	if len(body) > 500 {
		body = body[:500] + "…"
	}
	notify.Send(title, body)

	// Feature 2.5: Save context snapshot for @LAST
	if data.TranscriptPath != "" || data.LastAssistantMessage != "" {
		snapshot.Generate(data.TranscriptPath, cwd, sessionID, data.LastAssistantMessage)
	}

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("stop", "Stop", executionTimeMS, true, map[string]any{
		"session_id":      sessionID,
		"files_formatted": formattedCount,
		"files_linted":    lintCount,
		"files_found":     len(dirtyFiles),
	})

	metrics.LogEvent("Stop", "stop", sessionID, cwd, map[string]any{
		"project": folderName,
	})

	// Print summary to stderr (visible in verbose mode)
	if formattedCount > 0 || lintCount > 0 {
		fmt.Fprintf(os.Stderr, "%s%s%s %s%d%s files formatted, %s%d%s files linted\n",
			ansi.BrightGreen, ansi.IconCheck, ansi.Reset,
			ansi.BrightWhite, formattedCount, ansi.Reset,
			ansi.BrightWhite, lintCount, ansi.Reset)
	}

	// Print session duration
	sessiontimer.PrintDuration()

	// Start kill timer for idle session cleanup
	if claudePID := killtimer.FindClaudePID(); claudePID > 0 {
		if err := killtimer.Start(claudePID, sessionID); err != nil {
			fmt.Fprintf(os.Stderr, "killtimer: %v\n", err)
		} else {
			fmt.Fprintf(os.Stderr, "%s%s  Auto-kill in 10m (PID %d)%s\n",
				ansi.BrightYellow, ansi.IconHourglass, claudePID, ansi.Reset)
		}
	}

	// Stop hook: exit 0 with no stdout = allow Claude to stop normally
	// Do NOT output JSON here - "continue":true can be misinterpreted as "keep working"
}

// getGitDirtyFiles returns unstaged modified files from git.
func getGitDirtyFiles(cwd string) map[string]bool {
	files := make(map[string]bool)
	if cwd == "" {
		return files
	}

	// Get git repo root to resolve relative paths
	topCmd := exec.Command("git", "rev-parse", "--show-toplevel")
	topCmd.Dir = cwd
	topOut, err := topCmd.Output()
	if err != nil {
		return files
	}
	gitRoot := strings.TrimSpace(string(topOut))

	// git diff --name-only: unstaged modified files (not yet added)
	cmd := exec.Command("git", "diff", "--name-only")
	cmd.Dir = cwd
	output, err := cmd.Output()
	if err != nil {
		return files
	}

	for _, line := range strings.Split(strings.TrimSpace(string(output)), "\n") {
		if line == "" {
			continue
		}
		// git diff paths are relative to repo root
		absPath := filepath.Join(gitRoot, line)
		if _, err := os.Stat(absPath); err == nil {
			files[absPath] = true
		}
	}

	return files
}

// skipDirs lists directories to skip for linting.
var skipDirs = map[string]bool{
	"node_modules": true, "dist": true, "build": true, ".next": true,
	".nuxt": true, "__pycache__": true, ".venv": true, "venv": true,
	".git": true, "coverage": true, ".cache": true, "out": true, ".output": true,
}

// lintDirtyFiles runs risky pattern detection and processors on dirty git files.
// Results are printed to stderr (informational only, not injected into context).
func lintDirtyFiles(files map[string]bool, cwd string) int {
	linted := 0
	for filePath := range files {
		// Skip directories that shouldn't be linted
		parts := strings.Split(strings.ReplaceAll(filePath, "\\", "/"), "/")
		skip := false
		for _, part := range parts {
			if skipDirs[part] {
				skip = true
				break
			}
		}
		if skip {
			continue
		}

		content, err := os.ReadFile(filePath)
		if err != nil {
			continue
		}

		linted++
		filename := filepath.Base(filePath)

		// Detect risky patterns
		isTest := isTestFilePath(filePath)
		findings := patterns.DetectRiskyPatterns(string(content), isTest)
		for _, f := range findings {
			if f.Severity == "high" {
				fmt.Fprintf(os.Stderr, "%s%s%s %s%s%s: %s\n",
					ansi.BrightRed, ansi.IconWarning, ansi.Reset,
					ansi.BrightYellow, filename, ansi.Reset,
					f.Description)
			}
		}

		// Run processors (linters)
		success, output := processors.ProcessFile(filePath)
		if !success && output != "" {
			fmt.Fprintf(os.Stderr, "%s\n", output)
		}
	}
	return linted
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

// formatEditedFiles runs formatters in parallel with a timeout.
func formatEditedFiles(files map[string]bool) int {
	ctx, cancel := context.WithTimeout(context.Background(), formatTimeout)
	defer cancel()

	// Build work queue: only files with a known formatter
	type formatJob struct {
		path string
		cmd  []string
	}

	// Pre-check which formatters are available
	formatterAvailable := make(map[string]bool)
	for _, cmd := range formatters {
		bin := cmd[0]
		if _, checked := formatterAvailable[bin]; !checked {
			_, err := exec.LookPath(bin)
			formatterAvailable[bin] = err == nil
		}
	}

	var jobs []formatJob
	for filePath := range files {
		ext := strings.ToLower(filepath.Ext(filePath))
		cmd, ok := formatters[ext]
		if !ok || !formatterAvailable[cmd[0]] {
			continue
		}
		jobs = append(jobs, formatJob{path: filePath, cmd: cmd})
	}

	if len(jobs) == 0 {
		return 0
	}

	// Parallel execution with worker pool
	var count atomic.Int32
	var wg sync.WaitGroup
	ch := make(chan formatJob, len(jobs))

	for _, job := range jobs {
		ch <- job
	}
	close(ch)

	workers := formatWorkers
	if len(jobs) < workers {
		workers = len(jobs)
	}

	for i := 0; i < workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for job := range ch {
				if ctx.Err() != nil {
					return
				}
				cmd := exec.CommandContext(ctx, job.cmd[0], append(job.cmd[1:], job.path)...)
				if err := cmd.Run(); err == nil {
					count.Add(1)
				}
			}
		}()
	}

	wg.Wait()
	return int(count.Load())
}

