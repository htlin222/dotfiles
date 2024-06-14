#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: add_md_to_anki
# date: "2023-10-06"
# author: Hsieh-Ting Lin, the Lizard 🦎
import json
import sys

import markdown
import requests
import yaml

# Constants for Anki
ANKI_DECK_NAME = "00_Inbox"
ANKI_NOTE_TYPE = "Basic"
ANKI_FRONT_FIELD = "Front"
ANKI_BACK_FIELD = "Back"
ANKICONNECT_ENDPOINT = "http://localhost:8765"


def load_markdown(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    return content


def parse_front_matter_and_content(markdown_content):
    parts = markdown_content.split("---")
    if len(parts) < 3:
        return None, None

    front_matter = yaml.safe_load(parts[1])
    content = parts[2]
    return front_matter, content


def find_existing_note(front):
    payload = {
        "action": "findNotes",
        "version": 6,
        "params": {"query": f'{ANKI_FRONT_FIELD}:"{front}"'},
    }
    response = requests.post(ANKICONNECT_ENDPOINT, json=payload)
    return json.loads(response.content.decode()).get("result", [])


def update_note(note_id, front, back):
    payload = {
        "action": "updateNoteFields",
        "version": 6,
        "params": {
            "note": {
                "id": note_id,
                "fields": {ANKI_FRONT_FIELD: front, ANKI_BACK_FIELD: back},
            }
        },
    }
    response = requests.post(ANKICONNECT_ENDPOINT, json=payload)
    print(f"Updated {front}")
    print(response.content.decode())


def send_to_anki(front, back):
    existing_notes = find_existing_note(front)

    if existing_notes:
        update_note(existing_notes[0], front, back)
    else:
        payload = {
            "action": "addNote",
            "version": 6,
            "params": {
                "note": {
                    "deckName": ANKI_DECK_NAME,
                    "modelName": ANKI_NOTE_TYPE,
                    "fields": {ANKI_FRONT_FIELD: front, ANKI_BACK_FIELD: back},
                    "options": {"allowDuplicate": False},
                    "tags": ["from_mymarkdown"],
                }
            },
        }

        response = requests.post(ANKICONNECT_ENDPOINT, json=payload)
        print(f"Added {front}")
        print(response.content.decode())


def main():
    if len(sys.argv) < 2:
        print("Usage: python add_md_to_anki.py <path_to_markdown_file>")
        return

    markdown_file_path = sys.argv[1]

    # Step 1: Load Markdown content
    markdown_content = load_markdown(markdown_file_path)

    content = "NA"
    # Step 2: Parse front matter and content
    front_matter, content = parse_front_matter_and_content(markdown_content)

    front = content.split("# ", 1)[1].split("\n", 1)[0].strip()
    back = content.split("# ", 1)[1].split("\n", 1)[1].strip()
    back_html = markdown.markdown(back)

    # Step 4: Open Anki app
    # subprocess.run(["open", "/Applications/Anki.app"])
    print(front)
    print(back_html)

    # Step 5: Send to Anki
    send_to_anki(front, back_html)


if __name__ == "__main__":
    main()
