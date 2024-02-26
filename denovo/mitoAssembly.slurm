#!/bin/bash   
#SBATCH -n 8                                 # Number of cores requested
#SBATCH -N 1                                 # Ensure that all cores are on one machine
#SBATCH -t 300                               # Runtime in minutes
#SBATCH -p serial_requeue,shared             # Partition to submit to
#SBATCH --mem-per-cpu=3000                   # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o mafft_%j.out                       # Standard out goes to this file
#SBATCH -e mafft_%j.err                       # Standard err goes to this filehostname

## USAGE: bash mitoAssembly.slurm [reads_1.fastq.gz] [reads_2.fastq.gz] [individual name] [number of reads for assembly] [min_kmer_coverage] 
## recommendations: I generaly use 10'000'000 reads and a min_kmer_coverage of 10. If it doesn't work for you try adjusting these parameters.


#/ User defined variables
FILE1=$1
FILE2=$2
INDIVIDUAL=$3; export INDIVIDUAL=$INDIVIDUAL
READS=$4;      export READS=$READS
KMCOV=$5;      export KMCOV=$KMCOV
READM=$(($READS/1000000))
export READM=$READM


#/ load modules and start mamba env
module load python/3.10.9-fasrc01
mamba activate abyss-env

## go to individual folder
mkdir $INDIVIDUAL.mitoAssembly
cd $INDIVIDUAL.mitoAssembly

## subsample reads [maintaining pair info]
seedRandom=`echo $RANDOM`; export seedRandom=$seedRandom
seqkit sample --two-pass --threads 8 -s $seedRandom -n ${READS} --out-file sub.$seedRandom.${READM}M.1.fastq ${FILE1} 
seqkit sample --two-pass --threads 8 -s $seedRandom -n ${READS} --out-file sub.$seedRandom.${READM}M.2.fastq ${FILE2} 

## assemble reads
for k in `seq 64 16 96`; do
    mkdir ${seedRandom}.2x${READM}M.k${k}.kc${KMCOV}
    # abyss
    abyss-pe \
        -C ${seedRandom}.2x${READM}M.k${k}.kc${KMCOV} \
        name=${INDIVIDUAL}.2x${READM}M.k${k}.kc${KMCOV} \
        np=8 \
        k=${k} \
        kc=${KMCOV} \
        v=-v \
        B=8G \
        in='../sub.${seedRandom}.${READM}M.1.fastq ../sub.${seedRandom}.${READM}M.2.fastq'
done

## retrieve large unitigs [likely mtDNA]
# this size is based on Heliconius mtDNA (should in general work for many other organisms)
awk '{if (length($1) > 15000) print }' *unitigs.fa
awk '{if (length($1) > 15000) print }' *scaffolds.fa


