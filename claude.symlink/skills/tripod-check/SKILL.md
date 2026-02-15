---
name: tripod-check
description: Use when auditing a prediction model or clinical AI manuscript against the TRIPOD+AI checklist. Triggers on prediction models, prognostic scores, diagnostic models, machine learning clinical tools, risk calculators, AUC/c-statistic reporting, or AI-assisted clinical decision support.
---

# TRIPOD+AI Compliance Checker

Audit prediction model and clinical AI manuscripts against the TRIPOD+AI (Transparent Reporting of a Multivariable Prediction Model for Individual Prognosis Or Diagnosis + AI extension) 27-item checklist.

## Workflow

1. Read the full manuscript
2. Identify study phase: **Development (D)**, **Evaluation (E)**, or **Both (D;E)**
3. Identify modelling approach: regression, machine learning, deep learning, ensemble
4. Walk through each item; note applicability column (D, E, or D;E)
5. For each applicable item, assign: **Reported** / **Partial** / **Missing** / **N/A**
6. Quote the relevant manuscript text as evidence
7. Output a compliance summary + actionable fixes

## TRIPOD+AI Checklist (27 Items)

### Title and Abstract

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **1** | D;E | Title | Identify as developing/evaluating a prediction model; specify target population, outcome, and modelling approach (regression vs ML) |
| **2** | D;E | Abstract | Structured summary following TRIPOD+AI for Abstracts |

### Introduction

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **3a** | D;E | Healthcare context | Explain diagnostic/prognostic setting; rationale for model; reference existing models |
| **3b** | D;E | Target population | Describe intended population, where in care pathway, who are intended users |
| **3c** | D;E | Health inequalities | Describe known health inequalities across demographic/socioeconomic groups; address fairness |
| **4** | D;E | Objectives | State objectives; specify whether development, evaluation, or both |

### Methods — Data and Participants

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **5a** | D;E | Data sources | Describe source(s) of data; justify selection; assess representativeness |
| **5b** | D;E | Data dates | Start/end dates of participant accrual; end of follow-up for prognostic models |
| **6a** | D;E | Setting | Study setting (primary/secondary care, general population); number and location of centres |
| **6b** | D;E | Eligibility | Inclusion and exclusion criteria |
| **6c** | D;E | Treatments | Treatments received; how handled during development/evaluation |

### Methods — Data Preparation and Outcome

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **7** | D;E | Data preparation | All preprocessing, cleaning, harmonisation steps; quality checks; consistency across demographic groups |
| **8a** | D;E | Outcome definition | Define predicted outcome; time horizon for prognostic models; assessment methods; consistency across subgroups |
| **8b** | D;E | Outcome assessors | For subjective outcomes: assessor qualifications and demographics |
| **8c** | D;E | Outcome blinding | Whether outcome assessment was blinded to predictor information |

### Methods — Predictors

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **9a** | D | Predictor selection | Describe and justify initial predictor choice and pre-selection |
| **9b** | D;E | Predictor definition | Define all predictors; how and when measured; blinding procedures |
| **9c** | D;E | Predictor assessors | For subjective predictors: assessor credentials and demographics |

### Methods — Sample Size and Missing Data

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **10** | D;E | Sample size | How determined; justify sufficiency; include calculation details |
| **11** | D;E | Missing data | Approach to missing data with justification |

### Methods — Analytical Approaches

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **12a** | D | Data partitioning | How data allocated to development/evaluation; partitioning strategy |
| **12b** | D | Predictor handling | How predictors handled (functional forms, transformations, standardisation) |
| **12c** | D | Model building | **Model type with rationale. For ML: architecture, hyperparameter tuning, training procedures.** Internal validation method |
| **12d** | D;E | Heterogeneity | How variability across clusters (hospitals, countries) was handled |
| **12e** | D;E | Performance evaluation | Discrimination (c-statistic/AUC), calibration methods, clinical utility; model comparison if applicable |
| **12f** | E | Model updating | Recalibration or updating approaches |
| **12g** | E | Prediction calculation | How predictions generated; formula, code, or API details |

### Methods — Class Imbalance and Fairness

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **13** | D;E | Class imbalance | Whether imbalance methods used, why, implementation, recalibration steps |
| **14** | D;E | Fairness assessment | Approaches to assess and address fairness across demographic groups |

### Methods — Model Specifications and Ethics

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **15** | D | Model output | Output type (probabilities vs classifications); classification thresholds and rationale |
| **16** | D;E | Dev vs eval differences | Differences between development and evaluation in settings, eligibility, outcome, predictors |
| **17** | D;E | Ethical approval | IRB/ethics committee; consent procedures or waiver |

