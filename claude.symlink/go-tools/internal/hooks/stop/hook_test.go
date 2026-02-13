package stop

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

// --- getGitDirtyFiles ---

func TestGetGitDirtyFiles_NoGitRepo(t *testing.T) {
	tmpDir := t.TempDir()
	files := getGitDirtyFiles(tmpDir)
	if len(files) != 0 {
		t.Errorf("expected 0 files for non-git dir, got %d", len(files))
	}
}

func TestGetGitDirtyFiles_EmptyCwd(t *testing.T) {
	files := getGitDirtyFiles("")
	if len(files) != 0 {
		t.Errorf("expected 0 files for empty cwd, got %d", len(files))
	}
}

func TestGetGitDirtyFiles_CleanRepo(t *testing.T) {
	tmpDir := t.TempDir()
	run := func(args ...string) {
		cmd := exec.Command(args[0], args[1:]...)
		cmd.Dir = tmpDir
		cmd.Run()
	}
	run("git", "init")
	run("git", "config", "user.email", "test@test.com")
	run("git", "config", "user.name", "Test")
	os.WriteFile(filepath.Join(tmpDir, "file.go"), []byte("package main"), 0644)
	run("git", "add", ".")
	run("git", "commit", "-m", "init")

	files := getGitDirtyFiles(tmpDir)
	if len(files) != 0 {
		t.Errorf("expected 0 files for clean repo, got %d", len(files))
	}
}

func TestGetGitDirtyFiles_UnstagedChanges(t *testing.T) {
	tmpDir := t.TempDir()
	// Resolve symlinks (macOS /var -> /private/var)
	tmpDir, _ = filepath.EvalSymlinks(tmpDir)
	run := func(args ...string) {
		cmd := exec.Command(args[0], args[1:]...)
		cmd.Dir = tmpDir
		cmd.Run()
	}
	run("git", "init")
	run("git", "config", "user.email", "test@test.com")
	run("git", "config", "user.name", "Test")
	f := filepath.Join(tmpDir, "file.go")
	os.WriteFile(f, []byte("package main"), 0644)
	run("git", "add", ".")
	run("git", "commit", "-m", "init")

	// Modify but don't stage
	os.WriteFile(f, []byte("package main\n// changed"), 0644)

	files := getGitDirtyFiles(tmpDir)
	if len(files) != 1 {
		t.Errorf("expected 1 unstaged file, got %d", len(files))
	}
	if !files[f] {
		t.Errorf("expected %s in result", f)
	}
}

func TestGetGitDirtyFiles_StagedNotReturned(t *testing.T) {
	tmpDir := t.TempDir()
	run := func(args ...string) {
		cmd := exec.Command(args[0], args[1:]...)
		cmd.Dir = tmpDir
		cmd.Run()
	}
	run("git", "init")
	run("git", "config", "user.email", "test@test.com")
	run("git", "config", "user.name", "Test")
	f := filepath.Join(tmpDir, "file.go")
	os.WriteFile(f, []byte("package main"), 0644)
	run("git", "add", ".")
	run("git", "commit", "-m", "init")

	// Modify and stage
	os.WriteFile(f, []byte("package main\n// staged"), 0644)
	run("git", "add", ".")

	files := getGitDirtyFiles(tmpDir)
	if len(files) != 0 {
		t.Errorf("expected 0 files (already staged), got %d", len(files))
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
