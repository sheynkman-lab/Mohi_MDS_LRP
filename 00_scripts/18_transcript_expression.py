import pandas as pd
import argparse

def parse_bed(file_path):
    data = []
    with open(file_path, 'r') as file:
        for line_number, line in enumerate(file, start=1):
            fields = line.strip().split('\t')
            chrom, start, end, transcript_info, score, strand, thickStart, thickEnd, itemRgb, blockCount, blockSizes, blockStarts = fields
            
            # Split transcript_info into gene_name, transcript_id, and cpm
            try:
                gene_name, transcript_id, cpm = transcript_info.split('|')
                cpm = float(cpm)
            except ValueError:
                print(f"Unexpected format in transcript_info on line {line_number}: {transcript_info}")
                continue  # Skip problematic lines
            
            data.append({
                'chrom': chrom,
                'start': int(start),
                'end': int(end),
                'gene_name': gene_name,
                'transcript_id': transcript_id,
                'cpm': cpm,
                'strand': strand
            })
    
    df = pd.DataFrame(data)
    return df

def aggregate_cpm_by_location(df):
    return df.groupby(['chrom', 'start', 'end', 'gene_name', 'transcript_id', 'strand'])['cpm'].sum().reset_index()

def calculate_fractional_abundance(df):
    gene_totals = df.groupby('gene_name')['cpm'].sum().reset_index()
    gene_totals.rename(columns={'cpm': 'total_cpm'}, inplace=True)
    df = df.merge(gene_totals, on='gene_name')
    df['fractional_abundance'] = df['cpm'] / df['total_cpm']
    return df

def compare_samples(sample1_bed, sample2_bed, output_file):
    df1 = parse_bed(sample1_bed)
    df2 = parse_bed(sample2_bed)
    
    agg_df1 = aggregate_cpm_by_location(df1)
    agg_df2 = aggregate_cpm_by_location(df2)
    
    agg_df1 = calculate_fractional_abundance(agg_df1)
    agg_df2 = calculate_fractional_abundance(agg_df2)
    
    merged_df = pd.merge(agg_df1, agg_df2, on=['chrom', 'start', 'end', 'strand'], suffixes=('_sample1', '_sample2'), how='outer')
    
    merged_df['gene_name'] = merged_df['gene_name_sample1'].combine_first(merged_df['gene_name_sample2'])
    merged_df['transcript_id'] = merged_df['transcript_id_sample1'].combine_first(merged_df['transcript_id_sample2'])
    merged_df['cpm_difference'] = merged_df['cpm_sample1'].fillna(0) - merged_df['cpm_sample2'].fillna(0)
    
    result_df = merged_df[['chrom', 'start', 'end', 'gene_name', 'transcript_id', 'strand', 
                           'cpm_sample1', 'cpm_sample2', 'cpm_difference', 
                           'fractional_abundance_sample1', 'fractional_abundance_sample2']]
    
    result_df.to_csv(output_file, index=False)
    print(f"Output saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compare transcript expression between two samples using BED files and calculate fractional abundances.")
    parser.add_argument('sample1_bed', type=str, help="Path to the BED file for sample 1.")
    parser.add_argument('sample2_bed', type=str, help="Path to the BED file for sample 2.")
    parser.add_argument('output_file', type=str, help="Path to the output CSV file.")
    
    args = parser.parse_args()
    compare_samples(args.sample1_bed, args.sample2_bed, args.output_file)
