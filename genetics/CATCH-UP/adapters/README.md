# Adapter sequences

If adapter trimming is required, you must specify which adapters were used in your experiment. This pipeline use trimmomatic and extra parameter can be changed in the configuration file.
In this folder we provide two example files:
- **SE.fa** provides adapter sequences for single-end fastq files.
- **PE.fa** provides adapter sequences for paired-end fastq files.
These files contain example of adapter sequences, and the user can edit the sequences accordingly with the experiments.

For more information, browse the following links:
- [Example of adapter sequences](https://github.com/timflutre/trimmomatic/tree/master/adapters)
- [Trimmomatic documentation](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf)