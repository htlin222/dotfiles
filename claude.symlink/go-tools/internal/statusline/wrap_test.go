package statusline

import (
	"strings"
	"testing"
)

func TestWrapPromptWordBoundary(t *testing.T) {
	cases := []struct {
		name  string
		in    string
		width int
		want  []string
	}{
		{"short", "hello world", 20, []string{"hello world"}},
		{"wrap at space", "comment out the dadjoke module and the uname", 20, []string{"comment out the", "dadjoke module and…"}},
		{"no space hard break", strings.Repeat("a", 25), 20, []string{strings.Repeat("a", 20), strings.Repeat("a", 5)}},
		{"cjk", strings.Repeat("好", 45), 20, []string{strings.Repeat("好", 20), strings.Repeat("好", 19) + "…"}},
	}
	for _, c := range cases {
		got := wrapPrompt(c.in, c.width)
		if len(got) != len(c.want) {
			t.Fatalf("%s: got %d lines %q, want %q", c.name, len(got), got, c.want)
		}
		for i := range got {
			if got[i] != c.want[i] {
				t.Errorf("%s line %d: got %q want %q", c.name, i, got[i], c.want[i])
			}
		}
		for i, l := range got {
			if n := len([]rune(l)); n > c.width {
				t.Errorf("%s line %d exceeds width: %d > %d (%q)", c.name, i, n, c.width, l)
			}
		}
	}
}
