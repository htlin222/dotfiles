package context

import (
	"path/filepath"
	"strings"
	"testing"
)

func TestGetLevel(t *testing.T) {
	tests := []struct {
		pct      int
		expected PressureLevel
	}{
		{0, PressureNone},
		{50, PressureNone},
		{69, PressureNone},
		{70, PressureWarning},
		{84, PressureWarning},
		{85, PressureHigh},
		{94, PressureHigh},
		{95, PressureCritical},
		{100, PressureCritical},
	}

	for _, tt := range tests {
		got := GetLevel(tt.pct)
		if got != tt.expected {
			t.Errorf("GetLevel(%d) = %d, want %d", tt.pct, got, tt.expected)
		}
	}
}

func TestWriteReadPressure(t *testing.T) {
	tmpDir := t.TempDir()
	PressureFilePath = filepath.Join(tmpDir, "context_pressure.json")
	defer func() { PressureFilePath = "" }()

	if err := WritePressure(85, 170000, 200000); err != nil {
		t.Fatal(err)
	}

	pct := ReadPressure()
	if pct != 85 {
		t.Errorf("ReadPressure() = %d, want 85", pct)
	}
}

func TestReadPressure_Missing(t *testing.T) {
	tmpDir := t.TempDir()
	PressureFilePath = filepath.Join(tmpDir, "nonexistent.json")
	defer func() { PressureFilePath = "" }()

	pct := ReadPressure()
	if pct != 0 {
		t.Errorf("ReadPressure() = %d, want 0 for missing file", pct)
	}
}

func TestCheckPressure_Levels(t *testing.T) {
	tmpDir := t.TempDir()
	PressureFilePath = filepath.Join(tmpDir, "context_pressure.json")
	defer func() { PressureFilePath = "" }()

	tests := []struct {
		pct         int
		wantEmpty   bool
		wantContain string
	}{
		{50, true, ""},
		{70, false, "approaching limit"},
		{85, false, "/compact"},
		{95, false, "strongly recommend"},
	}

	for _, tt := range tests {
		WritePressure(tt.pct, tt.pct*2000, 200000)
		got := CheckPressure()
		if tt.wantEmpty && got != "" {
			t.Errorf("CheckPressure() at %d%% = %q, want empty", tt.pct, got)
		}
		if !tt.wantEmpty && got == "" {
			t.Errorf("CheckPressure() at %d%% = empty, want non-empty", tt.pct)
		}
		if tt.wantContain != "" && !strings.Contains(got, tt.wantContain) {
			t.Errorf("CheckPressure() at %d%% = %q, want to contain %q", tt.pct, got, tt.wantContain)
		}
	}
}

func TestThresholdOrder(t *testing.T) {
	if WarningThreshold >= HighThreshold {
		t.Error("WarningThreshold should be less than HighThreshold")
	}
	if HighThreshold >= CriticalThreshold {
		t.Error("HighThreshold should be less than CriticalThreshold")
	}
	if CriticalThreshold >= 100 {
		t.Error("CriticalThreshold should be less than 100")
	}
}
