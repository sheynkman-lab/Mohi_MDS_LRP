#!/usr/bin/env python3

import pandas as pd
import argparse
import os

def add_rgb_colors(bed_file, rgb, output_directory):
    bed_names = ['chrom', 'chromStart', 'chromStop', 'acc_full', 'score', 'strand', 'thickStart', 'thickEnd', 'itemRGB', 'blockCount', 'blockSizes', 'blockStarts']
    bed = pd.read_table(bed_file, names=bed_names)
    bed['rgb'] = rgb
    filter_names = ['chrom', 'chromStart', 'chromStop', 'acc_full', 'score', 'strand', 'thickStart', 'thickEnd', 'rgb', 'blockCount', 'blockSizes', 'blockStarts']
    bed = bed[filter_names]

    output_file = os.path.join(output_directory, 'shaded.bed12')
    with open(output_file, 'w') as ofile:
        ofile.write(f'track name="Patient" itemRgb=On\n')
        bed.to_csv(ofile, sep='\t', index=None, header=None)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_bed", action="store", dest="input_bed")
    parser.add_argument("--rgb", action="store", dest="rgb", default="0,0,140")
    parser.add_argument("--output_dir", action="store", dest="output_dir", help="output directory for the result files")
    args = parser.parse_args()
    add_rgb_colors(args.input_bed, args.rgb, args.output_dir)

if __name__ == "__main__":
    main()
