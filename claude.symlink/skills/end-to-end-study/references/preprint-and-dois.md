# Preprints and persistent DOIs

The skill's release is a tagged GitHub release. Modern high-IF journals expect additionally (i) a preprint on bioRxiv / medRxiv / arXiv with a citable DOI, and (ii) a Zenodo DOI that freezes the exact commit used to produce the submitted figures. Both are free.

## Preprint: bioRxiv / medRxiv / arXiv

### Which server

- **bioRxiv** (`biorxiv.org`): life sciences non-clinical (genomics, bioinformatics, cell biology). Default choice for this skill.
- **medRxiv** (`medrxiv.org`): clinical / epidemiology / health research. Choose if the paper includes patient-level clinical data or clinical-trial outcomes.
- **arXiv** (`arxiv.org`) q-bio section: methods-focused papers with mathematical content. Less common for clinical-genomics.

Submitting to the wrong server results in a category-change request that wastes 2-3 days.

### Prerequisites

- A PDF (the tagged release PDF).
- A LaTeX source bundle (bioRxiv accepts .tex + .bib + figure PDFs in a zip; the skill's `source-bundle.tar.gz` qualifies after re-tarring as `.zip`).
- ORCID for every author.
- A 250-word abstract matching the PDF.
- Agreement to the preprint licence (CC-BY by default; CC-BY-NC or CC0 also allowed).

### Timing relative to journal submission

- Target journals that **explicitly encourage** preprints (most Nature portfolio, all BMC, PLOS, Cell Press, Elsevier): post to bioRxiv **before** submitting to the journal. Include the preprint DOI in the cover letter.
- Target journals that **discourage or forbid** preprints (rare now; a small number of clinical journals): check Sherpa/Romeo (`v2.sherpa.ac.uk/romeo`) before posting.
- Once the preprint is live, cite it in the GitHub release notes and in the `manuscript/JOURNAL.md`.

### Preprint version hygiene

- Version 1 (v1) goes up at first journal submission.
- Version 2 (v2) after each revision the journal requests. Post only when the revised manuscript is being resubmitted; do not post interim drafts.
- Final published version: do not replace the preprint; preprint servers link to the journal version automatically via the DOI.

## Zenodo DOI for code + data

### Why

Reviewers at IF 11+ journals increasingly demand a persistent (non-GitHub-mutable) DOI for the code and processed data. GitHub URLs rot; repositories can be renamed, taken private, or deleted. Zenodo snapshots each tagged release immutably.

### One-time setup

1. Sign in to Zenodo (`zenodo.org`) with your GitHub account.
2. Go to `zenodo.org/account/settings/github` and toggle the study repository to **on**.
3. From now on, every time you push a tag matching the GitHub release semantics (`v*`), Zenodo automatically creates a new version and mints a DOI.

### Using the DOI

- Each release tag has its own DOI (`10.5281/zenodo.<n>`).
- There is also a "concept DOI" (also shown in Zenodo) that resolves to the latest release - use this in the manuscript Code Availability section so citing the paper never goes stale.
- Include the version-specific DOI in the cover letter and release notes (so reviewers can verify the exact code used for the submitted figures).

### Zenodo metadata

- Title: `<manuscript title> (v<tag>)`
- Authors: match the manuscript author list.
- Licence: match the repo licence (MIT for code, CC-BY 4.0 for data).
- Keywords: match the manuscript keywords.
- Related identifiers: add the preprint DOI (`is supplement to`) and the GitHub URL (`is derived from`).

## Data deposition DOIs

Separately from code, processed data artefacts (not raw dbGaP data) may require their own deposition if the journal's data-availability policy is strict.

- **Figshare** (`figshare.com`): good for single large processed matrices (e.g. harmonised expression matrix with a DOI). File size limit 20 GB.
- **Zenodo**: smaller processed artefacts; suits the source-bundle.tar.gz shipped by the release workflow.
- **GEO** (expression), **dbGaP** (controlled access): raw data you generated yourself.
- **Dryad** (`datadryad.org`): data repositories with an editorial layer; required by some clinical journals.

### What to deposit

- Processed expression / drug-response / clinical matrices.
- Results tables (subgroup labels, Cox coefficients, calibration tables).
- Figures (PDF + PNG + source data CSV).
- NOT raw patient-level data from dbGaP / EGA - that stays where it is.

## Verification

Before submitting to the journal:

- Preprint DOI resolves and opens the PDF: `https://doi.org/10.1101/<preprint id>`
- Zenodo DOI resolves and shows the code snapshot: `https://doi.org/10.5281/zenodo.<n>`
- GitHub repo is public (flip from private at this stage).
- Both DOIs are cited in the manuscript's Code Availability and Data Availability subsections.
- Cover letter mentions the preprint DOI.
