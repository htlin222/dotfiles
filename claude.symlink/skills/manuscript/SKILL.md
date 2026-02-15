---
name: manuscript
description: Guide medical manuscript writing with argumentation-driven structure, section-by-section best practices, and sentence-level craft. Use when writing, revising, or reviewing original research manuscripts for biomedical journals, or when a draft reads flat or reviewer comments cite structural issues.
---

# Medical Manuscript Writing

Transform manuscripts from data reports into persuasive scientific arguments.

## The Core Shift

**Stop reporting. Start arguing.**

| Report Thinking | Argumentation Thinking |
|----------------|----------------------|
| "I did X, found Y, concluded Z" | "There's a problem, current answers fall short, here's a better one" |
| Paragraphs present data | Every paragraph advances the argument |
| Reader sees your lab notebook | Reader sees your insight |

Before writing any paragraph, ask: **What role does this play in my argument?** If you can't answer, the paragraph doesn't belong — or needs repositioning.

## When to Use

- Writing a new original research manuscript
- Revising a draft that reads "flat" or "boring"
- Reviewing a colleague's manuscript for structural issues
- Preparing a response to reviewer comments
- Transitioning from thesis/report style to journal style

## Master Checklist

Copy and track progress through each section:

### Pre-Writing
- [ ] Define your **one-sentence argument** (what gap you fill and why it matters)
- [ ] Identify your target journal and its conventions
- [ ] Outline the logical chain: Gap → Approach → Key Finding → Implication

### Introduction
- [ ] Opens with a **specific clinical dilemma**, not a textbook sentence
- [ ] Literature builds a **logical chain** toward your gap (not a stack of citations)
- [ ] Gap statement is **crisp and specific**
- [ ] Final paragraph states **exact study strategy** (data, method, outcome)
- [ ] Every citation serves a purpose (importance, prior limitation, or theoretical basis)

**Detailed guidance:** [references/introduction.md](references/introduction.md)

### Methods
- [ ] Organized by **research logic**, not by tool category
- [ ] Key methodological decisions include **justification** ("why this method")
- [ ] Sensitivity analyses **target your biggest threats to validity**
- [ ] Reporting follows a guideline (STROBE, CONSORT, PRISMA, etc.)

**Detailed guidance:** [references/methods.md](references/methods.md)

### Results
- [ ] Opens with a **bird's-eye view** before any details
- [ ] Baseline characteristics in text limited to **clinically relevant** differences
- [ ] Presentation order follows **research questions**, not analysis chronology
- [ ] No interpretation or speculation (no "This suggests..." or "This may be because...")
- [ ] Tables and figures referenced by finding, not narrated line-by-line

**Detailed guidance:** [references/results.md](references/results.md)

### Discussion
- [ ] First paragraph is a **conceptual elevator pitch** (finding + clinical picture + significance)
- [ ] Interpretation organized in **layers** (biological → methodological → clinical)
- [ ] Inconsistent results **honestly engaged**, not ignored
- [ ] Literature comparison builds **your explanatory framework**, not a citation list
- [ ] Limitations are **balanced**: acknowledge → mitigate → contextualize
- [ ] Conclusion states **clinical implication**, not just statistical summary

**Detailed guidance:** [references/discussion.md](references/discussion.md)

### Sentence-Level Polish
- [ ] Subjects are **study variables or actions**, not passive constructions
- [ ] Each paragraph's **first and last sentences** carry the main message
- [ ] No hedge stacking ("may possibly potentially suggest...")
- [ ] Eliminated empty adjectives ("interesting", "important", "noteworthy")
- [ ] Read aloud — every sentence flows naturally

**Detailed guidance:** [references/sentence-craft.md](references/sentence-craft.md)

### Figures & Tables
- [ ] Every figure has a **single take-home message**
- [ ] Figure legends are **self-contained** (method, sample, key stats, abbreviations)
- [ ] Tables show only **study-relevant** variables (extras go to supplement)
- [ ] Large-sample comparisons use **SMD** instead of p-values where appropriate

