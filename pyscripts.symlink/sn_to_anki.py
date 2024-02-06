#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: sn_to_anki
# date: "2024-02-04"
# @raycast.title Simplenote to Anki
# @raycast.author HTLin the 🦎
# @raycast.authorURL https://github.com/htlin222
# @raycast.description Sync to Anki
# @raycast.icon 🔃
# @raycast.mode fullOutput
# @raycast.packageName System
# @raycast.schemaVersion 1

import json
import os

import markdown
import requests
import simplenote

# import openai

# Define the Simplenote credentials and tag to filter for
SIMPLENOTE_EMAIL = os.getenv("SIMPLENOTE_EMAIL")
SIMPLENOTE_PASSWORD = os.getenv("SIMPLENOTE_PASSWORD")
SIMPLENOTE_TAG = "anki"

# Define the AnkiConnect API endpoint and deck to use
ANKICONNECT_ENDPOINT = "http://localhost:8765"
ANKI_DECK_NAME = "00_inbox"

# Define the Anki note type and fields
ANKI_NOTE_TYPE = "Basic"
ANKI_FRONT_FIELD = "Front"
ANKI_BACK_FIELD = "Back"
ANKICONNECT_API_KEY = "mykey"  # 將此處替換為您的API密鑰


def get_sn():
    # Authenticate with Simplenote
    sn = simplenote.Simplenote(SIMPLENOTE_EMAIL, SIMPLENOTE_PASSWORD)

    # Get all notes with the specified tag
    notes = sn.get_note_list(tags=[SIMPLENOTE_TAG])
    notes = notes[0]

    for note in notes:
        content = note["content"] + "\n\n🤗"

        lines = content.split("\n")
        title = lines[0]
        back = "\n".join(lines[1:])
        print("--------")
        # Define the AnkiConnect note payload
        # back = back + "\n" + add_explain(content)
        sent_to_anki(title, back)
        # change tags

        note["tags"] = ["added_to_anki" if x == "anki" else x for x in note["tags"]]
        sn.update_note(note)


def add_explain(note_body):
    prompt = "explained in Zh-tw of following <text>,:\n"
    full_prompt = prompt + note_body

    response = openai.Completion.create(
        model="text-davinci-003",
        prompt=full_prompt,
        max_tokens=2000,
        temperature=0.5,
    )

    explain = response["choices"][0]["text"]
    return explain


def sent_to_anki(title, back):
    back_html = markdown.markdown(back)
    # print(back_html)
    payload = {
        "key": ANKICONNECT_API_KEY,  # 使用API密鑰
        "action": "addNote",
        "version": 6,
        "params": {
            "note": {
                "deckName": ANKI_DECK_NAME,
                "modelName": ANKI_NOTE_TYPE,
                "fields": {
                    ANKI_FRONT_FIELD: title,
                    ANKI_BACK_FIELD: back_html,
                },
                "options": {
                    "allowDuplicate": False,
                },
                "tags": ["from_simplenote"],
            },
        },
    }

    # Send the AnkiConnect request
    response = requests.post(ANKICONNECT_ENDPOINT, data=json.dumps(payload))

    print(f"{title} done")
    # Print the response
    print(response.content.decode())


if __name__ == "__main__":
    get_sn()
