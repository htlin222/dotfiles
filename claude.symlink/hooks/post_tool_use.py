#!/usr/bin/env python3
import json
import os
import re
import sys

# Import processors
from processors import (process_prettier_files, process_python_files,
                        process_vale_files)

# Read input
raw_input = sys.stdin.read()

# Find file paths using regex
pattern = r'"(?:filePath|file_path)"\s*:\s*"([^"]+)"'
file_paths = re.findall(pattern, raw_input)

# File type mappings
prettier_exts = {
    ".html",
    ".css",
    ".js",
    ".jsx",
    ".tsx",
    ".ts",
    ".json",
    ".md",
    ".mdx",
    ".scss",
    ".less",
    ".vue",
    ".yaml",
    ".yml",
}
python_exts = {".py", ".pyi"}
markdown_exts = {".md", ".mdx"}
eslint_exts = {".js", ".jsx", ".ts", ".tsx"}

# Process found paths
for file_path in file_paths:
    if os.path.exists(file_path):
        _, ext = os.path.splitext(file_path)

        if ext in prettier_exts:
            process_prettier_files(file_path)
            # If markdown, also run Vale and write-good after Prettier
            if ext in markdown_exts:
                process_vale_files(file_path)
                # process_write_good_files(file_path)
            # If JavaScript/TypeScript, also run ESLint after Prettier
            # elif ext in eslint_exts:
            # process_eslint_files(file_path)

        elif ext in python_exts:
            process_python_files(file_path)


# Output the original input (with control chars escaped if needed)
try:
    # Try to parse and re-output as valid JSON
    data = json.loads(raw_input)
    print(json.dumps(data))
except:
    # If JSON is malformed, try to clean it
    cleaned = raw_input.replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
    print(cleaned)
