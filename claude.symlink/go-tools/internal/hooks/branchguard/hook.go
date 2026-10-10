// Package branchguard blocks destructive git operations on protected branches.
package branchguard

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
)

var (
	// protectedBranches may never be deleted locally or remotely.
	protectedBranches = map[string]bool{
		"main": true, "master": true, "production": true, "release": true,
	}

	// wrapperWords run their arguments as a command (`sudo git …`).
	wrapperWords = map[string]bool{
		"rtk": true, "command": true, "sudo": true, "env": true,
		"time": true, "nohup": true,
	}

	// gitOptsWithValue are git global options whose value is the next word.
	gitOptsWithValue = map[string]bool{
		"-C": true, "-c": true, "--git-dir": true, "--work-tree": true,
		"--namespace": true, "--exec-path": true, "--config-env": true,
	}

	envAssign = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9_]*=`)
)

// Run executes the branch-guard hook. Allow = exit 0 with no output.
func Run() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		return
	}

	if reason := checkCommand(data.ToolInput.Command); reason != "" {
		fmt.Println(protocol.PreToolUseDeny(reason))
	}
}

// checkCommand returns a deny reason if any command segment on the first
// line is a destructive git operation, or "" to allow. Only the first line
// is scanned so heredoc / commit-message bodies can't cause false positives.
func checkCommand(cmd string) string {
	firstLine := strings.SplitN(strings.TrimSpace(cmd), "\n", 2)[0]
	for _, seg := range splitSegments(firstLine) {
		args := gitArgs(splitWords(seg))
		if args == nil {
			continue
		}
		if why := destructive(args); why != "" {
			return fmt.Sprintf("危險 git 操作被阻擋 (%s): %s", why, strings.TrimSpace(seg))
		}
	}
	return ""
}

// splitSegments splits a command line on && || ; | outside of quotes.
func splitSegments(line string) []string {
	var segs []string
	var cur strings.Builder
	var quote byte
	for i := 0; i < len(line); i++ {
		c := line[i]
		switch {
		case quote != 0:
			if c == '\\' && quote == '"' && i+1 < len(line) {
				cur.WriteByte(c)
				i++
				c = line[i]
			} else if c == quote {
				quote = 0
			}
			cur.WriteByte(c)
		case c == '\\' && i+1 < len(line):
			cur.WriteByte(c)
			cur.WriteByte(line[i+1])
			i++
		case c == '\'' || c == '"':
			quote = c
			cur.WriteByte(c)
		case c == '&' && ((i > 0 && line[i-1] == '>') || (i+1 < len(line) && line[i+1] == '>')):
			cur.WriteByte(c) // redirection: 2>&1, &>file
		case c == ';' || c == '|' || c == '&':
			// "&&", "||", "|", ";" end a segment; a lone "&" (background)
			// does too. Doubled operators are consumed as one.
			if i+1 < len(line) && line[i+1] == c && c != ';' {
				i++
			}
			segs = append(segs, cur.String())
			cur.Reset()
		default:
			cur.WriteByte(c)
		}
	}
	return append(segs, cur.String())
}

// splitWords tokenizes a segment into shell words, removing quotes.
func splitWords(seg string) []string {
	var words []string
	var cur strings.Builder
	inWord := false
	var quote byte
	for i := 0; i < len(seg); i++ {
		c := seg[i]
		switch {
		case quote != 0:
			if c == quote {
				quote = 0
			} else if c == '\\' && quote == '"' && i+1 < len(seg) {
				i++
				cur.WriteByte(seg[i])
			} else {
				cur.WriteByte(c)
			}
		case c == '\'' || c == '"':
			quote = c
			inWord = true
		case c == '\\' && i+1 < len(seg):
			i++
			cur.WriteByte(seg[i])
			inWord = true
		case c == ' ' || c == '\t':
			if inWord {
				words = append(words, cur.String())
				cur.Reset()
				inWord = false
			}
		default:
			cur.WriteByte(c)
			inWord = true
		}
	}
	if inWord {
		words = append(words, cur.String())
	}
	return words
}

// gitArgs returns the words after `git` and its global options (i.e. the
// subcommand and its arguments), or nil if the segment is not a git call.
// Leading VAR=val assignments, subshell parens and wrapper words are skipped.
func gitArgs(words []string) []string {
	i := 0
	for i < len(words) {
		w := strings.TrimLeft(words[i], "({")
		switch {
		case w == "":
			i++
		case envAssign.MatchString(w):
			i++
		case wrapperWords[w]:
			i++
			// Skip the wrapper's own flags (sudo -E, env -i, time -p).
			for i < len(words) && strings.HasPrefix(words[i], "-") {
				i++
			}
		default:
			if w != "git" && filepath.Base(w) != "git" {
				return nil
			}
			i++
			// Skip git global options.
			for i < len(words) && strings.HasPrefix(words[i], "-") {
				opt := words[i]
				i++
				if gitOptsWithValue[opt] && i < len(words) {
					i++ // value in the next word; "--git-dir=x" needs no skip
				}
			}
			args := make([]string, 0, len(words)-i)
			for _, a := range words[i:] {
				args = append(args, strings.TrimRight(a, ")}"))
			}
			return args
		}
	}
	return nil
}

// destructive reports why a git subcommand + args is blocked, or "".
func destructive(args []string) string {
	if len(args) == 0 {
		return ""
	}
	sub, rest := args[0], args[1:]
	switch sub {
	case "push":
		for _, a := range rest {
			if strings.HasPrefix(a, "--force") || hasShortFlag(a, 'f') {
				return "force push"
			}
			if strings.HasPrefix(a, "+") {
				return "force push refspec"
			}
			if strings.HasPrefix(a, ":") && protectedBranches[a[1:]] {
				return "delete protected branch"
			}
		}
		if hasAny(rest, "--delete") || hasShortFlagIn(rest, 'd') {
			for _, a := range rest {
				if protectedBranches[a] {
					return "delete protected branch"
				}
			}
		}
	case "reset":
		if hasAny(rest, "--hard") {
			return "reset --hard"
		}
	case "clean":
		if hasAny(rest, "--force") || hasShortFlagIn(rest, 'f') {
			return "clean -f"
		}
	case "checkout":
		if wholeTree(rest) {
			return "discard all working-tree changes"
		}
	case "restore":
		staged := hasAny(rest, "--staged") || hasShortFlagIn(rest, 'S')
		worktree := hasAny(rest, "--worktree") || hasShortFlagIn(rest, 'W')
		// Default target is the worktree; --staged alone only unstages.
		if wholeTree(rest) && (!staged || worktree) {
			return "discard all working-tree changes"
		}
	case "branch":
		if hasAny(rest, "--delete") || hasShortFlagIn(rest, 'd') || hasShortFlagIn(rest, 'D') {
			for _, a := range rest {
				if protectedBranches[a] {
					return "delete protected branch"
				}
			}
		}
	}
	return ""
}

// wholeTree reports whether a pathspec covers the entire tree.
func wholeTree(args []string) bool {
	for _, a := range args {
		if a == "." || a == "./" || a == ":/" || a == "*" {
			return true
		}
	}
	return false
}

func hasAny(args []string, want string) bool {
	for _, a := range args {
		if a == want {
			return true
		}
	}
	return false
}

// hasShortFlag reports whether a is a short-flag cluster (e.g. -fd)
// containing flag.
func hasShortFlag(a string, flag byte) bool {
	return len(a) > 1 && a[0] == '-' && a[1] != '-' && strings.IndexByte(a[1:], flag) >= 0
}

func hasShortFlagIn(args []string, flag byte) bool {
	for _, a := range args {
		if hasShortFlag(a, flag) {
			return true
		}
	}
	return false
}
