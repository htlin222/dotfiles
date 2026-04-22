# Author-instructions fetch and distil

Before writing, pull the target journal's author instructions and distil them into a per-project `manuscript/JOURNAL.md`. Every decision downstream (word limit, figure count, reference style, reporting-guideline compliance) derives from this file.

## Canonical author-instruction URLs

| Journal | URL |
|---|---|
| Nature Communications | `https://www.nature.com/ncomms/submission-guidelines` |
| Leukemia | `https://www.nature.com/leu/submission-guidelines` |
| Genome Medicine | `https://genomemedicine.biomedcentral.com/submission-guidelines/preparing-your-manuscript` |
| Blood Cancer Journal | `https://www.nature.com/bcj/for-authors` |
| Cell Reports Medicine | `https://www.cell.com/cell-reports-medicine/authors` |
| Briefings in Bioinformatics | `https://academic.oup.com/bib/pages/General_Instructions` |
| PLOS Computational Biology | `https://journals.plos.org/ploscompbiol/s/submission-guidelines` |
| npj Precision Oncology | `https://www.nature.com/npjprecisiononcology/for-authors` |

Use `WebFetch` with a distillation prompt to pull the exact numbers; the URLs above sometimes redirect to parent navigation pages.

## Distillation checklist

From each journal's author instructions, extract into `manuscript/JOURNAL.md`:

1. **Word limit** (abstract + main text) and whether methods count towards the main-text total.
2. **Figure and table count** caps; are figure-plus-tables combined or separate?
3. **Reference count cap** (important - Nature journals often cap at 50-70).
4. **Reference style**: natbib unsrtnat vs vancouver vs numeric-comp; numbered vs author-year; superscripts yes/no.
5. **Section structure** expectations (Nature Commun: Introduction / Results / Discussion / Methods vs IMRAD variants).
6. **Abstract format** - structured (Background / Methods / Results / Conclusion) vs unstructured.
7. **Data availability** policy - require a statement? GEO / dbGaP / Zenodo accession required before submission?
8. **Code availability** policy - GitHub link acceptable? DOI via Zenodo required?
9. **Preprint policy** - bioRxiv allowed / encouraged / required?
10. **Ethics / IRB statement** format.
11. **Reporting-guideline compliance** required (TRIPOD for prediction models, STROBE for observational studies, CONSORT for trials, ARRIVE for animal work, STARD for diagnostic accuracy). Clinical-prognosis manuscripts almost always require TRIPOD; attach a completed checklist as supplementary.
12. **Author-contributions** statement format (CRediT taxonomy vs free text).
13. **Competing-interests** statement format.
14. **Supplementary material** - single PDF vs separate files, naming conventions.
15. **Cover-letter requirements** - mandatory / optional / required explanation of novelty.

## Distilled-file template (`manuscript/JOURNAL.md`)

```markdown
# Target: <Journal name>

## Evidence expectations
- Word limit: <N words main + <M words abstract>
- Figures: <N figures, N tables cap>
- References: <cap>
- Reference style: <natbib / numeric-comp / vancouver>
- Abstract: <structured / unstructured>
- Section order: <Nature Commun / IMRAD / custom>

## Mandatory statements
- Data availability: <required text pattern>
- Code availability: <required text pattern>
- Ethics: <required text pattern>
- Competing interests: <required>
- Author contributions: <CRediT / free-text>

## Reporting-guideline compliance
- <TRIPOD / STROBE / ARRIVE / etc.> - checklist attached as Supplementary

## Reader profile (see reader-reviewer-writing.md)
- <one-sentence reader description>

## Reviewer profile
- <one-sentence typical reviewer description>

## Cover-letter hook
- <one sentence that will lead the cover letter>
```

## LaTeX template adjustments per journal

- **Nature Commun / Leukemia / BCJ / npj Precision Oncology**: `natbib` with `unsrtnat` style, numbered references superscript; keep `\bibliographystyle{unsrtnat}`.
- **Genome Medicine**: author-year citations; switch to `\bibliographystyle{plainnat}` with `natbib` in `authoryear` mode.
- **Cell Reports Medicine**: Cell Press numbered style; either `unsrtnat` or the Cell LaTeX class.
- **Briefings in Bioinformatics**: numeric-comp style; switch to `\bibliographystyle{vancouver}`.
- **PLOS Comp Biol**: PLOS house style numbered; `plos2015.bst` from CTAN.

## Tips

- Do not trust a summary - pull the actual URL and read the constraints. Journals update instructions every 12-18 months.
- If the journal has a LaTeX template on its website, download and adapt rather than starting from the generic template in `assets/latex/main.tex`.
- Word count: if the target journal enforces a strict main-text word limit, run `texcount manuscript/main.tex` after compilation.
- Reporting guidelines: the TRIPOD 2015 checklist (for risk-prediction models) is specific about what must appear in abstract, methods, results, and discussion - checking it during drafting prevents reviewer #2 pain.
