package patterns

import (
	"regexp"
	"strings"
)

// TokenHeavyPattern represents a token-heavy request pattern.
type TokenHeavyPattern struct {
	Pattern *regexp.Regexp
	Warning string
}

// TokenHeavyPatterns contains patterns for potentially expensive requests.
var TokenHeavyPatterns = []TokenHeavyPattern{
	{regexp.MustCompile(`(?i)整個專案|entire project|whole codebase|all files`), "整個專案操作可能消耗大量 tokens"},
	{regexp.MustCompile(`(?i)所有檔案|every file|each file`), "處理所有檔案可能消耗大量 tokens"},
	{regexp.MustCompile(`(?i)重構整個|refactor all|refactor entire`), "大規模重構可能消耗大量 tokens，建議分階段進行"},
	{regexp.MustCompile(`(?i)完整分析|full analysis|comprehensive review`), "完整分析可能消耗大量 tokens，建議分階段進行"},
	{regexp.MustCompile(`(?i)從頭開始|from scratch|start over`), "從頭開始可能消耗大量 tokens"},
}

// CheckTokenHeavy checks for potentially token-heavy requests.
func CheckTokenHeavy(prompt string) string {
	promptLower := strings.ToLower(prompt)
	for _, th := range TokenHeavyPatterns {
		if th.Pattern.MatchString(promptLower) {
			return th.Warning
		}
	}
	return ""
}
