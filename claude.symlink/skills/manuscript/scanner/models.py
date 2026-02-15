"""Data models for manuscript scanner."""

from dataclasses import dataclass, field


@dataclass
class SectionRange:
    """A detected manuscript section with line boundaries."""
    name: str
    start_line: int  # 1-indexed, inclusive
    end_line: int     # 1-indexed, inclusive


@dataclass
class Finding:
    """A single issue found in the manuscript."""
    check_id: str       # "A1", "B2", etc.
    check_name: str     # "interpretation-in-results"
    severity: str       # "error" or "warning"
    section: str        # "Results", "Introduction", etc.
    line_num: int
    line_text: str
    matched_text: str
    message: str
    suggestion: str


@dataclass
class ScanResult:
    """Complete scan results."""
    findings: list = field(default_factory=list)
    sections: list = field(default_factory=list)  # list of SectionRange
    total_words: int = 0
    sentence_count: int = 0
    sentence_lengths: list = field(default_factory=list)
    passive_counts: dict = field(default_factory=dict)  # section -> (passive, total)
    lines: list = field(default_factory=list)  # raw text lines for section word counts
