import pandas as pd
import re
import argparse

def extract_pb_numbers(isoform):
    """Extract gene and isoform numbers from PB.XX.YY format"""
    match = re.match(r'PB\.(\d+)\.(\d+)', isoform)
    if match:
        gene_num, iso_num = match.groups()
        return int(gene_num), f"{gene_num}.{iso_num}"
    return None, None

def calculate_cpm(fl_count, total_fl):
    """Calculate CPM from FL count"""
    if total_fl == 0:
        return 0
    return (fl_count / total_fl) * 1_000_000

def process_sqanti_file(sqanti_file):
    """Process SQANTI classification file"""
    # Read the SQANTI classification file
    sqanti_df = pd.read_csv(sqanti_file, sep='\t')
    
    # Calculate CPM for each sample using FL column
    sample_cols = ['X504_Q157R', 'A258_Q157R', 'A309_Q157R', 'V335_WT', 'V334_WT', 'A310_WT']
    fl_cols = ['FL.BioSample_1', 'FL.BioSample_2', 'FL.BioSample_3', 'FL.BioSample_4', 'FL.BioSample_5', 'FL.BioSample_6']
    
    # Calculate CPM for each sample
    for new_col, fl_col in zip(sample_cols, fl_cols):
        # Calculate total FL for this sample
        total_fl = sqanti_df[fl_col].sum()
        # Calculate CPM
        sqanti_df[new_col] = sqanti_df[fl_col].apply(lambda x: calculate_cpm(x, total_fl))
    
    # Extract gene and isoform information for indexing
    sqanti_df['Gene_index'], sqanti_df['Isoform_index'] = zip(*sqanti_df['isoform'].map(extract_pb_numbers))
    
    return sqanti_df

def process_gtf_files(wt_gtf, mutant_gtf):
    """Process GTF files to get transcript information"""
    def parse_gtf(file_path):
        transcripts = []
        with open(file_path, 'r') as f:
            for line in f:
                if 'transcript_id' in line:
                    match = re.search(r'transcript_id "([^|]+)\|([^|]+)\|([^"]+)"', line)
                    if match:
                        gene, pb_id, cpm = match.groups()
                        transcripts.append({
                            'gene': gene,
                            'isoform': pb_id,
                            'cpm': float(cpm)
                        })
        return pd.DataFrame(transcripts).drop_duplicates()
    
    wt_df = parse_gtf(wt_gtf)
    mutant_df = parse_gtf(mutant_gtf)
    return wt_df, mutant_df

def process_isoform_info(tsv_file):
    """Process isoform information file"""
    return pd.read_csv(tsv_file, sep='\t')

def create_final_table(sqanti_df, isoform_df):
    """Create final formatted table"""
    # Merge SQANTI data with isoform information
    result = pd.merge(
        sqanti_df,
        isoform_df[['pb_acc', 'gene', 'transcript', 'cat', 'cat2']],
        left_on='isoform',
        right_on='pb_acc',
        how='inner'
    )
    
    # Determine Known/Novel status
    result['K/N'] = result['cat'].apply(lambda x: 'K' if x in ['FSM', 'ISM'] else 'N')
    
    # Format final table
    final_columns = [
        'Gene_index', 'Isoform_index', 'gene', 'associated_transcript',
        'transcript', 'K/N', 'X504_Q157R', 'A258_Q157R', 'A309_Q157R',
        'V335_WT', 'V334_WT', 'A310_WT'
    ]
    
    # Rename columns to match desired output
    column_mapping = {
        'gene': 'Gene',
        'associated_transcript': 'Transcript',
        'transcript': 'Transcript_name'
    }
    
    final_table = result[final_columns].rename(columns=column_mapping)
    final_table = final_table.sort_values(['Gene_index', 'Isoform_index'])
    
    return final_table

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Process gene expression data files.')
    
    parser.add_argument('-s', '--sqanti', 
                        required=True,
                        help='Path to SQANTI classification file (.txt)')
    
    parser.add_argument('-w', '--wildtype',
                        required=True,
                        help='Path to wild-type GTF file')
    
    parser.add_argument('-m', '--mutant',
                        required=True,
                        help='Path to mutant GTF file')
    
    parser.add_argument('-i', '--isoform',
                        required=True,
                        help='Path to isoform information file (.tsv)')
    
    parser.add_argument('-o', '--output',
                        required=True,
                        help='Path for output file (.tsv)')
    
    return parser.parse_args()

def main():
    """Main function to process all files and generate output"""
    # Parse command line arguments
    args = parse_arguments()
    
    try:
        # Process input files
        print(f"Processing SQANTI file: {args.sqanti}")
        sqanti_df = process_sqanti_file(args.sqanti)
        
        print(f"Processing isoform information: {args.isoform}")
        isoform_df = process_isoform_info(args.isoform)
        
        # Create and save final table
        print("Creating final table...")
        final_table = create_final_table(sqanti_df, isoform_df)
        
        print(f"Saving output to: {args.output}")
        final_table.to_csv(args.output, sep='\t', index=False)
        
        print("Table generated successfully!")
        
    except FileNotFoundError as e:
        print(f"Error: Could not find file - {e}")
        return 1
    except Exception as e:
        print(f"Error: An unexpected error occurred - {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())