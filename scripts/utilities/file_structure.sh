#!/bin/bash

# Author: Jake Jackson

#Description: This is a simple script to organise the run information file structure
#Examples is only used whist I'm building usecase library

while getopts ":j:o:" i; do
  case $i in
    j) name="$OPTARG" #Used j for now n already taken in runscript
    ;;
    o) output_dir="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

AF_UNMASKED_DIR="/projects/ilfgrid/apps/AF_unmasked"
EXAMPLES="$AF_UNMASKED_DIR/examples" 

# Set up file structure
if [[ "$name" == "" ]] ; then
    echo "name not set"
else 
    echo "building run file structure"
    mkdir -p $EXAMPLES/$name/template_data
    #If the user does not specify output 
    if [[ "$output_dir" == "" ]] ; then #
        echo "setting output directory in folder"
        output_dir=$EXAMPLES/$name/output
    fi
    mkdir -p $EXAMPLES/msas
fi
mkdir -p $output_dir
