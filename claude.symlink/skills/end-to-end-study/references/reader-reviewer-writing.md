# Reader- and reviewer-oriented writing by journal

Rewriting the same manuscript for a different target journal is mostly about re-ordering the reader hooks and anticipating a different reviewer profile. Use this file to match the voice to the venue.

## Reader profile + opening hook pattern

| Journal | Reader profile | First-sentence hook |
|---|---|---|
| Nature Communications | Interdisciplinary scientist; wants broad-interest signal | "<Biological or clinical problem> remains unsolved despite <prior effort>; here we show that <method> <quantitative result>." |
| Leukemia | Clinical haematologist + research clinician | "<Clinical management gap in AML/lymphoma/MDS>; we ask whether <method> addresses it and find <actionable finding>." |
| Genome Medicine | Translational genomics researcher, often clinician-scientist | "Despite <guideline> (ELN 2022 / NCCN / ACMG), <clinical gap>; here we leverage <dataset> to <quantitative finding>." |
| Cell Reports Medicine | Translational biologist, precision-medicine-leaning | "<Disease> stratification still relies on <classic biomarker>; we integrate <new modality> and demonstrate <orthogonal actionable outcome>." |
| Blood Cancer Journal | Haematology specialist + community clinician | Short, direct: "<Method> applied to <BeatAML / MMRF / TARGET> predicts <drug response / relapse / OS> with <effect size>." |
| Briefings in Bioinformatics | Methods-focused bioinformatician | "Current <method class> pipelines suffer from <rigor gap>; we present <improved method> and benchmark on <N datasets>." |
| PLOS Comp Biol | Quantitative biologist | Methodological framing: "<Problem>; we introduce <method>; on <benchmark> it achieves <metric>." |

## Reviewer profile (what they will demand)

| Journal | Reviewer 2 will demand |
|---|---|
| Nature Communications | Broad-interest positioning, clean cross-reference consistency, figure quality, novelty delta vs 3+ cited prior arts, TRIPOD if clinical prediction, data / code DOI |
| Leukemia | Comparison against ELN 2022 / guideline baseline, treatment-aware analyses, induction-response and HSCT adjustments, reporting at the haematology-specialist terminology level (FAB, AML-MRC, etc.) |
| Genome Medicine | Clinical usefulness beyond existing guideline, decision-curve analysis, net reclassification index, external validation in >=2 cohorts, reporting of incremental C-index with bootstrap CI |
| Cell Reports Medicine | Mechanistic or at least mechanism-adjacent interpretability, clinical actionability statement, supplementary reproducibility statement |
| Blood Cancer Journal | Benchmarking, open data release, comparison against current AML standard of care |
| Briefings in Bioinformatics | Comparative benchmarking across >=3 methods, ablation studies, runtime and memory reporting, clean open-source code |
| PLOS Comp Biol | Method-first writing, theoretical justification, benchmark on synthetic and real data |

## Abstract headline patterns

- **Nature Commun dissociation pattern**: "We find that <method> is concordant with <baseline> for <outcome X> but orthogonal to <baseline> for <outcome Y>, where <outcome Y> is <clinically meaningful>."
- **Genome Medicine incremental-value pattern**: "Adding <method> to <baseline> increases <C-index or AUC> from <X> to <Y> (<95% CI>), with <ΔLR chi-square> on <df> degrees of freedom; decision-curve analysis shows <quantitative net benefit> at <threshold>."
- **Leukemia actionable-finding pattern**: "<Method> stratifies <patient subset>, with <sensitive subgroup> showing <effect on drug A> (<metric>) and <resistant subgroup> showing <effect on drug B>."
- **Briefings benchmarking pattern**: "<Method> matches <state of art> on <benchmark 1> while requiring <efficiency gain> and extending to <new scenario> not covered by <state of art>."

## Discussion caveat pattern

Clinical / high-IF reviewers expect explicit caveats, phrased actionably:
```
We emphasise three caveats. First, <honest limitation A> - this is a known feature of <dataset / method> and we quantify it as <number>. Second, <honest limitation B>. Third, <honest limitation C>. Notwithstanding these, three positive observations warrant emphasis. First, <positive A>. Second, <positive B>. Third, <positive C>.
```

Reviewers trust papers that explicitly enumerate their own weaknesses.

## Reader-convenience elements reviewers love

- **First paragraph of Results**: always cohort composition with sample sizes and follow-up time.
- **Every effect size with 95% CI**: no p-value without an effect size.
- **Explicit statement of what is NOT claimed**: "We do not claim X" pre-empts reviewer over-reading.
- **Nested model ladder as a table in the main text**: one row per incremental covariate set, with ΔLR on df and bootstrap C-index CI. This single table defuses most reviewer #2 objections at clinical journals.
- **Decision-curve analysis panel** if the claim is clinical utility.
- **Reporting-guideline checklist** as supplementary.

## Style switches by venue

- Nature Commun: avoid "Interestingly, ...", "We note that ...", "It is tempting to speculate ...". Directness preferred.
- Leukemia: use clinical terminology (FAB, ELN 2022 tiers, HSCT, MRD) without defining on first use; readers know.
- Genome Medicine: define genomic terminology on first use; readers may be computationally-leaning clinicians.
- Briefings in Bioinformatics: methods terminology can be assumed; readers know hyperparameters, train/test splits.
- PLOS Comp Biol: more mathematical formality encouraged.

## Anti-patterns

- "Significantly" used without effect size and p-value.
- "Novel" without the explicit contrast against prior art.
- "We show that <method> improves <metric>" without saying by how much.
- Burying the effect size in a supplementary table.
- Starting the discussion with a restatement of results ("In this paper we have shown ..."). Start with the central finding.
- Discussion caveats hidden in the last paragraph; reviewers expect them up front.

## Venue-specific title patterns

- Nature Commun: <=15 words, one concrete finding, no colons ("Topological stratification of AML predicts ex-vivo drug sensitivity beyond ELN 2022").
- Leukemia / BCJ: can use a haematology-specific qualifier ("in acute myeloid leukaemia").
- Genome Medicine: translational qualifier ("for precision risk stratification").
- Briefings in Bioinformatics: methods qualifier ("a benchmark of X across Y cohorts").
- Avoid question-titles; reviewers read them as under-confident.
