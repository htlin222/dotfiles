#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: split_by_h2
# author: Hsieh-Ting Lin, the Lizard 🦎
# description: split_by_h2 is a script about...
# date: "2024-03-06"
# --END-- #

import os
import re
from datetime import datetime


class MarkdownProcessor:
    def __init__(self, file_path):
        self.file_path = file_path
        self.original_filename = os.path.basename(file_path).replace(".md", "")
        self.content = self._read_markdown_file()

    def _read_markdown_file(self):
        with open(self.file_path, "r", encoding="utf-8") as f:
            return f.read()

    def _create_new_md_file(self, title, content, yaml_extra=""):
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

    def _search_siblings_to_next_heading(
        self, pattern=r"### Siblings.*?(?=\n[#]+ |$)", flags=re.DOTALL
    ):
        match = re.search(pattern, self.content, flags=flags)
        return match.group(0).strip() if match else ""

    def _delete_siblings_from_text(
        self, pattern=r"### Siblings.*?(?=\n[#]+ |$)", flags=re.DOTALL
    ):
        self.content = re.sub(pattern, "", self.content, flags=flags)

    def _get_content_before_first_h2(self):
        match = re.search(r"##(?!#)", self.content)
        if match:
            return self.content[: match.start()].strip()
        else:
            return self.content.strip()

    def _process_markdown_content(self):
        self._delete_siblings_from_text()
        # 使用正則表達式直接分割和提取所需內容
        pre_h1_content, h1_title, post_h1_content = re.split(
            r"#\s(.+?)\n", self.content, 1
        )
        between_h1_h2 = self._get_content_before_first_h2()
        # 提取二級標題及其後的內容
        level_2_headings = re.findall(
            r"##\s(.+?)\n(.*?)(?=\n## |\Z)", post_h1_content, re.DOTALL
        )
        return pre_h1_content, h1_title, between_h1_h2, level_2_headings

    def save_new_markdown_files(self):
        (
            pre_h1_content,
            h1_title,
            between_h1_h2,
            level_2_headings,
        ) = self._process_markdown_content()
        new_md_files = {
            heading: self._create_new_md_file(heading, content)
            for heading, content in level_2_headings
        }

        wikilink_list = "\n".join(
            [
                f"- [[{heading.lower().replace(' ', '_')}.md|{heading}]]"
                for heading in new_md_files
            ]
        )

        for filename, content in new_md_files.items():
            # 在生成wikilink_list時排除當前的filename
            filtered_wikilink_list = "\n".join(
                link
                for link in wikilink_list.split("\n")
                if f'[[{filename.lower().replace(" ", "_")}.md|' not in link
            )

            with open(
                f"{filename.lower().replace(' ', '_')}.md", "w", encoding="utf-8"
            ) as f:
                to_write = f"{content}\n\n### Siblings\n\n{filtered_wikilink_list}\n\n"
                f.write(to_write)
                main_content_updated = f"{between_h1_h2}\n\n{wikilink_list}\n\n"
                self._update_original_file(main_content_updated)

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
