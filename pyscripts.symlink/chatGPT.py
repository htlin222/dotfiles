#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: chatGPT
# date: "2023-02-12"

import openai
import pyperclip
import os

def main():

    openai.api_key = os.environ.get('OPENAI_API_KEY')
    input_text = pyperclip.paste()

    def respond(prompt):
        completions = openai.Completion.create(
            engine="text-davinci-002",
            prompt=prompt,
            max_tokens=1024,
            n=1,
            stop=None,
            temperature=0.5,
        )

        message = completions.choices[0].text
        return message

    if isinstance(input_text, str):
        input_text = "key points of the following paragraph: " + input_text
        response = respond(input_text)
        lines = [line for line in response.splitlines() if line.strip()]

        result = '\n'.join(lines)
        print(result)
    else:
        print("The clipboard does not contain text.")


if __name__ == '__main__':
    main()

