package statusline

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

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

func getUnixTime() int64 {
	cmd := exec.Command("date", "+%s")
	output, err := cmd.Output()
	if err != nil {
		return 0
	}
	t, _ := strconv.ParseInt(strings.TrimSpace(string(output)), 10, 64)
	return t
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

func sessionDuration2String(minutes int) string {
	return fmt.Sprintf("%dm", minutes)
}
