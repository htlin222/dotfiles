package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// ESLintProcessor handles JavaScript/TypeScript with ESLint.
type ESLintProcessor struct{}

func (p *ESLintProcessor) Extensions() []string {
	return []string{".js", ".jsx", ".ts", ".tsx"}
}

func (p *ESLintProcessor) Process(filePath string) (bool, string) {
	if !commandExists("eslint") {
		return true, ""
	}

	cmd := exec.Command("eslint", "--no-error-on-unmatched-pattern", filePath)
	output, err := cmd.CombinedOutput()

	if err != nil {
		return false, fmt.Sprintf("📋 %s: ESLint issues:\n%s", filePath, strings.TrimSpace(string(output)))
	}

	return true, fmt.Sprintf("✅ %s: ESLint checks passed", filePath)
}
