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

# Step 1 - align CDS_GTF file with SQANTI classification output (need CPM for each biological sample, and need each biological sample to be renamed as X504_Q157R, A258_Q157R, A309_Q157R, V335_WT, V334_WT, and A310_WT) and gene name and transcript from sqanti_isoform_info.tsv
    # Should also contain column saying K or N for known or novel
python 00_scripts/19_summary_table.py -s 02_sqanti/MDS_classification.txt -w 07_make_cds_gtf/WT_cds.gtf -m 07_make_cds_gtf/Q157R_cds.gtf -i 04_transcriptome_summary/sqanti_isoform_info.tsv -o 19_LRP_summary/full_summary.tsv

# Step 2 - gene counts table with gene name and CPM for each biological sample
python 00_scripts/19_sum_gene_cpm.py -i 19_LRP_summary/full_summary.tsv -o 19_LRP_summary/gene_cpm_summary.tsv

# Step 3 - isoform fractional abundance table with transcript name and CPM for each biological sample
python 00_scripts/19_calculate_isoform_fractions.py -i 19_LRP_summary/full_summary.tsv -o 19_LRP_summary/isoform_fractions.tsv

# Step 4 - differential expression 
    # bring transcript counts table to edgeR and generate differential gene expression with average WT and mutant samples with p-values
    # Ran edgeR in R

python 00_scripts/19_diff_transcript_expression.py \
    -s 19_LRP_summary/full_summary.tsv \
    -e 19_LRP_summary/edgeR/edgeR_transcript_results.csv \
    -o 19_LRP_summary/diff_transcript_expression.tsv
