#!/usr/bin/env python3
"""Scaffold a new end-to-end study project.

Usage:
    scripts/init_project.py <project-dir> [--force]

Creates the directory tree, copies LaTeX and GitHub-Actions templates from the
skill's assets/ folder, and writes a minimal .gitignore, LICENSE, README.md and
pyproject.toml suitable for a computational-biology reproducible study.

Safety
------
If the target directory already contains any of the files this script would
write, the script refuses to run without --force. This prevents silent
clobbering of customised project files. With --force, a timestamped backup
of each pre-existing file is taken before overwriting.
"""
from __future__ import annotations

import argparse
import datetime as dt
import shutil
import sys
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
ASSETS = SKILL_ROOT / "assets"

SUBDIRS = [
    "data/raw",
    "data/processed",
    "data/results",
    "analysis",
    "figures",
    "manuscript",
    "docs",
    ".github/workflows",
]

LICENSE_MIT = """MIT License

Copyright (c) {year} The Authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

README_TEMPLATE = """# {title}

End-to-end reproducible study scaffold.

## Layout

```
analysis/         numbered analysis scripts (01_prepare_data.py -> ...)
data/raw/         raw downloads (gitignored)
data/processed/   harmonised inputs (gitignored, regenerable)
data/results/     analytic artefacts
docs/prereg.md    preregistration of primary + secondary outcomes
figures/          PDF + PNG figures
manuscript/       LaTeX sources, references.bib, compiled PDF
.github/workflows CI that rebuilds the PDF on each v* tag
```

## Reproduce

```bash
uv sync
uv run python analysis/01_prepare_data.py
uv run python analysis/02_<method>.py
uv run python analysis/03_<clinical>.py
uv run python analysis/04_figures.py
cd manuscript && make
```

## Preregistration

Before running any analysis against an outcome of interest, commit
`docs/prereg.md` with the primary hypothesis, pre-specified secondary
outcomes, and analysis plan. See the end-to-end-study skill
`preregistration-and-integrity.md` for the template.

## Licence
MIT. See `LICENSE`.
"""

PYPROJECT_TEMPLATE = """[project]
name = "{slug}"
version = "0.1.0"
description = "End-to-end reproducible study."
requires-python = ">=3.12,<3.14"
dependencies = [
    "pandas>=2.2,<3.0",
    "numpy>=1.26,<3.0",
    "scipy>=1.11,<2.0",
    "scikit-learn>=1.4,<2.0",
    "matplotlib>=3.8,<4.0",
    "seaborn>=0.13,<0.14",
    "statsmodels>=0.14,<0.15",
]
"""

PREREG_TEMPLATE = """# Preregistration - {slug}

**Date of preregistration:** {date}
**Commit hash when this file is committed:** (recorded by git automatically)

## Primary outcome
<one sentence; exact variable, exact statistic, exact rejection threshold>

## Primary hypothesis
<directional hypothesis with expected effect size>

## Confirmatory analysis plan
<Cox / regression / classification formula; covariates; test statistic>

## Secondary (pre-specified) outcomes
<list, each with analysis plan>

## Exploratory analyses
<explicitly marked; results cannot be promoted to primary>

## Stop rules
<when the primary hypothesis is refuted; what counts as a clean null>

## Multiple-testing family
<name every outcome tested, including any that turn out to be null>
"""

# Files written by init that must not be silently overwritten.
CRITICAL_FILES = [
    "LICENSE",
    "README.md",
    "pyproject.toml",
    ".gitignore",
    "docs/prereg.md",
    "manuscript/main.tex",
    "manuscript/references.bib",
    "manuscript/Makefile",
    "manuscript/latexmkrc",
    ".github/workflows/release.yml",
]


def _safe_write_path(target_root: Path, relative_path: str, content: str, force: bool) -> None:
    dest = target_root / relative_path
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        if not force:
            raise FileExistsError(
                f"refusing to overwrite existing {dest}; rerun with --force to backup and replace"
            )
        ts = dt.datetime.now().strftime("%Y%m%dT%H%M%S")
        backup = dest.with_suffix(dest.suffix + f".bak-{ts}")
        shutil.copy(dest, backup)
        print(f"  backup: {dest} -> {backup.name}")
    dest.write_text(content)


def _safe_copy_path(target_root: Path, src: Path, relative_path: str, force: bool) -> None:
    dest = target_root / relative_path
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        if not force:
            raise FileExistsError(
                f"refusing to overwrite existing {dest}; rerun with --force to backup and replace"
            )
        ts = dt.datetime.now().strftime("%Y%m%dT%H%M%S")
        backup = dest.with_suffix(dest.suffix + f".bak-{ts}")
        shutil.copy(dest, backup)
        print(f"  backup: {dest} -> {backup.name}")
    shutil.copy(src, dest)


def scaffold(target: Path, force: bool) -> None:
    target.mkdir(parents=True, exist_ok=True)
    for sub in SUBDIRS:
        (target / sub).mkdir(parents=True, exist_ok=True)
    (target / "data/raw/.gitkeep").touch()

    # Conflict pre-check: list which critical files already exist
    existing = [p for p in CRITICAL_FILES if (target / p).exists()]
    if existing and not force:
        print("Refusing to overwrite the following existing files:", file=sys.stderr)
        for p in existing:
            print(f"  - {p}", file=sys.stderr)
        print("\nRe-run with --force to take timestamped backups and overwrite.", file=sys.stderr)
        sys.exit(3)

    # LaTeX assets
    for name in ["main.tex", "references.bib", "Makefile", "latexmkrc"]:
        src = ASSETS / "latex" / name
        if src.exists():
            _safe_copy_path(target, src, f"manuscript/{name}", force)

    # GitHub Actions workflow
    workflow_src = ASSETS / "github" / "release.yml"
    if workflow_src.exists():
        _safe_copy_path(target, workflow_src, ".github/workflows/release.yml", force)

    # .gitignore
    gitignore_src = ASSETS / "github" / "gitignore"
    if gitignore_src.exists():
        _safe_copy_path(target, gitignore_src, ".gitignore", force)

    # LICENSE
    year = dt.datetime.now().year
    _safe_write_path(target, "LICENSE", LICENSE_MIT.format(year=year), force)

    # README.md
    title = target.name.replace("-", " ").replace("_", " ").title()
    _safe_write_path(target, "README.md", README_TEMPLATE.format(title=title), force)

    # pyproject.toml
    slug = target.name
    _safe_write_path(target, "pyproject.toml", PYPROJECT_TEMPLATE.format(slug=slug), force)

    # Preregistration stub
    _safe_write_path(
        target,
        "docs/prereg.md",
        PREREG_TEMPLATE.format(
            slug=slug, date=dt.datetime.now().strftime("%Y-%m-%d")
        ),
        force,
    )

    print(f"Scaffolded {target.resolve()}")
    print("Next steps:")
    print(f"  cd {target}")
    print("  uv sync")
    print("  # edit docs/prereg.md and commit BEFORE running any analysis")
    print("  # download raw data into data/raw/")
    print("  # write analysis/01_prepare_data.py")
    print("  cd manuscript && make  # compile the placeholder PDF")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Scaffold an end-to-end study project")
    parser.add_argument("project_dir", help="target directory (created if missing)")
    parser.add_argument(
        "--force",
        action="store_true",
        help="overwrite existing critical files after taking timestamped backups",
    )
    args = parser.parse_args(argv[1:])
    scaffold(Path(args.project_dir), args.force)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
