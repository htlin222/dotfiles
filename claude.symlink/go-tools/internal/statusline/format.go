package statusline

import (
	"fmt"
	"strconv"
	"strings"
)

// rainbowPalette is Claude Code's dark-theme ROYGBIV palette (from the
// "ultrathink" shimmer effect), used for a static gradient across text.
var rainbowPalette = [7][3]int{
	{235, 95, 87},   // red
	{245, 139, 87},  // orange
	{250, 195, 95},  // yellow
	{145, 200, 130}, // green
	{130, 170, 220}, // blue
	{155, 130, 200}, // indigo
	{200, 130, 180}, // violet
}

// rainbowColor returns the 24-bit ANSI SGR for position p of total,
// linearly interpolating between adjacent palette stops.
func rainbowColor(p, total int) string {
	if total < 2 {
		total = 2
	}
	f := float64(p) / float64(total-1) * float64(len(rainbowPalette)-1)
	i := int(f)
	if i >= len(rainbowPalette)-1 {
		i = len(rainbowPalette) - 2
	}
	frac := f - float64(i)
	a, b := rainbowPalette[i], rainbowPalette[i+1]
	lerp := func(x, y int) int { return x + int(float64(y-x)*frac) }
	return fmt.Sprintf("\033[38;2;%d;%d;%dm", lerp(a[0], b[0]), lerp(a[1], b[1]), lerp(a[2], b[2]))
}

// rainbowSpan colors runes as a slice of a longer gradient: their global
// positions start at startIdx within a text of total runes.
func rainbowSpan(runes []rune, startIdx, total int) string {
	var b strings.Builder
	for i, r := range runes {
		b.WriteString(rainbowColor(startIdx+i, total))
		b.WriteRune(r)
	}
	b.WriteString(Reset)
	return b.String()
}

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
