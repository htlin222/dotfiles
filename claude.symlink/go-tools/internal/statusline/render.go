package statusline

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/htlin/claude-tools/internal/protocol"
)

// ANSI constants
const (
	Green       = "\033[32m"
	Yellow      = "\033[33m"
	Orange      = "\033[93m"
	Red         = "\033[31m"
	LightBlue   = "\033[38;5;117m"
	LightGreen  = "\033[38;5;119m"
	ClaudeOrange = "\033[38;5;209m"
	Gray        = "\033[38;5;245m"
	White       = "\033[37m"
	Black       = "\033[30m"
	Reset       = "\033[0m"
	Dim         = "\033[2m"
	BgGreen     = "\033[42m"
	BgYellow    = "\033[43m"
	BgOrange    = "\033[103m"
	BgRed       = "\033[41m"
	Cyan        = "\033[36m"
	Magenta     = "\033[35m"

	// Nerd Font icons
	IconModel      = "\ue20f "
	IconFolderGit  = "\ue5fb "
	IconFolder     = "\ue5ff "
	IconContext    = "\ueaa4 "
	IconUsage      = "\ueded"
	IconWeekly     = "\ueebf"
	IconTime       = "\U000f0954 "
	IconSession    = "\U000f0b77 "
	IconVim        = "\ue7c5 "
	IconLines      = "\uf44d "
	IconDepth      = "\uf075 "
	IconBranch     = "\ue725 "
	IconSepRight   = "\ue0bc"
	IconCompact    = "\uea6c"
	IconTimerSand  = "\ueb7c"
	IconLastCmd    = "\uf4a4 " // nf-md-message_text

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

	// Switch input method to ABC when entering NORMAL mode
	handleVimModeIMSwitch(vimMode, data.TranscriptPath)

	// Session tokens
	sessionTokens := data.ContextWindow.TotalInputTokens + data.ContextWindow.TotalOutputTokens
	sessionDisplay := formatTokens(sessionTokens)

	// Cost
	sessionCost := fmt.Sprintf("$%.2f", data.Cost.TotalCostUSD)

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

	// Session time
	sessionDuration := getSessionDuration()

	// Burn rate
	burnRate := "0"
	if sessionDuration > 0 {
		rate := data.Cost.TotalCostUSD * 60.0 / float64(sessionDuration)
		burnRate = fmt.Sprintf("%.2f", rate)
	}

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
	lastCmd := getLastUserCommand(data.TranscriptPath, 80)

	// Git status
	gitStatus := GetGitStatus(data.Workspace.CurrentDir)

	// Begin output with synchronized update
	fmt.Print(SyncStart)

	// Line 1: model, folder, tokens, cost, time, burn, lines, depth, vim
	fmt.Printf("%s%s%s%s%s ", ClearLine, ClaudeOrange, IconModel, model, Reset)
	fmt.Printf("%s%s%s%s", White, folderIcon, dir, Reset)
	if langIcon != "" {
		fmt.Printf(" %s%s%s", Cyan, langIcon, Reset)
	}
	fmt.Printf(" %s%s%s ", LightBlue, sessionDisplay, Reset)
	fmt.Printf("%s%s%s/%s%s%s=%s$%s/h%s ", LightGreen, sessionCost, Reset, Gray, sessionDuration2String(sessionDuration), Reset, Cyan, burnRate, Reset)
	fmt.Printf("%s+%d%s%s-%d%s ", Green, linesAdded, Reset, Red, linesRemoved, Reset)
	fmt.Printf("%s%s%d%s ", LightBlue, IconDepth, convDepth, Reset)
	fmt.Printf("%s%s%s%s\n", vimColor, IconVim, vimMode, Reset)

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

	// Line 3: Dad joke
	fmt.Printf("%s%s%s%s", ClearLine, Dim, dadJoke, Reset)

	// Line 4: Last user command
	if lastCmd != "" {
		fmt.Printf("\n%s%s%s%s%s%s", ClearLine, LightGreen, IconLastCmd, lastCmd, Reset, "\033[K")
	}

	// Line 5: Git branch
	if gitStatus.BranchLine != "" {
		fmt.Printf("\n%s", ClearLine)
		renderBranchLine(gitStatus)
	}

	// Git file status
	if len(gitStatus.Files) > 0 {
		for _, file := range gitStatus.Files {
			fmt.Print(ClearLine)
			renderFileStatus(file)
		}
		if gitStatus.TotalFiles > 6 {
			extra := gitStatus.TotalFiles - 6
			fmt.Printf("%s%s[+%d more, use git status -sb]%s\n", ClearLine, Dim, extra, Reset)
		}
	}

	// End synchronized update
	fmt.Print(SyncEnd)
}

