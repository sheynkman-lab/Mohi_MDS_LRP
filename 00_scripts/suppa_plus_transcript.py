import pandas as pd

# Load the transformed SUPPA output and the transcript CPM data
transformed_suppa_path = '18_LRP_summary/transformed_suppa_output.csv'  # Update the path as needed
transcript_cpm_path = '18_LRP_summary/transcript_cpm.csv'  # Update the path as needed

transformed_suppa_data = pd.read_csv(transformed_suppa_path, sep="\t")
transcript_cpm_data = pd.read_csv(transcript_cpm_path, sep="\t")

# Check the first few rows of each DataFrame for verification
print("Transformed SUPPA data:")
print(transformed_suppa_data.head())
print("\nTranscript CPM data:")
print(transcript_cpm_data.head())

# Split the 'Alternative_splice' column to get individual transcript IDs
transformed_suppa_data['Transcript'] = transformed_suppa_data['Alternative_splice'].str.split(';').str[1]

# Merge the two DataFrames on the 'Transcript' column
merged_data = pd.merge(transcript_cpm_data, transformed_suppa_data, on='Transcript', how='left')

# Select the desired columns for output
output_columns = [
    'Gene', 
    'Transcript', 
    'WT_cpm', 
    'Q157R_cpm', 
    'delta_cpm', 
    'Alternative_splice', 
    'WT_psi', 
    'Q157R_psi', 
    'delta_psi'
]
final_data = merged_data[output_columns]

# Save the combined data to a new file
final_data.to_csv('18_LRP_summary/AS_transcript_combined.csv', index=False, sep="\t")  # Save as tab-delimited

print("18_LRP_summary/AS_transcript_combined.csv has been created successfully.")
