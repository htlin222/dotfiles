package context

import (
	"strings"
	"testing"
)

func TestSessionMetrics_EstimateTokens(t *testing.T) {
	tests := []struct {
		name     string
		metrics  SessionMetrics
		expected int
	}{
		{
			name:     "empty metrics",
			metrics:  SessionMetrics{},
			expected: 0,
		},
		{
			name: "prompts only",
			metrics: SessionMetrics{
				PromptCount: 10,
			},
			expected: 10 * AverageTokensPerPrompt,
		},
		{
			name: "mixed operations",
			metrics: SessionMetrics{
				PromptCount:  5,
				FileReads:    10,
				FileWrites:   3,
				BashCommands: 8,
				TaskAgents:   2,
			},
			expected: 5*AverageTokensPerPrompt + 10*AverageTokensPerFileRead + 3*200 + 8*AverageTokensPerBashOutput + 2*1000,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := tt.metrics.EstimateTokens()
			if got != tt.expected {
				t.Errorf("EstimateTokens() = %d, want %d", got, tt.expected)
			}
		})
	}
}

func TestSessionMetrics_GetPressureLevel(t *testing.T) {
	tests := []struct {
		name     string
		metrics  SessionMetrics
		expected PressureLevel
	}{
		{
			name:     "no pressure",
			metrics:  SessionMetrics{PromptCount: 10},
			expected: PressureNone,
		},
		{
			name:     "warning level (70%+)",
			metrics:  SessionMetrics{PromptCount: 70}, // 70 * 2000 = 140k (70% of 200k)
			expected: PressureWarning,
		},
		{
			name:     "high level (85%+)",
			metrics:  SessionMetrics{PromptCount: 85}, // 85 * 2000 = 170k (85% of 200k)
			expected: PressureHigh,
		},
		{
			name:     "critical level (95%+)",
			metrics:  SessionMetrics{PromptCount: 95}, // 95 * 2000 = 190k (95% of 200k)
			expected: PressureCritical,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := tt.metrics.GetPressureLevel()
			if got != tt.expected {
				t.Errorf("GetPressureLevel() = %d, want %d", got, tt.expected)
			}
		})
	}
}

func TestSessionMetrics_GetPressurePercentage(t *testing.T) {
	metrics := SessionMetrics{PromptCount: 50} // 50 * 2000 = 100k (50% of 200k)
	got := metrics.GetPressurePercentage()
	expected := 50.0

	if got != expected {
		t.Errorf("GetPressurePercentage() = %.2f, want %.2f", got, expected)
	}
}

func TestSessionMetrics_GetRemainingCapacity(t *testing.T) {
	tests := []struct {
		name     string
		metrics  SessionMetrics
		wantZero bool
	}{
		{
			name:     "plenty of capacity",
			metrics:  SessionMetrics{PromptCount: 10},
			wantZero: false,
		},
		{
			name:     "over high threshold",
			metrics:  SessionMetrics{PromptCount: 90},
			wantZero: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := tt.metrics.GetRemainingCapacity()
			if tt.wantZero && got != 0 {
				t.Errorf("GetRemainingCapacity() = %d, want 0", got)
			}
			if !tt.wantZero && got == 0 {
				t.Errorf("GetRemainingCapacity() = 0, want > 0")
			}
		})
	}
}

func TestCheckPressure(t *testing.T) {
	tests := []struct {
		name        string
		metrics     *SessionMetrics
		wantEmpty   bool
		wantContain string
	}{
		{
			name:      "nil metrics",
			metrics:   nil,
			wantEmpty: true,
		},
		{
			name:      "no pressure",
			metrics:   &SessionMetrics{PromptCount: 10},
			wantEmpty: true,
		},
		{
			name:        "warning pressure",
			metrics:     &SessionMetrics{PromptCount: 72},
			wantEmpty:   false,
			wantContain: "approaching limit",
		},
		{
			name:        "high pressure",
			metrics:     &SessionMetrics{PromptCount: 87},
			wantEmpty:   false,
			wantContain: "/compact",
		},
		{
			name:        "critical pressure",
			metrics:     &SessionMetrics{PromptCount: 96},
			wantEmpty:   false,
			wantContain: "strongly recommend",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := CheckPressure(tt.metrics)
			if tt.wantEmpty && got != "" {
				t.Errorf("CheckPressure() = %q, want empty", got)
			}
			if !tt.wantEmpty && got == "" {
				t.Errorf("CheckPressure() = empty, want non-empty")
			}
			if tt.wantContain != "" && !strings.Contains(got, tt.wantContain) {
				t.Errorf("CheckPressure() = %q, want to contain %q", got, tt.wantContain)
			}
		})
	}
}

func TestPressureLevelConstants(t *testing.T) {
	// Ensure thresholds are in correct order
	if WarningThreshold >= HighThreshold {
		t.Error("WarningThreshold should be less than HighThreshold")
	}
	if HighThreshold >= CriticalThreshold {
		t.Error("HighThreshold should be less than CriticalThreshold")
	}
	if CriticalThreshold >= 1.0 {
		t.Error("CriticalThreshold should be less than 1.0")
	}
}
