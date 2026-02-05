package patterns

import (
	"regexp"
	"strings"
)

// SkillRule defines a skill suggestion rule.
type SkillRule struct {
	Keywords    []string
	Patterns    []*regexp.Regexp
	SkillName   string
	Suggestion  string
}

// SkillRules contains all skill auto-activation rules.
var SkillRules = []SkillRule{
	// Frontend Development
	{
		Keywords: []string{
			"component", "ui", "button", "form", "modal", "dialog",
			"css", "style", "tailwind", "react", "vue",
		},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)create.*(?:component|ui|button|form)`),
			regexp.MustCompile(`(?i)build.*(?:interface|page|layout)`),
		},
		SkillName:  "frontend-design",
		Suggestion: "建議使用 /frontend-design 來建立 UI 元件",
	},
	// Code Review
	{
		Keywords: []string{"review", "check", "審查", "檢查代碼"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)review.*(?:code|pr|pull)`),
			regexp.MustCompile(`(?i)check.*(?:quality|code)`),
		},
		SkillName:  "code-review",
		Suggestion: "建議使用 /code-review 進行程式碼審查",
	},
	// Feature Development
	{
		Keywords: []string{"feature", "implement", "功能", "實作"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:add|create|implement|build).*feature`),
			regexp.MustCompile(`新增.*功能`),
		},
		SkillName:  "feature-dev",
		Suggestion: "建議使用 /feature-dev 進行功能開發",
	},
	// Git Operations
	{
		Keywords: []string{"commit", "push", "merge", "branch", "rebase", "pr", "pull request"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:create|make).*(?:commit|pr|branch)`),
			regexp.MustCompile(`(?i)git.*(?:push|merge)`),
		},
		SkillName:  "git",
		Suggestion: "建議使用 /git 進行版本控制操作",
	},
	// Testing
	{
		Keywords: []string{"test", "testing", "spec", "e2e", "unit test", "測試"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:write|create|add).*test`),
			regexp.MustCompile(`(?i)run.*test`),
		},
		SkillName:  "test",
		Suggestion: "建議使用 /test 進行測試相關操作",
	},
	// Documentation
	{
		Keywords: []string{"document", "readme", "doc", "文件", "說明"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:write|create|update).*(?:doc|readme|documentation)`),
		},
		SkillName:  "document",
		Suggestion: "建議使用 /document 生成文件",
	},
	// Analysis
	{
		Keywords: []string{"analyze", "分析", "investigate", "debug", "troubleshoot"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:analyze|investigate|debug|find).*(?:issue|bug|problem|error)`),
		},
		SkillName:  "analyze",
		Suggestion: "建議使用 /analyze 進行深度分析",
	},
	// Build & Deploy
	{
		Keywords: []string{"build", "deploy", "ci", "cd", "pipeline", "docker"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:set up|create|configure).*(?:build|deploy|ci|cd|pipeline)`),
		},
		SkillName:  "build",
		Suggestion: "建議使用 /build 進行建置相關操作",
	},
	// Cleanup & Refactor
	{
		Keywords: []string{"cleanup", "refactor", "clean", "整理", "重構"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:cleanup|refactor|clean up|reorganize)`),
		},
		SkillName:  "cleanup",
		Suggestion: "建議使用 /cleanup 進行程式碼清理",
	},
	// Design & Architecture
	{
		Keywords: []string{"design", "architecture", "設計", "架構", "schema", "database"},
		Patterns: []*regexp.Regexp{
			regexp.MustCompile(`(?i)(?:design|architect|plan).*(?:system|api|database|schema)`),
		},
		SkillName:  "design",
		Suggestion: "建議使用 /design 進行系統設計",
	},
}

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

// ComplexTaskPatterns are patterns that suggest using Task delegation.
var ComplexTaskPatterns = []*regexp.Regexp{
	regexp.MustCompile(`(?i)multiple files`),
	regexp.MustCompile(`(?i)all .*files`),
	regexp.MustCompile(`(?i)every .*file`),
	regexp.MustCompile(`(?i)across the codebase`),
	regexp.MustCompile(`(?i)throughout the project`),
	regexp.MustCompile(`(?i)refactor.*(?:module|component|system)`),
	regexp.MustCompile(`(?i)fix.*(?:all|every|multiple)`),
	regexp.MustCompile(`(?i)update.*(?:all|every|multiple)`),
	regexp.MustCompile(`(?i)change.*(?:all|every|multiple)`),
	regexp.MustCompile(`(?i)(?:10|20|50|100)\+?\s*(?:files|changes|edits)`),
	regexp.MustCompile(`(?i)batch.*(?:edit|update|fix)`),
	regexp.MustCompile(`(?i)mass.*(?:edit|update|rename)`),
	regexp.MustCompile(`全部|所有.*檔案|多個.*檔案|批次`),
}

// BashSearchPattern represents a bash search pattern.
type BashSearchPattern struct {
	Pattern    *regexp.Regexp
	NativeTool string
}

// BashSearchPatterns contains patterns for bash search commands.
var BashSearchPatterns = []BashSearchPattern{
	{regexp.MustCompile(`\bgrep\b`), "Grep"},
	{regexp.MustCompile(`\brg\b`), "Grep"},
	{regexp.MustCompile(`\bripgrep\b`), "Grep"},
	{regexp.MustCompile(`\bfind\s+[./-]`), "Glob"},
	{regexp.MustCompile(`\bls\s+-`), "Bash(ls) or Glob"},
	{regexp.MustCompile(`\bcat\s+`), "Read"},
	{regexp.MustCompile(`\bhead\s+`), "Read with limit"},
	{regexp.MustCompile(`\btail\s+`), "Read with offset"},
}

// SuggestSkill returns a skill suggestion based on the prompt.
func SuggestSkill(prompt string) string {
	promptLower := strings.ToLower(prompt)

	for _, rule := range SkillRules {
		// Skip if prompt already mentions the skill
		if strings.Contains(promptLower, "/"+rule.SkillName) {
			continue
		}

		// Check keywords
		keywordMatch := false
		for _, kw := range rule.Keywords {
			if strings.Contains(promptLower, strings.ToLower(kw)) {
				keywordMatch = true
				break
			}
		}

		// Check patterns
		patternMatch := false
		for _, pattern := range rule.Patterns {
			if pattern.MatchString(promptLower) {
				patternMatch = true
				break
			}
		}

		if keywordMatch || patternMatch {
			return rule.Suggestion
		}
	}

	return ""
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

// CheckComplexTask checks for complex tasks that should be delegated.
func CheckComplexTask(prompt string) bool {
	promptLower := strings.ToLower(prompt)
	for _, pattern := range ComplexTaskPatterns {
		if pattern.MatchString(promptLower) {
			return true
		}
	}
	return false
}

// CheckToolEfficiency checks for bash search commands that should use native tools.
func CheckToolEfficiency(prompt string) string {
	promptLower := strings.ToLower(prompt)
	for _, bp := range BashSearchPatterns {
		if bp.Pattern.MatchString(promptLower) {
			return bp.NativeTool
		}
	}
	return ""
}
