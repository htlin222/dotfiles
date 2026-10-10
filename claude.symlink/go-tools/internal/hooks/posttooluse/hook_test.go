package posttooluse

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
	"unicode/utf8"
)

// fakeTool writes an executable shell script named name into dir.
func fakeTool(t *testing.T, dir, name, body string) {
	t.Helper()
	script := "#!/bin/sh\n" + body + "\n"
	if err := os.WriteFile(filepath.Join(dir, name), []byte(script), 0755); err != nil {
		t.Fatal(err)
	}
}

// withPath replaces PATH for the duration of a test.
func withPath(t *testing.T, dir string) {
	t.Helper()
	t.Setenv("PATH", dir)
}

func TestFormatFile(t *testing.T) {
	tests := []struct {
		name       string
		relPath    string
		tool       string // fake formatter binary name ("" = none installed)
		toolBody   string
		wantRan    bool
		wantSuffix string // expected appended content after formatting
	}{
		{"py runs ruff format on the file", "a.py", "ruff", `echo "# formatted:$1" >> "$2"`, true, "# formatted:format\n"},
		{"js runs biome format --write", "a.js", "biome", `echo "// $1 $2" >> "$3"`, true, "// format --write\n"},
		{"unknown extension", "a.xyz", "ruff", `exit 0`, false, ""},
		{"formatter not installed", "a.py", "", "", false, ""},
		{"formatter fails", "a.py", "ruff", `exit 1`, false, ""},
		{"skipped dir node_modules", "node_modules/pkg/a.js", "biome", `echo x >> "$3"`, false, ""},
		{"skipped dir .venv", ".venv/lib/a.py", "ruff", `echo x >> "$2"`, false, ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			binDir := t.TempDir()
			if tt.tool != "" {
				fakeTool(t, binDir, tt.tool, tt.toolBody)
			}
			withPath(t, binDir+":/bin:/usr/bin")
			if tt.tool == "" {
				withPath(t, binDir)
			}

			f := filepath.Join(t.TempDir(), tt.relPath)
			os.MkdirAll(filepath.Dir(f), 0755)
			os.WriteFile(f, []byte("orig\n"), 0644)

			if got := formatFile(f); got != tt.wantRan {
				t.Errorf("formatFile() = %v, want %v", got, tt.wantRan)
			}
			content, _ := os.ReadFile(f)
			if want := "orig\n" + tt.wantSuffix; string(content) != want {
				t.Errorf("file content = %q, want %q", content, want)
			}
		})
	}
}

func TestFormatFile_Timeout(t *testing.T) {
	binDir := t.TempDir()
	fakeTool(t, binDir, "ruff", "sleep 5")
	withPath(t, binDir+":/bin:/usr/bin")

	orig := formatTimeout
	formatTimeout = 200 * time.Millisecond
	defer func() { formatTimeout = orig }()

	f := filepath.Join(t.TempDir(), "a.py")
	os.WriteFile(f, []byte("x\n"), 0644)

	start := time.Now()
	if formatFile(f) {
		t.Error("timed-out formatter should report not formatted")
	}
	if elapsed := time.Since(start); elapsed > 3*time.Second {
		t.Errorf("formatFile did not honor timeout, took %v", elapsed)
	}
}

func TestLintFile(t *testing.T) {
	tests := []struct {
		name         string
		file         string
		content      string
		wantEmpty    bool
		wantContains []string
	}{
		{"hardcoded credential is high severity", "conf.txt", `password = "supersecret123"`, false,
			[]string{"Lint findings for", "可能的硬編碼憑證"}},
		{"eval is high severity", "a.txt", "eval(userInput)", false, []string{"eval/exec"}},
		{"low/medium severity only is silent", "a.txt", "console.log(1)\n// TODO: later\n", true, nil},
		{"clean file", "a.txt", "hello\n", true, nil},
		{"skipped dir", "node_modules/a.txt", "eval(x)", true, nil},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			withPath(t, t.TempDir()) // no external linters
			f := filepath.Join(t.TempDir(), tt.file)
			os.MkdirAll(filepath.Dir(f), 0755)
			os.WriteFile(f, []byte(tt.content), 0644)

			got := lintFile(f)
			if tt.wantEmpty != (got == "") {
				t.Fatalf("lintFile() = %q, wantEmpty=%v", got, tt.wantEmpty)
			}
			if strings.Contains(got, "\x1b") {
				t.Errorf("ANSI escape in findings: %q", got)
			}
			for _, w := range tt.wantContains {
				if !strings.Contains(got, w) {
					t.Errorf("want %q in %q", w, got)
				}
			}
		})
	}
}

