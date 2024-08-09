# Import Modules 
import numpy as np 
import pandas as pd
import argparse
import os 

# Define Functions
def sqtab(sqanti_out, ensg_to_gene, enst_to_isoname):
    """
    Sorts data from Sqanti output 

    Note: We are not considering genes from sqanti output like ENSG00000242861.1_ENSG00000196187.12
    """

    # Import Data
    cols = ['isoform', 'length', 'structural_category','associated_gene','associated_transcript','subcategory', 'FL'] 
    data = pd.read_csv(sqanti_out, delimiter="\t", usecols = cols)
    data.columns = ['pb_acc', 'len', 'cat', 'gene','transcript', 'cat2', 'fl_cts']

    # Map categories to acronyms and filter out anything that is not FSM, ISM, NNC or NIC
    data.replace({"novel_not_in_catalog":"NNC","novel_in_catalog":"NIC","incomplete-splice_match":"ISM","full-splice_match":"FSM"}, inplace = True)
    fdata = data[data.cat.isin(['FSM', 'ISM', 'NNC', "NIC"])]

    # Normalize fl_cts to cpm
    fdata['cpm'] = 1000000*fdata['fl_cts']/fdata['fl_cts'].sum(skipna=True)

    # Map gene -> gene_name
    gen_name = pd.read_csv(ensg_to_gene, delimiter="\t", header=None)
    gdict = pd.Series(gen_name.loc[:,1].values,index=gen_name.loc[:,0]).to_dict()
    df = fdata[['gene']]
    fdata['gene'] = fdata['gene'].map(gdict).fillna(df['gene'])

    # Drop cases like ENSG00000242861.1_ENSG00000196187.12 
    fdata.drop(fdata[fdata['gene'] == df['gene']].index, inplace=True)

    # Map enst -> isoname
    trans = pd.read_csv(enst_to_isoname, delimiter="\t", header=None)
    tdict = pd.Series(trans.loc[:,1].values, index=trans.loc[:,0]).to_dict()
    df2 = fdata[['transcript']]
    fdata['transcript'] = fdata['transcript'].map(tdict).fillna(df2['transcript'])
    print("Isoform Table from sqanti output has been prepared")
    return fdata

def main():

    # Main Code 
    parser = argparse.ArgumentParser(description='Process transcriptome related input file locations')
    parser.add_argument('--sq_out', '-s', action='store', dest='sqanti_out', help = 'input : Sqanti Classification output location')
    parser.add_argument('--ensg_to_gene', '-gmap', action='store', dest='ensg_to_gene', help='ENSG -> Gene Map file location')
    parser.add_argument('--enst_to_isoname', '-imap', action='store', dest='enst_to_isoname', help='ENST -> Isoname Map file location')
    parser.add_argument('--odir', '-o', action='store', dest='odir', help='Output Directory', default=None)
    results = parser.parse_args()

    # If results folder does not exist, make it
    odir = results.odir
    if odir is not None and not os.path.exists(odir):
        os.mkdir(odir)
    else:
        odir = ''

    # Make Sqanti Isoform Table and output to a TSV
    sq_isotab = sqtab(results.sqanti_out, results.ensg_to_gene, results.enst_to_isoname)
    # sq_isotab['gene'] = sq_isotab['gene'].str.replace('_','-')
    sq_isotab.to_csv(os.path.join(odir, 'sqanti_isoform_info.tsv'), sep="\t", index= False, na_rep='0')

    # Make PB-Gene reference table
    pb_gene = sq_isotab[['pb_acc','gene']]
    # pb_gene.columns = ['isoform','gene']
    pb_gene = pb_gene.drop_duplicates()
    pb_gene.to_csv(os.path.join(odir, 'pb_gene.tsv'), sep="\t", index= False, na_rep='0')

if __name__ == "__main__":
    main()
