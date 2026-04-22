# CRediT authorship and ethics declarations

Contributions, authorship order, funding, and ethics language are required by every IF 10+ journal. Standardise them up front.

## CRediT contributor roles

Use the CRediT (Contributor Roles Taxonomy) as a structured way to declare author contributions. The fourteen roles are:

1. Conceptualization
2. Data curation
3. Formal analysis
4. Funding acquisition
5. Investigation
6. Methodology
7. Project administration
8. Resources
9. Software
10. Supervision
11. Validation
12. Visualization
13. Writing - original draft
14. Writing - review & editing

### Pattern for the manuscript section

```latex
\subsection*{Author contributions}
\textbf{<First author>}: Conceptualization, Methodology, Software, Formal analysis, Writing -- original draft. 
\textbf{<Middle author>}: Data curation, Validation, Writing -- review \& editing.
\textbf{<Senior author>}: Conceptualization, Supervision, Funding acquisition, Writing -- review \& editing.
```

### Guidance

- Every author must have at least one role. If they don't, they should be in Acknowledgements, not the author list.
- "Conceptualization" is not automatic - it must be earned; not every author conceived the study.
- "Writing - original draft" typically belongs to one or two authors; "Writing - review & editing" can apply to many.
- The corresponding author is typically listed with Supervision and at least one Writing role.

## Authorship order

Conventions vary by field. For computational biology / clinical genomics:

- **First author**: did most of the analysis and writing.
- **Second ... n-1 authors**: middle authors in rough decreasing-contribution order.
- **Last author**: senior / corresponding author, typically the lab PI.
- **Co-first authors**: two authors with equal contribution; mark with a `$^*$` footnote. Acceptable but inflationary if >2.
- **Co-last authors**: two senior authors with shared supervision; mark similarly.

Changes to authorship after submission require formal letters at most journals and can delay or kill a submission. Agree on order during Phase 4, not after acceptance.

## Ethics and IRB language

### Public-data studies (the skill's default case)

```latex
\subsection*{Ethics and data-use statement}
Both datasets used in this study are fully de-identified, publicly released resources (<TCGA dbGaP study phs000178>; <BeatAML dbGaP study phs001657>). No new human-subjects data were collected. The work falls under the scope of public-data reanalysis and did not require additional institutional review board approval under applicable guidelines. Analysis was performed in accordance with the data-use policies of the relevant consortia.
```

### Gated-access datasets with a DUA

If the dataset required a data-use agreement (MMRF CoMMpass, MSK-CHORD, etc.):

```latex
\subsection*{Ethics and data-use statement}
This study used the <dataset name> under data-use agreement <DUA identifier> approved by <IRB / DAC>. <PI name> is the approved user. All analyses were performed in compliance with the DUA's terms, including the prohibition on redistributing per-participant genotype or clinical data. The dataset access ID is provided to reviewers upon request; raw participant-level data are not included in the public code release.
```

### New patient data (outside this skill's default scope, but occasionally relevant)

```latex
\subsection*{Ethics and data-use statement}
This study was approved by the <Institution> Institutional Review Board (approval number <XXX>). Written informed consent was obtained from all participants.
```

## Funding statement

```latex
\subsection*{Funding}
This work was supported by <Agency> grant <number> (<PI>) and <Agency> grant <number> (<PI>). The funders had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript.
```

- If entirely unfunded, state explicitly: "No external funding was received for this study."
- Grant numbers must be exact; many journals cross-check via Crossref Funder Registry.

## Competing interests

```latex
\subsection*{Competing interests}
The authors declare no competing interests.
```

If any author has a relevant financial interest (consulting, equity, patents), disclose:

```latex
\subsection*{Competing interests}
<Author X> serves as a consultant for <Company>. <Author Y> holds equity in <Company>. The other authors declare no competing interests.
```

## Data and code availability - canonical phrasing

```latex
\subsection*{Data availability}
<Dataset A> was accessed via <URL or accession>. <Dataset B> was accessed via <URL or accession>. No restricted-access patient-level data were used. Processed data generated in this study are deposited at Zenodo under DOI \texttt{10.5281/zenodo.<n>}.

\subsection*{Code availability}
Source code, LaTeX sources, and compiled PDF are released under the MIT licence at \url{https://github.com/<user>/<slug>} (tag \texttt{v<tag>}). A persistent snapshot is archived at Zenodo: \texttt{10.5281/zenodo.<n>}.
```

## Reviewer-suggested and opposed reviewers

Most journals ask for 3-5 suggested reviewers. Conventions:

- Suggest experts in the specific method and the specific disease. One of each is insufficient; aim for 2 method + 2 disease.
- Avoid direct collaborators, co-authors in the last 3 years, and people at your institution.
- One-sentence justification for each: "<Name, affiliation> is an expert on <topic relevant to this manuscript>."
- Provide current institutional emails; personal emails trigger editor skepticism.

For opposed reviewers (0-2): use only when there is a clear conflict (patent dispute, recent public dispute). Do not use the field to exclude honest critics.
