package ansi

import "path/filepath"

// UTF-8 icons for visual styling (portable, no Nerd Font required)
const (
	// Status Icons
	IconCheck    = "✓" // U+2713
	IconCross    = "✗" // U+2717
	IconWarning  = "⚠" // U+26A0
	IconInfo     = "ℹ" // U+2139
	IconQuestion = "?" // U+003F
	IconExclaim  = "!" // U+0021
	IconPlus     = "+" // U+002B
	IconMinus    = "−" // U+2212

	// File & Folder Icons
	IconFile       = "◇" // U+25C7
	IconFileCode   = "◈" // U+25C8
	IconFileText   = "▤" // U+25A4
	IconFolder     = "□" // U+25A1
	IconFolderOpen = "▣" // U+25A3
	IconFolderGit  = "□" // U+25A1
	IconSave       = "⊡" // U+22A1

	// Code & Dev Icons
	IconCode     = "⟨⟩" // U+27E8 U+27E9
	IconTerminal = "▸"  // U+25B8
	IconBug      = "¤"  // U+00A4
	IconGear     = "⚙"  // U+2699
	IconWrench   = "⚒"  // U+2692
	IconMagic    = "✦"  // U+2726
	IconRocket   = "↗"  // U+2197

	// Git Icons
	IconGit    = "⎇" // U+2387
	IconGitHub = "⊙" // U+2299
	IconBranch = "⎇" // U+2387
	IconCommit = "◉" // U+25C9
	IconMerge  = "⊕" // U+2295

	// Status & Progress Icons
	IconPlay      = "▶" // U+25B6
	IconPause     = "⏸" // U+23F8
	IconStop      = "■" // U+25A0
	IconSpinner   = "◌" // U+25CC
	IconClock     = "◷" // U+25F7
	IconHourglass = "⧗" // U+29D7

	// Security Icons
	IconLock   = "⊘" // U+2298
	IconUnlock = "⊙" // U+2299
	IconShield = "⊞" // U+229E
	IconKey    = "⚿" // U+26BF

	// Misc Icons
	IconLightning = "⚡" // U+26A1
	IconStar      = "★"  // U+2605
	IconHeart     = "♥"  // U+2665
	IconFire      = "△"  // U+25B3
	IconDatabase  = "⊞"  // U+229E
	IconCloud     = "☁"  // U+2601
	IconDownload  = "↓"  // U+2193
	IconUpload    = "↑"  // U+2191
	IconSync      = "⟳"  // U+27F3
	IconSearch    = "⌕"  // U+2315
	IconEye       = "◎"  // U+25CE
	IconComment   = "▹"  // U+25B9
	IconBell      = "♪"  // U+266A
	IconFlag      = "⚑"  // U+2691
	IconTag       = "⏏"  // U+23CF
	IconBookmark  = "▷"  // U+25B7
	IconTrash     = "⊗"  // U+2297
	IconEdit      = "✎"  // U+270E
	IconCopy      = "⊡"  // U+22A1
	IconPaste     = "⊟"  // U+229F
	IconLink      = "∞"  // U+221E
	IconUnlink    = "≠"  // U+2260

	// Arrow Icons
	IconArrowRight   = "→" // U+2192
	IconArrowLeft    = "←" // U+2190
	IconArrowUp      = "↑" // U+2191
	IconArrowDown    = "↓" // U+2193
	IconChevronRight = "›" // U+203A
	IconChevronLeft  = "‹" // U+2039

	// Language Icons
	IconPython     = "◎" // U+25CE
	IconJavaScript = "⬡" // U+2B21
	IconTypeScript = "⬢" // U+2B22
	IconRust       = "⚙" // U+2699
	IconGo         = "⟐" // U+27D0
	IconRuby       = "◆" // U+25C6
	IconJava       = "◇" // U+25C7
	IconLua        = "☽" // U+263D
	IconMarkdown   = "▾" // U+25BE
	IconR          = "®" // U+00AE

	// Claude Icons
	IconClaude     = "◆" // U+25C6
	IconCrosshairs = "⊕" // U+2295
	IconSmile      = "☺" // U+263A
	IconMeh        = "○" // U+25CB
	IconFrown      = "●" // U+25CF

	// Statusline Icons (safe single-width)
	IconModel   = "◆ " // U+25C6 + space
	IconSession = "▶ " // U+25B6 + space
	IconContext = "⊞ " // U+229E + space
	IconUsage   = "⏐"  // U+23D0
	IconWeekly  = "⟳"  // U+27F3
	IconTime    = "◷ " // U+25F7 + space
	IconVim     = "◈ " // U+25C8 + space
	IconLines   = "≡ " // U+2261 + space
	IconBurn    = "△ " // U+25B3 + space
	IconDepth   = "↕ " // U+2195 + space
	IconSepLeft = "│"  // U+2502
)

