#!/usr/bin/env python3
"""
EnvValidation hook - Validate development environment on session start.
Triggers: SessionStart hook.

Features:
1. Check required tools (git, node, python, etc.)
2. Validate project-specific requirements
3. Report missing or outdated dependencies
4. Suggest fixes for common issues
"""

import json
import os
import shutil
import subprocess
import sys
from datetime import datetime

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")

# Required tools with version check commands
REQUIRED_TOOLS = {
    "git": {"cmd": ["git", "--version"], "min_version": "2.0"},
    "node": {"cmd": ["node", "--version"], "min_version": "18.0", "optional": True},
    "python": {"cmd": ["python3", "--version"], "min_version": "3.10"},
    "uv": {"cmd": ["uv", "--version"], "min_version": "0.1", "optional": True},
    "pnpm": {"cmd": ["pnpm", "--version"], "min_version": "8.0", "optional": True},
    "ruff": {"cmd": ["ruff", "--version"], "min_version": "0.1", "optional": True},
    "rip": {"cmd": ["rip", "--version"], "min_version": None, "optional": True},
    "scip-typescript": {
        "cmd": ["scip-typescript", "--version"],
        "min_version": None,
        "optional": True,
        "install_hint": "npm install -g @sourcegraph/scip-typescript",
    },
}

