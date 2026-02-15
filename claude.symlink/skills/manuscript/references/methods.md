# Methods: Earning Trust

## Organize by Research Logic, Not by Tool

Don't organize Methods by instrument:

- "Data Collection" → "Variable Definitions" → "Statistical Analysis"

Organize by research flow:

- Who are your subjects → What did you measure → How did you handle those measurements → How did you analyze them

This order should mirror the study strategy stated in your Introduction's final paragraph. The reader already has a mental map — follow it.

## Justify Key Methodological Decisions

When you make a non-obvious choice, briefly explain why. One sentence suffices.

### Examples

**Model selection:**

> "We selected group-based trajectory modeling over growth curve modeling because our goal was to identify discrete subgroups rather than characterize population-average trends."

**Number of groups:**

> "We selected the optimal number of trajectory groups based on BIC and average posterior probability of assignment, following established guidelines (Nagin 2005)."

**Covariate selection:**

> "Covariates were selected based on prior literature and directed acyclic graph analysis to minimize collider bias."

### Why This Matters

Justifying decisions shows methodological depth. It also preempts reviewer questions — saving you a revision cycle.

## Strategic Sensitivity Analyses

Don't scatter random sensitivity analyses. Target the **biggest threats** to your study's validity.

### The Strategy

1. Identify your study's top 2–3 validity threats
2. Design a sensitivity analysis that directly tests each threat
3. Report them in Results
4. Reference them in Discussion when addressing limitations

### Example

| Threat | Sensitivity Analysis |
|--------|---------------------|
| Informative censoring (sicker patients die earlier → missing data) | Multiple imputation with mortality as auxiliary variable |
| Misclassification of trajectory groups | Restrict to patients with ≥3 measurements |
| Confounding by indication | Propensity score–weighted analysis |

### The Payoff in Discussion

Instead of: "A limitation is possible informative censoring."

You write: "Although informative censoring is a concern, our multiple imputation analysis incorporating mortality status yielded consistent results (eTable 3)."

## Reporting Guidelines

Always follow the appropriate guideline:

| Study Design | Guideline |
|-------------|-----------|
| Observational cohort / case-control | STROBE |
| Randomized trial | CONSORT |
| Systematic review / meta-analysis | PRISMA |
| Diagnostic accuracy | STARD |
| Prediction model | TRIPOD |
| Case report | CARE |
| Qualitative research | COREQ |

Mention adherence in Methods: "We followed the STROBE guideline for reporting observational studies (Supplementary Checklist)."

## Checklist

- [ ] Organization mirrors Introduction's stated study strategy
- [ ] Key non-obvious decisions include one-sentence justification
- [ ] Sensitivity analyses target specific validity threats (not random)
- [ ] Appropriate reporting guideline followed and cited
- [ ] Statistical software and version specified
- [ ] Significance threshold stated (or explain why not using one)
- [ ] Ethics approval and informed consent documented
