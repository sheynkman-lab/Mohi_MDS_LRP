# dtu_analysis.R

# ================
# Package Handling
# ================
options(repos = c(CRAN = "https://cloud.r-project.org"))
packages <- c("vroom", "dplyr", "ggplot2", "DRIMSeq")
installed <- rownames(installed.packages())

cran_packages <- c("vroom", "dplyr", "ggplot2")
for (pkg in cran_packages) {
  if (!pkg %in% installed) install.packages(pkg)
}

if (!"BiocManager" %in% installed) install.packages("BiocManager")
if (!"DRIMSeq" %in% installed) BiocManager::install("DRIMSeq")

lapply(packages, library, character.only = TRUE)

# =====================
# Set Working Directory
# =====================
setwd("/Volumes/sheynkman/projects/Mohi_MDS_LRP")
output_dir <- "20_visualization/DTU"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ============================
# Load and Prepare Count Data
# ============================

counts <- vroom("01_isoseq/collapse/merged.collapsed.flnc_count.txt", delim = ",", show_col_types = FALSE)
if (!"id" %in% colnames(counts)) stop("Count file must have an 'id' column.")

counts <- counts %>% rename(feature_id = id)

# ============================
# Add Gene Mapping
# ============================

# Read SQANTI classification
sqanti <- vroom("02_sqanti/MDS_classification.txt", delim = "\t", show_col_types = FALSE)

# Read transcript-to-gene name mapping
gene_map <- vroom("01_reference_tables/ensg_gene.tsv", delim = "\t", show_col_types = FALSE,
                  col_names = c("associated_gene", "gene_name"))

# Join SQANTI to get gene info
counts <- counts %>%
  left_join(sqanti[, c("isoform", "associated_gene")], by = c("feature_id" = "isoform")) %>%
  mutate(
    # Strip version suffix from Ensembl gene IDs
    associated_gene_clean = ifelse(
      grepl("^ENSMUSG", associated_gene),
      sub("\\..*$", "", associated_gene),
      associated_gene  # retain 'novelGene_xxx' or 'novel'
    )
  )

# Merge readable gene names if available
counts <- counts %>%
  left_join(gene_map, by = c("associated_gene_clean" = "associated_gene")) %>%
  mutate(
    gene_id = ifelse(!is.na(gene_name), gene_name, associated_gene_clean)
  ) %>%
  select(-associated_gene, -associated_gene_clean, -gene_name)

# =====================================
# Select Sample Columns and Finalize DF
# =====================================
sample_cols <- c("BioSample_1", "BioSample_2", "BioSample_3", 
                 "BioSample_4", "BioSample_5", "BioSample_6")

missing <- setdiff(sample_cols, colnames(counts))
if (length(missing) > 0) stop("Missing sample columns: ", paste(missing, collapse = ", "))

counts <- counts %>% select(feature_id, gene_id, all_of(sample_cols))

# ======================
# Create Sample Metadata
# ======================
samples <- data.frame(
  sample_id = sample_cols,
  group = c("Q157R", "Q157R", "Q157R", "WT", "WT", "WT")
)
samples$group <- factor(samples$group)

stopifnot(all(samples$sample_id %in% colnames(counts)))
stopifnot(all(colnames(counts)[-(1:2)] %in% samples$sample_id))

# ============================
# Run DRIMSeq DTU Analysis
# ============================
# Ensure counts is a base data.frame
counts <- as.data.frame(counts)

# Ensure all sample columns are integers (not character or double)
counts[sample_cols] <- lapply(counts[sample_cols], as.integer)

# Now run DRIMSeq setup
d <- dmDSdata(counts = counts, samples = samples)

d <- dmFilter(d,
              min_samps_gene_expr = 1,
              min_samps_feature_expr = 1,
              min_gene_expr = 1,
              min_feature_expr = 1)

design <- model.matrix(~ group, data = samples)

d <- dmPrecision(d, design = design)
d <- dmFit(d, design = design)
d <- dmTest(d, coef = "groupWT")

# ============================
# Save Results
# ============================

res_gene <- results(d, level = "gene")
vroom_write(res_gene, file.path(output_dir, "dtu_gene_results.tsv"))

res_transcript <- results(d, level = "feature")
vroom_write(res_transcript, file.path(output_dir, "dtu_transcript_results.tsv"))

# ============================
# Plot Top 5 DTU Genes
# ============================
top_genes <- head(res_gene[order(res_gene$pvalue), ], 5)$gene_id

for (gene in top_genes) {
  png(file.path(output_dir, paste0("dtu_", gene, "_barplot.png")), width = 800, height = 600)
  plotProportions(d, gene_id = gene, group_variable = "group", plot_type = "barplot")
  dev.off()
}

