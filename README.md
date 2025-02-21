# MDS Project
This project is comparing protein isoforms identified by long-read proteogenomics between wild type and mutant model mice. The goal is to identify novel isoforms and quantify the changes in isoform expression between the two groups. <br />

## Make directory structure and prepare the data 
```
cd /project/sheynkman/projects/Mohi_MDS_LRP
module load gcc/11.4.0 openmpi/4.1.4 python/3.11.4 miniforge/24.3.0-py3.11

mkdir ./00_input_data/
mkdir ./00_scripts/
mkdir 01_isoseq
mkdir 01_isoseq/merge
mkdir 01_isoseq/cluster
mkdir 01_isoseq/align
mkdir 01_isoseq/collapse
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
mkdir ./18_SUPPA/
mkdir ./18_SUPPA/01_splice_events/
mkdir ./19_LRP_summary/
mkdir ./19_LRP_summary/edgeR/

gunzip /project/sheynkman/raw_data/PacBio/mohi_data/X504_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9850-001_1-1-C01_IsoSeqX_bc06.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/A258_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9851-001_1-1-C01_IsoSeqX_bc07.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/A309_Q157R_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9852-001_1-1-C01_IsoSeqX_bc08.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/V335_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9847-001_1-1-C01_IsoSeqX_bc03.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/V334_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9848-001_1-1-C01_IsoSeqX_bc04.flnc.fastq.gz
gunzip /project/sheynkman/raw_data/PacBio/mohi_data/A310_WT_LK/PACBIO_DATA/XMOHI_20240510_R84050_PL9849-001_1-1-C01_IsoSeqX_bc05.flnc.fastq.gz
```

## Iso-Seq can now be run with mutliple samples and fits into our pipeline a little more smoothly, so I am re-running with Iso-Seq
## 01 - Iso-Seq
```
sbatch 00_scripts/01_isoseq_multisample.sh
```
## 01 - Make reference tables
```
sbatch 00_scripts/01_make_reference_tables.sh
```
## 02 - SQANTI
```
sbatch 00_scripts/02_sqanti.sh
```
## 02 - Make gencode database
```
sbatch 00_scripts/02_make_gencode_database.sh
```
## 04 - CPAT
```
sbatch 00_scripts/04_cpat.sh
```
## 04 - Transcriptome Summary
```
sbatch 00_scripts/04_transcriptome_summary.sh
```
## 05 - ORF Calling
This is where we are splitting WT and Q157R samples. <br />
```
sbatch 00_scripts/05_orf_calling.sh
```
## 06 - Refine ORF Database
```
sbatch 00_scripts/06_refine_orf_database.sh
```
## 07 - Make CDS GTF
```
sbatch 00_scripts/07_make_cds_gtf.sh
```
## 08 - Rename CDS to Exon
```
sbatch 00_scripts/08_rename_cds_to_exon.sh
```
## 09 - SQANTI Protein
```
sbatch 00_scripts/09_sqanti_protein.sh
```
## 10 - 5' UTR
```
sbatch 00_scripts/10_5p_utr.sh
```
## 11 - Protein Classification
```
sbatch 00_scripts/11_protein_classification.sh
```
## 12 - Protein Gene Rename
```
sbatch 00_scripts/12_protein_gene_rename.sh
```
## 13 - Protein Filter
```
sbatch 00_scripts/13_protein_filter.sh
```
## 14 - Protein Hybrid Database
```
sbatch 00_scripts/14_protein_hybrid_database.sh
```
## 17 - Track Visualization
```
sbatch 00_scripts/17_track_visualization.sh
```
## 18 - SUPPA
```
sbatch 00_scripts/18_suppa.sh
```
## 19 - LRP Result Summary
```
sbacth 00_scripts/19_LRP_summary.sh
```