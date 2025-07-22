#!/bin/bash
# title: "stop"
# author: Hsieh-Ting Lin
# date: "2025-07-22"
# version: 1.0.0
# description:
# --END-- #
current_folder=$(basename "$PWD")
# Construct the message
message="$current_folder 中的對話已經完成"

afplay /System/Library/Sounds/Hero.aiff
# Speak the message aloud
say -r 220 "$message"
# Send a notification
ntfy publish lizard "$current_folder 對話結束"
