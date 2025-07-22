#!/bin/bash   
#SBATCH -n 8                                 # Number of cores requested
#SBATCH -N 1                                 # Ensure that all cores are on one machine
#SBATCH -t 300                               # Runtime in minutes
#SBATCH -p serial_requeue,shared             # Partition to submit to
#SBATCH --mem-per-cpu=3000                   # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o mafft_%j.out                       # Standard out goes to this file
#SBATCH -e mafft_%j.err                       # Standard err goes to this filehostname

## define variables
reads=10000000      ; export reads=$reads
mkcov=10            ; export mkcov=$mkcov


## subset reads and launch ABySS
cat identifiers.txt | xargs -n 1 sh -c '
    sbatch mitoAssembly.slurm \
    $0.r1.fastq.gz \
    $0.r2.fastq.gz \
    $0 \
    ${reads} \
    {mkcov}
'

## Collect all mitogenomes 
rm mitoassembly.fasta
touch mitoassembly.fasta
# for prefix in `cat identifiers.txt `; do 
#     lfolder=$(ls -d $prefix.mitobim/iteration* | sort -Vr | head -n 1)
#     printf "%s\n" ">$prefix" >> mitobim.fasta
#     cat ${lfolder}/*_noIUPAC.fasta | grep -v "_bb_" >> mitoassembly.fasta
# done

## Reverse complement sequences if necessary
perl revcom.pl \
    mitoassembly.fasta \
    mitoassembly.rc.fasta

## Left align sequences with MARS - so that all sequences star/end at the same position
mars -a DNA -i mitoassembly.rc.fasta -o mitoassembly.mars.fasta -a DNA --method 1 -T 16

## Align with mafft
mafft --maxiterate 1000 --thread 8 mitoassembly.mars.fasta > mitoassembly.mafft.fasta

