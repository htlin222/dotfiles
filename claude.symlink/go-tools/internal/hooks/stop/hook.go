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

	"github.com/htlin/claude-tools/internal/hooks/busy"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/notify"
)

const (
	// formatTimeout is the maximum time for the entire formatting step.
	formatTimeout = 30 * time.Second
	// formatWorkers is the number of parallel formatter goroutines.
	formatWorkers = 8
)

// File extension to formatter mapping
var formatters = map[string][]string{
	// Biome
	".js":   {"biome", "format", "--write"},
	".jsx":  {"biome", "format", "--write"},
	".ts":   {"biome", "format", "--write"},
	".tsx":  {"biome", "format", "--write"},
	".json": {"biome", "format", "--write"},
	".css":  {"biome", "format", "--write"},
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

	// Feature 2: Git status & notification
	gitStatusAndNotify(cwd, folderName)

	// Feature 2.5: Save context snapshot for @LAST
	if data.TranscriptPath != "" {
		snapshot.Generate(data.TranscriptPath, cwd, sessionID)
	}

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("stop", "Stop", executionTimeMS, true, map[string]any{
		"session_id":      sessionID,
		"files_formatted": formattedCount,
		"files_found":     len(dirtyFiles),
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
