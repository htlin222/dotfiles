package groq

import "testing"

func TestParseEnvValue(t *testing.T) {
	tests := []struct {
		name    string
		content string
		want    string
	}{
		{"plain", "GROQ_API_KEY=gsk_abc123", "gsk_abc123"},
		{"double quoted", `GROQ_API_KEY="gsk_abc123"`, "gsk_abc123"},
		{"single quoted", `GROQ_API_KEY='gsk_abc123'`, "gsk_abc123"},
		{"export prefix", "export GROQ_API_KEY=gsk_abc123", "gsk_abc123"},
		{"with comments and other keys", "# comment\nOTHER=x\nGROQ_API_KEY=gsk_abc123\n", "gsk_abc123"},
		{"spaces around equals value", "GROQ_API_KEY= gsk_abc123 ", "gsk_abc123"},
		{"missing", "OTHER=x", ""},
		{"empty", "", ""},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := parseEnvValue(tt.content, "GROQ_API_KEY"); got != tt.want {
				t.Errorf("parseEnvValue() = %q, want %q", got, tt.want)
			}
		})
	}
}
