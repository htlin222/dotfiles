package ansi

import "path/filepath"

// Nerd Font icons for visual styling
const (
	// Status Icons
	IconCheck    = "\uf00c" //
	IconCross    = "\uf00d" //
	IconWarning  = "\uf071" //
	IconInfo     = "\uf05a" //
	IconQuestion = "\uf128" //
	IconExclaim  = "\uf12a" //
	IconPlus     = "\uf067" //
	IconMinus    = "\uf068" //

	// File & Folder Icons
	IconFile       = "\uf15b" //
	IconFileCode   = "\uf1c9" //
	IconFileText   = "\uf15c" //
	IconFolder     = "\uf07b" //
	IconFolderOpen = "\uf07c" //
	IconFolderGit  = "\ue5fb" //
	IconSave       = "\uf0c7" //

	// Code & Dev Icons
	IconCode     = "\uf121" //
	IconTerminal = "\uf120" //
	IconBug      = "\uf188" //
	IconGear     = "\uf013" //
	IconWrench   = "\uf0ad" //
	IconMagic    = "\uf0d0" //
	IconRocket   = "\uf135" //

	// Git Icons
	IconGit    = "\uf1d3" //
	IconGitHub = "\uf09b" //
	IconBranch = "\ue725" //
	IconCommit = "\uf417" //
	IconMerge  = "\uf419" //

	// Status & Progress Icons
	IconPlay      = "\uf04b" //
	IconPause     = "\uf04c" //
	IconStop      = "\uf04d" //
	IconSpinner   = "\uf110" //
	IconClock     = "\uf017" //
	IconHourglass = "\uf252" //

	// Security Icons
	IconLock   = "\uf023" //
	IconUnlock = "\uf09c" //
	IconShield = "\uf132" //
	IconKey    = "\uf084" //

	// Misc Icons
	IconLightning = "\uf0e7" //
	IconStar      = "\uf005" //
	IconHeart     = "\uf004" //
	IconFire      = "\uf06d" //
	IconDatabase  = "\uf1c0" //
	IconCloud     = "\uf0c2" //
	IconDownload  = "\uf019" //
	IconUpload    = "\uf093" //
	IconSync      = "\uf021" //
	IconSearch    = "\uf002" //
	IconEye       = "\uf06e" //
	IconComment   = "\uf075" //
	IconBell      = "\uf0f3" //
	IconFlag      = "\uf024" //
	IconTag       = "\uf02b" //
	IconBookmark  = "\uf02e" //
	IconTrash     = "\uf1f8" //
	IconEdit      = "\uf044" //
	IconCopy      = "\uf0c5" //
	IconPaste     = "\uf0ea" //
	IconLink      = "\uf0c1" //
	IconUnlink    = "\uf127" //

	// Arrow Icons
	IconArrowRight   = "\uf061" //
	IconArrowLeft    = "\uf060" //
	IconArrowUp      = "\uf062" //
	IconArrowDown    = "\uf063" //
	IconChevronRight = "\uf054" //
	IconChevronLeft  = "\uf053" //

	// Language Icons
	IconPython     = "\ue73c" //
	IconJavaScript = "\ue74e" //
	IconTypeScript = "\ue628" //
	IconRust       = "\ue7a8" //
	IconGo         = "\ue626" //
	IconRuby       = "\ue791" //
	IconJava       = "\ue738" //
	IconLua        = "\ue826" //
	IconMarkdown   = "\ueb1d" //
	IconR          = "\uedc1" //

	// Claude Icons
	IconClaude     = "\ue20f" //
	IconCrosshairs = "\uf05d" //
	IconSmile      = "\uf118" //
	IconMeh        = "\uf11a" //
	IconFrown      = "\uf119" //

	// Statusline Icons (safe single-width)
	IconModel   = "\ue20f " // Claude
	IconSession = "\U000f0b77 "
	IconContext = "\ueaa4 "
	IconUsage   = "\ueded"
	IconWeekly  = "\ueebf"
	IconTime    = "\U000f0954 "
	IconVim     = "\ue7c5 "
	IconLines   = "\uf44d "
	IconBurn    = "\uf490 "
	IconDepth   = "\uf075 "
	IconSepLeft = "\ue0ba"
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
