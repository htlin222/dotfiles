#!/usr/bin/env python3
"""
Shared ANSI styling module for Claude Code hooks.

Provides:
1. ANSI color codes
2. Nerd Font icons
3. Helper functions for styled output
"""


# =============================================================================
# ANSI Color Codes
# =============================================================================


class Colors:
    """ANSI color codes for terminal styling."""

    # Reset
    RESET = "\033[0m"

    # Styles
    BOLD = "\033[1m"
    DIM = "\033[2m"
    ITALIC = "\033[3m"
    UNDERLINE = "\033[4m"
    BLINK = "\033[5m"
    REVERSE = "\033[7m"
    STRIKETHROUGH = "\033[9m"

    # Regular Colors
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"

    # Bright Colors
    BRIGHT_BLACK = "\033[90m"
    BRIGHT_RED = "\033[91m"
    BRIGHT_GREEN = "\033[92m"
    BRIGHT_YELLOW = "\033[93m"
    BRIGHT_BLUE = "\033[94m"
    BRIGHT_MAGENTA = "\033[95m"
    BRIGHT_CYAN = "\033[96m"
    BRIGHT_WHITE = "\033[97m"

    # Background Colors
    BG_BLACK = "\033[40m"
    BG_RED = "\033[41m"
    BG_GREEN = "\033[42m"
    BG_YELLOW = "\033[43m"
    BG_BLUE = "\033[44m"
    BG_MAGENTA = "\033[45m"
    BG_CYAN = "\033[46m"
    BG_WHITE = "\033[47m"

    # 256 Color support
    @staticmethod
    def fg(code: int) -> str:
        """Foreground color from 256-color palette."""
        return f"\033[38;5;{code}m"

    @staticmethod
    def bg(code: int) -> str:
        """Background color from 256-color palette."""
        return f"\033[48;5;{code}m"

    # RGB Color support
    @staticmethod
    def rgb(r: int, g: int, b: int) -> str:
        """Foreground color from RGB values."""
        return f"\033[38;2;{r};{g};{b}m"

    @staticmethod
    def bg_rgb(r: int, g: int, b: int) -> str:
        """Background color from RGB values."""
        return f"\033[48;2;{r};{g};{b}m"


# Shorthand alias
C = Colors


# =============================================================================
# Nerd Font Icons
# =============================================================================


class Icons:
    """Nerd Font icons for visual styling."""

    # Status Icons
    CHECK = "\uf00c"  #
    CROSS = "\uf00d"  #
    WARNING = "\uf071"  #
    INFO = "\uf05a"  #
    QUESTION = "\uf128"  #
    EXCLAIM = "\uf12a"  #
    PLUS = "\uf067"  #
    MINUS = "\uf068"  #

    # File & Folder Icons
    FILE = "\uf15b"  #
    FILE_CODE = "\uf1c9"  #
    FILE_TEXT = "\uf15c"  #
    FOLDER = "\uf07b"  #
    FOLDER_OPEN = "\uf07c"  #
    SAVE = "\uf0c7"  #

    # Code & Dev Icons
    CODE = "\uf121"  #
    TERMINAL = "\uf120"  #
    BUG = "\uf188"  #
    GEAR = "\uf013"  #
    WRENCH = "\uf0ad"  #
    MAGIC = "\uf0d0"  #
    ROCKET = "\uf135"  #

    # Git Icons
    GIT = "\uf1d3"  #
    GITHUB = "\uf09b"  #
    BRANCH = "\ue725"  #
    COMMIT = "\uf417"  #
    MERGE = "\uf419"  #

    # Status & Progress Icons
    PLAY = "\uf04b"  #
    PAUSE = "\uf04c"  #
    STOP = "\uf04d"  #
    SPINNER = "\uf110"  #
    CLOCK = "\uf017"  #
    HOURGLASS = "\uf252"  #

    # Security Icons
    LOCK = "\uf023"  #
    UNLOCK = "\uf09c"  #
    SHIELD = "\uf132"  #
    KEY = "\uf084"  #

    # Misc Icons
    LIGHTNING = "\uf0e7"  #
    STAR = "\uf005"  #
    HEART = "\uf004"  #
    FIRE = "\uf06d"  #
    DATABASE = "\uf1c0"  #
    CLOUD = "\uf0c2"  #
    DOWNLOAD = "\uf019"  #
    UPLOAD = "\uf093"  #
    SYNC = "\uf021"  #
    SEARCH = "\uf002"  #
    EYE = "\uf06e"  #
    COMMENT = "\uf075"  #
    BELL = "\uf0f3"  #
    FLAG = "\uf024"  #
    TAG = "\uf02b"  #
    BOOKMARK = "\uf02e"  #
    TRASH = "\uf1f8"  #
    EDIT = "\uf044"  #
    COPY = "\uf0c5"  #
    PASTE = "\uf0ea"  #
    LINK = "\uf0c1"  #
    UNLINK = "\uf127"  #

    # Arrow Icons
    ARROW_RIGHT = "\uf061"  #
    ARROW_LEFT = "\uf060"  #
    ARROW_UP = "\uf062"  #
    ARROW_DOWN = "\uf063"  #
    CHEVRON_RIGHT = "\uf054"  #
    CHEVRON_LEFT = "\uf053"  #

    # Language Icons
    PYTHON = "\ue73c"  #
    JAVASCRIPT = "\ue74e"  #
    TYPESCRIPT = "\ue628"  #
    RUST = "\ue7a8"  #
    GO = "\ue626"  #
    RUBY = "\ue791"  #
    JAVA = "\ue738"  #

    # Custom Claude Icons
    CLAUDE = "\ue20f"  #
    CROSSHAIRS = "\uf05d"  #
    SMILE = "\uf118"  #
    MEH = "\uf11a"  #
    FROWN = "\uf119"  #


