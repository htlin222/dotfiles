// claude-hooks is the unified Claude Code hooks binary.
package main

import (
	"fmt"
	"os"

	"github.com/htlin/claude-tools/internal/hooks/autostage"
	"github.com/htlin/claude-tools/internal/hooks/branchguard"
	"github.com/htlin/claude-tools/internal/hooks/checkfileexists"
	"github.com/htlin/claude-tools/internal/hooks/checkreadexists"
	"github.com/htlin/claude-tools/internal/hooks/checkrm"
	"github.com/htlin/claude-tools/internal/hooks/depremind"
	"github.com/htlin/claude-tools/internal/hooks/envvalidation"
	"github.com/htlin/claude-tools/internal/hooks/fileguard"
	"github.com/htlin/claude-tools/internal/hooks/largewriteguard"
	"github.com/htlin/claude-tools/internal/hooks/notification"
	"github.com/htlin/claude-tools/internal/hooks/posttooluse"
	"github.com/htlin/claude-tools/internal/hooks/precompact"
	"github.com/htlin/claude-tools/internal/hooks/sessionhint"
	"github.com/htlin/claude-tools/internal/hooks/stop"
	"github.com/htlin/claude-tools/internal/hooks/subagentstop"
	"github.com/htlin/claude-tools/internal/hooks/todotracker"
	"github.com/htlin/claude-tools/internal/hooks/userprompt"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "user-prompt":
		userprompt.Run()
	case "post-tool-use":
		posttooluse.Run()
	case "file-guard":
		fileguard.Run()
	case "check-rm":
		checkrm.Run()
	case "branch-guard":
		branchguard.Run()
	case "large-write-guard":
		largewriteguard.Run()
	case "check-file-exists":
		checkfileexists.Run()
	case "check-read-exists":
		checkreadexists.Run()
	case "notification":
		notification.Run()
	case "subagent-stop":
		subagentstop.Run()
	case "auto-stage":
		autostage.Run()
	case "dep-remind":
		depremind.Run()
	case "todo-tracker":
		todotracker.Run()
	case "pre-compact":
		precompact.Run()
	case "stop":
		stop.Run()
	case "session-hint":
		sessionhint.Run()
	case "env-validate":
		envvalidation.Run()
	case "help", "-h", "--help":
		printUsage()
	case "version", "-v", "--version":
		fmt.Println("claude-hooks v1.0.0")
	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n", os.Args[1])
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println(`claude-hooks - Claude Code hooks in Go

Usage:
  claude-hooks <command>

Commands:
  user-prompt        Handle UserPromptSubmit events
  post-tool-use      Handle PostToolUse events
  file-guard         Block access to sensitive files (PreToolUse)
  check-rm           Block rm commands (PreToolUse)
  branch-guard       Block destructive git on protected branches (PreToolUse)
  large-write-guard  Warn on large file writes >500 lines (PreToolUse)
  check-file-exists  Block cat/bat if file not found (PreToolUse)
  check-read-exists  Block Read if file not found (PreToolUse)
  notification       Play sound + ntfy when Claude needs attention (Notification)
  subagent-stop      Log subagent completion (SubagentStop)
  auto-stage         Git-stage files after Write/Edit (PostToolUse)
  dep-remind         Remind to install after dep file edits (PostToolUse)
  todo-tracker       Log TODO/FIXME/HACK from edited files (PostToolUse)
  pre-compact        Save context snapshot before compaction (PreCompact)
  stop               Handle Stop events (format, backup, notify)
  session-hint       Hint @LAST snapshot availability on SessionStart
  env-validate       Validate dev environment on SessionStart
  version            Show version
  help               Show this help

Examples:
  echo '{"prompt":"test"}' | claude-hooks user-prompt
  echo '{"tool_input":{"command":"rm -rf /"}}' | claude-hooks check-rm`)
}