### Open Science

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **18a** | D;E | Funding | Funding sources and funder role |
| **18b** | D;E | Conflicts | All author disclosures |
| **18c** | D;E | Protocol | Where protocol accessible; or state not prepared |
| **18d** | D;E | Registration | Registry name and number; or state not registered |
| **18e** | D;E | Data sharing | Data availability; access restrictions and terms |
| **18f** | D;E | Code sharing | Analytical code availability; access conditions |

### Patient and Public Involvement

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **19** | D;E | PPI | Patient/public involvement in design, conduct, reporting; or state none |

### Results

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **20a** | D;E | Participant flow | Flow of participants; outcome event counts; follow-up time; flow diagram recommended |
| **20b** | D;E | Participant characteristics | Demographics and key characteristics overall and per setting; predictor values, treatments, sample size, events, missing data; differences across demographic groups |
| **20c** | E | Data comparison | Compare predictor distributions between evaluation and development datasets |
| **21** | D;E | Participant counts | Participants and events for each analysis phase (development, tuning, evaluation) |
| **22** | D | Full model specification | **Complete model details for reproduction: regression coefficients/intercept, or model code/object/API** |
| **23a** | D;E | Performance | Performance measures with CIs; subgroup results; calibration plots |
| **23b** | D;E | Heterogeneity results | Performance variation across clusters |
| **24** | E | Model updating results | Updated model and its performance |

### Discussion

| # | Applies | Topic | Requirement |
|---|:---:|-------|-------------|
| **25** | D;E | Interpretation | Overall interpretation; fairness considerations; comparison to existing models |
| **26** | D;E | Limitations | Non-representativeness, sample size, overfitting, missing data, measurement bias, generalisability |
| **27a** | D | Poor quality input | How model handles poor quality, missing, or out-of-range input data at deployment |
| **27b** | D | User requirements | Level of user interaction needed; expertise required |
| **27c** | D;E | Future research | Next steps: external validation, implementation, generalisability studies |

## ML/AI-Specific Emphasis

These items have expanded requirements for ML/AI models compared to traditional regression:

| Item | ML/AI Extra Requirements |
|------|--------------------------|
| **7** (Data preparation) | Feature engineering, data augmentation, normalisation pipelines |
| **12c** (Model building) | Full architecture spec, hyperparameter search space, training/validation split, early stopping, regularisation |
| **13** (Class imbalance) | SMOTE, oversampling, undersampling, cost-sensitive learning |
| **14** (Fairness) | Algorithmic fairness metrics across demographic groups (new in TRIPOD+AI) |
| **3c** (Health inequalities) | Equity considerations for model deployment (new in TRIPOD+AI) |
| **18e-f** (Open science) | Model weights, training code, inference API sharing |
| **22** (Model specification) | Model weights/code/API, not just coefficients |

## Common TRIPOD+AI Gaps

| Frequently Missing | Fix |
|--------------------|-----|
| Item 3c (Health inequalities) | Add paragraph on known demographic disparities in the prediction problem |
| Item 12c (Full ML pipeline) | Document architecture, hyperparameters, training procedure, validation strategy |
| Item 14 (Fairness) | Report model performance stratified by sex, age, race/ethnicity |
| Item 22 (Model specification) | Share model code/weights via GitHub or provide formula with all coefficients |
| Item 18e-f (Data/code sharing) | Publish code on GitHub; share de-identified data or explain restrictions |
| Item 19 (PPI) | State whether patients/public were involved; if not, say so explicitly |
| Item 10 (Sample size) | Use Riley et al. criteria for prediction model sample size |

## Output Format

```
TRIPOD+AI Compliance Report
Study phase: [Development / Evaluation / Both]
Modelling approach: [Regression / ML / Deep Learning / Ensemble]
Manuscript: [filename]

Summary: X/27 Reported | Y Partial | Z Missing | W N/A
(Items assessed based on study phase: D-only / E-only / D;E)

ML/AI-SPECIFIC GAPS:
  [Item #] [Topic] — [What's needed for ML/AI compliance]

OTHER MISSING:
  [Item #] [Topic] — [What's needed]

PARTIAL ITEMS:
  [Item #] [Topic] — [What's present] → [What's missing]

Open science:
  Code sharing: [Available (URL) / Not available / Not stated]
  Data sharing: [Available (URL) / Not available / Not stated]
  Registration: [Registered (ID) / Not registered / Not stated]
```

## Extensions

- **TRIPOD-LLM** (2024, Nature Medicine): Extension for studies using large language models in biomedical/healthcare. Adds 19 items covering explainability, transparency, human oversight, and task-specific LLM considerations.
- **PROBAST** (Prediction model Risk Of Bias ASsessment Tool): Companion tool for assessing risk of bias; use alongside TRIPOD+AI for quality appraisal.

## Related Skills

- `/manuscript` — Overall manuscript writing and anti-pattern scanning
- `/strobe-check` — If the prediction model is developed from an observational cohort, also run STROBE
