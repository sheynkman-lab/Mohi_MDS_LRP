#!/bin/bash

#SBATCH --constraint=afton
#SBATCH --job-name=isoseq3-afton
#SBATCH --cpus-per-task=10 # number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=34:00:00 # amount of time for the whole job
#SBATCH --partition=standard # the queue/partition to run on
#SBATCH --account=sheynkman_lab_paid
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu
#SBATCH --mem=1000G # memory per node 

# Load necessary modules (if needed)
module purge 

module load isoseqenv/py3.7
module load apptainer/1.2.2
module load gcc/11.4.0
module load bedops/2.4.41
module load mamba/22.11.1-4
module load nseg/1.0.0
module load bioconda/py3.10
module load anaconda/2023.07-py3.11
module load smrtlink/12.0.0.177059


# Change to the working directory
cd /project/sheynkman/projects/mohi_MDS

conda activate isoseq_env

# Wild type
# Merge SMRT cells
ls ./00_input_data/wild_type/*.flnc.bam > ./01_isoseq/wild_type_flnc.fofn

# Cluster reads
isoseq3 cluster ./00_input_data/flnc/wild_type_flnc.fofn ./wild_type/01_isoseq/04_cluster/WT.merged.clustered.bam --verbose --use-qvs

# Align reads to the genome 
pbmm2 align /project/sheynkman/external_data/GENCODE_M35/GRCm39.primary_assembly.genome.fa ./wild_type/01_isoseq/04_cluster/WT.merged.clustered.hq.bam ./01_isoseq/05_align/WT.merged.aligned.bam --preset ISOSEQ --sort -j 40 --log-level INFO

# Collapse redundant reads
isoseq3 collapse ./wild_type/01_isoseq/05_align/WT.merged.aligned.bam ./wild_type/01_isoseq/06_collapse/WT.merged.collapsed.gff

# Collapse redundant reads
isoseq3 collapse ./disease/01_isoseq/05_align/D.merged.aligned.bam ./disease/01_isoseq/06_collapse/D.merged.collapsed.gff

# Mutant
# Merge SMRT cells
ls ./00_input_data/mutant/*.flnc.bam > ./01_isoseq/mutant_flnc.fofn
isoseq3 cluster ./00_input_data/flnc/mutant_flnc.fofn ./mutant/01_isoseq/04_cluster/M.merged.clustered.bam --verbose --use-qvs

# Align reads to the genome
pbmm2 align /project/sheynkman/external_data/GENCODE_M35/GRCm39.primary_assembly.genome.fa ./mutant/01_isoseq/04_cluster/M.merged.clustered.hq.bam ./01_isoseq/05_align/M.merged.aligned.bam --preset ISOSEQ --sort -j 40 --log-level INFO

# Collapse redundant reads
isoseq3 collapse ./mutant/01_isoseq/05_align/M.merged.aligned.bam ./mutant/01_isoseq/06_collapse/M.merged.collapsed.gff

conda deactivate
