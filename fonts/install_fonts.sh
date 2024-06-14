#!usr/bin/env bash
#
# install all fonts in this folder

install_fonts(){
  local src=$1 dst=$2
  local overwrite= backup= skip=
  local action=
  if [-f "$dst" -o -d "$dst" -o -L "$dst"]
  then
    if ["$overwrite_all"=="false"]&&["backup_all"=="false"]&&["$skip_all"=="false"]
    then

      local currentSrc="$(readlink $dst)"
      if["$currentSrc"=="$src"]
      then
        skip=true;

      fi

    fi
  fi
}
