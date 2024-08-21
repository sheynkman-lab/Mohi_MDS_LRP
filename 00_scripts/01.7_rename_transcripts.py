import os
import re
import argparse

def escape_regex(string):
    # Escape special characters in regex patterns
    return re.escape(string)

def rename_accessions(file_path, old_new_mapping, output_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Escape regex patterns and perform replacements
    for old_acc, new_acc in old_new_mapping.items():
        escaped_old_acc = escape_regex(old_acc)
        content = re.sub(rf'\b{escaped_old_acc}\b', new_acc, content)

    with open(output_path, 'w') as file:
        file.write(content)

def generate_mapping(sample1_fasta, sample2_fasta):
    with open(sample1_fasta, 'r') as file1, open(sample2_fasta, 'r') as file2:
        sample1_headers = [line for line in file1 if line.startswith('>')]
        sample2_headers = [line for line in file2 if line.startswith('>')]

    sample1_accessions = [re.match(r'>\s*(\S+)', header).group(1) for header in sample1_headers]
    sample2_accessions = [re.match(r'>\s*(\S+)', header).group(1) for header in sample2_headers]

    # Create mappings for transcripts
    accession_mapping = dict(zip(sample2_accessions, sample1_accessions))

    # Handle missing transcripts by assigning new names
    max_transcript_number = max([int(re.search(r'PB\.(\d+)\.(\d+)', acc).group(2) or 0) for acc in sample1_accessions], default=0)
    
    for acc in sample2_accessions:
        if acc not in accession_mapping:
            base_name = re.match(r'(PB\.\d+)', acc).group(1)
            new_acc = f'{base_name}.{max_transcript_number + 1}'
            accession_mapping[acc] = new_acc
            max_transcript_number += 1

    return accession_mapping

def main():
    parser = argparse.ArgumentParser(description="Align PB accession numbers between two Iso-Seq3 samples.")
    parser.add_argument('--sample1_fasta', required=True, help="Path to the .fasta file for the patient sample")
    parser.add_argument('--sample2_fasta', required=True, help="Path to the .fasta file for the mother sample")
    parser.add_argument('--sample2_gff', required=True, help="Path to the .gff file for the mother sample")
    parser.add_argument('--sample2_abundance', required=True, help="Path to the abundance table for the mother sample")
    parser.add_argument('--sample1_out', required=True, help="Folder to save the patient files")
    parser.add_argument('--sample2_out', required=True, help="Folder to save the mother files")

    args = parser.parse_args()

    # Ensure the output folders exist
    os.makedirs(args.sample1_out, exist_ok=True)
    os.makedirs(args.sample2_out, exist_ok=True)

    # Generate mapping from mother to patient and handle missing transcripts
    accession_mapping = generate_mapping(args.sample1_fasta, args.sample2_fasta)

    # Define output file paths
    patient_fasta_output = os.path.join(args.sample1_out, os.path.basename(args.sample1_fasta))
    mother_fasta_output = os.path.join(args.sample2_out, os.path.basename(args.sample2_fasta))
    mother_gff_output = os.path.join(args.sample2_out, os.path.basename(args.sample2_gff))
    mother_abundance_output = os.path.join(args.sample2_out, os.path.basename(args.sample2_abundance))

    # Rename accessions in the .fasta, .gff, and abundance files for the mother sample
    rename_accessions(args.sample2_fasta, accession_mapping, mother_fasta_output)
    rename_accessions(args.sample2_gff, accession_mapping, mother_gff_output)
    rename_accessions(args.sample2_abundance, accession_mapping, mother_abundance_output)

    # Copy the patient .fasta file to the patient output folder (no renaming needed)
    os.rename(args.sample1_fasta, patient_fasta_output)

    print("Renaming complete. Accessions are now aligned between samples.")

if __name__ == "__main__":
    main()
