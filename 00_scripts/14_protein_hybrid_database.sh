#!/bin/bash

#SBATCH --job-name=make_hybrid_database
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
python ./00_scripts/14_make_hybrid_database.py \
    --protein_classification 13_protein_filter/WT.classification_filtered.tsv \
    --gene_lens 01_reference_tables/gene_lens.tsv \
    --pb_fasta 13_protein_filter/WT.filtered_protein.fasta \
    --gc_fasta 02_make_gencode_database/gencode_clusters.fasta \
    --refined_info 12_protein_gene_rename/WT_orf_refined_gene_update.tsv \
    --pb_cds_gtf 13_protein_filter/WT_with_cds_filtered.gtf \
    --name 14_protein_hybrid_database/WT

# Q157R
python ./00_scripts/14_make_hybrid_database.py \
    --protein_classification 13_protein_filter/Q157R.classification_filtered.tsv \
    --gene_lens 01_reference_tables/gene_lens.tsv \
    --pb_fasta 13_protein_filter/Q157R.filtered_protein.fasta \
    --gc_fasta 02_make_gencode_database/gencode_clusters.fasta \
    --refined_info 12_protein_gene_rename/Q157R_orf_refined_gene_update.tsv \
    --pb_cds_gtf 13_protein_filter/Q157R_with_cds_filtered.gtf \
    --name 14_protein_hybrid_database/Q157R

conda deactivate
module purge