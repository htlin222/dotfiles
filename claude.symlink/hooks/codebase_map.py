#!/usr/bin/env python3
"""
CodebaseMap hook - Inject invisible project context on first prompt.
Triggers: UserPromptSubmit (first prompt of session).

Features:
1. Generate project structure map
2. Identify key files (README, package.json, etc.)
3. Detect tech stack and frameworks
4. Inject context invisibly into Claude's awareness
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
CONTEXT_CACHE_FILE = os.path.join(LOG_DIR, "codebase_context.json")
CACHE_TTL_HOURS = 2  # Refresh cache every 2 hours

# Files to always read for context
KEY_FILES = [
    "README.md",
    "package.json",
    "pyproject.toml",
    "Cargo.toml",
    "go.mod",
    "composer.json",
    "Gemfile",
    "requirements.txt",
    "tsconfig.json",
    "CLAUDE.md",
    ".claude/CLAUDE.md",
]

# Directories to summarize
IMPORTANT_DIRS = ["src", "lib", "app", "components", "pages", "api", "hooks", "utils"]


def get_project_structure(cwd: str, max_depth: int = 3) -> str:
    """Generate project structure using tree or find."""
    try:
        # Try tree first
        result = subprocess.run(
            [
                "tree",
                "-L",
                str(max_depth),
                "-I",
                "node_modules|.git|__pycache__|.venv|venv|dist|build",
            ],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            return result.stdout[:3000]
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass

    # Fallback to find
    try:
        result = subprocess.run(
            [
                "find",
                ".",
                "-type",
                "f",
                "-maxdepth",
                str(max_depth),
                "-not",
                "-path",
                "*/node_modules/*",
                "-not",
                "-path",
                "*/.git/*",
                "-not",
                "-path",
                "*/__pycache__/*",
            ],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            files = result.stdout.strip().split("\n")[:100]
            return "\n".join(files)
    except Exception:
        pass

    return ""


def detect_tech_stack(cwd: str) -> dict:
    """Detect technology stack from config files."""
    stack = {
        "languages": [],
        "frameworks": [],
        "package_manager": None,
        "test_framework": None,
    }

    cwd_path = Path(cwd)

    # Detect by config files
    if (cwd_path / "package.json").exists():
        try:
            with open(cwd_path / "package.json", "r") as f:
                pkg = json.load(f)

            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}

            if "typescript" in deps:
                stack["languages"].append("TypeScript")
            else:
                stack["languages"].append("JavaScript")

            # Frameworks
            if "react" in deps:
                stack["frameworks"].append("React")
            if "next" in deps:
                stack["frameworks"].append("Next.js")
            if "vue" in deps:
                stack["frameworks"].append("Vue")
            if "express" in deps:
                stack["frameworks"].append("Express")
            if "fastify" in deps:
                stack["frameworks"].append("Fastify")

            # Test frameworks
            if "jest" in deps:
                stack["test_framework"] = "Jest"
            elif "vitest" in deps:
                stack["test_framework"] = "Vitest"
            elif "mocha" in deps:
                stack["test_framework"] = "Mocha"

            # Package manager
            if (cwd_path / "pnpm-lock.yaml").exists():
                stack["package_manager"] = "pnpm"
            elif (cwd_path / "yarn.lock").exists():
                stack["package_manager"] = "yarn"
            elif (cwd_path / "package-lock.json").exists():
                stack["package_manager"] = "npm"

        except Exception:
            pass

    if (cwd_path / "pyproject.toml").exists():
        stack["languages"].append("Python")
        stack["package_manager"] = "uv/pip"

        try:
            content = (cwd_path / "pyproject.toml").read_text()
            if "pytest" in content:
                stack["test_framework"] = "pytest"
            if "django" in content.lower():
                stack["frameworks"].append("Django")
            if "fastapi" in content.lower():
                stack["frameworks"].append("FastAPI")
            if "flask" in content.lower():
                stack["frameworks"].append("Flask")
        except Exception:
            pass

    if (cwd_path / "requirements.txt").exists():
        stack["languages"].append("Python")

    if (cwd_path / "Cargo.toml").exists():
        stack["languages"].append("Rust")

    if (cwd_path / "go.mod").exists():
        stack["languages"].append("Go")

    # Deduplicate
    stack["languages"] = list(set(stack["languages"]))
    stack["frameworks"] = list(set(stack["frameworks"]))

    return stack


def read_key_file_snippets(cwd: str) -> dict:
    """Read snippets from key files."""
    snippets = {}
    cwd_path = Path(cwd)

    for key_file in KEY_FILES:
        file_path = cwd_path / key_file
        if file_path.exists():
            try:
                content = file_path.read_text(encoding="utf-8", errors="ignore")
                # Limit to first 1000 chars for context
                snippets[key_file] = content[:1000]
            except Exception:
                pass

    return snippets


def get_git_info(cwd: str) -> dict:
    """Get git repository information."""
    info = {}

    try:
        # Current branch
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            info["branch"] = result.stdout.strip()

        # Recent commits
        result = subprocess.run(
            ["git", "log", "--oneline", "-5"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            info["recent_commits"] = result.stdout.strip()

    except Exception:
        pass

    return info


def generate_codebase_context(cwd: str) -> dict:
    """Generate comprehensive codebase context."""
    context = {
        "generated_at": datetime.now().isoformat(),
        "project_name": os.path.basename(cwd),
        "structure": get_project_structure(cwd),
        "tech_stack": detect_tech_stack(cwd),
        "key_files": read_key_file_snippets(cwd),
        "git": get_git_info(cwd),
    }

    return context


def load_cached_context(cwd: str) -> dict | None:
    """Load cached context if fresh enough."""
    if not os.path.exists(CONTEXT_CACHE_FILE):
        return None

    try:
        with open(CONTEXT_CACHE_FILE, "r") as f:
            cached = json.load(f)

        # Check if same project and fresh
        if cached.get("project_name") != os.path.basename(cwd):
            return None

        generated_at = datetime.fromisoformat(cached.get("generated_at", "2000-01-01"))
        age_hours = (datetime.now() - generated_at).total_seconds() / 3600

        if age_hours < CACHE_TTL_HOURS:
            return cached

    except Exception:
        pass

    return None


def save_context_cache(context: dict):
    """Save context to cache."""
    os.makedirs(LOG_DIR, exist_ok=True)
    try:
        with open(CONTEXT_CACHE_FILE, "w") as f:
            json.dump(context, f, indent=2)
    except Exception:
        pass


def format_context_message(context: dict) -> str:
    """Format context as a concise system message."""
    parts = []

    # Tech stack
    stack = context.get("tech_stack", {})
    if stack.get("languages"):
        langs = ", ".join(stack["languages"])
        parts.append(f"📦 {langs}")

    if stack.get("frameworks"):
        frameworks = ", ".join(stack["frameworks"])
        parts.append(f"🔧 {frameworks}")

    if stack.get("package_manager"):
        parts.append(f"📋 {stack['package_manager']}")

    # Git info
    git = context.get("git", {})
    if git.get("branch"):
        parts.append(f"🌿 {git['branch']}")

    return " | ".join(parts) if parts else ""


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        prompt = data.get("prompt", "")

        if not cwd:
            return

        # Check if we should inject context (first meaningful prompt)
        # Skip if prompt is very short or just a greeting
        if len(prompt.strip()) < 10:
            return

        # Load or generate context
        context = load_cached_context(cwd)
        if not context:
            context = generate_codebase_context(cwd)
            save_context_cache(context)

        # Format and inject context message
        context_message = format_context_message(context)

        if context_message:
            response = {
                "continue": True,
                "systemMessage": context_message,
            }
            print(json.dumps(response))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
