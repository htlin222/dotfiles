import argparse
import json
import re
import sys


def parse_comments(py_file):
    """Parse the comments at the beginning of a Python file."""
    comments_data = {}
    with open(py_file, "r", encoding="utf-8") as file:
        content = file.read()
        for line in content.split("\n"):
            match = re.match(r"#\s*(\w+):\s*(.*)", line)
            if match:
                key, value = match.groups()
                comments_data[key] = value
    return comments_data


def extract_content_after_end_marker(py_file):
    """Extract content from a Python file after a specific '# --END-- #' comment."""
    with open(py_file, "r", encoding="utf-8") as file:
        content = file.read()
        body_match = re.search(r"#\s*--END--\s*#\n(.*)", content, re.DOTALL)
        if body_match:
            body_content = body_match.group(1).strip().split("\n")
            return body_content
    return []


def add_or_update_snippet(py_file, json_file):
    comments_data = parse_comments(py_file)
    body = extract_content_after_end_marker(
        py_file
    )  # Update this line to use the new function

    if comments_data:
        title = comments_data.get("title", "")
        prefix = comments_data.get("prefix", "")
        description = comments_data.get("description", title)

        new_snippet = {
            title: {"prefix": prefix, "body": body, "description": description}
        }

        try:
            with open(json_file, "r") as f:
                try:
                    snippets = json.load(f)
                except (
                    json.decoder.JSONDecodeError
                ):  # Handle empty or invalid JSON file
                    snippets = {}  # Initialize as empty dict if JSON is invalid or file is empty
        except FileNotFoundError:
            snippets = {}  # Initialize as empty dict if file does not exist

        if title in snippets:
            print(f"Updating snippet for title '{title}' in {json_file}")
        else:
            print(f"Adding snippet for title '{title}' to {json_file}")

        snippets.update(new_snippet)

        with open(json_file, "w") as f:
            json.dump(snippets, f, indent=4)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Add or update a snippet from a Python file to a JSON file."
    )
    parser.add_argument("py_file", type=str, help="Python file path")
    parser.add_argument("json_file", type=str, help="JSON file path")

    args = parser.parse_args()

    # if not args.py_file.endswith(".py"):
    #     print("The first argument should be a Python file (.py)")
    #     sys.exit(1)

    if not args.json_file.endswith(".json"):
        print("The second argument should be a JSON file (.json)")
        sys.exit(1)

    add_or_update_snippet(args.py_file, args.json_file)
