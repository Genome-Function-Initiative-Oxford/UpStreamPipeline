#!/usr/bin/env python

#---------------------------------------------------------------------------
# CALIBRATED ChIP-seq ANALYSIS: DownSampling Calculations
# Emily Georgiades, Simone G Riva
# Updated May 2022
#---------------------------------------------------------------------------

import pandas as pd
import warnings, os, glob, sys

warnings.filterwarnings('ignore')

config_name = sys.argv[1]
input_provided = sys.argv[2]

read_count_files = config_name+os.sep+"results/07_read_counts/*_readCounts.txt"
# Load the textfiles containing read counts:
rcs = []
for r in glob.glob(read_count_files):
    tmp_rc = pd.read_csv(r, sep=' ', header=None)
    tmp_rc.columns = ["SAMPLE", "TOTAL_READS", "GENOME_READS", "SPIKEIN_READS"]
    rcs.append(tmp_rc)
read_counts = pd.concat(rcs, axis=0)
read_counts.reset_index(inplace=True, drop=True)

# Load the textfiles containing read counts:

cond_file_list = pd.read_csv(config_name+os.sep+"results/00_fastq_home_dir/samples_pairing.csv", sep="\t", header=None)[0].tolist()
if input_provided=="True":
    cond_input_file_list = cond_file_list[0::2]
else:
    cond_input_file_list = cond_file_list

cond = []
if input_provided=="True":
    for i in read_counts['SAMPLE']:
        if i in cond_input_file_list:
            cond.append("input")
        else:
            cond.append("ChIP")
    read_counts['TYPEOF'] = cond
else:
    read_counts['TYPEOF'] = "ChIP"

# Filter for the rows containing ChIP samples (rather than inputs controls)
# Input samples must have "input" in sample name.
sample_counts = read_counts[read_counts['TYPEOF'] != "input"]

# Calculate ratios:
sample_counts['RATIO_GENOME_UNIQ']    = (sample_counts['GENOME_READS'])/(sample_counts['TOTAL_READS'])
sample_counts['RATIO_SPIKEIN_UNIQ']   = sample_counts['SPIKEIN_READS']/sample_counts['TOTAL_READS']
sample_counts['RATIO_SPIKEINvGENOME'] = sample_counts['SPIKEIN_READS']/sample_counts['GENOME_READS']
sample_counts['SPIKEIN_NORM']         = min(sample_counts['SPIKEIN_READS'])/sample_counts['SPIKEIN_READS'] 

# Filter for the rows containing input controls
# Input samples must have "input" in sample name.
if input_provided=="True":
    input_counts = read_counts[read_counts['TYPEOF'] == "input"]
    # Calculate ratios:
    input_counts['RATIO_GENOME_UNIQ']    = input_counts['GENOME_READS']/input_counts['TOTAL_READS']
    input_counts['RATIO_SPIKEIN_UNIQ']   = input_counts['SPIKEIN_READS']/input_counts['TOTAL_READS']
    input_counts['RATIO_SPIKEINvGENOME'] = input_counts['SPIKEIN_READS']/input_counts['GENOME_READS']
    input_counts['SPIKEIN_NORM']         = min(input_counts['SPIKEIN_READS'])/input_counts['SPIKEIN_READS'] 

    renaming = pd.read_csv(config_name+os.sep+"results/00_fastq_home_dir/samples_pairing.csv", sep='\t', names=['sample', 'name'])
    renaming_dict = {}
    for i, j in zip(renaming['sample'], renaming['name']):
        renaming_dict[i] = j
    new_sample = []
    for i in sample_counts['SAMPLE']:
        new_sample.append(renaming_dict[i])
    sample_counts['SAMPLE'] = new_sample
    new_sample = []
    for i in input_counts['SAMPLE']:
        new_sample.append(renaming_dict[i])
    input_counts['SAMPLE'] = new_sample

    # Re-merge the sample and input rows
    merged                    = pd.merge(sample_counts, input_counts, on="SAMPLE")
else:
    merged = sample_counts

new_merged = merged.iloc[:,0:9]


if input_provided=="True":
    new_merged['INPUT_RATIO'] = merged['RATIO_SPIKEINvGENOME_y']

    new_merged.columns        = ['SAMPLE', 'TOTAL_READS',
                                 'GENOME_READS','SPIKEIN_READS',
                                 'TYPEOF', 'RATIO_GENOME_UNIQ',
                                 'RATIO_SPIKEIN_UNIQ','RATIO_SPIKEINvGENOME',
                                 'SPIKEIN_NORM','INPUT_RATIO']
else:
    new_merged.columns        = ['SAMPLE', 'TOTAL_READS',
                                 'GENOME_READS','SPIKEIN_READS',
                                 'TYPEOF', 'RATIO_GENOME_UNIQ',
                                 'RATIO_SPIKEIN_UNIQ','RATIO_SPIKEINvGENOME',
                                 'SPIKEIN_NORM']

if input_provided=="True":
    new_merged['DOWNSAMPLE_FRACTION']   = new_merged['INPUT_RATIO']*new_merged['SPIKEIN_NORM']
    new_merged['DOWNSAMPLE_FACTOR']     = new_merged['DOWNSAMPLE_FRACTION']/max(new_merged['DOWNSAMPLE_FRACTION'])*0.9999
    new_merged['READS_POST_DOWNSAMPLE'] = (new_merged['GENOME_READS']*new_merged['DOWNSAMPLE_FACTOR']).astype(int)
else:
    new_merged['DOWNSAMPLE_FACTOR'] = new_merged['SPIKEIN_NORM']/max(new_merged['SPIKEIN_NORM'])*0.9999
    # Changed downsampling factor to mm39/total ratio:
    new_merged['READS_POST_DOWNSAMPLE'] = (new_merged['GENOME_READS']*new_merged['RATIO_GENOME_UNIQ']).astype(int)

if input_provided=="True":
    renaming_dict_2 = {}
    for i, j in zip(renaming['sample'], renaming['name']):
        if i != j:
            renaming_dict_2[j] = i
            
    new_merged_2 = new_merged.copy()
    new_sample = []
    for i in new_merged_2['SAMPLE']:
        new_sample.append(renaming_dict_2[i])
    new_merged_2['SAMPLE'] = new_sample
    new_merged_2['TYPEOF'] = 'input'

    merged = pd.concat([new_merged, new_merged_2])
    merged.reset_index(inplace=True, drop=True)

else:
    merged = new_merged
    
# Export results to textfile
if not os.path.exists(config_name+os.sep+'results/08_downsampling_factor'):
    os.makedirs(config_name+os.sep+'results/08_downsampling_factor')
merged.to_csv(config_name+os.sep+'results/08_downsampling_factor/downsamplingCalculations.txt', sep='\t', index=False)
