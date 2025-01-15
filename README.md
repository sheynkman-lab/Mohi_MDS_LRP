# MDS Project
This project is comparing protein isoforms identified by long-read proteogenomics between wild type and mutant model mice. The goal is to identify novel isoforms and quantify the changes in isoform expression between the two groups. <br />

## Make directory structure and prepare the data 
```
cd /project/sheynkman/projects/Mohi_MDS_LRP
module load gcc/11.4.0 openmpi/4.1.4 python/3.11.4 miniforge/24.3.0-py3.11

mkdir ./00_input_data/
mkdir ./00_scripts/
mkdir ./01_mandalorion/
mkdir ./01_isoquant/
mkdir ./01_reference_tables/
mkdir ./02_make_gencode_database/
mkdir ./02_sqanti/
mkdir ./03_filter_sqanti/
mkdir ./04_CPAT/
mkdir ./04_transcriptome_summary/
mkdir ./05_orf_calling/
mkdir ./06_refine_orf_database/
mkdir ./07_make_cds_gtf/
mkdir ./08_rename_cds_to_exon/
mkdir ./09_sqanti_protein/
mkdir ./10_5p_utr/
mkdir ./11_protein_classification/
mkdir ./12_protein_gene_rename/
mkdir ./13_protein_filter/
mkdir ./14_protein_hybrid_database/
mkdir ./17_track_visualization/

gunzip /project/sheynkman/raw_data/PacBio/mohi_data/X504_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9850-001_1-1-C01_IsoSeqX_bc06.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/A258_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9851-001_1-1-C01_IsoSeqX_bc07.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/A309_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9852-001_1-1-C01_IsoSeqX_bc08.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/V335_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9847-001_1-1-C01_IsoSeqX_bc03.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/V334_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9848-001_1-1-C01_IsoSeqX_bc04.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/A310_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9849-001_1-1-C01_IsoSeqX_bc05.flnc.fastq.gz
```

I am going to proceed with both IsoQuant and Mandalorion, as we are testing both for use in our pipeline. Once we finalize our choice, I will make a choice for the direction of this project. <br />
I also created the reference tables and gencode database (which are independent of our data) in a previous run. <br />

## Step 1 - Mandalorion
```
sbatch 00_scripts/mandalorion.sh
```
Modify the Isoforms.filtered.clean.quant file for SQANTI input then split into WT and Q157R <br />
```
python 00_scripts/01_sqanti_counts_mando.py \
    01_mandalorion/Isoforms.filtered.clean.quant \
    01_mandalorion/fl_count_for_sqanti3.csv \
    sample6 sample7 sample8 sample3 sample4 sample5

python 00_scripts/01_sqanti_split_mando.py
```
Make two GTF files unique to each sample.
```
python 00_scripts/01_gtf_split_mando.py --gtf_file 01_mandalorion/Isoforms.filtered.clean.gtf --wt_csv 01_mandalorion/WT_fl_count_for_sqanti3.csv --q157r_csv 01_mandalorion/Q157R_fl_count_for_sqanti3.csv --wt_output 01_mandalorion/WT.gtf --q157r_output 01_mandalorion/Q157R.gtf
```

## Step 1 - IsoQuant
```
sbatch 00_scripts/isoquant.sh
```

Modify the transcript_model_grouped_counts.tsv file for SQANTI input
```
# all
python 00_scripts/01_sqanti_counts_isoquant.py \
    01_isoquant/OUT/OUT.transcript_model_grouped_counts.tsv \
    01_isoquant/fl_count_for_sqanti3.csv \
    sample3 sample4 sample5 sample6 sample7 sample8

# WT
python 00_scripts/01_sqanti_counts_isoquant.py \
    01_isoquant/WT/WT.transcript_model_grouped_counts.tsv \
    01_isoquant/WT_fl_count_for_sqanti3.csv \
    sample6 sample7 sample8

# Q157R
python 00_scripts/01_sqanti_counts_isoquant.py \
    01_isoquant/Q157R/Q157R.transcript_model_grouped_counts.tsv \
    01_isoquant/Q157R_fl_count_for_sqanti3.csv \
    sample3 sample4 sample5
```