# =============================================================================
# Styled Output Helpers
# =============================================================================


def style(text: str, *styles: str) -> str:
    """Apply multiple styles to text."""
    prefix = "".join(styles)
    return f"{prefix}{text}{C.RESET}"


def success(text: str) -> str:
    """Format success message."""
    return f"{C.BRIGHT_GREEN}{Icons.CHECK} {text}{C.RESET}"


def error(text: str) -> str:
    """Format error message."""
    return f"{C.BRIGHT_RED}{Icons.CROSS} {text}{C.RESET}"


def warning(text: str) -> str:
    """Format warning message."""
    return f"{C.BRIGHT_YELLOW}{Icons.WARNING} {text}{C.RESET}"


def info(text: str) -> str:
    """Format info message."""
    return f"{C.BRIGHT_CYAN}{Icons.INFO} {text}{C.RESET}"


def dim(text: str) -> str:
    """Format dimmed text."""
    return f"{C.DIM}{text}{C.RESET}"


def bold(text: str) -> str:
    """Format bold text."""
    return f"{C.BOLD}{text}{C.RESET}"


def code(text: str) -> str:
    """Format code/command text."""
    return f"{C.BRIGHT_MAGENTA}{Icons.CODE} {text}{C.RESET}"


def file_icon(filename: str) -> str:
    """Get appropriate icon for file type."""
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""

    icon_map = {
        "py": Icons.PYTHON,
        "pyi": Icons.PYTHON,
        "js": Icons.JAVASCRIPT,
        "jsx": Icons.JAVASCRIPT,
        "ts": Icons.TYPESCRIPT,
        "tsx": Icons.TYPESCRIPT,
        "rs": Icons.RUST,
        "go": Icons.GO,
        "rb": Icons.RUBY,
        "java": Icons.JAVA,
        "json": Icons.FILE_CODE,
        "yaml": Icons.FILE_CODE,
        "yml": Icons.FILE_CODE,
        "md": Icons.FILE_TEXT,
        "txt": Icons.FILE_TEXT,
        "sh": Icons.TERMINAL,
        "bash": Icons.TERMINAL,
        "zsh": Icons.TERMINAL,
    }

    return icon_map.get(ext, Icons.FILE)


def file_styled(filepath: str) -> str:
    """Format file path with icon."""
    import os

    filename = os.path.basename(filepath)
    icon = file_icon(filename)
    return f"{C.BRIGHT_BLUE}{icon} {filename}{C.RESET}"


def progress_bar(current: int, total: int, width: int = 20) -> str:
    """Create a progress bar."""
    if total == 0:
        return ""

    filled = int(width * current / total)
    empty = width - filled

    bar = f"{C.BRIGHT_GREEN}{'█' * filled}{C.DIM}{'░' * empty}{C.RESET}"
    percent = f"{C.BRIGHT_WHITE}{current}/{total}{C.RESET}"

    return f"[{bar}] {percent}"


def status_icon(status: str) -> str:
    """Get status icon with color."""
    status_map = {
        "success": f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}",
        "ok": f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}",
        "pass": f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}",
        "error": f"{C.BRIGHT_RED}{Icons.CROSS}{C.RESET}",
        "fail": f"{C.BRIGHT_RED}{Icons.CROSS}{C.RESET}",
        "warning": f"{C.BRIGHT_YELLOW}{Icons.WARNING}{C.RESET}",
        "warn": f"{C.BRIGHT_YELLOW}{Icons.WARNING}{C.RESET}",
        "info": f"{C.BRIGHT_CYAN}{Icons.INFO}{C.RESET}",
        "pending": f"{C.BRIGHT_YELLOW}{Icons.HOURGLASS}{C.RESET}",
        "running": f"{C.BRIGHT_BLUE}{Icons.SPINNER}{C.RESET}",
        "blocked": f"{C.BRIGHT_RED}{Icons.LOCK}{C.RESET}",
    }

    return status_map.get(status.lower(), f"{C.DIM}{Icons.QUESTION}{C.RESET}")


