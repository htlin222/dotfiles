package delegateedits

import "testing"

func TestIsAllowed(t *testing.T) {
	tests := []struct {
		name string
		path string
		want bool
	}{
		// Disallowed extensions
		{"go file", "/home/user/project/main.go", false},
		{"tsx file", "/home/user/project/App.tsx", false},

		// Allowed by extension (.md)
		{"md file", "/home/user/project/notes.md", true},
		{"README.md", "/home/user/project/README.md", true},

		// Allowed by basename
		{"CLAUDE.md", "/home/user/project/CLAUDE.md", true},
		{"Makefile", "/home/user/project/Makefile", true},
		{".gitignore", "/home/user/project/.gitignore", true},
		{"settings.json", "/home/user/project/.vscode/settings.json", true},
		{"settings.local.json", "/home/user/project/.vscode/settings.local.json", true},

		// Allowed by path fragment
		{"path with /.claude/", "/home/user/.claude/config.yaml", true},
		{"path with /claude.symlink/go-tools/", "/home/user/claude.symlink/go-tools/main.go", true},
		{"path with /.claude/plans/", "/home/user/.claude/plans/step1.txt", true},

		// Disallowed paths
		{"js file in src", "/src/app.js", false},
		{"python file", "/home/user/project/main.py", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isAllowed(tt.path)
			if got != tt.want {
				t.Errorf("isAllowed(%q) = %v, want %v", tt.path, got, tt.want)
			}
		})
	}
}
