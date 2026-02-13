// Package sessiontimer prints session wall-clock duration on stop.
package sessiontimer

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/pkg/ansi"
)

// PrintDuration reads the first edit timestamp from edits.jsonl
// and prints the elapsed session duration to stderr.
// Called from the stop hook.
func PrintDuration() {
	editsFile := config.EditsLogFile()
	f, err := os.Open(editsFile)
	if err != nil {
		return
	}
	defer f.Close()

	cutoff := time.Now().Add(-time.Duration(config.SessionTimeoutMinutes) * time.Minute)
	var firstEdit time.Time

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		var entry struct {
			Timestamp string `json:"timestamp"`
		}
		if err := json.Unmarshal(scanner.Bytes(), &entry); err != nil {
			continue
		}
		ts, err := time.Parse(time.RFC3339, entry.Timestamp)
		if err != nil {
			continue
		}
		if ts.Before(cutoff) {
			continue
		}
		if firstEdit.IsZero() || ts.Before(firstEdit) {
			firstEdit = ts
		}
	}

	if firstEdit.IsZero() {
		return
	}

	duration := time.Since(firstEdit)
	fmt.Fprintf(os.Stderr, "%s⏱%s  Session: %s\n",
		ansi.BrightCyan, ansi.Reset, formatDuration(duration))
}

func formatDuration(d time.Duration) string {
	h := int(d.Hours())
	m := int(d.Minutes()) % 60
	s := int(d.Seconds()) % 60

	if h > 0 {
		return fmt.Sprintf("%dh%dm", h, m)
	}
	if m > 0 {
		return fmt.Sprintf("%dm%ds", m, s)
	}
	return fmt.Sprintf("%ds", s)
}