def header(text: str, icon: str = Icons.CLAUDE) -> str:
    """Format a section header."""
    return f"{C.BOLD}{C.BRIGHT_CYAN}{icon} {text}{C.RESET}"


def subheader(text: str) -> str:
    """Format a subheader."""
    return f"{C.BOLD}{C.WHITE}{Icons.CHEVRON_RIGHT} {text}{C.RESET}"


def bullet(text: str, level: int = 0) -> str:
    """Format a bullet point."""
    indent = "  " * level
    return f"{indent}{C.DIM}•{C.RESET} {text}"


def numbered(index: int, text: str) -> str:
    """Format a numbered item."""
    return f"{C.BRIGHT_CYAN}{index}.{C.RESET} {text}"


def key_value(key: str, value: str, separator: str = ":") -> str:
    """Format a key-value pair."""
    return f"{C.DIM}{key}{separator}{C.RESET} {C.WHITE}{value}{C.RESET}"


def table_row(cells: list[str], widths: list[int] | None = None) -> str:
    """Format a table row."""
    if widths:
        formatted = [cell.ljust(w) for cell, w in zip(cells, widths)]
    else:
        formatted = cells
    return " │ ".join(formatted)


def separator(char: str = "─", length: int = 40) -> str:
    """Create a separator line."""
    return f"{C.DIM}{char * length}{C.RESET}"


# =============================================================================
# Git Status Icons (for stop.py)
# =============================================================================

GIT_STATUS_ICONS = {
    "??": f"{C.BRIGHT_YELLOW}{Icons.QUESTION}{C.RESET}",  # Untracked
    " A": f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}",  # Added to staging
    "A ": f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}",  # Added to staging
    " M": f"{C.BRIGHT_BLUE}{Icons.EDIT}{C.RESET}",  # Modified (not staged)
    "M ": f"{C.BRIGHT_CYAN}{Icons.EDIT}{C.RESET}",  # Modified and staged
    "MM": f"{C.BRIGHT_CYAN}{Icons.EDIT}{C.RESET}",  # Modified, staged, modified
    "AM": f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET}",  # Added, then modified
    " D": f"{C.BRIGHT_RED}{Icons.TRASH}{C.RESET}",  # Deleted (not staged)
    "D ": f"{C.BRIGHT_RED}{Icons.TRASH}{C.RESET}",  # Deleted and staged
    "R ": f"{C.BRIGHT_MAGENTA}{Icons.SYNC}{C.RESET}",  # Renamed
    "C ": f"{C.BRIGHT_BLUE}{Icons.COPY}{C.RESET}",  # Copied
    "U ": f"{C.BRIGHT_RED}{Icons.WARNING}{C.RESET}",  # Unmerged
}


def git_status_icon(git_code: str) -> str:
    """Get git status icon with color."""
    return GIT_STATUS_ICONS.get(git_code, f"{C.DIM}{Icons.FILE}{C.RESET}")


# =============================================================================
# Severity Styling
# =============================================================================


def severity_style(severity: str, text: str) -> str:
    """Apply styling based on severity level."""
    severity_styles = {
        "critical": f"{C.BOLD}{C.BRIGHT_RED}{Icons.FIRE} {text}{C.RESET}",
        "high": f"{C.BRIGHT_RED}{Icons.EXCLAIM} {text}{C.RESET}",
        "medium": f"{C.BRIGHT_YELLOW}{Icons.WARNING} {text}{C.RESET}",
        "low": f"{C.BRIGHT_CYAN}{Icons.INFO} {text}{C.RESET}",
        "info": f"{C.DIM}{Icons.INFO} {text}{C.RESET}",
    }
    return severity_styles.get(severity.lower(), text)


# =============================================================================
# Demo / Test
# =============================================================================


def demo():
    """Display demo of all styling options."""
    print(header("ANSI Styling Demo"))
    print(separator())

    print(subheader("Status Messages"))
    print(success("Operation completed successfully"))
    print(error("Something went wrong"))
    print(warning("Proceed with caution"))
    print(info("Here's some information"))
    print()

    print(subheader("Severity Levels"))
    print(severity_style("critical", "Critical issue detected"))
    print(severity_style("high", "High priority warning"))
    print(severity_style("medium", "Medium concern"))
    print(severity_style("low", "Low priority note"))
    print()

    print(subheader("File Icons"))
    files = ["main.py", "index.ts", "app.js", "Cargo.toml", "README.md"]
    for f in files:
        print(f"  {file_styled(f)}")
    print()

    print(subheader("Progress Bar"))
    print(f"  {progress_bar(7, 10)}")
    print(f"  {progress_bar(3, 10)}")
    print()

    print(subheader("Key-Value"))
    print(f"  {key_value('Status', 'Active')}")
    print(f"  {key_value('Files', '42')}")
    print()

    print(subheader("Status Icons"))
    for status in ["success", "error", "warning", "info", "pending", "running"]:
        print(f"  {status_icon(status)} {status}")


if __name__ == "__main__":
    demo()
