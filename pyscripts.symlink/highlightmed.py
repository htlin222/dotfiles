#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: highlightmed
# date: "2023-02-18"
# @raycast.title highlightmed
# @raycast.author HTLin the 🦎
# @raycast.authorURL https://github.com/htlin222
# @raycast.description hight the medical term from selection

# @raycast.icon 🖍️
# @raycast.mode silent
# @raycast.packageName System
# @raycast.schemaVersion 1

import nltk

# download the required resources

# sample sentence
sentence = "The quick brown fox jumped over the lazy dog"

# tokenize the sentence into words
words = nltk.word_tokenize(sentence)

# get the part-of-speech tags for each word
pos_tags = nltk.pos_tag(words)

# add ** syntax to the nouns
highlighted_sentence = ''
for word, pos in pos_tags:
    if pos.startswith('N'):
        highlighted_sentence += '**' + word + '** '
    else:
        highlighted_sentence += word + ' '

print(highlighted_sentence)
