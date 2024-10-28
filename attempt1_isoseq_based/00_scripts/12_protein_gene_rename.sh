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
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

conda activate protein_class

# wild_type
python ./00_scripts/12_protein_gene_rename.py \
    --sample_gtf wild_type/07_make_cds_gtf/WT_cds.gtf \
    --sample_protein_fasta wild_type/06_refine_orf_database/WT_30_orf_refined.fasta \
    --sample_refined_info wild_type/06_refine_orf_database/WT_30_orf_refined.tsv \
    --pb_protein_genes wild_type/11_protein_classification/WT_genes.tsv \
    --name wild_type/12_protein_gene_rename/WT

# mutant
python ./00_scripts/12_protein_gene_rename.py \
    --sample_gtf mutant/07_make_cds_gtf/M_cds.gtf \
    --sample_protein_fasta mutant/06_refine_orf_database/M_30_orf_refined.fasta \
    --sample_refined_info mutant/06_refine_orf_database/M_30_orf_refined.tsv \
    --pb_protein_genes mutant/11_protein_classification/M_genes.tsv \
    --name mutant/12_protein_gene_rename/M

conda deactivate
module purge