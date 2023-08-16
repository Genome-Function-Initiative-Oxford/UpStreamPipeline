#!/usr/bin/env
# coding: utf-8

# -------------------------------------------
# ## Virtual Capture Plotting from Tiled-C ##
# -------------------------------------------
# May 2023    
# Emily Georgiades

# In summary this script takes the output from HiCPro,
# and filters for interactions with your viewpoint of interest.
# You can specify multiple replicates and samples, these will be 
# grouped and plotted on the same figure.

# For reference:
# Alpha globin enhancer coordinates (mm39):
    # R2 region = ['chr11','32200546','32201851']
    # R1 region = ['chr11','32195028','32196147']
    # R3 region = ['chr11','32206048','32207191']
    # Rm region = ['chr11','32215011','32215922']
    # R4 region = ['chr11','32218783','32219689']

    
##############################################
# START
##############################################  
    
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import interpolate
import numpy as np
import itertools
import warnings
import sys, os, re, glob, shutil

# Bad practise but doing it anyway...
warnings.filterwarnings("ignore")

##############################################
# MODIFY THESE PARAMETERS ONLY!
##############################################

# Specify viewpoint coordinates
view_point = re.split(r":|-", sys.argv[1])

# Specify resolution
resolution = int(sys.argv[2])

# Specifiy how many bins you want to plot
plotWindow = int(sys.argv[3]) 

# Directory containing matrix files:
directory_orig = sys.argv[4]

# These will be used for plot titles etc
sampleNames = glob.glob(directory_orig+"/*")
sampleNames = [s.split("/")[-1] for s in sampleNames]

# List of matrix files to plot (make sure resolution matches!)
matrixFiles = []
for s in sampleNames:
    matrixFiles.append(s+'_ontarget_'+str(resolution)+'_iced.matrix')

# make tmp folder with all matrix files
for s, m in zip(sampleNames, matrixFiles):
    src = directory_orig+os.sep+s+os.sep+"iced"+os.sep+str(resolution)+os.sep+m
    dst = directory_orig+os.sep+'tmp_matrix/'

    if not os.path.exists(dst):
        os.makedirs(dst)

    shutil.copy(src, dst)

directory = dst

# Directory to save plots:
figure_dir = sys.argv[5]

# Bedfile containing bin coordinates (this should be identical for all samples so just choose one)
bed_scr = directory_orig+os.sep+sampleNames[0]+os.sep+"raw"+os.sep+str(resolution)+os.sep+sampleNames[0]+"_ontarget_"+str(resolution)+"_abs.bed"
bed_dst = directory_orig+os.sep+'tmp_matrix/'
shutil.copy(bed_scr, bed_dst)

bedFile = sampleNames[0]+"_ontarget_"+str(resolution)+"_abs.bed"

# These must be used in the sample names and are used to group sample condtions
conditions = sys.argv[6].split(',')

##############################################
# DO NOT EDIT FROM HERE!
##############################################

# Round the ROI values to nearest bin 
def custom_round(x, base=resolution):
    return int(base * round(float(x)/base))

regionBin = [view_point[0],(custom_round(view_point[1])),(custom_round(view_point[2]))]

print("Viewpoint in contained within this region:",regionBin)
print("Region coordinates:", regionBin[0],":", int(regionBin[1]-((plotWindow/2)*resolution)),"-", int(regionBin[1]+((plotWindow/2)*resolution)))

bed = pd.read_csv('{}/{}'.format(directory, bedFile), sep='\t', header=None)
bed.columns = ('chr', 'start' , 'end', 'bin')
BOI = bed.loc[(bed["chr"] == regionBin[0]) & (bed["start"] == regionBin[1])]
viewpointBin = BOI.iloc[0]['bin']

print("Bin containing viewpoint =", viewpointBin)

binLimits = list(range((viewpointBin+1-plotWindow/2).astype(int), (viewpointBin+plotWindow/2).astype(int)))

toPlot = pd.DataFrame(columns = ['partnerBin'])
toPlot['partnerBin'] = binLimits

# For each sample, select only interactions from viewpoint.
for i, j in zip(matrixFiles,sampleNames):
    matrix = pd.read_csv('{}/{}'.format(directory,i), sep='\t', header=None)
    matrix.columns = ('bin1', 'bin2' , 'int')
    
    BOI_interactions = matrix.loc[(matrix['bin1'] == viewpointBin) | (matrix['bin2'] == viewpointBin)]
    BOI_interactions['partnerBin'] = (BOI_interactions['bin1']+ BOI_interactions['bin2']) - viewpointBin
    
    sortedBins = BOI_interactions.sort_values('partnerBin')
    sortedBinsfiltered = (sortedBins.loc[(sortedBins['partnerBin'] > (viewpointBin - plotWindow/2)) & (sortedBins['partnerBin'] < (viewpointBin + plotWindow/2))]).reset_index()
    colSelect = sortedBinsfiltered[['partnerBin','int']]
    colSelect.columns = ('partnerBin',j)
    toPlot = pd.merge(toPlot, colSelect, how="left", on="partnerBin")
    

##############################################
# NORMALISATION AND SMOOTHING
############################################## 
    
# Calculate the total interactions for each sample for normalisation
add = toPlot.sum()

# Calculate the minimum interaction sum
minIndex = min(range(len(add)), key=add.__getitem__)

# Minimum value:
add[minIndex]

# Calculate values divided by min
divided = (add/(add[minIndex]))[1:]


# Create new columns for normalised values
for i, j in zip(sampleNames,divided):
    newName = i + "_norm"
    toPlot[newName] = toPlot[i]/j

# Using a rolling mean to smooth across datapoints  
for i in sampleNames:
    newName = i + "_smooth"
    toPlot[newName] = toPlot[(i + "_norm")].rolling(2).mean()
    
##############################################
# PLOTTING USING SEABORN
############################################## 

# Select only th columns containing the normalised, smoothed data
toPlotFinal = toPlot.loc[:, toPlot.columns.str.contains('smooth')]
toPlotFinal['partnerBin'] = binLimits          

# Melt dataframe in order to group replicates by condition
options = '|'.join(conditions)
melting= pd.melt(toPlotFinal, ['partnerBin'])
melting["Condition"] = melting['variable'].str.extract("("+options+")")[0]


# Plot the data
sns.set_theme(style="white")

sns.lineplot(x='partnerBin', 
             y='value', 
             hue='Condition', # plots halos around mean.
             estimator='mean', # mean is the default estimator for halo
             errorbar=('ci', 95), # 95% CI is the default setting, can be changed
             data=melting).set(title='Virtual Capture-C\nviewpoint: {} (mm39)'.format(' '.join(view_point)))

plt.xlabel('bin')
plt.ylabel('Normalised interaction frequency')

# Save plots to specified directory
plt.savefig('{}/virtualCapture_viewpoint:{}.{}-{}_{}bp.png'.format(figure_dir, 
                                                                   view_point[0],
                                                                   view_point[1],
                                                                   view_point[2],
                                                                   resolution))

shutil.rmtree(directory)   