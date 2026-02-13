// Package precompact implements the PreCompact hook.
// It saves a context snapshot before Claude Code compacts the conversation.
package precompact

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/metrics"
)

const (
	maxSnapshots     = 20
	maxDevDocBytes   = 5000
	maxGitStatusLen  = 1000
	maxMessageText   = 200
	maxRecentLines   = 30
	maxRecentMsgKeep = 10
)

var contextDir = filepath.Join(config.ClaudeDir, "context-snapshots")

// contextSnapshot is the JSON structure written to disk.
type contextSnapshot struct {
	Timestamp      string                        `json:"timestamp"`
	SessionID      string                        `json:"session_id"`
	Project        string                        `json:"project"`
	CWD            string                        `json:"cwd"`
	TranscriptPath string                        `json:"transcript_path"`
	DevDocs        map[string]map[string]string  `json:"dev_docs"`
	GitStatus      string                        `json:"git_status"`
	ActiveTodos    []string                      `json:"active_todos"`
	RecentMessages []recentMessage               `json:"recent_messages,omitempty"`
}

type recentMessage struct {
	Role string `json:"role"`
	Text string `json:"text"`
}

// transcriptLine is used to parse transcript JSONL entries.
type transcriptLine struct {
	Role    string      `json:"role"`
	Content interface{} `json:"content"`
}

// Run executes the pre-compact hook.
func Run() {
	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		outputJSON(true, "")
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		outputJSON(true, "")
		return
	}

	cwd := data.CWD
	sessionID := data.SessionID
	transcriptPath := data.TranscriptPath
	project := filepath.Base(cwd)

	// Save context snapshot
	snapshotFile, err := saveContextSnapshot(cwd, transcriptPath, sessionID)
	if err != nil {
		outputJSON(true, "")
		return
	}

	// Log compaction event
	logCompactionEvent(cwd, snapshotFile)

	// Log metrics
	execMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("pre_compact", "PreCompact", execMS, true, map[string]any{
		"session_id":    sessionID,
		"project":       project,
		"snapshot_file": filepath.Base(snapshotFile),
	})
	metrics.LogEvent("PreCompact", "pre_compact", sessionID, cwd, map[string]any{
		"snapshot_file": snapshotFile,
	})

	outputJSON(true, fmt.Sprintf("📸 Context snapshot saved before compaction: %s", filepath.Base(snapshotFile)))
}

func saveContextSnapshot(cwd, transcriptPath, sessionID string) (string, error) {
	if err := os.MkdirAll(contextDir, 0755); err != nil {
		return "", err
	}

	project := "unknown"
	if cwd != "" {
		project = filepath.Base(cwd)
	}

	snap := contextSnapshot{
		Timestamp:      time.Now().Format(time.RFC3339),
		SessionID:      sessionID,
		Project:        project,
		CWD:            cwd,
		TranscriptPath: transcriptPath,
		DevDocs:        make(map[string]map[string]string),
		ActiveTodos:    []string{},
	}

	// Capture dev docs
	if cwd != "" {
		collectDevDocs(cwd, &snap)
	}

	// Capture git status
	if cwd != "" {
		snap.GitStatus = gitStatusShort(cwd)
	}

	// Extract recent transcript messages
	if transcriptPath != "" {
		snap.RecentMessages = extractRecentMessages(transcriptPath)
	}

	// Write snapshot
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("%s_%s.json", project, timestamp)
	snapshotFile := filepath.Join(contextDir, filename)

	data, err := json.MarshalIndent(snap, "", "  ")
	if err != nil {
		return "", err
	}
	if err := os.WriteFile(snapshotFile, data, 0644); err != nil {
		return "", err
	}

	cleanupOldSnapshots()
	return snapshotFile, nil
}

