package statusline

import (
	"encoding/json"
	"net/http"
	"os/exec"
	"time"

	"github.com/htlin/claude-tools/internal/protocol"
)

// UsageData contains parsed usage information.
type UsageData struct {
	FiveHourPct     int
	WeeklyPct       int
	TimeLeft        string
	WeeklyResetDate string
}

// GetUsageData fetches real usage data from Anthropic's OAuth API.
func GetUsageData() *UsageData {
	data := &UsageData{
		TimeLeft:        "--",
		WeeklyResetDate: "--",
	}

	// Get OAuth token from macOS Keychain
	cmd := exec.Command("security", "find-generic-password", "-s", "Claude Code-credentials", "-w")
	output, err := cmd.Output()
	if err != nil {
		return data
	}

	var creds struct {
		ClaudeAiOauth struct {
			AccessToken string `json:"accessToken"`
		} `json:"claudeAiOauth"`
	}
	if err := json.Unmarshal(output, &creds); err != nil {
		return data
	}

	token := creds.ClaudeAiOauth.AccessToken
	if token == "" {
		return data
	}

	// Call the usage API
	client := &http.Client{Timeout: 5 * time.Second}
	req, err := http.NewRequest("GET", "https://api.anthropic.com/api/oauth/usage", nil)
	if err != nil {
		return data
	}

	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("anthropic-beta", "oauth-2025-04-20")

	resp, err := client.Do(req)
	if err != nil {
		return data
	}
	defer resp.Body.Close()

	var usageResp protocol.UsageAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&usageResp); err != nil {
		return data
	}

	data.FiveHourPct = int(usageResp.FiveHour.Utilization)
	data.WeeklyPct = int(usageResp.SevenDay.Utilization)

	// Calculate time left until reset
	if usageResp.FiveHour.ResetsAt != "" {
		data.TimeLeft = formatTimeUntil(usageResp.FiveHour.ResetsAt)
	}

	// Format weekly reset date
	if usageResp.SevenDay.ResetsAt != "" {
		data.WeeklyResetDate = formatResetDate(usageResp.SevenDay.ResetsAt)
	}

	return data
}

func formatTimeUntil(resetTime string) string {
	t, err := time.Parse(time.RFC3339, resetTime)
	if err != nil {
		return "--"
	}

	diff := time.Until(t)
	if diff < 0 {
		return "0m"
	}

	hours := int(diff.Hours())
	minutes := int(diff.Minutes()) % 60

	if hours > 0 {
		return formatInt(hours) + "h" + formatIntPad(minutes) + "m"
	}
	return formatInt(minutes) + "m"
}

func formatResetDate(resetTime string) string {
	t, err := time.Parse(time.RFC3339, resetTime)
	if err != nil {
		return "--"
	}
	return t.Format("01/02 15:04")
}

func formatInt(n int) string {
	if n < 10 {
		return string(rune('0'+n))
	}
	return string(rune('0'+n/10)) + string(rune('0'+n%10))
}

func formatIntPad(n int) string {
	if n < 10 {
		return "0" + string(rune('0'+n))
	}
	return string(rune('0'+n/10)) + string(rune('0'+n%10))
}
