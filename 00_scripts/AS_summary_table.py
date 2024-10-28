#!/usr/bin/env python

import pandas as pd
import argparse

def generate_summary(summary_table_path, suppa_file_path, output_file="summary_output.csv"):
    # Load the summary table with delimiter handling
    try:
        summary_table = pd.read_csv(summary_table_path, sep="\t")
        if len(summary_table.columns) == 1:
            summary_table = pd.read_csv(summary_table_path, sep=",")
    except Exception as e:
        print(f"Error loading summary table: {e}")
        return

    # Load the SUPPA .psivec file
    try:
        suppa_psivec = pd.read_csv(suppa_file_path, sep="\t")
        print("Columns in suppa_psivec:", suppa_psivec.columns.tolist())

        # Check if the SUPPA file has the expected columns
        if len(suppa_psivec.columns) != 3:
            raise ValueError("Expected exactly 3 columns in SUPPA file.")

        # Rename the columns appropriately
        suppa_psivec.columns = ['Alternative_Splice', 'WT_psi', 'Q157R_psi']
    except Exception as e:
        print(f"Error loading SUPPA file: {e}")
        return

    # Rename summary_table columns
    rename_dict = {
        'gene_name': 'Gene',
        'pb_id': 'Transcript',
        'cpm_WT': 'WT_cpm',
        'cpm_M': 'Q157R_cpm',
        'fractional_abundance_sample1': 'WT_psi',  # Update this if needed
        'fractional_abundance_sample2': 'Q157R_psi'  # Update this if needed
    }
    summary_table.rename(columns={k: v for k, v in rename_dict.items() if k in summary_table.columns}, inplace=True)

    # Ensure required columns are present
    required_columns = ['WT_cpm', 'Q157R_cpm', 'Gene', 'Transcript']
    missing_columns = [col for col in required_columns if col not in summary_table.columns]
    if missing_columns:
        raise ValueError(f"Missing columns in summary table: {missing_columns}")

    # Calculate delta values
    summary_table['delta_cpm'] = summary_table['Q157R_cpm'] - summary_table['WT_cpm']

    # Merge with SUPPA data on 'Alternative_Splice'
    merged = pd.merge(
        summary_table,
        suppa_psivec,
        how="left",
        left_on="Transcript",
        right_on="Alternative_Splice"
    )

    # Check the structure of the merged DataFrame
    print("Merged DataFrame columns:", merged.columns.tolist())

    # Calculate delta psi
    if 'Q157R_psi' in merged.columns and 'WT_psi' in merged.columns:
        merged['delta_psi'] = merged['Q157R_psi'] - merged['WT_psi']
    else:
        raise ValueError("Columns 'WT_psi' and 'Q157R_psi' not found in merged DataFrame.")

    # Reorder columns and save to output
    final_table = merged[['Gene', 'Transcript', 'WT_cpm', 'Q157R_cpm', 'delta_cpm', 
                          'Alternative_Splice', 'WT_psi', 'Q157R_psi', 'delta_psi']]
    final_table.to_csv(output_file, sep="\t", index=False)
    print(f"Summary table saved as {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a summary table with transcript abundance and PSI values.")
    parser.add_argument("summary_table", help="Path to the summary table file (e.g., summary_table.csv)")
    parser.add_argument("suppa_file", help="Path to the SUPPA .psivec file (e.g., suppa_file.psivec)")
    parser.add_argument("-o", "--output", default="summary_output.csv", help="Output file name (default: summary_output.csv)")
    
    args = parser.parse_args()
    generate_summary(args.summary_table, args.suppa_file, args.output)
