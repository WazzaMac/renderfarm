#!/bin/bash

# fa.sh - Runs Python script to set critical Overwite and Placeholder properties render properties 

helpFunction()
{
   echo ""
   echo "Usage: $0 -i Input-file"
   echo -e "\t-i Name of animation file including the file extension"
   exit 1 # Exit script after printing help
}


while getopts "i:" opt
do
   case "$opt" in
       i) infile="$OPTARG" ;; 
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$infile" ]
then
   echo "Missing arguement or dash";
   helpFunction
fi

# Begin script in case all parameters are correct
echo "Render job with..."
echo "\tInput animation file: $infile"
echo "Initiate from..."
cd ~
pwd
start_time=$(date +"%c")
echo "Started at: $start_time"

# Blender background mode command line

exec blender -b ~/staging/$infile -P ~/render_bin/set_fa.py

