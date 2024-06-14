#!/Users/htlin/.pyenv/versions/keyboardmaestro/bin/python
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clip To Imgur
# @raycast.mode silent
# @raycast.packageName Browsing
# Optional parameters:
# @raycast.icon 🌠
# Documentation:
# @raycast.author Hsieh.Ting Lin
# @raycast.description Imgur upload from Clipboard
import logging
import os
import subprocess
from pathlib import Path

import pyimgur
import pyperclip
from PIL import Image, ImageGrab

PILlogger = logging.getLogger("PIL")
PILlogger.setLevel(logging.CRITICAL)

CLIENT_ID = "713cacc415ed391"
IMAGE_PATH = f"{str(Path.home())}/Pictures/.tmp.png"
IMAGE = ImageGrab.grabclipboard()


def run_macos_notification(title, body):
    """Display a macOS notification with the specified title and body."""
    command = (
        f'osascript -e \'display notification with title "{title}" subtitle "{body}"\''
    )
    subprocess.run(command, shell=True)


def cmd_p():
    command = 'osascript -e \'tell application "System Events" to keystroke "v" using command down\''
    subprocess.run(command, shell=True)


def upload_image(image):
    """Check if image exists and upload."""
    if image is not None:
        run_macos_notification("🖼️ 上傳中 🆙", "跟我一起數萬, 吐, Three🎉")
        image = image.save(IMAGE_PATH)
        width, height = Image.open(IMAGE_PATH).size
        size_config = (
            "width:1150px"
            if float(width) / float(height) * 450 > 1100
            else "height:450px"
        )
        uploaded_image = pyimgur.Imgur(CLIENT_ID).upload_image(
            IMAGE_PATH, title="Uploaded by PyImgur"
        )
        md_formated_result = f"\n![Figure: {size_config}]({uploaded_image.link})\n\n"
        pyperclip.copy(md_formated_result)
        os.remove(IMAGE_PATH)
        run_macos_notification(
            "🎉 登登！你的圖片網址來啦👇爽爽爽😁", md_formated_result
        )
        # use this if you want cmd + p directly after the image uploaded
        # cmd_p()
    # else:
    # run_macos_notification("📋 只有一般文字", "🌻 祝您有個美好的一天")


if __name__ == "__main__":
    upload_image(IMAGE)