// GitStatusIcon returns the appropriate icon for a git status code.
var GitStatusIcons = map[string]string{
	"??": BrightYellow + IconQuestion + Reset, // Untracked
	" A": BrightGreen + IconCheck + Reset,     // Added to staging
	"A ": BrightGreen + IconCheck + Reset,     // Added to staging
	" M": BrightBlue + IconEdit + Reset,       // Modified (not staged)
	"M ": BrightCyan + IconEdit + Reset,       // Modified and staged
	"MM": BrightCyan + IconEdit + Reset,       // Modified, staged, modified
	"AM": BrightGreen + IconCheck + Reset,     // Added, then modified
	" D": BrightRed + IconTrash + Reset,       // Deleted (not staged)
	"D ": BrightRed + IconTrash + Reset,       // Deleted and staged
	"R ": BrightMagenta + IconSync + Reset,    // Renamed
	"C ": BrightBlue + IconCopy + Reset,       // Copied
	"U ": BrightRed + IconWarning + Reset,     // Unmerged
}

// GitStatusEmoji returns emoji for git status (for ntfy - no Nerd Font).
var GitStatusEmoji = map[string]string{
	"??": "🆕", // Untracked/new file
	" A": "✅", // Added to staging
	"A ": "✅", // Added to staging
	" M": "✏️", // Modified (not staged)
	"M ": "📝", // Modified and staged
	"MM": "📝", // Modified, staged, modified
	"AM": "✅", // Added, then modified
	" D": "🗑️", // Deleted (not staged)
	"D ": "🗑️", // Deleted and staged
	"R ": "🔄", // Renamed
	"C ": "📋", // Copied
	"U ": "⚠️", // Unmerged/conflict
}

// FileIcon returns the appropriate icon for a file extension.
func FileIcon(filename string) string {
	ext := filepath.Ext(filename)
	if ext == "" {
		return IconFile
	}

	switch ext {
	case ".py", ".pyi":
		return IconPython
	case ".js", ".jsx":
		return IconJavaScript
	case ".ts", ".tsx":
		return IconTypeScript
	case ".rs":
		return IconRust
	case ".go":
		return IconGo
	case ".rb":
		return IconRuby
	case ".java":
		return IconJava
	case ".lua":
		return IconLua
	case ".md", ".mdx":
		return IconMarkdown
	case ".r", ".R":
		return IconR
	case ".json", ".yaml", ".yml", ".toml":
		return IconFileCode
	case ".txt":
		return IconFileText
	case ".sh", ".bash", ".zsh":
		return IconTerminal
	default:
		return IconFile
	}
}

// GitStatusIcon returns the icon for a git status code.
func GitStatusIcon(code string) string {
	if icon, ok := GitStatusIcons[code]; ok {
		return icon
	}
	return Dim + IconFile + Reset
}

// GetGitStatusEmoji returns the emoji for a git status code.
func GetGitStatusEmoji(code string) string {
	if emoji, ok := GitStatusEmoji[code]; ok {
		return emoji
	}
	return "📄"
}
