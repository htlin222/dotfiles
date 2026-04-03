// Package notify provides notification functionality via ntfy.
package notify

import (
	"os"
	"os/exec"
	"runtime"
)

const fallbackTopic = "3efa6497d3b3"

func topic() string {
	if t := os.Getenv("NTFY_TOPIC"); t != "" {
		return t
	}
	return fallbackTopic
}

// Send sends a notification via ntfy + sound (fire-and-forget).
func Send(title, body string) error {
	playSound()
	return SendToTopic(topic(), title, body)
}

// SendToTopic sends a notification to a specific ntfy topic (fire-and-forget).
func SendToTopic(t, title, body string) error {
	cmd := exec.Command("ntfy", "publish", "--markdown", "--title", title, t, body)
	return cmd.Start()
}

// SendSimple sends a simple notification without a title (fire-and-forget).
func SendSimple(body string) error {
	playSound()
	cmd := exec.Command("ntfy", "publish", "--markdown", topic(), body)
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
