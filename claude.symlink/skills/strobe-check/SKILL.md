---
name: strobe-check
description: Use when auditing an observational study manuscript (cohort, case-control, or cross-sectional) against the STROBE checklist. Triggers on retrospective studies, hospital data, registry/database studies like TCGA, SEER, NHIRD, or any non-randomized clinical research.
---

# STROBE Compliance Checker

Audit observational study manuscripts against the STROBE (Strengthening the Reporting of Observational Studies in Epidemiology) 22-item checklist.

## Workflow

1. Read the full manuscript
2. Identify the study design: **cohort**, **case-control**, or **cross-sectional**
3. Walk through each item below, noting design-specific sub-items
4. For each item, assign: **Reported** / **Partial** / **Missing** / **N/A**
5. Quote the relevant manuscript text (with line/page reference) as evidence
6. Output a compliance summary table + actionable fixes for Missing/Partial items

## STROBE Checklist (22 Items)

### Title and Abstract

| # | Topic | Requirement |
|---|-------|-------------|
| **1a** | Title | Indicate the study design with a commonly used term in the title or abstract |
| **1b** | Abstract | Provide an informative and balanced summary of what was done and found |

### Introduction

| # | Topic | Requirement |
|---|-------|-------------|
| **2** | Background/rationale | Explain the scientific background and rationale for the investigation |
| **3** | Objectives | State specific objectives, including any prespecified hypotheses |

### Methods

| # | Topic | Requirement |
|---|-------|-------------|
| **4** | Study design | Present key elements of study design early in the paper |
| **5** | Setting | Describe setting, locations, relevant dates (recruitment, exposure, follow-up, data collection) |
| **6a** | Participants | **Cohort:** eligibility criteria, sources/methods of selection, methods of follow-up. **Case-control:** eligibility, case ascertainment, control selection, rationale. **Cross-sectional:** eligibility, sources/methods of selection |
| **6b** | Participants | **Cohort/Case-control:** For matched studies, give matching criteria and number matched |
| **7** | Variables | Clearly define all outcomes, exposures, predictors, confounders, effect modifiers; give diagnostic criteria |
| **8** | Data sources | For each variable, give sources of data and methods of assessment; describe comparability across groups |
| **9** | Bias | Describe any efforts to address potential sources of bias |
| **10** | Study size | Explain how the study size was arrived at |
| **11** | Quantitative variables | Explain how quantitative variables were handled; describe groupings and rationale |
| **12a** | Statistical methods | Describe all statistical methods, including confounding control |
| **12b** | Statistical methods | Methods for subgroups and interactions |
| **12c** | Statistical methods | How missing data were addressed |
| **12d** | Statistical methods | **Cohort:** how loss to follow-up was addressed. **Case-control:** how matching was addressed. **Cross-sectional:** sampling strategy methods |
| **12e** | Statistical methods | Describe any sensitivity analyses |

### Results

| # | Topic | Requirement |
|---|-------|-------------|
| **13a** | Participants | Report numbers at each stage of study (eligible, examined, confirmed, included, completed, analysed) |
| **13b** | Participants | Give reasons for non-participation at each stage |
| **13c** | Participants | Consider use of a flow diagram |
| **14a** | Descriptive data | Characteristics of participants (demographic, clinical, social) and information on exposures/confounders |
| **14b** | Descriptive data | Number of participants with missing data for each variable |
| **14c** | Descriptive data | **Cohort:** Summarise follow-up time (average and total) |
| **15** | Outcome data | **Cohort:** numbers of outcome events or summary measures over time. **Case-control:** numbers in each exposure category. **Cross-sectional:** numbers of outcome events or summary measures |
| **16a** | Main results | Unadjusted estimates and confounder-adjusted estimates with precision (95% CI). State which confounders and why |
| **16b** | Main results | Report category boundaries when continuous variables were categorised |
| **16c** | Main results | If relevant, translate relative risk into absolute risk for a meaningful time period |
| **17** | Other analyses | Report subgroup analyses, interactions, sensitivity analyses |

### Discussion

| # | Topic | Requirement |
|---|-------|-------------|
| **18** | Key results | Summarise key results with reference to study objectives |
| **19** | Limitations | Discuss limitations: sources of bias/imprecision, direction and magnitude of potential bias |
| **20** | Interpretation | Cautious overall interpretation considering objectives, limitations, multiplicity, similar studies |
| **21** | Generalisability | Discuss external validity of results |

### Other Information

| # | Topic | Requirement |
|---|-------|-------------|
| **22** | Funding | Source of funding and role of funders |

## Design-Specific Attention

| Design | Extra Focus |
|--------|-------------|
| **Cohort** | Items 6b, 12d (follow-up), 14c (follow-up time), 15 (events over time) |
| **Case-control** | Items 6a-6b (case/control selection rationale, matching), 12d (matching analysis), 15 (exposure categories) |
| **Cross-sectional** | Items 6a (selection), 12d (sampling strategy), 15 (summary measures) |

## Common STROBE Gaps

| Frequently Missing | Fix |
|--------------------|-----|
| Item 9 (Bias) | Add a dedicated paragraph on bias sources and mitigation strategies |
| Item 10 (Study size) | State sample size justification or explain it was convenience-based |
| Item 12c (Missing data) | Describe complete-case, imputation, or sensitivity approach |
| Item 14b (Missing data counts) | Add missingness counts per variable to Table 1 or supplement |
| Item 16a (Unadjusted + adjusted) | Report both crude and adjusted estimates with 95% CIs |
| Item 19 (Limitations direction) | Discuss direction of bias (toward/away from null), not just list weaknesses |

## Output Format

```
STROBE Compliance Report
Study design: [Cohort / Case-control / Cross-sectional]
Manuscript: [filename]

Summary: X/22 Reported | Y Partial | Z Missing | W N/A

MISSING ITEMS (priority fixes):
  [Item #] [Topic] — [What's needed]

PARTIAL ITEMS (improvements needed):
  [Item #] [Topic] — [What's present] → [What's missing]

FULLY REPORTED:
  [Item #] [Topic] ✓
```

## Extensions

- **STROBE-Equity** (2024): 10 additional items for reporting health equity data. Use alongside core STROBE when the study addresses health disparities.
- **RECORD** (REporting of studies Conducted using Observational Routinely-collected Data): Extension for electronic health record / claims database studies.

## Related Skills

- `/manuscript` — Overall manuscript writing and anti-pattern scanning
- `/human-write` — AI-flavored vocabulary detection
