package statusline

import (
	"fmt"
	"time"
)

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
	return t.Local().Format("15:04:05") + " GMT+8"
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
