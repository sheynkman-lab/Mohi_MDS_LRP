#!/bin/bash

#SBATCH --job-name=refine_orf_database
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load apptainer/1.2.2
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

source $(conda info --base)/etc/profile.d/conda.sh

conda activate refined-database-generation

# WT
python 00_scripts/06_refine_orf_database.py \
--name 06_refine_orf_database/WT/WT_30 \
--orfs 05_orf_calling/WT/WT_best_ORF.tsv \
--pb_fasta 02_sqanti/isoquant/WT_isoquant_corrected.fasta \
--coding_score_cutoff 0.3 

# Q157R
python 00_scripts/06_refine_orf_database.py \
--name 06_refine_orf_database/Q157R/Q157R_30 \
--orfs 05_orf_calling/Q157R/Q157R_best_ORF.tsv \
--pb_fasta 02_sqanti/isoquant/Q157R_isoquant_corrected.fasta \
--coding_score_cutoff 0.3

conda deactivate 

