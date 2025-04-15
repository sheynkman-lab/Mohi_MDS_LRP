#!/bin/bash

#SBATCH --job-name=filter_sqanti
#SBATCH --cpus-per-task=10 #number of cores to use
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=24:00:00 #amount of time for the whole job
#SBATCH --mem=100G #amount of memory for the whole job
#SBATCH --partition=standard #the queue/partition to run on
#SBATCH --account=sheynkman_lab
#SBATCH --output=%x-%j.log
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=yqy3cu@virginia.edu

module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load bioconda/py3.10
module load miniforge/24.3.0-py3.11

conda activate sqanti_filter

chmod +x /project/sheynkman/programs/SQANTI3-5.2/utilities/gtfToGenePred
export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/project/sheynkman/programs/SQANTI3-5.2/cDNA_Cupcake/

#python 00_scripts/03_filter_sqanti_mouse.py \
#    --sqanti_classification 02_sqanti/MDS_classification.txt \
#    --sqanti_corrected_fasta 02_sqanti/MDS_corrected.fasta \
#    --sqanti_corrected_gtf 02_sqanti/MDS_corrected.gtf \
#    --protein_coding_genes 01_reference_tables/protein_coding_genes.txt \
#    --ensmusg_gene 01_reference_tables/ensg_gene.tsv \
#    --filter_protein_coding yes \
#    --filter_intra_polyA yes \
#    --filter_template_switching yes \
#    --percent_A_downstream_threshold 80 \
#    --structural_categories_level strict \
#    --minimum_illumina_coverage 3 \
#    --output_dir 03_filter_sqanti/dropout

python 00_scripts/03_collapse_isoforms.py \
    --name MDS \
    --sqanti_gtf 03_filter_sqanti/filtered_MDS_corrected.gtf \
    --sqanti_fasta 03_filter_sqanti/filtered_MDS_corrected.fasta \
    --output_folder 03_filter_sqanti/dropout

python 00_scripts/03_collapse_classification.py \
    --name MDS \
    --collapsed_fasta 03_filter_sqanti/MDS_corrected.5degfilter.fasta \
    --classification 03_filter_sqanti/filtered_MDS_classification.tsv \
    --output_folder 03_filter_sqanti/dropout

conda deactivate
module purge