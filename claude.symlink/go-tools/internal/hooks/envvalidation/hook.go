// Package envvalidation implements the SessionStart environment validation hook.
// It checks required tools, project requirements, and writes env vars.
package envvalidation

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/metrics"
)

// ToolConfig defines a tool to check.
type ToolConfig struct {
	Name       string
	Cmd        []string
	MinVersion string
	Optional   bool
	InstallCmd []string // auto-install command (background)
}

// ToolResult holds the result of a tool check.
type ToolResult struct {
	Name            string `json:"name"`
	Available       bool   `json:"available"`
	Version         string `json:"version,omitempty"`
	MeetsRequirement bool  `json:"meets_requirement"`
	Optional        bool   `json:"optional"`
	Error           string `json:"error,omitempty"`
}

// ProjectRequirement maps a config file to required tools.
type ProjectRequirement struct {
	ConfigFile string
	Tools      []string
}

// RequiredTools are core development tools.
var RequiredTools = []ToolConfig{
	{Name: "git", Cmd: []string{"git", "--version"}, MinVersion: "2.0"},
	{Name: "node", Cmd: []string{"node", "--version"}, MinVersion: "18.0", Optional: true},
	{Name: "python", Cmd: []string{"python3", "--version"}, MinVersion: "3.10"},
	{Name: "uv", Cmd: []string{"uv", "--version"}, MinVersion: "0.1", Optional: true},
	{Name: "pnpm", Cmd: []string{"pnpm", "--version"}, MinVersion: "8.0", Optional: true},
	{Name: "ruff", Cmd: []string{"ruff", "--version"}, MinVersion: "0.1", Optional: true},
	{Name: "rip", Cmd: []string{"rip", "--version"}, Optional: true},
}

// ProcessorTools are optional formatters/linters used by hooks.
var ProcessorTools = []ToolConfig{
	{Name: "biome", Cmd: []string{"biome", "--version"}, Optional: true, InstallCmd: []string{"pnpm", "install", "-g", "@biomejs/biome"}},
	{Name: "prettier", Cmd: []string{"prettier", "--version"}, Optional: true, InstallCmd: []string{"pnpm", "install", "-g", "prettier"}},
	{Name: "eslint", Cmd: []string{"eslint", "--version"}, Optional: true, InstallCmd: []string{"pnpm", "install", "-g", "eslint"}},
	{Name: "shellcheck", Cmd: []string{"shellcheck", "--version"}, Optional: true, InstallCmd: []string{"brew", "install", "shellcheck"}},
}

// ProjectRequirements maps config files to required tools.
var ProjectRequirements = []ProjectRequirement{
	{ConfigFile: "package.json", Tools: []string{"node", "pnpm"}},
	{ConfigFile: "pyproject.toml", Tools: []string{"python3", "uv"}},
	{ConfigFile: "requirements.txt", Tools: []string{"python3"}},
	{ConfigFile: "Cargo.toml", Tools: []string{"cargo"}},
	{ConfigFile: "go.mod", Tools: []string{"go"}},
	{ConfigFile: "Gemfile", Tools: []string{"ruby"}},
}

var versionRegex = regexp.MustCompile(`(\d+)\.(\d+)(?:\.(\d+))?`)

// Run executes the env validation hook.
func Run() {
	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	cwd := data.CWD
	source := data.Source
	sessionID := data.SessionID

	// Always write env vars
	writeEnvVars(cwd, source)

	// Only run full validation on startup/clear
	if source != "startup" && source != "clear" {
		fmt.Println(protocol.ContinueWithMessage("Success"))
		return
	}

	// Check all tools in parallel
	allTools := append(RequiredTools, ProcessorTools...)
	results := checkToolsParallel(allTools)

	// Check project requirements
	projectMissing := checkProjectRequirements(cwd)

	// Log results
	logValidation(cwd, source, sessionID, results, projectMissing)

	// Auto-install missing processor tools in background
	installMissing(results)

	// Build report
	report, hasIssues, installing := formatReport(results, projectMissing)

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("env_validation", "SessionStart", executionTimeMS, true, map[string]any{
		"session_id": sessionID,
		"source":     source,
		"has_issues": hasIssues,
	})

	if hasIssues || len(installing) > 0 {
		fmt.Println(protocol.ContinueWithMessage(report))
	} else {
		fmt.Println(protocol.ContinueWithMessage(
			ansi.BrightGreen + ansi.IconCheck + " 開發環境檢查通過" + ansi.Reset))
	}
}

