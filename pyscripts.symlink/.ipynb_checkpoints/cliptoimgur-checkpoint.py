import pyimgur
import pyperclip
from PIL import ImageGrab
import os
import time
from pathlib import Path
home = str(Path.home())
# define the t to make the image name
t = time.localtime()
t = time.strftime("%y-%m-%d_%H_%M_%S", t)
# set your client I
CLIENT_ID = "713cacc415ed391"
title = "Uploaded with PyImgur"
# if not(os.path.exists(image_path)):
#    os.mkdir(image_path)
image_path = f"{home}/Pictures/image-{t}.png"
image = ImageGrab.grabclipboard()
if image is not None: # check if there's image in the clipboard
    image = image.save(image_path)
    im = pyimgur.Imgur(CLIENT_ID)
    uploaded_image = im.upload_image(image_path, title=title)
    # print(uploaded_image.title)
    # print(uploaded_image.link)
    # print(uploaded_image.type)
    link = uploaded_image.link
    result = f"![image_{t}]({link})"
    # pyperclip.copy(result)
    # spam = pyperclip.paste() # save the result to system clipboard
    os.remove(image_path)  # comment this line if you want to keep the image
else:
    link = "https://i.imgur.com/9HfL3bw.jpeg"
    result = f"![🤷🏻📷找不到圖片，只好用一隻🦎]({link})"
print(result)
