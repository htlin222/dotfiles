#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "emoji_survival_vulcan"
# Date: "2023-12-20"
# Version: 1.0.0
# Notes: Live long and prosperous

# Input argument for the number of Vulcan salute emojis
vulcan_salutes=$1

# Check if input is a number and within the range 0-100
if ! [[ "$vulcan_salutes" =~ ^[0-9]+$ ]] || [ "$vulcan_salutes" -lt 0 ] || [ "$vulcan_salutes" -gt 100 ]; then
	echo "Warning: Input must be a number between 0 and 100."
	exit 1
fi

count=0

for i in {1..100}; do
	if [ $count -lt $vulcan_salutes ]; then
		printf "🖖"
	else
		printf "🪦"
	fi

	count=$((count + 1))

	if [ $((i % 10)) -eq 0 ]; then
		printf "\n"
	fi
done
