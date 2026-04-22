# Manuscript structure that survives IF 11+ review

## Section map

```
Title            (<= 15 words, no clickbait)
Abstract         (Background / Methods / Results / Conclusion; <=300 words)
Keywords
1 Introduction       (3 paragraphs: field state -> method primitive -> contribution)
2 Results
  2.1 Study design and cohort composition
  2.2 <Core method result>
  2.3 <Stability / null / robustness result>
  2.4 <Primary outcome result>
  2.5 <External validation result>
  2.6 <Incremental value benchmark>
  2.7 <PH diagnostics and calibration>
  2.8 <Molecular correlates or mechanistic correlates>
3 Discussion     (central finding paragraph -> 3 caveats -> 3 positives -> limitations -> outlook)
4 Methods        (data -> harmonisation -> method -> stability / null -> statistical tests -> reproducibility -> ethics)
Data availability
Code availability
Acknowledgements
Author contributions
Competing interests
References       (BibTeX; unsrtnat or numeric-comp style)
```

## Abstract skeleton

> **Background.** One sentence on field state and gap.
> **Methods.** Pipeline + cohort sizes + validation strategy + robustness moves.
> **Results.** Headline number (with effect size and p-value), second finding, external validation, incremental-value result, honest negative if any.
> **Conclusion.** What the paper does and does not claim; release statement.

## Introduction pattern

- Paragraph 1: field state and clinical / biological motivation. Cite the most authoritative review or guideline (ELN 2022 for AML, NCCN for solid tumours, Sanger CancerGene for drivers).
- Paragraph 2: method primitive in one-sentence intuitions. Cite the foundational paper (Carlsson 2009 for TDA, Breiman 2001 for RF, Vaswani 2017 for transformers) plus one biomedical application.
- Paragraph 3: the gap and the contribution. Numbered `(i), (ii), (iii)` list of concrete contributions. End with "the release includes a reproducible pipeline at <repo>".

## Results section hygiene

- Every subsection begins with the question it answers ("We asked whether...") and ends with the quantitative answer.
- First subsection is always cohort composition with a table or figure panel.
- External validation gets its own subsection, never buried.
- Include an explicit "benchmarking against baseline" subsection with a nested-model C-index ladder. Show the numbers even if the result is null.

## Discussion pattern

- Sentence 1: the central finding, restated in one clause.
- Paragraph 2: three explicit caveats, each starting with "First ...", "Second ...", "Third ...". Naming caveats transparently is the single strongest defence against reviewer #2.
- Paragraph 3: three positive observations (what the paper does establish even after the caveats).
- Paragraph 4: limitations + future-work. Name DCA / NRI / external validation / single-cell extension explicitly if any is missing.

## Methods section invariants

- Data sources URLs (UCSC Xena, cBioPortal, etc.) with exact filenames.
- Harmonisation steps with gene-symbol intersection counts.
- Hyperparameter values explicitly. No "default" - write the number.
- Random seeds explicitly.
- Ethics / IRB statement even when using only public data ("Both datasets are de-identified publicly released resources ...").
- Reproducibility paragraph: Python version, key packages, `uv.lock`, analysis-script numbering, release tag.

## Figure captions

- Bold lead phrase: "**Kaplan-Meier overall survival by topological subgroup.**"
- Panels as `**a**, **b**, **c**` with terse interpretation, not just labels.
- Every abbreviation expanded at first use inside the caption.
- Sample size on every panel.

## Honest-negative framing

When a primary finding fails under a proper baseline, the abstract and discussion must say so plainly. Use phrasing like:

> "Topological subgroups recapitulate but do not augment ELN 2022 risk architecture once ELN 2022 and induction response are included; we therefore do not claim prognostic utility beyond ELN 2022. For ex-vivo drug response, by contrast, ..."

This framing is not a weakness - it is the most efficient way past reviewer #2.

## What to cut

- Any sentence that starts with "It is well known that ..." or "It is important to note that ...".
- Any "we hope to ..." sentence.
- Subheadings that duplicate content. One subsection per finding.
- Citations that do not support the specific claim. Each citation must be checked.
