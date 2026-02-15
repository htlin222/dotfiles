"""Tier B checks: warning-level detection.

B1: Passive voice ratio
B2: Sentence monotony
B3: Table/figure narration
B4: Statistical Discussion opener
B5: Mechanical transitions
B6: Overclaiming language
B7: Anthropomorphism (inanimate agency)
B8: Informal/colloquial language
B9: British/American English mixing
B10: Citation stacking in Discussion
B11: Statistical conclusion
"""

import re
from .models import Finding
from .detector import get_section_for_line, get_section_lines
from .tokenizer import split_sentences, sentence_word_count
from .patterns import CITATION_VERB, STAT_NOTATION

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

        if STAT_NOTATION.search(line):
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


# --- B7: Anthropomorphism (inanimate agency) ---

_ANTHROPOMORPHISM_PATTERNS = [
    (re.compile(r"\bthis\s+study\s+(?:found|showed|demonstrated|revealed|concluded|proved|confirmed|discovered|observed|established|believed|argued)\b", re.I),
     "this study found/showed"),
    (re.compile(r"\bthe\s+data\s+(?:suggest|show|demonstrate|reveal|argue|indicate|confirm|support|prove)\b", re.I),
     "the data suggest/argue"),
    (re.compile(r"\bthe\s+results?\s+(?:suggest|show|demonstrate|reveal|argue|indicate|confirm|support|prove|concluded)\b", re.I),
     "the results suggest/show"),
    (re.compile(r"\bthe\s+analysis\s+(?:found|showed|demonstrated|revealed|concluded|confirmed|discovered)\b", re.I),
     "the analysis found/showed"),
    (re.compile(r"\bthe\s+findings?\s+(?:suggest|show|demonstrate|reveal|argue|indicate|confirm|support)\b", re.I),
     "the findings suggest"),
    (re.compile(r"\bthe\s+evidence\s+(?:suggests?|shows?|demonstrates?|argues?|proves?|confirms?)\b", re.I),
     "the evidence suggests"),
    (re.compile(r"\bthis\s+paper\s+(?:argues?|shows?|demonstrates?|proves?|presents?|describes?|reports?)\b", re.I),
     "this paper argues/shows"),
    (re.compile(r"\bthe\s+literature\s+(?:suggests?|shows?|demonstrates?|argues?|supports?|confirms?)\b", re.I),
     "the literature suggests"),
]


