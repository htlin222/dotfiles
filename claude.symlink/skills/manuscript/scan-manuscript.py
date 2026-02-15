#!/usr/bin/env python3
"""
Scan medical manuscripts for common anti-patterns.

Detects section-specific issues (interpretation in Results, textbook openings,
vague aims, hedge stacking, etc.) and produces a scored report.

Usage:
    python3 scan-manuscript.py <file>
    cat manuscript.md | python3 scan-manuscript.py
    python3 scan-manuscript.py --json <file>
    python3 scan-manuscript.py --severity error <file>
    python3 scan-manuscript.py --section Results <file>
    python3 scan-manuscript.py --checklist <file>
    python3 scan-manuscript.py --list-checks
"""

import sys
import argparse
from pathlib import Path

# Add the skill directory to path so scanner package is importable
sys.path.insert(0, str(Path(__file__).resolve().parent))

from scanner import scan
from scanner.formatter import format_report, format_json, format_checklist

# Check descriptions for --list-checks
CHECK_DESCRIPTIONS = {
    "A1": ("error", "interpretation-in-results", "Interpretation language in Results section (suggests, may be because)"),
    "A2": ("error", "empty-adjective", "Empty adjectives that tell rather than show (interestingly, importantly)"),
    "A3": ("error", "hedge-stacking", "Multiple hedge words in a single sentence"),
    "A4": ("error", "textbook-opening", "Generic textbook-style opening (X is a leading cause of death)"),
    "A5": ("error", "weak-ending", "Weak conclusions (future research is needed)"),
    "A6": ("error", "vague-aim", "Vague study aim (aimed to explore the relationship)"),
    "A7": ("error", "pvalue-without-ci", "P-value reported without confidence interval"),
    "A8": ("error", "citation-stacking", "3+ consecutive Author (year) found/showed sentences"),
    "A9": ("error", "contraction", "Contractions in formal prose (don't, can't, it's)"),
    "A10": ("error", "duplicate-word", "Duplicate adjacent words (the the, of of)"),
    "A11": ("error", "tautological-acronym", "Tautological acronyms (HIV virus, PCR reaction, BMI index)"),
    "B1": ("warning", "passive-voice-ratio", "Excessive passive voice in a section"),
    "B2": ("warning", "sentence-monotony", "Low sentence length variety or consecutive long sentences"),
    "B3": ("warning", "table-figure-narration", "Table/figure narration (Table X shows) instead of referencing by finding"),
    "B4": ("warning", "statistical-discussion-opener", "Discussion opens with statistical results instead of conceptual significance"),
    "B5": ("warning", "mechanical-transitions", "Cluster of Furthermore/Moreover/Additionally transitions"),
    "B6": ("warning", "overclaiming", "Overclaiming language (revolutionize, first to demonstrate, conclusively proves)"),
    "B7": ("warning", "anthropomorphism", "Inanimate agency (this study found, the data argue)"),
    "B8": ("warning", "informal-language", "Informal/colloquial language (a lot of, pretty significant, basically)"),
    "B9": ("warning", "dialect-mixing", "Mixed British and American English spelling in same document"),
    "C1": ("suggestion", "nominalization", "Weak verb + nominalization (conducted an analysis -> analyzed)"),
    "C2": ("suggestion", "wordy-phrase", "Wordy filler phrases (in order to -> to, due to the fact that -> because)"),
    "C3": ("suggestion", "redundant-modifier", "Redundant modifiers (completely eliminate -> eliminate, end result -> result)"),
    "C4": ("suggestion", "self-referential-filler", "Excessive 'in this/our/the present study' (3+ occurrences)"),
    "C5": ("suggestion", "sentence-sprawl", "Sentences exceeding 50 words"),
    "C6": ("suggestion", "double-negative", "Double negative constructions (not uncommon, cannot be excluded)"),
    "B10": ("warning", "citation-stacking-discussion", "3+ consecutive Author (year) found/showed sentences in Discussion"),
    "B11": ("warning", "statistical-conclusion", "Conclusion ends with statistics instead of clinical implication"),
    "C7": ("suggestion", "missing-reporting-guideline", "No reporting guideline mentioned (STROBE, CONSORT, PRISMA, etc.)"),
    "C8": ("suggestion", "pvalue-before-effect", "P-value appears before effect estimate in Results"),
    "C9": ("suggestion", "monotonous-results", "3+ consecutive lines with same Group... p<... reporting pattern"),
}


def main():
    parser = argparse.ArgumentParser(
        description="Scan medical manuscripts for common anti-patterns"
    )
    parser.add_argument("file", nargs="?", help="Manuscript file to scan (or use stdin)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument("--quiet", action="store_true", help="Score only")
    parser.add_argument("--checklist", action="store_true", help="Output as markdown checklist")
    parser.add_argument(
        "--section",
        help="Treat entire input as this section (Introduction, Methods, Results, Discussion)",
    )
    parser.add_argument(
        "--no-section-detect",
        action="store_true",
        help="Skip section detection; run all checks everywhere",
    )
    parser.add_argument(
        "--severity",
        choices=["error", "warning", "suggestion", "all"],
        default="all",
        help="Filter findings by severity (default: all)",
    )
    parser.add_argument(
        "--list-checks",
        action="store_true",
        help="Show all available checks and exit",
    )
    args = parser.parse_args()

    # List checks mode
    if args.list_checks:
        print("Available checks:\n")
        print(f"  {'ID':4s}  {'Severity':8s}  {'Name':30s}  Description")
        print(f"  {'--':4s}  {'--------':8s}  {'----':30s}  -----------")
        for check_id, (severity, name, desc) in sorted(CHECK_DESCRIPTIONS.items()):
            print(f"  {check_id:4s}  {severity:8s}  {name:30s}  {desc}")
        print(f"\n  Total: {len(CHECK_DESCRIPTIONS)} checks ({sum(1 for v in CHECK_DESCRIPTIONS.values() if v[0] == 'error')} errors, {sum(1 for v in CHECK_DESCRIPTIONS.values() if v[0] == 'warning')} warnings, {sum(1 for v in CHECK_DESCRIPTIONS.values() if v[0] == 'suggestion')} suggestions)")
        sys.exit(0)

    # Read input
    if args.file:
        path = Path(args.file)
        if not path.exists():
            print(f"Error: File not found: {args.file}", file=sys.stderr)
            sys.exit(1)
        text = path.read_text(encoding="utf-8")
    elif not sys.stdin.isatty():
        text = sys.stdin.read()
    else:
        print("Usage: scan-manuscript.py <file>", file=sys.stderr)
        print("       cat manuscript.md | scan-manuscript.py", file=sys.stderr)
        print("       scan-manuscript.py --list-checks", file=sys.stderr)
        sys.exit(1)

    # Scan
    result = scan(
        text,
        section_override=args.section,
        no_section_detect=args.no_section_detect,
    )

    # Filter by severity
    if args.severity != "all":
        result.findings = [f for f in result.findings if f.severity == args.severity]

    # Output
    if args.quiet:
        from scanner.scoring import calculate_score
        score = calculate_score(result.findings, result.total_words)
        print(f"{score:.1f}")
    elif args.json:
        print(format_json(result.findings, result.sections, result.total_words, lines=result.lines))
    elif args.checklist:
        print(format_checklist(result.findings, result.sections))
    else:
        print(format_report(result.findings, result.sections, result.total_words, lines=result.lines))


if __name__ == "__main__":
    main()
