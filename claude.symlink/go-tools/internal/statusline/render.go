package statusline

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
	"unsafe"

	"github.com/htlin/claude-tools/internal/hooks/killtimer"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/pkg/context"
)

// getTermWidth returns the terminal width in columns, or 0 if unknown.
func getTermWidth() int {
	// Open /dev/tty directly — works even when all fds are piped
	tty, err := os.Open("/dev/tty")
	if err != nil {
		return 0
	}
	defer tty.Close()

	var ws struct {
		Row, Col, Xpixel, Ypixel uint16
	}
	_, _, errno := syscall.Syscall(syscall.SYS_IOCTL,
		tty.Fd(),
		syscall.TIOCGWINSZ,
		uintptr(unsafe.Pointer(&ws)))
	if errno == 0 && ws.Col > 0 {
		return int(ws.Col)
	}
	return 0
}

const narrowThreshold = 80

// ANSI constants
const (
	Green        = "\033[32m"
	Yellow       = "\033[33m"
	Orange       = "\033[93m"
	Red          = "\033[31m"
	LightBlue    = "\033[38;5;117m"
	LightGreen   = "\033[38;5;119m"
	ClaudeOrange = "\033[38;5;209m"
	Gray         = "\033[38;5;245m"
	DarkGreen    = "\033[38;5;65m" // Desaturated dark green
	White        = "\033[37m"
	Black        = "\033[30m"
	Reset        = "\033[0m"
	Dim          = "\033[2m"
	BgGreen      = "\033[42m"
	BgYellow     = "\033[43m"
	BgOrange     = "\033[103m"
	BgRed        = "\033[41m"
	Cyan         = "\033[36m"
	Magenta      = "\033[35m"

	// Statusline icons (UTF-8)
	IconModel       = "◆ "
	IconFolderGit   = "□ "
	IconFolder      = "□ "
	IconContext      = "⊞ "
	IconUsage       = "⏐"
	IconWeekly      = "⟳"
	IconTime        = "◷ "
	IconSession     = "▶ "
	IconVim         = "◈ "
	IconLines       = "≡ "
	IconDepth       = "↕ "
	IconBranch      = "．"
	IconSepRight    = "│"
	IconCompact     = "⊟"
	IconTimerSand   = "⧗"
	IconLastCmd     = "› "
	IconUser        = "○"
	IconFirstPrompt = "● "

	// Synchronized Update
	SyncStart = "\033[?2026h"
	SyncEnd   = "\033[?2026l"
	ClearLine = "\033[2K"
)

