#!/bin/bash
# title: "cleanup_downloads"
# author: Hsieh-Ting Lin
# date: "2025-05-07"
# version: 1.0.0
# description:
# --END-- #
DOWNLOADS_DIR="$HOME/downloads"
DAYS_OLD=14

# Find and delete files older than 2 weeks
find "$DOWNLOADS_DIR" -type f -mtime +$DAYS_OLD -exec rm -f {} \;

echo "Files older than $DAYS_OLD days have been deleted from $DOWNLOADS_DIR."
