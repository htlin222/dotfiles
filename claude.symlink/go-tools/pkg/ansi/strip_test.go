package ansi

import "testing"

func TestStrip(t *testing.T) {
	tests := []struct {
		name, in, want string
	}{
		{"plain", "hello", "hello"},
		{"color", "\x1b[91mred\x1b[0m text", "red text"},
		{"constants", BrightYellow + "warn" + Reset, "warn"},
		{"multi param", "\x1b[1;38;5;208mx\x1b[0m", "x"},
		{"osc hyperlink", "\x1b]8;;http://a\x07link\x1b]8;;\x07", "link"},
		{"cjk kept", "\x1b[2m深夜了\x1b[0m", "深夜了"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Strip(tt.in); got != tt.want {
				t.Errorf("Strip(%q) = %q, want %q", tt.in, got, tt.want)
			}
		})
	}
}