func TestLintFile_ProcessorOutputStrippedAndCapped(t *testing.T) {
	binDir := t.TempDir()
	// shellcheck processor: fake one that fails with ANSI-colored, long output.
	fakeTool(t, binDir, "shellcheck", `i=0; while [ $i -lt 300 ]; do printf '\033[31mSC2086\033[0m: quote this\n'; i=$((i+1)); done; exit 1`)
	withPath(t, binDir+":/bin:/usr/bin")

	f := filepath.Join(t.TempDir(), "s.sh")
	os.WriteFile(f, []byte("echo $x\n"), 0644)

	got := lintFile(f)
	if !strings.Contains(got, "SC2086") {
		t.Fatalf("expected processor findings, got %q", got)
	}
	if strings.Contains(got, "\x1b") {
		t.Error("processor ANSI escapes must be stripped")
	}
	if len(got) > maxContextLen {
		t.Errorf("findings length %d exceeds cap %d", len(got), maxContextLen)
	}
}

func TestCapText(t *testing.T) {
	tests := []struct {
		name string
		in   string
		max  int
	}{
		{"short unchanged", "abc", 10},
		{"ascii truncated", strings.Repeat("a", 100), 50},
		{"cjk truncated on rune boundary", strings.Repeat("中", 100), 50},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := capText(tt.in, tt.max)
			if len(got) > tt.max {
				t.Errorf("len = %d > max %d", len(got), tt.max)
			}
			if !utf8.ValidString(got) {
				t.Errorf("invalid UTF-8: %q", got)
			}
			if len(tt.in) <= tt.max && got != tt.in {
				t.Errorf("short input changed: %q", got)
			}
			if len(tt.in) > tt.max && !strings.HasSuffix(got, "(truncated)") {
				t.Errorf("missing truncation marker: %q", got)
			}
		})
	}
}

func TestResolvePath(t *testing.T) {
	tests := []struct{ in, cwd, want string }{
		{"/abs/a.go", "/cwd", "/abs/a.go"},
		{"rel/a.go", "/cwd", "/cwd/rel/a.go"},
		{"", "/cwd", ""},
		{"a.go", "", "a.go"},
	}
	for _, tt := range tests {
		if got := resolvePath(tt.in, tt.cwd); got != tt.want {
			t.Errorf("resolvePath(%q,%q) = %q, want %q", tt.in, tt.cwd, got, tt.want)
		}
	}
}

func TestFormatterFor(t *testing.T) {
	expected := map[string]string{
		"a.js": "biome", "a.ts": "biome", "a.jsx": "biome", "a.tsx": "biome",
		"a.json": "biome", "a.css": "biome",
		"a.html": "prettier", "a.md": "prettier", "a.qmd": "prettier", "a.yaml": "prettier",
		"a.py": "ruff", "a.pyi": "ruff", "A.PY": "ruff",
		"a.R": "air",
	}
	for file, want := range expected {
		cmd := formatterFor(file)
		if len(cmd) == 0 || cmd[0] != want {
			t.Errorf("formatterFor(%q) = %v, want %s", file, cmd, want)
		}
	}
	for _, file := range []string{"a.rb", "a.rs", "a.java", "a.c", "a.sh", "a.txt"} {
		if cmd := formatterFor(file); cmd != nil {
			t.Errorf("unexpected formatter for %s: %v", file, cmd)
		}
	}
}
