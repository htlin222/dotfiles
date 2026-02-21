// Package snapshot manages sliding-window context snapshots for @LAST injection.
package snapshot

import (
	"bufio"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/config"
)

const (
	// SnapshotPrefix is the filename prefix for per-CWD snapshots.
	SnapshotPrefix = "claude_last_context_"
	// SnapshotSuffix is the filename suffix for snapshots.
	SnapshotSuffix = ".md"
	// MaxTurns is the maximum number of conversation turns to keep.
	MaxTurns = 6
	// MaxTextLen is the maximum text length per turn.
	MaxTextLen = 4000
	// MaxTotalLen is the maximum total text length for all turns combined.
	MaxTotalLen = 20000
	// MaxAge is the maximum age of a snapshot before it's considered stale.
	MaxAge = 24 * time.Hour
)

// snapshotDir is the directory for snapshot files. Tests can override this.
var snapshotDir = "/tmp"

// cwdHash returns a deterministic 8-hex-char hash of the CWD path.
func cwdHash(cwd string) string {
	h := sha256.Sum256([]byte(cwd))
	return hex.EncodeToString(h[:4])
}

// snapshotPathForCWD returns the snapshot file path for a given CWD.
func snapshotPathForCWD(cwd string) string {
	return filepath.Join(snapshotDir, SnapshotPrefix+cwdHash(cwd)+SnapshotSuffix)
}

// transcriptEntry represents a line in the transcript JSONL.
type transcriptEntry struct {
	Type    string `json:"type"`
	Message struct {
		Role    string      `json:"role"`
		Content interface{} `json:"content"`
	} `json:"message"`
}

// conversationTurn holds one turn of conversation.
type conversationTurn struct {
	Role string
	Text string
}

// Generate creates a context snapshot from the transcript and project state.
// If lastAssistantMessage is provided (from the official Stop hook input),
// it is used directly instead of parsing the transcript for the last assistant turn.
func Generate(transcriptPath, cwd, sessionID, lastAssistantMessage string) error {
	turns := extractConversation(transcriptPath)

	// If the official last_assistant_message is available, ensure it's the final turn.
	// This avoids relying on transcript parsing for the most recent response.
	if lastAssistantMessage != "" {
		msg := lastAssistantMessage
		if len(msg) > MaxTextLen {
			msg = msg[:MaxTextLen] + "..."
		}
		// Replace the last assistant turn or append if missing
		replaced := false
		for i := len(turns) - 1; i >= 0; i-- {
			if turns[i].Role == "assistant" {
				turns[i].Text = msg
				replaced = true
				break
			}
		}
		if !replaced {
			turns = append(turns, conversationTurn{Role: "assistant", Text: msg})
		}
	}

	editedFiles := getEditedFilesList()
	gitStatus := getGitStatusString(cwd)

	project := filepath.Base(cwd)
	now := time.Now().Format("2006-01-02 15:04")

	var sb strings.Builder
	sb.WriteString("# Last Session Context\n")
	sb.WriteString(fmt.Sprintf("_Saved: %s | Project: %s_\n", now, project))

	// Recent conversation
	if len(turns) > 0 {
		sb.WriteString("\n## Recent Conversation\n")
		for _, turn := range turns {
			if turn.Role == "user" {
				sb.WriteString("\n### User\n")
			} else {
				sb.WriteString("\n### Assistant\n")
			}
			sb.WriteString(turn.Text)
			sb.WriteString("\n")
		}
	}

	// Modified files
	if len(editedFiles) > 0 {
		sb.WriteString("\n## Modified Files\n")
		for _, f := range editedFiles {
			sb.WriteString(fmt.Sprintf("- %s\n", f))
		}
	}

	// Git changes
	if gitStatus != "" {
		sb.WriteString("\n## Git Changes\n```\n")
		sb.WriteString(gitStatus)
		sb.WriteString("\n```\n")
	}

	return os.WriteFile(snapshotPathForCWD(cwd), []byte(sb.String()), 0644)
}

