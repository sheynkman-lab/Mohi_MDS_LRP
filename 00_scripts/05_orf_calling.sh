#!/bin/bash

#SBATCH --job-name=orf-calling
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu
#SBATCH --mem=1000G # memory per node 

# Load modules
module load apptainer/1.3.4
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

#activate conda env

conda activate orf-calling

# Command to open the container & run script
apptainer exec /project/sheynkman/dockers/LRP/orf_calling_latest.sif /bin/bash -c "\
    python 00_scripts/05_orf_calling_multisample.py \
    --orf_coord 04_CPAT/MDS.ORF_prob.tsv \
    --orf_fasta 04_CPAT/MDS.ORF_seqs.fa \
    --gencode /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
    --sample_gtf 02_sqanti/MDS_corrected.gtf \
    --pb_gene 04_transcriptome_summary/pb_gene.tsv \
    --classification 02_sqanti/MDS_classification.txt \
    --sample_fasta 02_sqanti/MDS_corrected.fasta \
    --output_mutant 05_orf_calling/best_ORF_Q157R.tsv \
    --output_wt 05_orf_calling/best_ORF_WT.tsv
"

conda deactivate
module purge