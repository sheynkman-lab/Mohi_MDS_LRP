import pandas as pd
import argparse

def process_gene_DEG(summary_file, deg_file, output_file):
    # Load summary table
    summary_df = pd.read_csv(summary_file, sep="\t", dtype={"Gene_index": str})  # Ensure Gene_index is a string

    # Load gene differential expression data
    deg_df = pd.read_csv(deg_file, sep="\t")

    # Extract numeric part from gene_id (removing 'PB.' prefix)
    deg_df["gene_id"] = deg_df["gene_id"].str.replace("PB.", "", regex=True)

    # Merge based on Gene_index (full_summary.tsv) and numeric gene_id (gene_DEG_results.txt)
    merged_df = pd.merge(summary_df, deg_df, left_on="Gene_index", right_on="gene_id", how="left")

    # Compute delta (logFC is already log-transformed)
    merged_df["delta"] = merged_df["logFC"]

    # Select and rename relevant columns
    output_df = merged_df[["Gene_index", "Gene", "logCPM", "delta", "PValue"]].copy()
    output_df.columns = ["gene_index", "gene", "avg_expr", "delta", "p-value"]

    # Save merged results
    output_df.to_csv(output_file, sep="\t", index=False)
    print(f"Merged differential expression results saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge gene expression summary with DEG results")
    parser.add_argument("-s", "--summary", required=True, help="Path to the gene summary table file")
    parser.add_argument("-e", "--expression", required=True, help="Path to the gene DEG results file")
    parser.add_argument("-o", "--output", required=True, help="Path to save the processed output file")

    args = parser.parse_args()
    process_gene_DEG(args.summary, args.expression, args.output)