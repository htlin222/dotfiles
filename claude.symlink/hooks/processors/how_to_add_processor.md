# How to add a file processor

This guide explains how to add a processor for handling specific file types in the Claude Code post-tool hook system.

## Overview

The processor system automatically formats and lints files after Write, Edit, or MultiEdit operations. Each processor:

- Handles specific file extensions
- Runs formatting or linting tools
- Employs exit code 2 to send issues to Claude for automatic processing
- Provides clear status messages

## Step-by-step guide

### 1. Create the processor file

Create a Python file in `/hooks/processors/` following this template:

```python
#!/usr/bin/env python3
"""[TOOL_NAME] processor for [description]."""

import subprocess
import sys


def process_[tool_name]_files(file_path):
    """Process files with [TOOL_NAME] formatter/linter."""
    try:
        # Step 1: Run formatter (if applicable)
        format_result = subprocess.run(
            ["[tool_command]", "[format_flags]", file_path],
            capture_output=True,
            text=True,
        )
        if format_result.returncode == 0:
            print(f"✨ Formatted {file_path} with [TOOL_NAME]", file=sys.stderr)
        else:
            print(
                f"⚠️  [TOOL_NAME] format failed: {format_result.stderr.strip()}",
                file=sys.stderr,
            )

        # Step 2: Run linter/checker (if applicable)
        check_result = subprocess.run(
            ["[tool_command]", "[check_flags]", file_path],
            capture_output=True,
            text=True,
        )

        if check_result.returncode == 0:
            if check_result.stdout and "fixed" in check_result.stdout.lower():
                # If tool fixed issues, send details to Claude via exit code 2
                print(
                    f"[TOOL_NAME] fixed issues in {file_path}:\n{check_result.stdout.strip()}",
                    file=sys.stderr,
                )
                sys.exit(2)  # Exit code 2 passes stderr to Claude
            else:
                print(f"✅ No issues in {file_path}", file=sys.stderr)
        else:
            # Send issues to Claude via stderr and exit code 2
            print(
                f"[TOOL_NAME] found issues in {file_path}:\n{check_result.stderr.strip()}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude

    except FileNotFoundError:
        print(
            "ERROR: [tool_command] not found. Install with: [installation_command]",
            file=sys.stderr,
        )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: [tool_name]_processor.py <file_path>", file=sys.stderr)
        sys.exit(1)
    process_[tool_name]_files(sys.argv[1])
```

### 2. Test command-line tool availability

Before implementing, verify the tool exists and works:

```bash
# Test if tool is installed
which [tool_command]

# Test basic functionality
[tool_command] --help
[tool_command] --version

# Test on sample file
echo "sample content" > test_file.[ext]
[tool_command] [format_flags] test_file.[ext]
[tool_command] [check_flags] test_file.[ext]
rm test_file.[ext]
```

### 3. Make processor executable

```bash
chmod +x /path/to/[tool_name]_processor.py
```

### 4. Update main hook configuration

Edit `/hooks/post_tool_use.py`:

```python
# Add import
from processors import (..., process_[tool_name]_files)

# Add file extension mapping
[tool_name]_exts = {
    ".[ext1]",
    ".[ext2]",
    # etc.
}

# Add processing logic in the main loop
for file_path in file_paths:
    if os.path.exists(file_path):
        _, ext = os.path.splitext(file_path)

        if ext in [tool_name]_exts:
            process_[tool_name]_files(file_path)
        # ... existing elif conditions ...
```

### 5. Update processor package

Edit `/hooks/processors/__init__.py`:

```python
# Add import
from .[tool_name]_processor import process_[tool_name]_files

# Add to __all__ list
__all__ = [
    # ... existing processors ...
    "process_[tool_name]_files",
]

# Update docstring
Current Processors:
# ... existing processors ...
- [tool_name]_processor: [description] for [file types]
```

### 6. Test the Integration

Create test files and verify the processor works:

```bash
# Create test file with issues
cat > /tmp/test.[ext] << 'EOF'
[content with formatting/linting issues]
EOF

# Use Claude Code to edit the file (triggers post-tool hook)
# Should see processor messages and auto-formatting
```

## Exit code behavior

| Exit Code | Behavior              | Use Case                         |
| --------- | --------------------- | -------------------------------- |
| 0         | Success, continue     | Tool ran successfully, no issues |
| 2         | Send output to Claude | Tool found issues or made fixes  |
| Other     | Non-blocking error    | Tool failed, show warning        |

## Message format examples

```python
# Success messages
print(f"✨ Formatted {file_path} with [TOOL]", file=sys.stderr)
print(f"✅ No issues in {file_path}", file=sys.stderr)

# Error messages
print(f"⚠️  [TOOL] failed: {error}", file=sys.stderr)

# Claude integration messages (with exit code 2)
print(f"[TOOL] fixed issues in {file_path}:\n{details}", file=sys.stderr)
print(f"[TOOL] found issues in {file_path}:\n{details}", file=sys.stderr)
```

## Real examples

### Biome processor for JavaScript and TypeScript

- **Tool**: `biome format --write` + `biome check --write`
- **Extensions**: `.js`, `.jsx`, `.ts`, `.tsx`, `.css`, `.json`
- **Features**: Formatting + linting with accessibility checks

### Python processor with Ruff

- **Tool**: `ruff format` + `ruff check --fix`
- **Extensions**: `.py`, `.pyi`
- **Features**: Formatting + linting with automatic fixes

### Prettier processor for web files

- **Tool**: `prettier --write`
- **Extensions**: `.html`, `.md`, `.scss`, `.yaml`, etc.
- **Features**: Formatting only

## Troubleshooting

### Common Issues

1. **Tool not found**: Ensure CLI tool is installed and in PATH
2. **Permission denied**: Run `chmod +x processor_file.py`
3. **Import errors**: Check processor is added to `__init__.py`
4. **No processing**: Verify file extension is in the mapping

### Debug steps

1. Test processor directly: `python3 processor_file.py test_file.ext`
2. Check hook integration: Look for processor messages in Claude output
3. Verify exit codes: Tool should exit with code 2 for Claude integration
4. Test file extensions: Ensure mapping covers target files

## Best practices

1. **Robust Error Handling**: Always catch `FileNotFoundError` for missing tools
2. **Clear Messages**: Use consistent emoji and format for status messages
3. **Exit Code Strategy**: Use code 2 only for meaningful Claude integration
4. **Tool Validation**: Test CLI commands thoroughly before implementation
5. **Documentation**: Update this guide and processor docstrings
6. **Performance**: Consider tool speed for frequently edited files
7. **Configuration**: Respect tool config files (`.biomerc`, `.prettierrc`, etc.)

## Integration with Claude

When using exit code 2, Claude Code can:

- Automatically apply suggested fixes
- Provide explanations for linting issues
- Offer code improvements and optimizations
- Apply best practices and style guidelines

This creates a powerful feedback loop for code quality improvement.
