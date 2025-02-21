#!/bin/bash

#SBATCH --job-name=5p_utr
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=4:00:00 #amount of time for the whole job
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

conda activate utr

python ./00_scripts/10_1_get_gc_exon_and_5utr_info.py \
--gencode_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--odir 10_5p_utr

# WT
python ./00_scripts/10_2_classify_5utr_status.py \
--gencode_exons_bed 10_5p_utr/gencode_exons_for_cds_containing_ensts.bed \
--gencode_exons_chain 10_5p_utr/gc_exon_chain_strings_for_cds_containing_transcripts.tsv \
--sample_cds_gtf 07_make_cds_gtf/WT_cds.gtf \
--odir 10_5p_utr 

python ./00_scripts/10_3_merge_5utr_info_to_pclass_table.py \
--name WT \
--utr_info 10_5p_utr/pb_5utr_categories.tsv \
--sqanti_protein_classification 09_sqanti_protein/WT.sqanti_protein_classification.tsv \
--odir 10_5p_utr

# Q157R
python ./00_scripts/10_2_classify_5utr_status.py \
--gencode_exons_bed 10_5p_utr/gencode_exons_for_cds_containing_ensts.bed \
--gencode_exons_chain 10_5p_utr/gc_exon_chain_strings_for_cds_containing_transcripts.tsv \
--sample_cds_gtf 07_make_cds_gtf/Q157R_cds.gtf \
--odir 10_5p_utr 

python ./00_scripts/10_3_merge_5utr_info_to_pclass_table.py \
--name Q157R \
--utr_info 10_5p_utr/pb_5utr_categories.tsv \
--sqanti_protein_classification 09_sqanti_protein/WT.sqanti_protein_classification.tsv \
--odir 10_5p_utr

conda deactivate
module purge