# RNA-Seq

### Overview
This user-friendly pipeline is built using [Snakemake](https://snakemake.readthedocs.io/en/stable/).   

It takes raw RNA-seq data in fastq format and uses the Spliced Transcripts Alignment to a Reference([STAR](https://github.com/alexdobin/STAR)) RNA-seq read mapper to align reads to a reference genome, and outputs analysed bigwigs for visualisation in the [UCSC genome browser](https://genome.ucsc.edu/index.html). 

### Preliminary requirements 

#### 1. UpStreamPipeline set-up :hammer_and_wrench:

Follow the instructions on [UpStreamPipeline](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline) to set up the correct environment. 

#### 2. Modify the config.yaml file :computer:

Detailed instructions are provided in the [config.yaml](./config/analysis.yaml) file for editing the necessary parameters.   

Key points:   
- Specify whether your fastq files are single- or paired-end
- Provide the genome build you want to align to

***

### Additional info:
This pipeline will run all the analyses in the RNA-Seq snakemake folder, within the [config.yaml](./config/analysis.yaml) you can specify where to move all the final analysis files to within your directory and if you would like to delete any intermediate files.

#### Output folders:
When running the pipeline, results, QCs, and logs folders will be automatically generated with all related outputs inside the output folder specified in the config.yaml file.


***
### How to run the Calibrated ChIP pipeline
Option #1: run locally.   
Run snakemake selecting number of cores (for parallelisation purpose) 
```
snakemake --configfile=config/analysis.yaml all --cores 4
```
Option #2: SLURM.   
Modify parameters of submit.sh, then submit the job as follows 
```
sbatch submit.sh
```
