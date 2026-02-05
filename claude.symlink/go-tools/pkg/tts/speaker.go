// Package tts provides text-to-speech functionality for macOS.
package tts

import (
	"os"
	"os/exec"
	"syscall"

	"github.com/htlin/claude-tools/internal/config"
)

const (
	defaultVoice = "Samantha"
	defaultRate  = "200"
)

// IsMuted checks if TTS is muted via environment variable.
func IsMuted() bool {
	val := os.Getenv("CLAUDE_MUTE")
	return val == "1" || val == "true" || val == "yes"
}

// Say speaks text using macOS say command with file locking.
func Say(message string) bool {
	return SayWithVoice(message, defaultVoice, defaultRate)
}

// SayWithVoice speaks text with specified voice and rate.
func SayWithVoice(message, voice, rate string) bool {
	if IsMuted() {
		return false
	}

	// Check if say command exists
	if _, err := exec.LookPath("say"); err != nil {
		return false
	}

	lockFile := config.TTSLockFile()

	// Ensure lock directory exists
	if err := os.MkdirAll(config.ClaudeDir, 0755); err != nil {
		return false
	}

	// Open lock file
	lock, err := os.OpenFile(lockFile, os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return false
	}
	defer lock.Close()

	// Acquire exclusive lock (blocking)
	if err := syscall.Flock(int(lock.Fd()), syscall.LOCK_EX); err != nil {
		return false
	}
	defer syscall.Flock(int(lock.Fd()), syscall.LOCK_UN)

	// Run say command
	cmd := exec.Command("say", "-v", voice, "-r", rate, message)
	cmd.Stdout = nil
	cmd.Stderr = nil
	cmd.Run()

	return true
}

// NotifyFileSaved notifies when a file is saved/edited.
func NotifyFileSaved(filePath, toolName string) bool {
	filename := filePath
	if idx := len(filePath) - 1; idx >= 0 {
		for i := idx; i >= 0; i-- {
			if filePath[i] == '/' || filePath[i] == '\\' {
				filename = filePath[i+1:]
				break
			}
		}
	}
	return Say(filename + " saved")
}

// NotifyBashComplete notifies when a bash command completes.
func NotifyBashComplete(command string, exitCode int, cwd string) bool {
	// Skip notification for common quick commands
	quickCommands := []string{"ls", "cd", "pwd", "echo", "cat", "head", "tail", "grep"}
	cmdName := ""
	for i, c := range command {
		if c == ' ' {
			cmdName = command[:i]
			break
		}
	}
	if cmdName == "" {
		cmdName = command
	}

	for _, qc := range quickCommands {
		if cmdName == qc {
			return false
		}
	}

	// Only notify on errors or specific commands
	if exitCode != 0 {
		return Say("Command failed")
	}

	// Notify for specific important commands
	importantPrefixes := []string{"git push", "git commit", "npm", "pnpm", "yarn", "make", "docker"}
	for _, prefix := range importantPrefixes {
		if len(command) >= len(prefix) && command[:len(prefix)] == prefix {
			return Say("Command completed")
		}
	}

	return false
}

// NotifySessionComplete notifies when a session completes with summary.
func NotifySessionComplete(projectName string, filesFormatted, filesEdited int, transcriptBackedUp bool) bool {
	var parts []string

	if projectName != "" {
		parts = append(parts, projectName)
	}

	if filesEdited > 0 {
		parts = append(parts, "files changed")
	}

	if filesFormatted > 0 {
		parts = append(parts, "files formatted")
	}

	if transcriptBackedUp {
		parts = append(parts, "transcript saved")
	}

	var message string
	if len(parts) > 0 {
		message = ""
		for i, p := range parts {
			if i > 0 {
				message += ", "
			}
			message += p
		}
		message += ". Session complete."
	} else {
		message = "Session complete"
	}

	return Say(message)
}
