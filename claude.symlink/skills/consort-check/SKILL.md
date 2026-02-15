---
name: consort-check
description: Use when auditing a randomized controlled trial manuscript against the CONSORT 2025 checklist. Triggers on RCTs, randomized trials, clinical trials, intervention studies with randomization, parallel-group designs, crossover trials, or factorial designs.
---

# CONSORT 2025 Compliance Checker

Audit randomized controlled trial manuscripts against the CONSORT 2025 (Consolidated Standards of Reporting Trials) 30-item checklist. Published April 2025, supersedes CONSORT 2010.

## What Changed from CONSORT 2010

- **7 new items** added (data sharing, conflicts of interest, PPI, site eligibility, harms assessment, analysis population, intervention delivery)
- **3 items revised** (protocol access, post-commencement changes, missing data)
- **1 item deleted** (generalisability — now incorporated into Limitations, item 30)
- **New Open Science section** (items 2-5)
- **Renumbered** throughout (do NOT use CONSORT 2010 numbering)

## Workflow

1. Read the full manuscript
2. Confirm the study is a randomized trial; identify design (parallel, factorial, crossover, cluster)
3. Walk through each item below
4. For each item, assign: **Reported** / **Partial** / **Missing** / **N/A**
5. Quote the relevant manuscript text as evidence
6. Output a compliance summary + actionable fixes
7. Check for CONSORT flow diagram (strongly recommended)

## CONSORT 2025 Checklist (30 Items)

### Title and Abstract

| # | Topic | Requirement |
|---|-------|-------------|
| **1a** | Title | Identification as a randomised trial in the title |
| **1b** | Abstract | Structured summary of trial design, methods, results, and conclusions |

### Open Science (NEW section)

| # | Topic | Requirement |
|---|-------|-------------|
| **2** | Trial registration | Registry name, identifying number with URL, and registration date |
| **3** | Protocol and SAP access | Where the trial protocol and statistical analysis plan can be accessed |
| **4** | Data sharing | **NEW.** Where and how de-identified participant data (including data dictionary), statistical code, and other materials can be accessed |
| **5a** | Funding | Sources of funding and other support; role of funders in design, conduct, analysis, reporting |
| **5b** | Conflicts of interest | **NEW.** Financial and other conflicts of interest of the manuscript authors |

### Introduction

| # | Topic | Requirement |
|---|-------|-------------|
| **6** | Background/rationale | Scientific background and rationale based on existing evidence |
| **7** | Objectives | Specific objectives related to benefits and harms, using PICO framework |

### Methods

| # | Topic | Requirement |
|---|-------|-------------|
| **8** | Patient/public involvement | **NEW.** Details of patient or public involvement in the design, conduct, and reporting of the trial |
| **9** | Trial design | Type of design (parallel, crossover, factorial, etc.), allocation ratio, framework (superiority, non-inferiority, equivalence) |
| **10** | Protocol changes | **REVISED.** Important changes to the trial after commencement, with reasons and timing |
| **11** | Trial setting | Settings and geographical locations where the trial was conducted |
| **12a** | Participant eligibility | Eligibility criteria for participants |
| **12b** | Site/provider eligibility | **NEW.** Eligibility criteria for sites and individuals delivering interventions |
| **13** | Interventions | Sufficient details to allow replication; how and when administered; access to intervention manuals/materials |
| **14** | Outcomes | Pre-specified primary and secondary outcomes: measurement variables, analysis metrics, aggregation methods, timepoints |
| **15** | Harms assessment | **NEW.** How harms were defined and assessed (systematically vs non-systematically) |
| **16a** | Sample size | How sample size was determined, with all supporting assumptions |
| **16b** | Interim analyses | Explanation of interim analyses and stopping guidelines |
| **17a** | Randomisation — sequence | Who generated sequence; method used |
| **17b** | Randomisation — type | Type of randomisation; details of restriction (stratification, blocking) |
| **18** | Allocation concealment | Mechanism to implement allocation sequence; steps taken to conceal until assignment |
| **19** | Implementation | Whether personnel accessing the allocation sequence could foresee assignment |
| **20a** | Blinding — who | Who was blinded after assignment (participants, care providers, outcome assessors) |
| **20b** | Blinding — how | How blinding was achieved; description of similarity of interventions |
| **21a** | Statistical methods | Methods for comparing groups for primary/secondary outcomes and harms |
| **21b** | Analysis population | **NEW.** Definition of who is included in each analysis and how group assignment was handled |
| **21c** | Missing data | **REVISED.** How missing data were handled in the analysis |
| **21d** | Additional analyses | Methods for subgroup and sensitivity analyses, distinguishing pre-specified from post hoc |

