import os
import re
from collections import OrderedDict
from datetime import datetime


class MarkdownProcessor:
    def __init__(self, file_path):
        self.file_path = file_path
        self.original_filename = os.path.basename(file_path).replace(".md", "")
        self.content = self._read_markdown_file()

    def _read_markdown_file(self):
        with open(self.file_path, "r", encoding="utf-8") as f:
            return f.read()

    def _create_new_md_file(self, title, content):
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        yaml_header = f"""---
title: "{title}"
date: "{current_time}"
enableToc: false
tags:
  - building
---

"""
        info_block = f"> [!info]\n>\n> 🌱來自: [[{self.original_filename}]]\n\n"
        return yaml_header + info_block + f"# {title}\n\n{content}"

    def _process_markdown_content(self):
        # Extract YAML front matter and content before first H1
        yaml_and_pre_h1 = re.match(
            r"^(---\n.*?\n---\n)?(.+?)(?=^# |\Z)",
            self.content,
            re.DOTALL | re.MULTILINE,
        )
        yaml_content = yaml_and_pre_h1.group(1) or ""
        pre_h1_content = yaml_and_pre_h1.group(2) or ""

        # Split content into sections based on H1 headings
        h1_sections = re.split(r"(^# .+?$)", self.content, flags=re.MULTILINE)[
            1:
        ]  # Skip content before first H1

        h1_contents = OrderedDict()
        h2_headings = OrderedDict()
        all_h2 = OrderedDict()

        for i in range(0, len(h1_sections), 2):
            h1_title = h1_sections[i].strip()
            h1_content = h1_sections[i + 1].strip() if i + 1 < len(h1_sections) else ""

            # Process H2 headings within H1 content
            h2_parts = re.split(r"(^## .+?$)", h1_content, flags=re.MULTILINE)

            h1_content_without_h2 = h2_parts[0].strip()
            h1_contents[h1_title] = h1_content_without_h2
            h2_headings[h1_title] = []

            for j in range(1, len(h2_parts), 2):
                h2_title = h2_parts[j].strip()[3:]  # Remove '## '
                h2_content = h2_parts[j + 1].strip() if j + 1 < len(h2_parts) else ""
                h2_headings[h1_title].append((h2_title, h2_content))
                all_h2[h2_title] = h2_content

        return yaml_content, pre_h1_content, h1_contents, h2_headings, all_h2

    def _lint_content(self, content):
        # Replace multiple consecutive newlines with a single newline
        return re.sub(r"\n{3,}", "\n\n", content)

    def save_new_markdown_files(self):
        yaml_content, pre_h1_content, h1_contents, h2_headings, all_h2 = (
            self._process_markdown_content()
        )

        new_md_files = {}
        for h2_title, h2_content in all_h2.items():
            new_md_files[h2_title] = self._create_new_md_file(h2_title, h2_content)

        for filename, content in new_md_files.items():
            with open(
                f"{filename.lower().replace(' ', '_')}.md", "w", encoding="utf-8"
            ) as f:
                siblings = "\n".join(
                    [
                        f"- [[{h2.lower().replace(' ', '_')}.md|{h2}]]"
                        for h2 in all_h2
                        if h2 != filename
                    ]
                )
                to_write = self._lint_content(
                    f"{content}\n\n### Siblings\n\n{siblings}\n\n"
                )
                f.write(to_write)

        # Reconstruct original file structure with wikilinks
        main_content = yaml_content + pre_h1_content
        for h1, h1_content in h1_contents.items():
            main_content += f"\n\n{h1}\n{h1_content}\n"
            for h2_title, _ in h2_headings[h1]:
                main_content += (
                    f"- [[{h2_title.lower().replace(' ', '_')}.md|{h2_title}]]\n"
                )

        main_content = self._lint_content(main_content.strip() + "\n")
        self._update_original_file(main_content)

    def _update_original_file(self, content):
        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(content)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python script.py <input_file>")
        sys.exit(1)
    file_path = sys.argv[1]
    processor = MarkdownProcessor(file_path)
    processor.save_new_markdown_files()
