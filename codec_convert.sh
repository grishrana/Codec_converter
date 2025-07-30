#!/usr/bin/bash

# 2>&1 redirects stderr(2) to stdout(1) we use & to specify that 1 is not a file.
# org_code=$(ffmpeg -i "$1" 2>&1 | grep "Stream #0")

# this function outputs the width and height of the media
# function check_res {
#   resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$1") # returns resolution(width, height) of a file
#   width=${resolution:0:4}
#   hieght=${resolution:5:4}
#   echo "${width} ${hieght}"
# }

# function to convert a file to prores_ks + pcm_s16le
function convert {
  filename=${1%.*}                 # extracting filename without extension
  new_file="changed/$filename.mov" # new file name + path to be saved

  # `<( .. )`  syntax is called process substitution. It runs the command inside the parentheses and gives you a "file-like" stream of the output.
  # `read` command takes input and splits it into variables. By default, it splits the input based on spaces or newlines.
  # IFS="," sets Internal Field Separator to a comma(,) which tell shell how to split the strings into separate variables when using commands like read
  resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$1") # returns resolution(width, height) of a file
  IFS="," read -r hieght widhth <<<"$resolution"

  if [ "$width" -eq "1080" ] || [ "$width" -eq "2160" ]; then
    # convert the codec with protrait scale
    echo "Width: $width Height: $hieght"
    echo "Converting to 1080:1920"
    # using gwak to format the output from ffmpeg
    ffmpeg -hide_banner -loglevel 0 -nostats -i "${1}" -vf "scale=1080:1920, fps=60" -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -c:a pcm_s16le -progress pipe:1 -y "${new_file}" | gawk -F "=" '
    /frame|fps|bitrate|speed|progress/ {
      stats[$1] = $2
      if ($1 == "progress"){
        printf "\r[ %s ]frame: %s fps: %s bitrate: %s speed: %s", $0, stats["frame"], stats["fps"], stats["bitrate"], stats["speed"]
        fflush()
      }
    }'
    prev_stat=$?

    if [ "$prev_stat" -eq 0 ]; then
      echo ""
      echo "--------------------------"
      echo "Successfully Converted: ${new_file}"
      echo "--------------------------"
    else
      echo ""
      echo -e "\e[31mAn error occured!\e[0m" >&2
    fi

  else
    # convert the codec with landscape scale
    # ffmpeg -hide_banner -loglevel 0 -i "${1}" -vf "scale=1920:1080, fps=60" -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -c:a pcm_s16le -progress pipe:1 -y "${new_file}" | gawk -v label="Video1" -f progress_parser.awk
    # using gwak to format the output from ffmpeg
    echo "Width: $width Height: $hieght"
    echo "Converting to 1920:1080"
    ffmpeg -hide_banner -loglevel 0 -i "${1}" -vf "scale=1920:1080, fps=60" -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -c:a pcm_s16le -progress pipe:1 -y "${new_file}" | gawk -F "=" '
    /frame|fps|bitrate|speed|progress/ {
      stats[$1] = $2
      if ($1 == "progress") {
        printf "\r[ %s ]frame: %s fps: %s bitrate: %s speed: %s", $0, stats["frame"], stats["fps"], stats["bitrate"], stats["speed"]
        fflush()
      }
    }'
    prev_stat=$?

    if [ "$prev_stat" -eq 0 ]; then
      echo ""
      echo "--------------------------"
      echo "Successfully Converted: ${new_file}"
      echo "--------------------------"
    else
      echo ""
      echo -e "\e[31mAn error occured!\e[0m" >&2
    fi

  fi

}

if [ -d "$1" ]; then

  # creating multiple threads for batch processing
  valid_ext=("mp4" "mov" "MOV")

  cd "$(pwd)/${1}"
  mkdir -p changed/
  for f in *; do
    if [ -f "$f" ]; then
      # Remove longest prefix ending with a . (i.e filename)
      ext="${f##*.}"
      if [[ " ${valid_ext[*]} " =~ "$ext" ]]; then
        echo "---------------"
        echo "$f is valid file."
        echo "---------------"
        echo ""
        convert $f
      fi
    fi
  done

elif [ -f "$1" ]; then
  mkdir -p changed/
  convert $1

else
  echo -e "\e[31mEnter a valid file or directory\e[0m"

fi
