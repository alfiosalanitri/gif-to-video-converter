#!/bin/bash
#
# NAME
# 	gif-to-video-converter - Convert a gif file or gif url to mp4|webp|ogv with ffmpeg.
#
# SYNOPSIS
#	gif-to-video-converter file.gif|url/file.gif
#
# INSTALLATION
#	sudo chmod +x /path/to/gif-to-video-converter
#
# REQUIREMENTS
#	- ffmpeg and wget packages 
#
# AUTHOR:
#	gif-to-video-converter is written by Alfio Salanitri <www.alfiosalanitri.it> and are licensed under MIT license.
#

#############################################################
# Icons	and color
# https://www.techpaste.com/2012/11/print-colored-text-background-shell-script-linux/
# https://apps.timwhitlock.info/emoji/tables/unicode
#############################################################
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nocolor='\033[0m'
icon_ok='\xE2\x9C\x94'
icon_ko='\xe2\x9c\x97'
icon_wait='\xE2\x8C\x9B'
icon_rocket='\xF0\x9F\x9A\x80'

# Usage
if [ $# -eq 0 ]; then
  cat <<-EOF
  Usage: $0 input_file
  Convert a gif to mp4|webp|ogv with ffmpeg.

  input_file  | A valid gif file to convert. If given a URI, this script will
  try to download it for you and then convert it.
EOF
  exit 1
fi

# user input gif
GIF=$1

if ! command -v ffmpeg &> /dev/null; then
  printf "[${red}${icon_ko}${nocolor}] Sorry, but ${green}ffmpeg${nocolor} is required. Install it with apt install ffmpeg.\n"
  exit 1;
fi

# Download the input file if given a URI
gifurl='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
if [[ $GIF =~ $gifurl ]]; then
  filename=$(basename "${GIF}")
  if ! command -v wget &> /dev/null; then
    printf "[${red}${icon_ko}${nocolor}] Sorry, but ${green}wget${nocolor} is required. Install it with apt install wget.\n"
    exit 1;
  fi
  printf "[${yellow}${icon_wait}${nocolor}] downloading gif from url...\n"
  wget -O "${filename}" "${GIF}" >/dev/null 2>&1
  printf "[${green}${icon_ok}${nocolor}] Gif downloaded.\n"
  echo ""
  GIF="${filename}"
fi
if [ ! -f "$GIF" ]; then
  printf "[${red}${icon_ko}${nocolor}] Gif file not found.\n"
  exit 1
fi

# Check if input is gif
if [[ $(file "$GIF") != *GIF* ]]; then
  printf "[${red}${icon_ko}${nocolor}] Input file '$GIF' is not a gif.\n"
  exit 1
fi

# convert gif to mp4
printf "[${yellow}${icon_wait}${nocolor}] converting gif to mp4...\n"
ffmpeg -i "${GIF}" \
       -filter_complex "loop=2:32767:0,scale=trunc(iw/2)*2:trunc(ih/2)*2" \
       -f mp4 \
       -y \
       -preset slow \
       -pix_fmt yuv420p \
       "${GIF}.mp4" >/dev/null 2>&1
printf "[${green}${icon_ok}${nocolor}] Mp4 saved.\n"
echo ""

# convert mp4 to webm
printf "[${yellow}${icon_wait}${nocolor}] converting mp4 to webm...\n"
ffmpeg -i "${GIF}.mp4" -vcodec libvpx -acodec libvorbis "$GIF.webm" >/dev/null 2>&1
printf "[${green}${icon_ok}${nocolor}] Webm saved.\n"
echo ""

# convert mp4 to ogv
printf "[${yellow}${icon_wait}${nocolor}] converting mp4 to ogv...\n"
ffmpeg -i "$GIF.mp4" -vcodec libtheora -q:v 2 "$GIF.ogv" >/dev/null 2>&1
printf "[${green}${icon_ok}${nocolor}] Ogv saved.\n"
echo ""

# end
printf "\n\n ${icon_rocket} That's all!\n"
exit 1
