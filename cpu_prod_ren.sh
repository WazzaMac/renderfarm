#!/bin/bash

# cpu_prod_ren.sh - Initiates a production background render using cpu cores

helpFunction()
{
   echo ""
   echo "Usage: $0 -i Input-file -o Output-file"
   echo "\t-i Name of animation file including the file extension"
   echo "\t-o Name of output image sequence with optional # spec"
   exit 1 # Exit script after printing help
}


while getopts "i:o:" opt
do
   case "$opt" in
       i) infile="$OPTARG" ;;
       o) outfile="$OPTARG" ;; 
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$infile" ] || [ -z "$outfile" ]
then
   echo "Missing arguement or dash";
   helpFunction
fi

# Begin script in case all parameters are correct
echo "Render job with..."
echo "\tInput animation file: $infile"
echo "\tOutput image sequence: $outfile"
echo "Initiate from..."
cd ~
pwd
start_time=$(date +"%c")
echo "Started at: $start_time"

# Blender background mode command line

exec blender -b ~/prod_render/$infile \
             -o //prod_images/$outfile -F PNG -x 1 \
             -P alloc_cpu_rt.py \
             -a