### Results

| # | Topic | Requirement |
|---|-------|-------------|
| **22a** | Participant flow | For each group: numbers randomised, received intervention, analysed. **Flow diagram strongly recommended** |
| **22b** | Losses/exclusions | Losses and exclusions after randomisation, with reasons |
| **23a** | Recruitment dates | Periods of recruitment and follow-up for outcomes of benefits and harms |
| **23b** | Trial termination | Why the trial ended or was stopped |
| **24a** | Intervention delivery | **NEW.** Intervention and comparator as actually administered, including fidelity |
| **24b** | Concomitant care | Care received during the trial for each group |
| **25** | Baseline characteristics | Table of baseline demographic and clinical characteristics for each group |
| **26** | Outcomes | Numbers analysed, available data, results per group, effect sizes with confidence intervals |
| **27** | Harms | All harms or unintended events in each group |
| **28** | Ancillary analyses | Other analyses performed, distinguishing pre-specified from post hoc |

### Discussion

| # | Topic | Requirement |
|---|-------|-------------|
| **29** | Interpretation | Interpretation consistent with results, balancing benefits and harms, considering other evidence |
| **30** | Limitations | **REVISED.** Trial limitations: bias, imprecision, **generalisability**, and multiplicity of analyses (generalisability now incorporated here; was a separate item in 2010) |

## Critical CONSORT 2025 Elements

| Must-Have | Why |
|-----------|-----|
| **Flow diagram** (22a) | Journals typically will not review without one |
| **Trial registration** (2) | Mandatory for ICMJE journals; prospective registration expected |
| **Randomisation details** (17-19) | Core of trial integrity reporting |
| **Sample size** (16a) | Reviewers check this immediately |
| **Analysis population / ITT** (21b) | Must define who is included and how; state ITT or per-protocol |
| **Harms** (15, 27) | Both assessment method AND results now required |
| **Data sharing** (4) | New open science requirement; increasingly mandated |

## Common CONSORT 2025 Gaps

| Frequently Missing | Fix |
|--------------------|-----|
| Item 4 (Data sharing) | State data availability policy; provide repository URL or explain restrictions |
| Item 5b (Conflicts) | Add explicit COI disclosure for each author |
| Item 8 (PPI) | Describe patient involvement or state "No patient or public involvement" |
| Item 12b (Site eligibility) | State criteria for site and provider selection |
| Item 15 (Harms assessment) | Describe how AEs were defined, collected, and classified |
| Item 21b (Analysis population) | State ITT/mITT/per-protocol explicitly; define who was included |
| Item 21c (Missing data) | Describe imputation or complete-case approach |
| Item 24a (Intervention delivery) | Report fidelity and actual administration vs protocol |

## Output Format

```
CONSORT 2025 Compliance Report
Trial design: [Parallel / Factorial / Crossover / Cluster]
Manuscript: [filename]

Summary: X/30 Reported | Y Partial | Z Missing | W N/A

CRITICAL MISSING (journal will likely reject):
  [Item #] [Topic] — [What's needed]

NEW ITEMS IN 2025 (check carefully):
  [Item #] [Topic] — [Status]

OTHER MISSING:
  [Item #] [Topic] — [What's needed]

PARTIAL ITEMS:
  [Item #] [Topic] — [What's present] → [What's missing]

Flow diagram: [Present / Missing]
Trial registration: [Registered (ID) / Not registered / Not stated]
Data sharing statement: [Present / Missing]
```

## Related Skills

- `/manuscript` — Overall manuscript writing and anti-pattern scanning
