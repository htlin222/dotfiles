package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// LintrProcessor handles R files with lintr.
type LintrProcessor struct{}

func (p *LintrProcessor) Extensions() []string {
	return []string{".R", ".r"}
}

func (p *LintrProcessor) Process(filePath string) (bool, string) {
	if !commandExists("Rscript") {
		return true, ""
	}

	// Run lintr via Rscript
	cmd := exec.Command("Rscript", "-e", fmt.Sprintf("lintr::lint('%s')", filePath))
	output, err := cmd.CombinedOutput()

	outputStr := strings.TrimSpace(string(output))
	if err != nil || outputStr != "" {
		return false, fmt.Sprintf("📊 %s: R linting issues:\n%s", filePath, outputStr)
	}

	return true, fmt.Sprintf("✅ %s: R checks passed", filePath)
}
