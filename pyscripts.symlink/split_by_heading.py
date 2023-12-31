# -*- coding: utf-8 -*-
#!/usr/bin/env python3
# title: split_by_heading
# date created: "2023-01-23"
# python split_by_heading.py --level=2 --file="file.md"

import os
import sys
import argparse
from datetime import datetime

current_date_time = datetime.now()
string_date_time = current_date_time.strftime("%Y-%m-%d")


def main(file_path, heading_level):
    '''
    split markdown by heading level
    '''
    heading_list = ["NONE", "# ", '## ', '### ', '#### ', '##### ', '###### ']
    level = heading_list[int(heading_level)]
    higher_level_list = heading_list[1:int(heading_level)]
    with open(file_path, 'r') as f:
        lines = f.readlines()
        i = 0
        while i < len(lines):
            if lines[i].startswith(level):
                strip_level = int(heading_level) + 1
                heading = lines[i].strip()[strip_level:]
                filename = heading + ".md"
                wikilink = "[["+heading+"]]\n"
                lines[i] = lines[i].replace(heading, wikilink)
                lines[i] = lines[i].replace(level, "* ")
                with open(filename, "a") as f:
                    file_name = os.path.basename(file_path)
                    new_front_and_heading = \
                        '# Pocket Medicine::' + heading + '\n'
                    f.write(new_front_and_heading)
                    # f.write(lines[i])
                    i += 1
                    while i < len(lines) and not lines[i].startswith(level) \
                             and all(not lines[i].startswith(string) for string in higher_level_list):
                        f.write(lines[i])
                        lines[i] = ''
                        i += 1
            else:
                i += 1
    with open(file_path, 'w') as f:
        f.writelines(lines)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--level", type=int, help="level of heading",
                        default=2)
    parser.add_argument("--file", type=str, help="file name")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"Error: file '{args.file}' does not exist")
        sys.exit(1)
    heading_level = args.level
    original_file = args.file
    current_directory = os.getcwd()
    file_path = os.path.join(current_directory, original_file)
    main(file_path, heading_level)
