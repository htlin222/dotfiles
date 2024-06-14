#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# @raycast.title split and highlight
# @raycast.author HTLin the 🦎
# @raycast.authorURL https://github.com/htlin222
# @raycast.description split the paragraph and highlight the nouns

# @raycast.icon ⚡
# @raycast.mode silent
# @raycast.packageName System
# @raycast.schemaVersion 1

import re

import nltk
import pyperclip as pc
# retrieve the text from the clipboard

text = pc.paste()
# define a regular expression to match the title
def main(text):

    regex = r'\s\s*[-–]\s\s*'
    parts = re.split(regex, text, maxsplit=1)
    if len(parts) > 1:
        title = parts[0]
        print(f"Got it: {title}")
        title_md = f"\n## {title}\n\n"
        content = parts[1]
        content = split_and_hightlight(content)
        return f"{title_md}{content}\n"
    else:
        return split_and_hightlight(text)

def split_and_hightlight(text):
    # take the ',000' out to avoid been replace
    sub_result = re.sub(',000','KILO',text)
    # move quote inside the period
    sub_result = re.sub('\.("|”)', '".', sub_result)
    # delete the dots at the beginning of the line
    sub_result = re.sub('(●|•|•\s)','',sub_result)
    # delete citations: NEJM style, Uptodate style, Clinical Key style
    # 1. NEJM
    sub_result = re.sub(',[0-9]{1,2}', '', sub_result)
    sub_result = re.sub('[0-9]{1,2};', '', sub_result)
    sub_result = re.sub('\.[0-9]{1,2}-[0-9]{1,2}(\s[A-Z][A-Za-z]*|\n)', '.\g<1>', sub_result)
    sub_result = re.sub('\.[0-9]{1,2}(\s[A-Z][A-Za-z]*|$)', '.\g<1>', sub_result)
    # 2. Clinical Key
    sub_result = re.sub('(\.|,|\))\s([0-9]{1,2})(\s|$)([A-Za-z]|A|\d)', '\g<1> \g<3>', sub_result)
    sub_result = re.sub('[0-9]\s\.','.',sub_result)
    # 3. Uptodate
    sub_result = re.sub('\[[0-9]{1,2}\]\.', '. ', sub_result)
    sub_result = re.sub('\[[0-9]{1,2}(-|,)[0-9]{1,2}\]\.', '. ', sub_result)
    # replace KILO back to ,000
    sub_result = re.sub('KILO',',000',sub_result)
    # break the lines
    sub_result = re.sub('(\s[A-Za-z]*\S[a-z]*[A-Za-z]|]|\%|\)|"|\s)(\.\s\s*)([A-Z][A-Za-z]|A|\d)', '\g<1>.\n\g<3>', sub_result)
    # Fix the Fig. Number
    sub_result = re.sub('Fig\.\n([0-9]{1,2})','Fig. \g<1>',sub_result)
    # add period if there's no period at the end of line
    sub_result = re.sub('\n\n','.\n',sub_result)
    # delete empty space in the beginning
    sub_result = re.sub('\n\s','\n',sub_result)
    # delete empty line
    sub_result = re.sub('^\n','',sub_result)

    # add '-' in each line and add title
    result = re.sub(r'(?m)^','- ',sub_result)
    # format the original text by adding >
    text = re.sub('\n\n','\n',text)
    text = re.sub(r'(?m)^','\n\n\t> 📋',text)

    highlighted_sentences = []
    for sentence in result.splitlines():

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
        highlighted_sentences.append(highlighted_sentence)

    return  "\n".join(highlighted_sentences)

if __name__=='__main__':
    text = pc.paste()
    result = main(text)
    pc.copy(result)
