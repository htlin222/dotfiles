"""Manuscript scanner: detect anti-patterns in medical research manuscripts."""

from .models import Finding, SectionRange, ScanResult
from .detector import detect_sections, get_section_for_line
from .tokenizer import word_count, split_sentences
from .checks_tier_a import ALL_TIER_A_CHECKS
from .checks_tier_b import ALL_TIER_B_CHECKS
from .checks_tier_c import ALL_TIER_C_CHECKS


def scan(text: str, section_override: str | None = None, no_section_detect: bool = False) -> ScanResult:
    """Run all checks on manuscript text.

    Args:
        text: Full manuscript text.
        section_override: If set, treat entire text as this section.
        no_section_detect: If True, skip section detection (run all checks everywhere).

    Returns:
        ScanResult with all findings, sections, and stats.
    """
    lines = text.splitlines()
    total = word_count(text)

    # Section detection
    if section_override:
        sections = [SectionRange(name=section_override, start_line=1, end_line=len(lines))]
    elif no_section_detect:
        sections = []
    else:
        sections = detect_sections(lines)

    # Run all checks
    findings = []
    for check_fn in ALL_TIER_A_CHECKS:
        findings.extend(check_fn(lines, sections))
    for check_fn in ALL_TIER_B_CHECKS:
        findings.extend(check_fn(lines, sections))
    for check_fn in ALL_TIER_C_CHECKS:
        findings.extend(check_fn(lines, sections))

    # Sentence stats
    sentences = split_sentences(text)
    from .tokenizer import sentence_word_count
    sent_lengths = [sentence_word_count(s) for s in sentences]

    return ScanResult(
        findings=findings,
        sections=sections,
        total_words=total,
        sentence_count=len(sentences),
        sentence_lengths=sent_lengths,
        lines=lines,
    )


__all__ = ["scan", "Finding", "SectionRange", "ScanResult"]
