"""Tier C checks: style suggestions (lower confidence).

C1: Nominalization + weak verb
C2: Wordy filler phrases
C3: Redundant modifiers
C4: Self-referential filler
C5: Sentence sprawl
C6: Double negatives
C7: Missing reporting guideline
C8: P-value before effect estimate
C9: Monotonous results pattern
"""

import re
from .models import Finding
from .detector import get_section_for_line, get_section_lines
from .tokenizer import split_sentences, sentence_word_count
from .patterns import PVALUE, EFFECT_ESTIMATE

# --- C1: Nominalization + weak verb ---

_NOMINALIZATION_PATTERN = re.compile(
    r"\b(?:perform|performs|performed|performing|"
    r"conduct|conducts|conducted|conducting|"
    r"carry\s+out|carries\s+out|carried\s+out|carrying\s+out)\s+"
    r"(?:a|an|the)\s+"
    r"\w+(?:tion|ment|sis|ance|ence)\b",
    re.I,
)


def check_nominalization(lines, sections):
    """C1: Flag weak verb + nominalization patterns."""
    findings = []
    for i, line in enumerate(lines):
        m = _NOMINALIZATION_PATTERN.search(line)
        if m:
            findings.append(Finding(
                check_id="C1",
                check_name="nominalization",
                severity="suggestion",
                section=get_section_for_line(sections, i + 1),
                line_num=i + 1,
                line_text=line.strip(),
                matched_text=m.group(),
                message=f'Nominalization: "{m.group().strip()}"',
                suggestion="Replace with the verb form: 'conducted an analysis' -> 'analyzed'",
            ))
    return findings


# --- C2: Wordy filler phrases ---

_WORDY_PHRASES = [
    (re.compile(r"\bin order to\b", re.I), "in order to", "to"),
    (re.compile(r"\bdue to the fact that\b", re.I), "due to the fact that", "because"),
    (re.compile(r"\bit should be noted that\b", re.I), "it should be noted that", "(delete)"),
    (re.compile(r"\bat the present time\b", re.I), "at the present time", "now/currently"),
    (re.compile(r"\bat this point in time\b", re.I), "at this point in time", "now/currently"),
    (re.compile(r"\bin the event that\b", re.I), "in the event that", "if"),
    (re.compile(r"\ba large number of\b", re.I), "a large number of", "many"),
    (re.compile(r"\bin the process of\b", re.I), "in the process of", "(delete or 'while')"),
    (re.compile(r"\bhas the ability to\b", re.I), "has the ability to", "can"),
    (re.compile(r"\bon the basis of\b", re.I), "on the basis of", "based on"),
    (re.compile(r"\bfor the purpose of\b", re.I), "for the purpose of", "for/to"),
    (re.compile(r"\bin spite of the fact that\b", re.I), "in spite of the fact that", "although"),
    (re.compile(r"\bit is worth noting that\b", re.I), "it is worth noting that", "(delete)"),
]


def check_wordy_phrases(lines, sections):
    """C2: Flag wordy filler phrases with concise alternatives."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label, replacement in _WORDY_PHRASES:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="C2",
                    check_name="wordy-phrase",
                    severity="suggestion",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Wordy phrase: "{label}"',
                    suggestion=f"Replace with: {replacement}",
                ))
                break  # one finding per line
    return findings


# --- C3: Redundant modifiers ---

_REDUNDANT_PAIRS = [
    (re.compile(r"\bcompletely\s+(?:eliminate|eliminates|eliminated|destroy|destroys|destroyed)\b", re.I),
     "completely eliminate/destroy", "eliminate/destroy"),
    (re.compile(r"\bpast\s+(?:history|experience)\b", re.I),
     "past history/experience", "history/experience"),
    (re.compile(r"\bend\s+result\b", re.I),
     "end result", "result"),
    (re.compile(r"\bclose\s+proximity\b", re.I),
     "close proximity", "proximity"),
    (re.compile(r"\bbasic\s+fundamentals?\b", re.I),
     "basic fundamentals", "fundamentals"),
    (re.compile(r"\badvance\s+planning\b", re.I),
     "advance planning", "planning"),
    (re.compile(r"\bfinal\s+outcome\b", re.I),
     "final outcome", "outcome"),
    (re.compile(r"\bmutual\s+cooperation\b", re.I),
     "mutual cooperation", "cooperation"),
    (re.compile(r"\bbrief\s+summary\b", re.I),
     "brief summary", "summary"),
    (re.compile(r"\btrue\s+fact\b", re.I),
     "true fact", "fact"),
]


def check_redundant_modifiers(lines, sections):
    """C3: Flag redundant modifier + noun pairs."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label, replacement in _REDUNDANT_PAIRS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="C3",
                    check_name="redundant-modifier",
                    severity="suggestion",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Redundant modifier: "{label}"',
                    suggestion=f"Replace with: {replacement}",
                ))
                break  # one finding per line
    return findings


