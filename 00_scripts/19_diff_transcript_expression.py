import pandas as pd
import argparse

def compile_differential_expression(edgeR_file, summary_file, output_file):
    # Load the edgeR results
    edgeR_results = pd.read_csv(edgeR_file, index_col=0)

    # Load the summary table
    summary_table = pd.read_csv(summary_file, sep="\t")  # Adjust separator if needed

    # Convert Isoform_index and edgeR index to string for merging
    summary_table["Isoform_index"] = "PB." + summary_table["Isoform_index"].astype(str)
    edgeR_results.index = edgeR_results.index.astype(str)

    # Debugging: Print sample values to check for mismatches
    print("Updated summary table Isoform_index sample:", summary_table["Isoform_index"].head())
    print("edgeR results index sample:", edgeR_results.index.tolist()[:5])

    # Rename columns in edgeR results for clarity
    edgeR_results = edgeR_results.rename(columns={"logFC": "delta", "FDR": "adj_p-value", "PValue": "p-value"})

    # Merge edgeR results with summary table
    merged_df = summary_table.merge(edgeR_results, left_on="Isoform_index", right_index=True, how="inner")

    # Debugging: Check if merge worked
    print(f"Merged dataframe shape: {merged_df.shape}")
    if merged_df.empty:
        print("Warning: No matching Isoform_index found after prefix adjustment.")

    # Compute average CPM for Q157R and WT samples
    q157r_cols = ["X504_Q157R", "A258_Q157R", "A309_Q157R"]
    wt_cols = ["V335_WT", "V334_WT", "A310_WT"]

    merged_df["avg_Q157R"] = merged_df[q157r_cols].mean(axis=1)
    merged_df["avg_WT"] = merged_df[wt_cols].mean(axis=1)

    # Select relevant columns for final output
    final_df = merged_df[["Isoform_index", "Gene", "Transcript_name", "avg_Q157R", "avg_WT", "delta", "p-value", "adj_p-value"]]

    # Save the final table as TSV
    final_df.to_csv(output_file, sep="\t", index=False)

    print(f"Differential expression table saved as {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compile edgeR results with a summary table for differential transcript expression analysis.")
    parser.add_argument("-e", "--edgeR", required=True, help="Path to edgeR results CSV file")
    parser.add_argument("-s", "--summary", required=True, help="Path to summary table TSV file")
    parser.add_argument("-o", "--output", required=True, help="Output file name for the final differential expression table")

    args = parser.parse_args()

    compile_differential_expression(args.edgeR, args.summary, args.output)
