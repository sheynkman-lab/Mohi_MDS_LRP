#!/bin/bash

#SBATCH --job-name=07_cds_gtf
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

source $(conda info --base)/etc/profile.d/conda.sh

#activate conda env

conda activate reference_tab

# WT
# Command to open the container & run script

apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
    python 00_scripts/07_make_pacbio_cds_gtf.py \
    --sample_gtf 02_sqanti/isoquant/WT_isoquant_corrected.gtf \
    --agg_orfs 06_refine_orf_database/WT/WT_30_orf_refined.tsv \
    --refined_orfs 05_orf_calling/WT/WT_best_ORF.tsv \
    --pb_gene 04_transcriptome_summary/WT/pb_gene.tsv \
    --output_cds 07_make_cds_gtf/WT/WT_cds.gtf
"

# Q157R
# Command to open the container & run script

apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
    python 00_scripts/07_make_pacbio_cds_gtf.py \
    --sample_gtf 02_sqanti/isoquant/Q157R_isoquant_corrected.gtf \
    --agg_orfs 06_refine_orf_database/Q157R/Q157R_30_orf_refined.tsv \
    --refined_orfs 05_orf_calling/Q157R/Q157R_best_ORF.tsv \
    --pb_gene 04_transcriptome_summary/Q157R/pb_gene.tsv \
    --output_cds 07_make_cds_gtf/Q157R/Q157R_cds.gtf
"

exit
conda deactivate