# --- C4: Self-referential filler ---

_SELF_REF_PATTERNS = [
    re.compile(r"\bin this study\b", re.I),
    re.compile(r"\bthe present study\b", re.I),
    re.compile(r"\bour study\b", re.I),
    re.compile(r"\bthe current study\b", re.I),
    re.compile(r"\bthe current investigation\b", re.I),
    re.compile(r"\bin the present study\b", re.I),
    re.compile(r"\bin our study\b", re.I),
]


def check_self_referential_filler(lines, sections):
    """C4: Flag excessive self-referential phrases (3+ total)."""
    findings = []
    occurrences = []  # (line_index, matched_text)

    for i, line in enumerate(lines):
        for pattern in _SELF_REF_PATTERNS:
            for m in pattern.finditer(line):
                occurrences.append((i, m.group()))

    if len(occurrences) >= 3:
        # Report on the first occurrence, noting total count
        first_line_idx, first_match = occurrences[0]
        findings.append(Finding(
            check_id="C4",
            check_name="self-referential-filler",
            severity="suggestion",
            section=get_section_for_line(sections, first_line_idx + 1),
            line_num=first_line_idx + 1,
            line_text=lines[first_line_idx].strip(),
            matched_text=first_match,
            message=f"Self-referential filler: {len(occurrences)} occurrences of 'in this/our/the present study'",
            suggestion="Reduce to 1-2 instances; rephrase others with direct statements",
        ))

    return findings


# --- C5: Sentence sprawl ---

def check_sentence_sprawl(lines, sections):
    """C5: Flag individual sentences exceeding 50 words."""
    findings = []
    text = "\n".join(lines)
    sentences = split_sentences(text)

    for sent in sentences:
        wc = sentence_word_count(sent)
        if wc > 50:
            # Find the line where this sentence starts
            key = sent[:40].strip()
            line_num = 1
            for i, line in enumerate(lines):
                if key in line:
                    line_num = i + 1
                    break

            snippet = sent[:80] + ("..." if len(sent) > 80 else "")
            findings.append(Finding(
                check_id="C5",
                check_name="sentence-sprawl",
                severity="suggestion",
                section=get_section_for_line(sections, line_num),
                line_num=line_num,
                line_text=snippet,
                matched_text=f"{wc} words",
                message=f"Sentence sprawl: {wc} words (>50 word threshold)",
                suggestion="Break into 2-3 shorter sentences for readability",
            ))

    return findings


# --- C6: Double negatives ---

_DOUBLE_NEGATIVE_PATTERNS = [
    (re.compile(r"\bnot\s+un\w+\b", re.I), "not un-"),
    (re.compile(r"\bnot\s+in(?:significant|frequent|considerable|consequential)\b", re.I), "not in-"),
    (re.compile(r"\bcannot\s+be\s+(?:excluded|ruled\s+out)\b", re.I), "cannot be excluded/ruled out"),
    (re.compile(r"\bnot\s+without\b", re.I), "not without"),
]


