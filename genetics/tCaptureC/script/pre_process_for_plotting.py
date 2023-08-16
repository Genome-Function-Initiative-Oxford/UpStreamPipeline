#!/usr/bin/env
# coding: utf-8
############################################################
#### Data pre-processing for plotting using HiCPlotter
############################################################
# For more info on plotting see: [
# HiCPlotter manual: https://gitee.com/simonjyoung/HiCPlotter/raw/master/HiCPlotterManual.pdf 
# Emily Georgiades, May 2023

import pandas as pd
import numpy as np
from datetime import datetime
import sys, os, re

now = datetime.now()
dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
print("Script started:",dt_string)


############################################################
# Edit this to your region of interest (ROI) for plotting
############################################################
region                  = sys.argv[1]
sample_name             = sys.argv[2]
path_to_hic_results_dir = sys.argv[3]
path_to_plotting_dir    = sys.argv[4]
resolution              = sys.argv[5]
lowerPercentile         = int(sys.argv[6])
upperPercentile         = int(sys.argv[7])
output                  = sys.argv[8]
############################################################


nlog = open("%s/pre_processing_log.txt"%path_to_plotting_dir, 'w')
nlog.write("Choosen parameters:\n")
nlog.write("region=%s\n"%region)
nlog.write("sample_name=%s\n"%sample_name)
nlog.write("path_to_hic_results_dir=%s\n"%path_to_hic_results_dir)
nlog.write("path_to_plotting_dir=%s\n"%path_to_plotting_dir)
nlog.write("resolution=%s\n"%resolution)
nlog.write("lowerPercentile=%s\n"%lowerPercentile)
nlog.write("upperPercentile=%s\n"%upperPercentile)
nlog.write("output=%s\n\n"%output)


############################################################
# Do not edit below! 
############################################################

# Round the ROI values to nearest bin 
def custom_round(x, base=resolution):
    return int(float(base) * round(float(x)/float(base)))

# To ensure entire ROI is covered include 1 bin either side of the rounded values
region = re.split(r":|-", region)
region_chr   = region[0]
region_start = int(region[1])
region_end   = int(region[2])

regionBin = [region_chr, custom_round(region_start-int(resolution)),custom_round(region_end)+int(resolution)]
print("Region to plot:",regionBin)
nlog.write("##########\n")
nlog.write("##########\n")
nlog.write("##########\n\n")
nlog.write("Region to plot: %s\n"%regionBin)


# Import the bed file which states the bin numbers
bed = pd.read_csv('{}hic_results/matrix/{}/raw/{}/{}_ontarget_{}_abs.bed'.format(path_to_hic_results_dir,
                                                                                 sample_name,
                                                                                 resolution, 
                                                                                 sample_name,
                                                                                 resolution), sep='\t', header=None)
bed.columns = ('chr','start','end','bin')


# Identify the start and end bin for the ROI:
startBin = bed.loc[(bed['chr'] == regionBin[0]) & (bed['start'] >= regionBin[1])].iloc[0,3]
endBin = bed.loc[(bed['chr'] == regionBin[0]) & (bed['start'] < regionBin[2])].iloc[-1,3]
print("start bin =",startBin)
print("end bin =",endBin)
nlog.write("start bin = %s\n"%startBin)
nlog.write("end bin = %s\n"%endBin)


# Import the matrix of interactions between the bins
matrix = pd.read_csv('{}hic_results/matrix/{}/iced/{}/{}_ontarget_{}_iced.matrix'.format(path_to_hic_results_dir,
                                                                       sample_name,
                                                                       resolution, 
                                                                       sample_name,
                                                                       resolution), header=None,sep='\t')
matrix.columns = ('bin1', 'bin2','iced-int')



ROImatrix = matrix[(matrix['bin1'] >= startBin) & (matrix['bin1'] <= endBin) & (matrix['bin2'] >= startBin) & (matrix['bin2'] <= endBin)]
ROIbed = bed[(bed['bin'] >= startBin) & (bed['bin'] <= endBin)]
ROIbed.to_csv('{}/{}_{}.{}.{}_{}res.bed'.format(path_to_plotting_dir,
                                                sample_name, 
                                                regionBin[0],
                                                regionBin[1],
                                                regionBin[2],
                                                resolution), header=None, sep='\t', index=None)


lowerThreshold = np.percentile(ROImatrix['iced-int'], lowerPercentile) 
upperThreshold = np.percentile(ROImatrix['iced-int'], upperPercentile) 

nlog.write("##########\n")
nlog.write("##########\n")
nlog.write("##########\n\n")
nlog.write("lowerThreshold = %s\n"%lowerThreshold)
nlog.write("upperThreshold = %s\n\n"%upperThreshold)
nlog.write("Alternative percentage thresholds for manual setting in UCSC:\n")
nlog.write("1:  %s\n")%np.percentile(ROImatrix['iced-int'], 1)
nlog.write("2:  %s\n")%np.percentile(ROImatrix['iced-int'], 2)
nlog.write("98: %s\n")%np.percentile(ROImatrix['iced-int'], 98)
nlog.write("99: %s\n")%np.percentile(ROImatrix['iced-int'], 99)
nlog.close()

ROImatrixThreshold = ROImatrix[(ROImatrix['iced-int'] >= lowerThreshold) & (ROImatrix['iced-int'] <= upperThreshold)]
ROImatrixThreshold.to_csv('{}/{}_{}.{}.{}_{}res.matrix'.format(path_to_plotting_dir, 
                                                               sample_name,
                                                               regionBin[0],
                                                               regionBin[1],
                                                               regionBin[2],
                                                               resolution), header=None, sep='\t', index=None)

print("Data pre-processed for plotting!")

nfile = open(output, 'w')
nfile.write("python {}/HiCPlotter-py3.py -f {}/{}_{}.{}.{}_{}res.matrix -chr {} -o {}_{}  -r {} -tri 1 -bed {}/{}_{}.{}.{}_{}res.bed -n {} -hmc 1 -ptr 1".format(
        os.path.abspath("script"),
        os.path.abspath(path_to_plotting_dir), 
        sample_name,
        regionBin[0],
        regionBin[1],
        regionBin[2],
        resolution,
        region[0],
        sample_name,
        resolution,
        resolution,
        os.path.abspath(path_to_plotting_dir), 
        sample_name,
        regionBin[0],
        regionBin[1],
        regionBin[2],
        resolution,
        sample_name))
nfile.close()