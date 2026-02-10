// Package context provides context window pressure monitoring
// using real token data from the statusline.
package context

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/htlin/claude-tools/pkg/ansi"
)

// Thresholds for context pressure warnings (percentage).
const (
	WarningThreshold  = 70
	HighThreshold     = 85
	CriticalThreshold = 95

	// MaxStaleness is how old pressure data can be before we ignore it.
	MaxStaleness = 10 * time.Minute
)

// PressureLevel represents the severity of context pressure.
type PressureLevel int

const (
	PressureNone PressureLevel = iota
	PressureWarning
	PressureHigh
	PressureCritical
)

// ContextPressure stores real context usage written by the statusline.
type ContextPressure struct {
	Pct       int       `json:"pct"`
	Tokens    int       `json:"tokens,omitempty"`
	Window    int       `json:"window,omitempty"`
	UpdatedAt time.Time `json:"updated_at"`
}

// PressureFilePath can be overridden for testing.
var PressureFilePath string

func pressureFile() string {
	if PressureFilePath != "" {
		return PressureFilePath
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".claude", "logs", "context_pressure.json")
}

// WritePressure persists real context usage from the statusline.
func WritePressure(pct, tokens, window int) error {
	data, err := json.Marshal(ContextPressure{
		Pct:       pct,
		Tokens:    tokens,
		Window:    window,
		UpdatedAt: time.Now(),
	})
	if err != nil {
		return err
	}
	return os.WriteFile(pressureFile(), data, 0644)
}

// ReadPressure loads context pressure percentage. Returns 0 if stale or missing.
func ReadPressure() int {
	data, err := os.ReadFile(pressureFile())
	if err != nil {
		return 0
	}
	var cp ContextPressure
	if err := json.Unmarshal(data, &cp); err != nil {
		return 0
	}
	if time.Since(cp.UpdatedAt) > MaxStaleness {
		return 0
	}
	return cp.Pct
}

// GetLevel returns the pressure level for a given percentage.
func GetLevel(pct int) PressureLevel {
	switch {
	case pct >= CriticalThreshold:
		return PressureCritical
	case pct >= HighThreshold:
		return PressureHigh
	case pct >= WarningThreshold:
		return PressureWarning
	default:
		return PressureNone
	}
}

// CheckPressure reads real context data and returns a warning if needed.
func CheckPressure() string {
	pct := ReadPressure()
	if pct == 0 {
		return ""
	}

	level := GetLevel(pct)

	switch level {
	case PressureCritical:
		return fmt.Sprintf("%s%s%s Context %s%d%%%s full - strongly recommend %s/compact%s or new session",
			ansi.BrightRed, ansi.IconWarning, ansi.Reset,
			ansi.BrightRed, pct, ansi.Reset,
			ansi.BrightCyan, ansi.Reset)

	case PressureHigh:
		return fmt.Sprintf("%s%s%s Context %s%d%%%s full - consider %s/compact%s soon",
			ansi.BrightYellow, ansi.IconWarning, ansi.Reset,
			ansi.BrightYellow, pct, ansi.Reset,
			ansi.BrightCyan, ansi.Reset)

	case PressureWarning:
		return fmt.Sprintf("%s%s%s Context %s%d%%%s - approaching limit, monitor usage",
			ansi.Dim, ansi.IconInfo, ansi.Reset,
			ansi.BrightWhite, pct, ansi.Reset)

	default:
		return ""
	}
}
