package statusline

import (
	"fmt"
	"strconv"
	"strings"
)

func getRamColor(mb int) string {
	switch {
	case mb >= 1000:
		return Red
	case mb >= 500:
		return Yellow
	default:
		return Gray
	}
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

// truncateString truncates a string to maxLen with ellipsis.
func truncateString(s string, maxLen int) string {
	if len(s) > maxLen {
		return s[:maxLen-3] + "..."
	}
	return s
}
