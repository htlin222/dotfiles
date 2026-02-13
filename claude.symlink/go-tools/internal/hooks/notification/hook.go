// Package notification implements the Notification hook.
// Plays a sound and sends ntfy when Claude needs user attention.
package notification

import (
	"encoding/json"
	"io"
	"os"
	"strings"

	"github.com/htlin/claude-tools/pkg/notify"
)

// Run executes the notification hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		return
	}

	var data struct {
		Message   string `json:"message,omitempty"`
		SessionID string `json:"session_id,omitempty"`
	}
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	msg := data.Message
	if msg == "" {
		msg = "需要你的注意"
	}

	notify.Send("Claude Code 🔔", msg)
}
