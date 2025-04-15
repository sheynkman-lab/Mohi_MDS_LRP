import pandas as pd
import argparse

def aggregate_gene_counts(input_file, output_file):
    # Load the count file with automatic delimiter detection
    df = pd.read_csv(input_file, sep=None, engine="python")

    # Print column names to debug potential issues
    print("Detected columns:", df.columns)

    # Ensure the first column is correctly named
    first_col = df.columns[0]  # Get the actual column name

    # Rename the first column if necessary
    df.rename(columns={first_col: "id"}, inplace=True)

    # Extract gene ID from transcript ID (PB.XX.YY -> PB.XX)
    df["gene_id"] = df["id"].astype(str).apply(lambda x: ".".join(x.split(".")[:2]))

    # Aggregate counts by gene (sum transcript counts within the same gene)
    gene_counts = df.groupby("gene_id").sum(numeric_only=True).reset_index()

    # Save the gene-level count file
    gene_counts.to_csv(output_file, sep="\t", index=False)
    print(f"Gene-level counts saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Aggregate transcript-level counts into gene-level counts.")
    parser.add_argument("input_file", help="Path to the input count file")
    parser.add_argument("output_file", help="Path to save the output gene-level count file")

    args = parser.parse_args()
    aggregate_gene_counts(args.input_file, args.output_file)