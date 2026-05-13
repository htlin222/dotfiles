// Package notify shows local macOS banners and plays sounds.
//
// All paths are macOS-specific (osascript / afplay / say). Notification
// delivery is local-only — no ntfy publish, no topic ID, no network.
// Non-darwin platforms get a silent no-op so callers don't have to
// branch.
package notify

import (
	"fmt"
	"os/exec"
	"runtime"
	"strings"
)

// Send shows a banner with a title (fire-and-forget).
func Send(title, body string) error {
	playSound()
	macDisplayNotification(title, body)
	return nil
}

// SendToTopic kept for source compatibility; topic is ignored. Same
// behavior as Send.
func SendToTopic(_, title, body string) error {
	return Send(title, body)
}

// SendSimple shows a titleless banner (fire-and-forget).
func SendSimple(body string) error {
	playSound()
	macDisplayNotification("", body)
	return nil
}

// playSound plays a notification sound (fire-and-forget, macOS only).
func playSound() {
	if runtime.GOOS != "darwin" {
		return
	}
	cmd := exec.Command("afplay", "/System/Library/Sounds/Submarine.aiff")
	cmd.Start()
}

// Say speaks text via macOS TTS (fire-and-forget).
func Say(text string) {
	if runtime.GOOS != "darwin" || text == "" {
		return
	}
	cmd := exec.Command("say", "-v", "Samantha", text)
	cmd.Start()
}

// macDisplayNotification shows a native macOS banner via osascript.
// No-op on other platforms. Fire-and-forget; failures are silent.
func macDisplayNotification(title, body string) {
	if runtime.GOOS != "darwin" {
		return
	}
	script := fmt.Sprintf(
		"display notification %s with title %s",
		appleScriptString(body),
		appleScriptString(title),
	)
	cmd := exec.Command("osascript", "-e", script)
	cmd.Start()
}

// appleScriptString escapes a Go string into a quoted AppleScript
// literal. AppleScript shares Go's two key escapes (\\ and \"), so
// quoting is just replacing those plus wrapping in double quotes.
func appleScriptString(s string) string {
	s = strings.ReplaceAll(s, `\`, `\\`)
	s = strings.ReplaceAll(s, `"`, `\"`)
	return `"` + s + `"`
}
