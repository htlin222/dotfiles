# Method-design checklist

Reviewers at IF 11+ venues reject methods papers that skip any of the following. Design upfront.

## 1. Leakage-free feature selection

- Select features (top-variable genes, informative features, hyperparameters) on the **discovery cohort only**. External validation cohorts are never used for selection.
- State this explicitly in both Methods and Results. Cite as a deliberate design choice.
- Common leak: "we used top 2000 MAD genes in the intersection of both cohorts" - this is semi-supervised selection. Fix by selecting on discovery alone, then projecting validation.

## 2. Stability / robustness of pipeline choices

- Every hyperparameter that could materially change conclusions must be swept.
- Example for Mapper-based TDA: 30-40 perturbations of cover size, overlap, DBSCAN epsilon multiplier, lens seed; report adjusted Rand Index distribution vs a reference labelling and a pairwise all-vs-all matrix.
- For clustering methods: report consensus / co-assignment matrix.

## 3. Null models appropriate to the statistic

- Shuffle labels within each feature (not across) to generate null for persistent-homology statistics; this preserves marginal feature distributions. Use Phipson-Smyth exact p: `p = (k + 1) / (n + 1)`.
- For survival claims, permute subgroup labels and refit the log-rank (not feasible for Cox).
- Report whether the null destroys feature-feature covariance and whether that matters (per-gene shuffle over-destroys covariance and may be conservative).

## 4. Proportional-hazards testing

- For every Cox model in the final tally, run Schoenfeld-residual tests (rank and Kaplan-Meier time transforms). Report per-covariate p-values in a supplementary table, not just a global min.
- If any covariate violates proportionality at p<0.05, refit with stratification on that covariate and report the sensitivity C-index.

## 5. Nested Cox ladder with Harrell C

- Structure: `M0 age+sex` -> `M1 +established clinical baseline (ELN, TNM stage, etc.)` -> `M2 +driver-mutation panel or other established biomarkers` -> `M3 +treatment covariates` -> `M4 +novel descriptor under test`.
- Report bootstrap 95% CI on each C-index (>=200 resamples) and the likelihood-ratio contribution of each step (chi-square on added degrees of freedom).
- The novel descriptor must survive this ladder to be called "incremental". If it does not, pivot the claim (see novelty-search.md).

## 6. Calibration and decision-curve analysis

- Horizon-specific Brier score at clinically meaningful time points (e.g. 1y, 3y) with bootstrap CI.
- Calibration plot (observed vs predicted survival by decile).
- Vickers-style survival decision-curve analysis if the claim is clinical utility.
- Categorical net reclassification index across risk tiers if the claim is re-classification.

## 7. Multiple-testing correction

- Always declare the family of tests. Subgroup HRs across K subgroups and C cohorts -> K*C family, Benjamini-Hochberg at q<0.1 minimum; Bonferroni in parallel for strict interpretation.
- Differential expression / drug response: BH-FDR across the full gene or drug panel.

## 8. Reproducibility invariants

- Fix random seeds everywhere (NumPy, PyTorch, sklearn, UMAP).
- Pin Python version and all dependencies with `uv.lock`.
- Release analysis scripts numbered in execution order; `uv run python analysis/01_prepare_data.py` reproducible from raw download commands documented in README.
- Release a persistent tag on first submission.

## 9. Honest-negative patterns

If the new method does not beat the established baseline after the full ladder:

- Do not hide it. Report the null result with the same rigor as a positive.
- Look for orthogonal outcomes (see TDA + AML example: survival null, drug-response strong).
- Reframe as benchmarking / concordance (the method recapitulates established risk architecture, which is itself useful for unsupervised discovery).

## 10. External validation

- Two cohorts minimum for translational claims.
- External cohort used only for projection; all thresholds fixed in discovery.
- Report platform / batch differences (bottleneck distance between persistence diagrams, PCA first-component angle, etc.) - reviewers ask.
