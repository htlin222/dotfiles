package stop

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/htlin/claude-tools/internal/config"
)

// --- getRecentEditedFiles ---

func TestGetRecentEditedFiles_NoFile(t *testing.T) {
	origLogDir := config.LogDir
	config.LogDir = filepath.Join(t.TempDir(), "nope")
	defer func() { config.LogDir = origLogDir }()

	files := getRecentEditedFiles()
	if len(files) != 0 {
		t.Errorf("expected 0 files, got %d", len(files))
	}
}

func TestGetRecentEditedFiles_ValidEntries(t *testing.T) {
	tmpDir := t.TempDir()
	origLogDir := config.LogDir
	config.LogDir = tmpDir
	defer func() { config.LogDir = origLogDir }()

	realFile := filepath.Join(tmpDir, "existing.go")
	os.WriteFile(realFile, []byte("package main"), 0644)

	now := time.Now()
	recent := map[string]any{
		"timestamp": now.Add(-5 * time.Minute).Format(time.RFC3339),
		"file":      realFile,
	}
	old := map[string]any{
		"timestamp": now.Add(-120 * time.Minute).Format(time.RFC3339),
		"file":      realFile,
	}
	ghost := map[string]any{
		"timestamp": now.Format(time.RFC3339),
		"file":      filepath.Join(tmpDir, "ghost.go"),
	}

	var lines []byte
	for _, entry := range []map[string]any{recent, old, ghost} {
		b, _ := json.Marshal(entry)
		lines = append(lines, b...)
		lines = append(lines, '\n')
	}
	os.WriteFile(filepath.Join(tmpDir, "edits.jsonl"), lines, 0644)

	files := getRecentEditedFiles()
	if len(files) != 1 {
		t.Errorf("expected 1 recent existing file, got %d", len(files))
	}
	if !files[realFile] {
		t.Errorf("expected %s in result", realFile)
	}
}

func TestGetRecentEditedFiles_MalformedJSON(t *testing.T) {
	tmpDir := t.TempDir()
	origLogDir := config.LogDir
	config.LogDir = tmpDir
	defer func() { config.LogDir = origLogDir }()

	os.WriteFile(filepath.Join(tmpDir, "edits.jsonl"), []byte("not json\n{bad\n"), 0644)

	files := getRecentEditedFiles()
	if len(files) != 0 {
		t.Errorf("expected 0 files from malformed input, got %d", len(files))
	}
}

// --- formatEditedFiles ---

func TestFormatEditedFiles_NoFormatter(t *testing.T) {
	files := map[string]bool{
		"/tmp/test.xyz": true,
	}
	count := formatEditedFiles(files)
	if count != 0 {
		t.Errorf("expected 0 formatted for unknown ext, got %d", count)
	}
}

func TestFormatEditedFiles_FormatterNotInstalled(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "test.js")
	os.WriteFile(f, []byte("var x = 1"), 0644)

	origPath := os.Getenv("PATH")
	os.Setenv("PATH", tmpDir)
	defer os.Setenv("PATH", origPath)

	files := map[string]bool{f: true}
	count := formatEditedFiles(files)
	if count != 0 {
		t.Errorf("expected 0 when formatter not installed, got %d", count)
	}
}

// --- formatters map ---

func TestFormattersMap_KnownExtensions(t *testing.T) {
	expected := map[string]string{
		".js":   "biome",
		".ts":   "biome",
		".jsx":  "biome",
		".tsx":  "biome",
		".json": "biome",
		".css":  "biome",
		".html": "prettier",
		".md":   "prettier",
		".qmd":  "prettier",
		".yaml": "prettier",
		".py":   "ruff",
		".pyi":  "ruff",
	}

	for ext, wantCmd := range expected {
		cmd, ok := formatters[ext]
		if !ok {
			t.Errorf("extension %s not in formatters map", ext)
			continue
		}
		if cmd[0] != wantCmd {
			t.Errorf("formatters[%s][0] = %q, want %q", ext, cmd[0], wantCmd)
		}
	}
}

func TestFormattersMap_UnknownExtension(t *testing.T) {
	unknowns := []string{".rb", ".rs", ".java", ".c", ".sh", ".txt"}
	for _, ext := range unknowns {
		if _, ok := formatters[ext]; ok {
			t.Errorf("unexpected formatter for %s", ext)
		}
	}
}
