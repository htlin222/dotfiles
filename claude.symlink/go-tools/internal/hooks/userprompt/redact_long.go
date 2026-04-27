package userprompt

import "regexp"

// longTokenRe matches a contiguous run of non-whitespace longer than 32
// chars — the typical shape of a pasted API key or credential that did
// not match any of the named patterns above.
var longTokenRe = regexp.MustCompile(`\S{33,}`)

func redactLongToken(s string) string {
	return longTokenRe.ReplaceAllString(s, "*****")
}
