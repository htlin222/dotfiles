package snapshot

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

// withTempSnapshotDir sets snapshotDir to a temp directory for the test duration.
func withTempSnapshotDir(t *testing.T) {
	t.Helper()
	orig := snapshotDir
	snapshotDir = t.TempDir()
	t.Cleanup(func() { snapshotDir = orig })
}

func TestCwdHash_Deterministic(t *testing.T) {
	h1 := cwdHash("/Users/alice/project-a")
	h2 := cwdHash("/Users/alice/project-a")
	if h1 != h2 {
		t.Errorf("cwdHash not deterministic: %q != %q", h1, h2)
	}
	if len(h1) != 8 {
		t.Errorf("cwdHash length = %d, want 8", len(h1))
	}
}

func TestCwdHash_DifferentCWDs(t *testing.T) {
	h1 := cwdHash("/Users/alice/project-a")
	h2 := cwdHash("/Users/alice/project-b")
	if h1 == h2 {
		t.Errorf("different CWDs produced same hash: %q", h1)
	}
}

func TestSnapshotPathForCWD(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := "/Users/alice/myproject"
	got := snapshotPathForCWD(cwd)
	want := filepath.Join(snapshotDir, SnapshotPrefix+cwdHash(cwd)+SnapshotSuffix)
	if got != want {
		t.Errorf("snapshotPathForCWD() = %q, want %q", got, want)
	}
}

