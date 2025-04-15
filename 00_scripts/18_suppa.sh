#!/bin/bash

#SBATCH --job-name=suppa
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
module load miniforge/24.3.0-py3.11
module load R/4.4.1

conda activate suppa
cd /project/sheynkman/projects/Mohi_MDS_LRP

#Generate splicing events. 
python /project/sheynkman/programs/SUPPA-2.4/suppa.py generateEvents -i 02_sqanti/MDS_corrected_PB_renamed.gtf -o 18_SUPPA/01_splice_events/all.events -e SE SS MX RI FL -f ioe

#Put all IOE events in the same file.
cd 18_SUPPA/01_splice_events

awk '
    FNR==1 && NR!=1 { while (/^<header>/) getline; }
    1 {print}
' *.ioe > all.events.ioe

cd ../..

#Create expression table.
python 00_scripts/18_expression_table.py 02_sqanti/MDS_classification_PB_renamed.txt 18_SUPPA/expression_table.tsv

#Must remove first title column from expression table

#Calculate PSI values.
python /project/sheynkman/programs/SUPPA-2.4/suppa.py psiPerEvent --ioe-file 18_SUPPA/01_splice_events/all.events.ioe --expression-file 18_SUPPA/expression_table.tsv -o 18_SUPPA/combined_local

#Differential splicing. Split the PSI and TPM files between the two conditions (if comparing)
Rscript 00_scripts/18_suppa_split_file.R 18_SUPPA/expression_table.tsv BioSample_1,BioSample_2,BioSample_3 BioSample_4,BioSample_5,BioSample_6 18_SUPPA/Q157R.tpm 18_SUPPA/WT.tpm -i
Rscript 00_scripts/18_suppa_split_file.R 18_SUPPA/combined_local.psi BioSample_1,BioSample_2,BioSample_3 BioSample_4,BioSample_5,BioSample_6 18_SUPPA/Q157R.psi 18_SUPPA/WT.psi -e

#Analyze differential splicing.
python /project/sheynkman/programs/SUPPA-2.4/suppa.py diffSplice \
    -m empirical \
    -i 18_SUPPA/01_splice_events/all.events.ioe \
    -p 18_SUPPA/Q157R.psi 18_SUPPA/WT.psi \
    -e 18_SUPPA/Q157R.tpm 18_SUPPA/WT.tpm \
    -gc \
    -o 18_SUPPA/FBS_diffsplice

conda deactivate
module purge
