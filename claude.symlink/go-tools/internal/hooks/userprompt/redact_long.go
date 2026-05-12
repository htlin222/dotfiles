package userprompt

import (
	"regexp"
	"strings"
)

// longTokenRe matches a contiguous run of non-whitespace longer than 32
// chars — the typical shape of a pasted API key or credential that did
// not match any of the named patterns above.
var longTokenRe = regexp.MustCompile(`\S{33,}`)

func redactLongToken(s string) string {
	return longTokenRe.ReplaceAllStringFunc(s, func(m string) string {
		if isAllowedLongToken(m) {
			return m
		}
		return "*****"
	})
}

// isAllowedLongToken returns true for shapes that are almost never
// credentials but commonly exceed the 32-char threshold: https:// URLs
// and filesystem paths (absolute, home-relative, or explicitly relative).
func isAllowedLongToken(m string) bool {
	switch {
	case strings.HasPrefix(m, "https://"):
		return true
	case strings.HasPrefix(m, "/"):
		return true
	case strings.HasPrefix(m, "~/"):
		return true
	case strings.HasPrefix(m, "./"):
		return true
	case strings.HasPrefix(m, "../"):
		return true
	}
	return false
}
