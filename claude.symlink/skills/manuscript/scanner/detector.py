"""Section detection for manuscript text.

Recognizes Introduction, Methods, Results, Discussion, Conclusion, Abstract
via markdown headers, LaTeX sections, ALL CAPS headers, and numbered headers.
"""

import re
from .models import SectionRange

# Canonical section names and their aliases
SECTION_ALIASES = {
    "abstract": "Abstract",
    "background": "Introduction",
    "introduction": "Introduction",
    "methods": "Methods",
    "methodology": "Methods",
    "materials and methods": "Methods",
    "patients and methods": "Methods",
    "study design": "Methods",
    "statistical analysis": "Methods",
    "results": "Results",
    "findings": "Results",
    "discussion": "Discussion",
    "comment": "Discussion",
    "conclusion": "Conclusion",
    "conclusions": "Conclusion",
    "summary": "Conclusion",
    "results and discussion": "Results",  # combined section
}

# Patterns for header detection (ordered by specificity)
HEADER_PATTERNS = [
    # Markdown: ## Introduction, # Methods, ### Results
    re.compile(r"^#{1,4}\s+(.+?)\s*$"),
    # Numbered: 1. Introduction, 2. Methods
    re.compile(r"^\d+\.?\s+(.+?)\s*$"),
    # LaTeX: \section{Introduction}, \subsection{Methods}
    re.compile(r"^\\(?:sub)*section\{(.+?)\}\s*$"),
    # ALL CAPS on its own line: INTRODUCTION, METHODS
    re.compile(r"^([A-Z][A-Z\s]{2,})$"),
]


def _normalize_section_name(raw: str) -> str | None:
    """Map a raw header string to a canonical section name, or None."""
    cleaned = raw.strip().rstrip(":").lower()
    # Remove numbering prefix like "3.1" or "III."
    # Digits: require period or space after (e.g. "3.1 " or "3 ")
    # Roman numerals (i, v, x): require period after to avoid stripping from words like "introduction"
    cleaned = re.sub(r"^(?:\d[\d.]*\.?\s+|[ivx]+\.\s*)", "", cleaned, flags=re.IGNORECASE)
    cleaned = cleaned.strip()
    return SECTION_ALIASES.get(cleaned)


def detect_sections(lines: list[str]) -> list[SectionRange]:
    """Detect manuscript sections from text lines.

    Args:
        lines: List of text lines (0-indexed internally, but SectionRange uses 1-indexed).

    Returns:
        List of SectionRange objects sorted by start_line.
    """
    candidates = []  # (line_index, canonical_name)

    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped:
            continue

        for pattern in HEADER_PATTERNS:
            m = pattern.match(stripped)
            if m:
                raw = m.group(1) if m.lastindex else stripped
                canonical = _normalize_section_name(raw)
                if canonical:
                    candidates.append((i, canonical))
                    break  # first matching pattern wins

    if not candidates:
        return []

    # Build section ranges
    sections = []
    for idx, (line_idx, name) in enumerate(candidates):
        start = line_idx + 1  # 1-indexed, line after header
        if idx + 1 < len(candidates):
            end = candidates[idx + 1][0]  # up to next header (exclusive)
        else:
            end = len(lines)  # until end of document
        sections.append(SectionRange(name=name, start_line=start + 1, end_line=end))

    return sections


def get_section_for_line(sections: list[SectionRange], line_num: int) -> str:
    """Return the section name for a given line number, or 'Unknown'."""
    for sec in sections:
        if sec.start_line <= line_num <= sec.end_line:
            return sec.name
    return "Unknown"


def get_section_lines(sections: list[SectionRange], name: str) -> tuple[int, int] | None:
    """Return (start_line, end_line) for a named section, or None."""
    for sec in sections:
        if sec.name == name:
            return (sec.start_line, sec.end_line)
    return None
