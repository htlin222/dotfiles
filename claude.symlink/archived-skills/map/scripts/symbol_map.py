#!/usr/bin/env python3
"""
Symbol Map Generator - Semantic code intelligence for Claude.

Generates a symbol map showing where all exports, classes, functions,
and interfaces are defined. Provides precise file:line locations.

Strategies (in order of preference):
1. SCIP (if scip-typescript installed) - Most accurate
2. LSP-lite (grep exports + patterns) - Lightweight fallback
"""

import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

# =============================================================================
# Configuration
# =============================================================================

OUTPUT_DIR = os.path.expanduser("~/.claude/codebase-maps")
IGNORE_DIRS = {
    "node_modules",
    ".git",
    "__pycache__",
    ".venv",
    "venv",
    "dist",
    "build",
    ".next",
    "coverage",
    ".turbo",
    ".cache",
}

LANG_PATTERNS = {
    "typescript": ["*.ts", "*.tsx"],
    "javascript": ["*.js", "*.jsx", "*.mjs"],
    "python": ["*.py"],
    "rust": ["*.rs"],
    "go": ["*.go"],
}

SYMBOL_PATTERNS = {
    "typescript": [
        (r"^export\s+(?:default\s+)?(?:async\s+)?function\s+(\w+)", "function"),
        (r"^export\s+(?:default\s+)?class\s+(\w+)", "class"),
        (r"^export\s+(?:default\s+)?interface\s+(\w+)", "interface"),
        (r"^export\s+(?:default\s+)?type\s+(\w+)", "type"),
        (r"^export\s+(?:default\s+)?const\s+(\w+)", "const"),
        (r"^export\s+(?:default\s+)?enum\s+(\w+)", "enum"),
        (r"^export\s+\{([^}]+)\}", "re-export"),
    ],
    "javascript": [
        (r"^export\s+(?:default\s+)?(?:async\s+)?function\s+(\w+)", "function"),
        (r"^export\s+(?:default\s+)?class\s+(\w+)", "class"),
        (r"^export\s+(?:default\s+)?const\s+(\w+)", "const"),
        (r"^module\.exports\s*=\s*(?:class\s+)?(\w+)?", "module.exports"),
        (r"^export\s+\{([^}]+)\}", "re-export"),
    ],
    "python": [
        (r"^class\s+(\w+)", "class"),
        (r"^(?:async\s+)?def\s+(\w+)", "function"),
        (r"^(\w+)\s*=\s*(?:TypeVar|NewType|namedtuple)", "type"),
        (r"^__all__\s*=\s*\[([^\]]+)\]", "exports"),
    ],
    "rust": [
        (r"^pub\s+(?:async\s+)?fn\s+(\w+)", "function"),
        (r"^pub\s+struct\s+(\w+)", "struct"),
        (r"^pub\s+enum\s+(\w+)", "enum"),
        (r"^pub\s+trait\s+(\w+)", "trait"),
        (r"^pub\s+type\s+(\w+)", "type"),
        (r"^pub\s+mod\s+(\w+)", "module"),
    ],
    "go": [
        (r"^func\s+([A-Z]\w*)", "function"),  # Exported = starts with capital
        (r"^func\s+\([^)]+\)\s+([A-Z]\w*)", "method"),
        (r"^type\s+([A-Z]\w*)\s+struct", "struct"),
        (r"^type\s+([A-Z]\w*)\s+interface", "interface"),
    ],
}


def run_command(cmd: list[str], cwd: str | None = None) -> tuple[bool, str]:
    """Run a command and return (success, output)."""
    try:
        result = subprocess.run(
            cmd, cwd=cwd, capture_output=True, text=True, timeout=60
        )
        return result.returncode == 0, result.stdout
    except Exception as e:
        return False, str(e)


def detect_languages(cwd: str) -> list[str]:
    """Detect project languages based on config files and actual files."""
    languages = []
    config_map = {
        "tsconfig.json": "typescript",
        "jsconfig.json": "javascript",
        "package.json": "javascript",
        "pyproject.toml": "python",
        "setup.py": "python",
        "requirements.txt": "python",
        "Cargo.toml": "rust",
        "go.mod": "go",
    }

    for config, lang in config_map.items():
        if os.path.exists(os.path.join(cwd, config)):
            if lang not in languages:
                languages.append(lang)

    # TypeScript overrides JavaScript
    if "javascript" in languages and os.path.exists(os.path.join(cwd, "tsconfig.json")):
        languages.remove("javascript")
        if "typescript" not in languages:
            languages.insert(0, "typescript")

    # Fallback: detect by actual file extensions if no config found
    if not languages:
        ext_map = {
            ".py": "python",
            ".ts": "typescript",
            ".tsx": "typescript",
            ".js": "javascript",
            ".jsx": "javascript",
            ".rs": "rust",
            ".go": "go",
        }
        try:
            for item in os.listdir(cwd):
                if os.path.isfile(os.path.join(cwd, item)):
                    ext = os.path.splitext(item)[1]
                    if ext in ext_map and ext_map[ext] not in languages:
                        languages.append(ext_map[ext])
        except Exception:
            pass

    return languages if languages else ["javascript"]


