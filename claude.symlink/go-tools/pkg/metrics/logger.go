// Package metrics provides hook metrics and profiling.
package metrics

import (
	"encoding/json"
	"os"
	"time"

	"github.com/htlin/claude-tools/internal/config"
)

// MetricsEntry represents a hook metrics log entry.
type MetricsEntry struct {
	Timestamp       string  `json:"timestamp"`
	Hook            string  `json:"hook"`
	EventType       string  `json:"event_type"`
	ExecutionTimeMS float64 `json:"execution_time_ms"`
	InputSize       int     `json:"input_size,omitempty"`
	OutputSize      int     `json:"output_size,omitempty"`
	Success         bool    `json:"success"`
	Error           string  `json:"error,omitempty"`
	Performance     string  `json:"performance,omitempty"`
	Extra           map[string]any `json:"extra,omitempty"`
}

// EventEntry represents a hook event log entry.
type EventEntry struct {
	Timestamp  string         `json:"timestamp"`
	EventType  string         `json:"event_type"`
	Hook       string         `json:"hook"`
	SessionID  string         `json:"session_id,omitempty"`
	Project    string         `json:"project,omitempty"`
	CWD        string         `json:"cwd,omitempty"`
	ToolName   string         `json:"tool_name,omitempty"`
	Decision   string         `json:"decision,omitempty"`
	Metadata   map[string]any `json:"metadata,omitempty"`
}

// LogMetrics logs hook execution metrics.
func LogMetrics(hookName, eventType string, executionTimeMS float64, success bool, extra map[string]any) error {
	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	entry := MetricsEntry{
		Timestamp:       time.Now().Format(time.RFC3339),
		Hook:            hookName,
		EventType:       eventType,
		ExecutionTimeMS: executionTimeMS,
		Success:         success,
		Extra:           extra,
	}

	// Add performance classification
	switch {
	case executionTimeMS > float64(config.VerySlowHookThresholdMS):
		entry.Performance = "critical"
	case executionTimeMS > float64(config.SlowHookThresholdMS):
		entry.Performance = "slow"
	default:
		entry.Performance = "ok"
	}

	return appendJSONL(config.MetricsLogFile(), entry)
}

// LogEvent logs a hook event for observability.
func LogEvent(eventType, hookName, sessionID, cwd string, metadata map[string]any) error {
	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	project := ""
	if cwd != "" {
		for i := len(cwd) - 1; i >= 0; i-- {
			if cwd[i] == '/' || cwd[i] == '\\' {
				project = cwd[i+1:]
				break
			}
		}
		if project == "" {
			project = cwd
		}
	}

	entry := EventEntry{
		Timestamp: time.Now().Format(time.RFC3339),
		EventType: eventType,
		Hook:      hookName,
		SessionID: sessionID,
		Project:   project,
		CWD:       cwd,
		Metadata:  metadata,
	}

	return appendJSONL(config.EventsLogFile(), entry)
}

// LogEdit logs a file edit to edits.jsonl.
func LogEdit(filePath, toolName, cwd, sessionID string) error {
	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	project := ""
	if cwd != "" {
		for i := len(cwd) - 1; i >= 0; i-- {
			if cwd[i] == '/' || cwd[i] == '\\' {
				project = cwd[i+1:]
				break
			}
		}
	}

	entry := map[string]any{
		"timestamp":  time.Now().Format(time.RFC3339),
		"file":       filePath,
		"tool":       toolName,
		"cwd":        cwd,
		"project":    project,
		"session_id": sessionID,
	}

	return appendJSONL(config.EditsLogFile(), entry)
}

// LogBashCommand logs a bash command to bash_commands.jsonl.
func LogBashCommand(command, cwd string, exitCode int) error {
	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	// Truncate very long commands
	truncatedCmd := command
	if len(command) > 500 {
		truncatedCmd = command[:500] + "..."
	}

	project := ""
	if cwd != "" {
		for i := len(cwd) - 1; i >= 0; i-- {
			if cwd[i] == '/' || cwd[i] == '\\' {
				project = cwd[i+1:]
				break
			}
		}
	}

	entry := map[string]any{
		"timestamp": time.Now().Format(time.RFC3339),
		"command":   truncatedCmd,
		"cwd":       cwd,
		"project":   project,
		"exit_code": exitCode,
	}

	return appendJSONL(config.BashLogFile(), entry)
}

// LogPrompt logs a user prompt to prompts.jsonl.
func LogPrompt(cwd, prompt string) error {
	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	// Truncate long prompts
	truncatedPrompt := prompt
	if len(prompt) > 500 {
		truncatedPrompt = prompt[:500]
	}

	entry := map[string]any{
		"timestamp": time.Now().Format(time.RFC3339),
		"cwd":       cwd,
		"prompt":    truncatedPrompt,
	}

	return appendJSONL(config.PromptsLogFile(), entry)
}

// LogSession logs a session summary to sessions.jsonl.
func LogSession(sessionID, cwd, projectName string, stats map[string]int, transcriptBackup string) error {
	if err := config.EnsureLogDir(); err != nil {
		return err
	}

	entry := map[string]any{
		"timestamp":         time.Now().Format(time.RFC3339),
		"session_id":        sessionID,
		"project":           projectName,
		"cwd":               cwd,
		"stats":             stats,
		"transcript_backup": transcriptBackup,
	}

	return appendJSONL(config.SessionLogFile(), entry)
}

// EstimateTokens estimates token count from text.
func EstimateTokens(text string) int {
	if text == "" {
		return 0
	}

	// Simple heuristic: ~4 chars per token for English
	// Adjust for CJK characters (count as ~1.5 tokens each)
	cjkCount := 0
	for _, c := range text {
		if c >= '\u4e00' && c <= '\u9fff' {
			cjkCount++
		}
	}
	asciiCount := len(text) - cjkCount
	return asciiCount/4 + int(float64(cjkCount)*1.5)
}

func appendJSONL(filename string, entry any) error {
	f, err := os.OpenFile(filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer f.Close()

	data, err := json.Marshal(entry)
	if err != nil {
		return err
	}

	_, err = f.Write(append(data, '\n'))
	return err
}