def check_anthropomorphism(lines, sections):
    """B7: Flag inanimate subjects given human agency."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label in _ANTHROPOMORPHISM_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="B7",
                    check_name="anthropomorphism",
                    severity="warning",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Anthropomorphism: "{label}"',
                    suggestion="Use researchers as subject: 'We found...' or 'The analysis revealed...' -> 'Using [method], we found...'",
                ))
                break
    return findings


# --- B8: Informal/colloquial language ---

_INFORMAL_PATTERNS = [
    (re.compile(r"\ba\s+lot\s+of\b", re.I), "a lot of", "many/numerous"),
    (re.compile(r"\blots\s+of\b", re.I), "lots of", "many/numerous"),
    (re.compile(r"\bpretty\s+(?:much|significant|clear|good|bad|strong|weak|high|low|big|small)\b", re.I),
     "pretty [adj]", "quite/rather or remove"),
    (re.compile(r"\bkind\s+of\b", re.I), "kind of", "somewhat/rather"),
    (re.compile(r"\bsort\s+of\b", re.I), "sort of", "somewhat/rather"),
    (re.compile(r"\b(?:get|got|getting)\s+(?:worse|better|rid)\b", re.I),
     "get worse/better", "worsened/improved/eliminated"),
    (re.compile(r"\breally\s+(?:significant|important|high|low|large|small)\b", re.I),
     "really [adj]", "remove intensifier or use precise language"),
    (re.compile(r"\bbasically\b", re.I), "basically", "(remove)"),
    (re.compile(r"\bstuff\b", re.I), "stuff", "materials/components/factors"),
    (re.compile(r"\bokay\b", re.I), "okay", "acceptable/satisfactory"),
    (re.compile(r"\band\s+so\s+on\b", re.I), "and so on", "etc. or list explicitly"),
    (re.compile(r"\band\s+so\s+forth\b", re.I), "and so forth", "etc. or list explicitly"),
    (re.compile(r"\bnowadays\b", re.I), "nowadays", "currently/at present"),
]


def check_informal_language(lines, sections):
    """B8: Flag informal or colloquial language in formal prose."""
    findings = []
    for i, line in enumerate(lines):
        for pattern, label, replacement in _INFORMAL_PATTERNS:
            m = pattern.search(line)
            if m:
                findings.append(Finding(
                    check_id="B8",
                    check_name="informal-language",
                    severity="warning",
                    section=get_section_for_line(sections, i + 1),
                    line_num=i + 1,
                    line_text=line.strip(),
                    matched_text=m.group(),
                    message=f'Informal language: "{label}"',
                    suggestion=f"Replace with: {replacement}",
                ))
                break
    return findings


# --- B9: British/American English mixing ---

_BRITISH_MARKERS = re.compile(
    r"\b\w+(?:ise|ised|ising)\b|"
    r"\b\w*(?:colour|behaviour|favour|honour|labour|neighbour|tumour|humour)\b|"
    r"\b(?:analyse|paralyse|catalyse|dialyse)\b|"
    r"\b(?:anaemia|haemoglobin|oedema|oestrogen|leukaemia|diarrhoea|haemorrhage|foetus|faeces|paediatric|gynaecology|orthopaedic)\b|"
    r"\b(?:centre|fibre|metre|litre|theatre)\b|"
    r"\b(?:defence|offence|licence|practise)\b|"
    r"\bgrey\b",
    re.I,
)

_AMERICAN_MARKERS = re.compile(
    r"\b\w+(?:ize|ized|izing)\b|"
    r"\b\w*(?:color|behavior|favor|honor|labor|neighbor|tumor|humor)\b|"
    r"\b(?:analyze|paralyze|catalyze|dialyze)\b|"
    r"\b(?:anemia|hemoglobin|edema|estrogen|leukemia|diarrhea|hemorrhage|fetus|feces|pediatric|gynecology|orthopedic)\b|"
    r"\b(?:center|fiber|meter|liter|theater)\b|"
    r"\b(?:defense|offense|license|practice)\b|"
    r"\bgray\b",
    re.I,
)

# Words that legitimately end in -ize/-ise in both dialects
_DIALECT_EXCEPTIONS = {"size", "sized", "sizing", "prize", "prized", "prizing",
                       "seize", "seized", "seizing", "advise", "advised", "advising",
                       "exercise", "exercised", "exercising", "comprise", "comprised",
                       "comprising", "supervise", "supervised", "supervising",
                       "otherwise", "rise", "risen", "wise", "sunrise", "demise",
                       "promise", "promised", "promising", "surprise", "surprised"}


def check_dialect_mixing(lines, sections):
    """B9: Flag mixing of British and American English spelling."""
    findings = []
    text = "\n".join(lines)

    british_hits = []
    american_hits = []

    for m in _BRITISH_MARKERS.finditer(text):
        word = m.group().lower()
        if word not in _DIALECT_EXCEPTIONS:
            british_hits.append(m.group())

    for m in _AMERICAN_MARKERS.finditer(text):
        word = m.group().lower()
        if word not in _DIALECT_EXCEPTIONS:
            american_hits.append(m.group())

    if british_hits and american_hits:
        # Find first line with a minority-dialect word
        minority = british_hits if len(british_hits) < len(american_hits) else american_hits
        majority_label = "American" if len(british_hits) < len(american_hits) else "British"
        minority_label = "British" if majority_label == "American" else "American"

        # Find line number of first minority hit
        first_word = minority[0]
        line_num = 1
        for i, line in enumerate(lines):
            if first_word in line:
                line_num = i + 1
                break

        br_sample = ", ".join(set(british_hits[:3]))
        am_sample = ", ".join(set(american_hits[:3]))

        findings.append(Finding(
            check_id="B9",
            check_name="dialect-mixing",
            severity="warning",
            section=get_section_for_line(sections, line_num),
            line_num=line_num,
            line_text=lines[line_num - 1].strip() if line_num <= len(lines) else "",
            matched_text=f"British: {br_sample}; American: {am_sample}",
            message=f"Mixed British ({len(british_hits)} words: {br_sample}) and American ({len(american_hits)} words: {am_sample}) spelling",
            suggestion=f"Manuscript appears predominantly {majority_label}; standardize {minority_label} spellings ({', '.join(set(minority[:3]))})",
        ))

    return findings


# --- B10: Citation stacking in Discussion ---


def check_citation_stacking_discussion(lines, sections):
    """B10: Flag 3+ consecutive citation-verb sentences in Discussion."""
    findings = []
    sec = get_section_lines(sections, "Discussion")
    if not sec:
        return findings

    start, end = sec
    check_range = range(start - 1, min(end, len(lines)))

    consecutive = []  # list of (line_index, matched_text)

    for i in check_range:
        line = lines[i].strip()
        if not line:
            if len(consecutive) >= 3:
                _emit_discussion_stacking(findings, lines, sections, consecutive)
            consecutive = []
            continue

        m = CITATION_VERB.search(line)
        if m:
            consecutive.append((i, m.group()))
        else:
            if len(consecutive) >= 3:
                _emit_discussion_stacking(findings, lines, sections, consecutive)
            consecutive = []

    if len(consecutive) >= 3:
        _emit_discussion_stacking(findings, lines, sections, consecutive)

    return findings


def _emit_discussion_stacking(findings, lines, sections, consecutive):
    """Create a finding for stacked citations in Discussion."""
    first_line = consecutive[0][0]
    findings.append(Finding(
        check_id="B10",
        check_name="citation-stacking-discussion",
        severity="warning",
        section="Discussion",
        line_num=first_line + 1,
        line_text=lines[first_line].strip(),
        matched_text=f"{len(consecutive)} consecutive Author (year) verb sentences",
        message=f"Citation stacking in Discussion: {len(consecutive)} consecutive 'Author (year) found/showed' sentences",
        suggestion="Synthesize sources into a coherent argument; don't just list what others found",
    ))


# --- B11: Statistical conclusion ---


def check_statistical_conclusion(lines, sections):
    """B11: Flag conclusion ending with statistics instead of clinical implication."""
    findings = []

    # Check last 15 non-empty lines of Discussion/Conclusion
    check_ranges = []
    for name in ("Conclusion", "Discussion"):
        sec = get_section_lines(sections, name)
        if sec:
            start, end = sec
            check_start = max(start - 1, end - 15)
            check_ranges.append((name, range(check_start, min(end, len(lines)))))

    if not check_ranges:
        # Fallback: last 15 lines of document
        check_ranges.append(("Unknown", range(max(0, len(lines) - 15), len(lines))))

    for sec_name, check_range in check_ranges:
        # Find last non-empty line in range that contains stats
        last_stat_line = None
        last_stat_idx = None
        for i in check_range:
            line = lines[i].strip()
            if not line:
                continue
            if STAT_NOTATION.search(line):
                last_stat_line = line
                last_stat_idx = i

        # Only flag if the stat appears in the final 3 non-empty lines
        if last_stat_idx is not None:
            trailing_nonempty = 0
            for i in reversed(list(check_range)):
                if lines[i].strip():
                    trailing_nonempty += 1
                    if i == last_stat_idx:
                        # Found stat in final lines
                        if trailing_nonempty <= 3:
                            findings.append(Finding(
                                check_id="B11",
                                check_name="statistical-conclusion",
                                severity="warning",
                                section=sec_name,
                                line_num=last_stat_idx + 1,
                                line_text=last_stat_line[:80] + ("..." if len(last_stat_line) > 80 else ""),
                                matched_text="statistical values in conclusion",
                                message="Conclusion ends with statistics instead of clinical implication",
                                suggestion="End with a concrete clinical takeaway, not numbers",
                            ))
                        break
                    if trailing_nonempty > 3:
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
    check_anthropomorphism,
    check_informal_language,
    check_dialect_mixing,
    check_citation_stacking_discussion,
    check_statistical_conclusion,
]