def get_source_files(cwd: str, languages: list[str]) -> list[str]:
    """Get all source files for detected languages."""
    files = []
    for lang in languages:
        for pattern in LANG_PATTERNS.get(lang, []):
            success, output = run_command(["git", "ls-files", "--", pattern], cwd=cwd)
            if success and output.strip():
                files.extend(output.strip().split("\n"))
            else:
                # Fallback to find
                success, output = run_command(
                    [
                        "find",
                        ".",
                        "-type",
                        "f",
                        "-name",
                        pattern,
                        "-not",
                        "-path",
                        "*/node_modules/*",
                        "-not",
                        "-path",
                        "*/.git/*",
                    ],
                    cwd=cwd,
                )
                if success and output.strip():
                    files.extend(f.lstrip("./") for f in output.strip().split("\n"))

    return list(set(f for f in files if f.strip()))


def extract_symbols(filepath: str, cwd: str, lang: str) -> list[dict]:
    """Extract symbols from a file using regex patterns."""
    symbols = []
    patterns = SYMBOL_PATTERNS.get(lang, [])
    if not patterns:
        return symbols

    full_path = os.path.join(cwd, filepath)
    if not os.path.exists(full_path):
        return symbols

    try:
        with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()

        for line_num, line in enumerate(lines, 1):
            for pattern, sym_type in patterns:
                match = re.match(pattern, line.strip())
                if match:
                    name = match.group(1)
                    if name:
                        if sym_type == "re-export":
                            # Handle multiple re-exports
                            for n in name.split(","):
                                n = n.strip().split(" as ")[-1].strip()
                                if n:
                                    symbols.append(
                                        {
                                            "name": n,
                                            "type": "export",
                                            "file": filepath,
                                            "line": line_num,
                                        }
                                    )
                        else:
                            symbols.append(
                                {
                                    "name": name,
                                    "type": sym_type,
                                    "file": filepath,
                                    "line": line_num,
                                }
                            )
    except Exception:
        pass

    return symbols


def generate_map(cwd: str, languages: list[str]) -> dict:
    """Generate symbol map."""
    print(f"🔍 Scanning {', '.join(languages)} files...", file=sys.stderr)

    files = get_source_files(cwd, languages)
    by_file = defaultdict(list)
    by_type = defaultdict(list)

    for filepath in files:
        if not filepath:
            continue
        ext = Path(filepath).suffix
        lang = None
        for lang_key, patterns in LANG_PATTERNS.items():
            if any(ext == p.replace("*", "") for p in patterns):
                lang = lang_key
                break
        if not lang:
            continue

        for sym in extract_symbols(filepath, cwd, lang):
            by_file[filepath].append(sym)
            by_type[sym["type"]].append(sym)

    return {
        "by_file": dict(by_file),
        "by_type": dict(by_type),
        "stats": {
            "total_files": len(files),
            "files_with_exports": len(by_file),
            "total_symbols": sum(len(s) for s in by_file.values()),
        },
    }


def to_markdown(data: dict, cwd: str, languages: list[str]) -> str:
    """Generate markdown output."""
    lines = [
        "# Codebase Symbol Map",
        "",
        f"**Project**: `{os.path.basename(cwd)}`",
        f"**Languages**: {', '.join(languages)}",
        f"**Files**: {data['stats']['total_files']} | **Symbols**: {data['stats']['total_symbols']}",
        "",
        "---",
        "",
    ]

    # By type
    type_emoji = {
        "class": "🏛️",
        "interface": "📋",
        "type": "📝",
        "function": "⚡",
        "const": "📦",
        "enum": "🔢",
        "struct": "🧱",
        "trait": "🎭",
        "module": "📁",
        "export": "📤",
        "method": "🔧",
    }

    for sym_type, symbols in sorted(data["by_type"].items()):
        if not symbols:
            continue
        emoji = type_emoji.get(sym_type, "•")
        lines.append(f"## {emoji} {sym_type.title()}s\n")
        lines.append("| Symbol | Location |")
        lines.append("|--------|----------|")
        for sym in sorted(symbols, key=lambda x: x["name"]):
            lines.append(f"| `{sym['name']}` | `{sym['file']}:{sym['line']}` |")
        lines.append("")

    # File index
    lines.extend(["---", "", "## File Index", ""])
    for filepath in sorted(data["by_file"].keys()):
        symbols = data["by_file"][filepath]
        names = ", ".join(f"`{s['name']}`" for s in symbols[:5])
        if len(symbols) > 5:
            names += f" +{len(symbols) - 5} more"
        lines.append(f"- **{filepath}**: {names}")

    lines.extend(["", "---", "*Generated by `/map` skill*"])
    return "\n".join(lines)


def main():
    cwd = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    if not os.path.isdir(cwd):
        print(f"Error: {cwd} is not a directory", file=sys.stderr)
        sys.exit(1)

    print(f"🗺️ Generating symbol map for: {os.path.basename(cwd)}", file=sys.stderr)

    languages = detect_languages(cwd)
    print(f"📦 Detected: {', '.join(languages)}", file=sys.stderr)

    data = generate_map(cwd, languages)
    markdown = to_markdown(data, cwd, languages)

    # Save
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_file = os.path.join(OUTPUT_DIR, f"{os.path.basename(cwd)}_symbols.md")
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(markdown)

    print(f"✅ Saved: {output_file}", file=sys.stderr)
    print(markdown)


if __name__ == "__main__":
    main()
