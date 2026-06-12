package stop

import (
	"os"
	"path/filepath"
	"testing"
)

func writeTranscript(t *testing.T, lines string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "transcript.jsonl")
	if err := os.WriteFile(path, []byte(lines), 0644); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestLastMessageFromTranscript_ClaudeBlocks(t *testing.T) {
	path := writeTranscript(t, `
{"type":"user","message":{"role":"user","content":"do the thing"}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash"}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":"hmm"},{"type":"text","text":"done, all tests pass"}]}}
{"type":"system","subtype":"info"}
`)
	got := lastMessageFromTranscript(path)
	if got != "done, all tests pass" {
		t.Fatalf("got %q", got)
	}
}

func TestLastMessageFromTranscript_ClaudeStringContent(t *testing.T) {
	path := writeTranscript(t, `{"type":"assistant","message":{"role":"assistant","content":"plain string answer"}}`)
	if got := lastMessageFromTranscript(path); got != "plain string answer" {
		t.Fatalf("got %q", got)
	}
}

func TestLastMessageFromTranscript_CodexTaskComplete(t *testing.T) {
	path := writeTranscript(t, `
{"type":"event_msg","payload":{"type":"user_message","message":"hi"}}
{"type":"event_msg","payload":{"type":"agent_message","message":"older agent text"}}
{"type":"event_msg","payload":{"type":"task_complete","turn_id":"t1","last_agent_message":"final codex answer"}}
{"type":"event_msg","payload":{"type":"token_count"}}
`)
	if got := lastMessageFromTranscript(path); got != "final codex answer" {
		t.Fatalf("got %q", got)
	}
}

func TestLastMessageFromTranscript_CodexAgentMessage(t *testing.T) {
	path := writeTranscript(t, `
{"type":"event_msg","payload":{"type":"agent_message","message":"codex agent says hi"}}
{"type":"event_msg","payload":{"type":"token_count"}}
`)
	if got := lastMessageFromTranscript(path); got != "codex agent says hi" {
		t.Fatalf("got %q", got)
	}
}

func TestLastMessageFromTranscript_CodexResponseItem(t *testing.T) {
	path := writeTranscript(t, `
{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"user prompt"}]}}
{"type":"response_item","payload":{"type":"message","role":"assistant","content":[{"type":"output_text","text":"assistant output text"}]}}
{"type":"response_item","payload":{"type":"function_call","name":"shell"}}
`)
	if got := lastMessageFromTranscript(path); got != "assistant output text" {
		t.Fatalf("got %q", got)
	}
}

func TestLastMessageFromTranscript_SkipsNonAssistant(t *testing.T) {
	path := writeTranscript(t, `
{"type":"event_msg","payload":{"type":"agent_message","message":"the answer"}}
{"type":"event_msg","payload":{"type":"user_message","message":"a user message"}}
{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"another prompt"}]}}
`)
	if got := lastMessageFromTranscript(path); got != "the answer" {
		t.Fatalf("got %q", got)
	}
}

func TestLastMessageFromTranscript_MissingFile(t *testing.T) {
	if got := lastMessageFromTranscript("/nonexistent/path.jsonl"); got != "" {
		t.Fatalf("got %q, want empty", got)
	}
}

func TestLastMessageFromTranscript_EmptyAndMalformed(t *testing.T) {
	path := writeTranscript(t, "\nnot json at all\n{\"type\":\"event_msg\"}\n")
	if got := lastMessageFromTranscript(path); got != "" {
		t.Fatalf("got %q, want empty", got)
	}
}
