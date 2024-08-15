#!/usr/bin/env python3
import argparse
from Bio import SeqIO
import pandas as pd
import os

parser = argparse.ArgumentParser()
parser.add_argument('--name', action='store', dest='name')
parser.add_argument('--collapsed_fasta', action='store', dest='collapsed_fasta')
parser.add_argument('--classification', action='store', dest='classification')
parser.add_argument('--output_folder', action='store', dest='output_folder', default='.')
args = parser.parse_args()

if not os.path.exists(args.output_folder):
    os.makedirs(args.output_folder)

collapsed_accs = set()
for record in SeqIO.parse(args.collapsed_fasta, 'fasta'):
    collapsed_accs.add(record.id)

classification = pd.read_table(args.classification)
classification = classification[classification['isoform'].isin(collapsed_accs)]
classification.to_csv(os.path.join(args.output_folder, f'{args.name}_classification.5degfilter.tsv'), sep='\t', index=False)
