package userprompt

import "regexp"

// kvPattern is a key/value heuristic: a known secret-name keyword
// followed by a separator and a value, where only the value is
// replaced. The keyword stays visible so the redacted prompt is still
// readable in logs ("password=*****" rather than "*****=*****").
type kvPattern struct {
	re     *regexp.Regexp
	redact func([]string) string
}

var kvPatterns = []kvPattern{
	{
		// password=hunter2  /  api_key: "abc"  /  token = '...'
		re: regexp.MustCompile(
			`(?i)\b(password|passwd|pwd|secret|token|api[_-]?key|access[_-]?key|secret[_-]?key|credential)(\s*[:=]\s*)(?:"[^"]*"|'[^']*'|\S+)`,
		),
		redact: func(m []string) string { return m[1] + m[2] + "*****" },
	},
	{
		// Authorization: Bearer xyz  /  bearer xyz  /  basic dXNlcjpwYXNz
		re: regexp.MustCompile(`(?i)\b(bearer|basic)(\s+)([A-Za-z0-9._=+/-]+)`),
		redact: func(m []string) string { return m[1] + m[2] + "*****" },
	},
}

func redactKV(s string) string {
	for _, p := range kvPatterns {
		re := p.re
		fn := p.redact
		s = re.ReplaceAllStringFunc(s, func(match string) string {
			return fn(re.FindStringSubmatch(match))
		})
	}
	return s
}
