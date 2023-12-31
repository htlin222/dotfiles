import time
import os
import pyperclip
from PIL import ImageGrab
import pyimgur
# define the t to make the image name
t = time.localtime()
t = time.strftime("%y-%m-%d_%H_%M_%S", t)

CLIENT_ID = "713cacc415ed391"
title = "Uploaded with PyImgur"
image_path = "/Users/mac/Pictures"
# if not(os.path.exists(image_path)):
#    os.mkdir(image_path)
image_path = f"{image_path}/image-{t}.png"
image = ImageGrab.grabclipboard()
if image is not None:  # check if there's image in the clipboard
    image = image.save(image_path)
    im = pyimgur.Imgur(CLIENT_ID)
    uploaded_image = im.upload_image(image_path, title=title)
    # print(uploaded_image.title)
    # print(uploaded_image.link)
    # print(uploaded_image.type)
    link = uploaded_image.link
    result = f"![]({link})"
    os.remove(image_path)  # comment this line if you want to keep the image
else:
    link = "https://i.imgur.com/9HfL3bw.jpeg"
    result = f"![🤷🏻📷只好用一隻🦎]({link})"
# print(result)
pyperclip.copy(result)
spam = pyperclip.paste()  # save the result to system clipboard
print("Link Generated")
