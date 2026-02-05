package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// RuffProcessor handles Python files with Ruff.
type RuffProcessor struct{}

func (p *RuffProcessor) Extensions() []string {
	return []string{".py", ".pyi"}
}

func (p *RuffProcessor) Process(filePath string) (bool, string) {
	if !commandExists("ruff") {
		return true, ""
	}

	var issues []string

	// Run Ruff format check
	cmd := exec.Command("ruff", "format", "--check", filePath)
	if err := cmd.Run(); err != nil {
		issues = append(issues, "格式問題")
	}

	// Run Ruff lint check
	cmd = exec.Command("ruff", "check", filePath)
	output, err := cmd.CombinedOutput()
	if err != nil {
		issues = append(issues, fmt.Sprintf("Lint: %s", strings.TrimSpace(string(output))))
	}

	if len(issues) > 0 {
		return false, fmt.Sprintf("🐍 %s: %s", filePath, strings.Join(issues, "; "))
	}

	return true, fmt.Sprintf("✅ %s: Ruff checks passed", filePath)
}
