#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: trans_doi_to_bib
# date: "2023-10-31"
# author: Hsieh-Ting Lin, the Lizard 🦎
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DOI to Citation
# @raycast.mode silent
# @raycast.packageName Browsing
# Optional parameters:
# @raycast.icon 🔖
# Documentation:
# @raycast.author Hsieh.Ting Lin
# @raycast.description DOI to short citation
# import argparse
import subprocess

import bibtexparser
import pyperclip


def run_macos_notification(title, body):
    """Display a macOS notification with the specified title and body."""
    command = (
        f'osascript -e \'display notification with title "{title}" subtitle "{body}"\''
    )
    subprocess.run(command, shell=True)


def get_reference(doi):
    result = subprocess.run(["/Users/mac/.pyenv/shims/doi2bib", doi],
                            capture_output=True,
                            text=True)
    return result.stdout


def convert_bib_to_custom_format(bib_info):
    bib_database = bibtexparser.loads(bib_info)
    entry = bib_database.entries[0]

    custom_format = f"{entry.get('journal', 'N/A')} {entry.get('year', 'N/A')}; {entry.get('volume', 'N/A')}:{entry.get('pages', 'N/A')}"
    return custom_format.replace("--", "-")


def main(doi):
    reference = get_reference(doi)
    custom_format_string = convert_bib_to_custom_format(reference)
    return custom_format_string


if __name__ == "__main__":
    # parser = argparse.ArgumentParser(
    #     description="Convert a DOI to a custom reference format.")
    # parser.add_argument("-i",
    #                     "--input",
    #                     required=True,
    #                     help="The DOI to convert.")
    # args = parser.parse_args()
    # doi = args.input
    doi = str(pyperclip.paste())
    # print(doi)
    doi = doi.replace("https://doi.org/", "").replace("DOI: ", "")
    run_macos_notification("🛋️ 正在處理doi:", doi)
    custom_format_string = main(doi)
    pyperclip.copy(custom_format_string)
    run_macos_notification("💡 結果", custom_format_string)
