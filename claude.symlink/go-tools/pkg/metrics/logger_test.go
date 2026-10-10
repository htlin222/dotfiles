package metrics

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRotateIfLarge(t *testing.T) {
	tests := []struct {
		name        string
		size        int
		oldBackup   string // pre-existing .1 content, "" = none
		wantRotated bool
	}{
		{"missing file", -1, "", false},
		{"under limit", 10, "", false},
		{"exactly at limit", 100, "", false},
		{"over limit", 101, "", true},
		{"over limit overwrites old backup", 150, "stale", true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			f := filepath.Join(t.TempDir(), "x.jsonl")
			if tt.size >= 0 {
				os.WriteFile(f, []byte(strings.Repeat("a", tt.size)), 0644)
			}
			if tt.oldBackup != "" {
				os.WriteFile(f+".1", []byte(tt.oldBackup), 0644)
			}

			rotateIfLarge(f, 100)

			_, errMain := os.Stat(f)
			backup, errBak := os.ReadFile(f + ".1")
			if tt.wantRotated {
				if !os.IsNotExist(errMain) {
					t.Errorf("expected %s to be moved away", f)
				}
				if errBak != nil || len(backup) != tt.size {
					t.Errorf("expected .1 with %d bytes, got %d (err=%v)", tt.size, len(backup), errBak)
				}
			} else if tt.size >= 0 && errMain != nil {
				t.Errorf("file should remain in place: %v", errMain)
			}
		})
	}
}

func TestAppendJSONL_RotatesThenAppends(t *testing.T) {
	f := filepath.Join(t.TempDir(), "x.jsonl")
	os.WriteFile(f, make([]byte, MaxLogSize+1), 0644)

	if err := AppendJSONL(f, map[string]int{"n": 1}); err != nil {
		t.Fatal(err)
	}
	got, _ := os.ReadFile(f)
	if string(got) != "{\"n\":1}\n" {
		t.Errorf("new file content = %q, want single fresh line", got)
	}
	if info, err := os.Stat(f + ".1"); err != nil || info.Size() != MaxLogSize+1 {
		t.Errorf("expected rotated backup of %d bytes", MaxLogSize+1)
	}
}

func TestAppendJSONL_NoRotateForPromptHistoryPath(t *testing.T) {
	// appendJSONL (used for prompts.jsonl) must never rotate.
	f := filepath.Join(t.TempDir(), "prompts.jsonl")
	os.WriteFile(f, make([]byte, MaxLogSize+1), 0644)

	if err := appendJSONL(f, map[string]int{"n": 1}); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(f + ".1"); !os.IsNotExist(err) {
		t.Error("prompt history must not be rotated")
	}
	if info, _ := os.Stat(f); info.Size() != MaxLogSize+1+int64(len("{\"n\":1}\n")) {
		t.Errorf("expected append onto existing file, size=%d", info.Size())
	}
}
