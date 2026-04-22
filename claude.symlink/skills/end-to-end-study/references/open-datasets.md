# Open datasets for computational biology / clinical genomics

Verified download routes used at least once in the skill's reference study. Check URLs before use - data hubs occasionally re-organise.

## TCGA (The Cancer Genome Atlas)

- **UCSC Xena TCGA hub** - the easiest clean source. Per-cancer expression matrices, clinical phenotype matrices, and survival tables ship as flat TSVs.
- Example: TCGA-LAML
  - Expression (log2 RSEM norm_count+1): `https://tcga.xenahubs.net/download/TCGA.LAML.sampleMap/HiSeqV2.gz`
  - Clinical: `https://tcga.xenahubs.net/download/TCGA.LAML.sampleMap/LAML_clinicalMatrix`
  - Survival: `https://tcga.xenahubs.net/download/survival/LAML_survival.txt`
- Replace `LAML` with `BRCA`, `LUAD`, `COAD`, etc. for other cancers.

## BeatAML

- cBioPortal datahub (`aml_ohsu_2018` and `aml_ohsu_2022` study IDs) ships clinical, mutations, RNA-seq CPM - but as Git LFS pointers. Fetch via the `media.githubusercontent.com` CDN:
  - `https://media.githubusercontent.com/media/cBioPortal/datahub/master/public/aml_ohsu_2018/data_clinical_patient.txt`
  - Replace the filename for: `data_clinical_sample.txt`, `data_mutations.txt`, `data_mrna_seq_cpm.txt`, `data_mrna_seq_rpkm.txt`.
- **Ex-vivo drug screen (122 inhibitors x 528 patients)** is in the Tyner 2018 Nature supplementary table S10 inside `supp3.xlsx` (276 MB). Download via Springer:
  - `https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-018-0623-z/MediaObjects/41586_2018_623_MOESM3_ESM.xlsx`
  - Read with pandas `pd.read_excel(path, sheet_name='Table S10-Drug Responses')` (columns: `inhibitor, lab_id, ic50, auc`). Drug-family mapping is in sheet `Table S11-Drug Families`.
- The BeatAML 2022 release ships a native ELN risk column (field name `ELN_2017` in the cBioPortal dump; contents follow ELN 2017/2022 risk tiers), native cytogenetics, and induction-response status on `data_clinical_sample.txt` (columns `ELN_2017`, `KARYOTYPE`, `FLT3_ITD_CONSENSUS_CALL`, `NPM1_CONSENSUS_CALL`, `CEBPA_BIALLELIC_MUTATION`, `INDUCTION_RESPONSE`, `TYPE_INDUCTION_TREATMENT`). These fields make the ELN-lite proxy obsolete - always use the native fields for clinical baselines, and remap to current ELN 2022 tiers where specific 2022 re-classifications apply.

## GEO / GSE

- Individual GEO submissions ship matrices and metadata through `ftp.ncbi.nlm.nih.gov/geo/series/GSE<N>nnn/GSE<N>/suppl/`.
- For single-cell resources like GSE116256 (van Galen 2019 AML scRNA-seq), expect 3-5 GB downloads and Smart-seq2 per-patient matrices.

## cBioPortal datahub

- Browse: `https://github.com/cBioPortal/datahub/tree/master/public`. Each study folder has `meta_study.txt`, `data_clinical_patient.txt`, `data_clinical_sample.txt`, `data_mutations.txt`, and expression data keyed on the study ID.
- Large files are LFS-gated. Use `media.githubusercontent.com/media/...` to bypass the JSON pointer.

## UCSC Xena (non-TCGA)

- PCAWG, Target, CCLE, GTEx normal-tissue data: `https://<hub>.xenahubs.net/`.
- `xenabrowser.net/datapages/` lists hub URLs per dataset.

## Gene symbols and annotation

- HGNC: `https://www.genenames.org/download/statistics-and-files/`.
- Intersect HUGO symbols across cohorts before computing anything shared.

## When in doubt

- Check if a recent (<2 years) benchmarking paper lists a "preprocessed data" download - saves 1-2 days of harmonisation.
- Prefer canonical redistributions (UCSC Xena, cBioPortal) over one-off Dropbox / Zenodo links from single papers, unless that is the only source.
