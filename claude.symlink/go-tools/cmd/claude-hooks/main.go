// claude-hooks is the unified Claude Code hooks binary.
package main

import (
	"fmt"
	"os"

	"github.com/htlin/claude-tools/internal/hooks/branchguard"
	"github.com/htlin/claude-tools/internal/hooks/checkfileexists"
	"github.com/htlin/claude-tools/internal/hooks/checkrm"
	"github.com/htlin/claude-tools/internal/hooks/delegateedits"
	"github.com/htlin/claude-tools/internal/hooks/depremind"
	"github.com/htlin/claude-tools/internal/hooks/envvalidation"
	"github.com/htlin/claude-tools/internal/hooks/fileguard"
	"github.com/htlin/claude-tools/internal/hooks/notification"
	"github.com/htlin/claude-tools/internal/hooks/posttooluse"
	"github.com/htlin/claude-tools/internal/hooks/precompact"
	"github.com/htlin/claude-tools/internal/hooks/sessionend"
	"github.com/htlin/claude-tools/internal/hooks/sessionhint"
	"github.com/htlin/claude-tools/internal/hooks/stop"
	"github.com/htlin/claude-tools/internal/hooks/subagentstop"
	"github.com/htlin/claude-tools/internal/hooks/tursosync"
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
	case "check-file-exists":
		checkfileexists.Run()
	case "notification":
		notification.Run()
	case "subagent-stop":
		subagentstop.Run()
	case "delegate-edits":
		delegateedits.Run()
	case "dep-remind":
		depremind.Run()
	case "pre-compact":
		precompact.Run()
	case "stop":
		stop.Run()
	case "session-end":
		sessionend.Run()
	case "session-hint":
		sessionhint.Run()
	case "env-validate":
		envvalidation.Run()
	case "turso-sync":
		tursosync.Run()
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
  post-tool-use      Format + lint edited file, log Bash/edit metrics (PostToolUse)
  file-guard         Block access to sensitive files (PreToolUse)
  check-rm           Block rm commands (PreToolUse)
  delegate-edits     Block large Writes in main session, suggest subagents (PreToolUse)
  branch-guard       Block destructive git on protected branches (PreToolUse)
  check-file-exists  Block cat/bat if file not found (PreToolUse; used by Codex)
  notification       Play sound + ntfy when Claude needs attention (Notification)
  subagent-stop      Log subagent completion (SubagentStop)
  dep-remind         Remind to install after dep file edits (PostToolUse)
  pre-compact        Save context snapshot before compaction (PreCompact)
  stop               Handle Stop events (notify, snapshot, Turso flush)
  session-end        Save session ID for resume on SessionEnd
  session-hint       Hint @LAST snapshot availability on SessionStart
  env-validate       Validate dev environment on SessionStart
  turso-sync         Sync local prompts.db replica with Turso cloud
  version            Show version
  help               Show this help

Examples:
  echo '{"prompt":"test"}' | claude-hooks user-prompt
  echo '{"tool_input":{"command":"rm -rf /"}}' | claude-hooks check-rm`)
}
