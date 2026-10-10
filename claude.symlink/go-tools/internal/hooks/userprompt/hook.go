// Package userprompt implements the UserPromptSubmit hook.
package userprompt

import (
	"encoding/json"
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
	"github.com/htlin/claude-tools/internal/turso"
	"github.com/htlin/claude-tools/pkg/ansi"
	"github.com/htlin/claude-tools/pkg/context"
	"github.com/htlin/claude-tools/pkg/metrics"
	"github.com/htlin/claude-tools/pkg/patterns"
)

// maxSnapshotBytes caps the @LAST injection so one keyword can't flood the context.
const maxSnapshotBytes = 16 * 1024

var (
	// @last / @img must stand alone as a token, not be part of an email or path.
	lastRe = regexp.MustCompile(`(?i)(?:^|\s)@last\b`)
	imgRe  = regexp.MustCompile(`(?i)(?:^|\s)@img(?:(\d+)(?:-(\d+))?|\s+x(\d+)|\s+(\d+)(m|h))?\b`)
)

// syntheticPrefixes mark turns the harness injects rather than the user typing.
var syntheticPrefixes = []string{"<task-notification>", "<system-reminder>"}

func isSyntheticPrompt(prompt string) bool {
	p := strings.TrimSpace(prompt)
	for _, prefix := range syntheticPrefixes {
		if strings.HasPrefix(p, prefix) {
			return true
		}
	}
	return false
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
		return
	}

	prompt := data.Prompt
	cwd := data.CWD
	sessionID := data.SessionID

	// Harness-generated turns (background task notifications etc.) also fire
	// UserPromptSubmit. They are not the user's words: don't log them, and
	// don't let text inside them (e.g. "@LAST") trigger context injection.
	if isSyntheticPrompt(prompt) {
		return
	}

	// Load state
	st, _ := state.Load()
	st.PromptCount++

	// messages are user-only notices (systemMessage); they never reach the
	// model. Model-relevant content goes through buildContext.
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
			messages = append(messages, "👑 清宮模式已啟動（QING=true）")
		}
	}

	// Log the prompt — redact likely secrets before persisting anywhere.
	// The raw prompt still drives feature processing below and still
	// reaches the model; only mirrored copies (jsonl, libSQL, Turso
	// cloud, quarantine) see the scrubbed version. If any redaction
	// rule fired we divert the row to a local-only JSONL so a residual
	// leak cannot reach the cloud mirror — the prompt itself is not
	// blocked, since the rules have too many benign matches (JSON,
	// deploy URLs, IDs) to justify aborting the user's turn.
	redaction := RedactSecrets(prompt)
	redactedPrompt := redaction.Text
	if prompt != "" {
		metrics.LogPrompt(cwd, redactedPrompt)
		if redaction.Triggered {
			appendQuarantine(redactedPrompt, sessionID, cwd, redaction.RuleHits)
		} else {
			captureToTurso(redactedPrompt, sessionID, cwd)
		}
	}

	// Feature 0: @LAST context injection
	var snapshotContent string
	if lastRe.MatchString(prompt) {
		if content, err := snapshot.Consume(cwd); err == nil && content != "" {
			if len(content) > maxSnapshotBytes {
				content = content[:maxSnapshotBytes] + "\n…(snapshot truncated)"
			}
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
		messages = append(messages, "⚠️ "+warning+" - 請確認這是你想要的操作")
	}

	// Feature 8: Token estimation warning
	if warning := patterns.CheckTokenHeavy(prompt); warning != "" {
		messages = append(messages, "⚠️ "+warning)
	}

	// Feature 6: Git status reminder
	if gitReminder := checkGitStatus(cwd, st); gitReminder != "" {
		messages = append(messages, gitReminder)
	}

	// Feature 9: Time reminder (every 10 prompts)
	if st.PromptCount%10 == 0 {
		if timeReminder := checkTimeReminder(st); timeReminder != "" {
			messages = append(messages, timeReminder)
		}
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

	// Output: additionalContext (model) + systemMessage (user only).
	if out := protocol.UserPromptResponse(
		buildContext(qingPersona, snapshotContent, imgPaths),
		ansi.Strip(strings.Join(messages, "\n")),
	); out != "" {
		fmt.Println(out)
	}

	// Log metrics (the per-prompt event log was dropped: it duplicated this
	// entry plus prompts.jsonl).
	executionTimeMS := float64(time.Since(startTime).Microseconds()) / 1000.0
	metrics.LogMetrics("user_prompt", "UserPromptSubmit", executionTimeMS, true, map[string]any{
		"session_id":       sessionID,
		"prompt_length":    len(prompt),
		"estimated_tokens": metrics.EstimateTokens(prompt),
		"messages_count":   len(messages),
	})
}

// buildContext assembles the model-facing additionalContext: QING persona,
// @LAST snapshot and @IMG screenshot paths only. Returns "" when none apply.
func buildContext(qingPersona, snapshotContent string, imgPaths []string) string {
	var parts []string
	if qingPersona != "" {
		parts = append(parts, "---\n"+qingPersona)
	}
	if snapshotContent != "" {
		parts = append(parts, "---\n## Previous Session Context\n"+snapshotContent)
	}
	if len(imgPaths) > 0 {
		lines := []string{"---\n## Screenshot"}
		for _, p := range imgPaths {
			lines = append(lines, "Please read and analyze this image file: "+p)
		}
		parts = append(parts, strings.Join(lines, "\n"))
	}
	return ansi.Strip(strings.Join(parts, "\n\n"))
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
		return fmt.Sprintf("Git: %d 個未提交變更，建議適時 commit", changeCount)
	}

	return ""
}

func checkTimeReminder(st *state.State) string {
	now := time.Now()
	var messages []string

	// Late night check (23:00 - 05:00)
	if now.Hour() >= 23 || now.Hour() < 5 {
		messages = append(messages, "🌙 深夜了，注意休息")
	}

	// Long session check
	if st.SessionStart != "" {
		startTime, err := time.Parse(time.RFC3339, st.SessionStart)
		if err == nil {
			duration := now.Sub(startTime).Hours()
			if duration > 2 {
				messages = append(messages, fmt.Sprintf("⏳ 已工作 %.1f 小時，建議休息一下", duration))
			}
		}
	} else {
		st.SessionStart = now.Format(time.RFC3339)
	}

	if len(messages) > 0 {
		return strings.Join(messages, " │ ")
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

// captureToTurso mirrors the prompt into a libSQL DB at ~/.claude/state/prompts.db.
// Always writes locally; if TURSO_DATABASE_URL/TURSO_AUTH_TOKEN are set, the
// client is an embedded replica and we kick off a detached `claude-hooks
// turso-sync` subprocess to push to the cloud out-of-band. Failures are
// silent — never block the user's prompt.
func captureToTurso(prompt, sessionID, cwd string) {
	url := os.Getenv("TURSO_DATABASE_URL")
	tok := os.Getenv("TURSO_AUTH_TOKEN")

	c, err := turso.Open(turso.DefaultDBPath(), url, tok)
	if err != nil || c == nil {
		return
	}
	defer c.Close()
	if err := c.EnsureSchema(); err != nil {
		return
	}
	host, _ := os.Hostname()
	_ = c.InsertPrompt(host, sessionID, cwd, prompt)

	if url == "" || tok == "" {
		return // local-only mode, nothing to sync
	}
	cmd := exec.Command(os.Args[0], "turso-sync")
	cmd.Stdin, cmd.Stdout, cmd.Stderr = nil, nil, nil
	cmd.SysProcAttr = detachSysProcAttr()
	_ = cmd.Start()
}
