#!/usr/bin/env python3
"""
Quarto Book Generator - Create complete book project structure.

Usage:
    python3 generate.py <book-name> [--chapters N] [--author "Name"] [--title "Title"]
"""

import argparse
import os
import sys
from datetime import datetime


def create_quarto_yml(
    book_dir: str, title: str, author: str, chapters: list[str]
) -> None:
    """Create _quarto.yml configuration file."""
    chapter_list = "\n".join(f"    - {ch}" for ch in chapters)

    content = f'''project:
  type: book
  output-dir: _book

book:
  title: "{title}"
  author: "{author}"
  date: "{datetime.now().strftime("%Y-%m-%d")}"
  chapters:
{chapter_list}

bibliography: references.bib

format:
  html:
    theme: cosmo
    toc: true
    number-sections: true
  pdf:
    documentclass: scrbook
    papersize: a4
    toc: true
    number-sections: true
'''
    with open(os.path.join(book_dir, "_quarto.yml"), "w") as f:
        f.write(content)


def create_chapter(book_dir: str, filename: str, title: str, content: str = "") -> None:
    """Create a chapter .qmd file."""
    chapter_id = filename.replace(".qmd", "")
    qmd_content = f'''---
title: "{title}"
---

# {title} {{#sec-{chapter_id}}}

{content if content else "Content here..."}
'''
    with open(os.path.join(book_dir, filename), "w") as f:
        f.write(qmd_content)


def create_index(book_dir: str, title: str, author: str) -> None:
    """Create index.qmd (preface)."""
    content = f'''---
title: "{title}"
---

# Preface {{.unnumbered}}

Welcome to {title}.

This book covers...

## How to use this book

- Chapter 1 introduces...
- Chapter 2 explains...

## Acknowledgments

Thanks to...
'''
    with open(os.path.join(book_dir, "index.qmd"), "w") as f:
        f.write(content)


def create_references(book_dir: str) -> None:
    """Create references.qmd and references.bib."""
    refs_qmd = """---
title: "References"
---

# References {.unnumbered}

::: {#refs}
:::
"""
    with open(os.path.join(book_dir, "references.qmd"), "w") as f:
        f.write(refs_qmd)

    refs_bib = """@book{quarto2024,
  title = {Quarto: An Open-Source Scientific and Technical Publishing System},
  author = {Posit},
  year = {2024},
  url = {https://quarto.org}
}
"""
    with open(os.path.join(book_dir, "references.bib"), "w") as f:
        f.write(refs_bib)


def create_gitignore(book_dir: str) -> None:
    """Create .gitignore for book project."""
    content = """# Quarto output
_book/
_freeze/
.quarto/

# OS files
.DS_Store
Thumbs.db

# Editor files
*.swp
*~
"""
    with open(os.path.join(book_dir, ".gitignore"), "w") as f:
        f.write(content)


def main():
    parser = argparse.ArgumentParser(description="Generate Quarto Book project")
    parser.add_argument("name", help="Book directory name")
    parser.add_argument(
        "--chapters", "-c", type=int, default=3, help="Number of chapters (default: 3)"
    )
    parser.add_argument("--author", "-a", default="Author Name", help="Author name")
    parser.add_argument(
        "--title", "-t", default=None, help="Book title (default: based on name)"
    )

    args = parser.parse_args()

    book_dir = args.name
    title = args.title or args.name.replace("-", " ").replace("_", " ").title()
    author = args.author
    num_chapters = args.chapters

    # Create directory
    if os.path.exists(book_dir):
        print(f"Error: Directory '{book_dir}' already exists", file=sys.stderr)
        sys.exit(1)

    os.makedirs(book_dir)
    print(f"Creating Quarto book: {title}")

    # Define chapters
    chapter_names = [
        ("intro.qmd", "Introduction"),
        ("methods.qmd", "Methods"),
        ("results.qmd", "Results"),
        ("discussion.qmd", "Discussion"),
        ("conclusion.qmd", "Conclusion"),
    ]

    # Build chapter list
    chapters = ["index.qmd"]
    for i in range(min(num_chapters, len(chapter_names))):
        chapters.append(chapter_names[i][0])
    chapters.append("references.qmd")

    # Create files
    create_quarto_yml(book_dir, title, author, chapters)
    create_index(book_dir, title, author)

    for i in range(min(num_chapters, len(chapter_names))):
        filename, ch_title = chapter_names[i]
        create_chapter(book_dir, filename, ch_title)
        print(f"  Created: {filename}")

    create_references(book_dir)
    create_gitignore(book_dir)

    print(f"\n✅ Book created: {book_dir}/")
    print(f"   Chapters: {len(chapters)}")
    print("\nNext steps:")
    print(f"  cd {book_dir}")
    print("  quarto preview")


if __name__ == "__main__":
    main()
