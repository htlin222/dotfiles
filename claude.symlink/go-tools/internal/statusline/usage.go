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

// GetUsageData returns rate-limit usage, preferring the stdin-provided
// rate_limits field (added by Claude Code) and falling back to the OAuth usage API.
func GetUsageData(input *protocol.StatuslineInput) *UsageData {
	data := &UsageData{
		TimeLeft:        "--",
		WeeklyResetDate: "--",
	}

	// Prefer rate_limits from stdin JSON (no API call, never rate-limited)
	if input != nil && input.RateLimits != nil {
		got := false
		if p := input.RateLimits.FiveHour; p != nil {
			data.FiveHourPct = int(p.UsedPercentage)
			if p.ResetsAt > 0 {
				data.TimeLeft = formatTimeUntilEpoch(p.ResetsAt)
			}
			got = true
		}
		if p := input.RateLimits.SevenDay; p != nil {
			data.WeeklyPct = int(p.UsedPercentage)
			if p.ResetsAt > 0 {
				data.WeeklyResetDate = formatResetDateEpoch(p.ResetsAt)
			}
			got = true
		}
		if got {
			return data
		}
	}

	// Fallback: OAuth token from macOS Keychain
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
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return data
	}

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

// formatTimeUntil renders the reset moment as actual clock time hh:mm (GMT+8).
func formatTimeUntil(resetTime string) string {
	t, err := time.Parse(time.RFC3339, resetTime)
	if err != nil {
		return "--"
	}
	gmt8 := time.FixedZone("GMT+8", 8*60*60)
	return t.In(gmt8).Format("15:04")
}

func formatResetDate(resetTime string) string {
	t, err := time.Parse(time.RFC3339, resetTime)
	if err != nil {
		return "--"
	}
	gmt8 := time.FixedZone("GMT+8", 8*60*60)
	return t.In(gmt8).Format("01/02 15:04")
}

func formatTimeUntilEpoch(epochSeconds int64) string {
	return formatTimeUntil(time.Unix(epochSeconds, 0).UTC().Format(time.RFC3339))
}

func formatResetDateEpoch(epochSeconds int64) string {
	gmt8 := time.FixedZone("GMT+8", 8*60*60)
	return time.Unix(epochSeconds, 0).In(gmt8).Format("01/02 15:04")
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
