#!/Users/htlin/.pyenv/versions/keyboardmaestro/bin/python
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Save Clipboard Image
# @raycast.mode silent
# @raycast.packageName Clipboard
# Optional parameters:
# @raycast.icon 💾
# Documentation:
# @raycast.author Hsieh.Ting Lin
# @raycast.description Imgur upload from Clipboard
import logging
import random
import subprocess
from datetime import datetime
from pathlib import Path

from PIL import Image
from PIL import ImageGrab

now = datetime.now()
rnd_number = random.randint(1000, 9999)

# Format the date and time as 'YYYY_MM_DD_HH_MM'
formatted_now = now.strftime("%Y_%m_%d_%H_%M")
formatted_now
PILlogger = logging.getLogger("PIL")
PILlogger.setLevel(logging.CRITICAL)

CLIENT_ID = "713cacc415ed391"
IMAGE_PATH = (
    f"{str(Path.home())}/Documents/images/Anki_{formatted_now}_{rnd_number}.png"
)
IMAGE = ImageGrab.grabclipboard()


def run_macos_notification(title, body):
    """Display a macOS notification with the specified title and body."""
    command = (
        f'osascript -e \'display notification with title "{title}" subtitle "{body}"\''
    )
    subprocess.run(command, shell=True)


def cmd_p():
    command = f'osascript -e \'tell application "System Events" to keystroke "v" using command down\''
    subprocess.run(command, shell=True)


def upload_image(image):
    """Check if image exists and upload."""
    if image is not None:
        run_macos_notification("🖼️ 把圖片從剪貼版存下來啦⬇️ ", "存到了~/Documents/images/")
        image = image.save(IMAGE_PATH)


if __name__ == "__main__":
    upload_image(IMAGE)
