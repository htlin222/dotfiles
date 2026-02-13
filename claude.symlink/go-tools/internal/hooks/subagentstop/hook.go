// Package subagentstop implements the SubagentStop hook.
// Logs subagent completion and sends a brief notification.
package subagentstop

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/pkg/metrics"
)

// Run executes the subagent-stop hook.
func Run() {
	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		return
	}

	var data struct {
		SessionID string `json:"session_id,omitempty"`
		CWD       string `json:"cwd,omitempty"`
	}
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	project := filepath.Base(data.CWD)

	// Log to subagent_completions.jsonl
	logSubagentCompletion(data.SessionID, data.CWD, project)

	// Log metrics
	execMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("subagent_stop", "SubagentStop", execMS, true, map[string]any{
		"session_id": data.SessionID,
		"project":    project,
	})
}

func logSubagentCompletion(sessionID, cwd, project string) {
	_ = config.EnsureLogDir()
	logFile := filepath.Join(config.LogDir, "subagent_completions.jsonl")

	entry := map[string]string{
		"timestamp":  time.Now().Format(time.RFC3339),
		"session_id": sessionID,
		"project":    project,
		"cwd":        cwd,
	}

	data, err := json.Marshal(entry)
	if err != nil {
		return
	}

	f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()

	f.Write(data)
	f.Write([]byte("\n"))

	fmt.Fprintf(os.Stderr, "subagent done [%s]\n", project)
}
