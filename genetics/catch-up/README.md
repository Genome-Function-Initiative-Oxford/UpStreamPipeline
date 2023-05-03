# Bulk ChIP and ATAC sequencing upstream analysis

### Note:
- This pipeline works with both single and paired-end fastq data.
- This pipeline will run all the analyses in this folder, within the ```config/analysis.yaml``` you can specify where to move all the final analysis files to within your directory and if you would like to delete any intermediate files.

### Configuration:
- The ```config/analysis.yaml``` indicates the *key*-*value* configuration with the respective documentation (open and follow carefully).
- In ```fastqfile_home_dir.txt``` must be specified sample names without including read numbers and extension (i.e., *_R1/_R2* and *.fastq.gz*), for example for the following fastq files (single-end sample's names must end with *.fastq.gz*, whilst paired-end with *_R+.fastq.gz*, and they must be stored in the same directory):
    ```
        Sample1_conditionA_R1.fastq.gz
        Sample1_conditionA_R2.fastq.gz
        Sample1_conditionB_R1.fastq.gz
        Sample1_conditionB_R2.fastq.gz
        Sample2_conditionA_R1.fastq.gz
        Sample2_conditionA_R2.fastq.gz
        Sample2_conditionB_R1.fastq.gz
        Sample2_conditionB_R2.fastq.gz
    ```
    In addition, the listed samples must be contained in the folder defined in the *fastq_home_dir* key in ```config/analysis.yaml```). Every line should contain one sample as follows:
    ```
        Sample1_conditionA
        Sample1_conditionB
        Sample2_conditionA
        Sample2_conditionB
    ```
    Generalisation of ```fastqfile_home_dir.txt``` 
- **If merging of samples is required**, in ```merge_bams.txt``` define the bam files' prefixes to be merged. If the sequencing data is composed of replicates, samples, or lanes, the user can specify to merge them or carry on the analysis keeping them separate. If the user chooses to merge bams a common prefix must be specified for the merged bams. Every line should contain one sample prefix as follows (i.e., a list of all bams to be merged):
    ```
        Sample1
        Sample2
    ```
    (Generalisation of ```merge_bams.txt```)
- There is an option for adapter trimming, which can be specified in the configuration file. The user must provide the correct adapter sequences.

### Output folders:
- When running the pipeline, ```results```, ```QCs```, and ```logs``` folders will be automatically generated with all related outputs inside the folder (*analysis_name*) specified in the configuration file.

### Generating rule plots:
- ```snakemake --configfile=config/analysis.yaml --forceall --dag | dot -Tpdf > dagALL.pdf```
- ```snakemake --configfile=config/analysis.yaml --forceall --rulegraph | dot -Tpdf > dag.pdf```

### Run snakemake:
- Run snakemake selecting number of cores (for parallelisation purpose) ```snakemake --configfile=config/analysis.yaml all --cores 4```

### Run snakemake (slurm):
- Modify parameters of ```submit_upstream.sh```
- Submit job ```sbatch submit_upstream.sh```

### Warning:
1) Run or submit the job through the terminal system and not inside e.g. jupyter-lab terminal.
2) add info about modify_fastq_names.py
3) add concatenation file info