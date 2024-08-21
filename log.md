# MDS Project
This project is comparing protein isoforms identified by long-read proteogenomics between wild type and mutant model mice. The goal is to identify novel isoforms and quantify the changes in isoform expression between the two groups. <br />
The IsoSeq tool is not yet equipped to run multiple samples and demultiplex them, so I am running the pipeline twice - one on 3 mutant model samples and one on 3 wild type samples. The results will be in folders called `wild_type` and `disease` <br />
I ran the script on all samples first, and the output is in a separate folder called `all_samples`, and the slurm script for running these together are in `00_scripts/all_samples`. <br />
## After each working session, push changes to GitHub
```
git status
git add .
git commit -m "Your descriptive commit message"
git reWTe -v
#git reWTe add origin https://github.com/sheynkman-lab/Mohi_MDS_LRP.git #only if the reWTe is not already set
git push origin main
```
## Set working directory and load required modules for LRP
```
cd /project/sheynkman/projects

module load mamba/22.11.1-4
module load bioconda/py3.10
module load anaconda/2023.07-py3.11
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load git-lfs/2.10.0

git clone https://github.com/sheynkman-lab/Mohi_MDS_LRP.git

cd Mohi_MDS_LRP

cd /project/sheynkman/projects/Mohi_MDS_LRP
```
## 1 - Run Isoseq
It looks like I will need to run isoseq3 on each sample then demultiplex (or actually mutliplex?) the samples before moving on to SQANTI. The roadmap for this is in `/projects/smc_proteogenomics/pacbio_analysis_full` and https://github.com/sheynkman-lab/IsoSeq-Nextflow/tree/main <br />
Demultiplexing is paused for now after speaking with PacBio represenatatives. I am proceeding with grouping disease and wild type samples together and running the pipeline on each to compare. <br />
The information about which samples are wild type (03, 04, and 05) and which are mutant models (06, 07, and 08) is in the IsoSeq raw data file. <br />
```
sbatch 00_scripts/01_isoseq.sh
```
Dempultiplex - skipped
```
conda activate isoseq_env

python 00_scripts/01_demux.py \
-idir 01_isoseq \
-odir 01_isoseq/07_demux \
--name merged

conda deactivate
```
Demultiplex
```
python ./00_scripts/01_demux.py -idir ./01_isoseq -odir ./01_isoseq/07_demux --name merged
```
## 1 - Make reference tables
This module is independent of the samples and can be run once for all samples.
```
sbatch ./00_scripts/01_make_reference_tables.sh
```
## 2 - Run SQANTI3
```
sbatch ./00_scripts/02_sqanti.sh
```
## 2 - Make gencode database
This module is independent of the samples and can be run once for all samples.
```
sbatch ./00_scripts/02_make_gencode_database.sh
```
## 3 - Filter SQANTI3 output
These scripts are only made for human data, so I'm skipping for mouse data. Transcrips will be filtered further down the pipeline.
```
sbatch ./00_scripts/03_filter_sqanti.sh
```
## 4 - CPAT
```
sbatch ./00_scripts/04_cpat.sh
```
## 4 - Transcriptome summary
```
sbatch ./00_scripts/04_transcriptome_summary.sh
```
## 5 - ORF-callling
```
sbatch ./00_scripts/05_orf_calling.sh
```
## 6 - Refine ORF database
```
sbatch ./00_scripts/06_refine_orf_database.sh
```
## 7 - Make CDS GTF
Note: for mouse data, the python script needs to be modified from hg38 to mm39. <br />
```
sbatch ./00_scripts/07_make_cds_gtf.sh
```
## 8 - Rename CDS to exon
```
sbatch ./00_scripts/08_rename_cds_to_exon.sh
```
## 9 - Sqanti protein
```
sbatch ./00_scripts/09_sqanti_protein.sh
```
## 10 - 5' UTR
```
sbatch 00_scripts/10_5p_utr.sh
```
## 11 - Protein classification
```
sbatch 00_scripts/11_protein_classification.sh
```
## 12 - Protein gene rename
```
sbatch 00_scripts/12_protein_gene_rename.sh
```
Skip middle steps from the typical LRP workflow here, because we are focused on transcripts.
## 17 - Track visualization
This step is more run by run customizable, so I'll do it manually
```
module purge
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

conda activate visualization

# Wild Type - RGB code (219,076,119)
# Refined
gtfToGenePred wild_type/12_protein_gene_rename/WT_with_cds_refined.gtf wild_type/17_track_visualization/WT_refined_cds.genePred
genePredToBed wild_type/17_track_visualization/WT_refined_cds.genePred wild_type/17_track_visualization/WT_refined_cds.bed12

python ./00_scripts/17_add_rgb_to_bed.py \
--input_bed wild_type/17_track_visualization/WT_refined_cds.bed12 \
--output_dir wild_type/17_track_visualization/ \
--rgb 219,076,119

# Mutant - RGB code (016,085,154)
# Refined
gtfToGenePred mutant/12_protein_gene_rename/M_with_cds_refined.gtf mutant/17_track_visualization/M_refined_cds.genePred
genePredToBed mutant/17_track_visualization/M_refined_cds.genePred mutant/17_track_visualization/M_refined_cds.bed12

python ./00_scripts/17_add_rgb_to_bed.py \
--input_bed mutant/17_track_visualization/M_refined_cds.bed12 \
--output_dir mutant/17_track_visualization/ \
--rgb 016,085,154
```

## 18 - Gene & Transcript Expression tables
First, I am creating tables that show gene expression, transcript expression, and transcript fractional abundance for mutant vs. wild type samples. Then, I will create a summary table. Becuase of the way PacBio accession numbers are assigned, we need to work around the mismatch. Here, I am using the wild type samples as a reference for accession numbers, then labeling any transcripts unique to the mutant samples as 'gene name + PB + number'. <br />
```
# gene expression 
python 00_scripts/18_gene_expression.py wild_type/17_track_visualization/WT_refined_cds.bed12 mutant/17_track_visualization/M_refined_cds.bed12 18_diff_expression/18_differential_gene_expression.csv

# transcript expression & fractional abundance
python 00_scripts/18_fractional_abundance.py wild_type/17_track_visualization/WT_refined_cds.bed12 mutant/17_track_visualization/M_refined_cds.bed12 18_diff_expression/18_transcript_expression_fractional_abundance.csv

# gene and transcript summary table
python 00_scripts/18_summary_table.py 18_diff_expression/18_transcript_expression_fractional_abundance.csv 18_diff_expression/18_summary_table.csv
```
Finally, I am making list of genes and transcripts unique to the mutant samples. This will use both the unified naming scheme and have the original PacBio accession numbers for the mutant samples. <br />
```
python 00_scripts/18_unique_transcripts.py wild_type/17_track_visualization/WT_refined_cds.bed12 mutant/17_track_visualization/M_refined_cds.bed12 18_diff_expression/18_unique_transcripts.csv
```