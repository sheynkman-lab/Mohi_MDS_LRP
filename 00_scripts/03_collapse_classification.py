
#!/usr/bin/env python3

import argparse
import pandas as pd
import os

def main():
    parser = argparse.ArgumentParser(description="Collapse classification to match collapsed isoforms.")
    parser.add_argument('--name', required=True, help='Sample name prefix.')
    parser.add_argument('--collapsed_fasta', required=True, help='Collapsed FASTA file (input).')
    parser.add_argument('--classification', required=True, help='Filtered SQANTI classification TSV (input).')
    parser.add_argument('--output_folder', required=True, help='Output directory for collapsed classification.')

    args = parser.parse_args()

    os.makedirs(args.output_folder, exist_ok=True)

    base_name = args.name
    output_file = os.path.join(args.output_folder, f"{base_name}_collapsed_classification.tsv")
    dropout_file = os.path.join(args.output_folder, f"dropout_{base_name}_collapsed_classification.tsv")

    # Extract IDs from collapsed FASTA
    collapsed_ids = []
    with open(args.collapsed_fasta, "r") as fasta_in:
        for line in fasta_in:
            if line.startswith(">"):
                header = line[1:].strip()
                ids = header.split("|")
                collapsed_ids.extend(ids)

    collapsed_ids_set = set(collapsed_ids)

    # Load original classification
    class_df = pd.read_csv(args.classification, sep="\t")
    classified_ids = set(class_df["isoform"])

    # Split matched vs unmatched
    matched_df = class_df[class_df["isoform"].isin(collapsed_ids_set)]
    dropout_df = class_df[~class_df["isoform"].isin(collapsed_ids_set)]

    # Save outputs
    matched_df.to_csv(output_file, sep="\t", index=False)
    if not dropout_df.empty:
        dropout_df.to_csv(dropout_file, sep="\t", index=False)

    print(f"Classification collapsing complete: {len(matched_df)} kept, {len(dropout_df)} dropouts.")

if __name__ == "__main__":
    main()
