#!/bin/bash

#SBATCH --job-name=mando
#SBATCH --cpus-per-task=30 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=24G 
#SBATCH --time=72:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

cd /project/sheynkman/projects/Mohi_MDS_LRP

module load gcc/11.4.0 openmpi/4.1.4 python/3.11.4 miniforge/24.3.0-py3.11

source $(conda info --base)/etc/profile.d/conda.sh
conda activate mando

python3 /project/sheynkman/programs/Mandalorion/Mando.py \
    -g /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
    -G /project/sheynkman/external_data/GENCODE_M35/GRCm39.primary_assembly.genome.fa \
    -f 00_input_data/all_fastq.fofn \
    -p 01_mandalorion \
    -M APDFQ

