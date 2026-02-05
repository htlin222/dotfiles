package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// BibtexProcessor handles BibTeX files with bibtex-tidy.
type BibtexProcessor struct{}

func (p *BibtexProcessor) Extensions() []string {
	return []string{".bib"}
}

func (p *BibtexProcessor) Process(filePath string) (bool, string) {
	if !commandExists("bibtex-tidy") {
		return true, ""
	}

	// Run bibtex-tidy in check mode
	cmd := exec.Command("bibtex-tidy", "--check", filePath)
	output, err := cmd.CombinedOutput()

	if err != nil {
		return false, fmt.Sprintf("📚 %s: BibTeX issues:\n%s", filePath, strings.TrimSpace(string(output)))
	}

	return true, fmt.Sprintf("✅ %s: BibTeX checks passed", filePath)
}
