# Cover letter and revision rebuttal

The skill's release pipeline ends at a tagged preprint-ready PDF. Actual journal submission and peer review happen off-skill, but the cover letter and the rebuttal letter are closely-templated artefacts that fit the same `manuscript/` directory.

## Cover letter - one page, four paragraphs

Create `manuscript/cover_letter.md` (render to PDF with `pandoc manuscript/cover_letter.md -o manuscript/cover_letter.pdf`). Pattern:

```markdown
<Date>
Dear Dr. <editor name if known, else "Editor">,

We enclose the manuscript entitled "<title>" for consideration at <Journal>.

<PARAGRAPH 1 - the finding, one paragraph>
We report that <headline finding in one sentence, with quantitative effect>. This addresses <specific clinical / biological gap>; using <dataset sizes> and <validation strategy>, we find that <second quantitative finding>.

<PARAGRAPH 2 - why this journal, one paragraph>
The finding advances <Journal>'s readership of <reader profile from reader-reviewer-writing.md> because <journal-specific hook>. It builds on work previously published at <Journal>, specifically <1-2 specific citations>, by <concrete delta>.

<PARAGRAPH 3 - rigor and reproducibility, one paragraph>
The analysis is fully reproducible; code, data-processing scripts and manuscript source are publicly released at <GitHub URL> under tag <v1.0.0> with a Zenodo DOI <10.5281/zenodo.xxx>. We followed the <TRIPOD / STROBE / CONSORT> reporting guideline; a completed checklist is included as Supplementary Table ST1.

<PARAGRAPH 4 - declarations, one paragraph>
This manuscript is not under consideration elsewhere, has been posted as a preprint at bioRxiv <DOI>, and all authors approve submission. We declare no competing interests. Suggested reviewers: <3 names with email and justification>. Opposed reviewers: <0-2 names with one-sentence reason>.

Sincerely,
<Corresponding author>
<Affiliation, email, ORCID>
```

### Cover letter anti-patterns

- "We believe this work is of broad interest ..." - editors filter this as padding.
- Claims not in the manuscript.
- Name-dropping reviewers without technical justification.
- Over-long discussions of prior work - the cover letter is not the introduction.

## Revision rebuttal (response to reviewers)

Every revision submission must include a point-by-point rebuttal. It is the single most important submission artefact, often longer than the cover letter.

Create `manuscript/rebuttal.md` structured per reviewer:

```markdown
# Response to reviewers - <Journal> <manuscript ID>

## Reviewer 1

**Comment 1.1**: <exact quote of reviewer concern>

**Response**: We thank the reviewer for <acknowledge the specific point>. <Specific action taken: what analysis we added, what text we changed, what sentence we toned down>. The revised manuscript reflects this at L<line number> and in new <Figure N / Table N>.

**Revised text**: > "<quoted new sentence(s)>"

**Comment 1.2**: ...
```

### Rebuttal hygiene

- **Quote every reviewer sentence verbatim** before responding. Skipping or paraphrasing is a trust breaker.
- **Show both the response and the exact revised text**, side by side. Editors skim rebuttals; if they cannot see the change, they assume it did not happen.
- **Concede when the reviewer is right**. The dominant failure mode in novice rebuttals is defensive argumentation; it loses acceptances.
- **Push back on technically wrong concerns politely and with evidence**. "We respectfully disagree; the reviewer's concern would hold if <X>, but in our case <evidence>, and Supplementary Figure SN demonstrates this." Never "the reviewer is mistaken".
- **Group related concerns**. If three reviewers raised overlapping points, it is acceptable to cross-reference ("see our response to Reviewer 2 Comment 3") after a full answer in one place.
- **End with a summary of changes**. A bullet list of all text / figure / analysis changes the editor can verify without re-reading the rebuttal.

### Common revision outcomes

| Editor decision | What to do |
|---|---|
| Accept | Nothing. Prepare submission-system final files. |
| Minor revisions | Full rebuttal + clean tracked-changes manuscript. Turnaround within 2-4 weeks. |
| Major revisions | Full rebuttal + new analysis where demanded + clean manuscript. Turnaround 6-12 weeks. Revisit the reviewer cycle in the skill (`reviewer-cycle.md`) before resubmitting. |
| Reject with option to resubmit | Treat as major revisions but flag in the cover letter that this is a resubmission. |
| Reject without option | Run the reviewer-cycle against the rejection reasoning before pivoting venue, then use `journal-targets.md` to select the next-best journal. |

### When the reviewer demands an analysis that is impossible

- If the data does not exist (e.g. treatment covariate not collected), state so plainly: "We agree this analysis would be informative but the variable <X> is not recorded in <dataset>. We now note this as a limitation at Discussion L<N>."
- If the analysis is not meaningful (e.g. power is insufficient), show the power calculation and explicitly decline. This is acceptable at honest journals when the refusal is quantitative.
- If the reviewer and the editor disagree, address both; editors usually side with the reviewer but may allow a scoped decline.

## Final checks before resubmission

- Compile PDF cleanly with `cd manuscript && make`.
- Re-run the full reviewer-cycle (`reviewer-cycle.md`) on the revised manuscript. Fresh reviewers often catch newly-introduced issues.
- Bump the release tag one PATCH version per minor-revision round, MINOR per major-revision round. Include the rebuttal in the tagged release bundle.
