---
name: prisma-check
description: Use when auditing a systematic review or meta-analysis manuscript against the PRISMA 2020 checklist. Triggers on systematic reviews, meta-analyses, pooled analyses, forest plots, search strategies, or study selection flow diagrams.
---

# PRISMA 2020 Compliance Checker

Audit systematic review and meta-analysis manuscripts against the PRISMA 2020 (Preferred Reporting Items for Systematic Reviews and Meta-Analyses) 27-item checklist.

## Workflow

1. Read the full manuscript
2. Confirm the study is a systematic review and/or meta-analysis
3. Walk through each item below, including all sub-items
4. For each item, assign: **Reported** / **Partial** / **Missing** / **N/A**
5. Quote the relevant manuscript text as evidence
6. Output a compliance summary + actionable fixes for Missing/Partial items
7. Check for PRISMA flow diagram (strongly recommended)

## PRISMA 2020 Checklist (27 Items)

### Title and Abstract

| # | Topic | Requirement |
|---|-------|-------------|
| **1** | Title | Identify the report as a systematic review |
| **2** | Abstract | Structured summary: background, objectives, data sources, eligibility criteria, participants/interventions, appraisal/synthesis methods, results, limitations, conclusions, registration number |

### Introduction

| # | Topic | Requirement |
|---|-------|-------------|
| **3** | Rationale | Describe rationale in context of existing knowledge |
| **4** | Objectives | Explicit statement of objectives or questions the review addresses |

### Methods

| # | Topic | Requirement |
|---|-------|-------------|
| **5** | Eligibility criteria | Inclusion/exclusion criteria and how studies were grouped for syntheses |
| **6** | Information sources | All databases, registers, websites, organisations, reference lists searched; date of last search for each |
| **7** | Search strategy | Full search strategies for all databases, including filters and limits |
| **8** | Selection process | Methods to decide inclusion: number of reviewers per record, independence, automation tools |
| **9** | Data collection process | Methods to collect data: number of reviewers, independence, processes for confirming with investigators, automation tools |
| **10a** | Data items — outcomes | List and define all outcomes sought; whether all compatible results per domain were sought |
| **10b** | Data items — other variables | List all other variables sought (participant/intervention characteristics, funding); assumptions about missing/unclear data |
| **11** | Risk of bias assessment | Methods to assess risk of bias: tool(s) used, number of reviewers, independence, automation |
| **12** | Effect measures | Effect measure(s) for each outcome (risk ratio, mean difference, etc.) |
| **13a** | Synthesis — eligibility | Processes to decide which studies eligible for each synthesis |
| **13b** | Synthesis — data preparation | Methods to prepare data for synthesis (handling missing statistics, conversions) |
| **13c** | Synthesis — display | Methods to tabulate or visually display results |
| **13d** | Synthesis — statistical methods | Methods to synthesise results with rationale; if meta-analysis: model(s), heterogeneity methods, software |
| **13e** | Synthesis — heterogeneity | Methods to explore causes of heterogeneity (subgroup analysis, meta-regression) |
| **13f** | Synthesis — sensitivity | Sensitivity analyses to assess robustness |
| **14** | Reporting bias assessment | Methods to assess risk of bias from missing results (reporting biases) |
| **15** | Certainty assessment | Methods to assess certainty in the body of evidence (e.g., GRADE) |

### Results

| # | Topic | Requirement |
|---|-------|-------------|
| **16a** | Study selection | Results of search and selection, ideally with a **PRISMA flow diagram** |
| **16b** | Study selection | Cite excluded studies that appeared to meet criteria; explain why excluded |
| **17** | Study characteristics | Cite each included study and present its characteristics |
| **18** | Risk of bias in studies | Present risk of bias assessments for each study |
| **19** | Individual study results | For all outcomes: summary statistics per group, effect estimate with precision (CI), structured tables or forest plots |
| **20a** | Synthesis results | Briefly summarise characteristics and risk of bias among contributing studies |
| **20b** | Synthesis results | All statistical syntheses: summary estimates with CI, heterogeneity measures, direction of effect |
| **20c** | Synthesis results | Investigations of heterogeneity causes |
| **20d** | Synthesis results | Sensitivity analysis results |
| **21** | Reporting biases | Risk of bias from missing results for each synthesis |
| **22** | Certainty of evidence | Certainty assessments for each outcome |

### Discussion

| # | Topic | Requirement |
|---|-------|-------------|
| **23a** | Discussion | General interpretation in context of other evidence |
| **23b** | Discussion | Limitations of the evidence |
| **23c** | Discussion | Limitations of the review processes |
| **23d** | Discussion | Implications for practice, policy, and future research |

### Other Information

| # | Topic | Requirement |
|---|-------|-------------|
| **24a** | Registration | Registration name and number, or state not registered |
| **24b** | Protocol | Where protocol can be accessed, or state not prepared |
| **24c** | Protocol amendments | Describe and explain amendments to registration or protocol |
| **25** | Support | Financial/non-financial support; role of funders/sponsors |
| **26** | Competing interests | Declare competing interests of review authors |
| **27** | Data/code availability | Report availability of: data collection forms, extracted data, analytic code, other materials |

## Critical PRISMA Elements

These are the items journals most commonly reject manuscripts for missing:

| Must-Have | Why |
|-----------|-----|
| **Flow diagram** (16a) | Most journals will not review without one |
| **Full search strategy** (7) | Reproducibility requirement; include as appendix if long |
| **PROSPERO registration** (24a) | Increasingly mandatory; register before data extraction |
| **Risk of bias table** (18) | Required for credibility; use RoB 2 or NOS as appropriate |
| **GRADE or certainty** (15, 22) | Expected by top-tier journals |

## Common PRISMA Gaps

| Frequently Missing | Fix |
|--------------------|-----|
| Item 7 (Full search strategy) | Append complete search strings for each database |
| Item 8 (Selection process detail) | State number of reviewers, kappa/agreement, screening tool |
| Item 13d (Heterogeneity methods) | Specify I-squared thresholds, random/fixed-effects model choice |
| Item 14 (Reporting bias) | Add funnel plot + Egger's test or trim-and-fill |
| Item 16b (Excluded studies) | List near-misses with exclusion reasons |
| Item 24a (Registration) | Register on PROSPERO; if post-hoc, disclose it |

## Output Format

```
PRISMA 2020 Compliance Report
Manuscript: [filename]

Summary: X/27 Reported | Y Partial | Z Missing | W N/A

CRITICAL MISSING (journal will likely reject):
  [Item #] [Topic] — [What's needed]

OTHER MISSING:
  [Item #] [Topic] — [What's needed]

PARTIAL ITEMS:
  [Item #] [Topic] — [What's present] → [What's missing]

Flow diagram: [Present / Missing]
Registration: [Registered (ID) / Not registered / Not stated]
```

## Related Skills

- `/manuscript` — Overall manuscript writing and anti-pattern scanning
- `/meta-manuscript-assembly` — Assemble tables, figures, references for meta-analyses
