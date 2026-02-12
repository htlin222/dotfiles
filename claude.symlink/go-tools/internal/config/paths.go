// Package config provides configuration and path constants.
package config

import (
	"os"
	"path/filepath"
)

var (
	// HomeDir is the user's home directory.
	HomeDir string

	// ClaudeDir is the base Claude directory.
	ClaudeDir string

	// LogDir is the log directory.
	LogDir string

	// TranscriptDir is the transcript backup directory.
	TranscriptDir string
)

func init() {
	HomeDir, _ = os.UserHomeDir()
	ClaudeDir = filepath.Join(HomeDir, ".claude")
	LogDir = filepath.Join(ClaudeDir, "logs")
	TranscriptDir = filepath.Join(ClaudeDir, "transcripts")
}

// Log file paths
func MetricsLogFile() string {
	return filepath.Join(LogDir, "hook_metrics.jsonl")
}

func EventsLogFile() string {
	return filepath.Join(LogDir, "hook_events.jsonl")
}

func EditsLogFile() string {
	return filepath.Join(LogDir, "edits.jsonl")
}

func BashLogFile() string {
	return filepath.Join(LogDir, "bash_commands.jsonl")
}

func SessionLogFile() string {
	return filepath.Join(LogDir, "sessions.jsonl")
}

func PromptsLogFile() string {
	return filepath.Join(LogDir, "prompts.jsonl")
}

func StateFile() string {
	return filepath.Join(LogDir, "hook_state.json")
}

// EnsureLogDir creates the log directory if it doesn't exist.
func EnsureLogDir() error {
	return os.MkdirAll(LogDir, 0755)
}

// EnsureTranscriptDir creates the transcript directory if it doesn't exist.
func EnsureTranscriptDir() error {
	return os.MkdirAll(TranscriptDir, 0755)
}

// Performance thresholds
const (
	SlowHookThresholdMS     = 500
	VerySlowHookThresholdMS = 2000
	SessionTimeoutMinutes   = 60
	MaxTranscriptBackups    = 50
	BuildErrorThreshold     = 5
)
