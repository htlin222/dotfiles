// Package userprompt implements the UserPromptSubmit hook.
package userprompt

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/htlin/claude-tools/internal/hooks/busy"
	"github.com/htlin/claude-tools/internal/hooks/killtimer"
	"github.com/htlin/claude-tools/internal/protocol"
	"github.com/htlin/claude-tools/internal/snapshot"
	"github.com/htlin/claude-tools/internal/state"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/context"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// errStopWalk signals filepath.Walk to stop walking (Go 1.18 compatible alternative to filepath.SkipAll)
var errStopWalk = errors.New("stop walking")

// Project types for detection
var projectTypes = map[string]struct {
	Files   []string
	Message string
}{
	"node":   {[]string{"package.json"}, "Node.js 專案"},
	"python": {[]string{"pyproject.toml", "setup.py", "requirements.txt"}, "Python 專案"},
	"rust":   {[]string{"Cargo.toml"}, "Rust 專案"},
	"go":     {[]string{"go.mod"}, "Go 專案"},
	"ruby":   {[]string{"Gemfile"}, "Ruby 專案"},
	"java":   {[]string{"pom.xml", "build.gradle"}, "Java 專案"},
}

// Run executes the user prompt hook.
func Run() {
	// Cancel any pending kill timer — user is still active
	if strings.EqualFold(os.Getenv("CLAUDE_STOP_AND_KILL"), "true") {
		if claudePID := killtimer.FindClaudePID(); claudePID > 0 {
			killtimer.Cancel(claudePID)
		}
	}

	if pane := busy.GetTmuxPane(); pane != "" {
		busy.SetBusy(pane)
	}

	startTime := time.Now()

	input, err := io.ReadAll(os.Stdin)
	if err != nil || len(strings.TrimSpace(string(input))) == 0 {
		return
	}

	var data protocol.HookInput
	if err := json.Unmarshal(input, &data); err != nil {
		fmt.Println(protocol.ContinueResponse())
		return
	}

	prompt := data.Prompt
	cwd := data.CWD
	sessionID := data.SessionID

	// Load state
	st, _ := state.Load()
	st.PromptCount++

	var messages []string

	// Feature: Qing dynasty court roleplay (env QING=true)
	var qingPersona string
	if strings.EqualFold(os.Getenv("QING"), "true") {
		if st.QingPersona == "" {
			// First prompt: roll persona and persist
			rollScript := filepath.Join(os.Getenv("HOME"), ".claude", "skills", "qing", "roll.sh")
			if out, err := exec.Command("bash", rollScript).Output(); err == nil && len(out) > 0 {
				st.QingPersona = strings.TrimSpace(string(out))
			}
		}
		qingPersona = st.QingPersona
		if qingPersona != "" && st.PromptCount == 1 {
			messages = append(messages, fmt.Sprintf("%s👑%s 清宮模式已啟動（QING=true）",
				ansi.BrightYellow, ansi.Reset))
		}
	}

	// Log the prompt
	if prompt != "" {
		metrics.LogPrompt(cwd, prompt)
	}

	// Feature 0: @LAST context injection
	var snapshotContent string
	if strings.Contains(strings.ToUpper(prompt), "@LAST") {
		if content, err := snapshot.Consume(cwd); err == nil && content != "" {
			snapshotContent = content
			messages = append(messages, "✅ 前次上下文已載入")
		} else {
			messages = append(messages, "⚠️ 無可用的前次上下文快照")
		}
	}

	// Feature 0b: @IMG — inject screenshots from $SCREENSHOT_DIR (default: /tmp/screenshot)
	// Syntax: @img (latest), @img1/@img2/... (nth newest), @img1-3 (range),
	//         @img x3 (last 3), @img 3m (last 3 minutes), @img 2h (last 2 hours)
	// Multiple @img references in one prompt are supported and deduplicated.
	const maxImgLoad = 10
	screenshotDir := os.Getenv("SCREENSHOT_DIR")
	if screenshotDir == "" {
		screenshotDir = "/tmp/screenshot"
	}
	var imgPaths []string
	imgRe := regexp.MustCompile(`(?i)@img(?:(\d+)(?:-(\d+))?|\s+x(\d+)|\s+(\d+)(m|h))?`)
	if allMatches := imgRe.FindAllStringSubmatch(prompt, -1); len(allMatches) > 0 {
		allFiles, err := findSortedFiles(screenshotDir)
		if err != nil || len(allFiles) == 0 {
			if os.IsNotExist(err) {
				messages = append(messages, fmt.Sprintf("⚠️ 截圖目錄不存在: %s（可設 SCREENSHOT_DIR 環境變數）", screenshotDir))
			} else {
				messages = append(messages, fmt.Sprintf("⚠️ %s 中無可用截圖", screenshotDir))
			}
		} else {
			seen := map[string]bool{}
			addPath := func(p string) {
				if !seen[p] {
					seen[p] = true
					imgPaths = append(imgPaths, p)
				}
			}

			for _, matches := range allMatches {
				if matches[5] != "" {
					// @img Nm or @img Nh — time-based
					n, _ := strconv.Atoi(matches[4])
					dur := time.Duration(n) * time.Minute
					if matches[5] == "h" || matches[5] == "H" {
						dur = time.Duration(n) * time.Hour
					}
					unit := "分鐘"
					if matches[5] == "h" || matches[5] == "H" {
						unit = "小時"
					}
					cutoff := time.Now().Add(-dur)
					count := 0
					for _, f := range allFiles {
						if info, err := os.Stat(f); err == nil && info.ModTime().After(cutoff) {
							addPath(f)
							count++
						}
					}
					if count == 0 {
						messages = append(messages, fmt.Sprintf("⚠️ 最近 %d %s內無截圖", n, unit))
					} else {
						messages = append(messages, fmt.Sprintf("🖼️ 已載入最近 %d %s內的 %d 張截圖", n, unit, count))
					}
				} else if matches[3] != "" {
					// @img xN — last N files
					n, _ := strconv.Atoi(matches[3])
					if n > len(allFiles) {
						n = len(allFiles)
					}
					for _, f := range allFiles[:n] {
						addPath(f)
					}
					messages = append(messages, fmt.Sprintf("🖼️ 已載入最新 %d 張截圖", n))
				} else if matches[1] != "" {
					start, _ := strconv.Atoi(matches[1])
					if start < 1 {
						start = 1
					}
					end := start
					if matches[2] != "" {
						// @imgA-B — range
						end, _ = strconv.Atoi(matches[2])
					}
					if start > len(allFiles) {
						messages = append(messages, fmt.Sprintf("⚠️ 只有 %d 張截圖，無法取得第 %d 張", len(allFiles), start))
					} else {
						if end > len(allFiles) {
							end = len(allFiles)
						}
						for i := start; i <= end; i++ {
							addPath(allFiles[i-1])
						}
						if start == end {
							messages = append(messages, fmt.Sprintf("🖼️ 已載入第 %d 新截圖: %s", start, filepath.Base(allFiles[start-1])))
						} else {
							messages = append(messages, fmt.Sprintf("🖼️ 已載入第 %d-%d 新截圖（共 %d 張）", start, end, end-start+1))
						}
					}
				} else {
					// @img — latest
					addPath(allFiles[0])
					messages = append(messages, fmt.Sprintf("🖼️ 已載入最新截圖: %s", filepath.Base(allFiles[0])))
				}
			}

			// Cap at maxImgLoad
			if len(imgPaths) > maxImgLoad {
				imgPaths = imgPaths[:maxImgLoad]
				messages = append(messages, fmt.Sprintf("⚠️ 截圖上限 %d 張，已截斷", maxImgLoad))
			}
		}
	}

	// Feature 1: Check for dangerous patterns
	if warning := patterns.CheckDangerousPatterns(prompt); warning != "" {
		messages = append(messages, fmt.Sprintf("%s%s%s %s - 請確認這是你想要的操作",
			ansi.BrightRed, ansi.IconWarning, ansi.Reset, warning))
	}

	// Feature 8: Token estimation warning
	if warning := patterns.CheckTokenHeavy(prompt); warning != "" {
		messages = append(messages, fmt.Sprintf("%s%s%s %s",
			ansi.BrightYellow, ansi.IconWarning, ansi.Reset, warning))
	}

	// Feature 10: Tool efficiency hint
	if nativeTool := patterns.CheckToolEfficiency(prompt); nativeTool != "" {
		messages = append(messages, fmt.Sprintf("%s%s%s Hint: prefer native %s tool over bash command",
			ansi.BrightCyan, ansi.IconSearch, ansi.Reset, nativeTool))
	}

	// Feature 12: Complex task delegation hint
	if patterns.CheckComplexTask(prompt) {
		messages = append(messages, fmt.Sprintf("%s%s%s Complex task detected: consider using Task agents to delegate work",
			ansi.BrightMagenta, ansi.IconRocket, ansi.Reset))
	} else if patterns.CheckImplementationTask(prompt) {
		messages = append(messages, fmt.Sprintf("%s%s%s Implementation task detected: delegate edits to Task agents to preserve context",
			ansi.BrightMagenta, ansi.IconRocket, ansi.Reset))
	}

	// Feature 3: Suggest skill if applicable
	if suggestion := patterns.SuggestSkill(prompt); suggestion != "" {
		messages = append(messages, fmt.Sprintf("%s%s%s %s",
			ansi.BrightCyan, ansi.IconMagic, ansi.Reset, suggestion))
	}

	// Feature 5: Smart context loading (first few prompts only)
	if st.PromptCount <= 3 {
		if contextSuggestion := checkLargeProject(cwd, st); contextSuggestion != "" {
			messages = append(messages, contextSuggestion)
		}
	}

	// Feature 6: Git status reminder
	if gitReminder := checkGitStatus(cwd, st); gitReminder != "" {
		messages = append(messages, gitReminder)
	}

	// Feature 7: Similar prompt detection
	if similarWarning := checkSimilarPrompt(prompt, st); similarWarning != "" {
		messages = append(messages, similarWarning)
	}

	// Feature 9: Time reminder (every 10 prompts)
	if st.PromptCount%10 == 0 {
		if timeReminder := checkTimeReminder(st); timeReminder != "" {
			messages = append(messages, timeReminder)
		}
	}

	// Feature 11: Model efficiency hint (every 20 prompts)
	if st.PromptCount%20 == 0 {
		messages = append(messages, "💡 Tip: delegate Edit-heavy tasks to Task(model:haiku) to save context")
	}

	// Feature 13: Context pressure monitor (every 5 prompts, uses real data from statusline)
	if st.PromptCount-st.LastPressureCheck >= 5 {
		if pressureMsg := context.CheckPressure(); pressureMsg != "" {
			messages = append(messages, pressureMsg)
			st.LastPressureCheck = st.PromptCount
		}
	}

	// Save state
	state.Save(st)

	// Build additionalContext
	var contextParts []string
	if qingPersona != "" {
		contextParts = append(contextParts, "\n---\n"+qingPersona)
	}
	if snapshotContent != "" {
		contextParts = append(contextParts, "\n---\n## Previous Session Context\n"+snapshotContent)
	}
	if len(imgPaths) > 0 {
		var imgLines []string
		imgLines = append(imgLines, "\n---\n## Screenshot")
		for _, p := range imgPaths {
			imgLines = append(imgLines, "Please read and analyze this image file: "+p)
		}
		contextParts = append(contextParts, strings.Join(imgLines, "\n"))
	}
	contextParts = append(contextParts, messages...)

	// Output response
	fmt.Println(protocol.UserPromptResponse(strings.Join(contextParts, "\n")))

	// Log metrics
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("user_prompt", "UserPromptSubmit", executionTimeMS, true, map[string]any{
		"session_id":       sessionID,
		"prompt_length":    len(prompt),
		"estimated_tokens": metrics.EstimateTokens(prompt),
		"messages_count":   len(messages),
	})

	metrics.LogEvent("UserPromptSubmit", "user_prompt", sessionID, cwd, map[string]any{
		"prompt_preview": truncate(prompt, 100),
		"suggestions":    messages,
	})
}

