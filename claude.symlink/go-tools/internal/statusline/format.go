package statusline

import (
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
	if tokens >= 1000 {
		return strconv.Itoa(tokens / 1000)
	}
	return strconv.Itoa(tokens)
}

func formatTokensShort(tokens int) string {
	if tokens >= 1000 {
		return strconv.Itoa(tokens / 1000)
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

// wrapPrompt wraps s into at most 2 lines of the given rune width,
// breaking at word boundaries and trimming the second line with an
// ellipsis if it overflows.
func wrapPrompt(s string, width int) []string {
	if width < 10 {
		width = 10
	}
	r := []rune(s)
	if len(r) <= width {
		return []string{s}
	}

	cut := wordBreakPoint(r, width)
	first := strings.TrimRight(string(r[:cut]), " ")
	rest := []rune(strings.TrimLeft(string(r[cut:]), " "))
	if len(rest) > width {
		cut2 := wordBreakPoint(rest, width-1)
		rest = append(rest[:cut2], '…')
	}
	return []string{first, string(rest)}
}

// wordBreakPoint returns the index to break r so the first part fits in
// width runes, preferring the last space; falls back to a hard break
// when no space exists (e.g. one long token or CJK without spaces).
func wordBreakPoint(r []rune, width int) int {
	for i := width; i > 0; i-- {
		if r[i] == ' ' {
			return i
		}
	}
	return width
}
