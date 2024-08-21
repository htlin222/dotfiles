#!/bin/bash
# title: publi
# date created: "2023-02-04"

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Publish the quartz
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon  🏡
#
# Documentation:
# @raycast.description Git Push and rsync the medical content to my website.
# @raycast.author Hsieht-Ting Lin
# @raycast.authorURL https://github.com/htlin222

# Define the source and destination folders
medical="$HOME/Dropbox/Medical/"
# src="$HOME/Dropbox/Medical/src/"
blog="$HOME/Dropbox/blog/"
# slides="$HOME/Dropbox/slides/output/"

# Loop through all files in the source folder
rsync -az --delete --include="*.md" --exclude="*" "$medical" ~/quartz/content/
rsync -az --delete --include="*.md" --exclude="*" "$blog" ~/quartz/content/blog/
# rsync -az --delete --include="*.svg" --exclude="*" "$src" ~/quartz/content/src/
# rsync -az --delete --include="*/" --include="*" "$slides" ~/quartz/content/slides/
echo "🔃 sync the folder"
# sed -i "" 's/\^[0-9]*//g' ~/quartz/content/*.md
# sed -i "" 's/\[\[index\]\]/[花園大門口](https:\/\/www.physician.tw\/)/g' ~/quartz/content/*.md
echo "🧼 clean up"
# mv ~/quartz/content/index.md ~/quartz/content/_index.md
rm ~/quartz/content/.md
# cp ~/quartz/content/index.md ~/quartz/content/_index.md
echo "rsync complete at $(date)"

if [[ $1 == 'cite' ]]; then
  cd ~/quartz/content || exit
  echo "📎Add Citation by pandoc"
  "$DOTFILES"/shellscripts/md_add_cite.sh
  sed -i "" 's/\\//g' ~/quartz/content/*
fi

if git -C ~/quartz/ rev-parse --git-dir >/dev/null 2>&1; then
  git -C ~/quartz/ add .
  git -C ~/quartz/ commit -m "routine quartzing 🌻 "
  git -C ~/quartz/ push
  echo "👉 see action at https://github.com/htlin222/quartz/actions"
  echo "👉 see website at https://www.physician.tw"
else
  echo "🔔 Not a git repo"
fi
echo "🏂"
if git -C ~/blog/ rev-parse --git-dir >/dev/null 2>&1; then
  git -C ~/blog/ add .
  git -C ~/blog/ commit -m "routine blogging ✏️ "
  git -C ~/blog/ push
  echo "👉 see action at https://app.netlify.com/sites/htlin/deploys"
  echo "👉 see website at https://htlin.site"
else
  echo "🔔 Not a git repo"
fi
echo "All Done 🥩"
