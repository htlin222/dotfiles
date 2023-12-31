import os
import re
import pyperclip as pc
text = pc.paste()

# replace:
# 「blablabla... 」
#
# 摘錄自:Author. 「」。Apple Books.
#
# To:
# blablabla...

result = re.sub('(\u300c)(.*)(\u300d\n\n\u6458\u9304\u81ea.*Apple\sBooks\.)','\g<2>',text)
# 小麻only
result = re.sub('\u2022','*',result)
result = re.sub('w/','with',result)

print(result)
