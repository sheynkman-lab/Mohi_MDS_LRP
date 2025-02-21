#!/bin/bash

#SBATCH --job-name=rename_cds_to_exon
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
module load apptainer/1.3.4
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

conda activate reference_tab

apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
  python 00_scripts/08_rename_cds_to_exon_multi.py \
  --sample1_gtf 07_make_cds_gtf/WT_cds.gtf \
  --sample1_name 08_rename_cds_to_exon/WT \
  --sample2_gtf 07_make_cds_gtf/Q157R_cds.gtf \
  --sample2_name 08_rename_cds_to_exon/Q157R \
  --reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
  --reference_name 08_rename_cds_to_exon/gencode \
  --num_cores 8 
"

conda deactivate 
module purge