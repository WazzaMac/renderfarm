#!/bin/bash

# max_cpu.sh - initiates a cpu render on all available render hosts

#   run using ./ not sh

# Declare constants, variables and arrays

declare -r unk="unknown";
declare -r fil="files";
declare -r emp="empty";
declare -r ntf="not_found";
declare -r prd="/home/master/prod/prod_render";
declare -r stg="/home/master/staging";
declare -a blender_files;
declare -i file_count;
declare -x infile;
declare -x outfile;
declare -a render_hosts;
declare -a active_hosts;
declare -i active_count;


# Initialise array of all render host IP addresses

render_hosts[0]="192.168.0.201";
render_hosts[1]="192.168.0.202";
render_hosts[2]="192.168.0.203";
render_hosts[3]="192.168.0.204";
render_hosts[4]="192.168.0.205";
render_hosts[5]="192.168.0.206";
render_hosts[6]="192.168.0.207";

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
  cd $2
}

###
# Display run notice
###

echo -e ${blue};
clear
echo
echo "     **************"
echo "     * CPU RENDER *"
echo "     **************"
echo 
echo "     Renders the selected Blender file using all active hosts."
echo
echo -e ${clear};
contin

# Delete any spurious hidden files

echo
echo "Deleting spurious and hidden files ..........";
echo

remove_hidden $stg $rbn;

remove_hidden $prd $rbn;


echo
echo "Searching network for active hosts";
echo "-----------------------------------";

# Ping hosts and if active add to active hosts array
active_count=0
for ip in ${render_hosts[@]}; do
  echo
  echo $ip;
  echo "-----------------------------------";
  if ping -c 1 -W 1 $ip; then
    echo "$ip is alive";
    active_hosts[${#active_hosts[@]}]="${ip}";
    active_count+=1;
  else
    echo
    echo "$ip is down";
  fi
done
echo
if [ "$active_count" -eq 0 ]; then
  error_exit "No active render hosts.";
fi

# list active hosts

echo
echo "Active hosts:";
echo "-------------";

for val in ${active_hosts[@]}; do
  echo "$val ready to render";
done

confirm

###
# Get Blender files from staging directory
###

# check if staging directory is empty

check_empty $stg

if [ "$status" = "$emp" ]; then
  error_exit "$stg status is $status";
else
  echo "$stg status is $status";
fi

# Read all staged Blender files into a string

cd $stg

file_list=`ls *.blend 2> /dev/null`

cd $rnd

# Copy files from string to array

file_count=0;
for file in $file_list; do
  blender_files+=("$file");
  file_count+=1;
done

if [ "$file_count" -eq 0 ]; then
  error_exit "No Blender file to render.";
fi

###
# Pick Blender file to be rendered and get output image filespec
###
 
# Display available Blender files and confirm render

echo
echo "Blender files available for render:";
echo "-----------------------------------";
for file in "${blender_files[@]}"; do
  echo $file;
done

contin  

# Display a pick list of render files

#clear;
echo
echo "Select input file:";
echo "------------------";

menu "${blender_files[@]}"

infile=$item;

# Promt for output file

echo "Enter job number:";
echo "-----------------";
echo
echo "Job number is used as the output image file-spec."
echo
jobnum=""
while :
do
  echo
  read -p "Job number:" jobnum;
  if [ -z "$jobnum" ]; then
    error_exit "Image file not specified.";
  else
    if [[ $jobnum =~ "-" ]]  || [[ $jobnum =~ "#" ]] || [[ $jobnum =~ " " ]]; then
      echo "Job number can't have ' ','-' or '#'.  Reserved for file spec.";
    else
      break;
    fi
  fi
done

outfile="${jobnum}-####"

echo
echo "Input file is $infile";
echo
echo "Output file is $outfile";

confirm

# Copy infile to production render directory

if test -f "/home/master/prod/prod_render/$infile"; then
  error_exit "Duplicate $infile";
else
  cp ~/staging/"$infile" ~/prod/prod_render/;
  rm ~/staging/"$infile";
fi

###
# Get target render device type
###

render_device="cpu";

# set standard host user and bin directory

host_user="tracer";
bin_dir="/home/tracer/render_bin";

cd /home/master/render_bin

###
# Choose render script
###

#render_script="network_test.sh";
#render_script="prod_ren.sh";
render_script="cpu_prod_ren.sh";

# Set redirect outputs and remote host command

redirect_out="${render_device}_render.out"
redirect_err="${render_device}_render.err"
redirect="> ~/redirect_logs/$redirect_out 2> ~/redirect_logs/$redirect_err </dev/null &"
#render_command="sh $render_script -i $infile -o $outfile \
# > ~/redirect_logs/$redirect_out 2> ~/redirect_logs/$redirect_err </dev/null &"
render_command="sh ${render_script} -i ${infile} -o ${outfile} ${redirect}"

###
# Initiate render on all available render hosts
###

echo "Initiating $render_device remote render......................";
echo

for ip in ${active_hosts[@]}; do
  render_host="${host_user}@${ip}";
  echo
  echo "Starting  $render_host ..................";
  echo
  ssh $render_host << EOF
    cd /home/tracer/redirect_logs
    [[ -f $redirect_out ]] && rm $redirect_out
    [[ -f $redirect_err ]] && rm $redirect_err
    cd /home/tracer/render_bin  
    nohup $render_command
    disown -h
    exit  
EOF
done

echo
echo "Render job $jobnum initiated at " `date`;
echo
echo "Blender output is redirected to /home/tracer/redirect_logs/$redirect_out"
echo
echo -e ${green};
echo "Exiting ..........";
echo -e ${clear};
sleep 3;

exit 0;
 




