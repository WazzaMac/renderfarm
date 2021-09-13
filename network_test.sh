
#!/bin/bash

# network_test.sh - Initiates a network background render session                

while getopts "i:o:" flag
do
    case "$flag" in
        i) infile="$OPTARG";;
        o) outfile="$OPTARG";;
    esac
done
echo "Input file: $infile";
echo "Output file: $outfile";

cd ~
pwd

exec blender -b ~/test_render/$infile \
             -o //test_images/$outfile -F PNG -x 1 \
             -a
