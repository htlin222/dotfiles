package userprompt

// Result is the outcome of running RedactSecrets on a prompt.
//
// Triggered/RuleHits exist so callers can fail-closed: if any rule fired,
// the row should be diverted to a local-only quarantine sink instead of
// the cloud-syncable libSQL replica. Even after redaction, "something
// matched" is treated as a signal that this prompt may still carry data
// the user does not want leaving the device.
type Result struct {
	Text      string
	Triggered bool
	RuleHits  []string
}

// rule is one named transformation step. Order is significant — see the
// registry below.
type rule struct {
	name  string
	apply func(string) string
}

// rules runs in order, most-specific first. Named-secret patterns and
// the key=value heuristic catch structured credentials before the
// catch-all brace and long-token rules nuke anything that's left.
var rules = []rule{
	{"named", redactNamed},
	{"kv", redactKV},
	{"braces", redactBraces},
	{"long-token", redactLongToken},
}

// RedactSecrets scrubs likely credentials from a prompt before it is
// mirrored to local logs or the libSQL replica. The original prompt is
// still sent to Claude — only the persisted copy goes through here.
func RedactSecrets(s string) Result {
	out := s
	var hits []string
	for _, r := range rules {
		next := r.apply(out)
		if next != out {
			hits = append(hits, r.name)
			out = next
		}
	}
	return Result{Text: out, Triggered: len(hits) > 0, RuleHits: hits}
}
