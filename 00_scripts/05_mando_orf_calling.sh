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

# Load modules
module load apptainer/1.2.2
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

#activate conda env

conda activate orf-calling

# WT
# Command to open the container & run script
apptainer exec /project/sheynkman/dockers/LRP/orf_calling_latest.sif /bin/bash -c "\
    python 00_scripts/05_mando_orf_calling.py \
    --orf_coord 04_CPAT/mando/WT.ORF_prob.tsv \
    --orf_fasta 04_CPAT/mando/WT.ORF_seqs.fa \
    --gencode /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
    --sample_gtf 02_sqanti/mando/WT_mando_corrected.gtf \
    --pb_gene 04_transcriptome_summary/mando/WT/pb_gene.tsv \
    --classification 02_sqanti/mando/WT_mando_classification.txt \
    --sample_fasta 02_sqanti/mando/WT_mando_corrected.fasta \
    --output 05_orf_calling/mando/WT/WT_best_ORF.tsv
"

# Q157R
# Command to open the container & run script
apptainer exec /project/sheynkman/dockers/LRP/orf_calling_latest.sif /bin/bash -c "\
    python 00_scripts/05_orf_calling.py \
    --orf_coord 04_CPAT/mando/Q157R.ORF_prob.tsv \
    --orf_fasta 04_CPAT/mando/Q157R.ORF_seqs.fa \
    --gencode /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
    --sample_gtf 02_sqanti/mando/Q157R_mando_corrected.gtf \
    --pb_gene 04_transcriptome_summarymando/Q157R/pb_gene.tsv \
    --classification 02_sqanti/mando/Q157R_mando_classification.txt \
    --sample_fasta 02_sqanti/mando/Q157R_mando_corrected.fasta \
    --output 05_orf_calling/mando/Q157R/Q157R_best_ORF.tsv
"

conda deactivate