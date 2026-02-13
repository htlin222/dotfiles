// Package notify provides notification functionality via ntfy.
package notify

import (
	"os/exec"
	"runtime"
)

const defaultTopic = "lizard"

// Send sends a notification via ntfy + sound (fire-and-forget).
func Send(title, body string) error {
	playSound()
	return SendToTopic(defaultTopic, title, body)
}

// SendToTopic sends a notification to a specific ntfy topic (fire-and-forget).
func SendToTopic(topic, title, body string) error {
	cmd := exec.Command("ntfy", "publish", "--title", title, topic, body)
	return cmd.Start()
}

// SendSimple sends a simple notification without a title (fire-and-forget).
func SendSimple(body string) error {
	playSound()
	cmd := exec.Command("ntfy", "publish", defaultTopic, body)
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
