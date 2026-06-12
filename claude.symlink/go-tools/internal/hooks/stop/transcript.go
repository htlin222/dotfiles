package stop

import (
	"encoding/json"
	"io"
	"os"
	"strings"
)

// transcriptTailBytes bounds how much of the transcript is read when
// recovering the last assistant message.
const transcriptTailBytes = 64 * 1024

// lastMessageFromTranscript reads the tail of a session transcript JSONL
// and returns the most recent assistant/agent message text. It understands
// both Claude Code transcripts ({"type":"assistant",...}) and Codex
// rollouts ({"type":"event_msg"|"response_item","payload":{...}}), so the
// Codex Stop hook gets the same notification body as the Claude one even
// when the payload omits last_assistant_message. Returns "" on any failure.
func lastMessageFromTranscript(path string) string {
	f, err := os.Open(path)
	if err != nil {
		return ""
	}
	defer f.Close()

	info, err := f.Stat()
	if err != nil {
		return ""
	}

	size := info.Size()
	offset := int64(0)
	readLen := size
	if size > transcriptTailBytes {
		offset = size - transcriptTailBytes
		readLen = transcriptTailBytes
	}

	buf := make([]byte, readLen)
	if _, err := f.ReadAt(buf, offset); err != nil && err != io.EOF {
		return ""
	}

	lines := strings.Split(string(buf), "\n")
	// Walk from the end so the most recent message wins.
	for i := len(lines) - 1; i >= 0; i-- {
		line := strings.TrimSpace(lines[i])
		if line == "" {
			continue
		}
		if text := extractMessageText(line); text != "" {
			return text
		}
	}
	return ""
}

// extractMessageText parses one JSONL line from either transcript format
// and returns its assistant message text, or "".
func extractMessageText(line string) string {
	var entry struct {
		Type    string `json:"type"`
		Message struct {
			Role    string          `json:"role"`
			Content json.RawMessage `json:"content"`
		} `json:"message"`
		Payload json.RawMessage `json:"payload"`
	}
	if err := json.Unmarshal([]byte(line), &entry); err != nil {
		return ""
	}
	switch entry.Type {
	case "assistant": // Claude Code transcript
		return textFromClaudeContent(entry.Message.Content)
	case "event_msg", "response_item": // Codex rollout
		return textFromCodexPayload(entry.Payload)
	}
	return ""
}

// textFromClaudeContent handles Claude message content: either a plain
// string or an array of typed blocks (last "text" block wins).
func textFromClaudeContent(raw json.RawMessage) string {
	if len(raw) == 0 {
		return ""
	}
	var asString string
	if err := json.Unmarshal(raw, &asString); err == nil {
		return strings.TrimSpace(asString)
	}
	var blocks []struct {
		Type string `json:"type"`
		Text string `json:"text"`
	}
	if err := json.Unmarshal(raw, &blocks); err != nil {
		return ""
	}
	for i := len(blocks) - 1; i >= 0; i-- {
		if blocks[i].Type == "text" {
			if t := strings.TrimSpace(blocks[i].Text); t != "" {
				return t
			}
		}
	}
	return ""
}

// textFromCodexPayload handles Codex rollout payloads:
//   - event_msg/task_complete carries last_agent_message
//   - event_msg/agent_message carries message
//   - response_item/message with role=assistant carries output_text blocks
func textFromCodexPayload(raw json.RawMessage) string {
	if len(raw) == 0 {
		return ""
	}
	var p struct {
		Type             string `json:"type"`
		Message          string `json:"message"`
		LastAgentMessage string `json:"last_agent_message"`
		Role             string `json:"role"`
		Content          []struct {
			Type string `json:"type"`
			Text string `json:"text"`
		} `json:"content"`
	}
	if err := json.Unmarshal(raw, &p); err != nil {
		return ""
	}
	switch p.Type {
	case "task_complete":
		return strings.TrimSpace(p.LastAgentMessage)
	case "agent_message":
		return strings.TrimSpace(p.Message)
	case "message":
		if p.Role != "assistant" {
			return ""
		}
		for i := len(p.Content) - 1; i >= 0; i-- {
			if p.Content[i].Type == "output_text" {
				if t := strings.TrimSpace(p.Content[i].Text); t != "" {
					return t
				}
			}
		}
	}
	return ""
}
