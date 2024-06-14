import argparse
import json
import re
import sys


def parse_yaml(yaml_str):
    """Parse the YAML content without using the yaml package."""
    yaml_data = {}
    for line in yaml_str.split("\n"):
        match = re.match(r"(\w+):\s*(.*)", line)
        if match:
            key, value = match.groups()
            yaml_data[key] = value
    return yaml_data


def add_or_update_snippet(md_file, json_file):
    try:
        # Read the Markdown file
        with open(md_file, "r") as f:
            content = f.read()
    except IOError:
        print(f"Error: Unable to read file {md_file}")
        sys.exit(1)

    # Your existing code for processing content

    try:
        # Read the existing JSON file
        with open(json_file, "r") as f:
            snippets = json.load(f)
    except IOError:
        print(f"Error: Unable to read file {json_file}")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: File {json_file} is not a valid JSON file")
        sys.exit(1)

    # Your existing code for updating snippets

    try:
        # Write the updated snippets back to the JSON file
        with open(json_file, "w") as f:
            json.dump(snippets, f, indent=4)
    except IOError:
        print(f"Error: Unable to write to file {json_file}")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Add or update a snippet from a Markdown file to a JSON file."
    )
    parser.add_argument("md_file", type=str, help="Markdown file path")
    parser.add_argument("json_file", type=str, help="JSON file path")

    args = parser.parse_args()

    if not args.md_file.endswith(".md"):
        print("The first argument should be a Markdown file (.md)")
        sys.exit(1)

    if not args.json_file.endswith(".json"):
        print("The second argument should be a JSON file (.json)")
        sys.exit(1)

    add_or_update_snippet(args.md_file, args.json_file)
