#!/bin/bash   
#SBATCH -n 16                                # Number of cores requested
#SBATCH -N 1                                 # Ensure that all cores are on one machine
#SBATCH -t 600                               # Runtime in minutes
#SBATCH -p serial_requeue,shared             # Partition to submit to
#SBATCH --mem-per-cpu=4000                   # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o mars_%j.out                       # Standard out goes to this file
#SBATCH -e mars_%j.err                       # Standard err goes to this filehostname



## Arguments
input=$1
output=$2

## MARS - left align sequences
~/software/MARS/mars \
    -a DNA \
    -i $input \
    -o $output \
    -a DNA \
    --method 1 \
    -T 16