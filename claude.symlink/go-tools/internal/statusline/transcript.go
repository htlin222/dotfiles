package statusline

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// transcriptMessage represents a message in the transcript
type transcriptMessage struct {
	Type      string `json:"type"`
	Timestamp string `json:"timestamp"`
	Message   struct {
		Content interface{} `json:"content"`
	} `json:"message"`
}

func countConversationDepth(transcriptPath string) int {
	if transcriptPath == "" {
		return 0
	}

	f, err := os.Open(transcriptPath)
	if err != nil {
		return 0
	}
	defer f.Close()

	count := 0
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		if strings.Contains(scanner.Text(), `"type":"user"`) {
			count++
		}
	}
	return count
}

func getLastUserCommand(transcriptPath string, maxLen int) (string, string) {
	if transcriptPath == "" {
		return "", ""
	}

	f, err := os.Open(transcriptPath)
	if err != nil {
		return "", ""
	}
	defer f.Close()

	var lastUserMsg string
	var lastTimestamp string
	scanner := bufio.NewScanner(f)
	// Increase buffer size for large lines
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		line := scanner.Text()
		if !strings.Contains(line, `"type":"user"`) {
			continue
		}

		var msg transcriptMessage
		if err := json.Unmarshal([]byte(line), &msg); err != nil {
			continue
		}

		// Extract text from content
		text := extractTextFromContent(msg.Message.Content)
		if text != "" {
			lastUserMsg = text
			lastTimestamp = msg.Timestamp
		}
	}

	// Clean and truncate
	lastUserMsg = strings.TrimSpace(lastUserMsg)
	lastUserMsg = strings.ReplaceAll(lastUserMsg, "\n", " ")
	lastUserMsg = strings.ReplaceAll(lastUserMsg, "\t", " ")

	// Filter out system-generated content (local-command tags, etc.)
	lastUserMsg = cleanLastCommand(lastUserMsg)

	// Collapse multiple spaces
	for strings.Contains(lastUserMsg, "  ") {
		lastUserMsg = strings.ReplaceAll(lastUserMsg, "  ", " ")
	}

	if len(lastUserMsg) > maxLen {
		lastUserMsg = lastUserMsg[:maxLen-3] + "..."
	}

	// Format timestamp as HH:MM:SS
	timeStr := formatTimestamp(lastTimestamp)

	return lastUserMsg, timeStr
}

func extractTextFromContent(content interface{}) string {
	switch c := content.(type) {
	case string:
		return c
	case []interface{}:
		var parts []string
		for _, item := range c {
			if m, ok := item.(map[string]interface{}); ok {
				if m["type"] == "text" {
					if text, ok := m["text"].(string); ok {
						parts = append(parts, text)
					}
				}
			}
		}
		return strings.Join(parts, " ")
	}
	return ""
}

// cleanLastCommand filters out system-generated content from the last command.
func cleanLastCommand(cmd string) string {
	// Tags to remove with their content
	tagsToRemove := []string{
		"local-command-stdout",
		"local-command-caveat",
		"local-command-stderr",
		"command-name",
		"command-message",
		"command-args",
		"system-reminder",
	}

	for _, tag := range tagsToRemove {
		for {
			openTag := "<" + tag + ">"
			closeTag := "</" + tag + ">"

			startIdx := strings.Index(cmd, openTag)
			if startIdx == -1 {
				break
			}
			endIdx := strings.Index(cmd[startIdx:], closeTag)
			if endIdx == -1 {
				// Remove just the opening tag if no close
				cmd = cmd[:startIdx] + cmd[startIdx+len(openTag):]
				break
			}
			// Remove entire tag with content
			cmd = cmd[:startIdx] + cmd[startIdx+endIdx+len(closeTag):]
		}
	}

	return strings.TrimSpace(cmd)
}

// getFirstPrompt returns the first prompt of the session, saving it if needed.
func getFirstPrompt(transcriptPath string, maxLen int) string {
	if transcriptPath == "" {
		return ""
	}

	// Session state file
	sessionID := filepath.Base(transcriptPath)
	sessionID = strings.TrimSuffix(sessionID, ".jsonl")
	stateFile := fmt.Sprintf("/tmp/claude_first_prompt_%s", sessionID)

	// Check if we already have it saved (format: prompt\nTIMESTAMP)
	if data, err := os.ReadFile(stateFile); err == nil {
		lines := strings.SplitN(string(data), "\n", 2)
		if len(lines) > 0 && strings.TrimSpace(lines[0]) != "" {
			return truncateString(strings.TrimSpace(lines[0]), maxLen)
		}
	}

	// Get first prompt from transcript
	firstPrompt, firstTime := extractFirstPrompt(transcriptPath)
	if firstPrompt == "" {
		return ""
	}

	// Save it for future (persists across compacts)
	os.WriteFile(stateFile, []byte(firstPrompt+"\n"+firstTime), 0644)

	return truncateString(firstPrompt, maxLen)
}

// getFirstPromptTime returns the timestamp of the first prompt.
func getFirstPromptTime(transcriptPath string) string {
	if transcriptPath == "" {
		return ""
	}

	sessionID := filepath.Base(transcriptPath)
	sessionID = strings.TrimSuffix(sessionID, ".jsonl")
	stateFile := fmt.Sprintf("/tmp/claude_first_prompt_%s", sessionID)

	// Read saved timestamp (format: prompt\nTIMESTAMP)
	if data, err := os.ReadFile(stateFile); err == nil {
		lines := strings.SplitN(string(data), "\n", 2)
		if len(lines) > 1 {
			return formatTimestamp(strings.TrimSpace(lines[1]))
		}
	}

	// Fallback: get from transcript
	_, firstTime := extractFirstPrompt(transcriptPath)
	return formatTimestamp(firstTime)
}

// extractFirstPrompt gets the first user message and timestamp from the transcript.
func extractFirstPrompt(transcriptPath string) (string, string) {
	f, err := os.Open(transcriptPath)
	if err != nil {
		return "", ""
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		line := scanner.Text()
		if !strings.Contains(line, `"type":"user"`) {
			continue
		}

		var msg transcriptMessage
		if err := json.Unmarshal([]byte(line), &msg); err != nil {
			continue
		}

		text := extractTextFromContent(msg.Message.Content)
		if text != "" {
			// Clean it up
			text = strings.TrimSpace(text)
			text = strings.ReplaceAll(text, "\n", " ")
			text = strings.ReplaceAll(text, "\t", " ")
			text = cleanLastCommand(text)
			// Collapse multiple spaces
			for strings.Contains(text, "  ") {
				text = strings.ReplaceAll(text, "  ", " ")
			}
			return text, msg.Timestamp
		}
	}
	return "", ""
}
