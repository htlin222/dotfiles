#!/usr/bin/env python3
"""
Scan text for AI-favored English words and calculate an AI vocabulary score.

Based on:
- Matsui K. (2025). Perspectives on Medical Education, 14(1), 882-890.
- Kobak, D., et al. (2025). Science Advances, 11(27), eadt3813.

Usage:
    python3 scan-ai-words.py <file>
    cat text.txt | python3 scan-ai-words.py
    python3 scan-ai-words.py --json <file>       # JSON output
    python3 scan-ai-words.py --quiet <file>       # Score only
"""

import re
import sys
import json
import argparse
from collections import defaultdict
from pathlib import Path

# === Word list loading ===
SCRIPT_DIR = Path(__file__).resolve().parent
WORDLIST_FILE = SCRIPT_DIR / "ai-words.yml"

# Hardcoded fallback (subset) if YAML file not found
_FALLBACK_TIER1 = {
    "delve": "explore, examine, look into",
    "underscore": "emphasize, highlight, stress",
    "meticulous": "careful, thorough, precise",
    "intricate": "complex, detailed, elaborate",
    "tapestry": "mix, combination, range",
    "commendable": "impressive, notable, solid",
    "showcase": "show, demonstrate, present",
    "pivotal": "key, important, central",
    "bolster": "support, strengthen, back up",
    "surpass": "exceed, beat, outperform",
    "boast": "have, feature, offer",
    "primarily": "mainly, mostly, largely",
}
_FALLBACK_TIER2 = {
    "elucidate": "explain, clarify, make clear",
    "garner": "gain, attract, earn, get",
    "leverage": "use, take advantage of, build on",
    "unveil": "reveal, introduce, present",
    "scrutinize": "examine, inspect, review",
    "foster": "encourage, promote, support",
    "facilitate": "help, enable, make easier",
    "harness": "use, apply, put to use",
    "navigate": "handle, manage, deal with",
    "streamline": "simplify, improve, speed up",
    "groundbreaking": "new, innovative, first-of-its-kind",
    "transformative": "significant, game-changing, major",
    "nuanced": "subtle, complex, layered",
    "comprehensive": "full, complete, thorough",
    "robust": "strong, solid, reliable",
    "multifaceted": "complex, varied, diverse",
    "notably": "especially, in particular",
    "predominantly": "mostly, mainly, largely",
    "furthermore": "also, and, in addition",
    "moreover": "also, besides, in addition",
    "realm": "area, field, domain",
    "landscape": "field, area, scene, picture",
    "paradigm": "model, approach, framework",
    "trajectory": "path, direction, trend",
    "myriad": "many, numerous, a wide range of",
    "plethora": "many, plenty, a lot of",
}


def load_wordlists(wordlist_path=None):
    """Load word lists from YAML file, with fallback to hardcoded lists.

    Supports optional --wordlist flag to use a custom YAML file.
    YAML format: tier1/tier2/custom sections, each with word: "alternatives"
    """
    path = Path(wordlist_path) if wordlist_path else WORDLIST_FILE

    if not path.exists():
        return dict(_FALLBACK_TIER1), dict(_FALLBACK_TIER2)

    try:
        # Simple YAML parser — no pyyaml dependency needed
        tier1, tier2, custom = {}, {}, {}
        current_section = None

        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue

            # Section headers
            if stripped == "tier1:":
                current_section = "tier1"
                continue
            elif stripped == "tier2:":
                current_section = "tier2"
                continue
            elif stripped == "custom:":
                current_section = "custom"
                continue

            # Word entries: word: "alternatives" or word: alternatives
            if current_section and ":" in stripped and not stripped.endswith(":"):
                # Skip comment lines within sections
                if stripped.startswith("#"):
                    continue
                key, _, value = stripped.partition(":")
                key = key.strip().strip('"').strip("'")
                value = value.strip().strip('"').strip("'")
                if key and value:
                    if current_section == "tier1":
                        tier1[key] = value
                    elif current_section == "tier2":
                        tier2[key] = value
                    elif current_section == "custom":
                        # Custom words go into tier2
                        tier2[key] = value

        if not tier1 and not tier2:
            return dict(_FALLBACK_TIER1), dict(_FALLBACK_TIER2)

        return tier1, tier2

    except Exception as e:
        print(f"Warning: Failed to parse {path}: {e}", file=sys.stderr)
        print("Falling back to built-in word list.", file=sys.stderr)
        return dict(_FALLBACK_TIER1), dict(_FALLBACK_TIER2)


# Load at module level
TIER1, TIER2 = load_wordlists()