// checkToolsParallel checks all tools concurrently.
func checkToolsParallel(tools []ToolConfig) []ToolResult {
	results := make([]ToolResult, len(tools))
	var wg sync.WaitGroup

	for i, tool := range tools {
		wg.Add(1)
		go func(idx int, tc ToolConfig) {
			defer wg.Done()
			results[idx] = checkTool(tc)
		}(i, tool)
	}

	wg.Wait()
	return results
}

// checkTool checks if a single tool is available and meets version requirements.
func checkTool(tc ToolConfig) ToolResult {
	result := ToolResult{
		Name:     tc.Name,
		Optional: tc.Optional,
	}

	// Check if binary exists in PATH
	if _, err := exec.LookPath(tc.Cmd[0]); err != nil {
		result.Error = tc.Name + " not found"
		return result
	}

	// Run version command with timeout
	cmd := exec.Command(tc.Cmd[0], tc.Cmd[1:]...)
	cmd.Env = os.Environ()
	out, err := runWithTimeout(cmd, 3*time.Second)
	if err != nil {
		// Tool exists but version check failed — still available
		result.Available = true
		result.MeetsRequirement = true
		return result
	}

	result.Available = true
	result.Version = strings.TrimSpace(out)

	// Check minimum version
	if tc.MinVersion == "" {
		result.MeetsRequirement = true
		return result
	}

	current := parseVersion(result.Version)
	required := parseVersion(tc.MinVersion)
	result.MeetsRequirement = compareVersions(current, required) >= 0

	return result
}

// runWithTimeout runs a command with a timeout, returning combined stdout+stderr.
func runWithTimeout(cmd *exec.Cmd, timeout time.Duration) (string, error) {
	done := make(chan error, 1)
	var out []byte
	var cmdErr error

	go func() {
		out, cmdErr = cmd.CombinedOutput()
		done <- cmdErr
	}()

	select {
	case <-done:
		return string(out), cmdErr
	case <-time.After(timeout):
		if cmd.Process != nil {
			cmd.Process.Kill()
		}
		return "", fmt.Errorf("timeout")
	}
}

// parseVersion extracts (major, minor, patch) from a version string.
func parseVersion(s string) [3]int {
	match := versionRegex.FindStringSubmatch(s)
	if match == nil {
		return [3]int{}
	}
	var v [3]int
	fmt.Sscanf(match[1], "%d", &v[0])
	fmt.Sscanf(match[2], "%d", &v[1])
	if len(match) > 3 && match[3] != "" {
		fmt.Sscanf(match[3], "%d", &v[2])
	}
	return v
}

// compareVersions returns -1, 0, or 1.
func compareVersions(a, b [3]int) int {
	for i := 0; i < 3; i++ {
		if a[i] < b[i] {
			return -1
		}
		if a[i] > b[i] {
			return 1
		}
	}
	return 0
}

// checkProjectRequirements checks if project-specific tools are available.
func checkProjectRequirements(cwd string) []string {
	if cwd == "" {
		return nil
	}

	var missing []string
	for _, req := range ProjectRequirements {
		if _, err := os.Stat(filepath.Join(cwd, req.ConfigFile)); err != nil {
			continue
		}
		for _, tool := range req.Tools {
			if _, err := exec.LookPath(tool); err != nil {
				missing = append(missing, tool+" (required by "+req.ConfigFile+")")
			}
		}
	}
	return missing
}

