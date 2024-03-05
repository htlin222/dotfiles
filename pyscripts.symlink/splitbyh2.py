import os
import re
import sys
from datetime import datetime


def create_new_md_file_final(original_filename, title, content, yaml_extra):
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    yaml_header = f"""---
title: "{title}"
date: "{current_time}"
enableToc: false
tags:
  - building
---

"""
    info_block = f"> [!info]\n>\n> 🌱來自: [[{original_filename}]]\n\n"
    return yaml_header + info_block + f"# {title}\n\n{content}"


def search_siblings_to_next_heading(
    text, pattern=r"### Siblings.*?(?=\n[#]+ |$)", flags=re.DOTALL
):
    match = re.search(pattern, text, flags=flags)
    return match.group(0).strip() if match else ""


def delete_siblings_from_text(
    text, pattern=r"### Siblings.*?(?=\n[#]+ |$)", flags=re.DOTALL
):
    # 使用 re.sub 將匹配到的模式替換為空字串
    return re.sub(pattern, "", text, flags=flags)


def get_content_before_first_h2(markdown_text):
    # 使用負向前瞻斷言來確保 '##' 後面不是另一個 '#'
    match = re.search(r"##(?!#)", markdown_text)
    # match = re.search(r"##", markdown_text)
    if match:
        return markdown_text[: match.start()].strip()
    else:
        return markdown_text.strip()


def read_markdown_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return f.read()


def process_markdown_content(content):
    sibling_content = search_siblings_to_next_heading(content)
    content = delete_siblings_from_text(content)
    pre_h1_content, h1_and_following_content = content.split("# ", 1)
    h1_title, post_h1_content = h1_and_following_content.split("\n", 1)
    between_h1_h2 = get_content_before_first_h2(post_h1_content)

    level_2_heading_pattern = re.compile(r"## (.+?)\n(.*?)(?=\n## |\Z)", re.DOTALL)
    level_2_headings = level_2_heading_pattern.findall(post_h1_content)

    return pre_h1_content, h1_title, between_h1_h2, sibling_content, level_2_headings


def save_new_markdown_files(new_md_files):
    for filename, content in new_md_files.items():
        with open(f"{filename}.md", "w", encoding="utf-8") as f:
            f.write(content)


def update_original_file(file_path, content):
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python splitbyh2.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    original_filename = os.path.basename(input_file).replace(".md", "")

    # Read the input markdown file
    with open(input_file, "r", encoding="utf-8") as f:
        main_content = f.read()

    sibling_content_of_main = search_siblings_to_next_heading(main_content)
    main_content = delete_siblings_from_text(main_content)
    # Extract content before the first H1 title and the first H2
    pre_h1_content, h1_and_following_content = main_content.split("# ", 1)
    h1_title, post_h1_content = h1_and_following_content.split("\n", 1)
    between_h1_h2 = get_content_before_first_h2(post_h1_content)
    level_2_heading_pattern = re.compile(r"## (.+?)\n(.*?)(?=\n## |\Z)", re.DOTALL)
    level_2_headings = level_2_heading_pattern.findall(post_h1_content)

    level_2_headings = [
        (heading, content.strip() if content.strip() else "<!-- ✖ 無量空處 ✖ -->")
        for heading, content in level_2_headings
    ]
    new_md_files = {}
    for heading, content in level_2_headings:
        new_md_files[heading] = create_new_md_file_final(
            original_filename, heading, content, ""
        )

    # Create wikilink list and update the input markdown file

    wikilink_list = "\n".join(
        [
            f"- [[{filename.lower().replace(' ', '_')}.md|{filename}]]"
            for filename in new_md_files.keys()
        ]
    )
    # wikilink_list = "\n".join([f"- [[{lowercase_filename}.md|{filename}]]" for filename in new_md_files.keys()])

    # where lowercase_filename = filename.lower().replace(" ", "_")
    # Save new markdown files
    for filename, content in new_md_files.items():
        with open(
            f"{filename.lower().replace(' ', '_')}.md", "w", encoding="utf-8"
        ) as f:
            to_write = f"{content}\n\n### Siblings\n\n{wikilink_list}\n\n"
            f.write(to_write)

    main_content_updated = f"{pre_h1_content}# {h1_title}\n{between_h1_h2}\n\n{wikilink_list}\n\n{sibling_content_of_main}"

    with open(input_file, "w", encoding="utf-8") as f:
        f.write(main_content_updated)
