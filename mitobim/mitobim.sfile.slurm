#!/bin/bash
#SBATCH -n 4                                    # Number of cores requested
#SBATCH -N 1                                    # Ensure that all cores are on one machine
#SBATCH -t 600                                  # Runtime in minutes
#SBATCH -p serial_requeue                       # Partition to submit to
#SBATCH --mem 24000                             # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o logs/mitobim%j.out                   # Standard out goes to this file
#SBATCH -e logs/mitobim%j.err                   # Standard err goes to this filehostname

## load modules
module load python/3.10.12-fasrc01
mamba activate mitobim
export LC_ALL=C


## User defined variables
FILE1=$1
FILE2=$2
INDIVIDUAL=$3;                              export INDIVIDUAL=$INDIVIDUAL
READS=$4;                                   export READS=$READS
REFSQ=$5;                                   export REFSQ=$REFSQ
REFNM=$6;                                   export REFNM=$REFNM
READM=$(($READS/1000000));                  export READM=$READM
prefix=`echo $INDIVIDUAL | sed 's,\.,_,g'`; export prefix=$prefix

## go to individual folder
mkdir $INDIVIDUAL.mitobim
cd $INDIVIDUAL.mitobim

# subsample reads [maintaining pair info]
seedRandom=`echo $RANDOM`; export seedRandom=$seedRandom
~/software/seqkit sample --two-pass --threads 4 -s $seedRandom -n ${READS} --out-file sub.$seedRandom.${READM}M.1.fastq ${FILE1} 


## mitobim
rm -r iteration*
LC_ALL=C MITObim.pl \
    -start 0 -end 40 \
    -sample ${prefix} \
    -readpool sub.$seedRandom.${READM}M.1.fastq \
    -ref ${REFNM} \
    --quick ${REFSQ} \
    --clean &> log
