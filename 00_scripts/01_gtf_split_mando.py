import csv
import argparse

def load_isoforms_from_csv(file_path):
    """Load isoform IDs from the first column of the CSV file."""
    isoforms = set()
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header
        for row in reader:
            isoforms.add(row[0])  # Isoform ID is in the first column
    return isoforms

def filter_gtf_by_isoforms(gtf_file, wt_isoforms, q157r_isoforms, wt_output, q157r_output):
    """Filter the GTF file based on the isoform lists and write to the respective files."""
    with open(gtf_file, 'r') as infile, open(wt_output, 'w') as wt_outfile, open(q157r_output, 'w') as q157r_outfile:
        for line in infile:
            if line.startswith("#"):
                # Write header lines to both files
                wt_outfile.write(line)
                q157r_outfile.write(line)
            else:
                # Parse the transcript ID from the GTF line
                fields = line.strip().split('\t')
                attributes = fields[-1]
                transcript_id = attributes.split('transcript_id "')[1].split('"')[0]

                # Check if the isoform is in WT or Q157R sets and write accordingly
                if transcript_id in wt_isoforms:
                    wt_outfile.write(line)
                if transcript_id in q157r_isoforms:
                    q157r_outfile.write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Separate a combined GTF file into WT and Q157R GTF files based on isoform counts.")
    parser.add_argument("--gtf_file", required=True, help="Path to the combined GTF file.")
    parser.add_argument("--wt_csv", required=True, help="Path to the WT isoform count CSV file.")
    parser.add_argument("--q157r_csv", required=True, help="Path to the Q157R isoform count CSV file.")
    parser.add_argument("--wt_output", default="WT.gtf", help="Output file for WT GTF.")
    parser.add_argument("--q157r_output", default="Q157R.gtf", help="Output file for Q157R GTF.")
    
    args = parser.parse_args()

    # Load isoforms from CSV files
    wt_isoforms = load_isoforms_from_csv(args.wt_csv)
    q157r_isoforms = load_isoforms_from_csv(args.q157r_csv)

    # Filter the GTF file
    filter_gtf_by_isoforms(args.gtf_file, wt_isoforms, q157r_isoforms, args.wt_output, args.q157r_output)
