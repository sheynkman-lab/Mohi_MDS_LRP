#!/bin/bash

#SBATCH --job-name=SQANTI_protein
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load apptainer/1.3.4
module load miniforge/24.3.0-py3.11
module load R/4.3.1 
module load perl/5.36.0 
module load star/2.7.9a 

# be sure SQANTI3 utilities are in your 00_scripts folder...I need to figure out how to fix this.

conda activate sqanti_protein

export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2/cDNA_Cupcake/
export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2

# WT
python 00_scripts/09_sqanti_protein.py \
08_rename_cds_to_exon/WT.transcript_exons_only.gtf \
08_rename_cds_to_exon/WT.cds_renamed_exon.gtf \
05_orf_calling/MDS_best_ORF.tsv \
08_rename_cds_to_exon/gencode.transcript_exons_only.gtf \
08_rename_cds_to_exon/gencode.cds_renamed_exon.gtf \
-d 09_sqanti_protein/ \
-p WT

# Q157R
python 00_scripts/09_sqanti_protein.py \
08_rename_cds_to_exon/Q157R.transcript_exons_only.gtf \
08_rename_cds_to_exon/Q157R.cds_renamed_exon.gtf \
05_orf_calling/MDS_best_ORF.tsv \
08_rename_cds_to_exon/gencode.transcript_exons_only.gtf \
08_rename_cds_to_exon/gencode.cds_renamed_exon.gtf \
-d 09_sqanti_protein/ \
-p Q157R

conda deactivate
module purge