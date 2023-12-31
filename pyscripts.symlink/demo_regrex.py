import re
from googletrans import Translator
import os
import pyperclip as pc
text = pc.paste()
# text = 'this is 5.5 M. something."4,5 Then next'
# Move quote inside the .
sub_result = re.sub('\.("|”)', '".', text)
sub_result = re.sub('•','-',sub_result)
# delete citations
sub_result = re.sub('([0-9][0-9]*,)', '', sub_result)
# delete citation 12-34
sub_result = re.sub('\.(\d*-\d*)', '.', sub_result)
sub_result = re.sub('\.\s(\d*)(\s|$)', '. ', sub_result)
# delete citation at last line
sub_result = re.sub('(\.\d*\s|\.\d*$)', '. ', sub_result)
# break the lines
sub_result = re.sub('(\s[A-Za-z]*\S[a-z]*|]|\%|\)|")(\.\s)([A-Z][A-Za-z]|A)', '\g<1>.\n\g<3>', sub_result)
# avoid empty line
sub_result = re.sub('- \n','- ',sub_result)
# translate
translator = Translator()
translated =translator.translate(sub_result, dest='zh-tw')
result = "- " + translated.text
# add first line and '-' in each line
result = "- ⭐ 學習重點 ⭐\n" + re.sub(r'(?m)^','\t- ',translated.text)
# clear dash
result = re.sub('- - ','- ',result)
text = re.sub('\n\n','\n',text)
text = re.sub(r'(?m)^','\t> 📋',text)
print(result,"\n\n",text)
# pc.copy(text1)

