import pandas as pd

# Load your existing summary table
summary_table_path = '18_LRP_summary/18_transcript_expression_fractional_abundance.csv'  # Update path as needed
summary_table = pd.read_csv(summary_table_path, sep=",")  # Use the appropriate delimiter

# Ensure relevant columns are present
required_columns = ['gene_name', 'pb_id', 'cpm_WT', 'cpm_M']
missing_columns = [col for col in required_columns if col not in summary_table.columns]
if missing_columns:
    raise ValueError(f"Missing columns in summary table: {missing_columns}")

# Rename columns for clarity
summary_table.rename(columns={
    'gene_name': 'Gene',
    'pb_id': 'Transcript',
    'cpm_WT': 'WT_cpm',
    'cpm_M': 'Q157R_cpm'
}, inplace=True)

# Calculate delta_cpm
summary_table['delta_cpm'] = summary_table['Q157R_cpm'] - summary_table['WT_cpm']

# Select the desired columns
transcript_cpm = summary_table[['Gene', 'Transcript', 'WT_cpm', 'Q157R_cpm', 'delta_cpm']]

# Save to tab-delimited file
transcript_cpm.to_csv('transcript_cpm.csv', index=False, sep="\t")  # Save as tab-delimited

print("transcript_cpm.csv has been created successfully.")