func checkLargeProject(cwd string, st *state.State) string {
	if cwd == "" {
		return ""
	}

	// Don't suggest too frequently
	if st.LastContextSuggestion > 0 {
		promptsSince := st.PromptCount - st.LastContextSuggestion
		if promptsSince < 10 {
			return ""
		}
	}

	// Count files (rough estimate)
	skipDirs := map[string]bool{
		".git": true, "node_modules": true, "__pycache__": true,
		".venv": true, "venv": true, "dist": true, "build": true, ".next": true,
	}

	fileCount := 0
	filepath.Walk(cwd, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		if info.IsDir() {
			if skipDirs[info.Name()] {
				return filepath.SkipDir
			}
			return nil
		}
		fileCount++
		if fileCount > 100 {
			return errStopWalk
		}
		return nil
	})

	if fileCount > 100 {
		st.LastContextSuggestion = st.PromptCount
		return fmt.Sprintf("%s%s%s 大型專案偵測（100+ 檔案），建議先執行 %s/prime%s 載入 context",
			ansi.BrightYellow, ansi.IconFolder, ansi.Reset,
			ansi.BrightCyan, ansi.Reset)
	}

	return ""
}

func checkGitStatus(cwd string, st *state.State) string {
	if cwd == "" {
		return ""
	}

	// Check at most once per 5 prompts
	if st.LastGitCheck > 0 {
		promptsSince := st.PromptCount - st.LastGitCheck
		if promptsSince < 5 {
			return ""
		}
	}

	// Check if in git repo
	cmd := exec.Command("git", "rev-parse", "--is-inside-work-tree")
	cmd.Dir = cwd
	if err := cmd.Run(); err != nil {
		return ""
	}

	// Get status
	cmd = exec.Command("git", "status", "--porcelain")
	cmd.Dir = cwd
	output, err := cmd.Output()
	if err != nil {
		return ""
	}

	st.LastGitCheck = st.PromptCount

	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	changeCount := 0
	for _, line := range lines {
		if line != "" {
			changeCount++
		}
	}

	if changeCount > 10 {
		return fmt.Sprintf("%s%s%s Git: %s%d%s 個未提交變更，建議適時 commit",
			ansi.BrightYellow, ansi.IconGit, ansi.Reset,
			ansi.BrightWhite, changeCount, ansi.Reset)
	}

	return ""
}

