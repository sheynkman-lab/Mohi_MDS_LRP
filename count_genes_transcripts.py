import os
import re
import pandas as pd

from collections import defaultdict

# === CONFIGURATION ===
overview_file = "/project/sheynkman/projects/Mohi_MDS_LRP/Mohi_LRP_overview.xlsx"
pipeline_dir = "/project/sheynkman/projects/Mohi_MDS_LRP"
output_csv = "pb_accession_counts.csv"

# === LOAD FILE LIST FROM OVERVIEW ===
df = pd.read_excel(overview_file)
file_col = "Files used downstream"

# Clean and collect file names
file_list = set()
for val in df[file_col].dropna():
    parts = [p.strip() for p in str(val).split(",")]
    file_list.update(parts)

# Remove vague entries like "gtf", "fasta", etc.
known_extensions = {'.gtf', '.gff', '.tsv', '.txt', '.fasta', '.fa'}
file_list = {f for f in file_list if os.path.splitext(f)[1] in known_extensions}

# === SETUP REGEX ===
pb_regex = re.compile(r'PB\.\d+\.\d+')

# === SCAN PIPELINE DIRECTORY ===
results = []

for root, _, files in os.walk(pipeline_dir):
    for fname in files:
        if fname in file_list:
            full_path = os.path.join(root, fname)
            try:
                with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    matches = pb_regex.findall(content)
                    transcripts = set(matches)
                    genes = set(p.split('.')[0] + '.' + p.split('.')[1] for p in transcripts)
                    results.append({
                        "File": fname,
                        "Relative_Path": os.path.relpath(full_path, pipeline_dir),
                        "Gene_Count": len(genes),
                        "Transcript_Count": len(transcripts)
                    })
            except Exception as e:
                results.append({
                    "File": fname,
                    "Relative_Path": os.path.relpath(full_path, pipeline_dir),
                    "Gene_Count": "ERROR",
                    "Transcript_Count": "ERROR"
                })

# === OUTPUT RESULTS ===
result_df = pd.DataFrame(results)
result_df.to_csv(output_csv, index=False)
print(f"✅ Summary written to {output_csv}")
print(result_df)