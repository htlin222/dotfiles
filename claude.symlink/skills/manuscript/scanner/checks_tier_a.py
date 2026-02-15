"""Tier A checks: high-confidence error detection.

A1: Interpretation in Results
A2: Empty adjectives
A3: Hedge stacking
A4: Textbook opening
A5: Weak ending
A6: Vague aim
A7: P-value without CI
A8: Citation stacking
"""

import re
from .models import Finding
from .detector import get_section_for_line, get_section_lines

# --- A1: Interpretation in Results ---

_INTERPRETATION_PATTERNS = [
    (re.compile(r"\bthis\s+suggests?\s+that\b", re.I), "this suggests that"),
    (re.compile(r"\bthis\s+may\s+be\s+because\b", re.I), "this may be because"),
    (re.compile(r"\bone\s+possible\s+explanation\b", re.I), "one possible explanation"),
    (re.compile(r"\bconsistent\s+with\s+(?:our|the)\s+hypothesis\b", re.I), "consistent with hypothesis"),
    (re.compile(r"\bas\s+expected\b", re.I), "as expected"),
    (re.compile(r"\bnot\s+surprisingly\b", re.I), "not surprisingly"),
    (re.compile(r"\bthis\s+(?:finding\s+)?implies\b", re.I), "this implies"),
    (re.compile(r"\bthis\s+(?:finding\s+)?indicates\s+that\b", re.I), "this indicates that"),
    (re.compile(r"\bpossibly\s+(?:due\s+to|because|reflecting)\b", re.I), "possibly due to/because"),
    (re.compile(r"\bthis\s+(?:could|might)\s+be\s+(?:due\s+to|attributed\s+to|explained\s+by)\b", re.I), "could be due to"),
]


def check_interpretation_in_results(lines, sections):
    """A1: Flag interpretation language within Results section."""
    findings = []
    sec = get_section_lines(sections, "Results")
    if not sec:
        return findings

    start, end = sec
    for i in range(start - 1, min(end, len(lines))):
        line = lines[i]
        for pattern, label in _INTERPRETATION_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="A1",
                    check_name="interpretation-in-results",
                    severity="error",
                    section="Results",
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Interpretation phrase "{label}" found in Results',
                    suggestion="Move interpretation to Discussion; Results should state facts only",
                ))
                break  # one finding per line
    return findings


# --- A2: Empty adjectives ---

_EMPTY_ADJ_PATTERNS = [
    (re.compile(r"\binterestingly\b", re.I), "Interestingly"),
    (re.compile(r"\bimportantly\b", re.I), "Importantly"),
    (re.compile(r"\bit\s+is\s+(?:noteworthy|worth\s+noting|interesting|important)\s+that\b", re.I), "It is noteworthy that"),
    (re.compile(r"\ba\s+novel\s+finding\s+(?:was|is)\b", re.I), "A novel finding"),
    (re.compile(r"\bof\s+(?:particular\s+)?(?:note|interest)\b", re.I), "Of note/interest"),
    (re.compile(r"\bremarkably\b", re.I), "Remarkably"),
    (re.compile(r"\bstrikingly\b", re.I), "Strikingly"),
]


