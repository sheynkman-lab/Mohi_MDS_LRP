# Load required libraries
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("pheatmap", quietly = TRUE)) install.packages("pheatmap")

BiocManager::install(c("edgeR", "DRIMSeq", "pheatmap"))

# Load libraries
library(edgeR)
library(ggplot2)
library(readr)
library(pheatmap)
library(DRIMSeq)

# Set working directory
setwd("/Volumes/sheynkman/projects/Mohi_MDS_LRP")

###############################################
############# Differential Transcripts ########
###############################################

# Read in transcript-level count data
counts <- read.csv("01_isoseq/collapse/merged.collapsed.flnc_count.txt", header=TRUE, row.names=1)

# Define sample groups
group <- factor(c("Q157R", "Q157R", "Q157R", "WT", "WT", "WT"))

# Create DGEList object
dge <- DGEList(counts=counts, group=group)

# Filter transcripts with low expression
keep <- filterByExpr(dge)
dge <- dge[keep, , keep.lib.sizes=FALSE]

# Normalize data using TMM
dge <- calcNormFactors(dge, method = "TMM")

# Create design matrix
design <- model.matrix(~ group)

# Estimate dispersion and fit model
dge <- estimateDisp(dge, design)
fit <- glmQLFit(dge, design)
result <- glmQLFTest(fit, coef=2) # Compare Q157R to WT

# Extract results
deg_results <- topTags(result, n=Inf)$table
deg_results$Gene <- rownames(deg_results)
deg_results$CPM <- rowMeans(cpm(dge, log=TRUE))  # Log-transformed CPM
deg_results$logP <- -log10(deg_results$PValue)  # -log10 p-value
write.table(deg_results, file="20_visualization/transcript_DEG_results.txt", sep="\t", quote=FALSE, row.names=TRUE)

# Define color categories for FDR plot
deg_results$color_FDR <- factor(ifelse(deg_results$FDR < 0.05 & deg_results$logFC > 2, "Upregulated",
                                       ifelse(deg_results$FDR < 0.05 & deg_results$logFC < -2, "Downregulated", "Not Significant")),
                                levels = c("Downregulated", "Not Significant", "Upregulated"))  

# Volcano Plot for FDR
ggplot(deg_results, aes(x=logFC, y=-log10(FDR), color=color_FDR)) +
  geom_point(size=1) +
  scale_color_manual(values=c("#008080", "black", "#FA8072")) +
  geom_hline(yintercept=-log10(0.05), linetype="dashed") +
  geom_vline(xintercept=c(-2, 2), linetype="dashed") +
  geom_text(aes(label=ifelse(FDR < 0.01 & abs(logFC) > 2, Gene, "")),
            hjust=1, vjust=1, size=3, check_overlap = TRUE) +
  theme_minimal() +
  labs(title="Volcano Plot - Transcripts (FDR)", x="Log2 Fold Change", y="-Log10 FDR")
ggsave("20_visualization/transcript_volcano_plot_FDR.png")

# Define color categories for CPM plot
deg_results$color_CPM <- factor(ifelse(deg_results$CPM > 2 & deg_results$logFC > 2, "Upregulated",
                                       ifelse(deg_results$CPM > 2 & deg_results$logFC < -2, "Downregulated", "Not Significant")),
                                levels = c("Downregulated", "Not Significant", "Upregulated"))

# Volcano Plot for CPM
ggplot(deg_results, aes(x=logFC, y=CPM, color=color_CPM)) +
  geom_point(size=1) +
  scale_color_manual(values=c("#008080", "black", "#FA8072")) +
  geom_hline(yintercept=log10(2), linetype="dashed") +
  geom_vline(xintercept=c(-2, 2), linetype="dashed") +
  geom_text(aes(label=ifelse(CPM > 3 & abs(logFC) > 2, Gene, "")),
            hjust=1, vjust=1, size=3, check_overlap = TRUE) +
  theme_minimal() +
  labs(title="Volcano Plot - Transcripts (CPM)", x="Log2 Fold Change", y="Log10 CPM")
ggsave("20_visualization/transcript_volcano_plot_CPM.png")

# Define color categories for log P-value plot
deg_results$color_logP <- factor(ifelse(deg_results$logP > -log10(0.05) & deg_results$logFC > 2, "Upregulated",
                                        ifelse(deg_results$logP > -log10(0.05) & deg_results$logFC < -2, "Downregulated", "Not Significant")),
                                 levels = c("Downregulated", "Not Significant", "Upregulated"))

# Volcano Plot for logP
ggplot(deg_results, aes(x=logFC, y=logP, color=color_logP)) +
  geom_point(size=1) +
  scale_color_manual(values=c("#008080", "black", "#FA8072")) +
  geom_hline(yintercept=-log10(0.05), linetype="dashed") +
  geom_vline(xintercept=c(-2, 2), linetype="dashed") +
  geom_text(aes(label=ifelse(logP > 5 & abs(logFC) > 2, Gene, "")), #points with very small p-values (high statistical confidence) and large fold changes (high biological impact) are labeled.
            hjust=1, vjust=1, size=3, check_overlap = TRUE) +
  theme_minimal() +
  labs(title="Volcano Plot - Transcripts (log P-Value)", x="Log2 Fold Change", y="-Log10 p-value")
