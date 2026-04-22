# Adversarial review cycle

Before each release, dispatch four reviewers in parallel. Iterate until unanimous accept.

## The four reviewers

Use the Agent tool (subagent_type: general-purpose) with tailored prompts. All four run in parallel in one message.

### R1 - Methods / topology / algorithms reviewer

Expertise: the technical primitive of the paper (TDA, deep learning, graph methods, network analysis, whatever the method is).

Must check: parameter-sensitivity, stability analyses, null models, whether theoretical claims are supported, whether the method is actually used correctly (e.g. Vietoris-Rips on non-metric distances requires disclosure).

### R2 - Clinical / domain reviewer

Expertise: the disease or biology. For oncology: an oncologist or pathologist; for cardiology: a cardiologist; etc.

Must check: clinical relevance, comparison against the real guideline-recommended baseline (ELN 2022 for AML, IPI for lymphoma, etc.), missing covariates (treatment, comorbidities), actionability, translational feasibility.

### R3 - Biostatistics reviewer

Expertise: survival analysis, multiple testing, calibration, reproducibility.

Must check: leakage, proportional-hazards violations, multiple-testing corrections across the full family, bootstrap vs cross-validation, calibration plots, .632+ optimism, power / detectable-effect-size calculations.

### R4 - High-IF editor

Expertise: editorial standards at the target journal (novelty, delta vs cited prior art, figure quality, writing clarity, abstract headline).

Must check: novelty is crisply stated vs prior art, claims match evidence, figures are legible, data / code availability meets the target journal's standards, title is short, ethics statement present, cross-reference errors (abstract-to-results-to-figure number consistency).

## Prompt template

For each reviewer, a self-contained prompt. Do not rely on shared context - the Agent tool starts fresh each time.

```
You are Reviewer N (of 4) for a manuscript being prepared for submission to
a high-impact-factor journal (target: <journal>).

Your expertise: <role-specific expertise>.

Manuscript file: <absolute path to main.tex>
<other files: clinical summary JSON, robustness summary, figures>

<optional: short list of what you flagged in the previous round, if this is
round >=2 - paste the previous concerns so the reviewer is calibrated>

Read the tex source and relevant data files critically. Be rigorous. Do not
do positive reviewing. Identify real weaknesses.

Return in THIS exact format, under N words:

VERDICT: <accept | minor revisions | major revisions | reject>

KEY CONCERNS (numbered, each <= 40 words, actionable):
1. ...
2. ...

MINOR ISSUES (<=5 bullets, <=20 words each):
- ...

STRENGTHS (<=3 bullets):
- ...

Do not implement any changes. Only report.
```

Word budget: 400 for round 1, 300 for round 2, 250 for round 3, 150 for round 4.

## Round cadence

Each round:

1. Dispatch four reviewers in parallel (one single message with four Agent tool calls).
2. Collect verdicts and concerns.
3. Identify the convergent high-impact issues (those flagged by >=2 reviewers).
4. Implement fixes - do not blindly implement all concerns; use the receiving-code-review skill principle (verify before implementing, push back on technically-questionable requests).
5. Recompile PDF, commit, release with a new minor version.
6. Next round: dispatch fresh reviewers, briefing them on what changed and what did not.

Stop conditions:
- Unanimous accept (4/4 accept) - ship.
- A reviewer flags a fatal leakage or statistical error - stop the cycle, fix the analysis, restart at round 1.
- Four rounds reached AND remaining concerns are cosmetic / fill-in (authors / ORCIDs / typography) - ship; document the remaining items in the release notes.
- Four rounds reached AND remaining concerns are scientific (overclaiming, unresolved leakage, missing statistical diagnostics that cannot be generated from the available data) - **do NOT ship**. Options: (i) pivot the venue to a lower-IF journal where the available evidence is sufficient; (ii) add a new analysis phase to address the concern; (iii) reframe the paper as a methods / benchmark contribution if the scientific claim cannot be supported. The skill must not tag a release that carries known-unresolved scientific issues; doing so creates a permanent scholarly record the author will later have to retract or correct.

## What to do with "major revisions"

If >=2 reviewers return major revisions, plan a full reanalysis phase before the next round. Typical triggers:

- Feature-selection leakage (rerun with discovery-only features).
- Missing clinical baseline (add ELN 2022 / IPI / etc. with nested-model C-index).
- Missing stability analysis (add ARI distribution, consensus matrix).
- Overclaiming (abstract and discussion honesty pass).

Do not advance to the next round without addressing the convergent concerns. Partial fixes produce recurring reviews.

## Pitfalls

- Agent tool cannot recover state between rounds - always re-brief with what changed since the last round.
- Reviewer hallucination: a reviewer may cite a paper that does not exist. Verify any cited paper before acting on the concern.
- Consensus is not proof of correctness - if all four reviewers share a misconception, the manuscript is still wrong. Sanity-check convergent concerns against the primary literature.
