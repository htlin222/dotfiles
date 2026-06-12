// Package notify shows local macOS banners and optionally pushes the
// same message to a remote ntfy topic for phone delivery.
//
// Local macOS path: osascript display notification. The banner shows
// only title + body, no topic ID. Always runs on darwin.
//
// Remote ntfy path: `ntfy publish` to the topic in $NTFY_TOPIC. Only
// runs when that env var is set, so a private topic value never lives
// in the source tree. Failures are silent and fire-and-forget.
package notify

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"github.com/htlin/claude-tools/pkg/elevenlabs"
)

func topic() string {
	return os.Getenv("NTFY_TOPIC")
}

// ntfyCmd builds an ntfy command with NTFY_TOPIC stripped from the child
// environment. The ntfy CLI reads $NTFY_TOPIC as the topic and, when set,
// treats ALL positional args as the message — so our explicit topic arg
// would be folded into the body ("<topic> <message>").
func ntfyCmd(args ...string) *exec.Cmd {
	cmd := exec.Command("ntfy", args...)
	var env []string
	for _, e := range os.Environ() {
		if !strings.HasPrefix(e, "NTFY_TOPIC=") {
			env = append(env, e)
		}
	}
	cmd.Env = env
	return cmd
}

// Send shows a local banner and, if $NTFY_TOPIC is set, also publishes
// to that topic for remote (phone) delivery (fire-and-forget).
func Send(title, body string) error {
	return SendWithTags(title, body, "")
}

// SendWithTags shows a local banner and publishes to ntfy with comma-separated
// tags (fire-and-forget). Known emoji shortcodes (e.g. "file_folder") render
// as emojis; other values render as labels beneath the message.
// No-op for ntfy when NTFY_TOPIC is unset; local banner still shows.
func SendWithTags(title, body, tags string) error {
	playSound()
	macDisplayNotification(title, body)
	t := topic()
	if t == "" {
		return nil
	}
	args := []string{"publish", "--markdown", "--title", title}
	if tags != "" {
		args = append(args, "--tags", tags)
	}
	args = append(args, t, body)
	return ntfyCmd(args...).Start()
}

// SendToTopic publishes to a specific ntfy topic (fire-and-forget).
// Skipped silently if t is empty.
func SendToTopic(t, title, body string) error {
	if t == "" {
		return nil
	}
	cmd := ntfyCmd("publish", "--markdown", "--title", title, t, body)
	return cmd.Start()
}

// SendSimple shows a titleless local banner and, if $NTFY_TOPIC is
// set, publishes to ntfy with an empty title (fire-and-forget).
func SendSimple(body string) error {
	playSound()
	macDisplayNotification("", body)
	t := topic()
	if t == "" {
		return nil
	}
	cmd := ntfyCmd("publish", "--markdown", t, body)
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

// sayCmd tracks the playback process started by Say so SaySummary can
// wait for it and speak afterwards instead of talking over it.
var sayCmd *exec.Cmd

// Say speaks text via ElevenLabs TTS, falling back to the built-in
// macOS `say` voice when no API key is configured or synthesis fails.
// Audio is cached per phrase, so only the first utterance of a given
// text pays the API round-trip; playback itself is fire-and-forget.
func Say(text string) {
	if runtime.GOOS != "darwin" || text == "" {
		return
	}
	var cmd *exec.Cmd
	if path, err := elevenlabs.FetchToCache(text); err == nil {
		cmd = exec.Command("afplay", path)
	} else {
		cmd = exec.Command("say", "-v", "Samantha", text)
	}
	if cmd.Start() == nil {
		sayCmd = cmd
	}
}

// maxSpokenRunes caps how much dynamic text gets spoken aloud.
const maxSpokenRunes = 300

// SaySummary speaks dynamic per-turn text (e.g. the Groq TLDR) via
// ElevenLabs, falling back to macOS `say`. Synthesis runs while any
// in-flight Say clip is still playing; playback then waits for that
// clip to finish so the two never overlap. Audio is NOT cached —
// summaries are unique per turn. Blocks until playback has started.
func SaySummary(text string) {
	if runtime.GOOS != "darwin" || text == "" {
		return
	}
	if runes := []rune(text); len(runes) > maxSpokenRunes {
		text = string(runes[:maxSpokenRunes])
	}
	var cmd *exec.Cmd
	if path, err := elevenlabs.FetchTemp(text); err == nil {
		cmd = exec.Command("afplay", path)
	} else {
		cmd = exec.Command("say", "-v", "Samantha", text)
	}
	if sayCmd != nil {
		_ = sayCmd.Wait()
		sayCmd = nil
	}
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
