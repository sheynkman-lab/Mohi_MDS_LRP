#!/bin/bash

#SBATCH --job-name=reference_tab
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00 #amount of time for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

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
module load openmpi/4.1.4
module load python/3.11.4

cd /project/sheynkman/projects/mohi_MDS

conda activate reference_tab

apptainer exec /project/sheynkman/dockers/LRP/generate-reference-tables_latest.sif /bin/bash -c "\
    python ./00_scripts/01_prepare_reference_tables.py \
        --gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
        --fa /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.pc_transcripts.fa \
        --ensg_gene ./01_reference_tables/ensg_gene.tsv \
        --enst_isoname ./01_reference_tables/enst_isoname.tsv \
        --gene_ensp ./01_reference_tables/gene_ensp.tsv \
        --gene_isoname ./01_reference_tables/gene_isoname.tsv \
        --isoname_lens ./01_reference_tables/isoname_lens.tsv \
        --gene_lens ./01_reference_tables/gene_lens.tsv \
        --protein_coding_genes ./01_reference_tables/protein_coding_genes.txt
"
exit
conda deactivate
