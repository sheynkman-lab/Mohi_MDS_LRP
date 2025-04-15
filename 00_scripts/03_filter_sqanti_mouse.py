
#!/usr/bin/env python3
#%%
import argparse
import pandas as pd
import os  
import shutil
import re 
import logging
import gtfparse
from Bio import SeqIO

logging.basicConfig(filename='sqanti_filter.log', encoding='utf-8', level=logging.DEBUG)

def write_dropout_fasta(dropout_ids, input_fasta_path, output_fasta_path):
    with open(output_fasta_path, "w") as out_f:
        for record in SeqIO.parse(input_fasta_path, "fasta"):
            if record.id in dropout_ids:
                SeqIO.write(record, out_f, "fasta")

def write_dropout_gtf(dropout_ids, input_gtf_path, output_gtf_path):
    with open(input_gtf_path, "r") as in_gtf, open(output_gtf_path, "w") as out_gtf:
        for line in in_gtf:
            if any(tid in line for tid in dropout_ids):
                out_gtf.write(line)

def write_dropout_classification(dropout_ids, input_classification_path, output_classification_path):
    with open(input_classification_path, "r") as in_class, open(output_classification_path, "w") as out_class:
        header = in_class.readline()
        out_class.write(header)
        for line in in_class:
            if line.split("\t")[0] in dropout_ids:
                out_class.write(line)

structural_categories = {
    'strict': ['novel_not_in_catalog', 'novel_in_catalog',
               'incomplete-splice_match', 'full-splice_match'],
    'all': ['antisense', 'novel_not_in_catalog', 'novel_in_catalog',
            'incomplete-splice_match', 'full-splice_match', 'genic',
            'intergenic', 'fusion', 'genic_intron']
}

def string_to_boolean(string):
    if isinstance(string, bool):
        return string
    if string.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif string.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def filter_protein_coding(classification, protein_coding_filename, ensmusg_gene_filename):
    logging.info("Filtering for only protein coding genes")
    with open(protein_coding_filename, 'r') as file:
        protein_coding_genes = file.read().splitlines()
    ensmusg_gene = pd.read_table(ensmusg_gene_filename, header=None)
    ensmusg_gene.columns = ['gene_id', 'gene_name']
    ensmusg_gene = ensmusg_gene[ensmusg_gene['gene_name'].isin(protein_coding_genes)]
    protein_coding_gene_ids = set(ensmusg_gene['gene_id'])
    classification = classification[classification['associated_gene'].isin(protein_coding_gene_ids)]
    return classification

def filter_intra_polyA(classification, percent_polyA_downstream):
    logging.info("Filtering Intra PolyA")
    return classification[classification['perc_A_downstream_TTS'] <= percent_polyA_downstream]

def filter_rts_stage(classification):
    logging.info("Filtering RTS Stage")
    return classification[classification['RTS_stage'] == False]

def save_filtered_sqanti_gtf(gtf_file, filtered_isoforms, output_path):
    logging.info("Saving GTF")
    with open(gtf_file, "r") as ifile, open(output_path, "w") as ofile:
        for line in ifile:
            transcript = re.findall('transcript_id "([^"]*)"', line)[0]
            if transcript in filtered_isoforms:
                ofile.write(line)

def save_filtered_sqanti_fasta(fasta_file, filtered_isoforms, output_path):
    logging.info("Saving FASTA")
    filtered_sequences = []
    for record in SeqIO.parse(fasta_file, "fasta"):
        if record.id in filtered_isoforms:
            filtered_sequences.append(record)
    SeqIO.write(filtered_sequences, output_path, "fasta")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_dir', type=str, required=True,
                        help='Directory to write output files including dropouts')
    parser.add_argument("--sqanti_classification", dest='classification_file')
    parser.add_argument("--sqanti_corrected_gtf", dest="corrected_gtf")
    parser.add_argument("--sqanti_corrected_fasta", dest="corrected_fasta")
    parser.add_argument("--filter_protein_coding", default="yes")
    parser.add_argument("--filter_intra_polyA", default="yes")
    parser.add_argument("--filter_template_switching", default="yes")
    parser.add_argument("--protein_coding_genes", required=False)
    parser.add_argument("--ensmusg_gene", required=False)
    parser.add_argument("--percent_A_downstream_threshold", default=95, type=float)
    parser.add_argument("--structural_categories_level", default="strict")
    parser.add_argument("--minimum_illumina_coverage", type=int, default=3)

    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    is_protein_coding_filtered = string_to_boolean(args.filter_protein_coding)
    is_intra_polyA_filtered = string_to_boolean(args.filter_intra_polyA)
    is_template_switching_filtered = string_to_boolean(args.filter_template_switching)

    sqanti_df = pd.read_table(args.classification_file)
    sqanti_df = sqanti_df[~sqanti_df['associated_gene'].isna()]
    sqanti_df = sqanti_df[sqanti_df['associated_gene'].str.startswith("ENSMUSG")]

    original_ids = set(sqanti_df['isoform'])

    if is_protein_coding_filtered:
        sqanti_df = filter_protein_coding(sqanti_df, args.protein_coding_genes, args.ensmusg_gene)
    if is_intra_polyA_filtered:
        sqanti_df = filter_intra_polyA(sqanti_df, args.percent_A_downstream_threshold)
    if is_template_switching_filtered:
        sqanti_df = filter_rts_stage(sqanti_df)
    if args.structural_categories_level in structural_categories:
        sqanti_df = sqanti_df[sqanti_df['structural_category'].isin(structural_categories[args.structural_categories_level])]

    kept_ids = set(sqanti_df['isoform'])
    dropout_ids = original_ids - kept_ids

    print(f"Dropping {len(dropout_ids)} transcripts due to filtering...")

    base_class_name = os.path.basename(args.classification_file)
    base_fasta_name = os.path.basename(args.corrected_fasta)
    base_gtf_name = os.path.basename(args.corrected_gtf)

    # Save filtered files
    sqanti_df.to_csv(os.path.join(args.output_dir, f"filtered_{base_class_name}"), sep="\t", index=False)
    save_filtered_sqanti_gtf(args.corrected_gtf, kept_ids, os.path.join(args.output_dir, f"filtered_{base_gtf_name}"))
    save_filtered_sqanti_fasta(args.corrected_fasta, kept_ids, os.path.join(args.output_dir, f"filtered_{base_fasta_name}"))

    # Save dropout files
    write_dropout_classification(dropout_ids, args.classification_file,
                                  os.path.join(args.output_dir, f"dropout_{base_class_name}"))
    write_dropout_fasta(dropout_ids, args.corrected_fasta,
                        os.path.join(args.output_dir, f"dropout_{base_fasta_name}"))
    write_dropout_gtf(dropout_ids, args.corrected_gtf,
                      os.path.join(args.output_dir, f"dropout_{base_gtf_name}"))

if __name__ == "__main__":
    main()
