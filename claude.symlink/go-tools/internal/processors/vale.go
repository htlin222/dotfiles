package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// ValeProcessor handles prose linting with Vale.
type ValeProcessor struct{}

func (p *ValeProcessor) Extensions() []string {
	return []string{".md", ".mdx", ".txt"}
}

func (p *ValeProcessor) Process(filePath string) (bool, string) {
	if !commandExists("vale") {
		return true, ""
	}

	cmd := exec.Command("vale", filePath)
	output, err := cmd.CombinedOutput()

	if err != nil {
		return false, fmt.Sprintf("Vale found issues in %s:\n%s", filePath, strings.TrimSpace(string(output)))
	}

	return true, fmt.Sprintf("📝 Vale check passed for %s", filePath)
}
