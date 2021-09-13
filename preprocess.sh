#!/bin/bash

# preprocess.sh - applies mandatory and options render settings 

#   run using ./ not sh

# declare constants
declare -r unk="unknown";
declare -r fil="files";
declare -r emp="empty";
declare -r ntf="not_found";
declare -r prd="/home/master/prod/prod_render";
declare -r trd="/home/master/test/test_render";
declare -r dbx="/home/master/drop_box";
declare -r stg="/home/master/staging";
declare -r org="Original";
declare -r hiq="High quality";
declare -r frt="Fast render";

# Declare arrays

declare -a blender_files;
declare -i file_count;
declare -x infile;
declare -x outfile;
declare -a options=("$org" "$hiq" "$frt")

# set colour variables
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
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

# function confirm prompts user to confirm input or selection
confirm() {
  echo
  read -p "Confirm (Y/y)? " -n 1 -r;
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    error_exit "No confirmation";
  fi  
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
    exit 0;
  fi  
}

# function check empty checks there are no files or directories present
check_empty() {
  if [ -n "$(find $1 -maxdepth 0 -empty 2> /dev/null)" ]; then  
    status=$emp;
  else
    status=$fil;
  fi 
}

# funtion menu displays a pick list of items in an array
menu() {
  select item ; do
  if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ]; then
    echo "$item selected";
    echo
    break;
  else
    echo "Select by a number from 1-$#";
  fi
done
}

# function move_file uses cp-rm - moves file (1) from source (2) to dest (3)
move_file() {
  if [ -f "$3/$1" ]; then
    error_exit "Duplicate file $infile";
  else
    if cp "$2/$1" "$3"; then
      rm "$2/$1";
    fi
  fi
}

remove_hidden() {
  cd $1;
  if [[ -n $(find . -mindepth 1 -name '.*') ]]; then
    echo "Hidden files found";
    find . -mindepth 1 -name '.*';
    echo
    echo "Removing hidden files";
    rm -rf .* 2> /dev/null;   
  else
    echo
    echo "No hidden files found";
  fi
  cd $2;
}

# function delete_bakfile - deleted blender .blend1 backup file
delete_1file() {
 bakfile="${1}1";
 if test -f "/home/master/staging/$bakfile"; then
   echo  "deleting $bakfile"
   rm "/home/master/staging/$bakfile";
 fi
}

###
# Display run notice
###

echo -e ${blue};
clear
echo
echo "     *****************"
echo "     * PREPROCESSING *"
echo "     *****************"
echo 
echo "     Applies frame allocation and quality control render settings."
echo
echo -e ${clear};

# Delete any spurious hidden files

echo
echo "Deleting spurious and hidden files ..........";
echo

remove_hidden $dbx $rbn;

remove_hidden $stg $rbn;
 

###
# Get Blender files from drop_box directory
###

cd $rbn;

status=$unk

check_empty $dbx

if [ "$status" = "$emp" ]; then
  error_exit "$dbx status is $status";
else
  echo "$dbx status is $status";
fi

cd $dbx

file_list=`ls *.blend`

cd $rbn

# Copy files from string to array

file_count=0;
for file in $file_list; do
  blender_files+=("$file");
  file_count+=1;
done

if [ "$file_count" -eq 0 ]; then
  error_exit "No Blender file to preprocess.";
fi

###
# Pick Blender file to be preprocessed
###
 
# Display available Blender files and confirm render

echo
echo "Blender files available for preprocessing:";
echo "------------------------------------------";
for file in "${blender_files[@]}"; do
  echo $file;
done

contin  

# Display a pick list of render files

echo
echo
echo "Select input file:";
echo "------------------";

menu "${blender_files[@]}"

infile=$item;

###
# Move selected file from drop_box to staging 
###

move_file $infile $dbx $stg

###
# Apply render settings
###

# Apply mandatory frame allocation settings

blender -b ~/staging/$infile -P ~/render_bin/set_fa.py

# delete any blender backup file

delete_1file $infile

echo
echo "$infile has Frame Allocation settings";

# Display a pick list of optional settings

echo
echo "Select optional settings:";
echo "-------------------------";

menu "${options[@]}"

set=$item;

# Apply selected settings

case $set in

  $org )
  echo
  echo "$infile has $org settings"
  ;;
  
  $hiq )
  temp_file=$infile
  blender -b ~/staging/$infile -P ~/render_bin/set_hiq_rp.py
  infile="h_$temp_file";
  if [ -f "$stg/$temp_file" ]; then
    rm "$stg/$temp_file";
    if [ -f "$stg/$temp_file"1 ]; then
       rm "$stg/$temp_file"1;
    fi
  fi
  echo
  echo "$infile has $hiq settings"
  ;;
  
  $frt )
  temp_file=$infile
  blender -b ~/staging/$infile -P ~/render_bin/set_frt_rp.py
  infile="f_$temp_file";
  if [ -f "$stg/$temp_file" ]; then
    rm "$stg/$temp_file";
    if [ -f "$stg/$temp_file"1 ]; then
      rm "$stg/$temp_file"1;
    fi
  fi
  echo
  echo "$infile has $frt settings"
  ;;
esac

delete_1file $infile

# Prompt for optimal CPU settings
 
echo
read -p "Apply optimal CPU settings (Y/y)? " -n 1 -r;
if [[ $REPLY =~ ^[Yy]$ ]]; then
  temp_file=$infile
  blender -b ~/staging/$infile -P ~/render_bin/set_cpu_rp.py
  infile="c_$temp_file";
  if [ -f "$stg/$temp_file" ]; then
    rm "$stg/$temp_file";
    if [ -f "$stg/$temp_file"1 ]; then
      rm "$stg/$temp_file"1;
    fi
  fi
  echo
  echo "$infile has optimal CPU settings"
fi 

delete_1file $infile

echo
echo "$infile is ready for rendering";
echo
echo -e ${green};
echo "Exiting ..........";
echo -e ${clear};
sleep 3;

exit 0;
 