func getColor(pct int) string {
	switch {
	case pct >= 90:
		return Red
	case pct >= 75:
		return Orange
	case pct >= 60:
		return Yellow
	default:
		return Green
	}
}

func getBgColor(pct int) string {
	switch {
	case pct >= 90:
		return BgRed
	case pct >= 75:
		return BgOrange
	case pct >= 60:
		return BgYellow
	default:
		return BgGreen
	}
}

func formatTokens(tokens int) string {
	if tokens >= 1000000 {
		return fmt.Sprintf("%.1fM", float64(tokens)/1000000)
	}
	if tokens >= 1000 {
		return fmt.Sprintf("%.1fK", float64(tokens)/1000)
	}
	return strconv.Itoa(tokens)
}

func formatTokensShort(tokens int) string {
	if tokens >= 1000000 {
		return fmt.Sprintf("%dM", tokens/1000000)
	}
	if tokens >= 1000 {
		return fmt.Sprintf("%dK", tokens/1000)
	}
	return strconv.Itoa(tokens)
}

func countConversationDepth(transcriptPath string) int {
	if transcriptPath == "" {
		return 0
	}

	f, err := os.Open(transcriptPath)
	if err != nil {
		return 0
	}
	defer f.Close()

	count := 0
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		if strings.Contains(scanner.Text(), `"type":"user"`) {
			count++
		}
	}
	return count
}

// transcriptMessage represents a message in the transcript
type transcriptMessage struct {
	Type    string `json:"type"`
	Message struct {
		Content interface{} `json:"content"`
	} `json:"message"`
}

func getLastUserCommand(transcriptPath string, maxLen int) string {
	if transcriptPath == "" {
		return ""
	}

	f, err := os.Open(transcriptPath)
	if err != nil {
		return ""
	}
	defer f.Close()

	var lastUserMsg string
	scanner := bufio.NewScanner(f)
	// Increase buffer size for large lines
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		line := scanner.Text()
		if !strings.Contains(line, `"type":"user"`) {
			continue
		}

		var msg transcriptMessage
		if err := json.Unmarshal([]byte(line), &msg); err != nil {
			continue
		}

		// Extract text from content
		text := extractTextFromContent(msg.Message.Content)
		if text != "" {
			lastUserMsg = text
		}
	}

	// Clean and truncate
	lastUserMsg = strings.TrimSpace(lastUserMsg)
	lastUserMsg = strings.ReplaceAll(lastUserMsg, "\n", " ")
	lastUserMsg = strings.ReplaceAll(lastUserMsg, "\t", " ")

	// Collapse multiple spaces
	for strings.Contains(lastUserMsg, "  ") {
		lastUserMsg = strings.ReplaceAll(lastUserMsg, "  ", " ")
	}

	if len(lastUserMsg) > maxLen {
		lastUserMsg = lastUserMsg[:maxLen-3] + "..."
	}

	return lastUserMsg
}

func extractTextFromContent(content interface{}) string {
	switch c := content.(type) {
	case string:
		return c
	case []interface{}:
		var parts []string
		for _, item := range c {
			if m, ok := item.(map[string]interface{}); ok {
				if m["type"] == "text" {
					if text, ok := m["text"].(string); ok {
						parts = append(parts, text)
					}
				}
			}
		}
		return strings.Join(parts, " ")
	}
	return ""
}

func getSessionDuration() int {
	sessionFile := fmt.Sprintf("/tmp/claude_session_start_%d", os.Getppid())
	data, err := os.ReadFile(sessionFile)
	if err != nil {
		// Create new session
		now := fmt.Sprintf("%d", getUnixTime())
		os.WriteFile(sessionFile, []byte(now), 0644)
		return 0
	}

	startTime, err := strconv.ParseInt(strings.TrimSpace(string(data)), 10, 64)
	if err != nil {
		return 0
	}

	return int((getUnixTime() - startTime) / 60) // minutes
}

func getUnixTime() int64 {
	cmd := exec.Command("date", "+%s")
	output, err := cmd.Output()
	if err != nil {
		return 0
	}
	t, _ := strconv.ParseInt(strings.TrimSpace(string(output)), 10, 64)
	return t
}

