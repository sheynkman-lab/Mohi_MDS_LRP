import pandas as pd
import sys

# Check if the correct number of arguments is provided
if len(sys.argv) != 4:
    print("Usage: python script.py <sample1_gtf_path> <sample2_gtf_path> <output_path>")
    sys.exit(1)

# Command-line arguments for input and output paths
sample1_gtf_path = sys.argv[1]
sample2_gtf_path = sys.argv[2]
output_path = sys.argv[3]

# Function to extract CPM from GTF file, ensuring each transcript per gene is retained
def extract_cpm_from_gtf(gtf_path):
    data = {}
    with open(gtf_path, 'r') as file:
        for line in file:
            if line.strip() and not line.startswith('#'):
                fields = line.strip().split('\t')
                if fields[2] == 'exon':  # Only consider exons
                    gene_info = fields[8]
                    # Extract gene name and transcript info from attributes
                    gene_name = gene_info.split('gene_id "')[1].split('";')[0]
                    transcript_info = gene_info.split('transcript_id "')[1].split('";')[0]
                    
                    # Split the transcript info to get transcript ID and CPM
                    parts = transcript_info.split('|')
                    if len(parts) == 3:
                        transcript_id = parts[1]
                        cpm_value = float(parts[2])  # Convert CPM to float
                        
                        # Store only the first CPM occurrence per unique (gene_name, transcript_id)
                        if (gene_name, transcript_id) not in data:
                            data[(gene_name, transcript_id)] = cpm_value

    # Convert dictionary to DataFrame, retaining each unique transcript per gene
    df = pd.DataFrame([(k[0], k[1], v) for k, v in data.items()], columns=['Gene', 'Transcript', 'CPM'])
    return df

# Extract CPM data from Sample1 and Sample2 GTF files
sample1_cpm_df = extract_cpm_from_gtf(sample1_gtf_path).rename(columns={'CPM': 'sample1_cpm'})
sample2_cpm_df = extract_cpm_from_gtf(sample2_gtf_path).rename(columns={'CPM': 'sample2_cpm'})

# Merge data on Gene and Transcript to align sample1 and sample2 CPM values without renaming transcripts
cpm_df = pd.merge(sample1_cpm_df, sample2_cpm_df, on=['Gene', 'Transcript'], how='outer')

# Calculate delta_cpm
cpm_df['delta_cpm'] = cpm_df['sample2_cpm'] - cpm_df['sample1_cpm']

# Format delta_cpm to 5 decimal places
cpm_df['delta_cpm'] = cpm_df['delta_cpm'].round(5)

# Save final table to a tab-delimited file
cpm_df.to_csv(output_path, index=False, sep="\t")

print(f"{output_path} has been created successfully.")
