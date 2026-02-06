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
	"time"

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
	DarkGreen   = "\033[38;5;65m"  // Desaturated dark green
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
	IconUser       = "\ued35 "
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

	// Session tokens (commented out)
	// sessionTokens := data.ContextWindow.TotalInputTokens + data.ContextWindow.TotalOutputTokens
	// sessionDisplay := formatTokens(sessionTokens)

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

	// Session time (commented out)
	// sessionDuration := getSessionDuration()

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
	Type      string `json:"type"`
	Timestamp string `json:"timestamp"`
	Message   struct {
		Content interface{} `json:"content"`
	} `json:"message"`
}

func getLastUserCommand(transcriptPath string, maxLen int) (string, string) {
	if transcriptPath == "" {
		return "", ""
	}

	f, err := os.Open(transcriptPath)
	if err != nil {
		return "", ""
	}
	defer f.Close()

	var lastUserMsg string
	var lastTimestamp string
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
			lastTimestamp = msg.Timestamp
		}
	}

	// Clean and truncate
	lastUserMsg = strings.TrimSpace(lastUserMsg)
	lastUserMsg = strings.ReplaceAll(lastUserMsg, "\n", " ")
	lastUserMsg = strings.ReplaceAll(lastUserMsg, "\t", " ")

	// Filter out system-generated content (local-command tags, etc.)
	lastUserMsg = cleanLastCommand(lastUserMsg)

	// Collapse multiple spaces
	for strings.Contains(lastUserMsg, "  ") {
		lastUserMsg = strings.ReplaceAll(lastUserMsg, "  ", " ")
	}

	if len(lastUserMsg) > maxLen {
		lastUserMsg = lastUserMsg[:maxLen-3] + "..."
	}

	// Format timestamp as HH:MM:SS
	timeStr := formatTimestamp(lastTimestamp)

	return lastUserMsg, timeStr
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

	// Show ahead/behind with dots (spaced)
	if status.AheadCount > 0 && status.BehindCount > 0 {
		fmt.Printf(" %s[ahead %d, behind %d]%s ", Yellow, status.AheadCount, status.BehindCount, Reset)
		fmt.Printf("%s%s%s %s%s%s",
			Green, spacedDots(status.AheadCount), Reset,
			Red, spacedDots(status.BehindCount), Reset)
	} else if status.AheadCount > 0 {
		fmt.Printf(" %s[ahead %d] %s%s", Green, status.AheadCount, spacedDots(status.AheadCount), Reset)
	} else if status.BehindCount > 0 {
		fmt.Printf(" %s[behind %d] %s%s", Red, status.BehindCount, spacedDots(status.BehindCount), Reset)
	}
	fmt.Println()
}

