# Tiled-CaptureC analysis and plotting pipeline

### OVERVIEW:

This user-friendly pipeline is built using [Snakemake](https://snakemake.readthedocs.io/en/stable/).   

This pipeline is built to analyse data Tiled-C data from raw fastqs to producing heatmap and virtual Capture-C plots.   
For more information on Tiled-C, see original publication by [Oudelaar et al.](https://www.nature.com/articles/s41467-020-16598-7)   

There are three steps to this pipeline:   
**1.** Processing of of paired end fastq data using [HiC-Pro](https://github.com/nservant/HiC-Pro).   
**2.**  Heatmap generation using a modified version of [HiCPlotter](https://github.com/akdemirlab/HiCPlotter).   
**3.**  Virtual Capture-C plotting.       

***
***

### :warning: Before starting:
Fastq files must contain the suffix ```_R1.fastq.gz``` or ```_R2.fastq.gz```.   
These fastq files must be contained within a single experiment directory, with sub-directories for each sample as follows:
```
Experiment1_KO-vs_WT
├── KO_rep1
│   ├── KO_rep1_R1.fastq.gz
│   └── KO_rep1_R2.fastq.gz
├── KO_rep2
│   ├── KO_rep2_R1.fastq.gz
│   └── KO_rep2_R2.fastq.gz
└── WT_rep1
    ├── WT_rep1_R1.fastq.gz
    └── WT_rep1_R2.fastq.gz
```

### :gear: Configuration:
- The ```config/analysis.yaml``` indicates the *key*-*value* configuration with the respective documentation (open and follow carefully).


### :inbox_tray: Output folders:
- When running the pipeline, ```results```, ```QCs```, and ```logs``` folders will be automatically generated with all related outputs inside the folder (*analysis_name*) specified in the configuration file.

***

### :arrow_forward: Run snakemake:
- Run snakemake selecting number of cores (for parallelisation purpose).  
```snakemake --configfile=config/analysis.yaml all --cores 4```
- If re-run is required add flag ```--rerun-incomplete``` 
- For full documentation see [Snakemake](https://snakemake.readthedocs.io/en/stable/index.html)

#### Generating rule plots:
- ```snakemake --configfile=config/analysis.yaml --forceall --dag | dot -Tpdf > dagALL.pdf```
- ```snakemake --configfile=config/analysis.yaml --forceall --rulegraph | dot -Tpdf > dag.pdf```

#### Run snakemake (slurm):
If executing the job on a cluster system:
- Modify parameters of ```submit.sh```
- Submit job ```sbatch submit.sh```
- Note: for internal WIMM users see [SLURM-BASICS](https://datashare.molbiol.ox.ac.uk/public/man/man7/slurm-basics.7.html) for more info on how to the modify jobscript.

#### :warning: Warning:
To avoid conflicts, run or submit the job through the terminal system, and not inside a jupyter-lab terminal.
