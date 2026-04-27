package userprompt

import "regexp"

// namedPatterns are regexes for credentials with well-known shapes.
// They run first so structured secrets are scrubbed cleanly even when
// shorter than the long-token threshold (e.g. AWS access keys are
// exactly 20 chars).
var namedPatterns = []*regexp.Regexp{
	regexp.MustCompile(`github_pat_[A-Za-z0-9_]{82}`),
	regexp.MustCompile(`gh[oprsu]_[A-Za-z0-9]{36,}`),
	regexp.MustCompile(`sk-ant-[A-Za-z0-9_-]{20,}`),
	regexp.MustCompile(`sk-[A-Za-z0-9_-]{20,}`),
	regexp.MustCompile(`AKIA[0-9A-Z]{16}`),
	regexp.MustCompile(`ASIA[0-9A-Z]{16}`),
	regexp.MustCompile(`AIza[0-9A-Za-z_-]{35}`),
	regexp.MustCompile(`xox[abprs]-[A-Za-z0-9-]{10,}`),
	regexp.MustCompile(`eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_.-]+(?:\.[A-Za-z0-9_-]*)?`),
	regexp.MustCompile(`(?s)-----BEGIN [A-Z ]*PRIVATE KEY[A-Z ]*-----.*?-----END [A-Z ]*PRIVATE KEY[A-Z ]*-----`),
}

func redactNamed(s string) string {
	for _, p := range namedPatterns {
		s = p.ReplaceAllString(s, "*****")
	}
	return s
}
