#!/bin/bash

#SBATCH --job-name=raname_transcripts # Job name
#SBATCH --cpus-per-task=10 # number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=72:00:00 # amount of time for the whole job
#SBATCH --partition=standard # the queue/partition to run on
#SBATCH --account=sheynkman_lab_paid
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu
#SBATCH --mem=1000G # memory per node 

module load isoseqenv/py3.7
module load apptainer/1.2.2
module load gcc/11.4.0
module load bedops/2.4.41
module load mamba/22.11.1-4
module load nseg/1.0.0
module load bioconda/py3.10
module load anaconda/2023.07-py3.11
module load openmpi/4.1.4
module load python/3.11.4

conda activate reference_tab


python 00_scripts/01.7_rename_transcripts.py \
--sample1_fasta mutant/01_isoseq/06_collapse/M.merged.collapsed.fasta \
--sample2_fasta wild_type/01_isoseq/06_collapse/WT.merged.collapsed.fasta \
--sample2_gff wild_type/01_isoseq/06_collapse/M.merged.collapsed.gff \
--sample2_abundance wild_type/01_isoseq/06_collapse/M.merged.collapsed.abundance.tsv \
--sample1_out mutant/01_isoseq/07_rename \
--sample2_out wild_type/01_isoseq/07_rename

conda deactivate