def check_empty_adjectives(lines, sections):
    """A2: Flag empty adjectives that tell rather than show."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label in _EMPTY_ADJ_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="A2",
                    check_name="empty-adjective",
                    severity="error",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Empty adjective "{label}" — show the contrast or surprise directly',
                    suggestion="Remove the adjective and let the finding speak for itself",
                ))
                break
    return findings


# --- A3: Hedge stacking ---

_HEDGE_WORDS = [
    r"\bmay\b", r"\bmight\b", r"\bcould\b", r"\bpossibly\b",
    r"\bpotentially\b", r"\bperhaps\b", r"\bsuggest(?:s|ed|ing)?\b",
    r"\btend(?:s|ed)?\s+to\b", r"\bappear(?:s|ed)?\s+to\b",
    r"\bseem(?:s|ed)?\s+to\b", r"\bit\s+is\s+possible\s+that\b",
    r"\blikely\b", r"\bprobably\b", r"\bpresumably\b",
]
_HEDGE_PATTERNS = [re.compile(p, re.I) for p in _HEDGE_WORDS]


def check_hedge_stacking(lines, sections):
    """A3: Flag sentences with 2+ hedge words."""
    findings = []
    # Work with raw lines — sentence splitting happens at a higher level
    # but for simplicity, check line-by-line (most sentences are on single lines)
    for i, line in enumerate(lines):
        matches = []
        for pattern in _HEDGE_PATTERNS:
            m = pattern.search(line)
            if m:
                matches.append(m.group())

        if len(matches) >= 2:
            findings.append(Finding(
                check_id="A3",
                check_name="hedge-stacking",
                severity="error",
                section=get_section_for_line(sections, i + 1),
                line_num=i + 1,
                line_text=line.strip(),
                matched_text=", ".join(matches),
                message=f"Hedge stacking: {len(matches)} hedges in one line ({', '.join(matches)})",
                suggestion="Keep one hedge per claim; remove the others",
            ))
    return findings


# --- A4: Textbook opening ---

_TEXTBOOK_PATTERNS = [
    (re.compile(r"\bis\s+(?:a|the)\s+(?:leading|major|common|significant|important)\s+cause\s+of\b", re.I),
     "is a leading/major cause of"),
    (re.compile(r"\bis\s+(?:a|the)\s+(?:major|significant|growing|serious)\s+(?:public\s+health|global|worldwide)\b", re.I),
     "is a major public health..."),
    (re.compile(r"\bis\s+one\s+of\s+the\s+(?:most|leading)\s+(?:common|prevalent|deadly)\b", re.I),
     "is one of the most common"),
    (re.compile(r"\bremains\s+(?:a|one\s+of\s+the)\s+(?:significant|major|important|key)\s+(?:challenge|problem|issue|concern)\b", re.I),
     "remains a significant challenge"),
    (re.compile(r"\baffects?\s+(?:millions|billions)\s+of\b", re.I),
     "affects millions of"),
    (re.compile(r"\b(?:is|are)\s+(?:a\s+)?(?:common|prevalent|frequent)\b.*\bworldwide\b", re.I),
     "is common... worldwide"),
]


def check_textbook_opening(lines, sections):
    """A4: Flag generic textbook-style opening sentences."""
    findings = []
    sec = get_section_lines(sections, "Introduction")

    # Check first 10 lines of Introduction, or first 10 lines of document
    if sec:
        start, end = sec
        check_range = range(start - 1, min(start + 9, end, len(lines)))
    else:
        check_range = range(min(10, len(lines)))

    for i in check_range:
        line = lines[i]
        for pattern, label in _TEXTBOOK_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="A4",
                    check_name="textbook-opening",
                    severity="error",
                    section="Introduction",
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Textbook opening: "{label}"',
                    suggestion="Open with a specific clinical dilemma or unsolved problem",
                ))
                break
    return findings


# --- A5: Weak ending ---

_WEAK_ENDING_PATTERNS = [
    (re.compile(r"\bfuture\s+(?:research|studies|investigations?)\s+(?:is|are)\s+(?:needed|required|warranted)\b", re.I),
     "future research is needed"),
    (re.compile(r"\bfurther\s+(?:research|studies|investigations?)\s+(?:is|are)\s+(?:needed|required|warranted)\b", re.I),
     "further research is warranted"),
    (re.compile(r"\bmore\s+(?:research|studies)\s+(?:is|are)\s+(?:needed|required)\b", re.I),
     "more research is needed"),
    (re.compile(r"\bfuture\s+(?:research|studies)\s+should\s+(?:investigate|explore|examine|address)\b", re.I),
     "future studies should investigate"),
]


def check_weak_ending(lines, sections):
    """A5: Flag weak 'future research needed' endings."""
    findings = []

    # Check last 20 lines of Discussion/Conclusion, or last 20 lines of document
    check_ranges = []
    for name in ("Conclusion", "Discussion"):
        sec = get_section_lines(sections, name)
        if sec:
            start, end = sec
            check_start = max(start - 1, end - 20)
            check_ranges.append(range(check_start, min(end, len(lines))))

    if not check_ranges:
        # Fallback: last 20 lines
        check_ranges.append(range(max(0, len(lines) - 20), len(lines)))

    for check_range in check_ranges:
        for i in check_range:
            line = lines[i]
            for pattern, label in _WEAK_ENDING_PATTERNS:
                m = pattern.search(line)
                if m:
                    findings.append(Finding(
                        check_id="A5",
                        check_name="weak-ending",
                        severity="error",
                        section=get_section_for_line(sections, i + 1),
                        line_num=i + 1,
                        line_text=line.strip(),
                        matched_text=m.group(),
                        message=f'Weak ending: "{label}"',
                        suggestion="State a concrete clinical implication and specific next step instead",
                    ))
                    break
    return findings


# --- A6: Vague aim ---

_VAGUE_AIM_PATTERNS = [
    (re.compile(r"\b(?:aim|aimed)\s+to\s+(?:explore|investigate|examine)\s+the\s+(?:relationship|association)\b", re.I),
     "aimed to explore the relationship"),
    (re.compile(r"\bpurpose\s+of\s+this\s+study\s+was\s+to\s+(?:explore|investigate|examine)\b", re.I),
     "the purpose was to explore"),
    (re.compile(r"\bwe\s+(?:aimed|sought)\s+to\s+(?:explore|investigate|examine)\s+(?:the\s+)?(?:role|impact|effect|association|relationship)\b", re.I),
     "we aimed to explore the role/impact"),
    (re.compile(r"\bthis\s+study\s+(?:aimed|sought)\s+to\s+(?:explore|investigate|examine)\b", re.I),
     "this study aimed to explore"),
]


def check_vague_aims(lines, sections):
    """A6: Flag vague study aim statements."""
    findings = []
    sec = get_section_lines(sections, "Introduction")

    # Check last 15 lines of Introduction, or last 15 lines of first quarter
    if sec:
        start, end = sec
        check_start = max(start - 1, end - 15)
        check_range = range(check_start, min(end, len(lines)))
    else:
        quarter = len(lines) // 4
        check_range = range(max(0, quarter - 15), quarter)

    for i in check_range:
        line = lines[i]
        for pattern, label in _VAGUE_AIM_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="A6",
                    check_name="vague-aim",
                    severity="error",
                    section="Introduction",
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Vague aim: "{label}"',
                    suggestion="State your exact data source, method, and outcome",
                ))
                break
    return findings


# --- A7: P-value without CI ---

_PVALUE_PATTERN = re.compile(r"p\s*[<>=]\s*0\.\d+|p\s*<\s*0\.001", re.I)
_CI_PATTERN = re.compile(r"\d+%?\s*CI|confidence\s+interval", re.I)
_TABLE_REF = re.compile(r"\bTable\s+1\b|\bbaseline\b|\bdemographic\b", re.I)


def check_pvalue_without_ci(lines, sections):
    """A7: Flag p-values not accompanied by confidence intervals."""
    findings = []
    sec = get_section_lines(sections, "Results")
    if sec:
        start, end = sec
        check_range = range(start - 1, min(end, len(lines)))
    else:
        check_range = range(len(lines))

    for i in check_range:
        line = lines[i]
        p_matches = list(_PVALUE_PATTERN.finditer(line))
        if not p_matches:
            continue

        # Skip if this line references Table 1 / baseline (descriptive stats)
        if _TABLE_REF.search(line):
            continue

        # Check if CI appears nearby (within same line or next line)
        context = line
        if i + 1 < len(lines):
            context += " " + lines[i + 1]

        if not _CI_PATTERN.search(context):
            findings.append(Finding(
                check_id="A7",
                check_name="pvalue-without-ci",
                severity="error",
                section=get_section_for_line(sections, i + 1),
                line_num=i + 1,
                line_text=line.strip(),
                matched_text=p_matches[0].group(),
                message="P-value without confidence interval",
                suggestion="Always pair effect estimates with 95% CI; p-value alone lacks magnitude info",
            ))
    return findings


# --- A8: Citation stacking ---

_CITATION_VERB = re.compile(
    r"[A-Z][a-z]+(?:\s+et\s+al\.?)?\s*\(\d{4}\)\s+"
    r"(?:found|showed|reported|demonstrated|observed|studied|investigated|examined|analyzed|concluded)\b",
    re.I,
)


def check_citation_stacking(lines, sections):
    """A8: Flag 3+ consecutive citation-verb sentences."""
    findings = []
    sec = get_section_lines(sections, "Introduction")
    if sec:
        start, end = sec
        check_range = range(start - 1, min(end, len(lines)))
    else:
        check_range = range(len(lines))

    consecutive = []  # list of (line_index, matched_text)

    for i in check_range:
        line = lines[i].strip()
        if not line:
            if len(consecutive) >= 3:
                _emit_stacking_finding(findings, lines, sections, consecutive)
            consecutive = []
            continue

        m = _CITATION_VERB.search(line)
        if m:
            consecutive.append((i, m.group()))
        else:
            if len(consecutive) >= 3:
                _emit_stacking_finding(findings, lines, sections, consecutive)
            consecutive = []

    # Handle end of range
    if len(consecutive) >= 3:
        _emit_stacking_finding(findings, lines, sections, consecutive)

    return findings


def _emit_stacking_finding(findings, lines, sections, consecutive):
    """Create a finding for a run of stacked citations."""
    first_line = consecutive[0][0]
    findings.append(Finding(
        check_id="A8",
        check_name="citation-stacking",
        severity="error",
        section=get_section_for_line(sections, first_line + 1),
        line_num=first_line + 1,
        line_text=lines[first_line].strip(),
        matched_text=f"{len(consecutive)} consecutive Author (year) verb sentences",
        message=f"Citation stacking: {len(consecutive)} consecutive 'Author (year) found/showed' sentences",
        suggestion="Synthesize into a logical chain with inline citations supporting each step",
    ))


# --- Registry ---

ALL_TIER_A_CHECKS = [
    check_interpretation_in_results,
    check_empty_adjectives,
    check_hedge_stacking,
    check_textbook_opening,
    check_weak_ending,
    check_vague_aims,
    check_pvalue_without_ci,
    check_citation_stacking,
]
