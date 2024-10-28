import csv

# Define input and output files
input_file = '01_mandalorion/fl_count_for_sqanti3.csv'
q157r_file = '01_mandalorion/Q157R_fl_count_for_sqanti3.csv'
wildtype_file = '01_mandalorion/WT_fl_count_for_sqanti3.csv'

# Open the input file and create two output files
with open(input_file, 'r') as infile, \
     open(q157r_file, 'w', newline='') as q157r_out, \
     open(wildtype_file, 'w', newline='') as wildtype_out:

    # Read the input file
    reader = csv.reader(infile)
    
    # Create CSV writers for the output files
    q157r_writer = csv.writer(q157r_out)
    wildtype_writer = csv.writer(wildtype_out)
    
    # Write headers for both output files
    header = next(reader)  # Read the header row
    q157r_writer.writerow([header[0], header[1], header[2], header[3]])  # Keep only sample 3, 4, 5 for Q157R
    wildtype_writer.writerow([header[0], header[4], header[5], header[6]])  # Keep only sample 6, 7, 8 for Wild Type
    
    # Process each row of the file and write to the appropriate output file
    for row in reader:
        # Check if all Q157R sample values are 0
        q157r_samples = [float(row[1]), float(row[2]), float(row[3])]
        if not all(value == 0.0 for value in q157r_samples):
            # Write to the Q157R file if not all values are 0
            q157r_writer.writerow([row[0], row[1], row[2], row[3]])

        # Check if all Wild Type sample values are 0
        wildtype_samples = [float(row[4]), float(row[5]), float(row[6])]
        if not all(value == 0.0 for value in wildtype_samples):
            # Write to the Wild Type file if not all values are 0
            wildtype_writer.writerow([row[0], row[4], row[5], row[6]])
