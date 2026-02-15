"""Tier B checks: warning-level detection.

B1: Passive voice ratio
B2: Sentence monotony
B3: Table/figure narration
B4: Statistical Discussion opener
B5: Mechanical transitions
B6: Overclaiming language
"""

import re
from .models import Finding
from .detector import get_section_for_line, get_section_lines
from .tokenizer import split_sentences, sentence_word_count

# --- B1: Passive voice ratio ---

_PASSIVE_PATTERNS = [
    re.compile(r"\bwas\s+(?:observed|found|noted|seen|performed|conducted|measured|assessed|evaluated|determined|calculated|analyzed|included|excluded|recorded|obtained|collected|demonstrated|identified|detected|associated|considered|defined|classified|compared|used|applied|administered|treated)\b", re.I),
    re.compile(r"\bwere\s+(?:observed|found|noted|seen|performed|conducted|measured|assessed|evaluated|determined|calculated|analyzed|included|excluded|recorded|obtained|collected|demonstrated|identified|detected|associated|considered|defined|classified|compared|used|applied|administered|treated)\b", re.I),
    re.compile(r"\bit\s+was\s+found\s+that\b", re.I),
    re.compile(r"\bhas\s+been\s+(?:shown|demonstrated|reported|suggested|established|observed|noted|described)\b", re.I),
    re.compile(r"\bhave\s+been\s+(?:shown|demonstrated|reported|suggested|established|observed|noted|described)\b", re.I),
]


def check_passive_voice_ratio(lines, sections):
    """B1: Flag sections with excessive passive voice."""
    findings = []

    section_names = [s.name for s in sections] if sections else ["Unknown"]
    if not sections:
        section_names = ["Unknown"]

    for sec in (sections or []):
        sec_lines = lines[sec.start_line - 1:sec.end_line]
        text = " ".join(sec_lines)
        sentences = split_sentences(text)
        if len(sentences) < 5:
            continue

        passive_count = 0
        for sent in sentences:
            for pattern in _PASSIVE_PATTERNS:
                if pattern.search(sent):
                    passive_count += 1
                    break

        ratio = passive_count / len(sentences)

        # Different thresholds for Methods vs. other sections
        threshold = 0.60 if sec.name == "Methods" else 0.40
        if ratio > threshold:
            findings.append(Finding(
                check_id="B1",
                check_name="passive-voice-ratio",
                severity="warning",
                section=sec.name,
                line_num=sec.start_line,
                line_text=f"[{sec.name} section: {len(sentences)} sentences]",
                matched_text=f"{ratio:.0%} passive",
                message=f"Passive voice ratio in {sec.name}: {ratio:.0%} ({passive_count}/{len(sentences)} sentences) — threshold {threshold:.0%}",
                suggestion="Use active voice with research variables as subjects: 'LDH predicted mortality' not 'A significant association was observed'",
            ))

    return findings


# --- B2: Sentence monotony ---

def check_sentence_monotony(lines, sections):
    """B2: Flag monotonous sentence length patterns."""
    findings = []
    text = "\n".join(lines)
    sentences = split_sentences(text)

    if len(sentences) < 6:
        return findings

    lengths = [sentence_word_count(s) for s in sentences]

    # Check for 3+ consecutive long sentences (all >25 words)
    consecutive_long = 0
    for idx, length in enumerate(lengths):
        if length > 25:
            consecutive_long += 1
            if consecutive_long >= 3:
                # Find approximate line number
                approx_line = _find_sentence_line(lines, sentences[idx])
                findings.append(Finding(
                    check_id="B2",
                    check_name="sentence-monotony",
                    severity="warning",
                    section=get_section_for_line(sections, approx_line),
                    line_num=approx_line,
                    line_text=sentences[idx][:80] + ("..." if len(sentences[idx]) > 80 else ""),
                    matched_text=f"{consecutive_long} consecutive sentences >25 words",
                    message=f"{consecutive_long} consecutive long sentences (>25 words each) — vary rhythm",
                    suggestion="Insert a short emphatic sentence (5-10 words) to break the monotony",
                ))
                consecutive_long = 0  # reset to avoid duplicate findings
        else:
            consecutive_long = 0

    # Check overall low variance (monotonous rhythm)
    if len(lengths) >= 10:
        import statistics
        std = statistics.stdev(lengths)
        mean = statistics.mean(lengths)
        if std < 5 and mean > 15:
            findings.append(Finding(
                check_id="B2",
                check_name="sentence-monotony",
                severity="warning",
                section="Overall",
                line_num=1,
                line_text=f"[{len(sentences)} sentences analyzed]",
                matched_text=f"mean={mean:.0f} words, std={std:.1f}",
                message=f"Low sentence length variety (mean {mean:.0f} words, std dev {std:.1f}) — monotonous rhythm",
                suggestion="Mix short (5-10 word) sentences with longer ones for emphasis and rhythm",
            ))

    return findings


def _find_sentence_line(lines, sentence_fragment):
    """Approximate the line number where a sentence begins."""
    # Use first 40 characters of the sentence as a search key
    key = sentence_fragment[:40].strip()
    for i, line in enumerate(lines):
        if key in line:
            return i + 1
    return 1


# --- B3: Table/figure narration ---

_NARRATION_PATTERNS = [
    (re.compile(r"\bTable\s+\d+\s+shows\b", re.I), "Table X shows"),
    (re.compile(r"\bFigure\s+\d+\s+shows\b", re.I), "Figure X shows"),
    (re.compile(r"\bas\s+(?:shown|seen|demonstrated|illustrated)\s+in\s+(?:Table|Figure)\b", re.I), "As shown in Table/Figure"),
    (re.compile(r"\bas\s+can\s+be\s+seen\s+in\s+(?:Table|Figure)\b", re.I), "As can be seen in"),
    (re.compile(r"\b(?:Table|Figure)\s+\d+\s+(?:demonstrates|illustrates|presents|displays|depicts|summarizes)\b", re.I), "Table/Figure X demonstrates"),
]


