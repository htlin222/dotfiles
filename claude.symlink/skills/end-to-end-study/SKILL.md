---
name: end-to-end-study
description: Data-first reproducible research workflow. Given a topic (or none), find the best underutilised public dataset, identify the low-hanging-fruit claim inside it, target the highest-acceptance-probability journal, fetch that journal's author instructions, design method under standard-of-rigor checklist, analyse, write reviewer-and-reader-oriented LaTeX + BibTeX manuscript matching the target-journal style, and ship to a private GitHub repo with CI-built tagged releases bundling PDF + .tex. Use when the user says "end-to-end paper", "take topic to publication", "find a paper in this dataset", "what's publishable here", or asks for a full research pipeline from idea to a tagged release. Good fit for computational-biology, bioinformatics, and clinical-genomics studies on public datasets (TCGA, BeatAML, GEO, GDC, UCSC Xena, cBioPortal).
---

# end-to-end-study

Chain: **best data for novelty** -> **low-hanging fruit** -> **most-likely paper (venue + story)** -> **author instructions** -> **method under rigor checklist** -> **reader/reviewer-oriented writing** -> **reviewer cycle** -> **private repo + tagged release**.

Seven phases. Each phase links to a dedicated reference file.

## Phase 0 - Orientation (30 s)

Confirm with the user: domain (oncology? immunology? neurology?), topic vagueness (is a topic given, or should the skill scan datasets first?), claim type preference (method / translational finding / benchmark). Decline phases outside scope (wet-lab validation, actual journal submission).

## Phase 1 - Best data for novelty (data-first scan)

Novelty usually lives in **under-mined assets of recently released large cohorts**, not in re-analyses of classic datasets. Scan for (1) recent large-cohort releases with a secondary modality that has not been systematically exploited, (2) paired-modality data where one modality is under-used, (3) public drug-response or perturbation screens paired with rich clinical metadata.

See [references/data-first-novelty.md](references/data-first-novelty.md) for the scan heuristics, a catalog of currently-underutilised public datasets, and worked example (BeatAML ex-vivo drug-sensitivity table in Tyner 2018 supplementary).

**Exit criterion**: a primary dataset is named, its under-mined asset is identified, and a short list of 2-3 candidate claims is drafted.

## Phase 2 - Low-hanging fruit selection

Within the chosen dataset, pick the claim with the best effort-to-impact ratio. See [references/low-hanging-fruit.md](references/low-hanging-fruit.md) for the selection matrix (combination-gap claim vs scale-gap vs rigor-gap vs orthogonal-outcome claim), with expected-IF mapping for each type.

Use WebSearch + bioRxiv / PubMed MCP to verify the chosen claim is actually un-done. Heuristics for keyword laddering and gap verification are in [references/novelty-search.md](references/novelty-search.md).

**Exit criterion**: one sentence of the form "No prior work does X in Y; this paper shows Z (effect-size guess)", validated against literature.

## Phase 3 - Target journal + author instructions

Pick the journal where this specific claim has the highest acceptance probability, not the highest IF in absolute terms. See [references/journal-targets.md](references/journal-targets.md) for the tiered catalog with acceptance-probability heuristics. Then immediately **fetch the target journal's author instructions** with WebFetch and distil them into the project-local `manuscript/JOURNAL.md`.

See [references/author-instructions.md](references/author-instructions.md) for the extraction checklist (word limits, figure count, reference style, reporting-guideline requirements, data-availability policy, preprint policy) and canonical author-instructions URLs for Nature Commun, Leukemia, Genome Medicine, Cell Reports Medicine, Blood Cancer Journal, Briefings in Bioinformatics.

Copy the LaTeX skeleton from `assets/latex/` and edit the bibliography style, section order, and figure-count cap to match the target journal.

**Exit criterion**: journal named, author-instructions distilled into `manuscript/JOURNAL.md`, LaTeX template adjusted, tex compiles with placeholder title.

## Phase 4 - Project setup + preregistration + method design

Scaffold with `scripts/init_project.py <project-dir>` (creates `data/raw`, `data/processed`, `data/results`, `analysis/`, `manuscript/`, `figures/`, `docs/`, `.github/workflows/`, `.gitignore`, `LICENSE`, `README.md`, `pyproject.toml`, and a `docs/prereg.md` stub). The script refuses to overwrite existing critical files without `--force` (which takes timestamped backups). Install Python dependencies with `uv add`.

**Commit `docs/prereg.md` before touching any outcome-related analysis.** The preregistration commit is the single most important integrity artefact; skipping it turns any later outcome pivot into HARKing. See [references/preregistration-and-integrity.md](references/preregistration-and-integrity.md) for the required contents and the rules that make the orthogonal-outcome pivot legitimate.

Design the method **before** looking at results. See [references/method-design.md](references/method-design.md) for the rigor checklist (leakage-free feature selection, stability / parameter sweep, permutation null, proportional-hazards tests, nested C-index, calibration + DCA / NRI if clinical, bootstrap CIs, multiple-testing correction). The target journal's author instructions drive the checklist priority - clinical journals weight calibration + DCA; methods journals weight stability + null models.

