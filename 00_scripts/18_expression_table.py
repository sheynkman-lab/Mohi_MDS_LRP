import pandas as pd
import argparse

def sqanti_to_tpm(input_file, output_file):
    """
    Converts SQANTI classification file with CPM values to a new table with TPM values.

    Parameters:
    input_file (str): Path to the input SQANTI file.
    output_file (str): Path to save the output file.
    """
    # Read the SQANTI file into a DataFrame
    df = pd.read_csv(input_file, sep="\t")

    # Extract only the FL.* columns for samples and the isoform column
    sample_columns = [col for col in df.columns if col.startswith("FL.")]
    isoforms = df['isoform']

    # Compute total CPM for each sample
    total_cpm = df[sample_columns].sum(axis=0)

    # Convert CPM to TPM
    tpm_values = df[sample_columns].div(total_cpm, axis=1) * 1e6

    # Create a new DataFrame with isoform names and TPM values
    output_df = pd.concat([isoforms, tpm_values], axis=1)
    output_df.columns = ["Transcript"] + [col.replace("FL.", "") for col in sample_columns]

    # Write the resulting table to a file
    output_df.to_csv(output_file, sep="\t", index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert SQANTI CPM values to TPM table.")
    parser.add_argument("input_file", help="Path to the input SQANTI file.")
    parser.add_argument("output_file", help="Path to save the output TPM table.")
    args = parser.parse_args()

    sqanti_to_tpm(args.input_file, args.output_file)