func renderFileStatus(file GitFileStatus) {
	// Color X (index status)
	xColored := colorStatus(file.IndexStatus)
	// Color Y (worktree status)
	yColored := colorStatus(file.WorktreeStatus)

	// Use white for files in current folder (no ../), gray for parent folders
	pathColor := Gray
	if !strings.HasPrefix(file.Path, "../") {
		pathColor = White
	}

	fmt.Printf("%s%s %s%s%s", xColored, yColored, pathColor, file.Path, Reset)

	// Show line changes if available
	if file.LinesAdded > 0 || file.LinesRemoved > 0 {
		fmt.Print("  ")
		if file.LinesAdded > 0 {
			fmt.Printf("%s+%d%s", Green, file.LinesAdded, Reset)
		}
		if file.LinesRemoved > 0 {
			fmt.Printf("%s-%d%s", Red, file.LinesRemoved, Reset)
		}
	}
	fmt.Println()
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
// Returns short name of saved IM for display (empty if none or not on macOS).
func handleVimModeIMSwitch(currentMode, transcriptPath string) string {
	// Find im-select (macOS only, gracefully skip on Linux)
	imSelect := findIMSelect()
	if imSelect == "" {
		return ""
	}

	// State file for this session
	sessionID := "default"
	if transcriptPath != "" {
		sessionID = filepath.Base(transcriptPath)
		sessionID = strings.TrimSuffix(sessionID, ".jsonl")
	}
	imStateFile := fmt.Sprintf("/tmp/claude_im_state_%s", sessionID)
	modeStateFile := fmt.Sprintf("/tmp/claude_vim_mode_%s", sessionID)

	// Cleanup old state files periodically (every ~100 calls)
	cleanupOldStateFiles()

	abc := "com.apple.keylayout.ABC"

	// Get current IM
	cmd := exec.Command(imSelect)
	output, err := cmd.Output()
	if err != nil {
		return ""
	}
	currentIM := strings.TrimSpace(string(output))

	// Read previous vim mode
	prevModeData, _ := os.ReadFile(modeStateFile)
	prevMode := strings.TrimSpace(string(prevModeData))

	// Save current vim mode
	os.WriteFile(modeStateFile, []byte(currentMode), 0644)

	// Read saved IM for display
	savedIMData, _ := os.ReadFile(imStateFile)
	savedIM := strings.TrimSpace(string(savedIMData))

	switch currentMode {
	case "NORMAL":
		// Entering NORMAL: save current IM (if not ABC), then switch to ABC
		if prevMode != "NORMAL" && currentIM != abc {
			os.WriteFile(imStateFile, []byte(currentIM), 0644)
			savedIM = currentIM
		}
		if currentIM != abc {
			exec.Command(imSelect, abc).Run()
		}

	case "INSERT":
		// Entering INSERT: restore saved IM if we have one
		if prevMode == "NORMAL" && savedIM != "" && savedIM != currentIM {
			exec.Command(imSelect, savedIM).Run()
		}
	}

	return imShortName(savedIM)
}

// findIMSelect returns path to im-select if available, empty string otherwise.
func findIMSelect() string {
	paths := []string{
		"/opt/homebrew/bin/im-select", // macOS ARM
		"/usr/local/bin/im-select",    // macOS Intel
	}
	for _, p := range paths {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}
	return ""
}

// imShortName converts full IM identifier to short display name.
func imShortName(im string) string {
	if im == "" {
		return ""
	}
	// Known input methods
	switch {
	case strings.Contains(im, "Boshiamy"):
		return "嘸"
	case strings.Contains(im, "Zhuyin"), strings.Contains(im, "Bopomofo"):
		return "注"
	case strings.Contains(im, "Pinyin"):
		return "拼"
	case strings.Contains(im, "Cangjie"):
		return "倉"
	case strings.Contains(im, "ABC"):
		return ""
	case strings.Contains(im, "US"):
		return ""
	default:
		// Return last part of identifier
		parts := strings.Split(im, ".")
		if len(parts) > 0 {
			last := parts[len(parts)-1]
			if len(last) > 4 {
				return last[:4]
			}
			return last
		}
		return ""
	}
}

// cleanupOldStateFiles removes state files older than 24 hours.
func cleanupOldStateFiles() {
	// Only run cleanup ~1% of the time to avoid overhead
	if os.Getpid()%100 != 0 {
		return
	}

	files, err := filepath.Glob("/tmp/claude_im_state_*")
	if err != nil {
		return
	}
	files2, _ := filepath.Glob("/tmp/claude_vim_mode_*")
	files = append(files, files2...)

	cutoff := getUnixTime() - 86400 // 24 hours ago
	for _, f := range files {
		info, err := os.Stat(f)
		if err != nil {
			continue
		}
		if info.ModTime().Unix() < cutoff {
			os.Remove(f)
		}
	}
}

// spacedDots returns n dots separated by spaces.
func spacedDots(n int) string {
	if n <= 0 {
		return ""
	}
	dots := make([]string, n)
	for i := range dots {
		dots[i] = "●"
	}
	return strings.Join(dots, " ")
}

// formatTimestamp converts ISO 8601 timestamp to HH:MM:SS in local time.
func formatTimestamp(ts string) string {
	if ts == "" {
		return ""
	}
	// Parse ISO 8601: 2026-02-06T18:18:36.335Z
	// Try to parse and convert to local time
	t, err := parseISO8601(ts)
	if err != nil {
		return ""
	}
	return t.Local().Format("15:04:05")
}

// parseISO8601 parses an ISO 8601 timestamp string.
func parseISO8601(ts string) (time.Time, error) {
	// Try common formats
	formats := []string{
		"2006-01-02T15:04:05.999Z",
		"2006-01-02T15:04:05Z",
		"2006-01-02T15:04:05.999-07:00",
		"2006-01-02T15:04:05-07:00",
	}
	for _, format := range formats {
		if t, err := time.Parse(format, ts); err == nil {
			return t, nil
		}
	}
	return time.Time{}, fmt.Errorf("unable to parse timestamp")
}

// cleanLastCommand filters out system-generated content from the last command.
func cleanLastCommand(cmd string) string {
	// Tags to remove with their content
	tagsToRemove := []string{
		"local-command-stdout",
		"local-command-caveat",
		"local-command-stderr",
		"command-name",
		"command-message",
		"command-args",
		"system-reminder",
	}

	for _, tag := range tagsToRemove {
		for {
			openTag := "<" + tag + ">"
			closeTag := "</" + tag + ">"

			startIdx := strings.Index(cmd, openTag)
			if startIdx == -1 {
				break
			}
			endIdx := strings.Index(cmd[startIdx:], closeTag)
			if endIdx == -1 {
				// Remove just the opening tag if no close
				cmd = cmd[:startIdx] + cmd[startIdx+len(openTag):]
				break
			}
			// Remove entire tag with content
			cmd = cmd[:startIdx] + cmd[startIdx+endIdx+len(closeTag):]
		}
	}

	return strings.TrimSpace(cmd)
}

// getFirstPrompt returns the first prompt of the session, saving it if needed.
func getFirstPrompt(transcriptPath string, maxLen int) string {
	if transcriptPath == "" {
		return ""
	}

	// Session state file
	sessionID := filepath.Base(transcriptPath)
	sessionID = strings.TrimSuffix(sessionID, ".jsonl")
	stateFile := fmt.Sprintf("/tmp/claude_first_prompt_%s", sessionID)

	// Check if we already have it saved (format: prompt\nTIMESTAMP)
	if data, err := os.ReadFile(stateFile); err == nil {
		lines := strings.SplitN(string(data), "\n", 2)
		if len(lines) > 0 && strings.TrimSpace(lines[0]) != "" {
			return truncateString(strings.TrimSpace(lines[0]), maxLen)
		}
	}

	// Get first prompt from transcript
	firstPrompt, firstTime := extractFirstPrompt(transcriptPath)
	if firstPrompt == "" {
		return ""
	}

	// Save it for future (persists across compacts)
	os.WriteFile(stateFile, []byte(firstPrompt+"\n"+firstTime), 0644)

	return truncateString(firstPrompt, maxLen)
}

// getFirstPromptTime returns the timestamp of the first prompt.
func getFirstPromptTime(transcriptPath string) string {
	if transcriptPath == "" {
		return ""
	}

	sessionID := filepath.Base(transcriptPath)
	sessionID = strings.TrimSuffix(sessionID, ".jsonl")
	stateFile := fmt.Sprintf("/tmp/claude_first_prompt_%s", sessionID)

	// Read saved timestamp (format: prompt\nTIMESTAMP)
	if data, err := os.ReadFile(stateFile); err == nil {
		lines := strings.SplitN(string(data), "\n", 2)
		if len(lines) > 1 {
			return formatTimestamp(strings.TrimSpace(lines[1]))
		}
	}

	// Fallback: get from transcript
	_, firstTime := extractFirstPrompt(transcriptPath)
	return formatTimestamp(firstTime)
}

// extractFirstPrompt gets the first user message and timestamp from the transcript.
func extractFirstPrompt(transcriptPath string) (string, string) {
	f, err := os.Open(transcriptPath)
	if err != nil {
		return "", ""
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
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

		text := extractTextFromContent(msg.Message.Content)
		if text != "" {
			// Clean it up
			text = strings.TrimSpace(text)
			text = strings.ReplaceAll(text, "\n", " ")
			text = strings.ReplaceAll(text, "\t", " ")
			text = cleanLastCommand(text)
			// Collapse multiple spaces
			for strings.Contains(text, "  ") {
				text = strings.ReplaceAll(text, "  ", " ")
			}
			return text, msg.Timestamp
		}
	}
	return "", ""
}

// truncateString truncates a string to maxLen with ellipsis.
func truncateString(s string, maxLen int) string {
	if len(s) > maxLen {
		return s[:maxLen-3] + "..."
	}
	return s
}

// getClaudeProcessStats returns RAM (MB), CPU (%), and PID for THIS session's claude process.
func getClaudeProcessStats() (int, float64, int) {
	// Walk up process tree to find the claude process for this session
	pid := os.Getppid() // Start with parent
	for i := 0; i < 10; i++ { // Max 10 levels up
		// Get command name for this pid
		cmd := exec.Command("ps", "-o", "comm=", "-p", fmt.Sprintf("%d", pid))
		out, err := cmd.Output()
		if err != nil {
			break
		}
		comm := strings.TrimSpace(string(out))

		// Check if this is claude
		if strings.Contains(strings.ToLower(comm), "claude") {
			// Get stats for THIS claude process
			cmd = exec.Command("ps", "-o", "rss=,pcpu=", "-p", fmt.Sprintf("%d", pid))
			out, err = cmd.Output()
			if err != nil {
				return 0, 0, pid
			}
			stats := strings.Fields(strings.TrimSpace(string(out)))
			if len(stats) < 2 {
				return 0, 0, pid
			}
			rss := 0
			for _, c := range stats[0] {
				if c >= '0' && c <= '9' {
					rss = rss*10 + int(c-'0')
				}
			}
			cpu := 0.0
			fmt.Sscanf(stats[1], "%f", &cpu)
			return rss / 1024, cpu, pid
		}

		// Get parent of current pid
		cmd = exec.Command("ps", "-o", "ppid=", "-p", fmt.Sprintf("%d", pid))
		out, err = cmd.Output()
		if err != nil {
			break
		}
		ppid := 0
		fmt.Sscanf(strings.TrimSpace(string(out)), "%d", &ppid)
		if ppid <= 1 {
			break
		}
		pid = ppid
	}
	return 0, 0, 0
}

// getUserHost returns user@hostname string.
func getUserHost() string {
	user := os.Getenv("USER")
	if user == "" {
		user = "unknown"
	}

	// Get short hostname (uname -n equivalent)
	cmd := exec.Command("uname", "-n")
	output, err := cmd.Output()
	host := "localhost"
	if err == nil {
		host = strings.TrimSpace(string(output))
		// Remove .local suffix if present
		host = strings.TrimSuffix(host, ".local")
	}

	return user + "@" + host
}

