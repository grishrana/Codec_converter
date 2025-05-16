#!/usr/bin/bash

# 2>&1 redirects stderr(2) to stdout(1) we use & to specify that 1 is not a file.
# org_code=$(ffmpeg -i "$1" 2>&1 | grep "Stream #0")

# this function outputs the width and height of the media
function check_res {
  resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$1") # returns resolution(width, height) of a file
  width=${resolution:0:4}
  hieght=${resolution:5:4}
  echo "${width} ${hieght}"
}

# function to convert a file to prores_ks + pcm_s16le
function convert {
  filename=${1%.*}                 # extracting filename without extension
  new_file="changed/$filename.mov" # new file name + path to be saved

  # `<( .. )`  syntax is called process substitution. It runs the command inside the parentheses and gives you a "file-like" stream of the output.
  # `read` command takes input and splits it into variables. By default, it splits the input based on spaces or newlines.
  read -r width hieght < <(check_res "$1")

  if [ "$width" -eq 1080 ] || [ "$width" -eq 3840 ]; then
    # convert the codec with protrait scale
    ffmpeg -i "${1}" -vf "scale=1080:1920, fps=60" -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -c:a pcm_s16le "${new_file}"
  else
    # convert the codec with landscape scale
    ffmpeg -i "${1}" -vf "scale=1920:1080, fps=60" -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -c:a pcm_s16le "${new_file}"
    echo "--------------------------"
    echo "Successfully Converted: ${new_file}"
    echo "--------------------------"
  fi

}

if [ -d "$1" ]; then
  cd "$(pwd)/${1}"
  mkdir -p changed/
  for f in *.mp4; do
    convert $f
  done
elif [ -f "$1" ]; then
  mkdir -p changed/
  convert $1

else
  echo "Enter a valid file or directory"

fi
