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
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

#activate conda env

conda activate reference_tab

# Wild type
# Command to open the container & run script

apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
    python ./00_scripts/07_make_pacbio_cds_gtf.py \
    --sample_gtf ./wild_type/02_sqanti/WT_corrected.gtf \
    --agg_orfs ./wild_type/06_refine_orf_database/WT_30_orf_refined.tsv \
    --refined_orfs ./wild_type/05_orf_calling/WT_best_ORF.tsv \
    --pb_gene ./wild_type/04_transcriptome_summary/pb_gene.tsv \
    --output_cds ./wild_type/07_make_cds_gtf/WT_cds.gtf
"

# Mutant
# Command to open the container & run script

apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
    python ./00_scripts/07_make_pacbio_cds_gtf.py \
    --sample_gtf ./mutant/02_sqanti/M_corrected.gtf \
    --agg_orfs ./mutant/06_refine_orf_database/M_30_orf_refined.tsv \
    --refined_orfs ./mutant/05_orf_calling/M_best_ORF.tsv \
    --pb_gene ./mutant/04_transcriptome_summary/pb_gene.tsv \
    --output_cds ./mutant/07_make_cds_gtf/M_cds.gtf
"

exit
conda deactivate