## Step 2 - SQANTI
```
sbatch 00_scripts/02_isoquant_sqanti.sh
sbatch 00_scripts/02_mando_sqanti.sh
```
Isoquant's output works better for our pipeline than Mandalorion's. Future iterations of our pipeline will address this <br />

## Step 3 - Filter SQANTI
Skipped for mouse. <br />

## Step 4 - CPAT
```
sbatch 00_scripts/04_cpat.sh
sbatch 00_scripts/04_mando_cpat.sh
```

## Step 4 - Transcriptome Summary
```
sbatch 00_scripts/04_transcriptome_summary.sh
sbatch 00_scripts/04_mando_transcriptome_summary.sh
```

## Step 5 - ORF Calling
```
sbatch 00_scripts/05_orf_calling.sh
sbatch 00_scripts/05_mando_orf_calling.sh
```

## Step 6 - Refine ORF Database
```
sbatch 00_scripts/06_refine_orf_database.sh
```

## Step 7 - Make CDS GTF
```
sbatch 00_scripts/07_make_cds_gtf.sh
```

## Step 8 - Rename CDS to Exon
We need this step for SUPPA later in the pipeline. <br />
```
sbatch 00_scripts/08_rename_cds_to_exon.sh
```
Skip forward for this analysis (no MS and protein data here) <br />

## 17 - Track visualization
This step is more run by run customizable, so I'll do it manually. <br />
Color by sample. <br />
```
module purge
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11

conda activate visualization

# WT - RGB code (219,076,119)
# Refined
gtfToGenePred 07_make_cds_gtf/WT/WT_cds.gtf 17_track_visualization/WT/WT_refined_cds.genePred
genePredToBed 17_track_visualization/WT/WT_refined_cds.genePred 17_track_visualization/WT/WT_refined_cds.bed12

python ./00_scripts/17_add_rgb_to_bed.py \
--input_bed 17_track_visualization/WT/WT_refined_cds.bed12 \
--output_dir 17_track_visualization/WT \
--rgb 219,076,119

# Q157R - RGB code (016,085,154)
# Refined
gtfToGenePred 07_make_cds_gtf/Q157R/Q157R_cds.gtf 17_track_visualization/Q157R/Q157R_refined_cds.genePred
genePredToBed 17_track_visualization/Q157R/Q157R_refined_cds.genePred 17_track_visualization/Q157R/Q157R_refined_cds.bed12

python ./00_scripts/17_add_rgb_to_bed.py \
--input_bed 17_track_visualization/Q157R/Q157R_refined_cds.bed12 \
--output_dir 17_track_visualization/Q157R \
--rgb 016,085,154
```
Color by cpm. <br />
```
python 00_scripts/17_track_add_rgb_colors_to_bed.py --name WT_cpm --bed_file 17_track_visualization/WT/WT_refined_cds.bed12

python 00_scripts/17_track_add_rgb_colors_to_bed.py --name Q157R_cpm --bed_file 17_track_visualization/Q157R/Q157R_refined_cds.bed12
```

