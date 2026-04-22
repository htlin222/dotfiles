# Data-first novelty scan

Novelty in computational biology almost always lives in an **under-mined asset of a recently-released large cohort**, not in re-analysing the classic datasets everyone else has already re-analysed. Start from the data, not the topic.

## The scan

Three passes, up to five WebSearch tool calls total.

### Pass A: recent large-cohort releases

Query: `<disease or field> large cohort public release 2024 OR 2025`. Look for:
- Cohort papers published in the last 18-24 months in Nature, Cancer Cell, Blood, Cell, NEJM.
- Update releases of established cohorts (BeatAML 2.0, TCGA Pan-Cancer 2018 second-wave, PCAWG 2020, GTEx v8).

### Pass B: secondary modalities

For each cohort identified, check what primary finding the release paper made. The **secondary modality** - the data released but not the headline - is where novelty lives. Examples:
- BeatAML 2018: headline was clinical-genomic correlation; the **ex-vivo drug-sensitivity matrix of 122 compounds x 528 patients** was an under-used secondary asset (Tyner 2018 Supplementary Table S10).
- TCGA-LAML 2013: headline was the integrated mutation landscape; **cytogenetic-risk and FAB morphology fields** were not fully exploited in downstream TDA work.
- POG570 2020 (BC Cancer Agency): headline was whole-genome of metastatic cancers; the **paired RNA-seq + germline + drug-exposure metadata** is still under-mined.
- DepMap / CCLE: cell-line drug sensitivity paired with CRISPR KO screens - most papers use one or the other.

### Pass C: paired metadata

Search the cohort's clinical_sample.txt / clinical_patient.txt for fields the release paper did not use:
- Treatment (induction regimen, HSCT, tyrosine-kinase inhibitor exposure).
- Response (complete response, refractory, relapse-free survival).
- Time-dependent covariates (MRD at 30 days).
- Morphology / cytogenetics text fields that can be re-parsed.

## What makes a dataset good for novelty

| Trait | Why it matters |
|---|---|
| Released in last 18-24 months | Novelty window still open; few methods applied |
| >=300 patients or samples | Large enough for external validation |
| Paired modalities (expression + mutation + clinical + drug) | Multi-modal claims available |
| Rich treatment metadata | Enables treatment-aware survival modelling |
| Permissive licence (public, no dbGaP gate) | Allows open-source release of processed data |
| Active secondary assets | The headline paper underused something |

## Worked example - BeatAML 2018

1. Scan identified BeatAML as a large (451 patients with RNA-seq, 672 with screening) recent AML cohort.
2. Headline: Tyner 2018 Nature correlated genotype with drug response.
3. Secondary asset: the full 122-drug AUC matrix in Supp Table S10 was reported as a resource but not systematically mined for multi-cohort transcriptomic subgrouping.
4. Low-hanging fruit: does an unsupervised transcriptomic subgrouping built on a different cohort (TCGA-LAML discovery) predict this drug-sensitivity matrix better than ELN 2022?
5. Result: yes for 95/122 drugs, Spearman improvements of +0.5 for venetoclax and FLT3 inhibitors - a genuine high-IF finding.

## Anti-patterns

- Re-analysing TCGA-Pan-Cancer for the Nth time without a novel modality.
- Picking a method first ("I want to do TDA") and shopping for data; usually produces a solution-in-search-of-a-problem.
- Ignoring secondary modalities because they are harder to download (e.g. BeatAML drug data is in a 276 MB Excel supplementary, but worth the wrangling).
- Using datasets from before 2015 without a concrete angle; most have been mined to saturation.

## Tool usage

- `WebSearch` with year filters (include `2024` or `2025` in the query).
- `WebFetch` against NCI GDC data-release pages.
- bioRxiv MCP for preprints that signal under-exploited datasets.

## Candidate dataset catalog

Catalog last verified: 2026-04. Refresh annually: re-run Pass A queries, check dataset pages for access-policy changes, and amend the table.

Access codes: **Open** = fully public download, **Gated** = dbGaP / EGA / data-use agreement required, **Mixed** = public clinical / summary data + gated raw sequencing.

| Dataset | Year | Size | Access | Under-mined asset |
|---|---|---|---|---|
| BeatAML (Tyner 2018, Bottomly 2022) | 2018 / 2022 | 672 patients | Mixed (processed public; raw via dbGaP `phs001657`) | Ex-vivo drug-screen matrix (122 compounds); induction-response status |
| MMRF CoMMpass | 2018, rolling | 1200+ MM patients | Gated (dbGaP `phs000748`) | Longitudinal expression + drug-response + MRD |
| MSK-CHORD | 2024 | 24000+ patients | Gated (cBioPortal restricted; contact MSK for full access) | Clinical + genomic pan-cancer; molecular-epidemiology angles |
| POG570 | 2020 | 570 metastatic cases | Gated (BC Cancer Agency DUA) | Paired germline + RNA-seq + drug exposure |
| PCAWG | 2020 | 2658 cancers | Mixed (summary data open; raw via ICGC DACO) | Non-coding variants; still under-mined |
| TCGA Pan-Cancer Atlas | 2018 | 10000+ | Open (processed); Gated (raw via GDC) | Immune infiltration; non-coding variants |
| HTAN (Human Tumor Atlas) | rolling | varies | Mixed (tier-1 open; tier-2 controlled) | Spatial + single-cell + bulk joint analyses |
| DepMap / CCLE 22Q4+ | rolling | 1000+ lines | Open (CCLE); Open (DepMap) | CRISPR + drug + expression joint; under-combined |
| TARGET-AML pediatric | 2020+ | ~1000 | Gated (dbGaP `phs000465`) | Paediatric AML complementary to BeatAML |

**Important**: if a dataset is Gated, the skill's release workflow cannot ship raw data; only the analysis code and processed-summary artefacts redistributable under the data-use agreement can be released. Check the DUA before committing any per-patient values.