# Processor tools - optional linters/formatters used by hooks/processors/
PROCESSOR_TOOLS = {
    "eslint": {
        "cmd": ["eslint", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["pnpm", "install", "-g", "eslint"],
        "install_hint": "pnpm install -g eslint",
    },
    "prettier": {
        "cmd": ["prettier", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["pnpm", "install", "-g", "prettier"],
        "install_hint": "pnpm install -g prettier",
    },
    "biome": {
        "cmd": ["biome", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["pnpm", "install", "-g", "@biomejs/biome"],
        "install_hint": "pnpm install -g @biomejs/biome",
    },
    "vale": {
        "cmd": ["vale", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["brew", "install", "vale"],
        "install_hint": "brew install vale",
    },
    "write-good": {
        "cmd": ["write-good", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["pnpm", "install", "-g", "write-good"],
        "install_hint": "pnpm install -g write-good",
    },
    "bibtex-tidy": {
        "cmd": ["bibtex-tidy", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["pnpm", "install", "-g", "bibtex-tidy"],
        "install_hint": "pnpm install -g bibtex-tidy",
    },
    "shellcheck": {
        "cmd": ["shellcheck", "--version"],
        "min_version": None,
        "optional": True,
        "install_cmd": ["brew", "install", "shellcheck"],
        "install_hint": "brew install shellcheck",
    },
}

# Project-specific requirements based on files present
PROJECT_REQUIREMENTS = {
    "package.json": ["node", "pnpm"],
    "pyproject.toml": ["python", "uv"],
    "requirements.txt": ["python"],
    "Cargo.toml": ["cargo"],
    "go.mod": ["go"],
    "Gemfile": ["ruby"],
}


def install_tool_async(name: str, config: dict) -> None:
    """Install a tool asynchronously in the background."""
    install_cmd = config.get("install_cmd")
    if not install_cmd:
        return

    # Check if the installer (pnpm, brew) is available
    installer = install_cmd[0]
    if not shutil.which(installer):
        return

    try:
        # Fork a background process to install
        pid = os.fork()
        if pid == 0:
            # Child process - detach and install
            os.setsid()  # Create new session
            # Redirect stdout/stderr to log file
            log_file = os.path.join(LOG_DIR, "install.log")
            with open(log_file, "a") as f:
                f.write(f"\n[{datetime.now().isoformat()}] Installing {name}...\n")
                try:
                    result = subprocess.run(
                        install_cmd,
                        capture_output=True,
                        text=True,
                        timeout=300,  # 5 min timeout
                    )
                    f.write(f"  Command: {' '.join(install_cmd)}\n")
                    f.write(f"  Exit code: {result.returncode}\n")
                    if result.stdout:
                        f.write(f"  stdout: {result.stdout[:500]}\n")
                    if result.stderr:
                        f.write(f"  stderr: {result.stderr[:500]}\n")
                    if result.returncode == 0:
                        f.write(f"  ✅ {name} installed successfully\n")
                    else:
                        f.write(f"  ❌ {name} installation failed\n")
                except Exception as e:
                    f.write(f"  ❌ Error installing {name}: {e}\n")
            os._exit(0)
        # Parent process continues immediately
    except (OSError, AttributeError):
        # os.fork() not available (Windows) - skip async install
        pass


def parse_version(version_str: str) -> tuple:
    """Parse version string into comparable tuple."""
    try:
        # Extract version numbers (e.g., "v18.17.0" -> (18, 17, 0))
        import re

        match = re.search(r"(\d+)\.(\d+)(?:\.(\d+))?", version_str)
        if match:
            groups = match.groups()
            return tuple(int(g) if g else 0 for g in groups)
    except Exception:
        pass
    return (0, 0, 0)


def check_tool(name: str, config: dict) -> dict:
    """Check if a tool is available and meets version requirements."""
    result = {
        "name": name,
        "available": False,
        "version": None,
        "meets_requirement": False,
        "optional": config.get("optional", False),
        "error": None,
        "install_hint": config.get("install_hint"),
    }

    # Check if tool exists
    if not shutil.which(config["cmd"][0]):
        result["error"] = f"{name} not found in PATH"
        return result

    # Get version
    try:
        proc = subprocess.run(
            config["cmd"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        version_output = proc.stdout.strip() or proc.stderr.strip()
        result["version"] = version_output
        result["available"] = True

        # Check minimum version
        min_version = config.get("min_version")
        if min_version:
            current = parse_version(version_output)
            required = parse_version(min_version)
            result["meets_requirement"] = current >= required
        else:
            result["meets_requirement"] = True

    except subprocess.TimeoutExpired:
        result["error"] = f"{name} timed out"
    except Exception as e:
        result["error"] = str(e)

    return result


def check_project_requirements(cwd: str) -> list:
    """Check project-specific requirements based on config files."""
    missing = []

    for config_file, tools in PROJECT_REQUIREMENTS.items():
        config_path = os.path.join(cwd, config_file)
        if os.path.exists(config_path):
            for tool in tools:
                if not shutil.which(tool):
                    missing.append(
                        {
                            "tool": tool,
                            "reason": f"Required by {config_file}",
                        }
                    )

    return missing


def format_validation_report(tool_results: list, project_missing: list) -> str:
    """Format validation results as a report."""
    lines = []
    issues = []

    # Check core tools
    for result in tool_results:
        if not result["available"]:
            if not result["optional"]:
                msg = f"❌ {result['name']}: {result['error']}"
                if result.get("install_hint"):
                    msg += f"\n   → {result['install_hint']}"
                issues.append(msg)
        elif not result["meets_requirement"]:
            issues.append(f"⚠️ {result['name']}: version outdated ({result['version']})")

    # Check project requirements
    for missing in project_missing:
        issues.append(f"📦 {missing['tool']}: {missing['reason']}")

    if issues:
        lines.append("🔧 環境檢查發現問題:")
        lines.extend(issues[:5])  # Limit to 5 issues
        if len(issues) > 5:
            lines.append(f"   ...還有 {len(issues) - 5} 個問題")
    else:
        lines.append("✅ 開發環境檢查通過")

    return "\n".join(lines)


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        source = data.get("source", "startup")

        # Only run full validation on startup, not resume/compact
        if source not in ("startup", "clear"):
            return

        # Check required tools
        tool_results = []
        for name, config in REQUIRED_TOOLS.items():
            result = check_tool(name, config)
            tool_results.append(result)

        # Check processor tools and install missing ones async
        processor_results = []
        tools_to_install = []
        for name, config in PROCESSOR_TOOLS.items():
            result = check_tool(name, config)
            processor_results.append(result)
            # Track missing tools that have install commands
            if not result["available"] and config.get("install_cmd"):
                tools_to_install.append((name, config))

        # Check project requirements
        project_missing = []
        if cwd:
            project_missing = check_project_requirements(cwd)

        # Log validation results
        os.makedirs(LOG_DIR, exist_ok=True)
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "cwd": cwd,
            "source": source,
            "tools": tool_results,
            "processor_tools": processor_results,
            "project_missing": project_missing,
            "installing": [t[0] for t in tools_to_install],
        }
        with open(os.path.join(LOG_DIR, "env_validation.jsonl"), "a") as f:
            f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")

        # Install missing processor tools asynchronously in background
        for name, config in tools_to_install:
            install_tool_async(name, config)

        # Generate report (only for required tools, not optional processors)
        report = format_validation_report(tool_results, project_missing)

        # Add installing info if any
        if tools_to_install:
            installing_names = [t[0] for t in tools_to_install]
            report += f"\n🔄 背景安裝中: {', '.join(installing_names)}"

        # Only output if there are issues or installing
        has_issues = (
            any(
                (not r["available"] and not r["optional"]) or not r["meets_requirement"]
                for r in tool_results
            )
            or project_missing
        )

        if has_issues or tools_to_install:
            response = {
                "continue": True,
                "systemMessage": report,
            }
            print(json.dumps(response))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
