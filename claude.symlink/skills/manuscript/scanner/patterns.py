"""Centralized regex patterns reused across check tiers.

Avoids duplication of common statistical and citation patterns.
"""

import re

PVALUE = re.compile(r"p\s*[<>=]\s*0\.\d+|p\s*<\s*0\.001", re.I)
CI = re.compile(r"\d+%?\s*CI|confidence\s+interval", re.I)
EFFECT_ESTIMATE = re.compile(r"\b(?:HR|OR|RR|AOR|aHR|aOR|RD|ARR|NNT)\s*[=:]\s*\d", re.I)
STAT_NOTATION = re.compile(
    r"(?:HR|OR|RR|AOR|aHR|aOR)\s*[=:]\s*\d|"
    r"\bp\s*[<>=]\s*0\.\d|"
    r"\d+%?\s*CI\s*[=:,]?\s*\d|"
    r"95%\s*(?:CI|confidence)",
    re.I,
)
CITATION_VERB = re.compile(
    r"[A-Z][a-z]+(?:\s+et\s+al\.?)?\s*\(\d{4}\)\s+"
    r"(?:found|showed|reported|demonstrated|observed|studied|investigated|examined|analyzed|concluded)\b",
    re.I,
)