# Words to match with their morphological variants
def build_patterns(word_dict):
    """Build regex patterns that match word forms (plural, -ing, -ed, etc.)."""
    patterns = {}
    for word in word_dict:
        # Match the word and common suffixes, as whole words only
        base = re.escape(word)
        # Handle common morphological variants
        pattern = rf"\b{base}(?:s|ed|ing|ly|es|d)?\b"
        patterns[word] = re.compile(pattern, re.IGNORECASE)
    return patterns


def count_words(text):
    """Count total words in text."""
    return len(re.findall(r"\b\w+\b", text))


def is_inside_quotes(text, start, end):
    """Check if a match position falls inside quotation marks."""
    # Check for various quote styles: "...", "...", '...'
    quote_patterns = [
        r'"[^"]*"',
        r'\u201c[^\u201d]*\u201d',  # smart quotes
        r"'[^']*'",
    ]
    for qp in quote_patterns:
        for qm in re.finditer(qp, text):
            if qm.start() <= start and end <= qm.end():
                return True
    return False


# Contextual exclusion: phrases where the word is domain-legitimate, not AI flavor
# Each key is a word, value is a list of regex patterns that make it a false positive
LEGITIMATE_CONTEXTS = {
    "landscape": [
        r"\b(?:urban|rural|natural|desert|mountain|forest|cultural|political|"
        r"agricultural|volcanic|coastal|arctic|tropical)\s+landscapes?\b",
        r"\blandscapes?\s+(?:architect|design|painting|photography|ecology|management)\b",
    ],
    "robust": [
        r"\brobust\s+(?:standard\s+errors?|regression|estimat\w*|statistic\w*|check\w*|test\w*|control\w*|optimizer|method)\b",
        r"\b(?:statistically|econometrically)\s+robust\b",
    ],
    "comprehensive": [
        r"\bcomprehensive\s+(?:metabolic\s+panel|exam|insurance|care|school|income)\b",
    ],
    "navigate": [
        r"\bnavigate\s+(?:to|the\s+(?:page|menu|site|app|interface|screen|tab|url|link))\b",
        r"\b(?:GPS|browser|user|ship|pilot|sailor)\s+navigat\b",
    ],
    "paradigm": [
        r"\bKuhn'?s?\s+paradigm\b",
        r"\bparadigm\s+shift\b",  # original Kuhn usage is legitimate
    ],
    "trajectory": [
        r"\b(?:ballistic|orbital|flight|missile|projectile|growth|career|patient|disease)\s+trajectory\b",
    ],
    "discourse": [
        r"\bdiscourse\s+(?:analysis|marker|structure|community|theory)\b",
        r"\b(?:critical|political|public|academic)\s+discourse\b",
    ],
    "leverage": [
        r"\b(?:financial|operating|debt|equity)\s+leverage\b",
        r"\bleverage\s+ratio\b",
    ],
    "foster": [
        r"\bfoster\s+(?:care|child|parent|home|family)\b",
        r"\b(?:Dr|Mr|Mrs|Ms|Prof)\.?\s+Foster\b",
    ],
    "paramount": [
        r"\bParamount\s+(?:Pictures|Studios|Plus|\+|Global)\b",
    ],
    "embark": [
        r"\bembark(?:s|ed|ing)?\s+(?:on\s+(?:a\s+)?(?:ship|boat|vessel|flight|journey|voyage|cruise|expedition|tour))\b",
    ],
    "illuminate": [
        r"\b(?:LED|lamp|light|bulb|sun|candle|laser)s?\s+illuminat\b",
        r"\billuminat(?:e|ed|ing|ion)\s+(?:the\s+)?(?:room|stage|path|street|building|area)\b",
    ],
    "cornerstone": [
        r"\bcornerstone\s+(?:ceremony|laying|stone|church|building)\b",
    ],
    "myriad": [
        r"\ba\s+myriad\s+of\b",  # grammatically debated but human-typical usage
    ],
}


def is_legitimate_context(word, line):
    """Check if the word appears in a domain-legitimate context (false positive)."""
    patterns = LEGITIMATE_CONTEXTS.get(word, [])
    for pattern in patterns:
        if re.search(pattern, line, re.IGNORECASE):
            return True
    return False


