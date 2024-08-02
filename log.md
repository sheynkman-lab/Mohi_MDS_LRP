## After each working session, push changes to GitHub
```
git status
git add .
git commit -m "Your descriptive commit message"
git remote -v
#git remote add origin https://github.com/sheynkman-lab/Mohi_MDS_LRP.git #only if the remote is not already set
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
It looks like I will need to run isoseq3 on each sample then demultiplex (or actually mutliplex?) the samples before moving on to SQANTI. The roadmap for this is in `/projects/smc_proteogenomics/pacbio_analysis_full` and https://github.com/sheynkman-lab/IsoSeq-Nextflow/tree/main 
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
```
sbatch ./00_scripts/01_make_reference_tables.sh
```
## 2 - Run SQANTI3
```
sbatch ./00_scripts/02_sqanti.sh
```
## 2 - Make gencode database
```
sbatch ./00_scripts/02_make_gencode_database.sh
```
## 3 - Filter SQANTI3 output - skipped for mouse
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
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

conda activate utr

python ./00_scripts/10_1_get_gc_exon_and_5utr_info.py \
--gencode_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--odir ./10_5p_utr

python ./00_scripts/10_2_classify_5utr_status.py \
--gencode_exons_bed ./10_5p_utr/gencode_exons_for_cds_containing_ensts.bed \
--gencode_exons_chain ./10_5p_utr/gc_exon_chain_strings_for_cds_containing_transcripts.tsv \
--sample_cds_gtf ./07_make_cds_gtf/MDS_cds.gtf \
--odir ./10_5p_utr 

python ./00_scripts/10_3_merge_5utr_info_to_pclass_table.py \
--name MDS \
--utr_info ./10_5p_utr/pb_5utr_categories.tsv \
--sqanti_protein_classification ./09_sqanti_protein/MDS.sqanti_protein_classification.tsv \
--odir ./10_5p_utr

conda deactivate
module purge
```
## 11 - Protein classification
```
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

conda activate protein_class

python ./00_scripts/11_protein_classification_add_meta.py \
--protein_classification  ./10_5p_utr/MDS.sqanti_protein_classification_w_5utr_info.tsv \
--best_orf ./05_orf_calling/MDS_best_ORF.tsv \
--refined_meta ./06_refine_orf_database/MDS_30_orf_refined.tsv \
--ensg_gene ./01_reference_tables/ensg_gene.tsv \
--name MDS \
--dest_dir ./11_protein_classification/

python ./00_scripts/11_protein_classification.py \
--sqanti_protein ./11_protein_classification/MDS.protein_classification_w_meta.tsv \
--name MDS \
--dest_dir ./11_protein_classification/
```
## 12 - Protein gene rename
```
python ./00_scripts/12_protein_gene_rename.py \
    --sample_gtf ./07_make_cds_gtf/MDS_cds.gtf \
    --sample_protein_fasta ./06_refine_orf_database/MDS_30_orf_refined.fasta \
    --sample_refined_info ./06_refine_orf_database/MDS_30_orf_refined.tsv \
    --pb_protein_genes ./11_protein_classification/MDS_genes.tsv \
    --name ./12_protein_gene_rename/MDS
```
## 13 - Protein filter
```
python ./00_scripts/13_protein_filter.py \
--protein_classification ./11_protein_classification/MDS.protein_classification.tsv \
--gencode_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--protein_fasta ./12_protein_gene_rename/MDS.protein_refined.fasta \
--sample_cds_gtf ./12_protein_gene_rename/MDS_with_cds_refined.gtf \
--min_junctions_after_stop_codon 2 \
--name ./13_protein_filter/MDS
```
## 14 - Protein hybrid database
```
python ./00_scripts/14_make_hybrid_database.py \
    --protein_classification ./13_protein_filter/MDS.classification_filtered.tsv \
    --gene_lens ./01_reference_tables/gene_lens.tsv \
    --pb_fasta ./13_protein_filter/MDS.filtered_protein.fasta \
    --gc_fasta ./02_make_gencode_database/gencode_clusters.fasta \
    --refined_info ./12_protein_gene_rename/MDS_orf_refined_gene_update.tsv \
    --pb_cds_gtf ./13_protein_filter/MDS_with_cds_filtered.gtf \
    --name ./14_protein_hybrid_database/MDS

conda deactivate
module purge
```
## 18 - Track visualization
```
module load gcc/11.4.0  
module load openmpi/4.1.4
module load python/3.11.4
module load bioconda/py3.10
module load anaconda/2023.07-py3.11

conda activate visualization

## Reference track 

python ./00_scripts/18_gencode_filter_protein_coding.py \
--reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--output_dir ./18_track_visualization/reference

gtfToGenePred ./18_track_visualization/reference/gencode.filtered.gtf ./18_track_visualization/reference/gencode.filtered.genePred

genePredToBed ./18_track_visualization/reference/gencode.filtered.genePred ./18_track_visualization/reference/gencode.filtered.bed12

python ./00_scripts/18_gencode_add_rgb_to_bed.py \
--gencode_bed ./18_track_visualization/reference/gencode.filtered.bed12 \
--rgb 0,0,140 \
--version V46 \
--output_dir ./18_track_visualization/reference

# Multiregion BED

# Refined
python ./00_scripts/18_make_region_bed_for_ucsc.py \
--name MDS_refined \
--sample_gtf ./07_make_cds_gtf/MDS_cds.gtf \
--reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--output_dir ./18_track_visualization/multiregion_bed

# Filtered
python ./00_scripts/18_make_region_bed_for_ucsc.py \
--name MDS_filtered \
--sample_gtf ./13_protein_filter/MDS_with_cds_filtered.gtf \
--reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--output_dir ./18_track_visualization/multiregion_bed

# Hybrid
python ./00_scripts/18_make_region_bed_for_ucsc.py \
--name MDS_hybrid \
--sample_gtf ./14_protein_hybrid_database/MDS_cds_high_confidence.gtf \
--reference_gtf /project/sheynkman/external_data/GENCODE_M35/gencode.vM35.basic.annotation.gtf \
--output_dir ./18_track_visualization/multiregion_bed

conda deactivate
```