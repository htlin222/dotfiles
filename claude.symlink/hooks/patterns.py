#!/usr/bin/env python3
"""
Prompt Pattern Detection Module

Analyzes user prompts and suggests relevant tools/workflows.
"""

import re
from typing import NamedTuple


class PatternMatch(NamedTuple):
    """A matched pattern with suggestion."""

    pattern_name: str
    confidence: float  # 0.0 - 1.0
    suggestion: str
    slash_command: str | None = None


# =============================================================================
# Pattern Definitions
# =============================================================================

PATTERNS = [
    # Code review patterns
    {
        "name": "code_review",
        "patterns": [
            r"review\s+(this|my|the)\s+(code|pr|pull\s*request|changes)",
            r"check\s+(this|my)\s+(code|implementation)",
            r"(is|does)\s+this\s+(code|implementation)\s+(good|ok|correct)",
            r"什麼.*問題|有.*bug|檢查.*code",
        ],
        "suggestion": "💡 Try /review for structured code review",
        "slash_command": "/review",
    },
    # Refactoring patterns
    {
        "name": "refactor",
        "patterns": [
            r"refactor\s+(this|the)",
            r"(clean|improve|simplify)\s+(up\s+)?(this|the)\s+code",
            r"make\s+(this|it)\s+(cleaner|simpler|more\s+readable)",
            r"重構|優化.*code|簡化",
        ],
        "suggestion": "💡 Consider using /refactor for systematic refactoring",
        "slash_command": "/refactor",
    },
    # Testing patterns
    {
        "name": "testing",
        "patterns": [
            r"(write|add|create)\s+(unit\s+)?tests?\s+for",
            r"test\s+(this|the)\s+(function|class|component)",
            r"(need|want)\s+tests?\s+for",
            r"寫.*測試|新增.*test",
        ],
        "suggestion": "💡 Use /test to generate comprehensive tests",
        "slash_command": "/test",
    },
    # Documentation patterns
    {
        "name": "documentation",
        "patterns": [
            r"(write|add|create|generate)\s+(documentation|docs|docstring)",
            r"document\s+(this|the)",
            r"(add|write)\s+comments?\s+(to|for)",
            r"寫.*文件|新增.*註解|說明.*這個",
        ],
        "suggestion": "💡 Try /doc for auto-generated documentation",
        "slash_command": "/doc",
    },
    # Bug fixing patterns
    {
        "name": "bug_fix",
        "patterns": [
            r"(fix|debug|solve)\s+(this|the)\s+(bug|error|issue|problem)",
            r"(why|what)\s+(is|does)\s+(this|it)\s+(not\s+work|fail|error)",
            r"getting\s+(an?\s+)?error",
            r"修.*bug|解決.*問題|為什麼.*錯誤",
        ],
        "suggestion": "💡 Describe the expected vs actual behavior for better debugging",
        "slash_command": None,
    },
    # Performance patterns
    {
        "name": "performance",
        "patterns": [
            r"(optimize|improve|speed\s+up)\s+(the\s+)?performance",
            r"(too\s+slow|taking\s+too\s+long)",
            r"make\s+(this|it)\s+faster",
            r"效能.*優化|太慢|加速",
        ],
        "suggestion": "💡 Consider profiling first with /perf before optimizing",
        "slash_command": "/perf",
    },
    # Git patterns
    {
        "name": "git_commit",
        "patterns": [
            r"commit\s+(these|the|my)\s+changes",
            r"(create|make)\s+a\s+commit",
            r"提交.*變更|commit",
        ],
        "suggestion": "💡 Remember to review changes with `git diff` before committing",
        "slash_command": None,
    },
    # PR patterns
    {
        "name": "pull_request",
        "patterns": [
            r"(create|open|make)\s+(a\s+)?(pr|pull\s*request)",
            r"submit\s+(this|the)\s+(pr|pull\s*request)",
            r"建立.*pr|開.*pull\s*request",
        ],
        "suggestion": "💡 Ensure tests pass before creating PR",
        "slash_command": None,
    },
    # Explanation patterns
    {
        "name": "explain",
        "patterns": [
            r"explain\s+(this|the|how)",
            r"(what|how)\s+does\s+(this|it)\s+(do|work)",
            r"(help\s+me\s+)?understand",
            r"解釋|說明|這是.*什麼|怎麼.*運作",
        ],
        "suggestion": "💡 Point to specific code sections for better explanations",
        "slash_command": None,
    },
    # Search patterns
    {
        "name": "search",
        "patterns": [
            r"(find|search|locate|where)\s+(is|are|for)",
            r"(which|what)\s+file",
            r"找.*在哪|搜尋|哪個.*檔案",
        ],
        "suggestion": "💡 Try using @file.ext to reference specific files",
        "slash_command": None,
    },
]


# =============================================================================
# Pattern Matching
# =============================================================================


def detect_patterns(prompt: str) -> list[PatternMatch]:
    """Detect patterns in user prompt and return suggestions."""
    matches = []
    prompt_lower = prompt.lower()

    for pattern_def in PATTERNS:
        for pattern in pattern_def["patterns"]:
            if re.search(pattern, prompt_lower, re.IGNORECASE):
                matches.append(
                    PatternMatch(
                        pattern_name=pattern_def["name"],
                        confidence=0.8,  # Fixed confidence for now
                        suggestion=pattern_def["suggestion"],
                        slash_command=pattern_def.get("slash_command"),
                    )
                )
                break  # Only match once per pattern type

    return matches


def get_suggestions(prompt: str) -> list[str]:
    """Get suggestion strings for a prompt."""
    matches = detect_patterns(prompt)
    return [m.suggestion for m in matches]


def format_suggestions(matches: list[PatternMatch]) -> str | None:
    """Format pattern matches as a single suggestion string."""
    if not matches:
        return None

    suggestions = [m.suggestion for m in matches[:3]]  # Limit to 3
    return "\n".join(suggestions)


# =============================================================================
# Prompt Analysis Statistics
# =============================================================================


def analyze_prompt(prompt: str) -> dict:
    """Analyze prompt and return statistics."""
    from metrics import estimate_tokens

    return {
        "char_count": len(prompt),
        "word_count": len(prompt.split()),
        "token_estimate": estimate_tokens(prompt),
        "patterns": [m.pattern_name for m in detect_patterns(prompt)],
        "has_code_block": "```" in prompt,
        "has_file_reference": "@" in prompt
        or re.search(r"\b\w+\.\w{2,4}\b", prompt) is not None,
        "is_question": prompt.strip().endswith("?")
        or any(
            q in prompt.lower()
            for q in [
                "what",
                "why",
                "how",
                "where",
                "when",
                "which",
                "什麼",
                "為什麼",
                "怎麼",
                "哪",
            ]
        ),
    }


# =============================================================================
# CLI Interface
# =============================================================================


def main():
    """Test pattern detection."""
    test_prompts = [
        "Can you review this code for me?",
        "Fix the bug in the login function",
        "Write tests for the UserService class",
        "Refactor this to make it cleaner",
        "Explain how this algorithm works",
        "Create a PR for these changes",
        "這個 function 有什麼問題？",
        "幫我優化這段 code 的效能",
    ]

    for prompt in test_prompts:
        print(f"\n📝 Prompt: {prompt}")
        matches = detect_patterns(prompt)
        if matches:
            for m in matches:
                print(f"   ✓ {m.pattern_name}: {m.suggestion}")
        else:
            print("   (no patterns detected)")


if __name__ == "__main__":
    main()