def check_table_figure_narration(lines, sections):
    """B3: Flag passive table/figure narration."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label in _NARRATION_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="B3",
                    check_name="table-figure-narration",
                    severity="warning",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Table/figure narration: "{label}"',
                    suggestion="Reference by finding: 'Mortality was higher in group 3 (Table 2)' not 'Table 2 shows that...'",
                ))
                break
    return findings


# --- B4: Statistical Discussion opener ---

_STAT_IN_DISCUSSION = re.compile(
    r"(?:HR|OR|RR|AOR|aHR|aOR)\s*[=:]\s*\d|"
    r"\bp\s*[<>=]\s*0\.\d|"
    r"\d+%?\s*CI\s*[=:,]?\s*\d|"
    r"95%\s*(?:CI|confidence)",
    re.I,
)


def check_statistical_discussion_opener(lines, sections):
    """B4: Flag Discussion opening with statistical results."""
    findings = []
    sec = get_section_lines(sections, "Discussion")
    if not sec:
        return findings

    start, end = sec
    # Check first 5 non-empty lines of Discussion
    count = 0
    for i in range(start - 1, min(end, len(lines))):
        line = lines[i].strip()
        if not line:
            continue
        count += 1
        if count > 3:
            break

        if _STAT_IN_DISCUSSION.search(line):
            findings.append(Finding(
                check_id="B4",
                check_name="statistical-discussion-opener",
                severity="warning",
                section="Discussion",
                line_num=i + 1,
                line_text=line[:80] + ("..." if len(line) > 80 else ""),
                matched_text="statistical values in Discussion opening",
                message="Discussion opens with statistical results instead of conceptual significance",
                suggestion="Lead with the conceptual meaning of your finding, not the numbers",
            ))
            break  # one finding is enough
    return findings


# --- B5: Mechanical transitions ---

_MECHANICAL_TRANSITIONS = re.compile(
    r"^\s*(?:Furthermore|Moreover|Additionally|In addition)\b", re.I | re.MULTILINE
)


def check_mechanical_transitions(lines, sections):
    """B5: Flag clusters of mechanical transition words."""
    findings = []
    positions = []

    for i, line in enumerate(lines):
        if _MECHANICAL_TRANSITIONS.match(line.strip()):
            positions.append(i)

    # Flag if 3+ within a 30-line window
    for idx, pos in enumerate(positions):
        window_end = pos + 30
        cluster = [p for p in positions if pos <= p <= window_end]
        if len(cluster) >= 3 and idx == positions.index(cluster[0]):
            findings.append(Finding(
                check_id="B5",
                check_name="mechanical-transitions",
                severity="warning",
                section=get_section_for_line(sections, pos + 1),
                line_num=pos + 1,
                line_text=lines[pos].strip(),
                matched_text=f'{len(cluster)}x "Furthermore/Moreover/Additionally" in {window_end - pos} lines',
                message=f"{len(cluster)} mechanical transitions in a short span",
                suggestion="Use logical connectors that show the relationship: 'Building on this...', 'In contrast...', 'This likely reflects...'",
            ))

    return findings


# --- B6: Overclaiming ---

_OVERCLAIM_PATTERNS = [
    (re.compile(r"\brevolutioniz\w*\b", re.I), "revolutionize"),
    (re.compile(r"\bparadigm\s+shift\b", re.I), "paradigm shift"),
    (re.compile(r"\bfirst\s+(?:study\s+)?to\s+(?:demonstrate|show|prove|report)\b", re.I), "first to demonstrate"),
    (re.compile(r"\bconclusively\s+(?:proves?|demonstrates?|shows?)\b", re.I), "conclusively proves"),
    (re.compile(r"\bdefinitively\s+(?:shows?|demonstrates?|establishes?)\b", re.I), "definitively shows"),
    (re.compile(r"\bundeniably\b", re.I), "undeniably"),
    (re.compile(r"\bunequivocally\b", re.I), "unequivocally"),
]


def check_overclaiming(lines, sections):
    """B6: Flag overclaiming language."""
    findings = []

    # Check Discussion and Conclusion
    check_ranges = []
    for name in ("Discussion", "Conclusion"):
        sec = get_section_lines(sections, name)
        if sec:
            check_ranges.append(range(sec[0] - 1, min(sec[1], len(lines))))

    if not check_ranges:
        # Fallback: last third of document
        start = len(lines) * 2 // 3
        check_ranges.append(range(start, len(lines)))

    for check_range in check_ranges:
        for i in check_range:
            line = lines[i]
            for pattern, label in _OVERCLAIM_PATTERNS:
                m = pattern.search(line)
                if m:
                    findings.append(Finding(
                        check_id="B6",
                        check_name="overclaiming",
                        severity="warning",
                        section=get_section_for_line(sections, i + 1),
                        line_num=i + 1,
                        line_text=line.strip(),
                        matched_text=m.group(),
                        message=f'Overclaiming language: "{label}"',
                        suggestion="Temper the claim; observational studies cannot prove causation",
                    ))
                    break
    return findings


# --- Registry ---

ALL_TIER_B_CHECKS = [
    check_passive_voice_ratio,
    check_sentence_monotony,
    check_table_figure_narration,
    check_statistical_discussion_opener,
    check_mechanical_transitions,
    check_overclaiming,
]
