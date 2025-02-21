import pandas as pd
import argparse

def calculate_isoform_fractions(input_file):
    """
    Calculate fractional abundance for each isoform within its gene
    """
    # Read the input file
    df = pd.read_csv(input_file, sep='\t')
    
    # List of CPM columns
    cpm_columns = ['X504_Q157R', 'A258_Q157R', 'A309_Q157R', 
                   'V335_WT', 'V334_WT', 'A310_WT']
    
    # Calculate total CPM per gene for each sample
    gene_totals = df.groupby('Gene')[cpm_columns].transform('sum')
    
    # Calculate fractions (avoiding division by zero)
    fraction_df = df.copy()
    for col in cpm_columns:
        fraction_df[col] = df[col].div(gene_totals[col]).fillna(0)
    
    # Select and order columns for output
    output_columns = ['Isoform_index', 'Gene', 'Transcript', 'Transcript_name'] + cpm_columns
    fraction_df = fraction_df[output_columns]
    
    # Round fractions to 4 decimal places
    fraction_df[cpm_columns] = fraction_df[cpm_columns].round(4)
    
    return fraction_df

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Calculate isoform fractional abundance.')
    
    parser.add_argument('-i', '--input',
                        required=True,
                        help='Path to input file (isoform CPM table)')
    
    parser.add_argument('-o', '--output',
                        required=True,
                        help='Path for output file')
    
    parser.add_argument('--min-expression',
                        type=float,
                        default=0,
                        help='Minimum gene CPM to include in analysis (default: 0)')
    
    return parser.parse_args()

def main():
    """Main function to process the file and generate output"""
    # Parse command line arguments
    args = parse_arguments()
    
    try:
        # Read and process the input file
        print(f"Processing input file: {args.input}")
        fraction_df = calculate_isoform_fractions(args.input)
        
        # Save the results
        print(f"Saving isoform fractions to: {args.output}")
        fraction_df.to_csv(args.output, sep='\t', index=False)
        
        print("Isoform fraction table generated successfully!")
        
        # Print some summary statistics
        total_genes = len(fraction_df['Gene'].unique())
        total_isoforms = len(fraction_df)
        print(f"\nSummary:")
        print(f"Total genes processed: {total_genes}")
        print(f"Total isoforms processed: {total_isoforms}")
        print(f"Average isoforms per gene: {total_isoforms/total_genes:.2f}")
        
    except FileNotFoundError as e:
        print(f"Error: Could not find file - {e}")
        return 1
    except Exception as e:
        print(f"Error: An unexpected error occurred - {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())