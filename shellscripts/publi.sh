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

medical="$HOME/Dropbox/Medical/"
blog="$HOME/Dropbox/blog/"
# Loop through all files in the source folder
rsync -az --delete --include="*.md" --exclude="*" "$medical" ~/quartz/content/
rsync -az --delete --include="*.md" --exclude="*" "$blog" ~/quartz/content/blog/
echo "🔃 sync the folder"
echo "🧼 clean up"
rm ~/quartz/content/.md
echo "rsync complete at $(date)"

if git -C ~/quartz/ rev-parse --git-dir >/dev/null 2>&1; then
  git -C ~/quartz/ pull
  git -C ~/quartz/ add .
  git -C ~/quartz/ commit -m "routine quartzing 🌻 "
  git -C ~/quartz/ push
  echo "👉 see action at https://app.netlify.com/sites/lizardgarden/deploys"
  echo "👉 see website at https://www.physician.tw"
else
  echo "🔔 Not a git repo"
fi
echo "🏂"
if git -C ~/blog/ rev-parse --git-dir >/dev/null 2>&1; then
  git -C ~/blog/ pull
  git -C ~/blog/ add .
  git -C ~/blog/ commit -m "routine blogging ✏️ "
  git -C ~/blog/ push
  echo "👉 see action at https://app.netlify.com/sites/htlin/deploys"
  echo "👉 see website at https://htlin.site"
else
  echo "🔔 Not a git repo"
fi
echo "All Done 🥩"