Common open-dataset URLs and download recipes live in [references/open-datasets.md](references/open-datasets.md); access codes (Open / Gated / Mixed) in [references/data-first-novelty.md](references/data-first-novelty.md) tell you which raw artefacts can be redistributed in the final release.

**Exit criterion**: `docs/prereg.md` committed, data downloaded, analysis scripts stubbed, `uv run python analysis/01_prepare_data.py` succeeds.

## Phase 5 - Analysis, figures, manuscript with journal-matched writing

Iterate analysis -> figures -> LaTeX. Structural conventions in [references/manuscript-structure.md](references/manuscript-structure.md).

Writing style is journal-specific. See [references/reader-reviewer-writing.md](references/reader-reviewer-writing.md) for the explicit reader and reviewer profiles of Nature Commun, Leukemia, Genome Medicine, BCJ, Cell Reports Medicine, Briefings in Bioinformatics, and the abstract-headline + discussion-caveat patterns that work at each. A Leukemia reader expects the clinical hook in the first sentence; a Briefings reader expects the methods gap; a Nature Commun reader expects the broad-interest statement followed by the quantitative headline.

Compile with `cd manuscript && make`.

**Exit criterion**: full PDF compiles; abstract-headline, discussion-caveats, and data/code availability sections match the style targeted at `manuscript/JOURNAL.md`.

## Phase 6 - Reviewer cycle

Dispatch four adversarial reviewers in parallel (methods, clinical, biostatistics, target-journal editor). Iterate until unanimous accept. Pattern and prompt templates in [references/reviewer-cycle.md](references/reviewer-cycle.md). The target-journal editor reviewer is instantiated with that journal's historical concerns - loaded from the author-instructions file produced in Phase 3.

## Phase 7 - Repo and tagged release

Create private GitHub repo, wire CI, push tag, release PDF + .tex + source bundle. Exact commands + CI workflow template in [references/release-workflow.md](references/release-workflow.md). CI template at `assets/github/release.yml`; LaTeX helpers at `assets/latex/Makefile` + `latexmkrc`. Use `scripts/new_release.sh` for a preflight-checked release (rejects dirty git tree, missing `gh` auth, stale placeholder DOIs, absent figures).

Release naming: `v<MAJOR>.<MINOR>.<PATCH>` where MAJOR bumps reflect scientific pivots, MINOR bumps reflect reviewer-round revisions, PATCH bumps reflect typos and terminology.

## Phase 8 - Submission support (optional but expected at IF 10+)

The skill's release workflow ends at a tagged preprint-ready PDF. Actual submission happens off-skill, but the supporting artefacts are templated here:

- Preprint posting (bioRxiv / medRxiv / arXiv) + Zenodo DOI minting: [references/preprint-and-dois.md](references/preprint-and-dois.md). Ship the preprint before the journal submission so the cover letter can cite it.
- Cover letter + point-by-point rebuttal templates: [references/cover-letter-and-rebuttal.md](references/cover-letter-and-rebuttal.md). Rebuttals are the highest-leverage artefact in a revision cycle.
- Submission-portal quirks (Editorial Manager, ScholarOne, Snapsubmit, figure-format, ORCID, supplementary material): [references/submission-portals.md](references/submission-portals.md).
- CRediT authorship, ethics and competing-interests language: [references/credit-and-ethics.md](references/credit-and-ethics.md). Do the CRediT assignment with all authors during Phase 4 or 5; negotiating at the last minute causes submission delays.

## Scripts

- `scripts/init_project.py <project-dir>` - scaffold directory tree, copy LaTeX + GH Actions templates, write `.gitignore`, `LICENSE`, `README.md`, `pyproject.toml`. Run once at start of Phase 4.
- `scripts/new_release.sh <project-dir> <version> "<title>" "<notes>"` - build PDF, stage artefacts into `/tmp`, create tagged `gh release` with PDF + .tex + source bundle. Run at Phase 7 and after every review round.

## Non-goals

- Wet-lab experiments, patient-level trial design, regulatory submission.
- Actual journal submission (the skill ends at a release-tagged preprint-ready PDF matched to one target journal's style).
- Author-name or ORCID fill-in (always prompt the user).

## Pitfalls the skill's references protect against

- Topic-first workflow that picks a fashionable method and shops for data -> Phase 1 is data-first precisely to avoid this.
- Novelty hallucinated from training data -> `novelty-search.md` verifies against current literature.
- Picking the highest-IF journal before checking acceptance probability -> `journal-targets.md` scores fit, not just IF.
- Writing manuscript before reading author instructions -> Phase 3 fetches and distils them up front.
- Gene-panel leakage across cohorts -> `method-design.md`.
- Claims that collapse under a proper clinical baseline -> `reviewer-cycle.md` catches it before submission.
- Release without GPG-signed tag fails on first push -> `release-workflow.md` uses `gh release create` (remote tag) to sidestep local signing.
