package envvalidation

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

// --- parseVersion ---

func TestParseVersion_Standard(t *testing.T) {
	tests := []struct {
		input string
		want  [3]int
	}{
		{"v18.17.0", [3]int{18, 17, 0}},
		{"2.42.1", [3]int{2, 42, 1}},
		{"git version 2.39.3 (Apple Git-145)", [3]int{2, 39, 3}},
		{"Python 3.12.0", [3]int{3, 12, 0}},
		{"10.0", [3]int{10, 0, 0}},
		{"v0.4.10", [3]int{0, 4, 10}},
	}

	for _, tt := range tests {
		got := parseVersion(tt.input)
		if got != tt.want {
			t.Errorf("parseVersion(%q) = %v, want %v", tt.input, got, tt.want)
		}
	}
}

func TestParseVersion_Invalid(t *testing.T) {
	tests := []string{"", "no version here", "abc"}
	for _, input := range tests {
		got := parseVersion(input)
		if got != [3]int{0, 0, 0} {
			t.Errorf("parseVersion(%q) = %v, want [0,0,0]", input, got)
		}
	}
}

// --- compareVersions ---

func TestCompareVersions(t *testing.T) {
	tests := []struct {
		a, b [3]int
		want int
	}{
		{[3]int{2, 0, 0}, [3]int{2, 0, 0}, 0},
		{[3]int{3, 0, 0}, [3]int{2, 0, 0}, 1},
		{[3]int{1, 0, 0}, [3]int{2, 0, 0}, -1},
		{[3]int{2, 1, 0}, [3]int{2, 0, 0}, 1},
		{[3]int{2, 0, 1}, [3]int{2, 0, 0}, 1},
		{[3]int{18, 17, 0}, [3]int{18, 0, 0}, 1},
		{[3]int{0, 4, 10}, [3]int{0, 1, 0}, 1},
	}

	for _, tt := range tests {
		got := compareVersions(tt.a, tt.b)
		if got != tt.want {
			t.Errorf("compareVersions(%v, %v) = %d, want %d", tt.a, tt.b, got, tt.want)
		}
	}
}

// --- checkTool ---

func TestCheckTool_GitAvailable(t *testing.T) {
	if _, err := exec.LookPath("git"); err != nil {
		t.Skip("git not in PATH")
	}

	result := checkTool(ToolConfig{
		Name:       "git",
		Cmd:        []string{"git", "--version"},
		MinVersion: "2.0",
	})

	if !result.Available {
		t.Error("expected git to be available")
	}
	if !result.MeetsRequirement {
		t.Errorf("expected git >= 2.0, got %s", result.Version)
	}
	if result.Version == "" {
		t.Error("expected version string")
	}
}

func TestCheckTool_NotFound(t *testing.T) {
	result := checkTool(ToolConfig{
		Name:     "nonexistent-tool-xyz",
		Cmd:      []string{"nonexistent-tool-xyz", "--version"},
		Optional: true,
	})

	if result.Available {
		t.Error("expected tool to not be available")
	}
	if result.Error == "" {
		t.Error("expected error message")
	}
}

func TestCheckTool_NoMinVersion(t *testing.T) {
	if _, err := exec.LookPath("git"); err != nil {
		t.Skip("git not in PATH")
	}

	result := checkTool(ToolConfig{
		Name: "git",
		Cmd:  []string{"git", "--version"},
		// No MinVersion
	})

	if !result.Available {
		t.Error("expected available")
	}
	if !result.MeetsRequirement {
		t.Error("expected meets requirement when no min version set")
	}
}

func TestCheckTool_VersionTooLow(t *testing.T) {
	if _, err := exec.LookPath("git"); err != nil {
		t.Skip("git not in PATH")
	}

	result := checkTool(ToolConfig{
		Name:       "git",
		Cmd:        []string{"git", "--version"},
		MinVersion: "999.0",
	})

	if !result.Available {
		t.Error("expected available")
	}
	if result.MeetsRequirement {
		t.Error("expected not meets requirement for version 999.0")
	}
}

// --- checkToolsParallel ---

func TestCheckToolsParallel_MultipleTools(t *testing.T) {
	tools := []ToolConfig{
		{Name: "git", Cmd: []string{"git", "--version"}, MinVersion: "2.0"},
		{Name: "fake", Cmd: []string{"nonexistent-abc", "--version"}, Optional: true},
	}

	results := checkToolsParallel(tools)

	if len(results) != 2 {
		t.Fatalf("expected 2 results, got %d", len(results))
	}

	// git should be first (preserves order)
	if results[0].Name != "git" {
		t.Errorf("expected first result to be git, got %s", results[0].Name)
	}
	if results[1].Name != "fake" {
		t.Errorf("expected second result to be fake, got %s", results[1].Name)
	}
	if results[1].Available {
		t.Error("expected fake tool to not be available")
	}
}

// --- checkProjectRequirements ---

func TestCheckProjectRequirements_EmptyCwd(t *testing.T) {
	missing := checkProjectRequirements("")
	if len(missing) != 0 {
		t.Errorf("expected 0 missing for empty cwd, got %d", len(missing))
	}
}

