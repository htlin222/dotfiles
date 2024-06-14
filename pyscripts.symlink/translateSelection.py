from googletrans import Translator
import os
import pyperclip as pc
text = pc.paste()
if len(text) < 1500:
    translator = Translator()
    translated =translator.translate(text, dest='zh-tw')
    print(translated.text)
else:
    print("選太多啦！API罷工")
# pc.copy(text1)
