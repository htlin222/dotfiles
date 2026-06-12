package groq

import (
	"os"
	"testing"
	"unicode/utf8"
)

// Run manually with: GROQ_LIVE_TEST=1 go test ./pkg/groq/ -run TestSummarizeLive -v
func TestSummarizeLive(t *testing.T) {
	if os.Getenv("GROQ_LIVE_TEST") == "" {
		t.Skip("set GROQ_LIVE_TEST=1 to run the live API test")
	}
	if APIKey() == "" {
		t.Skip("no API key configured")
	}
	long := "I refactored the stop hook to load the Groq API key from a git-ignored " +
		".env file, added a new pkg/groq package with a 10-second timeout and " +
		"fallback truncation, wired it into the notification path, and verified " +
		"everything with go vet and the full test suite before reinstalling the binary."
	got, err := SummarizeZHTW(long)
	if err != nil {
		t.Fatalf("SummarizeZHTW failed: %v", err)
	}
	n := utf8.RuneCountInString(got)
	if n == 0 || n > 50 {
		t.Fatalf("summary length %d out of range: %q", n, got)
	}
	t.Logf("summary (%d runes): %s", n, got)
}
