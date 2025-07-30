#!/usr/bin/env python3
import json
import os
import re
import sys

# Import processors
from processors import (
    process_bibtex_files,
    process_biome_files,
    process_prettier_files,
    process_python_files,
    process_r_files,
    process_shellcheck_files,
    process_vale_files,
)

# Read input
raw_input = sys.stdin.read()

# Find file paths using regex
pattern = r'"(?:filePath|file_path)"\s*:\s*"([^"]+)"'
file_paths = re.findall(pattern, raw_input)

# File type mappings
biome_exts = {
    ".js",
    ".jsx",
    ".tsx",
    ".ts",
    ".json",
    ".css",
}
prettier_exts = {
    ".html",
    ".md",
    ".qmd",
    ".mdx",
    ".scss",
    ".less",
    ".vue",
    ".yaml",
    ".yml",
}
python_exts = {".py", ".pyi"}
bibtex_exts = {".bib"}
shell_exts = {".sh", ".bash", ".zsh", ".fish"}
r_exts = {".R", ".r"}
markdown_exts = {".md", ".mdx", ".qmd"}


# Process found paths
for file_path in file_paths:
    if os.path.exists(file_path):
        _, ext = os.path.splitext(file_path)
        filename = os.path.basename(file_path)
        # subprocess.run(["say", f"{filename} 編輯完成"], check=False)

        if ext in biome_exts:
            process_biome_files(file_path)
        elif ext in prettier_exts:
            process_prettier_files(file_path)
            # If markdown, also run Vale after Prettier
            if ext in markdown_exts:
                process_vale_files(file_path)
        elif ext in python_exts:
            process_python_files(file_path)
        elif ext in bibtex_exts:
            process_bibtex_files(file_path)
        elif ext in shell_exts:
            process_shellcheck_files(file_path)
        elif ext in r_exts:
            process_r_files(file_path)


# Output the original input (with control chars escaped if needed)
try:
    # Try to parse and re-output as valid JSON
    data = json.loads(raw_input)
    print(json.dumps(data))
except json.JSONDecodeError:
    # If JSON is malformed, try to clean it
    cleaned = raw_input.replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
    print(cleaned)
