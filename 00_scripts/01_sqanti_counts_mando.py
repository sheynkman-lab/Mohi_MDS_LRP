import pandas as pd
import sys

def reformat_counts(input_file, output_file, sample_order):
    # Load the input file
    df = pd.read_csv(input_file, sep='\t')

    # Print the columns for debugging
    print(f"Columns in the input file: {df.columns.tolist()}")

    # Drop the 'Gene' column
    if 'Gene' in df.columns:
        df = df.drop(columns=['Gene'])
        print("Dropped 'Gene' column.")
    else:
        print("No 'Gene' column found to drop.")

    # Remove any 'Unnamed' columns or excess columns
    df = df.loc[:, ~df.columns.str.contains('^Unnamed|Unnamed:')]

    # Check the new column count
    print(f"Columns after processing: {df.columns.tolist()}")

    # Ensure the number of sample columns matches the number of provided sample names
    if len(df.columns) != (1 + len(sample_order)):
        raise ValueError(f"Length mismatch: Input file has {len(df.columns)} columns, "
                         f"but expected {1 + len(sample_order)} based on the sample names provided.")

    # Rename the sample columns in the order provided from the command line
    df.columns = ['Isoform'] + sample_order

    # Extract the 'Isoform' column as the new 'id' column
    df['id'] = df['Isoform']

    # Select and rearrange the columns
    df_final = df[['id'] + sample_order]

    # Convert counts to float values
    df_final.iloc[:, 1:] = df_final.iloc[:, 1:].astype(float)

    # Save the output file as CSV
    df_final.to_csv(output_file, index=False)

    print(f"File converted successfully and saved to {output_file}")

if __name__ == "__main__":
    # Command-line arguments: input_file, output_file, sample columns
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    sample_order = sys.argv[3:]

    reformat_counts(input_file, output_file, sample_order)
