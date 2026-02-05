// Package notify provides notification functionality via ntfy.
package notify

import (
	"os/exec"
)

const defaultTopic = "lizard"

// Send sends a notification via ntfy.
func Send(title, body string) error {
	return SendToTopic(defaultTopic, title, body)
}

// SendToTopic sends a notification to a specific ntfy topic.
func SendToTopic(topic, title, body string) error {
	cmd := exec.Command("ntfy", "publish", "--title", title, topic, body)
	return cmd.Run()
}

// SendSimple sends a simple notification without a title.
func SendSimple(body string) error {
	cmd := exec.Command("ntfy", "publish", defaultTopic, body)
	return cmd.Run()
}
