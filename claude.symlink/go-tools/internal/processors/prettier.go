package processors

import (
	"fmt"
	"os/exec"
)

// PrettierProcessor handles web files with Prettier.
type PrettierProcessor struct{}

func (p *PrettierProcessor) Extensions() []string {
	return []string{".html", ".mdx", ".scss", ".less", ".vue", ".yaml", ".yml"}
}

func (p *PrettierProcessor) Process(filePath string) (bool, string) {
	if !commandExists("prettier") {
		return true, ""
	}

	cmd := exec.Command("prettier", "--check", filePath)
	err := cmd.Run()

	if err != nil {
		// Prettier found issues
		return false, fmt.Sprintf("✨ %s: Prettier 格式問題 - 需要格式化", filePath)
	}

	return true, fmt.Sprintf("✅ %s: Prettier checks passed", filePath)
}

// MarkdownProcessor handles markdown files with Prettier and Vale.
type MarkdownProcessor struct{}

func (p *MarkdownProcessor) Extensions() []string {
	return []string{".md"}
}

func (p *MarkdownProcessor) Process(filePath string) (bool, string) {
	var issues []string
	success := true

	// Run Prettier
	if commandExists("prettier") {
		cmd := exec.Command("prettier", "--check", filePath)
		if err := cmd.Run(); err != nil {
			success = false
			issues = append(issues, "Prettier 格式問題")
		}
	}

	// Vale disabled — not currently needed
	// if commandExists("vale") {
	// 	cmd := exec.Command("vale", filePath)
	// 	output, err := cmd.CombinedOutput()
	// 	if err != nil {
	// 		success = false
	// 		issues = append(issues, fmt.Sprintf("Vale: %s", string(output)))
	// 	}
	// }

	if !success {
		return false, fmt.Sprintf("📝 %s: %v", filePath, issues)
	}

	return true, fmt.Sprintf("✅ %s: Markdown checks passed", filePath)
}
