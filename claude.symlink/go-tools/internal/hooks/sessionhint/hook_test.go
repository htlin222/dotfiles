package sessionhint

import (
	"strings"
	"testing"
)

func TestBuildMessage(t *testing.T) {
	const qingText = "我在大清當皇帝"
	const lastText = "@LAST"

	tests := []struct {
		name         string
		source       string
		qing         string
		snapshot     bool
		wantEmpty    bool
		wantContains []string
		wantAbsent   []string
	}{
		{"startup plain", "startup", "", false, true, nil, []string{qingText, lastText}},
		{"startup with QING", "startup", "true", false, false, []string{qingText}, []string{lastText}},
		{"QING case-insensitive", "startup", "TRUE", false, false, []string{qingText}, nil},
		{"clear with snapshot", "clear", "", true, false, []string{lastText}, []string{qingText}},
		{"clear without snapshot", "clear", "", false, true, nil, nil},
		{"startup with snapshot gives no hint", "startup", "", true, true, nil, nil},
		{"no delegation reminder", "clear", "true", true, false, []string{qingText, lastText}, []string{"delegation", "MultiEdit"}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := buildMessage(tt.source, tt.qing, tt.snapshot)
			if tt.wantEmpty != (got == "") {
				t.Fatalf("buildMessage() = %q, wantEmpty=%v", got, tt.wantEmpty)
			}
			if strings.Contains(got, "\x1b[") {
				t.Errorf("ANSI escape in %q", got)
			}
			for _, s := range tt.wantContains {
				if !strings.Contains(got, s) {
					t.Errorf("want %q in %q", s, got)
				}
			}
			for _, s := range tt.wantAbsent {
				if strings.Contains(got, s) {
					t.Errorf("did not want %q in %q", s, got)
				}
			}
		})
	}
}
