#!/bin/bash

# render_control.sh - main control of render process

#   run using ./ not sh

# declare constants, variables and arrays


declare -r rbn="/home/master/render_bin";
declare -r tmp="/home/master/tmp";

# Initialise variables
declare -a process_steps;
inf="Information";
fls="Files";
pre="Preprocess";
rnd="Render";
mvi="Move-Images";
afl="Archive-File";
aim="Archive-Images";

# set colour variables
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
purple="\033[0;35m"
clear="\033[0m"


# define user functions

# function error_exit checks return code and exits 
error_exit () {
  echo
  echo "$1"
  echo -e ${yellow};
  echo "Exiting ..........";
  echo -e ${clear};
  sleep 3;
  exit 1;
}

# function contin prompts user to continue to next
contin() {
  echo
  read -p "Continue (Y/y)? " -n 1 -r;
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo -e ${green};
    echo "Exiting ..........";
    echo -e ${clear};
    sleep 3;
    exit 0;
  fi  
}

# function info - displays infomation about each step

info() {
  clear
  echo -e ${purple};
  echo 
  echo "    Render Process Information";
  echo "    --------------------------";
  echo
  echo "    Control process menu options:"
  echo
  echo "    Files - reports on the files currently in the render farm directories"
  echo "          - removes hidden (.) files and directories during the report"
  echo
  echo "    Preprocess - selects a file from the dropbox directory"
  echo "               - applies render settings fequired for frame allocation"
  echo "               - optionally applies render settings fequired for quality control"
  echo "               - optionally applies render settings for optimal CPU usage"
  echo "               - moves the file to the staging directory"
  echo
  echo "    Render - selects a file from staging directory"
  echo "           - moves the file to the render directory"
  echo
  echo "    Move-Images - checks if the compositig directory is available"
  echo "                - selects an image sequence from the image directory"
  echo "                - moves all images in the sequence to the compositing directory"
  echo
  echo "    Archive-File - selects a file from the render directory"
  echo "                 - moves the file to ths for-archive directory"
  echo
  echo "    Archive-Images - checks if the compositing directory has an image sequence"
  echo "                   - compresses the image sequence into a tarball"
  echo "                   - moves the tarball to the for-archive directory"
  echo "                   - removes all files from the compositing directory"  
  echo 
  echo
  echo -e ${clear};
  contin
}


###
# Display run notice
###

clear
echo -e ${blue};
echo
echo "     ******************"
echo "     * RENDER CONTROL *"
echo "     ******************"
echo 
echo "     Main control for render process."
echo
echo
echo -e ${clear};

contin 

cd ~/render_bin;

# display menu of render process steps


title="Render Process Options:"
options=("$fls" "$pre" "$rnd" "$mvi" "$afl" "$aim" "$inf")

do_menu=0

while [ $do_menu = 0 ]; do
  clear
  echo 
  echo "$title"
  echo
  select opt in "${options[@]}" "Quit"; do
    case $opt in
      "$fls")
        ./file_report.sh
        echo
        break
        ;;
      "$pre")
        ./preprocess.sh
        echo
        break
        ;;
      "$rnd")
        ./max_cpu.sh
        echo
        break
        ;;
      "$mvi")
        ./move_images.sh
        echo
        break
        ;;
      "$afl")
        ./archive_render_file.sh
        echo
        break
        ;;
      "$aim")
        ./archive_images.sh
        echo
        break
        ;;
      "$inf")
        echo "$inf selected"
        info
        echo
        break
        ;;  
      Quit)
        do_menu=1
        break
        ;;
      *) 
        echo "No option $REPLY"
        ;;
    esac
  done
done

echo -e ${green};
echo "Exiting ..........";
echo -e ${clear};
sleep 3;

exit 0