ggsave("20_visualization/transcript_volcano_plot_logP.png")

###############################################
############# Differential Genes ########
###############################################

# Read in gene-level count data
counts_gene <- read_delim("/Volumes/sheynkman/projects/Mohi_MDS_LRP/01_isoseq/gene_level_counts.txt", 
                          delim = "\t", escape_double = FALSE, 
                          trim_ws = TRUE)

# Define sample groups
group_gene <- factor(c("Q157R", "Q157R", "Q157R", "WT", "WT", "WT"))

# Create DGEList object
dge_gene <- DGEList(counts=counts_gene, group=group_gene)

# Filter genes with low expression
keep_gene <- filterByExpr(dge_gene)
dge_gene <- dge_gene[keep_gene, , keep.lib.sizes=FALSE]

# Normalize data using TMM
dge_gene <- calcNormFactors(dge_gene, method = "TMM")

# Create design matrix
design_gene <- model.matrix(~ group_gene)

# Estimate dispersion and fit model
dge_gene <- estimateDisp(dge_gene, design_gene)
fit_gene <- glmQLFit(dge_gene, design_gene)
result_gene <- glmQLFTest(fit_gene, coef=2) # Compare Q157R to WT

# Extract results
deg_results_gene <- topTags(result_gene, n=Inf)$table
deg_results_gene$Gene <- rownames(deg_results_gene)
deg_results_gene$CPM <- rowMeans(cpm(dge_gene, log=TRUE))  # Log-transformed CPM
deg_results_gene$logP <- -log10(deg_results_gene$PValue)  # -log10 p-value
write.table(deg_results_gene, file="20_visualization/gene_DEG_results.txt", sep="\t", quote=FALSE, row.names=TRUE)

# Define color categories for FDR plot
deg_results_gene$color_FDR <- factor(ifelse(deg_results_gene$FDR < 0.05 & deg_results_gene$logFC > 2, "Upregulated",
                                            ifelse(deg_results_gene$FDR < 0.05 & deg_results_gene$logFC < -2, "Downregulated", "Not Significant")),
                                     levels = c("Downregulated", "Not Significant", "Upregulated"))  

# Volcano Plot for FDR
ggplot(deg_results_gene, aes(x=logFC, y=-log10(FDR), color=color_FDR)) +
  geom_point(size=1) +
  scale_color_manual(values=c("#008080", "black", "#FA8072")) +
  geom_hline(yintercept=-log10(0.05), linetype="dashed") +
  geom_vline(xintercept=c(-2, 2), linetype="dashed") +
  geom_text(aes(label=ifelse(FDR < 0.01 & abs(logFC) > 2, Gene, "")),
            hjust=1, vjust=1, size=3, check_overlap = TRUE) +
  theme_minimal() +
  labs(title="Volcano Plot - Genes (FDR)", x="Log2 Fold Change", y="-Log10 FDR")
ggsave("20_visualization/gene_volcano_plot_FDR.png")

# Define color categories for CPM plot
deg_results_gene$color_CPM <- factor(ifelse(deg_results_gene$CPM > 2 & deg_results_gene$logFC > 2, "Upregulated",
                                            ifelse(deg_results_gene$CPM > 2 & deg_results_gene$logFC < -2, "Downregulated", "Not Significant")),
                                     levels = c("Downregulated", "Not Significant", "Upregulated"))

# Volcano Plot for CPM
ggplot(deg_results_gene, aes(x=logFC, y=CPM, color=color_CPM)) +
  geom_point(size=1) +
  scale_color_manual(values=c("#008080", "black", "#FA8072")) +
  geom_hline(yintercept=log10(2), linetype="dashed") +
  geom_vline(xintercept=c(-2, 2), linetype="dashed") +
  geom_text(aes(label=ifelse(CPM > 3 & abs(logFC) > 2, Gene, "")),
            hjust=1, vjust=1, size=3, check_overlap = TRUE) +
  theme_minimal() +
  labs(title="Volcano Plot - Genes (CPM)", x="Log2 Fold Change", y="Log10 CPM")
ggsave("20_visualization/gene_volcano_plot_CPM.png")

# Define color categories for log P-value plot
deg_results_gene$color_logP <- factor(ifelse(deg_results_gene$logP > -log10(0.05) & deg_results_gene$logFC > 2, "Upregulated",
                                             ifelse(deg_results_gene$logP > -log10(0.05) & deg_results_gene$logFC < -2, "Downregulated", "Not Significant")),
                                      levels = c("Downregulated", "Not Significant", "Upregulated"))

# Volcano Plot for logP
ggplot(deg_results_gene, aes(x=logFC, y=logP, color=color_logP)) +
  geom_point(size=1) +
  scale_color_manual(values=c("#008080", "black", "#FA8072")) +
  geom_hline(yintercept=-log10(0.05), linetype="dashed") +
  geom_vline(xintercept=c(-2, 2), linetype="dashed") +
  geom_text(aes(label=ifelse(logP > 5 & abs(logFC) > 2, Gene, "")),
            hjust=1, vjust=1, size=3, check_overlap = TRUE) +
  theme_minimal() +
  labs(title="Volcano Plot - Genes (log P-Value)", x="Log2 Fold Change", y="-Log10 p-value")
ggsave("20_visualization/gene_volcano_plot_logP.png")
