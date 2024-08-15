#!/bin/bash

#SBATCH --job-name=gencode_database
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module purge 
module load gcc/11.4.0
module load openmpi/4.1.4
module load python/3.11.4 
module load anaconda/2023.07-py3.11 
module load perl/5.36.0 
module load star/2.7.9a 
module load kallisto/0.48.0

conda activate make_database

python ./00_scripts/02_make_gencode_database.py \
--gencode_fasta /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.pc_translations.fa \
--protein_coding_genes ./01_reference_tables/protein_coding_genes.txt \
--output_fasta ./02_make_gencode_database/gencode_clusters.fasta \
--output_cluster ./02_make_gencode_database/gencode_isoname_clusters.tsv


conda deactivate