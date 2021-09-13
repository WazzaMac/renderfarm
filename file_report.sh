#!/bin/bash

# file_report.sh - displays file disposition in key directories

#   run using ./ not sh

# declare constants and arrays
# Note: Defined paths are used to prevent inadvertant access to system directories

declare -r unk="unknown";
declare -r ntf="not_found";
declare -r fil="files";
declare -r emp="empty";
declare -r rbn="/home/master/render_bin";
declare -r tmp="/home/master/tmp";
declare -r dbx="/home/master/drop_box";
declare -r stg="/home/master/staging";
declare -r prd="/home/master/prod/prod_render/"
declare -r pim="/home/master/prod/prod_render/prod_images";
declare -r com="/home/master/compositing";
declare -r pbx="/home/master/pickup_box";

declare -a img_seqs;

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


# function remove_hidden - removes all hiddent files and directories

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
  cd $rbn
}

# function check empty checks there are no files or directories present
check_empty() {
  if [ -n "$(find $1 -maxdepth 0 -empty 2> /dev/null)" ]; then  
    status=$emp;
  else
    status=$fil;
  fi 
}

report_files () {
  cd $1
  file_list=`ls *.* 2> /dev/null`
  file_count=0;
  for file in $file_list; do
    file_list+=("$file");
    file_count+=1;
  done
  if [ $file_count -gt 0 ]; then
    echo
    echo "Files in $1:"
    for file in $file_list; do
      echo $file
    done
  else
    echo
    echo "No files found"
  fi
  cd $rbn
}


###
# Display run notice
###

echo -e ${blue};
clear
echo
echo "     ***************"
echo "     * FILE REPORT *"
echo "     ***************"
echo 
echo "     Displays the disposition of files in render process directories."
echo "     and deletes all hidden files";
echo
echo -e ${clear};

contin 

cd ~/render_bin

###
# Report disposition of directories
###

# Report disposition of drop box

echo
echo "Reporting on Drop box ..........";

remove_hidden $dbx
report_files $dbx
contin
echo

# Report disposition of staging

echo
echo "Reporting on Staging ..........";

remove_hidden $stg
report_files $stg
contin
echo

# Report disposition of prod render

echo
echo "Reporting on Render ..........";

remove_hidden $prd
report_files $prd
contin
echo

# Report disposition of images

echo
echo "Reporting on Images ..........";

remove_hidden $pim
check_empty $pim
if [[ "$status" == "$fil" ]]; then
# compile list of image sequences
  last_seq=" ";
  last_frm=" ";
  cd $pim
  ls *.png | sort -t'-' -k1,1 -k2,2 | while read imgfile; do
    seq=$(echo $imgfile | cut -d'-' -f 1)
    frm=$(echo $imgfile | cut -d'-' -f 2)
    if [[ "$seq" == "$last_seq" ]]; then  
      last_frm=$frm
    else
      last_seq=$seq
      echo "$seq-####" >> /home/master/tmp/seqs.txt
    fi
  done
# Recover sequences from external file
  tmp_seqs="$tmp/seqs.txt"
  while read line; do
     img_seqs+="${line} ";
  done < $tmp_seqs
  rm "$tmp/seqs.txt";

# display pick list
  echo
  echo "Image sequences in $pim:"
  for file in $img_seqs; do
    echo $file
  done  
else
  echo
  echo "No files found"
fi
contin
echo

# Report disposition of compositing

echo
echo "Reporting on Compositing ..........";

remove_hidden $com
check_empty $com
if [[ "$status" == "$fil" ]]; then
# compile list of image sequences
  last_seq=" ";
  last_frm=" ";
  cd $com
  ls *.png | sort -t'-' -k1,1 -k2,2 | while read imgfile; do
    seq=$(echo $imgfile | cut -d'-' -f 1)
    frm=$(echo $imgfile | cut -d'-' -f 2)
    if [[ "$seq" == "$last_seq" ]]; then  
      last_frm=$frm
    else
      last_seq=$seq
      echo "$seq-####" >> /home/master/tmp/seqs.txt
    fi
  done
# Recover sequences from external file
  tmp_seqs="$tmp/seqs.txt"
  while read line; do
     img_seqs+="${line} ";
  done < $tmp_seqs
  rm "$tmp/seqs.txt";

# display pick list
  echo
  echo "Image sequences in $com:"
  for file in $img_seqs; do
    echo $file
  done  
else
  echo
  echo "No files found"
fi
contin
echo

# Report disposition of Pickupbox

echo
echo "Reporting on Pickup box ..........";

remove_hidden $pbx
report_files $pbx
contin
echo

echo
echo "All render process directories reported.";
echo
echo -e ${green}; 
echo "Exiting ..........";
echo -e ${clear};
sleep 3;

exit 0

