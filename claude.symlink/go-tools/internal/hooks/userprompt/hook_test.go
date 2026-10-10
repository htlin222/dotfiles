package userprompt

import (
	"strings"
	"testing"
	"time"

	"github.com/htlin/claude-tools/internal/state"
)

func TestBuildContext(t *testing.T) {
	tests := []struct {
		name         string
		persona      string
		snapshot     string
		imgs         []string
		wantEmpty    bool
		wantContains []string
	}{
		{"nothing", "", "", nil, true, nil},
		{"persona only", "你是乾隆", "", nil, false, []string{"你是乾隆"}},
		{"snapshot only", "", "did X", nil, false, []string{"## Previous Session Context", "did X"}},
		{"images", "", "", []string{"/tmp/screenshot/a.png", "/tmp/screenshot/b.png"}, false,
			[]string{"## Screenshot", "/tmp/screenshot/a.png", "/tmp/screenshot/b.png"}},
		{"all three", "P", "S", []string{"/i.png"}, false, []string{"P", "S", "/i.png"}},
		{"ansi in snapshot stripped", "", "\x1b[91mred\x1b[0m", nil, false, []string{"red"}},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := buildContext(tt.persona, tt.snapshot, tt.imgs)
			if tt.wantEmpty != (got == "") {
				t.Fatalf("buildContext() = %q, wantEmpty=%v", got, tt.wantEmpty)
			}
			if strings.Contains(got, "\x1b") {
				t.Errorf("ANSI escape in additionalContext: %q", got)
			}
			for _, w := range tt.wantContains {
				if !strings.Contains(got, w) {
					t.Errorf("want %q in %q", w, got)
				}
			}
		})
	}
}

func TestCheckTimeReminder_PlainText(t *testing.T) {
	st := &state.State{SessionStart: time.Now().Add(-3 * time.Hour).Format(time.RFC3339)}
	got := checkTimeReminder(st)
	if !strings.Contains(got, "已工作") {
		t.Errorf("expected long-session reminder after 3h, got %q", got)
	}
	if strings.Contains(got, "\x1b") {
		t.Errorf("ANSI escape in reminder: %q", got)
	}
}

func TestIsSyntheticPrompt(t *testing.T) {
	tests := []struct {
		prompt string
		want   bool
	}{
		{"<task-notification>\n<status>completed</status> the @LAST snapshot", true},
		{"  <system-reminder>x</system-reminder>", true},
		{"please load @LAST", false},
		{"/commit fix things", false},
	}
	for _, tt := range tests {
		if got := isSyntheticPrompt(tt.prompt); got != tt.want {
			t.Errorf("isSyntheticPrompt(%q) = %v, want %v", tt.prompt, got, tt.want)
		}
	}
}

func TestTriggerTokens(t *testing.T) {
	tests := []struct {
		re     string
		prompt string
		want   bool
	}{
		{"last", "@LAST continue", true},
		{"last", "continue from @last", true},
		{"last", "mail me@last.com", false},
		{"last", "@lastly", false},
		{"img", "看 @img", true},
		{"img", "@img2 and @img x3", true},
		{"img", "user@img.example", false},
		{"img", "@imgur link", false},
	}
	for _, tt := range tests {
		re := lastRe
		if tt.re == "img" {
			re = imgRe
		}
		if got := re.MatchString(tt.prompt); got != tt.want {
			t.Errorf("%s.MatchString(%q) = %v, want %v", tt.re, tt.prompt, got, tt.want)
		}
	}
}
