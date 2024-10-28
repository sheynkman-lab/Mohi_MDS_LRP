#!/usr/bin/env python

import pandas as pd
import argparse

def main(input_file, output_file, sample_names):
    # Read the TSV file
    df = pd.read_csv(input_file, sep='\t')

    # Ensure the correct number of sample names is provided
    if len(sample_names) != df.shape[1] - 1:
        raise ValueError("The number of sample names provided does not match the number of samples in the file.")

    # Rename the columns: first column is 'id', followed by the sample names
    new_column_names = ['id'] + sample_names
    df.columns = new_column_names

    # Convert full-length counts to integer
    df.iloc[:, 1:] = df.iloc[:, 1:].astype(int)

    # Save the reformatted CSV file
    df.to_csv(output_file, index=False)
    print(f'Reformatted file saved as {output_file}')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Reformat IsoQuant counts TSV file for SQANTI3 input with custom sample names.")
    parser.add_argument("input_file", help="Path to the input TSV file.")
    parser.add_argument("output_file", help="Path to the output CSV file.")
    parser.add_argument("sample_names", nargs='+', help="List of sample names to use for renaming the columns (in order).")
    
    args = parser.parse_args()

    main(args.input_file, args.output_file, args.sample_names)
