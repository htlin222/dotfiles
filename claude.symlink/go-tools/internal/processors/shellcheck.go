package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// ShellcheckProcessor handles shell scripts with ShellCheck.
type ShellcheckProcessor struct{}

func (p *ShellcheckProcessor) Extensions() []string {
	return []string{".sh", ".bash"}
}

func (p *ShellcheckProcessor) Process(filePath string) (bool, string) {
	if !commandExists("shellcheck") {
		return true, ""
	}

	cmd := exec.Command("shellcheck", filePath)
	output, err := cmd.CombinedOutput()

	if err != nil {
		return false, fmt.Sprintf("🐚 %s: ShellCheck issues:\n%s", filePath, strings.TrimSpace(string(output)))
	}

	return true, fmt.Sprintf("✅ %s: ShellCheck passed", filePath)
}
