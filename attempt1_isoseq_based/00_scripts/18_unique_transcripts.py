import pandas as pd
import argparse

def parse_bed(file_path):
    data = []
    with open(file_path, 'r') as file:
        for line in file:
            fields = line.strip().split('\t')
            chrom, start, end, transcript_info, score, strand, thickStart, thickEnd, itemRgb, blockCount, blockSizes, blockStarts = fields
            
            # Extract gene name, PB ID, and CPM
            gene_name, pb_id, cpm = transcript_info.split('|')
            cpm = float(cpm)
            
            data.append({
                'chrom': chrom,
                'start': int(start),
                'end': int(end),
                'gene_name': gene_name,
                'pb_id': pb_id,
                'cpm': cpm,
                'strand': strand
            })
    
    df = pd.DataFrame(data)
    return df

def aggregate_cpm_by_location(df):
    return df.groupby(['chrom', 'start', 'end', 'gene_name', 'pb_id', 'strand'])['cpm'].sum().reset_index()

def calculate_fractional_abundance(df):
    # Calculate total CPM for each gene
    gene_totals = df.groupby('gene_name')['cpm'].sum().reset_index()
    gene_totals.rename(columns={'cpm': 'total_cpm'}, inplace=True)
    
    # Merge gene totals with original dataframe
    df = df.merge(gene_totals, on='gene_name')
    
    # Calculate fractional abundance
    df['fractional_abundance'] = df['cpm'] / df['total_cpm']
    
    return df

def compare_samples(sample1_bed, sample2_bed, output_file):
    # Parse the BED files
    df1 = parse_bed(sample1_bed)
    df2 = parse_bed(sample2_bed)
    
    # Aggregate CPM by genomic location
    agg_df1 = aggregate_cpm_by_location(df1)
    agg_df2 = aggregate_cpm_by_location(df2)
    
    # Calculate fractional abundance for each sample
    agg_df1 = calculate_fractional_abundance(agg_df1)
    agg_df2 = calculate_fractional_abundance(agg_df2)
    
    # Merge the two aggregated DataFrames on genomic coordinates
    merged_df = pd.merge(agg_df1, agg_df2, on=['chrom', 'start', 'end', 'strand'], suffixes=('_sample1', '_sample2'), how='outer')
    
    # Filter to keep only transcripts present in sample 2 but not in sample 1
    sample2_only_df = merged_df[merged_df['pb_id_sample1'].isna()]
    
    # Initialize a counter for the unified transcript naming
    counter = 1

    # Function to assign a unified PB ID
    def assign_unified_pb_id(row):
        nonlocal counter
        unified_id = f"{row['gene_name_sample2']}PB{counter}"
        counter += 1
        return unified_id

    # Apply the unified PB ID assignment
    sample2_only_df['unified_pb_id'] = sample2_only_df.apply(assign_unified_pb_id, axis=1)
    
    # Select the relevant columns for the output
    result_df = sample2_only_df[['gene_name_sample2', 'unified_pb_id', 'pb_id_sample2']]
    result_df.columns = ['gene_name', 'unified_transcript_name', 'original_transcript_name']
    
    # Save the output to a CSV file
    result_df.to_csv(output_file, index=False)
    print(f"List of transcripts only present in sample 2 saved to {output_file}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Generate a list of transcripts only present in sample 2.")
    parser.add_argument('sample1_bed', type=str, help="Path to the BED file for sample 1.")
    parser.add_argument('sample2_bed', type=str, help="Path to the BED file for sample 2.")
    parser.add_argument('output_file', type=str, help="Path to the output CSV file.")
    
    args = parser.parse_args()
    
    # Run the comparison to get transcripts unique to sample 2
    compare_samples(args.sample1_bed, args.sample2_bed, args.output_file)