func TestCheckProjectRequirements_NoConfigFiles(t *testing.T) {
	tmpDir := t.TempDir()
	missing := checkProjectRequirements(tmpDir)
	if len(missing) != 0 {
		t.Errorf("expected 0 missing for empty dir, got %d", len(missing))
	}
}

func TestCheckProjectRequirements_GoMod(t *testing.T) {
	tmpDir := t.TempDir()
	os.WriteFile(filepath.Join(tmpDir, "go.mod"), []byte("module test"), 0644)

	missing := checkProjectRequirements(tmpDir)

	// "go" should be available in test environment
	if _, err := exec.LookPath("go"); err == nil {
		// go is available, should be no missing
		for _, m := range missing {
			if m == "go (required by go.mod)" {
				t.Error("go is installed but reported missing")
			}
		}
	}
}

func TestCheckProjectRequirements_MissingTool(t *testing.T) {
	tmpDir := t.TempDir()
	os.WriteFile(filepath.Join(tmpDir, "Gemfile"), []byte("source 'rubygems'"), 0644)

	missing := checkProjectRequirements(tmpDir)

	if _, err := exec.LookPath("ruby"); err != nil {
		// ruby not installed, should be in missing
		found := false
		for _, m := range missing {
			if m == "ruby (required by Gemfile)" {
				found = true
			}
		}
		if !found {
			t.Error("expected ruby to be reported missing")
		}
	}
}

// --- writeEnvVars ---

func TestWriteEnvVars_WritesFile(t *testing.T) {
	tmpFile := filepath.Join(t.TempDir(), "env")
	os.Setenv("CLAUDE_ENV_FILE", tmpFile)
	defer os.Unsetenv("CLAUDE_ENV_FILE")

	writeEnvVars("/Users/test/myproject", "startup")

	data, err := os.ReadFile(tmpFile)
	if err != nil {
		t.Fatalf("failed to read env file: %v", err)
	}

	content := string(data)
	if !containsStr(content, "PROJECT_NAME='myproject'") {
		t.Error("expected PROJECT_NAME in env file")
	}
	if !containsStr(content, "SESSION_SOURCE='startup'") {
		t.Error("expected SESSION_SOURCE in env file")
	}
}

func TestWriteEnvVars_NoEnvFile(t *testing.T) {
	os.Unsetenv("CLAUDE_ENV_FILE")
	// Should not panic
	writeEnvVars("/tmp", "startup")
}

func TestWriteEnvVars_EmptyCwd(t *testing.T) {
	tmpFile := filepath.Join(t.TempDir(), "env")
	os.Setenv("CLAUDE_ENV_FILE", tmpFile)
	defer os.Unsetenv("CLAUDE_ENV_FILE")

	writeEnvVars("", "startup")

	data, _ := os.ReadFile(tmpFile)
	if !containsStr(string(data), "PROJECT_NAME='unknown'") {
		t.Error("expected PROJECT_NAME='unknown' for empty cwd")
	}
}

// --- formatReport ---

func TestFormatReport_AllOK(t *testing.T) {
	results := []ToolResult{
		{Name: "git", Available: true, MeetsRequirement: true},
		{Name: "node", Available: true, MeetsRequirement: true, Optional: true},
	}

	report, hasIssues, installing := formatReport(results, nil)

	if hasIssues {
		t.Error("expected no issues")
	}
	if len(installing) > 0 {
		t.Error("expected nothing installing")
	}
	if report == "" {
		t.Error("expected non-empty report")
	}
}

func TestFormatReport_MissingRequired(t *testing.T) {
	results := []ToolResult{
		{Name: "git", Available: false, Optional: false, Error: "not found"},
	}

	_, hasIssues, _ := formatReport(results, nil)
	if !hasIssues {
		t.Error("expected issues for missing required tool")
	}
}

func TestFormatReport_MissingOptionalNoIssue(t *testing.T) {
	results := []ToolResult{
		{Name: "ruff", Available: false, Optional: true, Error: "not found"},
	}

	_, hasIssues, _ := formatReport(results, nil)
	if hasIssues {
		t.Error("expected no issues for missing optional tool")
	}
}

func TestFormatReport_OutdatedVersion(t *testing.T) {
	results := []ToolResult{
		{Name: "node", Available: true, MeetsRequirement: false, Version: "v16.0.0"},
	}

	_, hasIssues, _ := formatReport(results, nil)
	if !hasIssues {
		t.Error("expected issues for outdated version")
	}
}

func TestFormatReport_ProjectMissing(t *testing.T) {
	results := []ToolResult{}
	missing := []string{"ruby (required by Gemfile)"}

	_, hasIssues, _ := formatReport(results, missing)
	if !hasIssues {
		t.Error("expected issues for project missing tools")
	}
}

func TestFormatReport_Installing(t *testing.T) {
	results := []ToolResult{
		{Name: "biome", Available: false, Optional: true, Error: "installing"},
	}

	_, _, installing := formatReport(results, nil)
	if len(installing) != 1 || installing[0] != "biome" {
		t.Errorf("expected installing=[biome], got %v", installing)
	}
}

func containsStr(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > 0 && indexOf(s, substr) >= 0)
}

func indexOf(s, substr string) int {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return i
		}
	}
	return -1
}
