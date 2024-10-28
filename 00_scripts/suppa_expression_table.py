import pandas as pd
import argparse
import os

def create_expression_table(bed_files, sample_names, output_file):
    expression_data = {}

    # Loop through each BED file and extract transcript IDs and CPM values
    for bed_file, sample_name in zip(bed_files, sample_names):
        with open(bed_file, 'r') as f:
            for line in f:
                fields = line.strip().split('\t')
                
                # Parse transcript_info field for gene, transcript, and CPM
                transcript_info = fields[3].split('|')
                transcript_id = transcript_info[1]
                cpm = float(transcript_info[2])
                
                # Initialize dictionary for each transcript if not already present
                if transcript_id not in expression_data:
                    expression_data[transcript_id] = {}
                
                # Add CPM value to the dictionary under the corresponding sample
                expression_data[transcript_id][sample_name] = cpm
    
    # Create DataFrame from the expression data dictionary
    df = pd.DataFrame(expression_data).T  # Transpose to get transcripts as rows
    df = df.fillna(0)  # Fill missing CPM values with 0
    df.index.name = 'Transcript'  # Set the index name to 'Transcript'

    # Write to output file
    df.to_csv(output_file, sep='\t')

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Generate expression table from specified BED12 files with CPM data.")
    parser.add_argument('-f', '--files', nargs='+', required=True, help="List of BED12 files with CPM data, in the desired sample order")
    parser.add_argument('-s', '--samples', nargs='+', required=True, help="List of sample names corresponding to each BED file")
    parser.add_argument('-o', '--output_file', required=True, help="Output .cpm file for the expression table")
    args = parser.parse_args()

    # Check if the number of files matches the number of sample names
    if len(args.files) != len(args.samples):
        print("Error: The number of files must match the number of sample names.")
        return

    # Create expression table
    create_expression_table(args.files, args.samples, args.output_file)

if __name__ == "__main__":
    main()