## 18 - SUPPA 
```
module purge
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load miniforge/24.3.0-py3.11
module load R/4.4.1

conda activate suppa

# Generate splicing events
python /project/sheynkman/programs/SUPPA-2.4/suppa.py generateEvents -i /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf -o SUPPA/events -f ioi

python /project/sheynkman/programs/SUPPA-2.4/suppa.py generateEvents -i 08_rename_cds_to_exon/WT/WT.cds_renamed_exon.gtf -o 18_SUPPA/LRP_events/WT.events -e SE SS MX RI FL -f ioe

python /project/sheynkman/programs/SUPPA-2.4/suppa.py generateEvents -i 08_rename_cds_to_exon/Q157R/Q157R.cds_renamed_exon.gtf -o 18_SUPPA/LRP_events/Q157R.events -e SE SS MX RI FL -f ioe

cd 18_SUPPA/LRP_events/

#Put all the ioe events in the same file:
awk '
    FNR==1 && NR!=1 { while (/^<header>/) getline; }
    1 {print}
' *.ioe > all.LRP.events.ioe

cd ../..

# create expression table 
python 00_scripts/18_suppa_expression_table.py -f 17_track_visualization/WT/WT_refined_cds.bed12 17_track_visualization/Q157R/Q157R_refined_cds.bed12 -s sample1 sample2 -o 18_SUPPA/combined.cpm

# Calculate PSI values 
python /project/sheynkman/programs/SUPPA-2.4/suppa.py psiPerEvent --ioe-file 18_SUPPA/LRP_events/all.LRP.events.ioe --expression-file 18_SUPPA/combined.cpm -o 18_SUPPA/combined_local

# Differential splicing 
# Split the PSI and TPM files between the 2 conditions:
Rscript 00_scripts/split_file.R 18_SUPPA/combined.cpm sample1 sample2 18_SUPPA/WT_sample1.tpm 18_SUPPA/Q157R_sample2.tpm -i
Rscript 00_scripts/split_file.R 18_SUPPA/combined_local.psi sample1 sample2 18_SUPPA/WT_sample1.psi 18_SUPPA/Q157R_sample2.psi -e

# Analyze differential splicing - creating an error now that I am trying to run with p-values, so reruning with ioi
python /project/sheynkman/programs/SUPPA-2.4/suppa.py diffSplice \
    -m empirical \
    -i 18_SUPPA/LRP_events/all.LRP.events.ioe \
    -p 18_SUPPA/WT_sample1.psi 18_SUPPA/Q157R_sample2.psi \
    -e 18_SUPPA/WT_sample1.tpm 18_SUPPA/Q157R_sample2.tpm \
    -gc \
    -o 18_SUPPA/diff_splice_events

conda deactivate
```
## 18 - Gene & Transcript Expression tables
First, I am creating tables that show gene expression, transcript expression, and transcript fractional abundance for mutant vs. wild type samples. Then, I will create a summary table. <br />
```
conda activate reference_tab

# gene expression 
python 00_scripts/18_gene_expression.py 17_track_visualization/WT/WT_refined_cds.bed12 17_track_visualization/Q157R/Q157R_refined_cds.bed12 18_LRP_summary/18_differential_gene_expression.csv

# transcript expression & fractional abundance
python 00_scripts/18_transcript_expression.py 17_track_visualization/WT/WT_refined_cds.bed12 17_track_visualization/Q157R/Q157R_refined_cds.bed12 18_LRP_summary/18_differential_transcript_expression.csv

python 00_scripts/18_fractional_abundance.py 17_track_visualization/WT/WT_refined_cds.bed12 17_track_visualization/Q157R/Q157R_refined_cds.bed12 18_LRP_summary/18_transcript_expression_fractional_abundance.csv

# gene and transcript summary table
python 00_scripts/18_summary_table.py 18_LRP_summary/18_transcript_expression_fractional_abundance.csv 18_LRP_summary/18_summary_table.csv
```
Now, I am making list of genes and transcripts unique to the mutant samples. <br />
```
python 00_scripts/18_unique_transcripts.py 17_track_visualization/WT/WT_refined_cds.bed12 17_track_visualization/Q157R/Q157R_refined_cds.bed12 18_LRP_summary/18_unique_transcripts.csv
```
These tables will summarize the gene and transcript expression, as well as the splicing information from SUPPA. <br />
```
python 00_scripts/transcript_summary_interm.py 07_make_cds_gtf/WT/WT_cds.gtf 07_make_cds_gtf/Q157R/Q157R_cds.gtf 18_LRP_summary/transcript_cpm.csv
```
Create summary tables for transcripts and SUPPA events. <br />
```
python 00_scripts/19_transcript_summary_interm.py
python 00_scripts/19_suppa_summary_interm.py
```
Create a mapping file to map splice events to transcripts and combine information for summary table. <br />
```
python 00_scripts/19_suppa_plus_transcript.py
```

## Iso-Seq can now be run with mutliple samples and fits into our pipeline a little more smoothly, so I am re-running with Iso-Seq
## 00 - Prepare
```
mkdir 01_isoseq
mkdir 01_isoseq/merge
mkdir 01_isoseq/cluster
mkdir 01_isoseq/align
mkdir 01_isoseq/collapse
```

## 01 - Iso-Seq
```
sbatch 00_scripts/01_isoseq_multisample.sh
```