# Preregistration and research-integrity safeguards

The skill's data-first scan + low-hanging-fruit selection + orthogonal-outcome pivot pattern is powerful but sits adjacent to HARKing (Hypothesising After the Results are Known) and p-hacking. Follow the rules below to stay on the integrity-respecting side.

## The rule

Before any analysis is run against the outcome of interest, write a dated preregistration file `docs/prereg.md` in the project. Commit it to git before `analysis/01_prepare_data.py` is executed the first time. It does not need to be a public OSF preregistration; a timestamped git commit is sufficient for self-accountability and for reviewer defence.

Minimum contents:

```markdown
# Preregistration - <study slug>

Date: <YYYY-MM-DD>
Commit at time of preregistration: <commit hash will be recorded by git>

## Primary outcome
<one sentence; exact variable, exact statistic, exact threshold>

## Primary hypothesis
<directional hypothesis with expected effect size>

## Confirmatory analysis plan
<Cox model formula; covariates; test statistic; rejection threshold>

## Secondary (pre-specified) outcomes
<list, each with analysis plan>

## Exploratory analyses
<listed and explicitly marked as exploratory; results from these cannot be
promoted to primary>

## Stop rules
<when do we declare the primary hypothesis refuted; what counts as a clean null>
```

## The orthogonal-outcome pivot under integrity rules

The pivot pattern in `low-hanging-fruit.md` is legitimate only when:

1. The secondary outcome was named in the preregistration. If it was not, it is exploratory and the paper must label it as such.
2. The primary-outcome null is reported with equal prominence to the pivot finding. The abstract must include both.
3. The paper explicitly states "the primary endpoint was <X>; the result on <X> was <null or attenuated>; we then investigated <Y> as a pre-specified secondary outcome / as an exploratory analysis".

If the secondary outcome was not pre-specified, report it as exploratory with appropriate multiple-comparison correction. Do not re-draft the paper as if the exploratory outcome had always been primary; this is HARKing and will be detected by sophisticated reviewers through cross-referencing with the preregistration or with patterns of citation in the introduction.

## Multiple-testing when pivoting

When pivoting from a failed primary outcome to an exploratory one, the family-wise error rate is the number of outcomes tried, not the outcomes reported. Apply Bonferroni or BH-FDR across the full set. The skill's `method-design.md` multiple-testing guidance is insufficient for this case; augment with a paragraph that names every outcome tested, including the failed primary.

## Pre-specified vs post-hoc subgroup analyses

Subgroup analyses of outcomes (e.g. drug-response per topological subgroup) are acceptable when:

- The subgroups were defined from transcriptomic data alone, before survival or drug outcomes were touched.
- The subgroup labels are frozen before the pivot is made.
- Subgroup counts and definitions appear in the preregistration.

Subgroup splits chosen after seeing the outcome are post-hoc; report them as such.

## What reviewers check for

- Does the introduction's framing match the preregistered hypothesis or the observed finding? Mismatch is HARKing.
- Does the abstract lead with the pivot finding and bury the primary-outcome null in the methods? Bury pattern is HARKing.
- Is the effect size of the pivot finding similar to what would be expected under a selective-reporting null? If 50 outcomes were tested and one survives at p=0.01, it is probably chance.
- Are confidence intervals and p-values adjusted for the multiple outcomes attempted?

## The honest-negative publication path

If the primary hypothesis is refuted and no pre-specified or sensibly-exploratory secondary outcome survives, the study is still publishable as a rigor-gap or replication paper at mid-IF methods venues (Briefings in Bioinformatics, PLOS Comp Biol, Bioinformatics). Do not force a positive claim out of a null study. Do not silently drop the study and reuse the dataset on a new hypothesis without preregistering the new hypothesis first.

## Integration with the skill's workflow

- `low-hanging-fruit.md` orthogonal-outcome pivot is valid only with a written preregistration predating the pivot.
- `novelty-search.md` "when to pivot the claim" - the same rule applies; the pivot must have been anticipated as a pre-specified secondary, or must be labelled exploratory.
- `reviewer-cycle.md` - the editor-reviewer profile must include a check for HARKing alignment.

## When the skill is used for a non-preregistered reanalysis

If the dataset has already been analysed by the skill's user before, the "primary outcome" is effectively post-hoc. In this case:

- Frame the paper as a methodological benchmark or a secondary-data reanalysis, not as a novel discovery.
- Cite the prior analyses.
- Lower the IF target accordingly; aiming a benchmark at Nature Communications invites rejection.

Integrity is not a cost; it is the condition for high-IF acceptance.
