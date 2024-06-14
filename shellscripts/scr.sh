#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "scr"
# Date: "2023-12-21"
# Version: 1.0.0
# Notes:
#!/bin/bash

convert_to_script() {
	local input=$1

	# Convert each character to its script form using sed
	echo "$input" | sed -e 's/A/𝒜/g' -e 's/B/ℬ/g' -e 's/C/𝒞/g' -e 's/D/𝒟/g' \
		-e 's/E/ℰ/g' -e 's/F/ℱ/g' -e 's/G/𝒢/g' -e 's/H/ℋ/g' \
		-e 's/I/ℐ/g' -e 's/J/𝒥/g' -e 's/K/𝒦/g' -e 's/L/ℒ/g' \
		-e 's/M/ℳ/g' -e 's/N/𝒩/g' -e 's/O/𝒪/g' -e 's/P/𝒫/g' \
		-e 's/Q/𝒬/g' -e 's/R/ℛ/g' -e 's/S/𝒮/g' -e 's/T/𝒯/g' \
		-e 's/U/𝒰/g' -e 's/V/𝒱/g' -e 's/W/𝒲/g' -e 's/X/𝒳/g' \
		-e 's/Y/𝒴/g' -e 's/Z/𝒵/g' \
		-e 's/a/𝒶/g' -e 's/b/𝒷/g' -e 's/c/𝒸/g' -e 's/d/𝒹/g' \
		-e 's/e/ℯ/g' -e 's/f/𝒻/g' -e 's/g/ℊ/g' -e 's/h/𝒽/g' \
		-e 's/i/𝒾/g' -e 's/j/𝒿/g' -e 's/k/𝓀/g' -e 's/l/𝓁/g' \
		-e 's/m/𝓂/g' -e 's/n/𝓃/g' -e 's/o/ℴ/g' -e 's/p/𝓅/g' \
		-e 's/q/𝓆/g' -e 's/r/𝓇/g' -e 's/s/𝓈/g' -e 's/t/𝓉/g' \
		-e 's/u/𝓊/g' -e 's/v/𝓋/g' -e 's/w/𝓌/g' -e 's/x/𝓍/g' \
		-e 's/y/𝓎/g' -e 's/z/𝓏/g'
}

convert_to_script "$1"
