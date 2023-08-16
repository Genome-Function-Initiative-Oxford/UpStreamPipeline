# Reference Genomes

This pipeline can be used to automate the download and indexing of reference genomes for use in the other upstream pipelines.
Genomes are downloaded directly from UCSC and indexed with your choice of aligner (e.g., Bowtie2, bwa-mem2).

***

### Set-up
1. Ensure that the upstream conda environment is installed correctly (see instructions [here](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline)).
2. Edit the [analysis.yaml](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/blob/main/Reference_Genomes/config/analysis.yaml) configuration file to specifiy which genome and aligner you want to use.

### Running the pipeline
Locally, select the number of cores (for parallelisation purpose)
```
snakemake --configfile=config/analysis.yaml all --cores 1
```
Cluster system (SLURM):
1. Modify parameters of [submit.sh](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/blob/main/Reference_Genomes/submit.sh)
2. Submit job:
```
sbatch submit.sh
```
