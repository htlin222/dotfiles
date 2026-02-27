// Package killtimer spawns a detached process that kills an idle Claude session
// after 10 minutes. The timer is cancelled when the user sends a new prompt.
package killtimer

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"syscall"
	"time"
)

const timerSeconds = 600 // 10 minutes

// MarkerData is persisted to /tmp/claude_killtimer_<pid>.
type MarkerData struct {
	ClaudePID int    `json:"claude_pid"`
	TimerPID  int    `json:"timer_pid"`
	Deadline  string `json:"deadline"`
	SessionID string `json:"session_id"`
}

// SecondsRemaining returns seconds until the kill deadline (0 if past).
func (m *MarkerData) SecondsRemaining() int {
	t, err := time.Parse(time.RFC3339, m.Deadline)
	if err != nil {
		return 0
	}
	rem := int(time.Until(t).Seconds())
	if rem < 0 {
		return 0
	}
	return rem
}

func markerPath(claudePID int) string {
	return fmt.Sprintf("/tmp/claude_killtimer_%d", claudePID)
}

// FindClaudePID walks the ppid chain to locate the Claude process.
func FindClaudePID() int {
	pid := os.Getppid()
	for i := 0; i < 10; i++ {
		cmd := exec.Command("ps", "-o", "comm=", "-p", fmt.Sprintf("%d", pid))
		out, err := cmd.Output()
		if err != nil {
			break
		}
		comm := strings.TrimSpace(string(out))
		if strings.Contains(strings.ToLower(comm), "claude") {
			return pid
		}
		cmd = exec.Command("ps", "-o", "ppid=", "-p", fmt.Sprintf("%d", pid))
		out, err = cmd.Output()
		if err != nil {
			break
		}
		ppid := 0
		fmt.Sscanf(strings.TrimSpace(string(out)), "%d", &ppid)
		if ppid <= 1 {
			break
		}
		pid = ppid
	}
	return 0
}

// Start cancels any existing timer, then spawns a detached shell that will
// TERM (then KILL) the Claude process after timerSeconds.
func Start(claudePID int, sessionID string) error {
	// Cancel previous timer if any
	Cancel(claudePID)

	deadline := time.Now().Add(time.Duration(timerSeconds) * time.Second)

	// Build the kill script: sleep, TERM, grace period, KILL, then play sound
	script := fmt.Sprintf(
		"sleep %d && kill -TERM %d 2>/dev/null; sleep 5 && kill -KILL %d 2>/dev/null; afplay /System/Library/Sounds/Hero.aiff &",
		timerSeconds, claudePID, claudePID,
	)

	cmd := exec.Command("sh", "-c", script)
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
	cmd.Stdout = nil
	cmd.Stderr = nil
	cmd.Stdin = nil

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("spawn timer: %w", err)
	}

	timerPID := cmd.Process.Pid

	// Detach — we don't wait for it
	cmd.Process.Release()

	// Write marker file
	marker := MarkerData{
		ClaudePID: claudePID,
		TimerPID:  timerPID,
		Deadline:  deadline.Format(time.RFC3339),
		SessionID: sessionID,
	}
	data, err := json.Marshal(marker)
	if err != nil {
		return fmt.Errorf("marshal marker: %w", err)
	}
	return os.WriteFile(markerPath(claudePID), data, 0644)
}

// Cancel kills the timer process group and removes the marker file.
func Cancel(claudePID int) {
	m := ReadMarker(claudePID)
	if m == nil {
		return
	}
	// Kill the entire process group (sh + sleep children)
	_ = syscall.Kill(-m.TimerPID, syscall.SIGKILL)
	os.Remove(markerPath(claudePID))
}

// ReadMarker returns the marker data if the timer is still alive, nil otherwise.
func ReadMarker(claudePID int) *MarkerData {
	data, err := os.ReadFile(markerPath(claudePID))
	if err != nil {
		return nil
	}
	var m MarkerData
	if err := json.Unmarshal(data, &m); err != nil {
		return nil
	}
	// Check if timer process is still alive
	if err := syscall.Kill(m.TimerPID, 0); err != nil {
		// Timer process is dead — clean up stale marker
		os.Remove(markerPath(claudePID))
		return nil
	}
	return &m
}
