package userprompt

import (
	"encoding/json"
	"os"
	"path/filepath"
	"time"
)

// quarantinePath is the local-only sink for prompts where redaction
// fired. It is intentionally not the libSQL replica DB so a row that
// might still carry a residual secret cannot reach Turso cloud. The
// prompt itself is NOT blocked — the user's turn still reaches the
// model with its original content; only the mirror copy is diverted
// here for audit.
func quarantinePath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".claude", "state", "prompts-quarantine.jsonl")
}

// appendQuarantine writes one JSONL entry with the redacted prompt and
// the names of the rules that fired. Best-effort — failures are
// silenced like the rest of the capture pipeline.
func appendQuarantine(prompt, sessionID, cwd string, hits []string) {
	p := quarantinePath()
	if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
		return
	}
	f, err := os.OpenFile(p, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o600)
	if err != nil {
		return
	}
	defer f.Close()

	entry := map[string]any{
		"ts":         time.Now().Format(time.RFC3339Nano),
		"session_id": sessionID,
		"cwd":        cwd,
		"rules":      hits,
		"prompt":     prompt,
	}
	b, err := json.Marshal(entry)
	if err != nil {
		return
	}
	_, _ = f.Write(b)
	_, _ = f.Write([]byte("\n"))
}
