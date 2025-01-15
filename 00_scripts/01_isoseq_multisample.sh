#!/bin/bash

#SBATCH --job-name=isoseq3
#SBATCH --cpus-per-task=10          
#SBATCH --nodes=1                   
#SBATCH --ntasks-per-node=1         
#SBATCH --mem=1460G           
#SBATCH --time=160:00:00             
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load isoseqenv/py3.7
module load gcc/11.4.0
module load bedops/2.4.41
module load nseg/1.0.0
module load bioconda/py3.10
module load smrtlink/13.1.0.221970
module load miniforge/24.3.0-py3.11

pbmerge -o 01_isoseq/merge/merged.flnc.bam /project/sheynkman/raw_data/PacBio/mohi_data/X504_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9850-001_1-1-C01_IsoSeqX_bc06.flnc.bam /project/sheynkman/raw_data/PacBio/mohi_data/A258_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9851-001_1-1-C01_IsoSeqX_bc07.flnc.bam /project/sheynkman/raw_data/PacBio/mohi_data/A309_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9852-001_1-1-C01_IsoSeqX_bc08.flnc.bam /project/sheynkman/raw_data/PacBio/mohi_data/V335_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9847-001_1-1-C01_IsoSeqX_bc03.flnc.bam /project/sheynkman/raw_data/PacBio/mohi_data/V334_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9848-001_1-1-C01_IsoSeqX_bc04.flnc.bam /project/sheynkman/raw_data/PacBio/mohi_data/A310_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9849-001_1-1-C01_IsoSeqX_bc05.flnc.bam

# Cluster reads
isoseq cluster2 01_isoseq/merge/merged.flnc.bam 01_isoseq/cluster/merged.clustered.bam --verbose --use-qvs

# Align reads to the genome 
pbmm2 align 00_input_data/GRCh38.primary_assembly.genome.fa 01_isoseq/cluster/merged.clustered.hq.bam 01_isoseq/align/merged.aligned.bam --preset ISOSEQ --sort -j 40 --log-level INFO

# Collapse redundant reads
isoseq collapse --do-not-collapse-extra-5exons 01_isoseq/align/merged.aligned.bam 01_isoseq/merge/merged.flnc.bam 01_isoseq/collapse/merged.collapsed.gff

conda deactivate
module purge