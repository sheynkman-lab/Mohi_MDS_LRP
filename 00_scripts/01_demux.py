import sys
import os
import pandas as pd

def add_sample_identifier(file_path, sample_id):
    # Load the Iso-Seq output file (assuming it's in a standard format such as GFF or GTF)
    df = pd.read_csv(file_path, sep='\t', header=None)
    
    # Assuming the PB accession number is in the first column (modify as needed)
    df[0] = df[0].apply(lambda x: f"{sample_id}_{x}")
    
    # Save the modified file
    output_file = f"{sample_id}_modified_{os.path.basename(file_path)}"
    df.to_csv(output_file, sep='\t', index=False, header=False)
    
    return output_file

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 add_sample_identifier.py <iso_seq_output_file> <sample_id>")
        sys.exit(1)

    iso_seq_output_file = sys.argv[1]
    sample_id = sys.argv[2]

    modified_output = add_sample_identifier(iso_seq_output_file, sample_id)
    print(f"Modified Iso-Seq output for {sample_id}: {modified_output}")
