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
	playSound()
	t := topic()
	if t == "" {
		return nil
	}
	return SendToTopic(t, title, body)
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
