# Low-hanging fruit selection

Once the dataset is chosen, pick the claim with the best effort-to-impact ratio. Not every gap is worth chasing.

## Four claim archetypes, with effort and IF potential

| Archetype | Claim form | Typical effort (person-weeks) | Typical IF ceiling |
|---|---|---|---|
| Combination-gap | Method M applied to outcome O in dataset D, never done before | 2-6 | 11-17 (Nature Commun, Genome Medicine) |
| Scale-gap | Prior work at N=30; we replicate at N=500 with external validation | 4-8 | 8-12 (specialty venues) |
| Rigor-gap | Prior work claimed X; with leakage control + proper baseline it collapses; honest negative | 2-4 | 8-11 (methods venues, BCJ) |
| Orthogonal-outcome | Method M does not predict X but predicts Y, which prior work did not test | 4-8 | 13-18 (high-IF when Y is clinically actionable) |

## Selection matrix

Score each candidate claim on five axes (0-3 each). Proceed with the highest total.

| Axis | What to score |
|---|---|
| Novelty (verified) | 0 = prior paper exists, 3 = literature search returned nothing |
| Clinical / biological actionability | 0 = descriptive only, 3 = decision-changing or drug-target |
| Data leverage | 0 = uses classic modality only, 3 = exploits an under-mined secondary asset |
| Effort to result | 0 = needs new wet-lab, 3 = everything in one analysis session |
| Evidence ceiling | 0 = ambiguous even if successful, 3 = a single plot settles it |

Sum >= 10: strong fruit. Sum 7-9: viable but plan more carefully. Sum < 7: pick a different claim.

## Orthogonal-outcome pattern (highest IF-per-effort)

When a method fails to beat the clinical baseline on the primary outcome, look for an outcome the baseline does not address. Examples:

- TDA subgroups did not beat ELN 2022 for overall survival; they predicted ex-vivo drug sensitivity that ELN 2022 never claimed to predict - pivot to drug response, IF ceiling rose from 8 to 17.
- Molecular signature does not beat clinical TNM for overall mortality; it predicts time-to-second-line-therapy that TNM does not track.
- Methylation clock does not improve all-cause mortality over age; it predicts treatment toxicity that age does not predict.

This pattern is the single highest IF-per-effort move. Always ask: "what outcome does the baseline not claim to address, and does my method work there?"

## Honest-negative-as-methodology pattern

A rigor-gap finding (prior work was wrong) is publishable at IF 8-11 if:

- The rigor gap is methodologically specific (leakage, selection bias, improper baseline, inflated test statistics, weak external validation).
- The corrected analysis yields a clean null or a substantially-attenuated effect.
- The paper is framed as benchmarking or methodology, not as attacking the prior authors.

Honest negatives are often easier to publish than weak positives.

## When to pivot the fruit mid-analysis

**Preregistration prerequisite**: before running `analysis/01_prepare_data.py`, commit `docs/prereg.md` naming the primary outcome and any pre-specified secondary outcomes. See [preregistration-and-integrity.md](preregistration-and-integrity.md). The steps below are valid only inside that preregistered frame; performing them without a preregistration is HARKing.

Once initial analysis yields null on the primary outcome, do not fight the null:

1. Check whether the null is from a leakage fix or a genuine absence (if the unfixed analysis was positive, the leakage-fixed version is the scientific truth).
2. If a pre-specified secondary outcome addresses an orthogonal question, escalate it to a secondary finding - with explicit multiple-testing correction across every outcome tested.
3. If no pre-specified secondary applies, outcomes discovered during analysis are **exploratory**; report them labelled as such, with FDR control across the full set of outcomes tried.
4. Reframe the narrative around the dissociation (concordant with baseline for X, orthogonal for Y) only when the pivot outcome was pre-specified or is honestly labelled exploratory.
5. Abandon or downgrade the study if there is no orthogonal outcome, no pre-specified secondary, and no rigor-gap frame available. Publishing a single surviving post-hoc finding from a large exploratory tree is HARKing.

## Pitfalls

- Picking a claim because the method excites you rather than because the evidence supports it.
- Going for the highest-IF ceiling when the sum of the selection matrix is below 7.
- Ignoring the effort axis - "ambitious but takes 12 months" is not low-hanging fruit.
- Confusing "no one has done X" with novelty - sometimes no one has done X because X is not interesting.
- Pivoting the primary outcome after seeing a null without preregistration. This is HARKing; see `preregistration-and-integrity.md`.
- Reporting only the surviving outcome from a large exploratory tree without multiple-testing correction across the full tree.
