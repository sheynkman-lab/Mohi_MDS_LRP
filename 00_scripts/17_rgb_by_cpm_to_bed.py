#!/usr/bin/env python3

import pandas as pd
import argparse
import os

# Convert HEX to RGB
def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return ','.join(str(int(hex_color[i:i+2], 16)) for i in (0, 2, 4))

# Function to add RGB colors to the BED file
def add_rgb_colors(bed_file, major_color, minor_color, output_file):
    bed_names = ['chrom', 'chromStart', 'chromStop', 'acc_full', 'score', 'strand', 'thickStart', 'thickEnd', 'itemRGB', 'blockCount', 'blockSizes', 'blockStarts', 'additional_field1']
    bed = pd.read_table(bed_file, names=bed_names, comment='#')  # Load BED13 format

    # Ensure 'acc_full' is treated as a string and handle missing/incorrect formats
    bed['acc_full'] = bed['acc_full'].astype(str)

    # Extract gene names and CPM values from the 'acc_full' column, with error handling
    def extract_gene_and_cpm(acc):
        try:
            parts = acc.split('|')
            if len(parts) < 2:  # Make sure there are enough parts
                raise ValueError("Invalid acc_full format")
            gene = parts[0]
            cpm = float(parts[-1])
            return gene, cpm
        except (IndexError, ValueError):
            return None, 0.0

    bed[['gene', 'cpm']] = bed['acc_full'].apply(lambda x: pd.Series(extract_gene_and_cpm(x)))

    # Handle rows where gene extraction failed (optional: you can also drop them)
    bed = bed.dropna(subset=['gene'])

    # Find the major isoform for each gene
    bed['is_major'] = bed.groupby('gene')['cpm'].transform(max) == bed['cpm']

    # Assign RGB color based on major/minor isoform
    bed['rgb'] = bed['is_major'].apply(lambda is_major: major_color if is_major else minor_color)

    # Ensure coordinates and other numeric fields are integers
    int_columns = ['chromStart', 'chromStop', 'score', 'thickStart', 'thickEnd', 'blockCount']
    bed[int_columns] = bed[int_columns].astype(int)
    
    # Ensure blockSizes and blockStarts are properly formatted as integers
    bed['blockSizes'] = bed['blockSizes'].apply(lambda x: ','.join([str(int(float(i))) for i in x.split(',') if i]))
    bed['blockStarts'] = bed['blockStarts'].apply(lambda x: ','.join([str(int(float(i))) for i in x.split(',') if i]))

    # Select columns relevant for BED12 format and ensure all fields are in correct order
    filter_names = ['chrom', 'chromStart', 'chromStop', 'acc_full', 'score', 'strand', 'thickStart', 'thickEnd', 'rgb', 'blockCount', 'blockSizes', 'blockStarts']
    bed = bed[filter_names]

    # Write to the output BED file
    with open(output_file, 'w') as ofile:
        ofile.write(f'track name="{os.path.basename(output_file).replace(".bed12", "")}" itemRgb=On\n')
        bed.to_csv(ofile, sep='\t', index=None, header=None)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_bed", action="store", dest="input_bed", required=True, help="Input BED13 file with CPM data")
    parser.add_argument("--day", action="store", dest="day", required=True, choices=['WT', 'Q157R'], help="Specify the day for color coding")
    parser.add_argument("--output_file", action="store", dest="output_file", required=True, help="Output BED12 file with color coding")
    args = parser.parse_args()

    # HEX color codes for major and minor isoforms
    MAJOR_COLORS = {"WT": "#E99787", "Q157R": "#336B87"}
    MINOR_COLORS = {"WT": "#EED8C9", "Q157R": "#90AFC5"}

    # Convert HEX to RGB
    major_color_rgb = hex_to_rgb(MAJOR_COLORS[args.day])
    minor_color_rgb = hex_to_rgb(MINOR_COLORS[args.day])

    # Add RGB colors to the BED file
    add_rgb_colors(args.input_bed, major_color_rgb, minor_color_rgb, args.output_file)

if __name__ == "__main__":
    main()
