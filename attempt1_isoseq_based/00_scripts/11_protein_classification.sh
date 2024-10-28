#!/bin/bash

#SBATCH --job-name=protein_classification
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
module load anaconda/2023.07-py3.11

conda activate protein_class

# wild_type
python ./00_scripts/11_protein_classification_add_meta.py \
--protein_classification  wild_type/10_5p_utr/WT.sqanti_protein_classification_w_5utr_info.tsv \
--best_orf wild_type/05_orf_calling/WT_best_ORF.tsv \
--refined_meta wild_type/06_refine_orf_database/WT_30_orf_refined.tsv \
--ensg_gene ./01_reference_tables/ensg_gene.tsv \
--name WT \
--dest_dir wild_type/11_protein_classification/


python ./00_scripts/11_protein_classification.py \
--sqanti_protein wild_type/11_protein_classification/WT.protein_classification_w_meta.tsv \
--name WT \
--dest_dir wild_type/11_protein_classification/

# mutant
python ./00_scripts/11_protein_classification_add_meta.py \
--protein_classification  mutant/10_5p_utr/M.sqanti_protein_classification_w_5utr_info.tsv \
--best_orf mutant/05_orf_calling/M_best_ORF.tsv \
--refined_meta mutant/06_refine_orf_database/M_30_orf_refined.tsv \
--ensg_gene ./01_reference_tables/ensg_gene.tsv \
--name M \
--dest_dir mutant/11_protein_classification/

python ./00_scripts/11_protein_classification.py \
--sqanti_protein mutant/11_protein_classification/M.protein_classification_w_meta.tsv \
--name M \
--dest_dir mutant/11_protein_classification/

conda deactivate 
module purge