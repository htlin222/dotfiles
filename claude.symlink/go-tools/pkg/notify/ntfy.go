// Package notify provides notification functionality via ntfy.
package notify

import (
	"os"
	"os/exec"
	"runtime"
)

func topic() string {
	return os.Getenv("NTFY_TOPIC")
}

// Send sends a notification via ntfy + sound (fire-and-forget).
// No-op for ntfy when NTFY_TOPIC is unset; sound still plays.
func Send(title, body string) error {
	return SendWithTags(title, body, "")
}

// SendWithTags sends a notification via ntfy + sound with comma-separated
// tags (fire-and-forget). Known emoji shortcodes (e.g. "file_folder") render
// as emojis; other values render as labels beneath the message.
// No-op for ntfy when NTFY_TOPIC is unset; sound still plays.
func SendWithTags(title, body, tags string) error {
	playSound()
	t := topic()
	if t == "" {
		return nil
	}
	args := []string{"publish", "--markdown", "--title", title}
	if tags != "" {
		args = append(args, "--tags", tags)
	}
	args = append(args, t, body)
	return exec.Command("ntfy", args...).Start()
}

// SendToTopic sends a notification to a specific ntfy topic (fire-and-forget).
func SendToTopic(t, title, body string) error {
	cmd := exec.Command("ntfy", "publish", "--markdown", "--title", title, t, body)
	return cmd.Start()
}

// SendSimple sends a simple notification without a title (fire-and-forget).
// No-op for ntfy when NTFY_TOPIC is unset; sound still plays.
func SendSimple(body string) error {
	playSound()
	t := topic()
	if t == "" {
		return nil
	}
	cmd := exec.Command("ntfy", "publish", "--markdown", t, body)
	return cmd.Start()
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
