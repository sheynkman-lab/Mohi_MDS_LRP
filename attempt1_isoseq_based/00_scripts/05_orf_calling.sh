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
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

#activate conda env

conda activate orf-calling

# Wild type
# Command to open the container & run script

apptainer exec /project/sheynkman/dockers/LRP/orf_calling_latest.sif /bin/bash -c "\
    python ./00_scripts/05_orf_calling.py \
    --orf_coord ./wild_type/04_CPAT/WT.ORF_prob.tsv \
    --orf_fasta ./wild_type/04_CPAT/WT.ORF_seqs.fa \
    --gencode /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
    --sample_gtf ./wild_type/02_sqanti/WT_corrected.gtf \
    --pb_gene ./wild_type/04_transcriptome_summary/pb_gene.tsv \
    --classification ./wild_type/02_sqanti/WT_classification.txt \
    --sample_fasta ./wild_type/02_sqanti/WT_corrected.fasta \
    --output ./wild_type/05_orf_calling/WT_best_ORF.tsv 
"

# Mutant
# Command to open the container & run script

apptainer exec /project/sheynkman/dockers/LRP/orf_calling_latest.sif /bin/bash -c "\
    python ./00_scripts/05_orf_calling.py \
    --orf_coord ./mutant/04_CPAT/M.ORF_prob.tsv \
    --orf_fasta ./mutant/04_CPAT/M.ORF_seqs.fa \
    --gencode /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
    --sample_gtf ./mutant/02_sqanti/M_corrected.gtf \
    --pb_gene ./mutant/04_transcriptome_summary/pb_gene.tsv \
    --classification ./mutant/02_sqanti/M_classification.txt \
    --sample_fasta ./mutant/02_sqanti/M_corrected.fasta \
    --output ./mutant/05_orf_calling/M_best_ORF.tsv
"

# exit container & deactivate condo env
exit
conda deactivate
