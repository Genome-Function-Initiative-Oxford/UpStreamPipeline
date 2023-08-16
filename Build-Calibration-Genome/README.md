# Build-Calibration-Genome

This pipeline is deisgned to build the genome that is required for the [Calibrated ChIP-seq](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/ChIP-Seq-Calibrated) pipeline.  It can be used for all combinations of species, provided there is a reference genome available.

### Overview
In brief, this pipeline proceeds as follows:
1. Two specified input genome fasta files (one for the cell type of interest and one for the spike-in) are specified by the user in the [config.yaml](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/Build-Calibration-Genome/config.yaml) file.
2. The chromosomes in these fasta files are renamed to include the genome e.g., chr1 --> chr1_mm39 (target) and chr1_dm6 (spike-in).
3. The two fasta files are catenated, the renamed chromosomes distinguish the origin species.
4. The catenated genome is indexed using Bowtie2.

***

### Set-up
1. Ensure that the upstream conda environment is installed correctly (see instructions [here](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline)).
2. Identify the paths to the fasta files of genomes you want to combine, or download from [UCSC](https://hgdownload.soe.ucsc.edu/downloads.html).
3. Edit the [config.yaml](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/Build-Calibration-Genome/config.yaml) file to detail which genomes you are using, instructions are provided within the yaml file. 

### Running the pipeline
Locally: select the number of cores (for parallelisation purpose)
```
snakemake --configfile=config/analysis.yaml all --cores 1
```
Cluster system (slurm):
1. Modify parameters of [submit_upstream.sh](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/Build-Calibration-Genome/submit_upstream.sh)
2. Submit job:
```
sbatch submit_upstream.sh
```