func TestGenerate_WritesToCWDBasedPath(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := t.TempDir()

	err := Generate("", cwd, "session-123", "")
	if err != nil {
		t.Fatalf("Generate() error = %v", err)
	}

	p := snapshotPathForCWD(cwd)
	data, err := os.ReadFile(p)
	if err != nil {
		t.Fatalf("reading snapshot: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "# Last Session Context") {
		t.Error("snapshot missing header")
	}
	project := filepath.Base(cwd)
	if !strings.Contains(content, project) {
		t.Errorf("snapshot missing project name %q", project)
	}
}

func TestCrossCWD_Isolation(t *testing.T) {
	withTempSnapshotDir(t)
	cwdA := t.TempDir()
	cwdB := t.TempDir()

	// Session A writes snapshot
	if err := Generate("", cwdA, "session-a", ""); err != nil {
		t.Fatalf("Generate(A) error = %v", err)
	}

	// Session B writes snapshot
	if err := Generate("", cwdB, "session-b", ""); err != nil {
		t.Fatalf("Generate(B) error = %v", err)
	}

	// Consume(cwdA) should get A's content
	gotA, err := Consume(cwdA)
	if err != nil {
		t.Fatalf("Consume(cwdA) error = %v", err)
	}
	projectA := filepath.Base(cwdA)
	if !strings.Contains(gotA, projectA) {
		t.Errorf("Consume(cwdA) got wrong content, expected project %q", projectA)
	}

	// Consume(cwdB) should get B's content
	gotB, err := Consume(cwdB)
	if err != nil {
		t.Fatalf("Consume(cwdB) error = %v", err)
	}
	projectB := filepath.Base(cwdB)
	if !strings.Contains(gotB, projectB) {
		t.Errorf("Consume(cwdB) got wrong content, expected project %q", projectB)
	}
}

func TestIsAvailable_FreshSnapshot(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := "/test/project"

	p := snapshotPathForCWD(cwd)
	if err := os.WriteFile(p, []byte("content"), 0644); err != nil {
		t.Fatal(err)
	}

	if !IsAvailable(cwd) {
		t.Error("IsAvailable() = false, want true for fresh snapshot")
	}
}

func TestIsAvailable_NoSnapshot(t *testing.T) {
	withTempSnapshotDir(t)

	if IsAvailable("/nonexistent/project") {
		t.Error("IsAvailable() = true, want false when no snapshot exists")
	}
}

func TestIsAvailable_StaleSnapshot(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := "/test/stale-project"

	p := snapshotPathForCWD(cwd)
	if err := os.WriteFile(p, []byte("stale"), 0644); err != nil {
		t.Fatal(err)
	}
	stale := time.Now().Add(-25 * time.Hour)
	os.Chtimes(p, stale, stale)

	if IsAvailable(cwd) {
		t.Error("IsAvailable() = true, want false for stale snapshot")
	}
}

func TestConsume_ReadsAndRenames(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := "/test/consume-project"

	p := snapshotPathForCWD(cwd)
	content := "# Test Snapshot Content"
	if err := os.WriteFile(p, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}

	got, err := Consume(cwd)
	if err != nil {
		t.Fatalf("Consume() error = %v", err)
	}
	if got != content {
		t.Errorf("Consume() = %q, want %q", got, content)
	}

	// Original file should be gone
	if _, err := os.Stat(p); !os.IsNotExist(err) {
		t.Error("original snapshot still exists after Consume()")
	}

	// .consumed file should exist
	consumed := strings.TrimSuffix(p, SnapshotSuffix) + ".consumed"
	if _, err := os.Stat(consumed); os.IsNotExist(err) {
		t.Error(".consumed file does not exist after Consume()")
	}
}

func TestConsume_SecondConsumeFails(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := "/test/double-consume"

	p := snapshotPathForCWD(cwd)
	if err := os.WriteFile(p, []byte("content"), 0644); err != nil {
		t.Fatal(err)
	}

	// First consume succeeds
	if _, err := Consume(cwd); err != nil {
		t.Fatalf("first Consume() error = %v", err)
	}

	// Second consume should fail
	_, err := Consume(cwd)
	if err == nil {
		t.Error("second Consume() should fail, got nil error")
	}
}

func TestConsume_NoSnapshot(t *testing.T) {
	withTempSnapshotDir(t)

	_, err := Consume("/nonexistent/project")
	if err == nil {
		t.Error("Consume() should fail when no snapshot exists")
	}
}

func TestConsume_StaleSnapshot(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := "/test/stale-consume"

	p := snapshotPathForCWD(cwd)
	if err := os.WriteFile(p, []byte("stale"), 0644); err != nil {
		t.Fatal(err)
	}
	stale := time.Now().Add(-25 * time.Hour)
	os.Chtimes(p, stale, stale)

	_, err := Consume(cwd)
	if err == nil {
		t.Error("Consume() should fail for stale snapshot")
	}
}

func TestGenerate_WithLastAssistantMessage(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := t.TempDir()

	err := Generate("", cwd, "session-456", "I've completed the refactoring.")
	if err != nil {
		t.Fatalf("Generate() error = %v", err)
	}

	p := snapshotPathForCWD(cwd)
	data, err := os.ReadFile(p)
	if err != nil {
		t.Fatalf("reading snapshot: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "I've completed the refactoring.") {
		t.Error("snapshot missing last_assistant_message content")
	}
	if !strings.Contains(content, "### Assistant") {
		t.Error("snapshot missing Assistant header for last_assistant_message")
	}
}

func TestGenerate_LastAssistantMessageReplacesTranscript(t *testing.T) {
	withTempSnapshotDir(t)
	cwd := t.TempDir()

	// Create a transcript with an assistant turn
	tmpFile := filepath.Join(t.TempDir(), "transcript.jsonl")
	lines := []string{
		`{"type":"human","message":{"role":"user","content":"do something"}}`,
		`{"type":"assistant","message":{"role":"assistant","content":"old response"}}`,
	}
	if err := os.WriteFile(tmpFile, []byte(strings.Join(lines, "\n")), 0644); err != nil {
		t.Fatal(err)
	}

	// Provide last_assistant_message which should replace the transcript's last assistant turn
	err := Generate(tmpFile, cwd, "session-789", "new official response")
	if err != nil {
		t.Fatalf("Generate() error = %v", err)
	}

	p := snapshotPathForCWD(cwd)
	data, err := os.ReadFile(p)
	if err != nil {
		t.Fatalf("reading snapshot: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "new official response") {
		t.Error("snapshot should contain the official last_assistant_message")
	}
	if strings.Contains(content, "old response") {
		t.Error("snapshot should NOT contain the old transcript response")
	}
}

func TestExtractText_String(t *testing.T) {
	got := extractText("hello world")
	if got != "hello world" {
		t.Errorf("extractText(string) = %q, want %q", got, "hello world")
	}
}

func TestExtractText_Array(t *testing.T) {
	content := []interface{}{
		map[string]interface{}{"type": "text", "text": "hello"},
		map[string]interface{}{"type": "tool_use", "name": "bash"},
		map[string]interface{}{"type": "text", "text": "world"},
	}
	got := extractText(content)
	want := "hello\nworld"
	if got != want {
		t.Errorf("extractText(array) = %q, want %q", got, want)
	}
}

func TestExtractText_Nil(t *testing.T) {
	got := extractText(nil)
	if got != "" {
		t.Errorf("extractText(nil) = %q, want empty", got)
	}
}

func TestExtractConversation_EmptyPath(t *testing.T) {
	turns := extractConversation("")
	if turns != nil {
		t.Errorf("extractConversation(\"\") = %v, want nil", turns)
	}
}

func TestExtractConversation_MissingFile(t *testing.T) {
	turns := extractConversation("/nonexistent/path.jsonl")
	if turns != nil {
		t.Errorf("extractConversation(nonexistent) = %v, want nil", turns)
	}
}

func TestExtractConversation_ParsesJSONL(t *testing.T) {
	tmpFile := filepath.Join(t.TempDir(), "transcript.jsonl")
	lines := []string{
		`{"type":"human","message":{"role":"user","content":"hello"}}`,
		`{"type":"assistant","message":{"role":"assistant","content":"hi there"}}`,
		`{"type":"tool_result","message":{"role":"tool","content":"output"}}`,
		`{"type":"human","message":{"role":"user","content":"thanks"}}`,
	}
	if err := os.WriteFile(tmpFile, []byte(strings.Join(lines, "\n")), 0644); err != nil {
		t.Fatal(err)
	}

	turns := extractConversation(tmpFile)
	if len(turns) != 3 {
		t.Fatalf("extractConversation() returned %d turns, want 3", len(turns))
	}

	if turns[0].Role != "user" || turns[0].Text != "hello" {
		t.Errorf("turn[0] = %+v, want user/hello", turns[0])
	}
	if turns[1].Role != "assistant" || turns[1].Text != "hi there" {
		t.Errorf("turn[1] = %+v, want assistant/hi there", turns[1])
	}
	if turns[2].Role != "user" || turns[2].Text != "thanks" {
		t.Errorf("turn[2] = %+v, want user/thanks", turns[2])
	}
}

func TestExtractConversation_MaxTurns(t *testing.T) {
	tmpFile := filepath.Join(t.TempDir(), "transcript.jsonl")
	var lines []string
	for i := 0; i < 10; i++ {
		lines = append(lines, `{"type":"human","message":{"role":"user","content":"msg"}}`)
	}
	if err := os.WriteFile(tmpFile, []byte(strings.Join(lines, "\n")), 0644); err != nil {
		t.Fatal(err)
	}

	turns := extractConversation(tmpFile)
	if len(turns) != MaxTurns {
		t.Errorf("extractConversation() returned %d turns, want %d (MaxTurns)", len(turns), MaxTurns)
	}
}

func TestExtractConversation_MaxTotalLen(t *testing.T) {
	tmpFile := filepath.Join(t.TempDir(), "transcript.jsonl")
	// Create MaxTurns entries each at MaxTextLen. Total = MaxTurns*MaxTextLen
	// which should exceed MaxTotalLen, causing oldest turns to be dropped.
	var lines []string
	for i := 0; i < MaxTurns; i++ {
		text := strings.Repeat("a", MaxTextLen)
		lines = append(lines, `{"type":"human","message":{"role":"user","content":"`+text+`"}}`)
	}
	if err := os.WriteFile(tmpFile, []byte(strings.Join(lines, "\n")), 0644); err != nil {
		t.Fatal(err)
	}

	// Sanity: MaxTurns * MaxTextLen must exceed MaxTotalLen for this test to be meaningful
	if MaxTurns*MaxTextLen <= MaxTotalLen {
		t.Skip("MaxTurns*MaxTextLen does not exceed MaxTotalLen; adjust constants")
	}

	turns := extractConversation(tmpFile)
	totalLen := 0
	for _, turn := range turns {
		totalLen += len(turn.Text)
	}
	if totalLen > MaxTotalLen {
		t.Errorf("total text length %d exceeds MaxTotalLen %d", totalLen, MaxTotalLen)
	}
	if len(turns) >= MaxTurns {
		t.Errorf("expected fewer than %d turns after MaxTotalLen enforcement, got %d", MaxTurns, len(turns))
	}
}

func TestExtractConversation_TruncatesLongText(t *testing.T) {
	tmpFile := filepath.Join(t.TempDir(), "transcript.jsonl")
	longText := strings.Repeat("x", MaxTextLen+500)
	line := `{"type":"human","message":{"role":"user","content":"` + longText + `"}}`
	if err := os.WriteFile(tmpFile, []byte(line), 0644); err != nil {
		t.Fatal(err)
	}

	turns := extractConversation(tmpFile)
	if len(turns) != 1 {
		t.Fatalf("got %d turns, want 1", len(turns))
	}
	if len(turns[0].Text) != MaxTextLen+3 { // +3 for "..."
		t.Errorf("truncated text length = %d, want %d", len(turns[0].Text), MaxTextLen+3)
	}
	if !strings.HasSuffix(turns[0].Text, "...") {
		t.Error("truncated text should end with '...'")
	}
}
