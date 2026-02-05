// Package context provides context window pressure monitoring.
package context

import (
	"fmt"

	"github.com/htlin/claude-tools/pkg/ansi"
)

// Thresholds for context pressure warnings (in tokens).
const (
	// MaxContextTokens is the estimated max context window (Sonnet/Opus).
	MaxContextTokens = 200000

	// WarningThreshold triggers a soft warning (70%).
	WarningThreshold = 0.70

	// HighThreshold triggers a stronger warning (85%).
	HighThreshold = 0.85

	// CriticalThreshold triggers urgent action (95%).
	CriticalThreshold = 0.95

	// AverageTokensPerPrompt is an estimate for prompt + response.
	AverageTokensPerPrompt = 2000

	// AverageTokensPerFileRead estimates tokens for file reads.
	AverageTokensPerFileRead = 500

	// AverageTokensPerBashOutput estimates tokens for bash output.
	AverageTokensPerBashOutput = 300
)

// PressureLevel represents the severity of context pressure.
type PressureLevel int

const (
	PressureNone PressureLevel = iota
	PressureWarning
	PressureHigh
	PressureCritical
)

// SessionMetrics tracks token usage within a session.
type SessionMetrics struct {
	PromptCount     int `json:"prompt_count"`
	FileReads       int `json:"file_reads"`
	FileWrites      int `json:"file_writes"`
	BashCommands    int `json:"bash_commands"`
	TaskAgents      int `json:"task_agents"`
	EstimatedTokens int `json:"estimated_tokens"`
}

// EstimateTokens calculates estimated token usage from metrics.
func (m *SessionMetrics) EstimateTokens() int {
	tokens := 0

	// Base prompt/response tokens
	tokens += m.PromptCount * AverageTokensPerPrompt

	// File operations
	tokens += m.FileReads * AverageTokensPerFileRead
	tokens += m.FileWrites * 200 // writes are typically smaller

	// Bash outputs
	tokens += m.BashCommands * AverageTokensPerBashOutput

	// Task agents spawn their own context but still contribute
	tokens += m.TaskAgents * 1000

	return tokens
}

// GetPressureLevel returns the current pressure level.
func (m *SessionMetrics) GetPressureLevel() PressureLevel {
	ratio := float64(m.EstimateTokens()) / float64(MaxContextTokens)

	switch {
	case ratio >= CriticalThreshold:
		return PressureCritical
	case ratio >= HighThreshold:
		return PressureHigh
	case ratio >= WarningThreshold:
		return PressureWarning
	default:
		return PressureNone
	}
}

// GetPressurePercentage returns the context usage as a percentage.
func (m *SessionMetrics) GetPressurePercentage() float64 {
	return float64(m.EstimateTokens()) / float64(MaxContextTokens) * 100
}

// CheckPressure returns a warning message if context pressure is high.
func CheckPressure(metrics *SessionMetrics) string {
	if metrics == nil {
		return ""
	}

	level := metrics.GetPressureLevel()
	percentage := metrics.GetPressurePercentage()

	switch level {
	case PressureCritical:
		return fmt.Sprintf("%s%s%s Context %s%.0f%%%s full - strongly recommend %s/compact%s or new session",
			ansi.BrightRed, ansi.IconWarning, ansi.Reset,
			ansi.BrightRed, percentage, ansi.Reset,
			ansi.BrightCyan, ansi.Reset)

	case PressureHigh:
		return fmt.Sprintf("%s%s%s Context %s%.0f%%%s full - consider %s/compact%s soon",
			ansi.BrightYellow, ansi.IconWarning, ansi.Reset,
			ansi.BrightYellow, percentage, ansi.Reset,
			ansi.BrightCyan, ansi.Reset)

	case PressureWarning:
		return fmt.Sprintf("%s%s%s Context %s%.0f%%%s - approaching limit, monitor usage",
			ansi.Dim, ansi.IconInfo, ansi.Reset,
			ansi.BrightWhite, percentage, ansi.Reset)

	default:
		return ""
	}
}

// GetRemainingCapacity returns estimated remaining prompts before hitting threshold.
func (m *SessionMetrics) GetRemainingCapacity() int {
	tokensUsed := m.EstimateTokens()
	tokensRemaining := int(float64(MaxContextTokens)*HighThreshold) - tokensUsed

	if tokensRemaining <= 0 {
		return 0
	}

	return tokensRemaining / AverageTokensPerPrompt
}