def scan_text(text):
    """Scan text and return findings. Skips quotes and legitimate contexts."""
    lines = text.splitlines()
    tier1_patterns = build_patterns(TIER1)
    tier2_patterns = build_patterns(TIER2)

    tier1_hits = defaultdict(list)  # word -> [(line_num, line_text, matched_form)]
    tier2_hits = defaultdict(list)

    for line_num, line in enumerate(lines, 1):
        for word, pattern in tier1_patterns.items():
            for match in pattern.finditer(line):
                if not is_inside_quotes(line, match.start(), match.end()) \
                        and not is_legitimate_context(word, line):
                    tier1_hits[word].append((line_num, line.strip(), match.group()))
        for word, pattern in tier2_patterns.items():
            for match in pattern.finditer(line):
                if not is_inside_quotes(line, match.start(), match.end()) \
                        and not is_legitimate_context(word, line):
                    tier2_hits[word].append((line_num, line.strip(), match.group()))

    return tier1_hits, tier2_hits


def calculate_score(tier1_hits, tier2_hits, total_words):
    """Calculate AI flavor score (0-10).

    Uses raw density as primary signal with a small tier1 boost.
    Also considers unique word variety (more distinct AI words = worse).
    """
    if total_words == 0:
        return 0.0

    raw_count = sum(len(v) for v in tier1_hits.values()) + sum(
        len(v) for v in tier2_hits.values()
    )
    density = raw_count / total_words * 100

    # Unique AI words found (variety penalty)
    unique_count = len(tier1_hits) + len(tier2_hits)

    # Tier1 boost: add 20% extra weight for tier1 words
    tier1_count = sum(len(v) for v in tier1_hits.values())
    boosted_density = density + (tier1_count / total_words * 100 * 0.2)

    # Variety factor: more distinct AI words = slightly worse (max 1.3x)
    variety_factor = min(1.3, 1.0 + unique_count * 0.02)
    effective_density = boosted_density * variety_factor

    # Map to 0-10 scale (calibrated for typical academic text)
    # Thresholds: 0%->0, 1%->2, 3%->4, 6%->6, 10%->8, 15%+->10
    # A typical paper with a few AI words (~1-2%) should score 2-3 (light)
    # Heavy AI use (~5-8%) should score 5-7 (moderate-strong)
    # Extreme AI text (>10%) should score 8-10
    if effective_density <= 0:
        return 0.0
    elif effective_density <= 1.0:
        return effective_density / 1.0 * 2
    elif effective_density <= 3.0:
        return 2 + (effective_density - 1.0) / 2.0 * 2
    elif effective_density <= 6.0:
        return 4 + (effective_density - 3.0) / 3.0 * 2
    elif effective_density <= 10.0:
        return 6 + (effective_density - 6.0) / 4.0 * 2
    elif effective_density <= 15.0:
        return 8 + (effective_density - 10.0) / 5.0 * 2
    else:
        return 10.0


def format_report(tier1_hits, tier2_hits, total_words, score):
    """Format a human-readable report."""
    raw_count = sum(len(v) for v in tier1_hits.values()) + sum(
        len(v) for v in tier2_hits.values()
    )
    density = raw_count / total_words * 100 if total_words > 0 else 0

    # Score descriptor
    if score <= 2:
        desc = "natural, minimal AI traces"
    elif score <= 4:
        desc = "light AI flavor, minor edits needed"
    elif score <= 6:
        desc = "moderate AI flavor, review each word"
    elif score <= 8:
        desc = "strong AI flavor, significant rewriting needed"
    else:
        desc = "very strong AI flavor, consider rewriting"

    lines = []
    lines.append("")
    lines.append("=" * 40)
    lines.append("  AI Word Scan Report")
    lines.append("=" * 40)
    lines.append("")
    lines.append(f"  Score: {score:.1f} / 10  ({desc})")
    lines.append("")
    lines.append(
        f"  Found {raw_count} AI-flavored word(s) in {total_words:,} words ({density:.2f}% density)"
    )
    lines.append("")

    if tier1_hits:
        lines.append("  TIER 1 (top flagged):")
        for word in sorted(tier1_hits, key=lambda w: -len(tier1_hits[w])):
            hits = tier1_hits[word]
            line_nums = ", ".join(str(h[0]) for h in hits[:5])
            if len(hits) > 5:
                line_nums += f" +{len(hits)-5} more"
            lines.append(f"    {word} x{len(hits)}  (line {line_nums})")
        lines.append("")

    if tier2_hits:
        lines.append("  TIER 2 (commonly flagged):")
        for word in sorted(tier2_hits, key=lambda w: -len(tier2_hits[w])):
            hits = tier2_hits[word]
            line_nums = ", ".join(str(h[0]) for h in hits[:5])
            if len(hits) > 5:
                line_nums += f" +{len(hits)-5} more"
            lines.append(f"    {word} x{len(hits)}  (line {line_nums})")
        lines.append("")

    # Suggestions (top 5)
    if tier1_hits or tier2_hits:
        lines.append("  Suggestions:")
        all_hits = []
        for word, hits in tier1_hits.items():
            for h in hits:
                all_hits.append((word, h, TIER1[word], 1))
        for word, hits in tier2_hits.items():
            for h in hits:
                all_hits.append((word, h, TIER2[word], 2))

        # Sort by tier (1 first), then by line number
        all_hits.sort(key=lambda x: (x[3], x[1][0]))

        shown = 0
        seen_words = set()
        for word, (line_num, line_text, matched), alternatives, tier in all_hits:
            if shown >= 5:
                remaining = len(all_hits) - shown
                if remaining > 0:
                    lines.append(f"    ... and {remaining} more")
                break
            if word in seen_words:
                continue
            seen_words.add(word)

            # Truncate long lines
            if len(line_text) > 60:
                # Find the word position and show context around it
                idx = line_text.lower().find(matched.lower())
                start = max(0, idx - 25)
                end = min(len(line_text), idx + len(matched) + 25)
                snippet = line_text[start:end]
                if start > 0:
                    snippet = "..." + snippet
                if end < len(line_text):
                    snippet = snippet + "..."
            else:
                snippet = line_text

            lines.append(f'    L{line_num}: "{matched}" -> try: {alternatives}')
            lines.append(f"          {snippet}")
            shown += 1

        lines.append("")

    if not tier1_hits and not tier2_hits:
        lines.append("  No AI-flavored words found. Looks natural!")
        lines.append("")

    lines.append("=" * 40)
    return "\n".join(lines)


