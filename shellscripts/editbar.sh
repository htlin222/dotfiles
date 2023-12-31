#!/bin/bash

# Loop over the past 7 days
for i in {0..6}; do
	# Calculate the date for each day (macOS and BSD)
	# day=$(date -j -v-"$i"d '+%Y-%m-%d')
	day=$(perl -e "use POSIX qw(strftime); print strftime '%Y-%m-%d', localtime(time - $i * 24 * 60 * 60);")
	# Find files modified on that day in the current directory and count them
	count=$(find . -maxdepth 1 -type f -newermt "$day" ! -newermt "$day 1 day" -print 2>/dev/null | wc -l)

	# Generate the bar using emoji 🟩
	bar=""
	if [ "$count" -eq 0 ]; then
		bar="🥚"
	else
		for ((j = 1; j <= count; j++)); do
			bar="${bar}🟩"
		done
	fi
	# Print the bar
	echo "🗓️  $day: $bar"
done
