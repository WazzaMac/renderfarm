
#!/bin/bash

# local_test.sh - Initiates a local background render session                

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

exec blender -b ~/local_in/$infile -o //local_out/$outfile -a