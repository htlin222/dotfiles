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
    # Initialize variables
    title = ""
    prefix = ""
    body = ""
    description = ""

    # Read the Markdown file
    with open(md_file, "r") as f:
        content = f.read()

    # Extract YAML and body content using regex
    yaml_match = re.search(r"^---\n(.*?)\n---", content, re.DOTALL)
    if yaml_match:
        yaml_content = yaml_match.group(1).replace('"', "")
        yaml_data = parse_yaml(yaml_content)
        title = yaml_data.get("title", "")
        prefix = yaml_data.get("prefix", "")
        description = yaml_data.get("description", title)

    # Extract body content after the first heading
    body_match = re.search(r"(?<=\n# ).*?\n(.*)", content, re.DOTALL)
    if body_match:
        body = body_match.group(1).strip().split("\n")

    # Create the JSON structure
    new_snippet = {title: {"prefix": prefix, "body": body, "description": description}}

    # Read the existing JSON file
    with open(json_file, "r") as f:
        snippets = json.load(f)

    # Update or add the new snippet
    if title in snippets:
        print(f"Updating snippet for title '{title}' in {json_file}")
    else:
        print(f"Adding snippet for title '{title}' to {json_file}")

    snippets.update(new_snippet)

    # Write the updated snippets back to the JSON file
    with open(json_file, "w") as f:
        json.dump(snippets, f, indent=4)


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
