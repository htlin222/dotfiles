#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# @raycast.title Bitly
# @raycast.author HTLin the
# @raycast.authorURL https://github.com/htlin222
# @raycast.description short the URL

# @raycast.icon 🔗
# @raycast.mode fullOutput
# @raycast.packageName System
# @raycast.schemaVersion 1
import os
import re
import sys
from pathlib import Path

import pyperclip
import bitlyshortener

# Bitly token: read from env or ~/.bitly_token — never hardcode in this public repo
api_token = os.environ.get("BITLY_TOKEN", "")
if not api_token:
    token_file = Path.home() / ".bitly_token"
    if token_file.is_file():
        api_token = token_file.read_text().strip()
if not api_token:
    print("Missing Bitly token: set BITLY_TOKEN or create ~/.bitly_token")
    sys.exit(1)
# get myurl from clipboard
myurl = pyperclip.paste()
# Create and regex for check if a valid URL or not
regex = re.compile(
        r'^(?:http|ftp)s?://' # http:// or https://
        r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+(?:[A-Z]{2,6}\.?|[A-Z0-9-]{2,}\.?)|' #domain...
        r'localhost|' #localhost...
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' # ...or ip
        r'(?::\d+)?' # optional port
        r'(?:/?|[/?]\S+)$', re.IGNORECASE)

# Check if is vaild URL
if re.match(regex, myurl) is not None:
    # you can have more than one tokens if you want
    tokens_pool = [api_token]
    shortener = bitlyshortener.Shortener(tokens=tokens_pool, max_cache_size=256)
    long_urls = [myurl, 'http://www.google.com']
    x = shortener.shorten_urls(long_urls)
    print(x[0])
else:
    print("Not a valid url")
