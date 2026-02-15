"""Output formatting for manuscript scan results."""

import json
from .scoring import calculate_score, calculate_section_scores, score_descriptor


def format_report(findings, sections, total_words, lines=None):
    """Format a human-readable scan report."""
    score = calculate_score(findings, total_words)
    sec_scores = calculate_section_scores(findings, sections, total_words, lines=lines)

    errors = [f for f in findings if f.severity == "error"]
    warnings = [f for f in findings if f.severity == "warning"]
    suggestions = [f for f in findings if f.severity == "suggestion"]

    lines = []
    lines.append("")
    lines.append("=" * 44)
    lines.append("  Manuscript Scan Report")
    lines.append("=" * 44)
    lines.append("")
    lines.append(f"  Score: {score:.1f} / 10  ({score_descriptor(score)})")
    lines.append("")

    # Sections detected
    if sections:
        sec_str = ", ".join(f"{s.name} (L{s.start_line}-{s.end_line})" for s in sections)
        lines.append(f"  Sections: {sec_str}")
    else:
        lines.append("  Sections: none detected (section-specific checks limited)")
    lines.append("")

    lines.append(f"  Found {len(findings)} issue(s) in {total_words:,} words")
    if total_words > 0:
        density = len(findings) / total_words * 1000
        lines.append(f"  ({density:.1f} per 1,000 words | {len(errors)} errors, {len(warnings)} warnings, {len(suggestions)} suggestions)")
    lines.append("")

    # Errors summary
    if errors:
        lines.append("  ERRORS:")
        _format_check_summary(lines, errors)
        lines.append("")

    # Warnings summary
    if warnings:
        lines.append("  WARNINGS:")
        _format_check_summary(lines, warnings)
        lines.append("")

    # Suggestions summary
    if suggestions:
        lines.append("  SUGGESTIONS:")
        _format_check_summary(lines, suggestions)
        lines.append("")

    # Detailed findings (up to 10)
    if findings:
        lines.append("  Details:")
        shown = 0
        _sev_order = {"error": 0, "warning": 1, "suggestion": 2}
        for f in sorted(findings, key=lambda x: (_sev_order.get(x.severity, 9), x.line_num)):
            if shown >= 10:
                remaining = len(findings) - shown
                if remaining > 0:
                    lines.append(f"    ... and {remaining} more")
                break

            snippet = f.line_text
            if len(snippet) > 70:
                snippet = snippet[:67] + "..."

            lines.append(f"    L{f.line_num}: [{f.check_id}] {f.message}")
            lines.append(f"          \"{snippet}\"")
            lines.append(f"          -> {f.suggestion}")
            lines.append("")
            shown += 1

    # Section summary
    if sec_scores:
        lines.append("  Section Summary:")
        for name, sec_score in sec_scores.items():
            sec_errors = len([f for f in findings if f.section == name and f.severity == "error"])
            sec_warns = len([f for f in findings if f.section == name and f.severity == "warning"])
            sec_sugs = len([f for f in findings if f.section == name and f.severity == "suggestion"])
            bar = _score_bar(sec_score)
            lines.append(f"    {name:15s} {sec_score:4.1f}/10  {bar}  ({sec_errors}E {sec_warns}W {sec_sugs}S)")
        lines.append("")

    if not findings:
        lines.append("  No mechanical anti-patterns found. Nice work!")
        lines.append("  (Note: this checks patterns only — argumentation quality requires human review)")
        lines.append("")

    lines.append("=" * 44)
    return "\n".join(lines)


def _format_check_summary(lines, findings_list):
    """Group findings by check_id and summarize."""
    from collections import Counter
    counts = Counter((f.check_id, f.check_name) for f in findings_list)
    for (check_id, check_name), count in sorted(counts.items()):
        line_nums = sorted(set(f.line_num for f in findings_list if f.check_id == check_id))
        line_str = ", ".join(f"L{n}" for n in line_nums[:5])
        if len(line_nums) > 5:
            line_str += f" +{len(line_nums) - 5} more"
        lines.append(f"    [{check_id}] {check_name} x{count}  ({line_str})")


def _score_bar(score, width=10):
    """Render a simple text bar for a score."""
    filled = int(score / 10 * width)
    return "[" + "#" * filled + "." * (width - filled) + "]"


def format_json(findings, sections, total_words, lines=None):
    """Format results as JSON."""
    score = calculate_score(findings, total_words)
    sec_scores = calculate_section_scores(findings, sections, total_words, lines=lines)

    result = {
        "score": round(score, 1),
        "total_words": total_words,
        "finding_count": len(findings),
        "error_count": len([f for f in findings if f.severity == "error"]),
        "warning_count": len([f for f in findings if f.severity == "warning"]),
        "suggestion_count": len([f for f in findings if f.severity == "suggestion"]),
        "sections": [
            {"name": s.name, "start_line": s.start_line, "end_line": s.end_line}
            for s in sections
        ],
        "section_scores": {k: round(v, 1) for k, v in sec_scores.items()},
        "findings": [
            {
                "check_id": f.check_id,
                "check_name": f.check_name,
                "severity": f.severity,
                "section": f.section,
                "line_num": f.line_num,
                "matched_text": f.matched_text,
                "message": f.message,
                "suggestion": f.suggestion,
            }
            for f in findings
        ],
    }
    return json.dumps(result, indent=2, ensure_ascii=False)


def format_checklist(findings, sections):
    """Format results as a markdown checklist matching SKILL.md format."""
    lines = []
    lines.append("# Manuscript Scan Checklist\n")

    check_groups = {
        "Introduction": ["A4", "A6", "A8"],
        "Methods": [],
        "Results": ["A1", "A7"],
        "Discussion": ["A5", "B4", "B6"],
        "Sentence Craft": ["A2", "A3", "B1", "B2", "B5", "B7"],
        "Figures & Tables": ["B3"],
        "Style": ["C1", "C2", "C3", "C4", "C5", "C6"],
        "Mechanics": ["A9", "A10", "A11", "B8", "B9"],
    }

    for group_name, check_ids in check_groups.items():
        group_findings = [f for f in findings if f.check_id in check_ids]
        if not check_ids:
            continue

        lines.append(f"## {group_name}\n")
        for cid in check_ids:
            matches = [f for f in group_findings if f.check_id == cid]
            if matches:
                check_name = matches[0].check_name
                lines.append(f"- [ ] **[{cid}] {check_name}** — {len(matches)} issue(s)")
                for m in matches[:3]:
                    lines.append(f"  - L{m.line_num}: {m.message}")
            else:
                lines.append(f"- [x] [{cid}] — pass")
        lines.append("")

    return "\n".join(lines)
