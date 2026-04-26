// Package branchguard blocks destructive git operations on protected branches.
package branchguard

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
)

var (
	// Protected branch names
	protectedBranches = []string{"main", "master", "production", "release"}

	// Patterns that are always blocked regardless of branch
	alwaysBlock = []*regexp.Regexp{
		regexp.MustCompile(`git\s+push\s+.*--force`),
		regexp.MustCompile(`git\s+push\s+-f\b`),
		regexp.MustCompile(`git\s+reset\s+--hard`),
		regexp.MustCompile(`git\s+clean\s+-f`),
		regexp.MustCompile(`git\s+checkout\s+\.\s*$`),
	}

	// Patterns blocked only for protected branches
	branchBlock = []*regexp.Regexp{
		regexp.MustCompile(`git\s+branch\s+-[dD]\s+(%s)`),
		regexp.MustCompile(`git\s+push\s+\S+\s+:(%s)`),
	}
)

// Run executes the branch-guard hook.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	cmd := strings.TrimSpace(data.ToolInput.Command)
	if cmd == "" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Skip non-git commands (e.g. gh, echo, etc.)
	// Only guard commands that actually start with "git "
	firstLine := strings.SplitN(cmd, "\n", 2)[0]
	firstWord := strings.Fields(firstLine)[0]
	if firstWord != "git" {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	// Check always-blocked patterns (only scan first line to avoid
	// false positives from heredoc/body content)
	cmdToCheck := firstLine
	for _, pat := range alwaysBlock {
		if pat.MatchString(cmdToCheck) {
			fmt.Println(protocol.BlockResponse(
				fmt.Sprintf("🚫 危險 git 操作被阻擋: %s", cmd)))
			return
		}
	}

	// Check branch-specific blocks
	branchAlt := strings.Join(protectedBranches, "|")
	for _, tmpl := range branchBlock {
		// Replace %s with branch alternatives
		patStr := strings.ReplaceAll(tmpl.String(), "(%s)", "("+branchAlt+")")
		pat := regexp.MustCompile(patStr)
		if pat.MatchString(cmdToCheck) {
			fmt.Println(protocol.BlockResponse(
				fmt.Sprintf("🚫 受保護分支操作被阻擋: %s", cmd)))
			return
		}
	}

	fmt.Println(protocol.ContinueResponse())
}
