package delegateedits

import (
	"strings"
	"testing"

	"github.com/htlin/claude-tools/internal/protocol"
)

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

func TestDecide(t *testing.T) {
	big := strings.Repeat("x\n", maxWriteLines) // maxWriteLines+1 lines
	small := strings.Repeat("x\n", maxWriteLines-1)
	src := "/home/user/project/main.go"

	tests := []struct {
		name      string
		input     protocol.HookInput
		force     bool
		wantBlock bool
	}{
		{"main session big Write", protocol.HookInput{ToolName: "Write", ToolInput: protocol.ToolInput{FilePath: src, Content: big}}, false, true},
		{"main session small Write", protocol.HookInput{ToolName: "Write", ToolInput: protocol.ToolInput{FilePath: src, Content: small}}, false, false},
		{"main session Edit", protocol.HookInput{ToolName: "Edit", ToolInput: protocol.ToolInput{FilePath: src}}, false, false},
		{"subagent big Write", protocol.HookInput{ToolName: "Write", AgentID: "a1", AgentType: "general-purpose", ToolInput: protocol.ToolInput{FilePath: src, Content: big}}, false, false},
		{"subagent Edit in force mode", protocol.HookInput{ToolName: "Edit", AgentID: "a1", ToolInput: protocol.ToolInput{FilePath: src}}, true, false},
		{"main session Edit in force mode", protocol.HookInput{ToolName: "Edit", ToolInput: protocol.ToolInput{FilePath: src}}, true, true},
		{"allowlisted big Write", protocol.HookInput{ToolName: "Write", ToolInput: protocol.ToolInput{FilePath: "/p/README.md", Content: big}}, false, false},
		{"allowlisted in force mode", protocol.HookInput{ToolName: "Edit", ToolInput: protocol.ToolInput{FilePath: "/p/Makefile"}}, true, false},
		{"non-write tool", protocol.HookInput{ToolName: "Read", ToolInput: protocol.ToolInput{FilePath: src}}, true, false},
		{"MultiEdit no longer handled", protocol.HookInput{ToolName: "MultiEdit", ToolInput: protocol.ToolInput{FilePath: src}}, true, false},
		{"no file path", protocol.HookInput{ToolName: "Write", ToolInput: protocol.ToolInput{Content: big}}, false, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := decide(&tt.input, tt.force) != ""
			if got != tt.wantBlock {
				t.Errorf("decide() blocked=%v, want %v", got, tt.wantBlock)
			}
		})
	}
}
