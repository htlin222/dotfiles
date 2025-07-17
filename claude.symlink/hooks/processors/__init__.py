"""Processors package for file type specific processing.

This package contains modular processors for different file types and linters.
Each processor handles formatting and linting for specific file extensions.

Current Processors:
- prettier_processor: Prettier formatting for web files (HTML, CSS, JS, etc.)
- vale_processor: Vale linting for markdown files
- write_good_processor: Write-good linting for markdown files
- python_processor: Ruff formatting and linting for Python files

Adding New Processors:
To add a new processor for a file type or linter:

1. Create a new processor file (e.g., go_processor.py):
   ```python
   #!/usr/bin/env python3
   import subprocess
   import sys

   def process_go_files(file_path):
       \"\"\"Process Go files with gofmt and golint.\"\"\"
       try:
           # Step 1: Format with gofmt
           result = subprocess.run(
               ["gofmt", "-w", file_path], capture_output=True, text=True
           )
           if result.returncode == 0:
               print(f"📦 Formatted {file_path} with gofmt", file=sys.stderr)

           # Step 2: Lint with golint
           result = subprocess.run(
               ["golint", file_path], capture_output=True, text=True
           )
           if result.returncode == 0:
               if result.stdout:
                   # Send linting results to Claude via exit code 2
                   print(f"Go linting issues in {file_path}:\\n{result.stdout.strip()}", file=sys.stderr)
                   sys.exit(2)  # Exit code 2 passes stderr to Claude
               else:
                   print(f"✅ No Go linting issues in {file_path}", file=sys.stderr)
       except FileNotFoundError:
           print("ERROR: Go tools not found. Install with: go install ...", file=sys.stderr)
   ```

2. Add file extensions to main post_tool_use.py:
   ```python
   go_exts = {".go"}
   ```

3. Add processor logic in main loop:
   ```python
   elif ext in go_exts:
       process_go_files(file_path)
   ```

4. Import and export in this __init__.py:
   ```python
   from .go_processor import process_go_files
   __all__ = [..., "process_go_files"]
   ```

Exit Code Behavior:
- Exit code 0: Success, continue processing
- Exit code 2: Send linter output to Claude for automatic processing
- Other codes: Non-blocking error, show to user

Claude Integration:
When using exit code 2, the linter output goes to Claude Code which can:
- Automatically fix the issues
- Provide suggestions and improvements
- Apply best practices and optimizations
"""

from .prettier_processor import process_prettier_files
from .vale_processor import process_vale_files
from .write_good_processor import process_write_good_files
from .python_processor import process_python_files
from .eslint_processor import process_eslint_files

__all__ = [
    "process_prettier_files",
    "process_vale_files",
    "process_write_good_files",
    "process_python_files",
    "process_eslint_files",
]
