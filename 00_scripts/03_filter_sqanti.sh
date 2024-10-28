#!/bin/bash

#SBATCH --job-name=filter_sqanti
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

conda activate sqanti_filter

# WT
python 00_scripts/03_filter_sqanti_mouse.py \
    --sqanti_classification 02_sqanti/mando/WT_mando_classification.txt \
    --sqanti_corrected_fasta 02_sqanti/mando/WT_mando_corrected.fasta \
    --sqanti_corrected_gtf 02_sqanti/mando/WT_mando_corrected.gtf \
    --protein_coding_genes 01_reference_tables/protein_coding_genes.txt \
    --ensg_gene 01_reference_tables/ensg_gene.tsv \
    --filter_protein_coding yes \
    --filter_intra_polyA yes \
    --filter_template_switching yes \
    --percent_A_downstream_threshold 95 \
    --structural_categories_level strict \
    --minimum_illumina_coverage 3 \
    --output_dir 03_filter_sqanti/WT

# Q157R
python 00_scripts/03_filter_sqanti_mouse.py \
    --sqanti_classification 02_sqanti/mando/Q157R_mando_classification.txt \
    --sqanti_corrected_fasta 02_sqanti/mando/Q157R_mando_corrected.fasta \
    --sqanti_corrected_gtf 02_sqanti/mando/Q157R_mando_corrected.gtf \
    --protein_coding_genes 01_reference_tables/protein_coding_genes.txt \
    --ensg_gene 01_reference_tables/ensg_gene.tsv \
    --filter_protein_coding yes \
    --filter_intra_polyA yes \
    --filter_template_switching yes \
    --percent_A_downstream_threshold 95 \
    --structural_categories_level strict \
    --minimum_illumina_coverage 3 \
    --output_dir 03_filter_sqanti/Q157R


conda deactivate
module purge