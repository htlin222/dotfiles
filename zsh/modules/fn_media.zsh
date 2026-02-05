# Media Processing Functions

# YouTube to MP3
function yt-mp3() {
  yt-dlp --extract-audio --audio-format mp3 \
    -o "%(playlist|.)s/%(playlist_index|)s%(playlist_index&_|)s%(title)s.%(ext)s" \
    "$1"
}

# YouTube playlist to MP3
function yt-mp3-list() {
  folder_name=$(basename "$(pwd)")
  if ! command -v pbpaste &>/dev/null; then
    echo "pbpaste not available" >&2
    return 127
  fi
  yt-dlp --extract-audio --audio-format mp3 "$(pbpaste)" -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"
}

# YouTube playlist download
function yt-playlist() {
  yt-dlp "$1" -o "%(playlist)s/%(playlist_index)s_%(title)s.%(ext)s"
}

# YouTube with cookies (for bilibili 1080p)
function yt-list-cookies() {
  yt-dlp "$1" -o "%(playlist)s/%(playlist_index)s_%(title)s.%(ext)s" --cookies-from-browser edge
}

# Generate playlist text file
function playlist() {
  playlist_name=$(yt-dlp "$1" -I 1:1 --skip-download --no-warning --print playlist_title | tr ' ' '_' | tr -d '/\\' | tr -d '[:punct:]')
  echo "start to generate playlist: ${playlist_name}"
  yt-dlp -i --get-filename -o "%(title)s" "$1" >"${playlist_name}.txt"
}

# Join MP4 files
joinmp4() {
  for file in *.mp4; do
    echo "$file: $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file") seconds"
  done
  for file in *.mp4; do
    echo "file '$file'" >>filelist.txt
  done
  ffmpeg -f concat -safe 0 -i filelist.txt -c copy combined_$1.mp4
}

# Join MP3 files
function joinmp3() {
  cd $1
  for f in ./*.mp3; do echo "file '$f'" >>mylist.txt; done
  ffmpeg -y -f concat -safe 0 -i mylist.txt -c copy output.mp3
  cd -
}

# Convert MP4 to GIF
function convert_mp4_to_gif() {
  if [[ -z "$1" ]]; then
    echo "Usage: convert_mp4_to_gif <input_file.mp4>"
    return 1
  fi
  local input_file=$1
  if [[ "${input_file: -4}" != ".mp4" ]]; then
    echo "The input file must be a .mp4 file."
    return 1
  fi
  local output_file="${input_file%.mp4}.gif"
  ffmpeg -y -i "$input_file" -r 15 -vf "scale=720:-1" -ss 00:00:00 -to 00:00:10 "$output_file"
  echo "GIF created: $output_file"
}

# Transcribe audio with OpenAI Whisper
transcribe_audio() {
  local file_path=$1
  local file_name=$(basename "$file_path")
  local output_file="${file_name}.txt"
  curl --request POST \
    --url https://api.openai.com/v1/audio/transcriptions \
    --header "Authorization: Bearer $OPENAI_API_KEY" \
    --header "Content-Type: multipart/form-data" \
    --form file=@${file_path} \
    --form model=whisper-1 | jq -r '.text' >"${output_file}"
  if command -v pbcopy &>/dev/null; then
    cat "$output_file" | pbcopy
  fi
  bat $output_file
}

# Convert images to slides PDF with watermark
toslides() {
  local fontsize=${1:-72}
  local foldername="${PWD##*/}"
  local output="${foldername}_slides.pdf"
  local tmp_prefix="wm_"
  local exts=("jpg" "png" "JPG" "PNG")
  local has_images=false

  for ext in "${exts[@]}"; do
    for img in *."$ext"; do
      [[ -e "$img" ]] || continue
      has_images=true
      break 2
    done
  done

  if ! $has_images; then
    echo "⚠️ No .jpg or .png files found in current directory."
    return 1
  fi

  echo "🔧 Adding filename watermark with font size $fontsize..."
  for ext in "${exts[@]}"; do
    for img in *."$ext"; do
      [[ -e "$img" ]] || continue
      local out="${tmp_prefix}${img}"
      magick "$img" -gravity southeast -pointsize $fontsize \
        -fill white -undercolor black \
        -annotate +20+20 "$img" "$out"
    done
  done

  echo "🧾 Combining into $output..."
  img2pdf ${tmp_prefix}* -o "$output" --auto-orient
  echo "🧹 Cleaning up..."
  rm -f ${tmp_prefix}*
  echo "✅ Done! Output: $output"
}

# Create caption image from text file
function capimg() {
  command -v magick >/dev/null 2>&1 || { echo "magick 未安裝或不在 PATH 中"; return 1 }
  local file="${1:-info.txt}"
  magick -size 1720x880 -background white -fill black -font Courier -pointsize 48 caption:@"$file" -gravity center -extent 1920x1080 00_cover.png
}
