package statusline

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
)

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

	// Nerd Font icons
	IconModel       = "\ue20f "
	IconFolderGit   = "\ue5fb "
	IconFolder      = "\ue5ff "
	IconContext      = "\ueaa4 "
	IconUsage       = "\ueded"
	IconWeekly      = "\ueebf"
	IconTime        = "\U000f0954 "
	IconSession     = "\U000f0b77 "
	IconVim         = "\ue7c5 "
	IconLines       = "\uf44d "
	IconDepth       = "\uf075 "
	IconBranch      = "\ue725 "
	IconSepRight    = "\ue0bc"
	IconCompact     = "\uea6c"
	IconTimerSand   = "\ueb7c"
	IconLastCmd     = "\uf4a4 " // nf-md-message_text
	IconUser        = "\ued35 "
	IconFirstPrompt = "\uf041 " // nf-fa-map_marker

	// Synchronized Update
	SyncStart = "\033[?2026h"
	SyncEnd   = "\033[?2026l"
	ClearLine = "\033[2K"
)

// Render outputs the statusline.
func Render(data *protocol.StatuslineInput) {
	// Get usage data
	usage := GetUsageData()

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
	folderIcon := IconFolder
	cmd := exec.Command("git", "rev-parse", "--git-dir")
	cmd.Dir = data.Workspace.CurrentDir
	if err := cmd.Run(); err == nil {
		folderIcon = IconFolderGit
	}

	// Detect language
	langIcon := DetectLanguage(data.Workspace.CurrentDir)

	// Vim mode
	vimMode := data.Vim.Mode
	if vimMode == "" {
		vimMode = "NORMAL"
	}
	vimColor := Yellow
	switch vimMode {
	case "INSERT":
		vimColor = Green
	case "VISUAL":
		vimColor = Magenta
	}

	// Switch input method and get saved IM for display
	savedIMShort := handleVimModeIMSwitch(vimMode, data.TranscriptPath)

	// Lines
	linesAdded := data.Cost.TotalLinesAdded
	linesRemoved := data.Cost.TotalLinesRemoved

	// Conversation depth
	convDepth := countConversationDepth(data.TranscriptPath)

	// Context usage
	windowSize := data.ContextWindow.ContextWindowSize
	if windowSize == 0 {
		windowSize = 200000
	}
	currentTokens := data.ContextWindow.CurrentUsage.InputTokens +
		data.ContextWindow.CurrentUsage.CacheCreationInputTokens +
		data.ContextWindow.CurrentUsage.CacheReadInputTokens
	contextPct := (currentTokens * 100 / windowSize) + 20 // Add 20% baseline
	if contextPct > 100 {
		contextPct = 100
	}

	currentDisplay := formatTokens(currentTokens)
	windowDisplay := formatTokensShort(windowSize)

	// Context bar
	barWidth := 10
	filled := contextPct * barWidth / 100
	if filled > barWidth {
		filled = barWidth
	}
	contextColor := getColor(contextPct)
	contextBar := contextColor + strings.Repeat("█", filled) + Gray + strings.Repeat("░", barWidth-filled) + Reset

	// Usage colors
	fiveHourColor := getColor(usage.FiveHourPct)
	fiveHourBg := getBgColor(usage.FiveHourPct)
	weeklyColor := getColor(usage.WeeklyPct)
	weeklyBg := getBgColor(usage.WeeklyPct)

	fiveHourDisplay := fmt.Sprintf("%d%%", usage.FiveHourPct)
	weeklyDisplay := fmt.Sprintf("%d%%", usage.WeeklyPct)

	// Get dad joke
	dadJoke := GetDadJoke()

	// Get last user command
	lastCmd, lastCmdTime := getLastUserCommand(data.TranscriptPath, 60)

	// Get first prompt (saved persistently)
	firstPrompt := getFirstPrompt(data.TranscriptPath, 50)

	// Git status
	gitStatus := GetGitStatus(data.Workspace.CurrentDir)

	// Begin output with synchronized update
	fmt.Print(SyncStart)

	// Line 1: Last user command with timestamp
	if lastCmd != "" {
		fmt.Printf("%s%s%s%s%s", ClearLine, LightGreen, IconLastCmd, lastCmd, Reset)
		if lastCmdTime != "" {
			fmt.Printf(" %sat %s%s", Gray, lastCmdTime, Reset)
		}
		fmt.Printf("%s\n", "\033[K")
	}

	// Line 2: First prompt of session (persists across compacts)
	if firstPrompt != "" {
		firstPromptTime := getFirstPromptTime(data.TranscriptPath)
		fmt.Printf("%s%s%s%s%s", ClearLine, DarkGreen, IconFirstPrompt, firstPrompt, Reset)
		if firstPromptTime != "" {
			fmt.Printf(" %sat %s%s", Gray, firstPromptTime, Reset)
		}
		fmt.Printf("%s\n", "\033[K")
	}

	// Line 3: user@host, model, RAM/CPU, vim
	userHost := getUserHost()
	ramMB, cpuPct, pid := getClaudeProcessStats()
	fmt.Printf("%s%s%s%s ", ClearLine, Dim, IconUser, Reset)
	fmt.Printf("%s%s%s ", Gray, userHost, Reset)
	fmt.Printf("%s%s%s%s ", ClaudeOrange, IconModel, model, Reset)
	fmt.Printf("%s\ue266 %dMB \uec19 %.1f%% on %d%s ", Gray, ramMB, cpuPct, pid, Reset)
	// Show vim mode with saved IM indicator
	if savedIMShort != "" && vimMode != "INSERT" {
		fmt.Printf("%s%s%s%s %s(%s)%s\n", vimColor, IconVim, vimMode, Reset, Dim, savedIMShort, Reset)
	} else {
		fmt.Printf("%s%s%s%s\n", vimColor, IconVim, vimMode, Reset)
	}

	// Line 2: context bar, 5h usage, weekly
	fmt.Printf("%s%s%s%s", ClearLine, contextColor, IconContext, Reset)
	fmt.Printf("%s ", contextBar)
	fmt.Printf("%s%s%s/%s ", contextColor, currentDisplay, Reset, windowDisplay)
	fmt.Printf("%s%d%%%s ", contextColor, contextPct, Reset)

	// 5-hour segment
	fmt.Printf("%s%s %s %s", fiveHourBg, Black, IconUsage, Reset)
	fmt.Printf("%s%s%s ", fiveHourColor, IconSepRight, Reset)
	fmt.Printf("%s%s%s ", fiveHourColor, fiveHourDisplay, Reset)
	fmt.Printf("%s%s %s%s ", Gray, IconTimerSand, usage.TimeLeft, Reset)

	// Weekly segment
	fmt.Printf("%s%s %s %s", weeklyBg, Black, IconWeekly, Reset)
	fmt.Printf("%s%s%s ", weeklyColor, IconSepRight, Reset)
	fmt.Printf("%s%s%s ", weeklyColor, weeklyDisplay, Reset)
	fmt.Printf("%s%s%s\033[K\n", Gray, usage.WeeklyResetDate, Reset)

	// Folder + Git branch
	if gitStatus.BranchLine != "" {
		fmt.Printf("\n%s", ClearLine)
		// Folder before branch (light blue with padding)
		fmt.Printf("%s %s%s %s", LightBlue, folderIcon, dir, Reset)
		if langIcon != "" {
			fmt.Printf(" %s%s%s", Cyan, langIcon, Reset)
		}
		fmt.Print(" ")
		renderBranchLine(gitStatus)
	}

	// Git file status
	if len(gitStatus.Files) > 0 {
		for _, file := range gitStatus.Files {
			fmt.Print(ClearLine)
			renderFileStatus(file)
		}
		fmt.Print(ClearLine)
		if gitStatus.TotalFiles > 6 {
			extra := gitStatus.TotalFiles - 6
			fmt.Printf("%s[+%d more]%s ", Dim, extra, Reset)
		}
		// Session stats: lines, depth (same line)
		fmt.Printf("%s+%d%s%s-%d%s ", Green, linesAdded, Reset, Red, linesRemoved, Reset)
		fmt.Printf("%s%s%d%s\n", LightBlue, IconDepth, convDepth, Reset)
	} else {
		// No git files, still show stats
		fmt.Printf("%s%s+%d%s%s-%d%s ", ClearLine, Green, linesAdded, Reset, Red, linesRemoved, Reset)
		fmt.Printf("%s%s%d%s\n", LightBlue, IconDepth, convDepth, Reset)
	}

	// Dad joke (at the bottom)
	fmt.Printf("%s%s%s%s\n", ClearLine, Dim, dadJoke, Reset)

	// End synchronized update
	fmt.Print(SyncEnd)
}
