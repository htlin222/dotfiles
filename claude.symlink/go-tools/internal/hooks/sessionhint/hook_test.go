package sessionhint

import (
	"bytes"
	"encoding/json"
	"os"
	"os/exec"
	"strings"
	"testing"
)

type hookOutput struct {
	Continue      bool   `json:"continue"`
	SystemMessage string `json:"systemMessage"`
}

func TestRun_StartupWithoutQING(t *testing.T) {
	if _, err := exec.LookPath("claude-hooks"); err != nil {
		t.Skip("claude-hooks not in PATH")
	}

	input, _ := json.Marshal(map[string]string{
		"session_id": "test-session-1",
		"source":     "startup",
	})

	cmd := exec.Command("claude-hooks", "session-hint")
	cmd.Stdin = bytes.NewReader(input)
	cmd.Env = filterEnv(os.Environ(), "QING")

	out, err := cmd.Output()
	if err != nil {
		t.Fatalf("claude-hooks session-hint failed: %v", err)
	}

	var result hookOutput
	if err := json.Unmarshal(out, &result); err != nil {
		t.Fatalf("failed to parse output JSON: %v\nraw output: %s", err, out)
	}

	if !strings.Contains(result.SystemMessage, "Delegation active") {
		t.Errorf("expected systemMessage to contain %q, got %q", "Delegation active", result.SystemMessage)
	}
	if strings.Contains(result.SystemMessage, "\u6211\u5728\u5927\u6e05\u7576\u7687\u5e1d") {
		t.Errorf("expected systemMessage NOT to contain Qing text, got %q", result.SystemMessage)
	}
}

func TestRun_StartupWithQING(t *testing.T) {
	if _, err := exec.LookPath("claude-hooks"); err != nil {
		t.Skip("claude-hooks not in PATH")
	}

	input, _ := json.Marshal(map[string]string{
		"session_id": "test-session-2",
		"source":     "startup",
	})

	cmd := exec.Command("claude-hooks", "session-hint")
	cmd.Stdin = bytes.NewReader(input)
	cmd.Env = append(filterEnv(os.Environ(), "QING"), "QING=true")

	out, err := cmd.Output()
	if err != nil {
		t.Fatalf("claude-hooks session-hint failed: %v", err)
	}

	var result hookOutput
	if err := json.Unmarshal(out, &result); err != nil {
		t.Fatalf("failed to parse output JSON: %v\nraw output: %s", err, out)
	}

	if !strings.Contains(result.SystemMessage, "\u6211\u5728\u5927\u6e05\u7576\u7687\u5e1d") {
		t.Errorf("expected systemMessage to contain Qing text, got %q", result.SystemMessage)
	}
	if !strings.Contains(result.SystemMessage, "Delegation active") {
		t.Errorf("expected systemMessage to contain %q, got %q", "Delegation active", result.SystemMessage)
	}
}

// filterEnv returns a copy of env with the named variable removed.
func filterEnv(env []string, name string) []string {
	prefix := name + "="
	out := make([]string, 0, len(env))
	for _, e := range env {
		if !strings.HasPrefix(e, prefix) {
			out = append(out, e)
		}
	}
	return out
}