def check_double_negatives(lines, sections):
    """C6: Flag double negative constructions."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label in _DOUBLE_NEGATIVE_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="C6",
                    check_name="double-negative",
                    severity="suggestion",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Double negative: "{m.group()}"',
                    suggestion=f"Use a direct positive form: '{label}' -> state the affirmative",
                ))
                break  # one finding per line
    return findings


# --- C7: Missing reporting guideline ---

_GUIDELINES = re.compile(
    r"\b(?:STROBE|CONSORT|PRISMA|STARD|TRIPOD|CARE|COREQ|"
    r"SPIRIT|ARRIVE|CHEERS|MOOSE|QUOROM|RECORD|SQUIRE)\b"
)


def check_missing_reporting_guideline(lines, sections):
    """C7: Flag if no reporting guideline (STROBE/CONSORT/etc.) is mentioned."""
    findings = []

    # Check Methods first, then whole document
    sec = get_section_lines(sections, "Methods")
    if sec:
        start, end = sec
        text = "\n".join(lines[start - 1:min(end, len(lines))])
    else:
        text = "\n".join(lines)

    if not _GUIDELINES.search(text):
        # Determine line to report on
        if sec:
            line_num = sec[0]
        else:
            line_num = 1

        findings.append(Finding(
            check_id="C7",
            check_name="missing-reporting-guideline",
            severity="suggestion",
            section="Methods" if sec else "Overall",
            line_num=line_num,
            line_text=lines[line_num - 1].strip() if line_num <= len(lines) else "",
            matched_text="(none found)",
            message="No reporting guideline mentioned (STROBE, CONSORT, PRISMA, etc.)",
            suggestion="Cite the applicable reporting guideline and include the checklist as supplementary material",
        ))

    return findings


# --- C8: P-value before effect estimate ---


def check_pvalue_before_effect(lines, sections):
    """C8: Flag sentences where p-value precedes the effect estimate."""
    findings = []
    sec = get_section_lines(sections, "Results")
    if sec:
        start, end = sec
        check_range = range(start - 1, min(end, len(lines)))
    else:
        check_range = range(len(lines))

    for i in check_range:
        line = lines[i]
        p_match = PVALUE.search(line)
        e_match = EFFECT_ESTIMATE.search(line)

        if p_match and e_match and p_match.start() < e_match.start():
            findings.append(Finding(
                check_id="C8",
                check_name="pvalue-before-effect",
                severity="suggestion",
                section=get_section_for_line(sections, i + 1),
                line_num=i + 1,
                line_text=line.strip(),
                matched_text=f"{p_match.group()} before {e_match.group()}",
                message="P-value appears before effect estimate",
                suggestion="Lead with the effect estimate (HR, OR, RR), then the CI, then the p-value",
            ))

    return findings


# --- C9: Monotonous results pattern ---

_RESULTS_TEMPLATE = re.compile(
    r"\b(?:group|cohort|arm|patients?)\b.*?\bp\s*[<>=]",
    re.I,
)


def check_monotonous_results(lines, sections):
    """C9: Flag 3+ consecutive lines matching the same results template."""
    findings = []
    sec = get_section_lines(sections, "Results")
    if sec:
        start, end = sec
        check_range = range(start - 1, min(end, len(lines)))
    else:
        check_range = range(len(lines))

    consecutive = 0
    run_start = None

    for i in check_range:
        line = lines[i].strip()
        if not line:
            if consecutive >= 3:
                findings.append(Finding(
                    check_id="C9",
                    check_name="monotonous-results",
                    severity="suggestion",
                    section=get_section_for_line(sections, run_start + 1),
                    line_num=run_start + 1,
                    line_text=lines[run_start].strip(),
                    matched_text=f"{consecutive} consecutive 'Group... p<...' lines",
                    message=f"Monotonous results reporting: {consecutive} consecutive lines with same pattern",
                    suggestion="Vary sentence structure — lead with the clinical finding, not the group comparison",
                ))
            consecutive = 0
            run_start = None
            continue

        if _RESULTS_TEMPLATE.search(line):
            if consecutive == 0:
                run_start = i
            consecutive += 1
        else:
            if consecutive >= 3:
                findings.append(Finding(
                    check_id="C9",
                    check_name="monotonous-results",
                    severity="suggestion",
                    section=get_section_for_line(sections, run_start + 1),
                    line_num=run_start + 1,
                    line_text=lines[run_start].strip(),
                    matched_text=f"{consecutive} consecutive 'Group... p<...' lines",
                    message=f"Monotonous results reporting: {consecutive} consecutive lines with same pattern",
                    suggestion="Vary sentence structure — lead with the clinical finding, not the group comparison",
                ))
            consecutive = 0
            run_start = None

    # Handle end of range
    if consecutive >= 3:
        findings.append(Finding(
            check_id="C9",
            check_name="monotonous-results",
            severity="suggestion",
            section=get_section_for_line(sections, run_start + 1),
            line_num=run_start + 1,
            line_text=lines[run_start].strip(),
            matched_text=f"{consecutive} consecutive 'Group... p<...' lines",
            message=f"Monotonous results reporting: {consecutive} consecutive lines with same pattern",
            suggestion="Vary sentence structure — lead with the clinical finding, not the group comparison",
        ))

    return findings


# --- Registry ---

ALL_TIER_C_CHECKS = [
    check_nominalization,
    check_wordy_phrases,
    check_redundant_modifiers,
    check_self_referential_filler,
    check_sentence_sprawl,
    check_double_negatives,
    check_missing_reporting_guideline,
    check_pvalue_before_effect,
    check_monotonous_results,
]
