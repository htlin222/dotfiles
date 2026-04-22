# Journal targeting (high-IF genomics and clinical methods venues)

Pick the journal **before** writing. The journal sets evidence bars (is a decision-curve analysis expected?), figure count, word limits and LaTeX template style.

Catalog last verified: 2026-04. Impact factors and policies drift 12-18 months; re-check the journal's current author instructions during Phase 3 (see `author-instructions.md`). The IF numbers below are rounded to the nearest integer and should be treated as indicative, not authoritative.

## Tier 1 - Realistic high-IF shots

| Journal | Approx IF | Scope | Typical paper | LaTeX class |
|---|---|---|---|---|
| Nature Communications | 17 | Broad, methods + translational | 4000-8000 words, 4-8 figures, supplementary unlimited | article.cls with single-column preprint style; Nature LaTeX package available but optional |
| Leukemia (Nature Portfolio) | 14 | Haematological malignancy focus | 3500-5000 words, 5-7 figures | Nature-Portfolio class or article.cls |
| Cell Reports Medicine | 15 | Translational, precision medicine | 5000-8000 words, 5-8 figures | Cell Press class |
| Genome Medicine | 11 | Genomics + translational | 4000-6000 words, 4-6 figures | BMC article class |

Nature Communications is the highest-IF clean shot for computational-biology methods papers with a translational finding. Genome Medicine has the friendliest review process for honest-negative + open-pipeline work.

## Tier 2 - Specialty flagships

| Journal | Approx IF | Scope |
|---|---|---|
| Blood Cancer Journal | 13 | Open access, haematology, benchmarking-friendly |
| npj Precision Oncology | 9 | Precision oncology, methods + clinical |
| Briefings in Bioinformatics | 9 | Methods / benchmarking, reviews |

## Tier 3 - Methods-forward

| Journal | Approx IF | Scope |
|---|---|---|
| Bioinformatics | 5 | Algorithms and software |
| PLOS Computational Biology | 4 | Quantitative biology methods |
| Nature Machine Intelligence | 19 | ML methods (higher bar for novelty) |

## Decision rules

- **Positive translational finding, reproducible pipeline, external cohort**: Nature Communications or Leukemia.
- **Dissociation finding (e.g. concordant with baseline for X, orthogonal for Y)**: Genome Medicine or Cell Reports Medicine (they reward nuanced stories).
- **Honest-negative + methods artefact**: Briefings in Bioinformatics or PLOS Comp Biol.
- **Wet-lab + genomics integration**: Blood Cancer Journal (haem) or Cancer Research (solid).

## Template choice

The skill ships a Nature-Communications-style single-column template (`assets/latex/main.tex`). It is compatible with Leukemia, Genome Medicine, BCJ, npj Precision Oncology and Briefings in Bioinformatics after light edits (section renaming, reference-style swap from natbib unsrtnat to vancouver or numeric-comp).

Do not use the official Nature LaTeX class for preprint work unless the user explicitly requests it; the class is finicky and not needed for preprint posting or most submission portals.

## Cover-letter triggers by venue

- **Nature Communications**: lead with the dissociation or novel finding; emphasise reproducibility and external validation.
- **Genome Medicine**: lead with the clinical hypothesis and the gap in existing risk rules.
- **Leukemia**: lead with the haematology context and actionable drug implications.
- **BCJ**: open-access angle; emphasise dataset release.
- **Briefings in Bioinformatics**: emphasise the benchmarking contribution and the code release.
