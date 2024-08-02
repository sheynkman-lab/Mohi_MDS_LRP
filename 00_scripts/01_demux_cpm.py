import pandas as pd
import argparse
import os 

def demux_cpm(demuxed_reads):
    total = demuxed_reads['fl_count'].sum()
    demuxed_reads['cpm'] = demuxed_reads['fl_count'] / total * 1000000
    return demuxed_reads

def cpm_grouped_barcode(demuxed_reads):
    demuxed_reads_barcode = (
        demuxed_reads
            .groupby(['pbid', 'barcode'])['cpm'].sum()
            .reset_index(name='cpm')
    )
    return demuxed_reads_barcode

def pivot_cpm_by_barcode(demuxed_barcode_total):
    demuxed_pivot_barcode = (
        demuxed_barcode_total
        .pivot(index='pbid', columns='barcode', values='cpm')
        .fillna(0)
    )
    return demuxed_pivot_barcode


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-ifile', '--demuxed_reads', action='store', dest='demuxed_reads')
    parser.add_argument('--name', action='store', dest='name')
    parser.add_argument('-odir', '--output_directory', action='store', dest='odir')
    args = parser.parse_args()

    demuxed_reads = pd.read_table(args.demuxed_reads)

    demuxed_reads = demux_cpm(demuxed_reads)
    demux_group_barcode = cpm_grouped_barcode(demuxed_reads)
    demux_cpm_barcode_pivot = pivot_cpm_by_barcode(demux_group_barcode)

    demuxed_reads.to_csv(os.path.join(args.odir, f'{args.name}.demuxed_reads_barcode_file.CPM.tsv'), sep='\t', index=False)
    demux_group_barcode.to_csv(os.path.join(args.odir, f'{args.name}.demuxed_reads_barcode.CPM.tsv'), sep='\t', index=False)
    demux_cpm_barcode_pivot.to_csv(os.path.join(args.odir, f'{args.name}.demuxed_reads_pivot_barcode.CPM.tsv'), sep='\t')



if __name__ == '__main__':
    main()