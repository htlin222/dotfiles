#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: emoji_to_utf8
# date: "2024-01-03"
# author: Hsieh-Ting Lin, the Lizard 🦎

import sys


def emoji_to_html(emoji):
    return "".join(f"&#x{ord(char):x};" for char in emoji)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        emoji = sys.argv[1]
        html_code = emoji_to_html(emoji)
        print(html_code)
    else:
        print("No emoji provided")
