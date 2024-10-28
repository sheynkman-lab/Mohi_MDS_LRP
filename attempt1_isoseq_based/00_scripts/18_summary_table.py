import pandas as pd
import argparse

def format_table(input_file, output_file):
    # Load the data
    df = pd.read_csv(input_file)  # Adjust to pd.read_excel(input_file) if you're working with Excel files

    # Replace NaN values with 0 for CPM columns
    df['cpm_WT'] = df['cpm_WT'].fillna(0)
    df['cpm_M'] = df['cpm_M'].fillna(0)

    # Initialize a list to store the formatted output rows
    formatted_rows = []

    # Iterate over each unique gene
    for gene in df['gene_name'].unique():
        # Extract rows for the current gene
        gene_rows = df[df['gene_name'] == gene]
        
        # Append gene name to formatted_rows
        formatted_rows.append([gene, '', '', ''])  # Empty strings for spacing
        
        # Append each transcript (pb_id) and its CPM values
        for _, row in gene_rows.iterrows():
            formatted_rows.append(['', row['pb_id'], row['cpm_WT'], row['cpm_M']])
        
        # Calculate and append the total row for this gene
        total_cpm_WT = gene_rows['cpm_WT'].sum()
        total_cpm_M = gene_rows['cpm_M'].sum()
        formatted_rows.append(['Total', '', total_cpm_WT, total_cpm_M])

    # Convert formatted_rows to a DataFrame
    formatted_df = pd.DataFrame(formatted_rows, columns=['Gene', 'Transcript', 'WT_cpm', 'M_cpm'])

    # Save the formatted DataFrame to a CSV file
    formatted_df.to_csv(output_file, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Format CPM table by gene and transcript.")
    parser.add_argument("input_file", help="Path to the input CSV file")
    parser.add_argument("output_file", help="Path to the output CSV file")

    args = parser.parse_args()

    # Run the formatting function with the provided arguments
    format_table(args.input_file, args.output_file)
