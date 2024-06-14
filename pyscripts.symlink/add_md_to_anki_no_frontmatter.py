#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: add_md_to_anki
# date: "2023-10-06"
# author: Hsieh-Ting Lin, the Lizard 🦎
import json
import sys

import markdown
import requests

# Constants for Anki
ANKI_DECK_NAME = "00_Inbox"
ANKI_NOTE_TYPE = "Basic"
ANKI_FRONT_FIELD = "Front"
ANKI_BACK_FIELD = "Back"
ANKICONNECT_ENDPOINT = "http://localhost:8765"


def load_markdown(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return f.readlines()


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
    print(f"Updated ☝️ : {front}")
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
        print(f"Added 👉 {front}")
        print(response.content.decode())


def main():
    if len(sys.argv) < 2:
        print("Usage: python add_md_to_anki.py <path_to_markdown_file>")
        return

    markdown_file_path = sys.argv[1]
    markdown_lines = load_markdown(markdown_file_path)

    if not markdown_lines:
        print("Markdown file is empty.")
        return

    # Extract 'front' and 'back'
    front = markdown_lines[0].strip().replace("#", "").strip()
    back = (
        "".join(markdown_lines[1:]).strip().replace("[[", "__📜 ").replace("]]", "__")
    )
    back_html = markdown.markdown(back)

    # print(back_html)

    # Send to Anki
    send_to_anki(front, back_html)


if __name__ == "__main__":
    main()