// IsAvailable checks if a snapshot for the given CWD exists and is younger than MaxAge.
func IsAvailable(cwd string) bool {
	path := snapshotPathForCWD(cwd)
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return time.Since(info.ModTime()) < MaxAge
}

// Consume reads the snapshot for the given CWD and renames it to prevent reuse.
func Consume(cwd string) (string, error) {
	path := snapshotPathForCWD(cwd)
	data, err := os.ReadFile(path)
	if err != nil {
		return "", fmt.Errorf("no snapshot available")
	}
	// Check staleness
	info, err := os.Stat(path)
	if err != nil || time.Since(info.ModTime()) >= MaxAge {
		return "", fmt.Errorf("no snapshot available")
	}
	// Rename to .consumed to prevent duplicate injection
	consumed := strings.TrimSuffix(path, SnapshotSuffix) + ".consumed"
	if err := os.Rename(path, consumed); err != nil {
		_ = os.Remove(path)
	}
	return string(data), nil
}

// extractConversation reads the transcript JSONL and returns the last MaxTurns turns.
func extractConversation(transcriptPath string) []conversationTurn {
	if transcriptPath == "" {
		return nil
	}

	f, err := os.Open(transcriptPath)
	if err != nil {
		return nil
	}
	defer f.Close()

	var turns []conversationTurn
	scanner := bufio.NewScanner(f)
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		line := scanner.Text()

		// Quick pre-filter
		if !strings.Contains(line, `"type":"human"`) && !strings.Contains(line, `"type":"assistant"`) {
			continue
		}

		var entry transcriptEntry
		if err := json.Unmarshal([]byte(line), &entry); err != nil {
			continue
		}

		if entry.Type != "human" && entry.Type != "assistant" {
			continue
		}

		text := extractText(entry.Message.Content)
		if text == "" {
			continue
		}

		// Truncate long text
		if len(text) > MaxTextLen {
			text = text[:MaxTextLen] + "..."
		}

		role := "user"
		if entry.Type == "assistant" {
			role = "assistant"
		}
		turns = append(turns, conversationTurn{Role: role, Text: text})
	}

	// Keep only last MaxTurns turns
	if len(turns) > MaxTurns {
		turns = turns[len(turns)-MaxTurns:]
	}

	// Enforce MaxTotalLen: drop oldest turns until total fits
	totalLen := 0
	for _, t := range turns {
		totalLen += len(t.Text)
	}
	for len(turns) > 0 && totalLen > MaxTotalLen {
		totalLen -= len(turns[0].Text)
		turns = turns[1:]
	}

	return turns
}

// extractText extracts text content, filtering out tool_use/tool_result blocks.
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
			typ, _ := m["type"].(string)
			if typ == "text" {
				if text, ok := m["text"].(string); ok && text != "" {
					parts = append(parts, text)
				}
			}
			// Skip tool_use, tool_result, and other non-text blocks
		}
		return strings.Join(parts, "\n")
	}
	return ""
}

// getEditedFilesList returns recently edited files from edits.jsonl.
func getEditedFilesList() []string {
	editsFile := config.EditsLogFile()
	f, err := os.Open(editsFile)
	if err != nil {
		return nil
	}
	defer f.Close()

	cutoff := time.Now().Add(-time.Duration(config.SessionTimeoutMinutes) * time.Minute)
	seen := make(map[string]bool)
	var files []string

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		var entry map[string]interface{}
		if err := json.Unmarshal(scanner.Bytes(), &entry); err != nil {
			continue
		}

		timestampStr, ok := entry["timestamp"].(string)
		if !ok {
			continue
		}
		ts, err := time.Parse(time.RFC3339, timestampStr)
		if err != nil {
			continue
		}
		if ts.Before(cutoff) {
			continue
		}

		filePath, ok := entry["file"].(string)
		if !ok || seen[filePath] {
			continue
		}
		seen[filePath] = true
		files = append(files, filePath)
	}

	return files
}

// getGitStatusString returns the git status output for the given directory.
func getGitStatusString(cwd string) string {
	if cwd == "" {
		return ""
	}
	cmd := exec.Command("git", "status", "-s")
	cmd.Dir = cwd
	output, err := cmd.Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(output))
}
