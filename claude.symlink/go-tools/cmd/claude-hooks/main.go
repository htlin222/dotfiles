// claude-hooks is the unified Claude Code hooks binary.
package main

import (
	"fmt"
	"os"

	"github.com/htlin/claude-tools/internal/hooks/checkrm"
	"github.com/htlin/claude-tools/internal/hooks/fileguard"
	"github.com/htlin/claude-tools/internal/hooks/posttooluse"
	"github.com/htlin/claude-tools/internal/hooks/stop"
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
	case "stop":
		stop.Run()
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
  user-prompt     Handle UserPromptSubmit events
  post-tool-use   Handle PostToolUse events
  file-guard      Block access to sensitive files (PreToolUse)
  check-rm        Block rm commands (PreToolUse)
  stop            Handle Stop events (format, backup, notify)
  version         Show version
  help            Show this help

Examples:
  echo '{"prompt":"test"}' | claude-hooks user-prompt
  echo '{"tool_input":{"command":"rm -rf /"}}' | claude-hooks check-rm`)
}
