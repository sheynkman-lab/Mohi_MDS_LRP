import pandas as pd
import argparse

def parse_bed(file_path):
    data = []
    with open(file_path, 'r') as file:
        for line in file:
            fields = line.strip().split('\t')
            chrom, start, end, gene_info, score, strand, thickStart, thickEnd, itemRgb, blockCount, blockSizes, blockStarts = fields
            
            # Extract gene name and CPM
            gene_name, _, cpm = gene_info.split('|')
            cpm = float(cpm)
            
            data.append({
                'gene_name': gene_name,
                'cpm': cpm
            })
    
    df = pd.DataFrame(data)
    return df

def aggregate_cpm_by_gene(df):
    return df.groupby('gene_name')['cpm'].sum().reset_index()

def compare_samples(sample1_bed, sample2_bed, output_file):
    # Parse the BED files
    df1 = parse_bed(sample1_bed)
    df2 = parse_bed(sample2_bed)
    
    # Aggregate CPM by gene
    agg_df1 = aggregate_cpm_by_gene(df1)
    agg_df2 = aggregate_cpm_by_gene(df2)
    
    # Initialize a DataFrame for the output
    output_df = pd.DataFrame({
        'gene_name': agg_df1['gene_name'],
        'cpm_sample1': agg_df1['cpm'],
        'cpm_sample2': agg_df2['cpm'] if len(agg_df2) > 0 else 0,
    })
    
    # Calculate the difference in CPM
    output_df['cpm_difference'] = output_df['cpm_sample1'] - output_df['cpm_sample2']
    
    # Save the output to a CSV file
    output_df.to_csv(output_file, index=False)
    print(f"Output saved to {output_file}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Compare gene expression between two samples using BED files.")
    parser.add_argument('sample1_bed', type=str, help="Path to the BED file for sample 1.")
    parser.add_argument('sample2_bed', type=str, help="Path to the BED file for sample 2.")
    parser.add_argument('output_file', type=str, help="Path to the output CSV file.")
    
    args = parser.parse_args()
    
    # Run the comparison
    compare_samples(args.sample1_bed, args.sample2_bed, args.output_file)