func sessionDuration2String(minutes int) string {
	return fmt.Sprintf("%dm", minutes)
}

func renderBranchLine(status *GitStatus) {
	branchLine := status.BranchLine

	// Remove tracking info for display
	displayLine := branchLine
	if idx := strings.Index(branchLine, " ["); idx != -1 {
		displayLine = branchLine[:idx]
	}

	fmt.Printf("%s%s", IconBranch, displayLine)

	// Show ahead/behind with dots
	if status.AheadCount > 0 && status.BehindCount > 0 {
		fmt.Printf(" %s[ahead %d, behind %d]%s ", Yellow, status.AheadCount, status.BehindCount, Reset)
		fmt.Printf("%s%s%s %s%s%s",
			Green, strings.Repeat("●", status.AheadCount), Reset,
			Red, strings.Repeat("●", status.BehindCount), Reset)
	} else if status.AheadCount > 0 {
		fmt.Printf(" %s[ahead %d] %s%s", Green, status.AheadCount, strings.Repeat("●", status.AheadCount), Reset)
	} else if status.BehindCount > 0 {
		fmt.Printf(" %s[behind %d] %s%s", Red, status.BehindCount, strings.Repeat("●", status.BehindCount), Reset)
	}
	fmt.Println()
}

func renderFileStatus(file GitFileStatus) {
	// Color X (index status)
	xColored := colorStatus(file.IndexStatus)
	// Color Y (worktree status)
	yColored := colorStatus(file.WorktreeStatus)

	fmt.Printf("%s%s%s\n", xColored, yColored, file.Path)
}

func colorStatus(status rune) string {
	switch status {
	case 'M':
		return Yellow + "M" + Reset
	case 'A':
		return Green + "A" + Reset
	case 'D':
		return Red + "D" + Reset
	case 'R':
		return LightBlue + "R" + Reset
	case 'C':
		return LightBlue + "C" + Reset
	case 'T':
		return Orange + "T" + Reset
	case 'U':
		return Red + "U" + Reset
	case '?':
		return Gray + "?" + Reset
	case '!':
		return Dim + "!" + Reset
	case ' ':
		return " "
	default:
		return string(status)
	}
}

// handleVimModeIMSwitch manages input method based on vim mode.
// - NORMAL mode: save current IM, switch to ABC
// - INSERT mode: restore saved IM
func handleVimModeIMSwitch(currentMode, transcriptPath string) {
	imSelect := "/opt/homebrew/bin/im-select"
	if _, err := os.Stat(imSelect); os.IsNotExist(err) {
		return
	}

	// State file for this session
	sessionID := "default"
	if transcriptPath != "" {
		sessionID = filepath.Base(transcriptPath)
		sessionID = strings.TrimSuffix(sessionID, ".jsonl")
	}
	imStateFile := fmt.Sprintf("/tmp/claude_im_state_%s", sessionID)
	modeStateFile := fmt.Sprintf("/tmp/claude_vim_mode_%s", sessionID)

	abc := "com.apple.keylayout.ABC"

	// Get current IM
	cmd := exec.Command(imSelect)
	output, err := cmd.Output()
	if err != nil {
		return
	}
	currentIM := strings.TrimSpace(string(output))

	// Read previous vim mode
	prevModeData, _ := os.ReadFile(modeStateFile)
	prevMode := strings.TrimSpace(string(prevModeData))

	// Save current vim mode
	os.WriteFile(modeStateFile, []byte(currentMode), 0644)

	switch currentMode {
	case "NORMAL":
		// Entering NORMAL: save current IM (if not ABC), then switch to ABC
		if prevMode != "NORMAL" && currentIM != abc {
			os.WriteFile(imStateFile, []byte(currentIM), 0644)
		}
		if currentIM != abc {
			exec.Command(imSelect, abc).Run()
		}

	case "INSERT":
		// Entering INSERT: restore saved IM if we have one
		if prevMode == "NORMAL" {
			savedIM, err := os.ReadFile(imStateFile)
			if err == nil && len(savedIM) > 0 {
				savedIMStr := strings.TrimSpace(string(savedIM))
				if savedIMStr != "" && savedIMStr != currentIM {
					exec.Command(imSelect, savedIMStr).Run()
				}
			}
		}
	}
}

