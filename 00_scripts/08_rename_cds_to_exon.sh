#!/bin/bash

#SBATCH --job-name=08_rename_cds_to_exon
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

# set working directory 
cd /project/sheynkman/projects/mohi_MDS

module load apptainer/1.2.2
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load bioconda/py3.10

conda activate reference_tab

# Wild type
apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
  python ./00_scripts/08_rename_cds_to_exon.py \
  --sample_gtf wild_type/07_make_cds_gtf/WT_cds.gtf \
  --sample_name wild_type/08_rename_cds_to_exon/WT \
  --reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
  --reference_name wild_type/08_rename_cds_to_exon/gencode
"

# Mutant
apptainer exec /project/sheynkman/dockers/LRP/pb-cds-gtf_latest.sif /bin/bash -c " \
  python ./00_scripts/08_rename_cds_to_exon.py \
  --sample_gtf mutant/07_make_cds_gtf/M_cds.gtf \
  --sample_name mutant/08_rename_cds_to_exon/M \
  --reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
  --reference_name mutant/08_rename_cds_to_exon/gencode
"

conda deactivate 
