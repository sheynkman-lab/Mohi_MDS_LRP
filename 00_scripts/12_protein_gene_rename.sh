#!/bin/bash

#SBATCH --job-name=protein_gene_rename
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

source $(conda info --base)/etc/profile.d/conda.sh

conda activate protein_class

# WT
python ./00_scripts/12_protein_gene_rename.py \
    --sample_gtf 07_make_cds_gtf/WT_cds.gtf \
    --sample_protein_fasta 06_refine_orf_database/WT_30_orf_refined.fasta \
    --sample_refined_info 06_refine_orf_database/WT_30_orf_refined.tsv \
    --pb_protein_genes 11_protein_classification/WT_genes.tsv \
    --name 12_protein_gene_rename/WT

# Q157R
python ./00_scripts/12_protein_gene_rename.py \
    --sample_gtf 07_make_cds_gtf/Q157R_cds.gtf \
    --sample_protein_fasta 06_refine_orf_database/Q157R_30_orf_refined.fasta \
    --sample_refined_info 06_refine_orf_database/Q157R_30_orf_refined.tsv \
    --pb_protein_genes 11_protein_classification/Q157R_genes.tsv \
    --name 12_protein_gene_rename/Q157R

conda deactivate
module purge