func checkSimilarPrompt(prompt string, st *state.State) string {
	// Create a simple hash of the prompt (normalized)
	normalized := regexp.MustCompile(`\s+`).ReplaceAllString(strings.ToLower(strings.TrimSpace(prompt)), " ")
	hash := md5.Sum([]byte(normalized))
	promptHash := hex.EncodeToString(hash[:])[:8]

	// Check for similar match
	if st.HasPromptHash(promptHash) {
		return fmt.Sprintf("%s%s%s 偵測到相似問題，可參考之前的對話紀錄",
			ansi.BrightCyan, ansi.IconSync, ansi.Reset)
	}

	// Add to history
	st.AddPromptHash(promptHash)

	return ""
}

func checkTimeReminder(st *state.State) string {
	now := time.Now()
	var messages []string

	// Late night check (23:00 - 05:00)
	if now.Hour() >= 23 || now.Hour() < 5 {
		messages = append(messages, fmt.Sprintf("%s%s%s 深夜了，注意休息",
			ansi.BrightMagenta, ansi.IconClock, ansi.Reset))
	}

	// Long session check
	if st.SessionStart != "" {
		startTime, err := time.Parse(time.RFC3339, st.SessionStart)
		if err == nil {
			duration := now.Sub(startTime).Hours()
			if duration > 2 {
				messages = append(messages, fmt.Sprintf("%s%s%s 已工作 %s%.1f%s 小時，建議休息一下",
					ansi.BrightYellow, ansi.IconHourglass, ansi.Reset,
					ansi.BrightWhite, duration, ansi.Reset))
			}
		}
	} else {
		st.SessionStart = now.Format(time.RFC3339)
	}

	if len(messages) > 0 {
		return strings.Join(messages, fmt.Sprintf(" %s│%s ", ansi.Dim, ansi.Reset))
	}

	return ""
}

// findSortedFiles returns files in dir sorted by modification time (newest first).
func findSortedFiles(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	type fileEntry struct {
		path    string
		modTime time.Time
	}
	var files []fileEntry

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		info, err := entry.Info()
		if err != nil {
			continue
		}
		files = append(files, fileEntry{
			path:    filepath.Join(dir, entry.Name()),
			modTime: info.ModTime(),
		})
	}

	if len(files) == 0 {
		return nil, fmt.Errorf("no files found in %s", dir)
	}

	// Sort newest first
	sort.Slice(files, func(i, j int) bool {
		return files[j].modTime.Before(files[i].modTime)
	})

	result := make([]string, len(files))
	for i, f := range files {
		result[i] = f.path
	}
	return result, nil
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen]
}

