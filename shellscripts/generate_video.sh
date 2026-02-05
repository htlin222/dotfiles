#!/bin/bash
# generate_video.sh -f yourfile.md
#  --- SETUP ---
# Remember to Check if the command "edge-tts" exists

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

if [ $# -lt 1 ]; then
    echo "Usage: $0 -f <input_file>"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -f)
            shift
            input_file="$1"
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done
output_dir="${input_file%.md}.tmp"
output_file="${input_file%.md}.mp4"
mkdir -p "$output_dir"

# TODO: Chose theme, and generate multiple version at once
# css_file="short.css"
# marp --theme-set ./themes

marp --theme-set ./themes --images png "$input_file" --image-scale 2 -o "$output_dir/${input_file%.md}.png"
# marp --images png "$input_file" --image-scale 2  --theme-set ./themes -o "$output_dir"
#  --- SPLIT ---
awk -v output_dir="$output_dir" -v input_file="$input_file" 'BEGIN { RS = "---\n"; FS = "\n" } NR > 2 { split(input_file, input_parts, "."); output_file = output_dir "/" input_parts[1] "." sprintf("%03d", NR-2) ".md"; print $0 > output_file }' "$input_file"

#  --- GENERATE CLIPS ---
process_file() {
    local input_file="$1"
    local base_name="${input_file%.md}"
    # marp --image png "$1" --image-scale 2
    sed 's/<!--\([^>]*\)-->/[\1]/g' "$1" >> "${base_name}_mod.md"
    # TODO: Remove ![setting](image.jpg)
    if is_mac; then
        sed -i '' '/!\[.*\](.*)/d' "${base_name}_mod.md"
    else
        sed -i '/!\[.*\](.*)/d' "${base_name}_mod.md"
    fi
    # NB: Option 1: clean up markdown by pandoc
    # pandoc -f markdown -t plain --wrap=none "${base_name}_mod.md" -o "${base_name}.txt"
    # NB: Option 2: extract comment only
    marp "${base_name}_mod.md" -o "${base_name}.txt"
    rm -f "${base_name}_mod.md"
    # NOTE: Select lang
    # Name: zh-TW-HsiaoChenNeural Gender: Female
    # Name: zh-TW-HsiaoYuNeural Gender: Female
    # Name: zh-TW-YunJheNeural Gender: Male
    edge-tts --rate=+25% --voice zh-TW-YunJheNeural -f "${base_name}.txt" --write-media "${base_name}.mp3" --write-subtitles "${base_name}.vtt"
    # TODO: fix the ugly code
    if is_mac; then
        sed -i "" 's/\([^A-Za-z]\)[[:space:]]\([^A-Za-z]\)/\1\2/g' "${base_name}.vtt"
        sed -i "" 's/\([^A-Za-z]\)[[:space:]]\([^A-Za-z]\)/\1\2/g' "${base_name}.vtt"
    else
        sed -i 's/\([^A-Za-z]\)[[:space:]]\([^A-Za-z]\)/\1\2/g' "${base_name}.vtt"
        sed -i 's/\([^A-Za-z]\)[[:space:]]\([^A-Za-z]\)/\1\2/g' "${base_name}.vtt"
    fi
    perl -i -pe 's/(?<=\S)-->(?=\S)/ --> /g' "${base_name}.vtt"
    ffmpeg -y -i "${base_name}.vtt" "${base_name}.srt" -hide_banner
    # Remove white spaces

    input_image="${base_name}.png"
    if command -v sips >/dev/null 2>&1; then
        image_width=$(sips -g pixelWidth "$input_image" | grep pixelWidth | awk '{print $2}')
    elif command -v identify >/dev/null 2>&1; then
        image_width=$(identify -format "%w" "$input_image")
    else
        echo "Missing image width tool (sips or identify)" >&2
        return 1
    fi
    input_audio="${base_name}.mp3"
    output_video="${base_name}.mp4"
    duration=$(ffprobe -i "$input_audio" -show_entries format=duration -v quiet -of csv="p=0")
    settings="-c:v libx264 -tune stillimage -c:a aac -b:a 96k -r 30 -pix_fmt yuv420p -t $duration"
    sub_settings="-vf subtitles=${base_name}.srt:force_style='Fontname=PingFangTC-Regular,OutlineColour=&000000000,BorderStyle=3,Outline=3,Shadow=0,MarginV=20'"
    # progress_bar="-filter_complex 'color=c=gray:s=${image_width}x10[bar];[0][bar]overlay=-w+(w/10)*t:H-h:shortest=1'"
    ffmpeg -y -loop 1 -i "$input_image" -i "$input_audio" $settings $sub_settings "$output_video"
}

for file in "$output_dir"/*.md; do
    if [ -f "$file" ]; then
        process_file "$file"
    fi
done

#  --- COMBINE ---
#
input_list="input_list.txt"
rm -f "$input_list"
# TODO: Cretae Opening Title
# echo "file 'opening.mp4'" >> "$input_list"
for input_file in "$output_dir"/*.mp4; do
    echo "file '$input_file'" >> "$input_list"
done

ffmpeg -y -f concat -safe 0 -i "$input_list" -c:v libx264 -c:a aac -strict experimental "$output_file"
# rm -f "$input_list"
# rm -rf "$output_dir"
echo "🟢 DONE 🟢"
message="$output_file"
title="影片輸出已完成"
notify "$title" "$message"
