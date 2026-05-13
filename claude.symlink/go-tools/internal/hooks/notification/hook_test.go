package notification

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestCondense(t *testing.T) {
	cases := []struct {
		in, want string
	}{
		{"hello", "hello"},
		{"  trim me   ", "trim me"},
		{"line1\n\nline2 final", "line2 final"},
		{"multi   spaces\tcollapse", "multi spaces collapse"},
		{"trailing blank lines\n\n\n", "trailing blank lines"},
	}
	for _, tc := range cases {
		if got := condense(tc.in); got != tc.want {
			t.Errorf("condense(%q) = %q, want %q", tc.in, got, tc.want)
		}
	}
}

func TestCondenseTruncates(t *testing.T) {
	long := strings.Repeat("a", 200)
	got := condense(long)
	r := []rune(got)
	// 80 chars + 1 ellipsis rune
	if len(r) != 81 {
		t.Fatalf("expected 81-rune output, got %d (%q)", len(r), got)
	}
	if !strings.HasSuffix(got, "…") {
		t.Errorf("expected ellipsis suffix, got %q", got)
	}
}

func TestExtractAssistantText(t *testing.T) {
	cases := []struct {
		name, line, want string
	}{
		{
			"text block",
			`{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Want me to commit?"}]}}`,
			"Want me to commit?",
		},
		{
			"plain string content",
			`{"type":"assistant","message":{"role":"assistant","content":"plain answer"}}`,
			"plain answer",
		},
		{
			"tool_use only — no text",
			`{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"t","name":"Bash"}]}}`,
			"",
		},
		{
			"thinking and text — take text",
			`{"type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":"reasoning..."},{"type":"text","text":"final answer"}]}}`,
			"final answer",
		},
		{
			"user turn ignored",
			`{"type":"user","message":{"role":"user","content":[{"type":"text","text":"my prompt"}]}}`,
			"",
		},
		{
			"malformed",
			`not json`,
			"",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := extractAssistantText(tc.line); got != tc.want {
				t.Errorf("got %q, want %q", got, tc.want)
			}
		})
	}
}

func TestLastAssistantTextWalksFromEnd(t *testing.T) {
	dir := t.TempDir()
	p := filepath.Join(dir, "t.jsonl")
	body := strings.Join([]string{
		`{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"older"}]}}`,
		`{"type":"user","message":{"role":"user","content":[{"type":"text","text":"reply"}]}}`,
		`{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"newer question?"}]}}`,
		`{"type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"x","content":"out"}]}}`,
		``,
	}, "\n")
	if err := os.WriteFile(p, []byte(body), 0o600); err != nil {
		t.Fatal(err)
	}
	if got := lastAssistantText(p); got != "newer question?" {
		t.Errorf("got %q, want %q", got, "newer question?")
	}
}

func TestLastAssistantTextMissingFile(t *testing.T) {
	if got := lastAssistantText("/nonexistent/path"); got != "" {
		t.Errorf("expected empty, got %q", got)
	}
}

func TestIsWaiting(t *testing.T) {
	yes := []string{
		"Claude is waiting for your input",
		"Claude needs your attention",
		"Idle 60s",
	}
	no := []string{
		"Claude needs your permission to use Bash",
		"",
	}
	for _, m := range yes {
		if !isWaiting(m) {
			t.Errorf("isWaiting(%q) = false, want true", m)
		}
	}
	for _, m := range no {
		if isWaiting(m) {
			t.Errorf("isWaiting(%q) = true, want false", m)
		}
	}
}

func TestProjectLabel(t *testing.T) {
	if got := projectLabel("/Users/htlin/.dotfiles"); got != ".dotfiles" {
		t.Errorf("got %q", got)
	}
	if got := projectLabel(""); got != "" {
		t.Errorf("got %q", got)
	}
}