// installMissing auto-installs missing processor tools in background.
func installMissing(results []ToolResult) {
	for i, r := range results {
		if r.Available || !r.Optional {
			continue
		}
		// Find matching config with install command
		for _, tc := range ProcessorTools {
			if tc.Name == r.Name && len(tc.InstallCmd) > 0 {
				if _, err := exec.LookPath(tc.InstallCmd[0]); err == nil {
					cmd := exec.Command(tc.InstallCmd[0], tc.InstallCmd[1:]...)
					cmd.Stdout = nil
					cmd.Stderr = nil
					cmd.Start() // fire-and-forget
					// Mark so we can report
					results[i].Error = "installing"
				}
				break
			}
		}
	}
}

// formatReport builds the ANSI-formatted validation report.
func formatReport(results []ToolResult, projectMissing []string) (string, bool, []string) {
	var issues []string
	var installing []string

	for _, r := range results {
		if !r.Available && !r.Optional {
			issues = append(issues, fmt.Sprintf("%s%s %s: not found%s",
				ansi.BrightRed, ansi.IconCross, r.Name, ansi.Reset))
		} else if r.Available && !r.MeetsRequirement {
			issues = append(issues, fmt.Sprintf("%s%s %s: version outdated (%s)%s",
				ansi.BrightYellow, ansi.IconWarning, r.Name, r.Version, ansi.Reset))
		}
		if r.Error == "installing" {
			installing = append(installing, r.Name)
		}
	}

	for _, m := range projectMissing {
		issues = append(issues, fmt.Sprintf("%s%s %s%s",
			ansi.BrightCyan, ansi.IconFolder, m, ansi.Reset))
	}

	hasIssues := len(issues) > 0

	var sb strings.Builder
	if hasIssues {
		sb.WriteString(ansi.BrightYellow + ansi.IconWarning + " 環境檢查發現問題:" + ansi.Reset + "\n")
		limit := 5
		if len(issues) < limit {
			limit = len(issues)
		}
		sb.WriteString(strings.Join(issues[:limit], "\n"))
		if len(issues) > 5 {
			sb.WriteString(fmt.Sprintf("\n%s...還有 %d 個問題%s", ansi.Dim, len(issues)-5, ansi.Reset))
		}
	} else {
		sb.WriteString(ansi.BrightGreen + ansi.IconCheck + " 開發環境檢查通過" + ansi.Reset)
	}

	if len(installing) > 0 {
		sb.WriteString(fmt.Sprintf("\n%s%s 背景安裝中: %s%s",
			ansi.BrightMagenta, ansi.IconSync, strings.Join(installing, ", "), ansi.Reset))
	}

	return sb.String(), hasIssues, installing
}

// writeEnvVars writes PROJECT_NAME and SESSION_SOURCE to CLAUDE_ENV_FILE.
func writeEnvVars(cwd, source string) {
	envFile := os.Getenv("CLAUDE_ENV_FILE")
	if envFile == "" {
		return
	}

	projectName := filepath.Base(cwd)
	if cwd == "" {
		projectName = "unknown"
	}

	f, err := os.OpenFile(envFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()

	fmt.Fprintf(f, "export PROJECT_NAME='%s'\n", projectName)
	fmt.Fprintf(f, "export SESSION_SOURCE='%s'\n", source)
}

// logValidation logs validation results to env_validation.jsonl.
func logValidation(cwd, source, sessionID string, results []ToolResult, projectMissing []string) {
	if err := config.EnsureLogDir(); err != nil {
		return
	}

	entry := map[string]any{
		"timestamp":       time.Now().Format(time.RFC3339),
		"cwd":             cwd,
		"source":          source,
		"session_id":      sessionID,
		"tools":           results,
		"project_missing": projectMissing,
	}

	data, err := json.Marshal(entry)
	if err != nil {
		return
	}

	f, err := os.OpenFile(filepath.Join(config.LogDir, "env_validation.jsonl"),
		os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()
	f.Write(append(data, '\n'))
}
