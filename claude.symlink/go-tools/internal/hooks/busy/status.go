// Package busy provides pane busy/idle status tracking via file presence.
// A file at /tmp/tmux_claude_cache/pane_status/<pane_id> means that pane is busy.
package busy

import (
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	statusDir = "/tmp/tmux_claude_cache/pane_status"
	staleAge  = 5 * time.Minute
)

// GetTmuxPane returns the numeric pane ID from $TMUX_PANE (strips leading %).
// Returns empty string if not in tmux.
func GetTmuxPane() string {
	pane := os.Getenv("TMUX_PANE")
	if pane == "" {
		return ""
	}
	return strings.TrimPrefix(pane, "%")
}

// SetBusy marks a pane as busy by creating its status file.
func SetBusy(paneID string) {
	os.MkdirAll(statusDir, 0755)
	f, err := os.Create(filepath.Join(statusDir, paneID))
	if err == nil {
		f.Close()
	}
}

// SetIdle marks a pane as idle by removing its status file.
func SetIdle(paneID string) {
	os.Remove(filepath.Join(statusDir, paneID))
}

// CleanupStale removes status files older than 5 minutes (handles crashed sessions).
func CleanupStale() {
	entries, err := os.ReadDir(statusDir)
	if err != nil {
		return
	}
	now := time.Now()
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		info, err := e.Info()
		if err != nil {
			continue
		}
		if now.Sub(info.ModTime()) > staleAge {
			os.Remove(filepath.Join(statusDir, e.Name()))
		}
	}
}
