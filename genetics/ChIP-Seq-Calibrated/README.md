# Calibrated ChIP-seq

### Overview
This user-friendly pipeline is built using [Snakemake](https://snakemake.readthedocs.io/en/stable/).

This pipeline is built for the comparative analysis of ChIP-seq data across biological conditions through the utilisation of spike-in normalisation. The downsampling calculation utilised in this pipeline is based on the method published in [Fursova _et al._ Mol Cell (2019)](https://doi.org/10.1016/j.molcel.2019.03.024)   

```
                                                       1                   N(spike-in in Input)
                Downsampling factor = α x --------------------------  x  -----------------------
                                              N(spike-in in ChIP)           N(target in Input)


              Where:
 N(spike-in in ChIP)    Σ reads aligning to spike-in genome for each ChIP-seq sample.
N(spike-in in Input)    Σ reads aligning to spike-in genome in the corresponding input sample.
  N(target in Input)    Σ reads aligning to mouse genome in the corresponding input sample.
                  α     coefficient applied to all files normalised together so that the value of the largest downsampling factor equals 1.
```
***
:star:  For gold-standard calibrated ChIP-seq analysis, input control samples should be provided for each ChIP sample. :star:     

***

### Preliminary requirements 

#### 1. UpStreamPipeline set-up :hammer_and_wrench:

Follow the instructions on [UpStreamPipeline](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline) to set up the correct environment. 

#### 2. Catenated genome :dna: + :dna:

In order to align to the genome + spike-in genome simultaneously, create a catenated genome as follows.

i. Take the two genomes of interest and rename chromosomes so that thet include species: 
 
```
# TARGET GENOME
sed 's/>chr/>mm39_chr/g' /databank/igenomes/Mus_musculus/UCSC/mm39/Sequence/Bowtie2Index/genome.fa > ./mm39_genome.fa

# SPIKE-IN GENOME
sed 's/>chr/>dm6_chr/g' /databank/igenomes/Drosophila_melanogaster/UCSC/dm6/Sequence/Bowtie2Index/genome.fa > ./dm6_genome.fa
```

ii. Catenate these two genomes:

```
cat ./mm39_genome.fa ./dm6_genome.fa > catenated_mm39_dm6.fa &
```

ii. Then need to build bowtie2 index [See detailed instructions on Homer webpage](http://homer.ucsd.edu/homer/basicTutorial/mapping.html)

```bowtie2-build /path/catenated_mm39_dm6.fa mm39.dm6```


#### 3. paths_to_fastqs.txt 

Needs to tab separated and without headers:   
COLUMN_1: sampleName _This is the name you want to call this sample_   
COLUMN_2: ChIP_sample _This is the ChIP sample without suffix (i.e., *R1.fastq.gz)_   

If providing input samples, also include a third column:   
COLUMN_3: input_sample _This is the input control sample that corresponds to the ChIP sample without suffix (i.e., *R1.fastq.gz)_

For example, if you have 2 samples with corresponding inputs:  
```
Sample 1: H3K4me3_ChIP_HeLa_sample1.R1.fastq.gz, H3K4me3_ChIP_HeLa_sample1.R2.fastq.gz, H3K4me3_input_HeLa_sample1.R1.fastq.gz, H3K4me3_input_HeLa_sample1.R2.fastq.gz
Sample 2: H3K4me3_ChIP_HeLa_sample2.R1.fastq.gz H3K4me3_ChIP_HeLa_sample2.R2.fastq.gz, H3K4me3_input_HeLa_sample2.R1.fastq.gz, H3K4me3_input_HeLa_sample2.R2.fastq.gz
```
paths_to_fastqs.txt should be as follows (this will be the same for both single- and paired-end reads)
```
H3K4me3_HeLa_sample1    H3K4me3_ChIP_HeLa_sample1    H3K4me3_input_HeLa_sample1
H3K4me3_HeLa_sample2    H3K4me3_ChIP_HeLa_sample2    H3K4me3_input_HeLa_sample2
```

#### 4. Modify the config.yaml file

Detailed instructions are provided in the config.yaml file for editing the necessary parameters.   

A few key points:   
- Include the full path to the catenated genome bowtie2 build.
- Correctly assign the target and spike-in genome.
- Specify whether your fastq files are single- or paired-end

***

### Additional info:
This pipeline will run all the analyses in the ChIP-Seq snakemake folder, within the config.yaml you can specify where to move all the final analysis files to within your directory and if you would like to delete any intermediate files.

#### Output folders:
When running the pipeline, results, QCs, and logs folders will be automatically generated with all related outputs inside the output folder specified in the config.yaml file.

***
### How to run the Calibrated ChIP pipeline
Option #1: run locally
Run snakemake selecting number of cores (for parallelisation purpose) 
```
snakemake --configfile=config/analysis.yaml all --cores 4
```
OPT2: SLURM   
Modify parameters of submit_upstream.sh, then submit the job as follows 
```
sbatch submit_upstream.sh
```
