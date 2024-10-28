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
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

conda activate sqanti_filter

# Wild type
python ./00_scripts/03_filter_sqanti_mouse.py \
    --sqanti_classification wild_type/02_sqanti/WT_classification.txt \
    --sqanti_corrected_fasta wild_type/02_sqanti/WT_corrected.fasta \
    --sqanti_corrected_gtf wild_type/02_sqanti/WT_corrected.gtf \
    --protein_coding_genes 01_reference_tables/protein_coding_genes.txt \
    --ensg_gene 01_reference_tables/ensg_gene.tsv \
    --filter_protein_coding yes \
    --filter_intra_polyA yes \
    --filter_template_switching yes \
    --percent_A_downstream_threshold 95 \
    --structural_categories_level strict \
    --minimum_illumina_coverage 3 \
    --output_dir wild_type/03_filter_sqanti

python ./00_scripts/03_collapse_isoforms.py \
    --name WT \
    --sqanti_gtf wild_type/03_filter_sqanti/filtered_WT_corrected.gtf \
    --sqanti_fasta wild_type/03_filter_sqanti/filtered_WT_corrected.fasta \
    --output_folder wild_type/03_filter_sqanti

python ./00_scripts/03_collapse_classification.py \
    --name WT \
    --collapsed_fasta wild_type/03_filter_sqanti/WT_corrected.5degfilter.fasta \
    --classification wild_type/03_filter_sqanti/filtered_WT_classification.tsv \
    --output_folder wild_type/03_filter_sqanti

# Mutant
python ./00_scripts/03_filter_sqanti_mouse.py \
    --sqanti_classification mutant/02_sqanti/M_classification.txt \
    --sqanti_corrected_fasta mutant/02_sqanti/M_corrected.fasta \
    --sqanti_corrected_gtf mutant/02_sqanti/M_corrected.gtf \
    --protein_coding_genes 01_reference_tables/protein_coding_genes.txt \
    --ensg_gene 01_reference_tables/ensg_gene.tsv \
    --filter_protein_coding yes \
    --filter_intra_polyA yes \
    --filter_template_switching yes \
    --percent_A_downstream_threshold 95 \
    --structural_categories_level strict \
    --minimum_illumina_coverage 3 \
    --output_dir mutant/03_filter_sqanti

python ./00_scripts/03_collapse_isoforms.py \
    --name M \
    --sqanti_gtf mutant/03_filter_sqanti/filtered_M_corrected.gtf \
    --sqanti_fasta mutant/03_filter_sqanti/filtered_M_corrected.fasta \
    --output_folder mutant/03_filter_sqanti

python ./00_scripts/03_collapse_classification.py \
    --name M \
    --collapsed_fasta mutant/03_filter_sqanti/M_corrected.5degfilter.fasta \
    --classification mutant/03_filter_sqanti/filtered_M_classification.tsv \
    --output_folder mutant/03_filter_sqanti

conda deactivate
module purge