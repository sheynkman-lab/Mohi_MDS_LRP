#!/bin/bash

#SBATCH --job-name=SQANTI3
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
module load bioconda/py3.10
module load apptainer/1.2.2
module load anaconda/2023.07-py3.11
module load R/4.3.1 
module load perl/5.36.0 
module load star/2.7.9a 

conda activate sqanti_protein

export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2/cDNA_Cupcake/
export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2


# Wild type
python ./00_scripts/09_sqanti_protein.py \
wild_type/08_rename_cds_to_exon/WT.transcript_exons_only.gtf \
wild_type/08_rename_cds_to_exon/WT.cds_renamed_exon.gtf \
wild_type/05_orf_calling/WT_best_ORF.tsv \
wild_type/08_rename_cds_to_exon/gencode.transcript_exons_only.gtf \
wild_type/08_rename_cds_to_exon/gencode.cds_renamed_exon.gtf \
-d wild_type/09_sqanti_protein/ \
-p WT

# Mutant
python ./00_scripts/09_sqanti_protein.py \
mutant/08_rename_cds_to_exon/M.transcript_exons_only.gtf \
mutant/08_rename_cds_to_exon/M.cds_renamed_exon.gtf \
mutant/05_orf_calling/M_best_ORF.tsv \
mutant/08_rename_cds_to_exon/gencode.transcript_exons_only.gtf \
mutant/08_rename_cds_to_exon/gencode.cds_renamed_exon.gtf \
-d mutant/09_sqanti_protein/ \
-p M

conda deactivate