# Submission-portal quirks

Journal submission systems accept the PDF but impose idiosyncratic requirements that trip first-time submitters. Check the relevant subsection before hitting submit.

## Common submission systems

| System | Journals | Quirks |
|---|---|---|
| Editorial Manager | Elsevier, Cell Press, Lancet, NEJM | Wants a single PDF containing text + figures + tables + supplementary (merged). Strict on line numbers. |
| ScholarOne Manuscripts | Wiley, Taylor & Francis, Oxford Academic | Separate file uploads per component. Tracks authorship via ORCID. |
| Snapsubmit / Springer Nature portal | Nature journals | Allows either a single PDF or separate files. Requires ORCID for corresponding author. |
| BMC submission system | BMC (Genome Medicine, etc.) | Accepts LaTeX directly; compiles server-side. Good option for TeX-native manuscripts. |
| bioRxiv / medRxiv | Preprints | One PDF + one source zip. Separate tool from journal submission. |

## Figure-file requirements

High-IF journals enforce image-format rules more strictly than the rest. Before submission, prepare:

- **Main-text figures**: 300 DPI minimum. PDF vector-graphics preferred for line art; TIFF for photographs. Some Nature journals want TIFF CMYK at 300 DPI, 18cm width for two-column figures.
- **File naming**: `Figure_1.pdf`, `Figure_2.pdf`, ... (no `Fig1`, no spaces, no `_final_v3`). Check the journal's naming spec; some want `Fig1.tiff`.
- **Figure legends**: often submitted separately as a text file, not embedded in the main PDF.
- **Source-data files**: per-panel CSVs for each quantitative figure. Nature journals now require them as Supplementary Data.

The skill's Fig*.pdf naming convention matches most requirements; rename to `Figure_N.pdf` just before upload.

## Main-text PDF assembly

- Line numbers: most journals want continuous line numbers across the full manuscript (including methods). Enable with `\usepackage{lineno}` + `\linenumbers` in preamble.
- Page numbers: continuous, visible on every page.
- Single-column format for preprint-like submission PDFs; the journal typesets the final layout.
- Figure placement: in-text in the PDF matters less than people think; what matters is that each figure is referenced in order and captioned inline.

## Supplementary material

Conventions vary, but most IF 10+ journals accept:

- A single supplementary PDF containing all Supplementary Figures and Tables.
- Separate CSV / XLSX files for data tables and source data.
- A supplementary methods section, typically several pages, if methods section in the main text is length-capped.
- Reporting-guideline checklists (TRIPOD, STROBE) as standalone PDFs.

Name everything with the prefix `Supplementary_`.

## ORCID and authorship

- Every author needs an ORCID. Create at `orcid.org` if missing.
- Some journals (Nature portfolio) require ORCIDs before a submission can proceed.
- Author order: confirm with all coauthors before uploading; changing order post-submission requires a formal letter at most journals.
- Corresponding author email: use an institutional email; personal gmail addresses trigger desk rejection at some clinical journals.

## Declarations embedded in the submission form

Beyond the manuscript's declarations section, the portal typically asks:

- Data availability: paste the text from the manuscript.
- Code availability: paste the GitHub URL and the Zenodo DOI.
- Funding: list every grant that supported the work. Include grant numbers.
- Competing interests: even if none, an explicit statement is required.
- Ethics statement: even for public-data studies. Use the language from `main.tex` ethics subsection.
- Preprint: paste the bioRxiv DOI.
- Prior submission history: if the manuscript was previously rejected elsewhere, disclosure is usually required.

## Submission day checklist

Before clicking submit:

- [ ] Cover letter (`manuscript/cover_letter.pdf`).
- [ ] Main text PDF with line numbers (`manuscript/main.pdf`).
- [ ] Source LaTeX + BibTeX bundle (`release/v<tag>/source-bundle.tar.gz`).
- [ ] Each figure as separate high-resolution file (renamed to journal convention).
- [ ] Figure legends as separate text file.
- [ ] Supplementary PDF (methods, figures, tables).
- [ ] Reporting-guideline checklist (TRIPOD / STROBE / etc.) as separate PDF.
- [ ] Data-availability statement with URLs and accession numbers.
- [ ] Code-availability statement with GitHub URL + Zenodo DOI + release tag.
- [ ] ORCIDs for all authors.
- [ ] Preprint posted to bioRxiv / medRxiv, DOI available.
- [ ] Three suggested reviewers with emails and one-sentence justifications each.
- [ ] Every coauthor has seen and approved the submission draft (email record).

## After submission

- Expect an automated confirmation email within 24 hours with a manuscript ID.
- Editorial decision timeline varies: desk rejection 1-2 weeks; first-round reviews 6-10 weeks at Nature portfolio, 4-8 weeks at BMC, 2-6 weeks at specialty journals.
- Do not nudge the editor before the journal's stated expected turnaround.
- Update the bioRxiv preprint only when the revised manuscript is being resubmitted - not during peer review.
