# Download and Index Reference Genomes

This pipeline can be used, if you need to download the reference genome from UCSC and index it with the relevant aligner (e.g., Bowtie2 and bwa-mem2).
       
### Configuration:
- This pipeline will run all the analyses in this folder, within the ```config/analysis.yaml``` you can specify where to move all the final analysis files to within your directory.


### Output folders:
- When running the pipeline, ```results``` folder will be automatically generated with all related outputs inside the folder named (*analysis_name*) specified in the configuration file.

### Generating rule plots:
- ```snakemake --forceall --configfile=config/analysis.yaml --dag | dot -Tpdf > dagALL.pdf```
- ```snakemake --forceall --configfile=config/analysis.yaml --rulegraph | dot -Tpdf > dag.pdf```

### Run snakemake:
- Run snakemake selecting number of cores (for parallelisation purpose) ``` snakemake --configfile=config/analysis.yaml all --cores 1```

### Run snakemake (slurm):
- Modify parameters of ```submit_upstream.sh```
- Submit job ```sbatch submit_upstream.sh```

### Warning:
Run or submit the job through the terminal system and not inside e.g. jupyter-lab terminal.