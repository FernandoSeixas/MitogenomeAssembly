#!/bin/bash   
#SBATCH -n 8                                 # Number of cores requested
#SBATCH -N 1                                 # Ensure that all cores are on one machine
#SBATCH -t 300                               # Runtime in minutes
#SBATCH -p serial_requeue,shared             # Partition to submit to
#SBATCH --mem-per-cpu=3000                   # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o mafft_%j.out                       # Standard out goes to this file
#SBATCH -e mafft_%j.err                       # Standard err goes to this filehostname


module load python/3.10.12-fasrc01
mamba activate mafft

prefix=$1

mafft --maxiterate 1000 --thread 8 ${prefix}.mars.fasta > ${prefix}.mafft.fasta
