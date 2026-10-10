// Package stop implements the Stop hook.
package stop

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/hooks/busy"
	"github.com/htlin/claude-tools/internal/hooks/killtimer"
	"github.com/htlin/claude-tools/internal/hooks/sessiontimer"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
	"github.com/htlin/claude-tools/internal/turso"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/groq"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/notify"
)

// Run executes the stop hook.
func Run() {
	if pane := busy.GetTmuxPane(); pane != "" {
		busy.SetIdle(pane)
	}

	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		notify.SendSimple("對話結束")
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		notify.SendSimple("對話結束")
		return
	}

	cwd := data.CWD
	sessionID := data.SessionID
	folderName := filepath.Base(cwd)

	// Persist session ID early so it survives kill signals
	// (sessionend hook may not run if process is killed)
	if sessionID != "" {
		_ = os.WriteFile(config.LastSessionIDFile(), []byte(sessionID+"\n"), 0644)
		if pane := os.Getenv("TMUX_PANE"); pane != "" {
			_ = os.WriteFile(config.LastSessionIDFileForPane(pane), []byte(sessionID+"\n"), 0644)
		}
		// Also store in tmux server memory as redundancy (survives /tmp cleanup)
		if os.Getenv("TMUX") != "" {
			_ = exec.Command("tmux", "set-environment", "CLAUDE_LAST_SESSION_ID", sessionID).Run()
		}
	}

	// TTS: say the repo name (fire-and-forget)
	notify.Say(folderName)

	// Feature 2: Notification with last assistant message.
	// Codex's Stop payload may omit last_assistant_message, so fall back
	// to extracting it from the transcript (Claude or Codex format).
	// Long messages are condensed to a short English summary via Groq;
	// on any failure we fall back to plain truncation.
	body := data.LastAssistantMessage
	msgSource := "payload"
	if body == "" && data.TranscriptPath != "" {
		body = lastMessageFromTranscript(data.TranscriptPath)
		msgSource = "transcript"
	}
	if body == "" {
		body = "Conversation completed"
		msgSource = "none"
	}
	if utf8.RuneCountInString(body) > 50 {
		if summary, err := groq.SummarizeZHTW(body); err == nil {
			body = summary
		} else if len(body) > 500 {
			body = body[:500] + "…"
		}
	}
	host, _ := os.Hostname()
	var title string
	switch {
	case folderName != "" && host != "":
		title = folderName + " at " + host
	case folderName != "":
		title = folderName
	case host != "":
		title = host
	default:
		title = "Claude Code"
	}
	var tags string
	if u, err := user.Current(); err == nil && u.Username != "" {
		tags = u.Username
	}
	notify.SendWithTags(title, body, tags)

	// Feature 2.1: speak the summary aloud after the repo-name clip.
	// Blocks briefly until playback starts; the audio process itself
	// outlives the hook.
	notify.SaySummary(body)

	// Feature 2.5: Save context snapshot for @LAST
	if data.TranscriptPath != "" || data.LastAssistantMessage != "" {
		snapshot.Generate(data.TranscriptPath, cwd, sessionID, data.LastAssistantMessage)
	}

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("stop", "Stop", executionTimeMS, true, map[string]any{
		"session_id": sessionID,
		"msg_source": msgSource,
	})

	metrics.LogEvent("Stop", "stop", sessionID, cwd, map[string]any{
		"project": folderName,
	})

	// Print session duration
	sessiontimer.PrintDuration()

	// Start kill timer for idle session cleanup (opt-in via CLAUDE_STOP_AND_KILL=true)
	if strings.EqualFold(os.Getenv("CLAUDE_STOP_AND_KILL"), "true") {
		if claudePID := killtimer.FindClaudePID(); claudePID > 0 {
			if err := killtimer.Start(claudePID, sessionID); err != nil {
				fmt.Fprintf(os.Stderr, "killtimer: %v\n", err)
			} else {
				fmt.Fprintf(os.Stderr, "%s%s  Auto-kill in 10m (PID %d)%s\n",
					ansi.BrightYellow, ansi.IconHourglass, claudePID, ansi.Reset)
			}
		}
	}

	// Best-effort flush of the local libSQL replica to Turso cloud — picks up
	// anything the userprompt-spawned sync subprocess didn't finish in time.
	// Latency here is invisible to the user (Claude already finished its turn).
	if url := os.Getenv("TURSO_DATABASE_URL"); url != "" {
		if c, err := turso.OpenReplica(turso.DefaultDBPath(), url, os.Getenv("TURSO_AUTH_TOKEN")); err == nil && c != nil {
			_ = c.Sync()
			_ = c.Close()
		}
	}

	// Stop hook: exit 0 with no stdout = allow Claude to stop normally
	// Do NOT output JSON here - "continue":true can be misinterpreted as "keep working"
}
