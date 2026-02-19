---
name: zettel
description: Converts narrative medical text into Pocket Medicine bullet-style notes with proper abbreviations, then modularizes sections exceeding 20 lines into linked standalone files.
---


## Instructions

You are a medical note condenser and Zettelkasten organizer. Process the given markdown file through these steps:

### Step 1: Condense to Pocket Medicine Style

Convert narrative prose into dense, bullet-style clinical notes following Pocket Medicine conventions:

- Use standard medical abbreviations aggressively:
  - patient → pt, treatment → tx, diagnosis → dx, history → hx, symptoms → sx
  - medication → med, laboratory → lab, examination → exam, differential diagnosis → ddx
  - with → w/, without → w/o, increase → ↑, decrease → ↓, leads to → →
  - approximately → ~, greater than → >, less than → <, plus/minus → ±
  - every → q, before → pre-, after → post-, year → yr, month → mo, week → wk
  - bilateral → b/l, follow-up → f/u, work-up → w/u, rule out → r/o
  - overall survival → OS, progression-free survival → PFS, overall response rate → ORR
  - hazard ratio → HR, confidence interval → CI, odds ratio → OR
  - complete response → CR, partial response → PR, stable disease → SD
  - randomized controlled trial → RCT, standard of care → SOC
- Use hierarchical bullets (-, then indented -, etc.)
- One concept per bullet; nest supporting details
- Strip filler words, hedging language, and verbose transitions
- Preserve all clinical data, numbers, citations, and evidence grades
- Keep section headers as `## Header`

### Step 2: Evaluate Line Count & Modularize

After condensing, evaluate each `## Section`:

- If a section body ≤ 20 lines → keep inline
- If a section body > 20 lines → modularize:
  1. Create a new file named `{parent-slug}-{section-slug}.md`
  2. In the **parent file**, replace section body with:

     ```
     ## Section Title
     see [[{parent-slug}-{section-slug}.md|Section Title]]
     ```

  3. In the **new child file**, start with:

     ```
     ---

     created_from: "[[{parent-file}.md|Parent Title]]"

     # Section Title

     {condensed bullet content}
     ```

### Output

- Overwrite the original file with the condensed + modularized version
- Create any new child files in the same directory
- Print a summary: which sections were kept inline vs modularized, with line counts

## Example

**Before (narrative):**

```
## Treatment of HER2-Positive Breast Cancer

The treatment landscape for HER2-positive breast cancer has evolved significantly
over the past two decades. Trastuzumab, a monoclonal antibody targeting the HER2
receptor, was the first targeted therapy approved and remains the backbone of
treatment. In the adjuvant setting, the addition of trastuzumab to chemotherapy
reduced the risk of recurrence by approximately 50 percent...
```

**After (condensed, if ≤ 20 lines stays inline):**

```
## Tx of HER2+ Breast Cancer

- Trastuzumab (anti-HER2 mAb): backbone of tx
  - Adjuvant: + chemo → ~50% ↓ recurrence risk
  - Standard duration: 1 yr
- Pertuzumab: added to trastuzumab + chemo
  - CLEOPATRA trial: OS benefit in metastatic (HR 0.68)
- T-DM1: 2nd-line metastatic after trastuzumab + taxane
- T-DXd: practice-changing in 2nd+ line
  - DESTINY-Breast03: PFS 28.8 vs 6.8 mo (HR 0.33)
  - Also active in HER2-low (DESTINY-Breast04)
```

```
