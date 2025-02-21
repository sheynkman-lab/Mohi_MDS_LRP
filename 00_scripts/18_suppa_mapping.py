import pandas as pd
import re

# File paths
suppa_file = '19_LRP_summary/19_transformed_suppa_output.csv'       # Update with your SUPPA results file path
gtf_files = {'mother': '08_rename_cds_to_exon/mother/Mot.cds_renamed_exon.gtf', 'patient': '08_rename_cds_to_exon/patient/Pat.cds_renamed_exon.gtf'}  # Update with your GTF file paths

# Read SUPPA events
suppa_df = pd.read_csv(suppa_file, sep='\t')

# Function to parse GTF and extract PB accession information
def parse_gtf(gtf_file):
    gtf_dict = {}
    with open(gtf_file, 'r') as gtf:
        for line in gtf:
            fields = line.strip().split('\t')
            if fields[2] == 'exon':
                chrom = fields[0]
                start = fields[3]
                end = fields[4]
                strand = fields[6]
                attributes = fields[8]
                
                # Extract gene_id and transcript_id
                gene_id = re.search(r'gene_id "(.*?)";', attributes).group(1)
                transcript_id = re.search(r'transcript_id "(.*?)";', attributes).group(1)
                
                # Build a key for the coordinates
                key = f"{gene_id}:{chrom}:{start}-{end}:{strand}"
                gtf_dict[key] = transcript_id
    return gtf_dict

# Parse both GTF files
gtf_data = {name: parse_gtf(path) for name, path in gtf_files.items()}

# Function to map SUPPA event to PB accession numbers from both files
def map_event_to_transcripts(event, gtf_data):
    gene_id, coords, strand = event.split(';')[0], event.split(':')[1:4], event.split(':')[-1]
    event_key = f"{gene_id}:{':'.join(coords)}:{strand}"
    
    # Look up the key in both GTF dictionaries
    mother_transcript = gtf_data['mother'].get(event_key, 'Not found')
    patient_transcript = gtf_data['patient'].get(event_key, 'Not found')
    
    return mother_transcript, patient_transcript

# Map each SUPPA event to corresponding transcripts and add new columns
suppa_df[['Mother_Transcript', 'Patient_Transcript']] = suppa_df['Alternative_splice'].apply(
    lambda x: pd.Series(map_event_to_transcripts(x, gtf_data))
)

# Save the updated SUPPA file with mapped transcript IDs
output_file = '19_LRP_summary/suppa_mapped_results.tsv'
suppa_df.to_csv(output_file, sep='\t', index=False)
print(f"Mapped SUPPA events saved to {output_file}")
