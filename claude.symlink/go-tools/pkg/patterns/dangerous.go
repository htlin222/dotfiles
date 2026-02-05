package patterns

import "regexp"

// DangerousPattern represents a dangerous command pattern.
type DangerousPattern struct {
	Pattern *regexp.Regexp
	Warning string
}

// DangerousPatterns contains patterns for dangerous commands.
var DangerousPatterns = []DangerousPattern{
	{regexp.MustCompile(`rm\s+-rf\s+[/~]`), "危險：嘗試刪除根目錄或家目錄"},
	{regexp.MustCompile(`rm\s+-rf\s+\*`), "危險：嘗試刪除所有檔案"},
	{regexp.MustCompile(`:\(\)\{\s*:\|:&\s*\};:`), "危險：Fork bomb 偵測"},
	{regexp.MustCompile(`mkfs\.`), "危險：格式化磁碟指令"},
	{regexp.MustCompile(`dd\s+if=.+of=/dev/`), "危險：覆寫磁碟指令"},
	{regexp.MustCompile(`>\s*/dev/sda`), "危險：覆寫磁碟"},
	{regexp.MustCompile(`chmod\s+-R\s+777\s+/`), "危險：開放所有權限"},
}

// RmPatterns are patterns to detect rm commands (for check_rm hook).
var RmPatterns = []*regexp.Regexp{
	regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*rm\s`),         // rm at command position
	regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*sudo\s+rm\s`),  // sudo rm
	regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*\\rm\s`),       // \rm (alias bypass)
	regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*command\s+rm\s`), // command rm
	regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*/bin/rm\s`),    // /bin/rm (direct path)
	regexp.MustCompile(`(?:^|&&|\|\||;|\|)\s*/usr/bin/rm\s`), // /usr/bin/rm
}

// CheckDangerousPatterns checks if a prompt contains dangerous patterns.
// Returns the warning message if found, empty string otherwise.
func CheckDangerousPatterns(prompt string) string {
	for _, dp := range DangerousPatterns {
		if dp.Pattern.MatchString(prompt) {
			return dp.Warning
		}
	}
	return ""
}

// IsRmCommand checks if a command contains an rm invocation.
func IsRmCommand(command string) bool {
	for _, pattern := range RmPatterns {
		if pattern.MatchString(command) {
			return true
		}
	}
	return false
}

// RiskyCodePattern represents a risky code pattern to detect.
type RiskyCodePattern struct {
	Pattern     *regexp.Regexp
	Description string
	Severity    string // "high", "medium", "low"
}

// RiskyCodePatterns contains patterns for risky code.
var RiskyCodePatterns = []RiskyCodePattern{
	// Note: Go doesn't support negative lookbehind, so we use simpler patterns
	// Async function detection (simplified)
	{
		regexp.MustCompile(`async\s+(?:function|def)\s+\w+`),
		"Async 函數可能缺少 try-catch",
		"medium",
	},
	// Hardcoded credentials
	{
		regexp.MustCompile(`(?i)(?:password|secret|api_key|apikey|token)\s*[=:]\s*["'][^"']{8,}["']`),
		"可能的硬編碼憑證",
		"high",
	},
	// Direct SQL queries (SQL injection risk) - simplified
	{
		regexp.MustCompile(`(?i)(?:execute|query)\s*\(\s*f["']`),
		"可能的 SQL 注入風險",
		"high",
	},
	// eval/exec usage
	{
		regexp.MustCompile(`\b(?:eval|exec)\s*\(`),
		"使用 eval/exec 有安全風險",
		"high",
	},
	// Console.log in production code
	{
		regexp.MustCompile(`console\.log\s*\(`),
		"殘留 console.log",
		"low",
	},
	// TODO/FIXME comments
	{
		regexp.MustCompile(`(?://|#)\s*(?:TODO|FIXME|XXX|HACK):`),
		"未完成的 TODO/FIXME",
		"low",
	},
	// Disabled eslint/type checks
	{
		regexp.MustCompile(`(?:eslint-disable|@ts-ignore|@ts-nocheck|type:\s*ignore|noqa)`),
		"停用的 lint/type 檢查",
		"medium",
	},
}

// DetectRiskyPatterns scans content for risky code patterns.
func DetectRiskyPatterns(content string, isTestFile bool) []RiskyCodePattern {
	var findings []RiskyCodePattern
	for _, pattern := range RiskyCodePatterns {
		// Skip console.log detection for test files
		if pattern.Description == "殘留 console.log" && isTestFile {
			continue
		}
		if pattern.Pattern.MatchString(content) {
			findings = append(findings, pattern)
		}
	}
	return findings
}
