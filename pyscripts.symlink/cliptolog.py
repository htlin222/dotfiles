#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: cliptolog
# date: "2023-02-21"


import openai
import pyperclip
import os
import datetime


def main():

    # Get OpenAI API key from environment variable
    openai.api_key = os.environ.get("OPENAI_API_KEY")

    # Get text from clipboard
    text = pyperclip.paste()

    # Generate response using OpenAI API
    prompt = f"title about: {text} "
    print(prompt)
    response = openai.Completion.create(
        engine="davinci",
        prompt=prompt,
        max_tokens=60,
        n=1,
        stop=None,
        temperature=0.5,
    )

    # Extract response text from OpenAI API result
    short_line = response.choices[0].text.strip()

    # Combine short line and clipboard text
    result = "## " + short_line + "\n" + text

    # Create or open markdown file
    now = datetime.datetime.now()
    date_str = now.strftime("%Y-%m-%d")
    filename = f"clip_from_web_{date_str}.md"
    dir_path = os.path.expanduser("~") + "/Documents/Medical/clips"
    filepath = os.path.join(dir_path, filename)
    if not os.path.exists(filepath):
        with open(filepath, "w", encoding="utf8") as f:
            f.write("> Clipboard Text from the Web\n\n")

    # Append result to markdown file
    with open(filepath, "a") as f:
        f.write(result + "\n\n")
        print(result)
        print(f"Result saved to {filepath}")


if __name__ == '__main__':
    main()
