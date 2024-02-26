
## define variables
fasref="/n/mallet_lab/Lab/fseixas/1.projects/7.elepar_biogeography/mitobim/hmelros.fasta"
dir="/n/holyscratch01/mallet_lab/fseixas/6.dryas/0.1.fastq/"
reads=10000000

fasref="/n/holyscratch01/mallet_lab/fseixas/5.charithoniaRingSpecies/0.dataTreatment/results/mitogenomes/mitobim/reference/sara.fasta"
refnam="NC_026564"


export dir=$dir
export reads=$reads
export fasref=$fasref

## launch mitobim
cat identifiers.txt | xargs -n 1 sh -c '
    sbatch ~/code/heliconius_seixas/wgs_workflow/mitobim/mitobim.slurm \
    ${dir}$0.r1.fastq.gz \
    ${dir}$0.r2.fastq.gz \
    $0 \
    ${reads} \
    ${fasref} \
    hmelros
'

## Collect all mitogenomes 
rm mitobim.fasta; touch mitobim.fasta
for prefix in `cat identifiers.txt `; do 
    lfolder=$(ls -d $prefix.mitobim/iteration* | sort -Vr | head -n 1)
    printf "%s\n" ">$prefix" >> mitobim.fasta
    cat ${lfolder}/*_noIUPAC.fasta | grep -v "_bb_" >> mitobim.fasta
done

## Reverse complement sequences if necessary
perl /n/home12/fseixas/code/heliconius_seixas/wgs_workflow/mitogenomeAssembly/denovo/revcom.pl \
    mitobim.fasta \
    mitobim.rc.fasta

## Align with mafft
module load python/3.10.12-fasrc01
mamba activate mafft
mafft --maxiterate 1000 --thread 8 mitobim.rc.fasta > mitobim.mafft.fasta

