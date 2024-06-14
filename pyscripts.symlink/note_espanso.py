#!/usr/bin/env python3
import re
import sys
import os
import glob

def scan_the_folder_and_read():
    '''
    get current directory and read all the files
    '''
    medical = os.getcwd()
    trigger_replace_list = []
    for file in os.listdir(medical):
        if file.endswith(".md"):
            with open(file, 'r', encoding='UTF-8') as file_object:
                text = file_object.read()
                # trigger_replace = re.sub(r'\*\*([^\*]*):(\s*)\*\*',\
                #                         '\t- trigger: "\g<2> "\n\t\treplace:\g<1>',\
                #                         text)
                print(text)
                trigger_replace = re.sub(r'\*\*(.*)\:\:(.*)\*\*',\
                                        '  -\n    trigger: "\g<2> "\n    replace: "\g<1> "',\
                                        text)
                print(trigger_replace)
                trigger_replace_list.append(trigger_replace)
    return trigger_replace_list

def save_to_yml(trigger_replace_list):
    '''
    append trigger_replace to the _note.yml
    '''
    for trigger_replace in trigger_replace_list:
        with open("../_note.yml", "a", encoding='UTF-8') as file_object:
            # Append 'hello' at the end of file
            file_object.write(trigger_replace)

if __name__=='__main__':
    # print(os.getcwd())
    working_list = scan_the_folder_and_read()
    save_to_yml(working_list)
    print("DONE")