func collectDevDocs(cwd string, snap *contextSnapshot) {
	activeDir := filepath.Join(cwd, "dev", "active")
	entries, err := os.ReadDir(activeDir)
	if err != nil {
		return
	}

	docFiles := []string{"plan.md", "context.md", "tasks.md"}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		taskDocs := make(map[string]string)
		for _, docFile := range docFiles {
			docPath := filepath.Join(activeDir, entry.Name(), docFile)
			content, err := os.ReadFile(docPath)
			if err != nil {
				continue
			}
			text := string(content)
			if len(text) > maxDevDocBytes {
				text = text[:maxDevDocBytes]
			}
			taskDocs[docFile] = text
		}
		if len(taskDocs) > 0 {
			snap.DevDocs[entry.Name()] = taskDocs
		}
	}
}

func gitStatusShort(cwd string) string {
	cmd := exec.Command("git", "status", "--short")
	cmd.Dir = cwd
	output, err := cmd.Output()
	if err != nil {
		return ""
	}
	text := strings.TrimSpace(string(output))
	if len(text) > maxGitStatusLen {
		text = text[:maxGitStatusLen]
	}
	return text
}

func extractRecentMessages(transcriptPath string) []recentMessage {
	data, err := os.ReadFile(transcriptPath)
	if err != nil {
		return nil
	}

	// Take last N lines
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")
	if len(lines) > maxRecentLines {
		lines = lines[len(lines)-maxRecentLines:]
	}

	var messages []recentMessage
	for _, line := range lines {
		var entry transcriptLine
		if err := json.Unmarshal([]byte(line), &entry); err != nil {
			continue
		}
		if entry.Role != "user" && entry.Role != "assistant" {
			continue
		}

		text := extractText(entry.Content)
		if text == "" {
			continue
		}
		if len(text) > maxMessageText {
			text = text[:maxMessageText]
		}
		messages = append(messages, recentMessage{Role: entry.Role, Text: text})
	}

	// Keep only last N
	if len(messages) > maxRecentMsgKeep {
		messages = messages[len(messages)-maxRecentMsgKeep:]
	}
	return messages
}

func extractText(content interface{}) string {
	switch c := content.(type) {
	case string:
		return c
	case []interface{}:
		var parts []string
		for _, item := range c {
			m, ok := item.(map[string]interface{})
			if !ok {
				continue
			}
			if typ, _ := m["type"].(string); typ == "text" {
				if text, ok := m["text"].(string); ok && text != "" {
					parts = append(parts, text)
				}
			}
		}
		return strings.Join(parts, "\n")
	}
	return ""
}

func cleanupOldSnapshots() {
	entries, err := os.ReadDir(contextDir)
	if err != nil {
		return
	}

	type fileInfo struct {
		name    string
		modTime time.Time
	}

	var snapshots []fileInfo
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".json") {
			continue
		}
		info, err := e.Info()
		if err != nil {
			continue
		}
		snapshots = append(snapshots, fileInfo{name: e.Name(), modTime: info.ModTime()})
	}

	if len(snapshots) <= maxSnapshots {
		return
	}

	// Sort oldest first
	sort.Slice(snapshots, func(i, j int) bool {
		return snapshots[i].modTime.Before(snapshots[j].modTime)
	})

	for _, s := range snapshots[:len(snapshots)-maxSnapshots] {
		os.Remove(filepath.Join(contextDir, s.name))
	}
}

func logCompactionEvent(cwd, snapshotFile string) {
	_ = config.EnsureLogDir()
	logFile := filepath.Join(config.LogDir, "compactions.jsonl")

	entry := map[string]string{
		"timestamp":     time.Now().Format(time.RFC3339),
		"cwd":           cwd,
		"snapshot_file": snapshotFile,
	}

	data, err := json.Marshal(entry)
	if err != nil {
		return
	}

	f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()

	f.Write(data)
	f.Write([]byte("\n"))
}

func outputJSON(cont bool, systemMsg string) {
	resp := map[string]interface{}{"continue": cont}
	if systemMsg != "" {
		resp["systemMessage"] = systemMsg
	}
	out, _ := json.Marshal(resp)
	fmt.Println(string(out))
}
