IMPORTANT
if file_exists("pyproject.toml") or any_file("*.py") or (.venv folder exist):
    Python 项目 → 使用 uv, start the venv by `source .venv/bin/activate`
elif file_exists("package.json") and (file_contains("package.json","react") or react_entry()):
     React/JS 项目 → 使用 pnpm
else:
    Per User instruction

and Avoid Error: File has not been read yet. Read it first before writing to it.