def format_json(tier1_hits, tier2_hits, total_words, score):
    """Format results as JSON."""
    raw_count = sum(len(v) for v in tier1_hits.values()) + sum(
        len(v) for v in tier2_hits.values()
    )

    result = {
        "score": round(score, 1),
        "total_words": total_words,
        "ai_word_count": raw_count,
        "density_pct": round(raw_count / total_words * 100, 2) if total_words else 0,
        "tier1": {
            word: {
                "count": len(hits),
                "lines": [h[0] for h in hits],
                "alternatives": TIER1[word],
            }
            for word, hits in tier1_hits.items()
        },
        "tier2": {
            word: {
                "count": len(hits),
                "lines": [h[0] for h in hits],
                "alternatives": TIER2[word],
            }
            for word, hits in tier2_hits.items()
        },
    }
    return json.dumps(result, indent=2, ensure_ascii=False)


def main():
    parser = argparse.ArgumentParser(
        description="Scan English text for AI-flavored vocabulary"
    )
    parser.add_argument("file", nargs="?", help="Text file to scan (or use stdin)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument("--quiet", action="store_true", help="Score only")
    parser.add_argument(
        "--wordlist",
        help="Custom word list YAML file (default: ai-words.yml next to this script)",
    )
    parser.add_argument(
        "--list-words", action="store_true", help="Show loaded word list and exit"
    )
    args = parser.parse_args()

    # Reload word lists if custom path given
    global TIER1, TIER2
    if args.wordlist:
        TIER1, TIER2 = load_wordlists(args.wordlist)

    # List words mode
    if args.list_words:
        print(f"Tier 1 ({len(TIER1)} words):")
        for w, alt in sorted(TIER1.items()):
            print(f"  {w:20s} -> {alt}")
        print(f"\nTier 2 ({len(TIER2)} words):")
        for w, alt in sorted(TIER2.items()):
            print(f"  {w:20s} -> {alt}")
        print(f"\nTotal: {len(TIER1) + len(TIER2)} words")
        sys.exit(0)

    # Read input
    if args.file:
        path = Path(args.file)
        if not path.exists():
            print(f"Error: File not found: {args.file}", file=sys.stderr)
            sys.exit(1)
        text = path.read_text(encoding="utf-8")
    elif not sys.stdin.isatty():
        text = sys.stdin.read()
    else:
        print("Usage: scan-ai-words.py <file>", file=sys.stderr)
        print("       cat text.txt | scan-ai-words.py", file=sys.stderr)
        print("       scan-ai-words.py --list-words", file=sys.stderr)
        print("       scan-ai-words.py --wordlist custom.yml <file>", file=sys.stderr)
        sys.exit(1)

    # Scan
    total_words = count_words(text)
    tier1_hits, tier2_hits = scan_text(text)
    score = calculate_score(tier1_hits, tier2_hits, total_words)

    # Output
    if args.quiet:
        print(f"{score:.1f}")
    elif args.json:
        print(format_json(tier1_hits, tier2_hits, total_words, score))
    else:
        print(format_report(tier1_hits, tier2_hits, total_words, score))


if __name__ == "__main__":
    main()
