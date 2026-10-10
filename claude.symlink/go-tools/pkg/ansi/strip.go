package ansi

import "regexp"

// escapeSeq matches CSI sequences (colors, cursor moves) and OSC sequences
// (e.g. hyperlinks) terminated by BEL or ST.
var escapeSeq = regexp.MustCompile(`\x1b\[[0-?]*[ -/]*[@-~]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)`)

// Strip removes ANSI escape sequences, for text that reaches the model or
// a plain-text UI field (systemMessage, permissionDecisionReason, …).
func Strip(s string) string {
	return escapeSeq.ReplaceAllString(s, "")
}
