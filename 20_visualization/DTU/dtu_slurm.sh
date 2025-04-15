#!/bin/bash

#SBATCH --job-name=DTU
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00 #amount of time for the whole job
#SBATCH --mem=100G #amount of memory for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load gcc/11.4.0 openmpi/4.1.4 R/4.3.1

Rscript /project/sheynkman/projects/Mohi_MDS_LRP/20_visualization/DTU/DTU.R