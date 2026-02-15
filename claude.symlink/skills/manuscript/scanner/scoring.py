"""Scoring system for manuscript scan results."""


def calculate_score(findings, total_words):
    """Calculate manuscript quality score (0-10, lower is better).

    Uses issue density (findings per 1000 words) with tier weighting:
    - Tier A (errors): weight 2
    - Tier B (warnings): weight 1
    """
    if total_words == 0:
        return 0.0

    tier_a = sum(1 for f in findings if f.severity == "error")
    tier_b = sum(1 for f in findings if f.severity == "warning")
    tier_c = sum(1 for f in findings if f.severity == "suggestion")

    weighted = tier_a * 2 + tier_b * 1 + tier_c * 0.5
    density = weighted / total_words * 1000

    # Map to 0-10 scale
    # 0-0.5 issues/kword -> 0-2  (clean)
    # 0.5-2.0            -> 2-4  (minor)
    # 2.0-5.0            -> 4-6  (moderate)
    # 5.0-10             -> 6-8  (significant)
    # 10+                -> 8-10 (needs major revision)
    if density <= 0:
        return 0.0
    elif density <= 0.5:
        return density / 0.5 * 2
    elif density <= 2.0:
        return 2 + (density - 0.5) / 1.5 * 2
    elif density <= 5.0:
        return 4 + (density - 2.0) / 3.0 * 2
    elif density <= 10.0:
        return 6 + (density - 5.0) / 5.0 * 2
    elif density <= 15.0:
        return 8 + (density - 10.0) / 5.0 * 2
    else:
        return 10.0


def calculate_section_scores(findings, sections, total_words, lines=None):
    """Calculate per-section scores.

    Args:
        findings: List of Finding objects.
        sections: List of SectionRange objects.
        total_words: Total word count (used as fallback).
        lines: Optional list of text lines for accurate per-section word counts.

    Returns dict of section_name -> score (0-10).
    """
    if not sections:
        return {}

    scores = {}
    for sec in sections:
        sec_findings = [f for f in findings if f.section == sec.name]
        if lines:
            import re
            sec_text = " ".join(lines[sec.start_line - 1:sec.end_line])
            sec_word_count = max(1, len(re.findall(r"\b\w+\b", sec_text)))
        else:
            sec_word_count = max(1, (sec.end_line - sec.start_line + 1) * 12)
        scores[sec.name] = calculate_score(sec_findings, sec_word_count)

    return scores


def score_descriptor(score):
    """Return a human-readable descriptor for a score."""
    if score <= 1:
        return "clean, well-crafted manuscript"
    elif score <= 2:
        return "minor issues, light revision"
    elif score <= 4:
        return "some anti-patterns detected, focused revision recommended"
    elif score <= 6:
        return "moderate issues, careful revision pass needed"
    elif score <= 8:
        return "significant issues, substantial revision recommended"
    else:
        return "many anti-patterns, major revision needed"
