"""Sentence tokenization for manuscript text.

Simple regex-based splitter with abbreviation handling for scientific text.
"""

import re

# Common abbreviations that end with a period but don't end a sentence
ABBREVIATIONS = {
    "et al", "fig", "figs", "eq", "eqs", "ref", "refs",
    "dr", "mr", "mrs", "ms", "prof", "sr", "jr",
    "vs", "approx", "dept", "div",
    "no", "nos", "vol", "vols", "ed", "eds",
    "jan", "feb", "mar", "apr", "jun", "jul", "aug", "sep", "oct", "nov", "dec",
    "inc", "ltd", "co", "corp",
    "i.e", "e.g", "cf", "viz",
}

# Build pattern to protect abbreviations
_ABBREV_PATTERN = re.compile(
    r"\b(" + "|".join(re.escape(a) for a in sorted(ABBREVIATIONS, key=len, reverse=True)) + r")\.\s",
    re.IGNORECASE,
)

# Sentence boundary: period/question/exclamation followed by space + capital letter
_SENT_BOUNDARY = re.compile(r"(?<=[.!?])\s+(?=[A-Z])")

# Also split on period followed by newline
_SENT_NEWLINE = re.compile(r"(?<=[.!?])\s*\n")


def split_sentences(text: str) -> list[str]:
    """Split text into sentences, handling scientific abbreviations.

    Returns list of sentence strings (whitespace-normalized).
    """
    # Protect abbreviations by replacing their period with a placeholder
    protected = text
    placeholder = "\x00"
    for m in reversed(list(_ABBREV_PATTERN.finditer(protected))):
        start, end = m.span()
        # Replace the period after the abbreviation
        period_pos = m.group().rindex(".")
        abs_pos = start + period_pos
        protected = protected[:abs_pos] + placeholder + protected[abs_pos + 1:]

    # Split on sentence boundaries
    parts = _SENT_BOUNDARY.split(protected)

    # Further split on newline boundaries
    sentences = []
    for part in parts:
        sub_parts = _SENT_NEWLINE.split(part)
        sentences.extend(sub_parts)

    # Restore placeholders and clean up
    result = []
    for sent in sentences:
        restored = sent.replace(placeholder, ".")
        cleaned = " ".join(restored.split()).strip()
        if cleaned and len(cleaned.split()) >= 3:  # skip fragments
            result.append(cleaned)

    return result


def word_count(text: str) -> int:
    """Count words in text."""
    return len(re.findall(r"\b\w+\b", text))


def sentence_word_count(sentence: str) -> int:
    """Count words in a single sentence."""
    return len(re.findall(r"\b\w+\b", sentence))
