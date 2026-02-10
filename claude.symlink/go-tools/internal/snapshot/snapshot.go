// Package snapshot manages sliding-window context snapshots for @LAST injection.
package snapshot

import (
	"bufio"
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
	// SnapshotPath is the default path for the context snapshot file.
	SnapshotPath = "/tmp/claude_last_context.md"
	// ConsumedPath is the path after snapshot has been consumed.
	ConsumedPath = "/tmp/claude_last_context.md.consumed"
	// MaxTurns is the maximum number of conversation turns to keep.
	MaxTurns = 5
	// MaxTextLen is the maximum text length per turn.
	MaxTextLen = 2000
	// MaxAge is the maximum age of a snapshot before it's considered stale.
	MaxAge = 24 * time.Hour
)

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
func Generate(transcriptPath, cwd string) error {
	turns := extractConversation(transcriptPath)
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

	return os.WriteFile(SnapshotPath, []byte(sb.String()), 0644)
}

// IsAvailable checks if a snapshot exists and is younger than MaxAge.
func IsAvailable() bool {
	info, err := os.Stat(SnapshotPath)
	if err != nil {
		return false
	}
	return time.Since(info.ModTime()) < MaxAge
}

// Consume reads the snapshot content and renames it to prevent reuse.
func Consume() (string, error) {
	data, err := os.ReadFile(SnapshotPath)
	if err != nil {
		return "", err
	}
	// Rename to .consumed to prevent duplicate injection
	if err := os.Rename(SnapshotPath, ConsumedPath); err != nil {
		// If rename fails, still return the content
		_ = os.Remove(SnapshotPath)
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
