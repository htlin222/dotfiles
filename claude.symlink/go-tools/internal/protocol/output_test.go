package protocol

import (
	"encoding/json"
	"testing"
)

func TestPreToolUseDeny(t *testing.T) {
	var got map[string]any
	if err := json.Unmarshal([]byte(PreToolUseDeny("no")), &got); err != nil {
		t.Fatal(err)
	}
	if _, ok := got["decision"]; ok {
		t.Errorf("deprecated top-level decision present: %v", got)
	}
	hso, _ := got["hookSpecificOutput"].(map[string]any)
	want := map[string]string{
		"hookEventName":            "PreToolUse",
		"permissionDecision":       "deny",
		"permissionDecisionReason": "no",
	}
	for k, v := range want {
		if hso[k] != v {
			t.Errorf("hookSpecificOutput[%q] = %v, want %q", k, hso[k], v)
		}
	}
}

func TestPostToolUseContext(t *testing.T) {
	want := `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"lint"}}`
	if got := PostToolUseContext("lint"); got != want {
		t.Errorf("got %s, want %s", got, want)
	}
}

func TestUserPromptResponse(t *testing.T) {
	tests := []struct {
		name, ctx, sys, want string
	}{
		{"both empty", "", "", ""},
		{"context only", "c", "", `{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"c"}}`},
		{"system only", "", "s", `{"systemMessage":"s"}`},
		{"both", "c", "s", `{"systemMessage":"s","hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"c"}}`},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := UserPromptResponse(tt.ctx, tt.sys); got != tt.want {
				t.Errorf("got %s, want %s", got, tt.want)
			}
		})
	}
}
