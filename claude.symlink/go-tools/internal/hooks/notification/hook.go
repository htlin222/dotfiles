// Package notification implements the Notification hook.
// Plays a sound and sends ntfy when Claude needs user attention.
package notification

import (
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/htlin/claude-tools/pkg/notify"
)

const (
	tailReadBytes = 64 * 1024
	tailSnippet   = 80
)

// Run executes the notification hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		return
	}

	var data struct {
		Message        string `json:"message,omitempty"`
		SessionID      string `json:"session_id,omitempty"`
		CWD            string `json:"cwd,omitempty"`
		TranscriptPath string `json:"transcript_path,omitempty"`
	}
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	msg := data.Message
	if msg == "" {
		msg = "需要你的注意"
	}

	title := "🔔"
	if proj := projectLabel(data.CWD); proj != "" {
		title = "🔔 " + proj
	}

	if isWaiting(msg) && data.TranscriptPath != "" {
		if tail := lastAssistantText(data.TranscriptPath); tail != "" {
			msg = msg + "\n➜ " + tail
		}
	}

	notify.Send(title, msg)
}

func projectLabel(cwd string) string {
	if cwd == "" {
		return ""
	}
	return filepath.Base(cwd)
}

// isWaiting returns true when the message looks like the generic idle
// prompt Claude Code emits while waiting for the user's next turn (as
// opposed to a tool-permission request, which is already informative).
func isWaiting(msg string) bool {
	m := strings.ToLower(msg)
	return strings.Contains(m, "waiting for your input") ||
		strings.Contains(m, "waiting for input") ||
		strings.Contains(m, "needs your attention") ||
		strings.Contains(m, "idle")
}

// lastAssistantText reads the tail of a transcript JSONL and returns
// the most recent assistant-emitted text block, trimmed and truncated
// to a one-line snippet. Returns empty string on any failure or when
// no text block is found in the tail window.
func lastAssistantText(path string) string {
	f, err := os.Open(path)
	if err != nil {
		return ""
	}
	defer f.Close()

	info, err := f.Stat()
	if err != nil {
		return ""
	}

	size := info.Size()
	offset := int64(0)
	readLen := size
	if size > tailReadBytes {
		offset = size - tailReadBytes
		readLen = tailReadBytes
	}

	buf := make([]byte, readLen)
	if _, err := f.ReadAt(buf, offset); err != nil && err != io.EOF {
		return ""
	}

	lines := strings.Split(string(buf), "\n")
	// Walk from end so we find the most recent assistant text first.
	for i := len(lines) - 1; i >= 0; i-- {
		line := strings.TrimSpace(lines[i])
		if line == "" {
			continue
		}
		text := extractAssistantText(line)
		if text != "" {
			return condense(text)
		}
	}
	return ""
}

// extractAssistantText parses a single JSONL line and returns the last
// "text"-typed content block from an assistant message. Anything that
// isn't a well-formed assistant turn returns "".
func extractAssistantText(line string) string {
	var entry struct {
		Type    string `json:"type"`
		Message struct {
			Role    string `json:"role"`
			Content json.RawMessage `json:"content"`
		} `json:"message"`
	}
	if err := json.Unmarshal([]byte(line), &entry); err != nil {
		return ""
	}
	if entry.Type != "assistant" {
		return ""
	}

	// Content can be a plain string or an array of typed blocks.
	var asString string
	if err := json.Unmarshal(entry.Message.Content, &asString); err == nil {
		return asString
	}

	var blocks []struct {
		Type string `json:"type"`
		Text string `json:"text"`
	}
	if err := json.Unmarshal(entry.Message.Content, &blocks); err != nil {
		return ""
	}
	for i := len(blocks) - 1; i >= 0; i-- {
		if blocks[i].Type == "text" && strings.TrimSpace(blocks[i].Text) != "" {
			return blocks[i].Text
		}
	}
	return ""
}

// condense collapses whitespace and truncates to a single-line snippet
// suitable for a notification body.
func condense(s string) string {
	s = strings.TrimSpace(s)
	// Take the last non-empty line so the snippet shows the closing
	// question/sentence rather than the opening of a long answer.
	parts := strings.Split(s, "\n")
	for i := len(parts) - 1; i >= 0; i-- {
		if t := strings.TrimSpace(parts[i]); t != "" {
			s = t
			break
		}
	}
	s = strings.Join(strings.Fields(s), " ")
	if len(s) > tailSnippet {
		// Truncate on a rune boundary so we don't slice a multi-byte char.
		r := []rune(s)
		if len(r) > tailSnippet {
			r = r[:tailSnippet]
			s = string(r) + "…"
		}
	}
	return s
}