**Detailed guidance:** [references/figures-tables.md](references/figures-tables.md)

### Overall Rhythm
- [ ] Information-dense paragraphs followed by **interpretive breathing room**
- [ ] No three consecutive paragraphs with the same "found A, p=B, consistent with C" pattern
- [ ] Transitions between sections feel **guided**, not mechanical
- [ ] **Read aloud** — if it sounds dull or stilted to you, it reads worse to others

## Section Quick Reference

| Section | Goal | Fatal Mistake | Fix |
|---------|------|--------------|-----|
| Introduction | Build logical case for your study | Starting with "X is a leading cause of death" | Open with a specific clinical dilemma |
| Methods | Earn reader trust | Listing tools without justification | Explain *why* for key decisions |
| Results | Present facts that advance the argument | Smuggling interpretation ("suggests...") | Facts only; interpretation in Discussion |
| Discussion | Provide conceptual significance | Restating results with p-values | Lead with meaning, not numbers |
| Figures | Deliver one message per figure | Cluttered figures without clear takeaway | Design around the take-home message |

## Common Anti-Patterns

| Anti-Pattern | Example | Better Approach |
|-------------|---------|----------------|
| Textbook opening | "Cancer is a leading cause of death worldwide" | Specific clinical dilemma your study addresses |
| Citation stacking | "Smith (2020) found X. Jones (2021) found Y." | Synthesize into a logical chain with inline citations |
| Vague study aim | "We aimed to explore the relationship between X and Y" | "We used [database] with [method] to test [specific hypothesis]" |
| Lab-notebook Results | Narrating every row of Table 1 | Highlight only clinically meaningful differences |
| Statistical Discussion | "HR was 2.4 (95% CI 1.8–3.2, p<0.001)" as Discussion opener | Lead with conceptual significance, not numbers |
| Self-destructive Limitations | Listing every weakness until the study sounds worthless | Acknowledge → mitigate → contextualize |
| Hedge stacking | "It is possible that this may potentially suggest..." | One hedge per claim: "This suggests..." |
| Empty adjectives | "Interestingly, we found..." | Show the contrast or surprise directly |

## Quick Scan

Run the built-in scanner to catch mechanical anti-patterns (20 checks, section-aware):

```bash
# Full scan
python3 ~/.claude/skills/manuscript/scan-manuscript.py manuscript.md

# Errors only (high confidence)
python3 ~/.claude/skills/manuscript/scan-manuscript.py --severity error manuscript.md

# Check a single section from stdin
cat results.md | python3 ~/.claude/skills/manuscript/scan-manuscript.py --section Results

# JSON output / markdown checklist
python3 ~/.claude/skills/manuscript/scan-manuscript.py --json manuscript.md
python3 ~/.claude/skills/manuscript/scan-manuscript.py --checklist manuscript.md

# List all checks
python3 ~/.claude/skills/manuscript/scan-manuscript.py --list-checks
```

**What it catches** (~30-35% of this skill's guidance): hedge stacking, empty adjectives, interpretation in Results, textbook openings, vague aims, p-values without CIs, citation stacking, passive voice ratio, sentence monotony, table/figure narration, statistical Discussion openers, mechanical transitions, overclaiming, nominalizations, wordy phrases, redundant modifiers, self-referential filler, sentence sprawl, double negatives.

**What it cannot catch** (~55%): argumentation quality, logical chains, gap specificity, interpretive framework depth, limitation balance. These require human judgment or AI-assisted review.

## Related Skills

- `/human-write` — Scan for AI-flavored vocabulary
- `/meta-manuscript-assembly` — Assemble tables, figures, references for meta-analyses
- `/scientific-figure-assembly` — Create multi-panel publication figures
- `/vale` — Lint prose for style and grammar
