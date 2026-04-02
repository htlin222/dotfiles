---
name: repo-init
description: Initializes a public GitHub repo with CITATION.cff, citation.bib, LICENSE (MIT), AMA+APA CSL files, README.md with badges and citation block, and gh repo description. Use when creating a new repo, setting up project metadata, or when user mentions "repo init", "badges", "citation", "CITATION.cff", or "license setup".
---

# Repo Init

Sets up Hsieh-Ting Lin's standard public GitHub repository metadata: CITATION.cff, citation.bib, LICENSE, CSL files, README badges, and GitHub repo description.

## Quick Start

Run `/repo-init` in any repo root. The skill auto-detects:
- Repo name from git remote or directory name
- Primary language(s) from file extensions
- Existing README (preserves or creates)

## Workflow

```
- [ ] Step 1: Detect repo context (name, languages, description, existing files)
- [ ] Step 2: Create CITATION.cff
- [ ] Step 3: Create citation.bib
- [ ] Step 4: Create LICENSE (MIT)
- [ ] Step 5: Download AMA + APA CSL files to csl/
- [ ] Step 6: Create or update README.md with badges + citation block
- [ ] Step 7: Set gh repo description (if gh CLI available)
```

## Author (hardcoded)

```yaml
family-names: "Lin"
given-names: "Hsieh-Ting"
orcid: "https://orcid.org/0009-0002-3974-4528"
github: htlin222
```

## Step 1: Detect Repo Context

```bash
# Repo name
REPO_NAME=$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))

# GitHub remote
GH_REMOTE=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
# e.g. "htlin222/survival-pipe"

# Primary languages (by file count)
# Check for: *.R, *.py, *.qmd, *.js, *.ts, *.go, *.rs, *.cpp, *.sh
```

Detect existing files — skip creating any that already exist (warn instead).

## Step 2: CITATION.cff

```yaml
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
type: software
title: "{REPO_NAME}: {SHORT_DESCRIPTION}"
version: 0.1.0
date-released: "{CURRENT_YEAR}-01-01"
url: "https://github.com/htlin222/{REPO_NAME}"
repository-code: "https://github.com/htlin222/{REPO_NAME}"
license: MIT
authors:
  - family-names: "Lin"
    given-names: "Hsieh-Ting"
    orcid: "https://orcid.org/0009-0002-3974-4528"
keywords:
  - {auto-detect from repo content, 3-6 keywords}
abstract: >-
  {One-sentence project description}
```

Ask the user for `SHORT_DESCRIPTION` and `abstract` if not obvious from existing README.

## Step 3: citation.bib

```bibtex
@software{lin{YEAR}{REPO_NAME_CLEAN},
  author = {Lin, Hsieh-Ting},
  title = {{REPO_NAME}: {SHORT_DESCRIPTION}},
  year = {{YEAR}},
  url = {https://github.com/htlin222/{REPO_NAME}},
  version = {0.1.0}
}
```

Where `REPO_NAME_CLEAN` is the repo name with hyphens removed (e.g. `survivalpipe`).

## Step 4: LICENSE

Standard MIT License:

```
MIT License

Copyright (c) {YEAR} Hsieh-Ting Lin

Permission is hereby granted, free of charge, ...
```

## Step 5: CSL Files

Download to `csl/` directory:

```bash
mkdir -p csl
# AMA 11th edition
curl -sL "https://raw.githubusercontent.com/citation-style-language/styles/master/american-medical-association.csl" -o csl/american-medical-association.csl
# APA 7th edition
curl -sL "https://raw.githubusercontent.com/citation-style-language/styles/master/apa.csl" -o csl/apa.csl
```

If curl/WebFetch fails, create placeholder files with a comment noting the download URL.

## Step 6: README.md

### Badge Selection

Auto-select badges based on detected languages and features:

**Always include:**
- License badge: `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)`
- GitHub stars: `[![GitHub stars](https://img.shields.io/github/stars/htlin222/{REPO})](https://github.com/htlin222/{REPO}/stargazers)`

**If R detected (*.R, *.Rmd, renv.lock):**
- `[![R](https://img.shields.io/badge/R-%3E%3D4.2-276DC3.svg?logo=r)](https://www.r-project.org)`

**If Python detected (*.py, pyproject.toml, requirements.txt):**
- `[![Python](https://img.shields.io/badge/Python-%3E%3D3.12-3776AB.svg?logo=python&logoColor=white)](https://www.python.org)`

**If Quarto detected (*.qmd, _quarto.yml):**
- `[![Quarto](https://img.shields.io/badge/Made%20with-Quarto-blue.svg?logo=quarto)](https://quarto.org)`

**If GitHub Pages / docs exist (pages/, docs/, .github/workflows/*pages*):**
- `[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-brightgreen.svg)](https://htlin222.github.io/{REPO}/)`

**If GH Actions exist (.github/workflows/*.yml):**
- `[![CI](https://github.com/htlin222/{REPO}/actions/workflows/{WORKFLOW}.yml/badge.svg)](https://github.com/htlin222/{REPO}/actions/workflows/{WORKFLOW}.yml)`

**If TypeScript/JavaScript (*.ts, *.js, package.json):**
- `[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC.svg?logo=typescript&logoColor=white)](https://www.typescriptlang.org)`

**If Go (*.go, go.mod):**
- `[![Go](https://img.shields.io/badge/Go-%3E%3D1.21-00ADD8.svg?logo=go&logoColor=white)](https://go.dev)`

**If Rust (*.rs, Cargo.toml):**
- `[![Rust](https://img.shields.io/badge/Rust-000000.svg?logo=rust)](https://www.rust-lang.org)`

### README Structure

If README.md **doesn't exist**, create with full structure:

```markdown
{BADGES}

# {REPO_NAME}

{One-paragraph description}

## Quick Start

{Auto-detect: setup.sh, make, npm, pip, cargo, etc.}

## Citation

If you use this project, please cite it:

**BibTeX:**
```bibtex
{citation.bib content}
```

<details>
<summary>AMA format</summary>

Lin HT. {REPO_NAME}: {SHORT_DESCRIPTION}. Published online {YEAR}. https://github.com/htlin222/{REPO_NAME}

</details>

<details>
<summary>APA format</summary>

Lin, H.-T. ({YEAR}). *{REPO_NAME}: {SHORT_DESCRIPTION}* (Version 0.1.0) [Computer software]. https://github.com/htlin222/{REPO_NAME}

</details>

## License

This project is licensed under the [MIT License](LICENSE).
```

If README.md **already exists**, append or update only the missing sections (Citation, License, badges). Do NOT overwrite existing content. Insert badges at top if none exist.

## Step 7: GitHub Repo Description

If `gh` CLI is available and authenticated:

```bash
gh repo edit htlin222/{REPO_NAME} --description "{SHORT_DESCRIPTION}"
```

Ask user for confirmation before running this step.

## Post-Init Checklist

After completion, print:

```
Repo Init Complete:
  [x] CITATION.cff
  [x] citation.bib
  [x] LICENSE (MIT)
  [x] csl/american-medical-association.csl
  [x] csl/apa.csl
  [x] README.md (with badges + citation)
  [ ] gh repo description (run: gh repo edit --description "...")
```

## Edge Cases

- **Monorepo**: If multiple languages detected, include all relevant badges
- **Existing LICENSE**: Warn and skip (don't overwrite a different license)
- **No git remote**: Use directory name, skip GH-specific steps
- **Private repo**: Skip stars badge, warn about Pages badge
