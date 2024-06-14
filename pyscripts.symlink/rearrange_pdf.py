#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: rearrange_pdf
# author: Hsieh-Ting Lin, the Lizard 🦎
# description: 把簡報印成小冊子，時常拿出來蕊，不是一件很快樂的事嗎？
# date: "2024-04-17"
# --END-- #

"""
把簡報印成小冊子，時常拿出來蕊，不是一件很快樂的事嗎？
👉
最近要做的簡報有點多，平均每週都要生出一個40分鐘的seminar內容。雖然把資料請ChatGPT快速整理好、做成Slide還算是穩定，但實際開講不卡詞，還是需要常常蕊一下。所以我習慣還是把簡報印出來，可以塗塗改改、加上註解等。
👉
但為了不成為環保殺手，所以印成四合一雙面、短邊翻面，較省紙。然而，如果想要印成一個小冊子，就需要動點腦筋。要將頁碼重排，1,2,3,4,5,6,7,8，改成1,3,5,7,4,2,8,6，這樣1的背面就會是2，3的背面就是4，以及類推。
"""

import sys

from PyPDF2 import PdfReader, PdfWriter


def add_blank_pages(writer, num_pages):
    from PyPDF2 import PageObject

    blank_page = PageObject.create_blank_page(width=842, height=595)  # 橫向A4 size page
    for _ in range(num_pages):
        writer.add_page(blank_page)


def rearrange_pages(filename):
    # 讀取PDF文件
    reader = PdfReader(filename)
    original_pages = reader.pages
    total_pages = len(original_pages)

    # 計算需要添加的空白頁數
    remainder = total_pages % 8
    if remainder != 0:
        blank_pages = 8 - remainder
    else:
        blank_pages = 0

    # 創建PDF寫入器
    writer = PdfWriter()

    # 添加原始頁面
    for page in original_pages:
        writer.add_page(page)

    # 添加空白頁至可以被8整除
    if blank_pages > 0:
        add_blank_pages(writer, blank_pages)
        total_pages += blank_pages

    # 創建另一個PDF寫入器用於重排
    rearranged_writer = PdfWriter()

    # 重排每8頁的順序
    new_order = [0, 2, 4, 6, 3, 1, 7, 5]  # 將1,2,3,4,5,6,7,8的索引轉換為0,1,2,3,4,5,6,7
    for start in range(0, total_pages, 8):
        for index in new_order:
            if (start + index) < total_pages:  # 確保不會試圖添加不存在的頁面
                rearranged_writer.add_page(writer.pages[start + index])

    # 儲存重排後的PDF文件
    new_filename = "rearranged_" + filename
    with open(new_filename, "wb") as f:
        rearranged_writer.write(f)

    return new_filename


def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <filename.pdf>")
        sys.exit(1)

    filename = sys.argv[1]
    new_pdf = rearrange_pages(filename)
    print(f"Rearranged PDF saved as {new_pdf}")


if __name__ == "__main__":
    main()
