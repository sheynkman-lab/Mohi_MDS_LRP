#!/bin/bash

#SBATCH --job-name=transcriptome_summary
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load gcc/11.4.0 openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

conda activate CDS_org

# Wild Type
gtfToGenePred 07_make_cds_gtf/WT_cds.gtf 17_track_visualization/WT.genePred
genePredToBed 17_track_visualization/WT.genePred 17_track_visualization/WT.bed12

python 00_scripts/17_rgb_by_cpm_to_bed.py --input_bed 17_track_visualization/WT.bed12 --day WT --output_file 17_track_visualization/rgb/wiltype.bed12

# Q157R
gtfToGenePred 07_make_cds_gtf/Q157R_cds.gtf 17_track_visualization/Q157R.genePred
genePredToBed 17_track_visualization/Q157R.genePred 17_track_visualization/Q157R.bed12

python 00_scripts/17_rgb_by_cpm_to_bed.py --input_bed 17_track_visualization/Q157R.bed12 --day Q157R --output_file 17_track_visualization/rgb/Q157R_mutation.bed12