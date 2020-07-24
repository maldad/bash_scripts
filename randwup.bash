#!/usr/bin/env bash

# Copyright © 2020 Antonio Hernández Blas <hba.nihilismus@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

# The query string to search for in wallpaperup.com:
#  In this case, pictures tagged as 'nature' with a ratio of '16:9'
export wpu_search_options=$1
# Other examples:
#  export wpu_search_options="animals+order:date_added+resolution:=:1920x1080"
#  export wpu_search_options="cats+order:downloads+ratio:1.33"
# You can get this query string from wallpaperup.com's search form.
# Other options available at: https://www.wallpaperup.com/search

# The path where the wallpaper will be saved:
export wpu_output=$HOME/background.jpg

set -u

wpu_page() {
  page=$(echo $RANDOM | sed 's/.*\(.\)$/\1/')
  if [ -z "$page" -o "$page" -eq 0 ]; then
    page=1
  fi
  if [ "$page" -gt 3 ]; then
    page=$(( $page / 3 ))
  fi
  echo $page
}

wpu_url() {
  wget -U Firefox -o /dev/null -O - "${1}" \
    | sed -e "s|${wpu_uploads}|\n${wpu_uploads}|g" \
    | grep -E " alt=.*data-wid=" \
    | sed -e "s|-...\.jpg .*$|.jpg|" \
    | shuf -n 20 \
    | shuf -n 10 \
    | shuf -n 1 \
    | grep -E "^${wpu_uploads}.*\.jpg$"
}

wpu_file() {
  wpu_search_page="$wpu_search_engine/$wpu_search_options/"$(wpu_page)
  echo "Searching wallpapers: $wpu_search_page"
  url_file="$(wpu_url $wpu_search_page)"
  if [ -z "${url_file}" ]; then
    return 1
  fi
  echo "Downloading wallpaper: $url_file"
  wget -U Firefox -o /dev/null -O ${wpu_output} "${url_file}"
  if [ $? -ne 0 ]; then
    rm -f "${wpu_output}"
    return 1
  fi
  file "${wpu_output}" 2>/dev/null | grep -q 'image data'
  if [ $? -ne 0 ]; then
    rm -f "${wpu_output}"
    return 1
  fi
}

main() {
  export wpu_search_engine="https://www.wallpaperup.com/search/results"
  export wpu_uploads="https://www.wallpaperup.com/uploads/wallpapers"
  wpu_file
  if [ $? -ne 0 -o ! -f "${wpu_output}" ]; then
    echo "Error: there was an error with the wallpaper being downloaded."
    exit 1
  fi
  echo "Setting wallpaper: ${wpu_output}"
  hsetroot -fill "${wpu_output}" \
    -tint '#888888' -blur 1.5 -sharpen 1.0 -gamma 1.5 >/dev/null 2>&1
}

main
