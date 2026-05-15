package userprompt

import "regexp"

// braceRe matches a non-nested {...} group. Applied iteratively so
// nested groups collapse inside-out: { { secret } } -> { **** } -> ****.
var braceRe = regexp.MustCompile(`\{[^{}]*\}`)

func redactBraces(s string) string {
	for {
		next := braceRe.ReplaceAllString(s, "****")
		if next == s {
			return s
		}
		s = next
	}
}
