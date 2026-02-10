package statusline

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

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
