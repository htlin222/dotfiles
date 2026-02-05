// Package ansi provides ANSI color codes and styling for terminal output.
package ansi

import "fmt"

// ANSI escape codes for colors and styles
const (
	// Reset
	Reset = "\033[0m"

	// Styles
	Bold          = "\033[1m"
	Dim           = "\033[2m"
	Italic        = "\033[3m"
	Underline     = "\033[4m"
	Blink         = "\033[5m"
	Reverse       = "\033[7m"
	Strikethrough = "\033[9m"

	// Regular Colors
	Black   = "\033[30m"
	Red     = "\033[31m"
	Green   = "\033[32m"
	Yellow  = "\033[33m"
	Blue    = "\033[34m"
	Magenta = "\033[35m"
	Cyan    = "\033[36m"
	White   = "\033[37m"

	// Bright Colors
	BrightBlack   = "\033[90m"
	BrightRed     = "\033[91m"
	BrightGreen   = "\033[92m"
	BrightYellow  = "\033[93m"
	BrightBlue    = "\033[94m"
	BrightMagenta = "\033[95m"
	BrightCyan    = "\033[96m"
	BrightWhite   = "\033[97m"

	// Background Colors
	BgBlack   = "\033[40m"
	BgRed     = "\033[41m"
	BgGreen   = "\033[42m"
	BgYellow  = "\033[43m"
	BgBlue    = "\033[44m"
	BgMagenta = "\033[45m"
	BgCyan    = "\033[46m"
	BgWhite   = "\033[47m"

	// Bright Background Colors
	BgBrightBlack   = "\033[100m"
	BgBrightRed     = "\033[101m"
	BgBrightGreen   = "\033[102m"
	BgBrightYellow  = "\033[103m"
	BgBrightBlue    = "\033[104m"
	BgBrightMagenta = "\033[105m"
	BgBrightCyan    = "\033[106m"
	BgBrightWhite   = "\033[107m"
)

// Fg returns a foreground color from the 256-color palette.
func Fg(code int) string {
	return fmt.Sprintf("\033[38;5;%dm", code)
}

// Bg returns a background color from the 256-color palette.
func Bg(code int) string {
	return fmt.Sprintf("\033[48;5;%dm", code)
}

// RGB returns a foreground color from RGB values.
func RGB(r, g, b int) string {
	return fmt.Sprintf("\033[38;2;%d;%d;%dm", r, g, b)
}

// BgRGB returns a background color from RGB values.
func BgRGB(r, g, b int) string {
	return fmt.Sprintf("\033[48;2;%d;%d;%dm", r, g, b)
}

// Style applies multiple styles to text.
func Style(text string, styles ...string) string {
	var prefix string
	for _, s := range styles {
		prefix += s
	}
	return prefix + text + Reset
}

// Success formats a success message.
func Success(text string) string {
	return fmt.Sprintf("%s%s %s%s", BrightGreen, IconCheck, text, Reset)
}

// Error formats an error message.
func Error(text string) string {
	return fmt.Sprintf("%s%s %s%s", BrightRed, IconCross, text, Reset)
}

// Warning formats a warning message.
func Warning(text string) string {
	return fmt.Sprintf("%s%s %s%s", BrightYellow, IconWarning, text, Reset)
}

// Info formats an info message.
func Info(text string) string {
	return fmt.Sprintf("%s%s %s%s", BrightCyan, IconInfo, text, Reset)
}

// DimText formats dimmed text.
func DimText(text string) string {
	return fmt.Sprintf("%s%s%s", Dim, text, Reset)
}

// BoldText formats bold text.
func BoldText(text string) string {
	return fmt.Sprintf("%s%s%s", Bold, text, Reset)
}

// Header formats a section header.
func Header(text string) string {
	return fmt.Sprintf("%s%s%s %s%s", Bold, BrightCyan, IconClaude, text, Reset)
}

// Separator creates a separator line.
func Separator(char string, length int) string {
	var result string
	for i := 0; i < length; i++ {
		result += char
	}
	return fmt.Sprintf("%s%s%s", Dim, result, Reset)
}

// GetColorForPercent returns appropriate color based on percentage.
func GetColorForPercent(pct int) string {
	switch {
	case pct >= 90:
		return BrightRed
	case pct >= 75:
		return BrightYellow
	case pct >= 60:
		return Yellow
	default:
		return BrightGreen
	}
}

// GetBgColorForPercent returns appropriate background color based on percentage.
func GetBgColorForPercent(pct int) string {
	switch {
	case pct >= 90:
		return BgRed
	case pct >= 75:
		return BgBrightYellow
	case pct >= 60:
		return BgYellow
	default:
		return BgGreen
	}
}

// SeverityStyle applies styling based on severity level.
func SeverityStyle(severity, text string) string {
	switch severity {
	case "critical":
		return fmt.Sprintf("%s%s%s %s%s", Bold, BrightRed, IconFire, text, Reset)
	case "high":
		return fmt.Sprintf("%s%s %s%s", BrightRed, IconExclaim, text, Reset)
	case "medium":
		return fmt.Sprintf("%s%s %s%s", BrightYellow, IconWarning, text, Reset)
	case "low":
		return fmt.Sprintf("%s%s %s%s", BrightCyan, IconInfo, text, Reset)
	case "info":
		return fmt.Sprintf("%s%s %s%s", Dim, IconInfo, text, Reset)
	default:
		return text
	}
}
