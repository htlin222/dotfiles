# Figures & Tables

## Figures: One Message Per Figure

Before designing any figure, answer: **What single message should the reader take away?**

Then design everything — layout, color, labels, annotations — to serve that message. Remove anything that doesn't.

### Kaplan-Meier Curves

**If your message is "three groups differ in survival":**

- Use three visually distinct lines (color + line style for colorblind accessibility)
- Annotate the time point where separation is most visible
- Include number-at-risk table below the x-axis
- Report log-rank p-value and median survival for each group

**If your message is "difference at a specific time point":**

- Add a vertical reference line at that time point
- Annotate the survival proportions at that point
- Consider an inset magnification of the relevant region

### Forest Plots

- Order subgroups logically (not alphabetically)
- Include the overall estimate prominently
- Mark the line of no effect clearly
- Use consistent scale across related forest plots

### General Figure Principles

| Principle | Implementation |
|-----------|---------------|
| Declutter | Remove gridlines, reduce tick marks, eliminate decorative elements |
| Emphasize | Bold or color the key comparison; gray out secondary elements |
| Annotate | Label directly on the figure, not just in the legend |
| Accessibility | Distinguish by shape/pattern in addition to color |

## Figure Legends: Self-Contained Documents

A reader should understand the figure from the legend alone, without reading the paper.

### Bad Legend

> "Figure 1. Kaplan-Meier curves for overall survival by trajectory group."

### Good Legend

> "Figure 1. Kaplan-Meier curves for 90-day survival by LDH trajectory group among 2,847 ICU admissions. Three trajectory groups were identified using group-based trajectory modeling: stable-low (n=1,168, blue solid line), transient-rise (n=997, orange dashed line), and persistent-climb (n=682, red dotted line). The persistent-climb group had significantly lower survival (median 34 days, 95% CI 28–41) compared to stable-low (median not reached) and transient-rise (median 72 days, 95% CI 61–85). Log-rank p<0.001. Numbers at risk shown below the x-axis. Shaded areas represent 95% confidence intervals. LDH, lactate dehydrogenase; CI, confidence interval; ICU, intensive care unit."

### Legend Checklist

- [ ] What the figure shows (plot type, comparison)
- [ ] Who is included (sample description, N)
- [ ] Key statistical information (p-value, medians, CIs)
- [ ] How to read the visual encoding (what colors/lines/shapes mean)
- [ ] All abbreviations defined

## Tables: Design for Relevance

### Table 1 (Baseline Characteristics)

**Don't** list every variable you collected. **Do** include:

- Variables relevant to your research question
- Variables that differ meaningfully between groups
- Key confounders you adjusted for

Everything else goes to supplementary material.

### P-Values vs. Standardized Mean Differences

In large samples, p-values are almost always significant and become uninformative.

| Scenario | Use |
|----------|-----|
| Small sample, hypothesis testing | P-values |
| Large sample, descriptive comparison | SMD (standardized mean difference) |
| Multiple groups | SMD (no multiple-comparison issue) |

**SMD interpretation:** <0.1 negligible, 0.1–0.2 small, 0.2–0.5 medium, >0.5 large

### Table Formatting

- Align decimal points in columns
- Use consistent precision within each variable
- Put units in column headers, not every cell
- Use footnotes sparingly and for essential clarification only
- Bold or highlight the primary comparison

## Supplementary Material Strategy

| Main paper | Supplement |
|-----------|------------|
| Primary outcome figures | Sensitivity analysis results |
| Key baseline comparison (Table 1) | Full variable lists |
| Multivariable model results | Model diagnostics |
| Central figure of your argument | Additional subgroup analyses |

### The Test

Ask: "Does the reader need this to follow my argument?" If yes → main paper. If no but reviewers might want it → supplement.

## Checklist

- [ ] Every figure designed around a single take-home message
- [ ] Non-essential visual elements removed
- [ ] Colorblind-accessible design (shape + color)
- [ ] Figure legends are self-contained with N, stats, abbreviations
- [ ] Tables include only study-relevant variables
- [ ] SMD used instead of p-values in large-sample comparisons where appropriate
- [ ] Supplementary material contains supporting but non-essential details
- [ ] All figures at 300 DPI minimum for print
