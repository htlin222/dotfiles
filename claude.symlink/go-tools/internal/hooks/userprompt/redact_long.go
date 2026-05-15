package userprompt

import (
	"regexp"
	"strings"
)

// longTokenRe matches a contiguous run of printable ASCII (no space)
// longer than 32 chars — the typical shape of a pasted API key or
// credential that did not match any of the named patterns above. CJK
// and other non-ASCII characters break the run, so unspaced Chinese
// prose is not mistaken for a credential.
var longTokenRe = regexp.MustCompile(`[!-~]{33,}`)

// hexHashRe matches a pure lowercase-hex SHA-1 (40 chars) or SHA-256
// (64 chars) digest. Caller exempts these so commit hashes and content
// hashes stay readable in prompts. MD5 (32 chars) falls below the
// long-token threshold and is not considered.
var hexHashRe = regexp.MustCompile(`^([0-9a-f]{40}|[0-9a-f]{64})$`)

func redactLongToken(s string) string {
	return longTokenRe.ReplaceAllStringFunc(s, func(m string) string {
		if r, ok := allowedLongToken(m); ok {
			return r
		}
		return "*****"
	})
}

// allowedLongToken decides whether a 33+ printable-ASCII run is benign.
// For HTTPS URLs it can return a partially-redacted form so the scheme,
// host, and path stay readable while embedded userinfo and query/fragment
// values are stripped. ok=false defers to the caller's blanket redaction.
func allowedLongToken(m string) (string, bool) {
	switch {
	case strings.HasPrefix(m, "https://"):
		return sanitizeHTTPSURL(m), true
	case hexHashRe.MatchString(m):
		return m, true
	case strings.HasPrefix(m, "/"),
		strings.HasPrefix(m, "~/"),
		strings.HasPrefix(m, "./"),
		strings.HasPrefix(m, "../"):
		if looksLikePath(m) {
			return m, true
		}
	}
	return "", false
}

// looksLikePath rejects long single-segment strings that happen to start
// with a path prefix (e.g. "/AAAAA…"). A real path has at least one
// internal separator or an extension dot inside its body.
func looksLikePath(m string) bool {
	body := m
	for _, p := range []string{"../", "./", "~/"} {
		if strings.HasPrefix(body, p) {
			body = body[len(p):]
			break
		}
	}
	body = strings.TrimPrefix(body, "/")
	return strings.ContainsAny(body, "/.")
}

// sanitizeHTTPSURL removes credentials from an HTTPS URL while keeping
// the scheme, host, and path readable. Userinfo (anything before @ in
// the authority) and the query/fragment (everything after the first ?
// or #) are replaced with *****.
func sanitizeHTTPSURL(m string) string {
	rest := m[len("https://"):]

	// Split authority from path/query/fragment.
	authEnd := strings.IndexAny(rest, "/?#")
	var authority, pathOnward string
	if authEnd == -1 {
		authority = rest
	} else {
		authority = rest[:authEnd]
		pathOnward = rest[authEnd:]
	}

	// Strip userinfo from authority.
	if at := strings.LastIndex(authority, "@"); at >= 0 {
		authority = "*****@" + authority[at+1:]
	}

	// Strip query and fragment values, keep the ?/# marker for readability.
	if q := strings.IndexAny(pathOnward, "?#"); q >= 0 {
		pathOnward = pathOnward[:q+1] + "*****"
	}

	return "https://" + authority + pathOnward
}