// Render outputs the statusline.
func Render(data *protocol.StatuslineInput) {
	// Get usage data (prefers stdin rate_limits, falls back to OAuth API)
	usage := GetUsageData(data)

	// Calculate values
	model := data.Model.DisplayName
	if model == "" {
		model = "Unknown"
	}

	dir := filepath.Base(data.Workspace.CurrentDir)
	if dir == "" {
		dir = "."
	}

	// Check if git repo
	cmd := exec.Command("git", "rev-parse", "--git-dir")
	cmd.Dir = data.Workspace.CurrentDir
	cmd.Run()

	// Vim mode
	vimMode := data.Vim.Mode
	if vimMode == "" {
		vimMode = "NORMAL"
	}
	// vimColor := Yellow
	// switch vimMode {
	// case "INSERT":
	// 	vimColor = Green
	// case "VISUAL":
	// 	vimColor = Magenta
	// }

	// Switch input method (side effect kept); vim status no longer displayed
	_ = handleVimModeIMSwitch(vimMode, data.TranscriptPath)

	// Lines
	linesAdded := data.Cost.TotalLinesAdded
	linesRemoved := data.Cost.TotalLinesRemoved

	// Conversation depth (not displayed)
	// convDepth := countConversationDepth(data.TranscriptPath)

	// Context usage
	windowSize := data.ContextWindow.ContextWindowSize
	if windowSize == 0 {
		windowSize = 200000
	}
	currentTokens := data.ContextWindow.CurrentUsage.InputTokens +
		data.ContextWindow.CurrentUsage.CacheCreationInputTokens +
		data.ContextWindow.CurrentUsage.CacheReadInputTokens
	rawContextPct := currentTokens * 100 / windowSize
	contextPct := rawContextPct + 20 // Add 20% baseline for display
	if contextPct > 100 {
		contextPct = 100
	}

	// Persist real context pressure for userprompt hook
	context.WritePressure(rawContextPct, currentTokens, windowSize)

	// currentDisplay := formatTokens(currentTokens)
	// windowDisplay := formatTokensShort(windowSize)

	contextColor := getColor(contextPct)

	// Usage colors
	fiveHourColor := getColor(usage.FiveHourPct)
	weeklyColor := getColor(usage.WeeklyPct)

	fiveHourDisplay := fmt.Sprintf("%d%%", usage.FiveHourPct)
	weeklyDisplay := fmt.Sprintf("%d%%", usage.WeeklyPct)

	// Get dad joke
	// dadJoke := GetDadJoke()

	// Get last user command (long enough to fill 2 wrapped lines)
	lastCmd, _ := getLastUserCommand(data.TranscriptPath, 500)

	// Get first prompt (saved persistently)
	// firstPrompt := getFirstPrompt(data.TranscriptPath, 50)

	// Git status
	gitStatus := GetGitStatus(data.Workspace.CurrentDir)

	// Begin output with synchronized update
	fmt.Print(SyncStart)

	// Narrow screen: single compact line
	if w := getTermWidth(); w > 0 && w < narrowThreshold {
		fmt.Printf("%s%s[C]%d%%%s", ClearLine, contextColor, contextPct, Reset)
		fmt.Printf(" %s[5]%s %s%s", fiveHourColor, fiveHourDisplay, usage.TimeLeft, Reset)
		fmt.Printf("\033[K\n")
		fmt.Print(SyncEnd)
		return
	}

	// Line 1: Last user command, wrapped to max 2 lines (indented continuation)
	if lastCmd != "" {
		width := getTermWidth()
		if width <= 0 {
			width = 80
		}
		const indent = "  " // matches IconLastCmd width
		lines := wrapPrompt(lastCmd, width-len(indent))
		fmt.Printf("%s%s%s%s%s\033[K\n", ClearLine, LightGreen, IconLastCmd, lines[0], Reset)
		if len(lines) > 1 {
			fmt.Printf("%s%s%s%s%s\033[K\n", ClearLine, LightGreen, indent, lines[1], Reset)
		}
	}

	// Line 2: First prompt of session (removed)
	// if firstPrompt != "" {
	// 	firstPromptTime := getFirstPromptTime(data.TranscriptPath)
	// 	fmt.Printf("%s%s%s%s%s", ClearLine, DarkGreen, IconFirstPrompt, firstPrompt, Reset)
	// 	if firstPromptTime != "" {
	// 		fmt.Printf(" %sat %s%s", Gray, firstPromptTime, Reset)
	// 	}
	// 	fmt.Printf("%s\n", "\033[K")
	// }

	// Line 3: RAM/CPU/PID (commented out; kill timer kept, shown only when active)
	// userHost := getUserHost()
	// ramMB, cpuPct, pid := getClaudeProcessStats()
	// fmt.Printf("%s%s%s%s ", ClearLine, Dim, IconUser, Reset)
	// fmt.Printf("%s%s%s ", Gray, userHost, Reset)
	// ramColor := getRamColor(ramMB)
	// fmt.Printf("%s✿ %dMB%s %s✿ %.1f%% on %d%s ", ramColor, ramMB, Reset, Gray, cpuPct, pid, Reset)
	// Show kill timer countdown if active
	_, _, pid := getClaudeProcessStats()
	if pid > 0 {
		if m := killtimer.ReadMarker(pid); m != nil {
			secs := m.SecondsRemaining()
			fmt.Printf("%s%s%s %dm%02ds%s\n", ClearLine, Orange, IconTimerSand, secs/60, secs%60, Reset)
		}
	}
	// Show vim mode with saved IM indicator
	// if savedIMShort != "" && vimMode != "INSERT" {
	// 	fmt.Printf("%s%s%s%s %s(%s)%s\n", vimColor, IconVim, vimMode, Reset, Dim, savedIMShort, Reset)
	// } else {
	// 	fmt.Printf("%s%s%s%s\n", vimColor, IconVim, vimMode, Reset)
	// }

	// Line: model + effort + context + usage (compact, no icons, no bar)
	effort := ""
	if data.Effort != nil && data.Effort.Level != "" {
		effort = " " + data.Effort.Level
	}
	fmt.Printf("%s%s%s%s%s %s%d%%%s", ClearLine, ClaudeOrange, model, effort, Reset, contextColor, contextPct, Reset)
	fmt.Printf(" %s[5]%s %s%s", fiveHourColor, fiveHourDisplay, usage.TimeLeft, Reset)
	fmt.Printf(" %s[W]%s %s%s\033[K\n", weeklyColor, weeklyDisplay, usage.WeeklyResetDate, Reset)

	// Folder + Git branch
	if gitStatus.BranchLine != "" {
		fmt.Printf("\n%s", ClearLine)
		// Repo name (yellow), then cwd as "dir/" — skip dir if it equals repo
		repoName := ""
		if data.Workspace.Repo != nil {
			repoName = data.Workspace.Repo.Name
		}
		if repoName != "" {
			fmt.Printf("%s%s%s%s．%s", Yellow, repoName, Reset, Dim, Reset)
		}
		if dir != repoName {
			fmt.Printf("%s%s/%s", Yellow, dir, Reset)
		}
		renderBranchLine(gitStatus, linesAdded, linesRemoved, data.Cost.TotalCostUSD, data.Cost.TotalDurationMS)
	}

	// Git file status
	if len(gitStatus.Files) > 0 {
		renderFileStatuses(gitStatus.Files)
		if gitStatus.TotalFiles > 6 {
			extra := gitStatus.TotalFiles - 6
			fmt.Printf("%s%s[+%d more]%s\n", ClearLine, Dim, extra, Reset)
		}
	}
	// Conversation depth (commented out)
	// fmt.Printf("%s%s%s%d%s\n", ClearLine, LightBlue, IconDepth, convDepth, Reset)

	// Dad joke (at the bottom)
	// fmt.Printf("%s%s%s%s\n", ClearLine, Dim, dadJoke, Reset)

	// End synchronized update
	fmt.Print(SyncEnd)
}
