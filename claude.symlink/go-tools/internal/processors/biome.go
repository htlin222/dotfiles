package processors

import (
	"fmt"
	"os/exec"
	"strings"
)

// BiomeProcessor handles JavaScript/TypeScript/CSS/JSON files with Biome.
type BiomeProcessor struct{}

func (p *BiomeProcessor) Extensions() []string {
	return []string{".js", ".jsx", ".ts", ".tsx", ".json", ".css"}
}

func (p *BiomeProcessor) Process(filePath string) (bool, string) {
	if !commandExists("biome") {
		return true, ""
	}

	cmd := exec.Command("biome", "check", filePath)
	output, err := cmd.CombinedOutput()

	if err != nil {
		// Biome found issues
		return false, fmt.Sprintf("✨ %s: Biome 發現問題:\n%s", filePath, strings.TrimSpace(string(output)))
	}

	return true, fmt.Sprintf("✅ %s: Biome checks passed", filePath)
}
